function theme_dark_luna
  base16-solarized-dark
  set -g theme_color_scheme solarized-dark
  echo "\
set background=dark
let g:airline_theme = 'luna'
" > ~/.config/vim/theme
  echo "theme_dark_luna" > ~/.config/fish/current_theme.fish
end
