#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") <target-directory>" >&2
}

assert_from_repo_root() {
    local cwd_abs
    cwd_abs="$(abspath "$PWD")"
    if [[ "$cwd_abs" != "$repo_root" ]]; then
        echo "Error: run this script from the repo root: $repo_root" >&2
        exit 1
    fi
}

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

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

script_path="$(abspath "${BASH_SOURCE[0]}")"
script_dir="$(dirname "$script_path")"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
    echo "Error: could not resolve git repo root from $script_dir" >&2
    exit 1
fi
if [[ "$script_dir" != "$repo_root/scripts" ]]; then
    echo "Error: expected script to live in repo scripts dir: $repo_root/scripts" >&2
    exit 1
fi
assert_from_repo_root

target_dir="$1"
if [[ ! -d "$target_dir" ]]; then
    echo "Error: target directory does not exist: $target_dir" >&2
    exit 1
fi

target_dir_abs="$(abspath "$target_dir")"

found=0
while IFS= read -r -d '' link_path; do
    if ! link_target="$(abspath "$link_path" 2>/dev/null)"; then
        continue
    fi
    case "$link_target" in
        "$script_dir"|"$script_dir"/*)
            printf '%s -> %s\n' "$link_path" "$link_target"
            found=1
            ;;
    esac
done < <(find "$target_dir_abs" -type l -print0)

if [[ "$found" -eq 0 ]]; then
    echo "No symlinks in $target_dir_abs point into $script_dir"
fi
