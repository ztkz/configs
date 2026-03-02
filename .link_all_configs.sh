#!/usr/bin/env bash

set -euo pipefail

abspath() {
    local path="$1"

    if [[ "$path" == "/" ]]; then
        echo "/"
        return 0
    fi

    while [[ -L "$path" ]]; do
        local link_dir
        link_dir="$(cd -P "$(dirname "$path")" >/dev/null 2>&1 && pwd)" || return 1
        path="$(readlink "$path")" || return 1
        [[ "$path" != /* ]] && path="$link_dir/$path"
    done

    if [[ -d "$path" ]]; then
        (cd -P "$path" >/dev/null 2>&1 && pwd)
        return 0
    fi

    local dir
    local base
    dir="$(cd -P "$(dirname "$path")" >/dev/null 2>&1 && pwd)" || return 1
    base="$(basename "$path")"
    printf '%s/%s\n' "$dir" "$base"
}

assert_from_repo_root() {
    local cwd_abs
    cwd_abs="$(abspath "$PWD")"
    if [[ "$cwd_abs" != "$REPO_ROOT" ]]; then
        echo "Error: run this script from the repo root: $REPO_ROOT" >&2
        exit 1
    fi
}

assert_symlink_target() {
    local destination="$1"
    local expected_target="$2"
    local raw_target
    local resolved_target
    local resolved_expected

    raw_target="$(readlink "$destination")"
    if [[ "$raw_target" == /* ]]; then
        resolved_target="$(abspath "$raw_target")"
    else
        resolved_target="$(abspath "$(dirname "$destination")/$raw_target")"
    fi
    resolved_expected="$(abspath "$expected_target")"

    if [[ "$resolved_target" != "$resolved_expected" ]]; then
        echo "Error: existing symlink points to unexpected target:" >&2
        echo "  path:     $destination" >&2
        echo "  expected: $resolved_expected" >&2
        echo "  actual:   $resolved_target" >&2
        exit 1
    fi
}

migrate_destination_into_repo() {
    local source="$1"
    local destination="$2"

    echo "Migrating existing destination into repo:"
    echo "  $destination -> $source"
    mkdir -p "$(dirname "$source")"
    rm -rf "$source"
    mv "$destination" "$source"
    mkdir -p "$(dirname "$destination")"
    ln -s "$source" "$destination"
}

link_one() {
    local rel_path="$1"
    local source="$REPO_ROOT/$rel_path"
    local destination="$HOME_DIR/$rel_path"

    if [[ ! -e "$source" && ! -L "$source" ]]; then
        echo "Error: source missing in repo: $source" >&2
        exit 1
    fi

    if [[ -L "$destination" ]]; then
        assert_symlink_target "$destination" "$source"
        echo "OK: symlink already points to source: $destination"
        return 0
    fi

    if [[ -e "$destination" ]]; then
        migrate_destination_into_repo "$source" "$destination"
        return 0
    fi

    mkdir -p "$(dirname "$destination")"
    ln -s "$source" "$destination"
    echo "Linked: $destination -> $source"
}

SCRIPT_PATH="$(abspath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || true)"
HOME_DIR="${HOME:?HOME is not set}"

if [[ -z "$REPO_ROOT" ]]; then
    echo "Error: could not resolve git repo root from $SCRIPT_DIR" >&2
    exit 1
fi

if [[ "$SCRIPT_DIR" != "$REPO_ROOT" ]]; then
    echo "Error: expected script to live in repo root: $REPO_ROOT" >&2
    exit 1
fi

assert_from_repo_root

echo "Linking from $REPO_ROOT to $HOME_DIR"

link_one .local/bin/black_line_length
link_one .vim/after/ftplugin/python.vim
link_one .tmux.conf
link_one .vimrc
link_one .zshrc
link_one .zshrc.my
link_one .zshrc.omz
link_one .config/pylintrc
link_one .config/.flake8
