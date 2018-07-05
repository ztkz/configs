function theme_dark
  base16-solarized-dark
  set -g theme_color_scheme solarized-dark
  echo "\
set background=dark
let g:airline_theme = 'solarized'
let g:airline_solarized_bg = 'dark'
" > ~/.config/vim/theme
  echo "theme_dark" > ~/.config/fish/current_theme.fish
end
