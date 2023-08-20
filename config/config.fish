if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Init starship
starship init fish | source

# Set welcome message
function fish_greeting
    set -x LANG pt_BR.UTF-8
    echo (set_color brblue; date +%l) e (date +%M) da madrugada de (date +%A) e vc trabalhando... (set_color normal)
    set -x LANG en_GB.UTF-8
end

# Variables
set -x ARM_GCC_PATH /opt/arm-none-eabi/gcc-arm-none-eabi-10.3-2021.10/bin

set -x CUBE_PATH /media/eduardo-barreto/Shared/Linux/STM/CubeMX
set -x CUBE_PROGRAMMER_PATH /media/eduardo-barreto/Shared/Linux/STM/Programmer/bin

set -x PATH $PATH $ARM_GCC_PATH
set -x PATH $PATH $CUBE_PROGRAMMER_PATH

# Abbreviations
abbr install 'sudo apt install -y'
abbr update 'sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh'
abbr uninstall 'sudo apt remove'
abbr clean 'sudo apt autoclean && sudo apt autoremove'
abbr fix 'sudo apt install -f'
abbr moo 'apt moo'
abbr tux 'cowsay -f tux'
abbr cls 'clear'
abbr cd.. 'cd ..'

abbr python 'python3'
abbr py python

abbr term 'gedit ~/.config/fish/config.fish'

abbr activate 'source ./*env/bin/activate.fish'

abbr cpwd 'pwd && pwd | xclip -selection clipboard'

abbr submodule 'git submodule update --init'

abbr cube '$CUBE_PATH/STM32CubeMX'
abbr cube_programmer 'CUBE_PROGRAMMER_PATH/STM32CubeProgrammer'

abbr remake 'cd .. && rm -rf build && mkdir build && cd build && cmake ..'
abbr old_remake 'make clean_all clean_cube clean cube prepare; make -j'

abbr thunder 'cd ~/ThunderProjetos'

for file in $HOME/scripts/*.py
    set name (basename "$file" .py)
    abbr -a $name "python3 \"$file\""
end


# Functions
function take
    mkdir -p $argv;
    cd $argv
end


function compile_c
    set name (ls *.c | head -n 1 | cut -d'.' -f1)
    mkdir -p out
    gcc "$name.c" -o "out/$name.o" -lm
    ./out/$name.o
end


function clone
    git clone $argv && cd (basename "$argv" .git)
end
