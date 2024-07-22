apt_update(){
    sudo apt update > /dev/null >> $LOG_FILE 2>&1
}

# Function to install apt packages
apt_install() {
    local package_name=$1
    local auto_install=0

    if [ "$2" = "-y" ]; then
        auto_install=1
    fi

    if [ "$auto_install" -eq 0 ]; then
        if ! ask_to_install "$package_name"; then
            return 1
        fi
    fi

    if sudo apt install $package_name -y >> $LOG_FILE 2>&1; then
        log_success "\t$package_name installed"
        return 0
    else
        log_error "\tFailed to install $package_name." >&2
        show_last_error
        return 1
    fi
}

# Function to install Flatpak packages
flatpak_install() {
    local package_name=$1
    local auto_install=0

    if [ "$2" = "-y" ]; then
        auto_install=1
    fi

    if [ "$auto_install" -eq 0 ]; then
        if ! ask_to_install "$package_name"; then
            return 1
        fi
    fi

    if flatpak install $package_name >> $LOG_FILE 2>&1; then
        log_success "\t$package_name installed"
        return 0
    else
        log_error "\tFailed to install $package_name." >&2
        show_last_error
        return 1
    fi

}

# Function to install Snap packages
snap_install(){
    local package_name=$1
    local auto_install=0

    if [ "$2" = "-y" ]; then
        auto_install=1
    fi

    if [ "$auto_install" -eq 0 ]; then
        if ! ask_to_install "$package_name"; then
            return 1
        fi
    fi

    if sudo snap install $package_name >> $LOG_FILE 2>&1; then
        log_success "\t$package_name installed"
        return 0
    else
        log_error "\tFailed to install $package_name." >&2
        show_last_error
        return 1
    fi
}

dpkg_install(){
    local package_name=$1

    log "\tInstalling $package_name..."

    if sudo dpkg -i $package_name >> $LOG_FILE 2>&1; then
        log_success "\t$package_name installed"
        return 0
    else
        log_error "\tFailed to install $package_name." >&2
        show_last_error
        return 1
    fi
}

download_stm_software() {
    local software_name=$1
    local download_url=$2
    local install_command=$3

    log "\t$software_name..."

    mkdir -p "./$software_name"
    cd "./$software_name"

    log "\t\tDownloading $software_name..."
    curl -fsSLO -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3" "$download_url"
    unzip -qn ./*.zip
    rm ./*.zip

    log "\t\tInstalling $software_name..."

    if [ "$install_command" == "dpkg" ] ;then
        sudo dpkg -i ./*.deb
    else
        chmod +x ./$install_command
        ./$install_command >> $LOG_FILE 2>&1
    fi

    cd ..

    log_success "\t$software_name installed successfully!"
}
