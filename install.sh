#!/usr/bin/env bash
#install.sh (enhanced with zsh, fancy i3, inline srcery colors)

set -euo pipefail
USER_HOME="${HOME}"
DOTFILES_DIR="${USER_HOME}/.dotfiles"

PACMAN_PKGS=(
  xorg-server xorg-xinit xorg-apps
  i3-wm i3status rofi dmenu xbindkeys feh picom
  alacritty kitty bash zsh
  ttf-dejavu ttf-liberation noto-fonts ttf-nerd-fonts-symbols
  lxappearance papirus-icon-theme
  networkmanager network-manager-applet pipewire pipewire-pulse pavucontrol
  bluez bluez-utils brightnessctl scrot
  firefox neovim mpv thunar vlc imagemagick
  git make cmake python python-pip nodejs npm go docker unzip zip rsync
  tmux htop ripgrep fd bat exa glances
  cups
)

AUR_PKGS=( polybar ttf-fira-code-nerd )

# -------------------------------------------------------
echoinfo(){ printf "\n\033[1;34m[INFO]\033[0m %s\n" "$*"; }

create_dotfiles_layout(){
  mkdir -p "${DOTFILES_DIR}/config/i3"
  mkdir -p "${DOTFILES_DIR}/config/polybar"
  mkdir -p "${DOTFILES_DIR}/config/alacritty"
  mkdir -p "${DOTFILES_DIR}/config/rofi"
}

install_zsh_ohmyzsh(){
  echoinfo "Installing Oh-My-Zsh and plugins..."
  if [[ ! -d "${USER_HOME}/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$USER_HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$USER_HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true

  cat > "${DOTFILES_DIR}/zshrc" <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

alias ll='ls -lah --color=auto'
alias gs='git status'
export EDITOR=nvim
EOF
  ln -sf "${DOTFILES_DIR}/zshrc" "${USER_HOME}/.zshrc"
}

write_inline_srcery_xresources(){
  cat > "${DOTFILES_DIR}/Xresources" <<'EOF'
! Srcery Xresources inline theme
*.foreground:   #ebdbb2
*.background:   #1c1b19
*.cursorColor:  #fbb829
*.color0:  #1c1b19
*.color1:  #ef2f27
*.color2:  #519f50
*.color3:  #fbb829
*.color4:  #2c78bf
*.color5:  #e02c6d
*.color6:  #0aaeb3
*.color7:  #baa67f
*.color8:  #918175
*.color9:  #f75341
*.color10: #98bc37
*.color11: #fed06e
*.color12: #68a8e4
*.color13: #ff5c8f
*.color14: #2be4d0
*.color15: #fce8c3
EOF
  ln -sf "${DOTFILES_DIR}/Xresources" "${USER_HOME}/.Xresources"
}

write_fancy_i3_config(){
  cat > "${DOTFILES_DIR}/config/i3/config" <<'EOF'
# Fancy i3 config with Polybar, gaps, workspace icons

set $mod Mod4
font pango:Fira Code Nerd Font 11
gaps inner 8
gaps outer 0

# Workspaces with icons
set $ws1 "1: "
set $ws2 "2: "
set $ws3 "3: "
set $ws4 "4: "
set $ws5 "5: "

bindsym $mod+1 workspace $ws1
bindsym $mod+2 workspace $ws2
bindsym $mod+3 workspace $ws3
bindsym $mod+4 workspace $ws4
bindsym $mod+5 workspace $ws5

# Launchers
bindsym $mod+Return exec alacritty
bindsym $mod+d exec rofi -show drun

# Screenshots
bindsym Print exec scrot ~/Pictures/screenshot-%Y-%m-%d-%H%M%S.png

# Volume keys
bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%
bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5%
bindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle

# Brightness keys
bindsym XF86MonBrightnessUp exec brightnessctl set +10%
bindsym XF86MonBrightnessDown exec brightnessctl set 10%-

# Restart / exit
bindsym $mod+Shift+r restart
bindsym $mod+Shift+e exec "i3-msg exit"

# Autostart apps
exec --no-startup-id nm-applet
exec --no-startup-id picom
exec_always --no-startup-id $HOME/.config/polybar/launch.sh
EOF

  mkdir -p "${DOTFILES_DIR}/config/polybar"
  cat > "${DOTFILES_DIR}/config/polybar/config" <<'EOF'
[bar/top]
width = 100%
height = 28
modules-left = i3
modules-center = date
modules-right = pulseaudio memory cpu

[module/i3]
type = internal/i3
format = <label-state>
label-focused = %name%
label-unfocused = %name%

[module/date]
type = internal/date
interval = 5
date = %Y-%m-%d %H:%M

[module/pulseaudio]
type = internal/pulseaudio

[module/cpu]
type = internal/cpu

[module/memory]
type = internal/memory
EOF

  cat > "${DOTFILES_DIR}/config/polybar/launch.sh" <<'EOF'
#!/bin/bash
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
polybar top &
EOF
  chmod +x "${DOTFILES_DIR}/config/polybar/launch.sh"

  ln -sf "${DOTFILES_DIR}/config/i3/config" "${USER_HOME}/.config/i3/config"
  ln -sf "${DOTFILES_DIR}/config/polybar" "${USER_HOME}/.config/polybar"
}
