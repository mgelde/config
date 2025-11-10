#! /bin/env/python3

import json
import os
import re
import socket
import struct
import subprocess
import sys
from enum import IntEnum

try:
    import gi
    gi.require_version('Gtk', '4.0')
    from gi.repository import Gtk, Gdk, GioUnix

    def lookup_icon(name):
        path = None
        theme = Gtk.IconTheme.get_for_display(Gdk.Display.get_default())

        if name is not None:
            search_terms = {
                name.split('.')[-1],  # for names like org.gnome.Evolution
                name,
                name.split('.')[-1].lower(),
                name.split('.')[-1].lower().capitalize(),
            }
            app_info_candidates = None
            names = None
            for name in search_terms:
                app_info_candidates = GioUnix.DesktopAppInfo.search(name)
                if not app_info_candidates:
                    continue
                for desktop_filename in app_info_candidates[0]:
                    desktop_file = GioUnix.DesktopAppInfo.new(desktop_filename)
                    icon = desktop_file.get_icon()
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
        err_msg = []
        for item in response:
            if item['success'] is False:
                err_msg.append(
                    f'parser_error={item["parse_error"]}. message: {item["error"]}'
                )
        if err_msg:
            raise ValueError(f'Command not successful: {" ; ".join(err_msg)}')


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
        f'title="{window["name"]}"',
        f'pid={window["pid"]}' if 'pid' in window else '',
        f'app_id={window["app_id"]}' if 'app_id' in window and window['app_id']
        else '', f'workspace="{window["workspace"]}"'
    ]

    descriptor_string = ' '.join(descriptor)
    sway.cmd(f'[{descriptor_string}] focus')


def build_wofi_choices(windows, use_icons=False):
    choices = []

    for i, window in enumerate(windows):
        text = f'<!-- {i} -->{window["name"]}  <small>on workspace "{window["workspace"]}"</small>'
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


def main(sway):
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
    with Sway() as sway_ipc:
        main(sway_ipc)
