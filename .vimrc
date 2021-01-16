" Welcome to Vim (http://go/vim).
"
" If you see this file, your homedir was just created on this workstation.
" That means either you are new to Google (in that case, welcome!) or you
" got yourself a faster machine.
" Either way, the main goal of this configuration is to help you be more
" productive; if you have ideas, praise or complaints, direct them to
" vi-users@google.com (http://g/vi-users). We'd especially like to hear from you
" if you can think of ways to make this configuration better for the next
" Noogler.
" If you want to learn more about Vim at Google, see http://go/vimintro.

if $SHELL =~ 'bin/fish'
  set shell=/bin/sh
endif

" Enable modern Vim features not compatible with Vi spec.
set nocompatible

"======================"
" Vundle configuration "
"======================"

filetype off
set rtp+=~/.vim/bundle/Vundle.vim
if isdirectory(expand('$HOME/.vim/bundle/Vundle.vim'))
  call vundle#begin()
  " Required
  Plugin 'VundleVim/Vundle.vim'
  " Plugin 'gmarik/vundle'
  " Install plugins that come from github.  Once Vundle is installed, these can be
  " installed with :PluginInstall
  Plugin 'google/vim-colorscheme-primary'
  Plugin 'vim-airline/vim-airline'
  Plugin 'vim-airline/vim-airline-themes'
  Bundle 'edkolev/tmuxline.vim'
  Plugin 'scrooloose/nerdtree'
  Plugin 'vim-syntastic/syntastic'
  " Plugin 'tpope/vim-surround.git'  " TODO.
  " Plugin 'chriskempson/base16-vim'  # TODO.
  Plugin 'danielwe/base16-vim'
  Plugin 'ctrlpvim/ctrlp.vim'
  Plugin 'FelikZ/ctrlp-py-matcher'
  " Plugin 'altercation/vim-colors-solarized'
  Plugin 'majutsushi/tagbar'
  Plugin 'scrooloose/nerdcommenter'
  " Plugin 'easymotion/vim-easymotion'  " TODO.
  " Plugin 'ervandew/supertab'  " TODO.
  " Add maktaba and codefmt to the runtimepath.
  " (The latter must be installed before it can be used.)
  Plugin 'google/vim-maktaba'
  Plugin 'google/vim-codefmt'
  " Also add Glaive, which is used to configure codefmt's maktaba flags. See
  " `:help :Glaive` for usage.
  Plugin 'google/vim-glaive'
  " https://github.com/tpope/vim-sensible  " TODO.
  Plugin 'vim-scripts/vcscommand.vim'
  Plugin 'airblade/vim-gitgutter'
  " Plugin 'tpope/vim-fugitive.git'
  " Plugin 'lyokha/vim-xkbswitch'
  Plugin 'ryanoasis/vim-devicons'
  Plugin 'mhinz/vim-signify'
  Plugin 'tpope/vim-obsession'
  Plugin 'editorconfig/editorconfig-vim'
  Plugin 'ambv/black'
  Plugin 'lifepillar/vim-solarized8'
  " Plugin 'noahfrederick/vim-noctu'
  " Plugin 'jeffkreeftmeijer/vim-dim'
  Plugin 'dawikur/base16-vim-airline-themes'
  """""""""""""""""""""
  " Plugin 'scrooloose/nerdcommenter'
  " Plugin 'Valloric/MatchTagAlways'
  " Plugin 'vim-scripts/netrw.vim'
  " Plugin 'tpope/vim-sensible'
  " Plugin 'SirVer/ultisnips'
  " Provide many default snippets for a variety of snippets.
  " Uncomment and :PluginInstall to enable
  " Plugin 'honza/vim-snippets'

  call vundle#end()
else
  echomsg 'Vundle is not installed. You can install Vundle from'
      \ 'https://github.com/VundleVim/Vundle.vim'
endif

"========"
" Glaive "
"========"

" the glaive#Install() should go after the "call vundle#end()"
call glaive#Install()
" Optional: Enable codefmt's default mappings on the <Leader>= prefix.
Glaive codefmt plugin[mappings]
autocmd FileType python let b:codefmt_formatter = 'yapf'
" Glaive codefmt google_java_executable="java -jar /path/to/google-java-format-VERSION-all-deps.jar"

"==============="
" Google config "
"==============="

if filereadable(expand('$HOME/.config/vim_google.vim'))
  source ~/.config/vim_google.vim
endif

"===================="
" Some basic options "
"===================="

filetype plugin indent on

" Enable syntax highlighting
syntax on

" Uncomment if you want to map ; to : to cut down on chording
" nnoremap ; :

" Automatically change the working path to the path of the current file
autocmd BufNewFile,BufEnter * silent! lcd %:p:h

" Show line numbers
set number

" use » to mark Tabs and ° to mark trailing whitespace. This is a
" non-obtrusive way to mark these special characters.
set list listchars=tab:»\ ,trail:°

" Highlight the search term when you search for it.
set hlsearch

" By default, it looks up man pages for the word under the cursor, which isn't
" very useful, so we map it to something else.
" nnoremap <s-k> <CR>

" Explicitly set the Leader to comma. You you can use '\' (the default),
" or anything else (some people like ';').
" let mapleader=','

" Enable mouse support.
" set mouse=a

" Clipboard persistence.
autocmd VimLeave * call system("xsel -ib", getreg('+'))

" Colors.
" set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
let g:airline_theme = 'base16_classic'
colorscheme solarized8
" set t_Co=256
" let g:solarized_termcolors=256
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
else
  echomsg 'Please install Base16 Shell.'
  let base16colorspace=256 " Access colors present in 256 colorspace
  colorscheme base16-solarized-dark
endif

" Airline.
" if filereadable(expand("~/.config/vim/theme"))
"   source ~/.config/vim/theme
" else
  " echomsg 'Please run theme_light or theme_dark.'
  " let g:airline_theme = 'minimalist'
  " set background=dark
  " let g:airline_theme = 'solarized'
  " let g:airline_solarized_bg = 'dark'
" endif
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#whitespace#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_powerline_fonts = 0  " Temp disabled.

" Tmuxline.
let g:tmuxline_powerline_separators = 0
let g:tmuxline_separators = {
    \ 'left' : ' ',
    \ 'left_alt': ':',
    \ 'right' : ' ',
    \ 'right_alt' : ' ',
    \ 'space' : ''}
let g:tmuxline_status_justify = 'left'
let g:tmuxline_preset = {
      \'a'    : '#S',
      \'win'  : ['#I', '#W'],
      \'cwin' : ['#I', '#W'],
      \'y'    : ['%Y-%m-%d', '%T'],
      \'z'    : '#h'}

" Syntastic.
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*

" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 1
" let g:syntastic_check_on_wq = 0

" CtrlP
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_root_markers = ['BUILD']
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }
" Install https://github.com/ggreer/the_silver_searcher.
let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --hidden
      \ --ignore .git
      \ --ignore .svn
      \ --ignore .hg
      \ --ignore .DS_Store
      \ --ignore "**/*.pyc"
      \ --ignore .git5_specs
      \ --ignore review
      \ -g ""'
let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }

" Tagbar
nmap <F8> :TagbarToggle<CR>

" NerdCommenter
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1
" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" Vim-codefmt
" augroup autoformat_settings
"   autocmd FileType bzl AutoFormatBuffer buildifier
"   autocmd FileType c,cpp,proto,javascript AutoFormatBuffer clang-format
"   autocmd FileType dart AutoFormatBuffer dartfmt
"   autocmd FileType go AutoFormatBuffer gofmt
"   autocmd FileType gn AutoFormatBuffer gn
"   autocmd FileType html,css,json AutoFormatBuffer js-beautify
"   autocmd FileType java AutoFormatBuffer google-java-format
"   autocmd FileType python AutoFormatBuffer yapf
"   " Alternative: autocmd FileType python AutoFormatBuffer autopep8
" augroup END

" Black
let g:black_linelength = 99

" ESC timeout
set timeoutlen=1000 ttimeoutlen=0
set updatetime=250

" Vim-xkbswitch
let g:XkbSwitchEnabled = 1

" Indentation
set tabstop=4
set expandtab
set shiftwidth=2
set softtabstop=2

" Relative line numbers
set number relativenumber
" set nonumber norelativenumber  " turn hybrid line numbers off
" set !number !relativenumber    " toggle hybrid line numbers

" Backspace fix
set backspace=indent,eol,start

" Fast saving
nmap <c-s> :w<CR>
vmap <c-s> <Esc><c-s>gv
imap <c-s> <Esc><c-s>
nmap <F2> :update<CR>
vmap <F2> <Esc><F2>gv
imap <F2> <c-o><F2>

" Split line
nnoremap <s-k> i<CR><Esc>k$

let &titlestring = "vi " . expand("%:t")
if &term == "screen"
  set t_ts=^[k
  set t_fs=^[\
endif
  if &term == "screen" || &term == "xterm"
    set title
endif
