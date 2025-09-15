#!/usr/bin/env bash
set -e

# -------------------------------
# Arch Linux XFCE4 Bootstrap Script
# With srcery colorscheme + zsh
# -------------------------------

echo "==> Updating system..."
sudo pacman -Syu --noconfirm

# -------------------------------
# Base Packages
# -------------------------------
echo "==> Installing base packages..."
sudo pacman -S --noconfirm --needed \
    base-devel git curl wget unzip htop neofetch \
    xfce4 xfce4-goodies lightdm lightdm-gtk-greeter \
    alacritty \
    thunar thunar-volman file-roller \
    firefox \
    pulseaudio pavucontrol \
    network-manager-applet \
    gvfs gvfs-mtp \
    zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting \
    noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-dejavu ttf-font-awesome

# Enable services
sudo systemctl enable NetworkManager
sudo systemctl enable lightdm

# -------------------------------
# Install yay (AUR helper)
# -------------------------------
if ! command -v yay >/dev/null 2>&1; then
    echo "==> Installing yay..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
fi

# -------------------------------
# AUR Packages
# -------------------------------
yay -S --noconfirm --needed \
    ttf-jetbrains-mono-nerd \
    google-chrome \
    spotify \
    visual-studio-code-bin \
    xfce4-screensaver

# -------------------------------
# DOTFILES + CONFIG
# -------------------------------

mkdir -p ~/.config

# Alacritty config with Srcery colors
mkdir -p ~/.config/alacritty
cat > ~/.config/alacritty/alacritty.yml <<'EOF'
colors:
  primary:
    background: '0x1c1b19'
    foreground: '0xfce8c3'
  normal:
    black:   '0x1c1b19'
    red:     '0xef2f27'
    green:   '0x519f50'
    yellow:  '0xfbb829'
    blue:    '0x2c78bf'
    magenta: '0xe02c6d'
    cyan:    '0x0aaeb3'
    white:   '0xbaa67f'
  bright:
    black:   '0x918175'
    red:     '0xf75341'
    green:   '0x98bc37'
    yellow:  '0xfed06e'
    blue:    '0x68a8e4'
    magenta: '0xff5c8f'
    cyan:    '0x2be4d0'
    white:   '0xfce8c3'
EOF

# Xresources (srcery)
cat > ~/.Xresources <<'EOF'
! Srcery color scheme
*background: #1c1b19
*foreground: #fce8c3
*cursorColor: #fce8c3
#define S_red     #ef2f27
#define S_green   #519f50
#define S_yellow  #fbb829
#define S_blue    #2c78bf
#define S_magenta #e02c6d
#define S_cyan    #0aaeb3
EOF

xrdb ~/.Xresources

# XFCE terminal with srcery colors
mkdir -p ~/.config/xfce4/terminal
cat > ~/.config/xfce4/terminal/terminalrc <<'EOF'
[Configuration]
ColorForeground=#fce8c3
ColorBackground=#1c1b19
ColorCursor=#fce8c3
ColorPalette=#1c1b19;#ef2f27;#519f50;#fbb829;#2c78bf;#e02c6d;#0aaeb3;#baa67f;#918175;#f75341;#98bc37;#fed06e;#68a8e4;#ff5c8f;#2be4d0;#fce8c3
FontName=JetBrainsMono Nerd Font 11
EOF

# ZSH config
chsh -s /bin/zsh
cat > ~/.zshrc <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
EOF

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "==> Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# -------------------------------
echo "✅ Setup complete!"
echo "Reboot and log into XFCE4 (LightDM will start automatically)."
