#! /bin/env/python3

import argparse
import html
import json
import logging
import os
import re
import socket
import struct
import subprocess
import sys
from enum import IntEnum

try:
    import Levenshtein

    def select_matching_item(key, items):
        found = items[0]
        score = Levenshtein.distance(key, found)
        for item in items[1:]:
            newscore = Levenshtein.distance(key, item)
            if score < newscore:
                continue
            found = item
            score = newscore
        return found
except (ModuleNotFoundError, ValueError):

    def select_matching_item(_, items):
        return items[0]


try:
    import gi
    gi.require_version('Gtk', '4.0')
    from gi.repository import Gtk, Gdk, GioUnix

    def lookup_icon(name):
        path = None
        theme = Gtk.IconTheme.get_for_display(Gdk.Display.get_default())
        logging.info(f'looking up icon for name: {name}')

        if name is not None:
            search_terms = {
                name.split('.')[-1],  # for names like org.gnome.Evolution
                name,
                name.split('.')[-1].lower(),
                name.split('.')[-1].lower().capitalize(),
                name.split()[0],
                name.split()[0].capitalize()
            }

            app_info_candidates = None
            names = None
            for term in search_terms:
                app_info_candidates = GioUnix.DesktopAppInfo.search(term)
                if not app_info_candidates:
                    logging.debug(f'Found no desktop file for {term}')
                    continue
                logging.debug(
                    f'Found desktop files for {term}: {app_info_candidates}')
                desktop_filename = select_matching_item(
                    term, app_info_candidates[0])
                logging.debug(
                    f'Selected desktop files for {term}: {desktop_filename}')
                icon = GioUnix.DesktopAppInfo.new(desktop_filename).get_icon()
                if icon:
                    names = icon.get_names()
                    break
            if not names:
                names = [name]
            path = theme.lookup_icon(names[0], names[1:], 0, 1, 0,
                                     0).get_file().get_path()
        if not path:
            path = theme.lookup_icon('application-x-executable', None, 0, 1, 0,
                                     0).get_file().get_path()
        return path

    HAVE_ICONS = True
except (ModuleNotFoundError, ValueError):
    HAVE_ICONS = False


class MessageType(IntEnum):

    MT_CMD = 0
    MT_GET_TREE = 4


class SwayError(Exception):

    def __init__(self, is_parser, msg):
        self._is_parser = is_parser
        self._msg = msg

    def is_parser_error(self):
        return self._is_parser

    def msg(self):
        return self._msg


class Sway:

    def __init__(self):
        self._socket = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

    def __enter__(self):
        self._socket.connect(os.getenv('SWAYSOCK'))
        return self

    def __exit__(self, *_unused):
        self._socket.close()

    @staticmethod
    def _build_msg(kind, payload):
        match kind:
            case MessageType.MT_CMD:
                pass
            case MessageType.MT_GET_TREE:
                pass
            case _:
                raise ValueError(f'Unknown message type: {kind}')
        return struct.pack('=6sII', b'i3-ipc', len(payload), kind) + payload

    _HEADER_SIZE = 14

    @staticmethod
    def _parse_header(header, expected_kind=None):
        magic, length, kind = struct.unpack('=6sII', header)
        if magic != b'i3-ipc' or (expected_kind and kind != expected_kind):
            raise ValueError(f'{magic}:{kind} was not expected')
        return length

    def _get_response(self, expected_kind=None):
        response_length = Sway._parse_header(
            self._socket.recv(Sway._HEADER_SIZE), expected_kind)
        return json.loads(self._socket.recv(response_length).decode())

    def get_tree(self):
        msg = Sway._build_msg(MessageType.MT_GET_TREE, b'')
        self._socket.send(msg)
        return self._get_response(MessageType.MT_GET_TREE)

    def cmd(self, command_string):
        msg = Sway._build_msg(MessageType.MT_CMD, command_string.encode())
        self._socket.send(msg)
        response = self._get_response(MessageType.MT_CMD)
        for item in response:
            if item['success'] is False:
                raise SwayError(item['parser_error'], item['error'])


def extract_windows(tree, workspace):
    windows = []

    if 'type' in tree:
        if tree['type'] in ['con', 'floating_con'] and tree['name']:
            # need to add the enclosing workspace, because we need it later...
            tree['workspace'] = workspace
            windows.append(tree)
        if tree['type'] == 'workspace':
            workspace = tree['name']
    for subtree in ['nodes', 'floating_nodes']:
        try:
            for x in tree[subtree]:
                windows.extend(extract_windows(x, workspace))
        except KeyError:
            pass
    return windows


def focus_window(window, sway):
    # hopefully these are enough for all use-cases
    descriptor = [
        # title accepts pcre expressions, so we need to escape
        f'title="{re.escape(window["name"])}"',
        f'pid={window["pid"]}' if 'pid' in window else '',
        f'workspace="{window["workspace"]}"'
    ]
    if window['app_id'] is not None:
        descriptor.append(f'app_id="{window["app_id"]}"')
    elif window['window'] is not None and 'window_properties' in window:
        descriptor.append(f'class="{window["window_properties"]["class"]}"')
    descriptor_string = ' '.join(descriptor)
    command = f'[{descriptor_string}] focus'
    try:
        sway.cmd(command)
    except SwayError as err:
        if err.is_parser_error():
            print(f'[!] Parser error for command: {err.msg()}',
                  file=sys.stderr)
        else:
            print(f'[!] Command failed: {command}', file=sys.stderr)
        sys.exit(1)


def build_wofi_choices(windows, use_icons=False):
    choices = []

    for i, window in enumerate(windows):
        text = f'<!-- {i} -->{html.escape(window["name"])}  <small>on workspace'\
                f' "{html.escape(window["workspace"])}"</small>'
        if use_icons:
            if window['app_id'] is not None:
                icon = lookup_icon(window['app_id'])
            elif window['window'] is not None and 'window_properties' in window:
                icon = lookup_icon(window['window_properties']['class'])
            else:
                icon = lookup_icon(None)
            text = f'img:{icon}:text:{text}'
        choices.append(text)
    return choices


def parse_args():
    argparser = argparse.ArgumentParser()
    argparser.add_argument('--log-level',
                           choices=['ERROR', 'WARN', 'INFO', 'DEBUG'],
                           help='Desireg log-level (default: WARN)',
                           default='WARN')
    return argparser.parse_args()


def main():
    args = parse_args()

    logging.basicConfig(level=logging.getLevelNamesMapping()[args.log_level],
                        stream=sys.stderr)
    with Sway() as sway:
        tree = sway.get_tree()
        windows = extract_windows(tree, -1)
        if not windows:
            sys.exit(0)

        try:
            selected = subprocess.check_output(
                ['wofi', '-dm'],
                input='\n'.join(build_wofi_choices(
                    windows, HAVE_ICONS)).encode()).decode().strip()
        except subprocess.CalledProcessError:
            # wofi aborted; maybe the user dismissed. do nothing
            sys.exit(0)

        match = re.search(r'<!-- (\d+) -->', selected)
        if not match:
            print(f'[!] Cannot find this window: {selected}')
            sys.exit(1)
        index = int(match.group(1))
        focus_window(windows[index], sway)


if __name__ == '__main__':
    main()
