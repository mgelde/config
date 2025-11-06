#! /bin/env/python3

import subprocess
import json
import sys
import re


def get_tree():
    try:
        output = subprocess.check_output(['swaymsg', '-t', 'get_tree', '-r'])
        return json.loads(output.decode())
    except subprocess.CalledProcessError as err:
        print(
            f'[!] Could not call swaymsg command. Exited with code {err.returncode}.',
            file=sys.stderr)
        print(f'   Reason: {err.stderr}')
        sys.exit(1)
    except (json.JSONDecodeError, UnicodeDecodeError) as err:
        print(f'[!] Error cannot decode JSON: {err!s}', file=sys.stderr)
        pass


def extract_windows(tree, workspace):
    windows = []

    if 'type' in tree and tree['type'] in ['con', 'floating_con'
                                           ] and tree['name']:
        # need to add the enclosing workspace, because we need it later...
        tree['workspace'] = workspace
        windows.append(tree)
    if 'type' in tree and tree['type'] == 'workspace':
        workspace = tree['name']
    if 'nodes' in tree:
        for x in tree['nodes']:
            windows.extend(extract_windows(x, workspace))
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


def main():
    tree = get_tree()
    windows = extract_windows(tree, -1)

    wofi_choice = '\n'.join([
        f'<!-- {i} -->{window["name"]}  <small>on workspace "{window["workspace"]}"</small>'
        for i, window in enumerate(windows) if window['name']
    ])

    try:
        selected = subprocess.check_output(
            ['wofi', '-dm'], input=wofi_choice.encode()).decode().strip()
    except subprocess.CalledProcessError:
        # wofi aborted; maybe the user dismissed. do nothing
        sys.exit(0)

    match = re.match(r'<!-- (\d+) -->', selected)
    if not match:
        print(f'[!] Cannot find this window: {selected}')
        sys.exit(1)
    index = int(match.group(1))
    focus_window(windows[index])


if __name__ == '__main__':
    main()
