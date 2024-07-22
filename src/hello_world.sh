#!/bin/bash

# File: hello_world.sh
# Brief: This script is used to install the basic packages for the system
# Author: Pedro De Santi
# Author: Eduardo Barreto
# Date: 07/2023

# How to run this script?
# sudo chmod +x hello_world.sh
# sudo ./hello_world.sh

source logger.sh
source installers.sh

# Function to prompt user to install a package
ask_to_install() {
    local package_name=$1
    
    log ""
    
    if [ "$AUTO_INSTALL" = "1" ] ; then
        log "Installing $package_name..."
        return 0
    fi
    
    read -p "Do you want to install $package_name? [Y/n] " answer
    case $answer in
        [Yy]*)
            log "Installing $package_name..."
            return 0
        ;;
        *)
            log_warning "Skipping installation of $package_name."
            return 1
        ;;
    esac
}

# Parse script arguments to check for -y (auto-install) flag
AUTO_INSTALL=0
if [ "$1" = "-y" ] ; then
    AUTO_INSTALL=1
fi

LOG_FILE="log.txt"
if [ -f "$LOG_FILE" ] ; then
    rm "$LOG_FILE"
fi

###############################
# Update the list of packages #
###############################

log "Updating the list of packages..."
apt_update
sudo apt upgrade -y >> "$LOG_FILE" 2>&1
log_success "Done!"

##############################
# Install the basic packages #
##############################

echo ""
apt_install build-essential
apt_install cmake
apt_install python3
apt_install python3-pip
apt_install git
apt_install uncrustify
apt_install curl
apt_install libusb-1.0-0-dev
apt_install xclip
apt_install neofetch
apt_install snapd
apt_install zip
apt_install unzip
apt_install gdb-multiarch
apt_install vim
apt_install flameshot
apt_install openocd
apt_install stlink-tools
apt_install cheese
apt_install cowsay
apt_install fzf
apt_install tree 
apt_install black
apt_install bat
apt_install httpie
apt_install clang-format
apt_install ffmpeg
apt_install lazygit
apt_install openvpn3
apt_install tldr
apt_install joystick
apt_install scrcpy
apt_install ripgrep

if apt_install flatpak; then
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

###############
# Install zsh #
###############

if ask_to_install "Zsh"; then
    apt_install zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    touch ~/.zshrc
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting\n
fi

###################
# Install lazygit #
###################

if ask_to_install "Lazygit"; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
fi

###############
# Install exa #
###############

if ask_to_install "eza"; then
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
fi


##################
# Install Neovim #
##################

if ask_to_install "Neovim"; then

    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf nvim-linux64.tar.gz

    echo "export PATH=\$PATH:/opt/nvim/bin" >> ~/.zshrc

fi

##########################
# Install gnome packages #
##########################

if ask_to_install "Gnome packages"; then
    apt_install gnome-tweaks -y
    apt_install gnome-shell-extensions -y
    apt_install chrome-gnome-shell -y
    apt_install dconf-editor -y
    apt_install dconf-cli -y
    apt_install gedit -y
fi

#################
# Install PyEnv #
#################

if ask_to_install "PyEnv"; then
    
    curl -fsSL https://pyenv.run | bash >> $LOG_FILE 2>&1
    echo -e "export PATH=\"\$HOME/.pyenv/bin:\$PATH\"\neval \"\$(pyenv init -)\"\neval \"\$(pyenv virtualenv-init -)\"" >> ~/.bashrc
    source ~/.bashrc
    
    log_success "PyEnv installed"
fi

###############
# Install nvm #
###############

if ask_to_install "Node.js"; then
    
    curl --silent https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash >> $LOG_FILE 2>&1
    source ~/.nvm/nvm.sh
    source ~/.profile
    source ~/.bashrc
    
    nvm install --lts >> $LOG_FILE 2>&1
    apt_install npm -y
    sudo npm install --global yarn
    
    log_success "nvm and node installed"
fi

##########################
# Install SEGGER Software #
##########################

if ask_to_install "SEGGER" ; then
    
    log "\t\tDownloading Segger JLink..."
    curl -fsLO -d 'accept_license_agreement=accepted&submit=Download+software' https://www.segger.com/downloads/jlink/JLink_Linux_x86_64.deb
    dpkg_install "./JLink_Linux_x86_64.deb"
    
    log_success "SEGGER Installed"
    
fi

###################
# Install ARM GCC #
###################

if ask_to_install "ARM GCC"; then
    
    cd
    curl -fsLO "https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2"
    tar -xvf gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2 >> $LOG_FILE 2>&1
    sudo mkdir /opt/arm-none-eabi
    sudo mv gcc-arm-none-eabi-10.3-2021.10 /opt/arm-none-eabi
    rm gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2
    
    log_success "ARM GCC installed"
fi

###################
# Install AnyDesk #
###################

if ask_to_install "AnyDesk"; then
    
    sudo wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add -
    sudo echo "deb http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk-stable.list
    apt_update
    apt_install anydesk -y
fi

#################
# Install Kazam #
#################

if ask_to_install "Kazam"; then
    
    apt_install build-essential -y
    apt_install libpython3-dev -y
    apt_install libdbus-1-dev -y
    apt_install libcairo2-dev -y
    apt_install libgirepository1.0-dev -y
    apt_install gir1.2-gudev-1.0 -y
    apt_install gir1.2-keybinder-3.0 -y
    
    pip install kazam >> $LOG_FILE 2>&1
    
    log_success "Kazam installed"
fi

###################
# Install Shotcut #
###################

snap_install "shotcut --classic"

###################
# Install Discord #
###################

flatpak_install "de.shorsh.discord-screenaudio"

log_success "All packages installed successfully!"

########################
# Configure the system #
########################

log "Configuring the system..."

#####################
# Install Fira Code #
#####################

apt_install fonts-firacode

#####################
# Install Nerdfonts #
#####################

if ask_to_install "NerdFonts"; then
    
    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts
    curl -fsLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Bold/FiraCodeNerdFontMono-Bold.ttf
    curl -fsLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Light/FiraCodeNerdFontMono-Light.ttf
    curl -fsLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Medium/FiraCodeNerdFontMono-Medium.ttf
    curl -fsLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Regular/FiraCodeNerdFontMono-Regular.ttf
    curl -fsLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Retina/FiraCodeNerdFontMono-Retina.ttf
    curl -fsLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/SemiBold/FiraCodeNerdFontMono-SemiBold.ttf
    
    log_success "Nerdfonts installed successfully!\n"
fi

#################
# Configure git #
#################

log
read -p "Do you want to configure git? (y/n) " answer

if [ "$answer" != "${answer#[Yy]}" ] ; then
    log "Enter the git username: "
    read git_username
    
    log "Enter the git email: "
    read git_email
    
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
    log_success "Git configured successfully!"
    
    log
    read -p "Do you want to configure the SSH? [Y/n] " answer
    
    if [ "$answer" != "${answer#[Yy]}" ] ; then
        ssh-keygen -t ed25519 -C "$git_email"
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_ed25519
        xclip -sel clip < ~/.ssh/id_ed25519.pub
        log_success "\nSSH configured successfully! The SSH public key was copied to the clipboard!"
        log_warning "\tGo to https://github.com/settings/ssh/new and paste the key there."
        
        log_warning "\nPress enter to continue..."
        read
    fi
fi
