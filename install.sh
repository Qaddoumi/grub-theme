#!/usr/bin/env bash

set -e # Exit on error

# Color codes
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
blue='\033[0;34m'
cyan='\033[0;36m'
bold="\e[1m"
no_color='\033[0m' # reset the color to default

backup_file() {
    local file="$1"
    if sudo test -f "$file"; then
        sudo cp -an "$file" "$file.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${green}Backed up $file${no_color}"
    else
        echo -e "${yellow}File $file does not exist, skipping backup${no_color}"
    fi
}
splash() {
    echo_title() {     echo -ne "\033[1;44;37m${*}\033[0m\n"; }
    local hr
    # create hr with length of $1
    hr=" **$(printf "%${#1}s" | tr ' ' '*')** "
    echo_title "${hr}"
    echo_title " * $1 * "
    echo_title "${hr}"
    echo
}

#THEME_DIR='/usr/share/grub/themes'
THEME_DIR='/boot/grub/themes'
THEME_NAME='CyberRe'
splash 'Installing CyberRe Theme...'
echo ""

splash 'The Matrix awaits you...'
echo ""
backup_file '/etc/default/grub'
#==========================================================================================
#==========================================================================================
# create themes directory if not exists
if [[ ! -d "${THEME_DIR}/${THEME_NAME}" ]]; then
    echo -e "${green}copying ${THEME_NAME} theme files...${no_color}"
    sudo mkdir -p "${THEME_DIR}/${THEME_NAME}"
    sudo cp -a ./"${THEME_NAME}"/* "${THEME_DIR}/${THEME_NAME}"
fi
#==========================================================================================
#==========================================================================================
echo -e "${green}Enabling grub menu${no_color}"
# remove default grub style if any
echo -e "${blue}sed -i '/GRUB_TIMEOUT_STYLE=/d' /etc/default/grub${no_color}"
sudo sed -i '/GRUB_TIMEOUT_STYLE=/d' /etc/default/grub

# issue #16
echo -e "${blue}sed -i '/GRUB_TERMINAL_OUTPUT=/d' /etc/default/grub${no_color}"
sudo sed -i '/GRUB_TERMINAL_OUTPUT=/d' /etc/default/grub

echo -e "${blue}echo 'GRUB_TIMEOUT_STYLE=\"menu\"' | sudo tee -a /etc/default/grub${no_color}"
echo 'GRUB_TIMEOUT_STYLE="menu"' | sudo tee -a /etc/default/grub > /dev/null

#--------------------------------------------------

echo -e "${green}Setting grub timeout to 60 seconds${no_color}"
# remove default timeout if any
echo -e "${blue}sed -i '/GRUB_TIMEOUT=/d' /etc/default/grub${no_color}"
sudo sed -i '/GRUB_TIMEOUT=/d' /etc/default/grub

echo -e "${blue}echo 'GRUB_TIMEOUT=\"60\"' | sudo tee -a /etc/default/grub${no_color}"
echo 'GRUB_TIMEOUT="60"' | sudo tee -a /etc/default/grub > /dev/null

#--------------------------------------------------

echo -e "${green}Setting ${THEME_NAME} as default${no_color}"
# remove theme if any
echo -e "${blue}sed -i '/GRUB_THEME=/d' /etc/default/grub${no_color}"
sudo sed -i '/GRUB_THEME=/d' /etc/default/grub

echo -e "${blue}echo \"GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"\" | sudo tee -a /etc/default/grub${no_color}"
echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" | sudo tee -a /etc/default/grub > /dev/null

#--------------------------------------------------

echo -e "${green}Setting grub graphics mode to auto${no_color}"
# remove default timeout if any
echo -e "${blue}sed -i '/GRUB_GFXMODE=/d' /etc/default/grub${no_color}"
sudo sed -i '/GRUB_GFXMODE=/d' /etc/default/grub

echo -e "${blue}echo 'GRUB_GFXMODE=\"auto\"' | sudo tee -a /etc/default/grub${no_color}"
echo 'GRUB_GFXMODE="auto"' | sudo tee -a /etc/default/grub > /dev/null
#==========================================================================================
#==========================================================================================
#  Update grub config
echo -e "${green}Updating grub config...${no_color}"
if [[ -x "$(command -v update-grub)" ]]; then
    echo -e "${blue}update-grub${no_color}"
    sudo update-grub

elif [[ -x "$(command -v grub-mkconfig)" ]]; then
    echo -e "${blue}grub-mkconfig -o /boot/grub/grub.cfg${no_color}"
    sudo grub-mkconfig -o /boot/grub/grub.cfg

elif [[ -x "$(command -v grub2-mkconfig)" ]]; then
    if [[ -x "$(command -v zypper)" ]]; then
        echo -e "${blue}grub2-mkconfig -o /boot/grub2/grub.cfg${no_color}"
        sudo grub2-mkconfig -o /boot/grub2/grub.cfg

    elif [[ -x "$(command -v dnf)" ]]; then
        echo -e "${blue}grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg${no_color}"
        sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
    fi
fi
#==========================================================================================
#==========================================================================================
echo -e "${green}Boot Theme Update Successful!${no_color}"
