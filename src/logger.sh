ERROR_COLOR='\033[0;31m'
SUCCESS_COLOR='\033[0;32m'
WARNING_COLOR='\033[0;33m'
NO_COLOR='\033[0m' # No Color

# Função para log normal (sem cor)
log() {
    echo -e "$1"
}

# Função para log de erro (vermelho)
log_error() {
    log "${ERROR_COLOR}$1${NO_COLOR}" >&2
}

# Função para log de sucesso (verde)
log_success() {
    log "${SUCCESS_COLOR}$1${NO_COLOR}"
}

# Função para log de aviso (amarelo)
log_warning() {
    log "${WARNING_COLOR}$1${NO_COLOR}"
}

# Function to prompt user to install a package
ask_to_install() {
    local package_name=$1

    log ""

    if [ "$AUTO_INSTALL" = "1" ]; then
        log "Installing $package_name..."
        return 0
    fi

    read -p "Do you want to install $package_name? (y/n) " answer
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

show_last_error() {
    log_error "\t$(grep -i "error\|E:" "$LOG_FILE" | tail -1)"
}
