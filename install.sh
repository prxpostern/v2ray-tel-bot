#!/bin/bash
red='\033[0;31m'
green='\033[0;32m'
plain='\033[0m'
wk_dir="/root/v2ray-tel-bot"
git_url="https://github.com/TeleDark/v2ray-tel-bot.git"

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Fatal error：${plain} Please run this script with root privilege \n " && exit 1

# Check OS and set release variable
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    release=$ID
elif [[ -f /usr/lib/os-release ]]; then
    source /usr/lib/os-release
    release=$ID
else
    echo "Failed to check the system OS, please contact the author!" >&2
    exit 1
fi

check_python() {
    # Check if Python 3.10 is already installed
    if [ -x "$(command -v python3.10)" ]; then
        echo -e "${green}Python 3.10 is already installed ${plain}\n"
    else
        # install some required packages
        apt install -y software-properties-common && add-apt-repository -y ppa:deadsnakes/ppa && apt -y install python3.10
    fi

    # Verify installation
    if [ -x "$(command -v python3.10)" ]; then
        unlink /usr/bin/python3; ln -s /usr/bin/python3.10 /usr/bin/python3

        curl -sS https://bootstrap.pypa.io/get-pip.py | python3
        python3 -m pip install --upgrade pip && python3 -m pip install --upgrade setuptools

        cd ~/; git clone $git_url;
        pip install -r $wk_dir/requirements.txt

    else
        echo -e "${red}Python 3.10 installation failed ${plain}\n"
    fi
}

install_base() {
    case "${release}" in
        centos|fedora)
            echo -e "${red}The script does not support CentOS-based operating systems ${plain}\n"
            ;;
        *)
            apt update && apt install -y curl git wget python3
            ;;
    esac
}

# && apt upgrade -y
echo -e "${green}Running...${plain}\n"

install_base
check_python

(crontab -l; echo "*/3 * * * * python3 ~/v2ray-tel-bot/login.py"; echo "@reboot python3 ~/v2ray-tel-bot/bot.py") | sort -u | crontab -

echo -e "\n${green}Edit the 'keys.py' and 'login.py' files, then restart the server with the 'reboot' command. The bot will start working after the server comes back up.${plain} \n"
