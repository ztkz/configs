function theme_light
  base16-solarized-light
  set -g theme_color_scheme solarized-light
  echo "\
set background=light
let g:airline_theme = 'solarized'
let g:airline_solarized_bg = 'light'
" > ~/.config/vim/theme
  echo "theme_light" > ~/.config/fish/current_theme.fish
end
