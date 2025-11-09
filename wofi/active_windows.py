#! /bin/env/python3

import json
import re
import subprocess
import sys

try:
    import gi
    gi.require_version('Gtk', '4.0')
    from gi.repository import Gtk, Gdk, GioUnix

    def lookup_icon(app_id):
        try:
            desktop_filename = GioUnix.DesktopAppInfo.search(app_id)[0][-1]
            desktop_file = GioUnix.DesktopAppInfo.new(desktop_filename)
            names = desktop_file.get_icon().get_names()
        except IndexError:
            names = [app_id]
        theme = Gtk.IconTheme.get_for_display(Gdk.Display.get_default())
        path = theme.lookup_icon(names[0], names[1:], 0, 1, 0,
                                 0).get_file().get_path()
        if not path:
            path = theme.lookup_icon('application-x-executable', None, 0, 1, 0,
                                     0).get_file().get_path()
        return path

    HAVE_ICONS = True
except (ModuleNotFoundError, ValueError):
    HAVE_ICONS = False


def get_tree():
    try:
        output = subprocess.check_output(['swaymsg', '-t', 'get_tree', '-r'])
        return json.loads(output.decode())
    except subprocess.CalledProcessError as err:
        print(
            f'[!] Could not call swaymsg command. Exited with code {err.returncode}.',
            file=sys.stderr)
        print(f'   Reason: {err.stderr}')
    except (json.JSONDecodeError, UnicodeDecodeError) as err:
        print(f'[!] Error cannot decode JSON: {err!s}', file=sys.stderr)
    sys.exit(1)


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


def focus_window(window):
    # hopefully these are enough for all use-cases
    descriptor = [
        f'title="{window["name"]}"',
        f'pid={window["pid"]}' if 'pid' in window else '',
        f'app_id={window["app_id"]}' if 'app_id' in window and window['app_id']
        else '', f'workspace="{window["workspace"]}"'
    ]

    descriptor_string = ' '.join(descriptor)
    subprocess.check_call(['swaymsg', f'[{descriptor_string}]', 'focus'])


def build_wofi_choices(windows, use_icons=False):
    choices = []

    for i, window in enumerate(windows):
        text = f'<!-- {i} -->{window["name"]}  <small>on workspace "{window["workspace"]}"</small>'
        if use_icons:
            icon = lookup_icon(window['app_id'])
            text = f'img:{icon}:text:{text}'
        choices.append(text)
    return choices


def main():
    tree = get_tree()
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
    focus_window(windows[index])


if __name__ == '__main__':
    main()
