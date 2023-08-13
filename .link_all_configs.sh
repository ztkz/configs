realpath_s() {
    python3 -c "import os; print(os.path.abspath('$1'))"
}

FROM_DIR=$(dirname "$PWD"/"$0")
FROM_DIR=$(realpath_s "$FROM_DIR")
TO_DIR="$HOME"

echo Linking from "$FROM_DIR" to "$TO_DIR"."\n"

cfg_link_file() {
    echo ln -s "$FROM_DIR"/"$1" "$TO_DIR"/"$1"
    local TARGET_DIR=$(dirname "$TO_DIR"/"$1")
    mkdir -p "$TARGET_DIR"
    ln -s "$FROM_DIR"/"$1" "$TO_DIR"/"$1"
    echo "\n"
}

cfg_link_file .local/bin/black_line_length
cfg_link_file .vim/after/ftplugin/python.vim
cfg_link_file .tmux.conf
cfg_link_file .vimrc
cfg_link_file .zshrc
cfg_link_file .zshrc.my
cfg_link_file .zshrc.omz
cfg_link_file .config/pylintrc
cfg_link_file .config/.flake8
