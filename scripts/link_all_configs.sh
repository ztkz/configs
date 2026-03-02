#!/usr/bin/env bash

set -euo pipefail

LINK_PATHS=(
    .config/nvim
    .bashrc
    .vim/after/ftplugin/python.vim
    .tmux.conf
    .vimrc
    .zshrc
    .zshrc.my
    .zshrc.my.mac
    .zshrc.omz
)

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

    echo "Copying existing destination into repo and linking:"
    echo "  $destination -> $source"
    mkdir -p "$(dirname "$source")"
    rm -rf "$source"
    cp -a "$destination" "$source"
    rm -rf "$destination"
    mkdir -p "$(dirname "$destination")"
    ln -s "$source" "$destination"
}

link_one() {
    local rel_path="$1"
    local source="$REPO_ROOT/$rel_path"
    local destination="$HOME_DIR/$rel_path"

    if [[ ! -e "$source" && ! -L "$source" ]]; then
        if [[ -L "$destination" ]]; then
            echo "Error: source missing in repo and destination is a symlink: $destination" >&2
            exit 1
        fi

        if [[ -e "$destination" ]]; then
            migrate_destination_into_repo "$source" "$destination"
            return 0
        fi

        echo "Error: source missing in repo and destination missing in home: $rel_path" >&2
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

is_linked_path() {
    local repo_file="$1"
    local link_path
    for link_path in "${LINK_PATHS[@]}"; do
        if [[ "$repo_file" == "$link_path" || "$repo_file" == "$link_path/"* ]]; then
            return 0
        fi
    done
    return 1
}

warn_unlinked_repo_files() {
    local repo_file
    local warning_count=0
    local had_warning=0

    while IFS= read -r -d '' repo_file; do
        if [[ ! -e "$REPO_ROOT/$repo_file" && ! -L "$REPO_ROOT/$repo_file" ]]; then
            continue
        fi

        case "$repo_file" in
            scripts/*|.gitignore)
                continue
                ;;
        esac

        if is_linked_path "$repo_file"; then
            continue
        fi

        if [[ "$had_warning" -eq 0 ]]; then
            echo "Warnings: tracked files not linked by this script:" >&2
            had_warning=1
        fi

        printf '  - %s\n' "$repo_file" >&2
        warning_count=$((warning_count + 1))
    done < <(git -C "$REPO_ROOT" ls-files -z)

    if [[ "$warning_count" -gt 0 ]]; then
        echo "Total unlinked tracked files (excluding scripts/ and .gitignore): $warning_count" >&2
    else
        echo "All tracked files (excluding scripts/ and .gitignore) are covered by LINK_PATHS."
    fi
}

SCRIPT_PATH="$(abspath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || true)"
HOME_DIR="${HOME:?HOME is not set}"

if [[ -z "$REPO_ROOT" ]]; then
    echo "Error: could not resolve git repo root from $SCRIPT_DIR" >&2
    exit 1
fi

if [[ "$SCRIPT_DIR" != "$REPO_ROOT/scripts" ]]; then
    echo "Error: expected script to live in repo scripts dir: $REPO_ROOT/scripts" >&2
    exit 1
fi

assert_from_repo_root

echo "Linking from $REPO_ROOT to $HOME_DIR"

for rel_path in "${LINK_PATHS[@]}"; do
    link_one "$rel_path"
done

warn_unlinked_repo_files
