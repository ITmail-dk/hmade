#!/bin/bash
#DEV TEST
# nano /tmp/install.sh && chmod +x /tmp/install.sh && . /tmp/install.sh

# Start the install *_:*:_*:*:_*_*:*:_*::*_*::*_*:_*::*_*:*:_:*:*_*:*:_*:*_:*:#

# Whiptail colors
export NEWT_COLORS='
root=white,gray
window=white,lightgray
border=black,lightgray
shadow=white,black
button=white,blue
actbutton=black,red
compactbutton=black,
title=black,
roottext=black,magenta
textbox=black,lightgray
acttextbox=gray,white
entry=lightgray,gray
disentry=gray,lightgray
checkbox=black,lightgray
actcheckbox=white,blue
emptyscale=,black
fullscale=,red
listbox=black,lightgray
actlistbox=lightgray,gray
actsellistbox=white,blue'

# Set Echo colors
# for c in {0..255}; do tput setaf $c; tput setaf $c | cat -v; echo =$c; done
NC="\033[0m"
RED="\033[0;31m"
RED2="\033[38;5;196m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;94m"

clear

if [ -f /etc/debian_version ]; then
    echo "The system is running on Debian Linux, everything is fine..."
else
    echo "This installation should only be run on a Debian Linux System."
    exit 1
fi


# Function to echo, handle errors - Stop the entire installation if an error occurs during the installation
error_handler() {
    echo -e "${RED} An error occurred during installation and has been stopped. ${NC}"
    exit 1
}

# Set the error handler to be called on any error
trap error_handler ERR

# Exit immediately if a command exits with a non-zero status
set -e

# ------------------- > > >

# Installation start screen
FULLUSERNAME=$(awk -v user="$USER" -F":" 'user==$1{print $5}' /etc/passwd | rev | cut -c 4- | rev)

if (whiptail --title "Installation of the Martin Hyprland Desktop" --yesno "Hi $FULLUSERNAME do you want to start \nthe installation of Hyprland Martin Andersen Desktop Environment, Hmade for short.! \n \nRemember you user must have sudo \naccess to run the installation." 13 50); then
    echo -e "${GREEN} Okay, let's start the installation."
else
    exit 1
fi


clear
echo -e "${RED} "
echo -e "${RED}-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-"
echo -e "${RED} "
echo -e "${RED}      Starting the installation..."
echo -e "${RED}      Enter your user password, to continue if necessary"
echo -e "${RED} "
echo -e "${RED}-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-"
echo -e "${RED} ${NC}"

if [ -f /etc/apt/sources.list ]; then
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak.$(date +'%d-%m-%Y_%H%M%S')
else
echo "No Debian repositories sources.list"
sudo cp /usr/share/doc/apt/examples/sources.list /etc/apt/sources.list
sudo sed -i '/^deb cdrom:/s/^/#/' /etc/apt/sources.list
fi


# APT Add "contrib non-free" to the sources list
if [ -f /etc/apt/sources.list.d/debian.sources ]; then
    if ! grep -q "Components:.* contrib non-free non-free-firmware" /etc/apt/sources.list.d/debian.sources; then
        sudo sed -i 's/^Components:* main/& contrib non-free non-free-firmware/g' /etc/apt/sources.list.d/debian.sources
    else
        echo "contrib non-free non-free-firmware is already present in /etc/apt/sources.list.d/debian.sources"
    fi
else
    if ! grep -q "deb .* contrib non-free" /etc/apt/sources.list; then
        sudo sed -i 's/^deb.* main/& contrib non-free/g' /etc/apt/sources.list
    else
        echo "contrib non-free is already present in /etc/apt/sources.list"
    fi
fi


if ! dpkg -s apt-transport-https >/dev/null 2>&1; then
    sudo DEBIAN_FRONTEND=noninteractive apt -y install apt-transport-https
    sudo sed -i 's+http:+https:+g' /etc/apt/sources.list
else
    echo "apt-transport-https is already installed."
fi

clear

sudo sed -i 's/bookworm main/sid main/g' /etc/apt/sources.list

sudo sed -i 's/bookworm-security/testing-security/g' /etc/apt/sources.list

sudo sed -i 's/bookworm-updates/testing-updates/g' /etc/apt/sources.list

# DEBIAN_FRONTEND=noninteractive

# APT Install Start
sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y && sudo DEBIAN_FRONTEND=noninteractive apt autoremove -y

sudo DEBIAN_FRONTEND=noninteractive apt -y install sddm --no-install-recommends

sudo DEBIAN_FRONTEND=noninteractive apt install -y git wget curl fastfetch kitty wayland-protocols wayland-utils hyprland hyprland-protocols xdg-desktop-portal-wlr xdg-desktop-portal-gtk xdg-desktop-portal-hyprland libinput-bin libinput-dev
sudo DEBIAN_FRONTEND=noninteractive apt install -y wlogout hyprpaper hyprcursor-util

sudo DEBIAN_FRONTEND=noninteractive apt install -y dbus acpi nwg-look fwupd fwupdate xdg-utils xdp-tools lm-sensors fancontrol flameshot speedcrunch mc gparted mpd mpc ncmpcpp fzf ccrypt xarchiver notepadqq htop
sudo DEBIAN_FRONTEND=noninteractive apt install -y thunar gvfs-backends xarchiver wofi dunst libnotify-bin notify-osd brightnessctl usbutils bash-completion wlr-randr coreutils imagemagick pipx power-profiles-daemon
sudo DEBIAN_FRONTEND=noninteractive apt install -y qt6-wayland qt5ct qt6ct --ignore-missing

sudo DEBIAN_FRONTEND=noninteractive apt install -y firefox-esr remmina

# # # May be deleted in the future # # #
sudo DEBIAN_FRONTEND=noninteractive apt install -y xwayland waybar swayidle swaylock swaybg
# chrony xsensors

# Build Tools
# sudo DEBIAN_FRONTEND=noninteractive apt install -y build-essential make xorriso live-build --ignore-missing

# Firmware
sudo DEBIAN_FRONTEND=noninteractive apt install -y firmware-linux firmware-linux-nonfree firmware-misc-nonfree

# WiFi Firmware
#sudo DEBIAN_FRONTEND=noninteractive apt install -y firmware-iwlwifi firmware-atheros firmware-realtek

# Network
sudo DEBIAN_FRONTEND=noninteractive apt install -y ceph-common nfs-common samba-common nmap

# Printer
sudo DEBIAN_FRONTEND=noninteractive apt install -y system-config-printer cups cups-client cups-filters cups-pdf printer-driver-all
sudo usermod -a -G lpadmin $USER

# Polkit Agent
sudo DEBIAN_FRONTEND=noninteractive apt install -y mate-polkit --no-install-recommends
#sudo DEBIAN_FRONTEND=noninteractive apt install -y polkit-kde-agent-1 --no-install-recommends

# Audio
sudo DEBIAN_FRONTEND=noninteractive apt install -y pipewire wireplumber pavucontrol pipewire-alsa pipewire-pulse pipewire-jack
 
# PipeWire Sound Server "Audio" - https://pipewire.org/
systemctl enable --user --now pipewire.socket pipewire-pulse.socket wireplumber.service

# Bluetooth
sudo DEBIAN_FRONTEND=noninteractive apt install -y bluetooth bluez-firmware blueman bluez bluez-tools bluez-cups bluez-obexd bluez-meshd pulseaudio-module-bluetooth libspa-0.2-bluetooth libspa-0.2-jack libspa-0.2-libcamera

# Linux Headers
sudo apt -y install linux-headers-$(uname -r)

echo -e "${GREEN} CPU Microcode install ${NC}"
export LC_ALL=C # All subsequent command output will be in English
CPUVENDOR=$(lscpu | grep "Vendor ID:" | awk '{print $3}')

if [ "$CPUVENDOR" == "GenuineIntel" ]; then
    if ! dpkg -s intel-microcode >/dev/null 2>&1; then
    sudo apt install -y intel-microcode
    fi
else
    echo -e "${GREEN} Intel Microcode OK ${NC}"
fi

if [ "$CPUVENDOR" == "AuthenticAMD" ]; then
    if ! dpkg -s amd64-microcode >/dev/null 2>&1; then
    sudo apt -y install amd64-microcode
    fi
else
    echo -e "${GREEN} Amd64 Microcode OK ${NC}"
fi
unset LC_ALL # unset the LC_ALL=C

sleep 1
#clear

cd /tmp/ && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && sudo apt install -y /tmp/google-chrome-stable_current_amd64.deb && rm google-chrome-stable_current_amd64.deb && cd ~

echo -e "${GREEN} Set User folders via xdg-user-dirs-update & xdg-mime default. ${NC}"
# ls /usr/share/applications/ Find The Default run.: "xdg-mime query default inode/directory"

xdg-user-dirs-update

xdg-mime default kitty.desktop text/x-shellscript
#xdg-mime default nsxiv.desktop image/jpeg
#xdg-mime default nsxiv.desktop image/png
xdg-mime default thunar.desktop inode/directory

sleep 1
#clear

echo -e "${GREEN}Settings GRUB TIMEOUT to 1 second. ${NC}"
sudo sed -i 's+GRUB_TIMEOUT=5+GRUB_TIMEOUT=1+g' /etc/default/grub && sudo update-grub


echo -e "${GREEN} Alias echo to ~/.bashrc ${NC}"

echo 'alias ls="ls --color=auto --group-directories-first -v -lah"' >> ~/.bashrc
echo 'alias df="df --human-readable --print-type"' >> ~/.bashrc
echo 'alias upup="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y"' >> ~/.bashrc
echo 'bind '"'"'"\C-f":"open "$(fzf)"\n"'"'" >> ~/.bashrc

# Make some directories for later use
mkdir -p ~/.local/src ~/.local/bin

# # # # # Config folders & files

echo -e "${GREEN} Hyprland config file START ${NC}"

if [ ! -f ~/.config/hypr/hyprland.conf ]; then
mkdir -p ~/.config/hypr
cat << "HYPRLANDCONFIG" > ~/.config/hypr/hyprland.conf
# Hyprland Configuring File.
# Refer to the wiki for more information.
# https://wiki.hyprland.org/Configuring/Configuring-Hyprland/

# Please note not all available settings / options are set here.
# For a full list, see the wiki at https://wiki.hyprland.org

# Split configuration into multiple files and source them.
# source = ~/.config/hypr/ColorsHyprland.conf


################
### MONITORS ###
################

# https://wiki.hyprland.org/Configuring/Monitors/
# list all available monitors - hyprctl monitors all
# monitor = name, resolution, position, scale

monitor=,preferred,auto,1

# unscale XWayland
xwayland {
  force_zero_scaling = true
}


#################
### AUTOSTART ###
#################

# Autostart necessary processes (like notifications daemons, status bars, etc.)
# Or execute your favorite apps at launch like this:

#exec-once = dbus-update-activation-environment --systemd --all
#exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland

# Wallpapers via HyprPaper (turn off for now)
# https://wiki.hyprland.org/Hypr-Ecosystem/hyprpaper/
#exec-once = hyprpaper
#exec-once = hyprctl hyprpaper preload "$HOME/Wallpapers/Wallpaper.png"
#exec-once = hyprctl hyprpaper wallpaper ",$HOME/Wallpapers/Wallpaper.png"

exec-once = wal --cols16 darken -q -i $HOME/Wallpapers
#exec-once = swaybg -m fill -i $(find $HOME/Wallpapers -type f | shuf -n 1)

exec-once = ~/.config/waybar/auto-reload-waybar.sh
exec-once = dunst

# exec-once = nm-applet
# exec-once = blueman-applet

#exec-once = [workspace special:magic silent] kitty
#exec-once = [workspace special:audio silent] pavucontrol

#############################
### ENVIRONMENT VARIABLES ###
#############################

# https://wiki.hyprland.org/Configuring/Environment-variables/

env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24
env = XDG_CURRENT_DESKTOP,Hyprland


#####################
### LOOK AND FEEL ###
#####################

# Refer to https://wiki.hyprland.org/Configuring/Variables/

# https://wiki.hyprland.org/Configuring/Variables/#general
general {
    gaps_in = 4
    gaps_out = 8

    border_size = 1

    # https://wiki.hyprland.org/Configuring/Variables/#variable-types
    col.active_border = rgba(195896c4)
    #col.active_border = rgba(216bb7cc) rgba(388abecc) 45deg
    col.inactive_border = rgba(3e4c55c9)

    # Set to true or false to enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = true

    # https://wiki.hyprland.org/Configuring/Tearing/
    allow_tearing = false

    # https://wiki.hyprland.org/Configuring/Dwindle-Layout/
    layout = dwindle
}

# https://wiki.hyprland.org/Configuring/Variables/#decoration
decoration {
    rounding = 0

    # Change transparency of focused and unfocused windows
    active_opacity = 1.0
    inactive_opacity = 1.0

    drop_shadow = false
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)

    # https://wiki.hyprland.org/Configuring/Variables/#blur
    blur {
        enabled = true
        size = 3
        passes = 2

        vibrancy = 0.1696
    }
}

# https://wiki.hyprland.org/Configuring/Variables/#animations
animations {
    enabled = true

    # Default animations, for more see https://wiki.hyprland.org/Configuring/Animations/

    bezier = myBezier, 0.05, 0.9, 0.1, 1.05

    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# https://wiki.hyprland.org/Configuring/Dwindle-Layout/
dwindle {
    pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
    preserve_split = true # You probably want this
    default_split_ratio = 1.2
}

# https://wiki.hyprland.org/Configuring/Master-Layout/
master {
    new_status = master
}

# https://wiki.hyprland.org/Configuring/Variables/#misc
misc {
    force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo = true # (true or false) If true disables the random hyprland logo / anime girl background. :(
}


#############
### INPUT ###
#############

# https://wiki.hyprland.org/Configuring/Variables/#input
input {
    kb_layout = dk
    kb_variant =
    kb_model =
    kb_options = nodeadkeys
    kb_rules =
    numlock_by_default = true

    follow_mouse = 1

    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.

    touchpad {
	tap-to-click = true
	disable_while_typing = true
	clickfinger_behavior = false
        natural_scroll = false
	scroll_factor = 1
    }
}

# https://wiki.hyprland.org/Configuring/Variables/#gestures
gestures {
    workspace_swipe = false
}

# Example per-device config
# See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
device {
    name = epic-mouse-v1
    sensitivity = -0.5
}


####################
# Default Programs #
####################

# https://wiki.hyprland.org/Configuring/Keywords/

# Set programs that you use
$terminal = kitty
$filemanager = thunar
$runmenu = wofi -GIm -S drun
$browser = google-chrome
$browser2 = firefox-esr
$rdpmanager = remmina

####################
### KEYBINDINGSS ###
####################
# https://wiki.hyprland.org/Configuring/Keywords/
# https://wiki.hyprland.org/Configuring/Binds/
# Mod list - SHIFT, CAPS, CTRL/CONTROL, ALT, MOD2, MOD3, SUPER/WIN/LOGO/MOD4, MOD5, Return, 

# Sets the modifier keys
$mainMod = SUPER
$secondMod = SHIFT
$thirdMod = ALT
$fourthdMod = CTRL

# https://wiki.hyprland.org/Configuring/Binds/
bind = $mainMod, Return, exec, $terminal
bind = $mainMod, B, exec, $browser
bind = $mainMod $secondMod, B, exec, $browser2
bind = $mainMod, E, exec, $filemanager
bind = $mainMod, R, exec, $runmenu
bind = $mainMod $secondMod, R, exec, $rdpmanager

bind = $mainMod, W, killactive,
# 0 - fullscreen (takes your entire screen), 1 - maximize (keeps gaps and bar(s)), 2 - fullscreen (same as fullscreen except doesn't alter window's internal fullscreen state)
bind = $mainMod, F, fullscreen, 1
bind = $mainMod $secondMod, F, fullscreen, 0
bind = $mainMod $fourthdMod, F, togglefloating,

bind = $mainMod $secondMod, W, exec, wal --cols16 darken -q -i $HOME/Wallpapers
#bind = $mainMod $secondMod, W, exec, swaybg -m fill -i $(find $HOME/Wallpapers -type f | shuf -n 1)

bind = $mainMod, P, pseudo, # dwindle
bind = $mainMod, J, togglesplit, # dwindle

# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Move focus window with mainMod + secondMod + arrow keys
bind = $mainMod $secondMod, left, movewindow, l
bind = $mainMod $secondMod, right, movewindow, r
bind = $mainMod $secondMod, up, movewindow, u
bind = $mainMod $secondMod, down, movewindow, d

bind = $mainMod, minus, centerwindow

bind = $mainMod $secondMod $thirdMod, left, movetoworkspace,-1
bind = $mainMod $secondMod $thirdMod, right, movetoworkspace,+1

# Switch workspaces with mainMod + [0-9]
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = $mainMod $secondMod, 1, movetoworkspace, 1
bind = $mainMod $secondMod, 2, movetoworkspace, 2
bind = $mainMod $secondMod, 3, movetoworkspace, 3
bind = $mainMod $secondMod, 4, movetoworkspace, 4
bind = $mainMod $secondMod, 5, movetoworkspace, 5
bind = $mainMod $secondMod, 6, movetoworkspace, 6
bind = $mainMod $secondMod, 7, movetoworkspace, 7
bind = $mainMod $secondMod, 8, movetoworkspace, 8
bind = $mainMod $secondMod, 9, movetoworkspace, 9
bind = $mainMod $secondMod, 0, movetoworkspace, 10

# Special Workspaces (ScratchPad)
bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod $secondMod, S, movetoworkspace, special:magic

bind = $mainMod $secondMod, A, togglespecialworkspace, special:audio

bind = $secondMod $secondMod, X, togglespecialworkspace

# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Audio
binde = , XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 1%+
binde = , XF86AudioLowerVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-
binde = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle || notify-send -u low "Audio muted" " "

bind = $mainMod $thirdMod, up, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 1%+
bind = $mainMod $thirdMod, down, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-
bind = $mainMod $thirdMod, M, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# XF86 Audio & Brightness keys
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 1%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind = , XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle

bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioPause, exec, playerctl pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous

bind = , XF86MonBrightnessUp, exec, brightnessctl -q s +10%
bind = , XF86MonBrightnessDown, exec, brightnessctl -q s 10%-

# Lockdown / Screenlock
bind = , XF86Lock, exec, swaylock -f -L -e -c 000000 --indicator-radius 250 --indicator-thickness 6 -i $(find $HOME/Wallpapers -type f | shuf -n 1)
bind = $mainMod, l, exec, swaylock -f -L -e -c 000000 --indicator-radius 250 --indicator-thickness 6 -i $(find $HOME/Wallpapers -type f | shuf -n 1)

# List out switches via "hyprctl devices"
#bindl=,switch:<switch-name>,exec,<command>

# Switch Example, closing the lid on the laptop will turn off the laptop screen
#bindl=,switch:<switch-name>, exec, sleep 1 && hyprctl dispatch dpms off eDP-1

# Open Programs


#############################################
### RULES - WINDOWS, LAYER AND WORKSPACES ###
#############################################

# https://wiki.hyprland.org/Configuring/Window-Rules/
# https://wiki.hyprland.org/Configuring/Workspace-Rules/

#windowrulev2 = suppressevent maximize, class:.*


# Float Windowrules
windowrulev2 = float,size 30% 50%,floatpos center,noborder,norounding,class:^(rofi|Rofi)
windowrulev2 = float,floatpos center,noborder,norounding,class:^(nwg-look)
windowrulev2 = float,floatpos center,noborder,norounding,class:(org.pulseaudio.pavucontrol)
windowrulev2 = size 50% 40%, class:(org.pulseaudio.pavucontrol)
windowrulev2 = float,class:(blueman-manager)


# Special Windowrules
windowrulev2 = idleinhibit fullscreen, class:.* # if a window is fullscreen, don't idle
windowrulev2=move 0 0,title:^(flameshot)



##############
# Layerrules #
##############
# https://wiki.hyprland.org/Configuring/Window-Rules/#layer-rules
layerrule = noanim, rofi

layerrule = blur, ^(waybar)$


#######################
# Windowrule Examples #
#######################

# Example windowrule v1
# windowrule = float, ^(kitty)$

# Example windowrule v2
# windowrulev2 = float,class:^(kitty)$,title:^(kitty)$



HYPRLANDCONFIG

else 
	echo "Hyprland config already exists."
fi

# Waybar Configuring File
if [ ! -f ~/.config/waybar/config.jsonc ]; then
mkdir -p ~/.config/waybar
cat << "WAYBARCONFIG" > ~/.config/waybar/config.jsonc
//# Waybar Configuring File.
//# https://github.com/Alexays/Waybar

// -*- mode: jsonc -*-
{
    // "layer": "top", // Waybar at top layer
    "position": "bottom", // Waybar position (top|bottom|left|right)
    "height": 28, // Waybar height (to be removed for auto height)
    //"width": 1400, // Waybar width
    "spacing": 5, // Gaps between modules
    "margin-top": 0,
    "margin-bottom": 6,
    "margin-left": 6,
    "margin-right": 6,
    // Choose the order of the modules
    "modules-left": [
        "hyprland/mode",
	"hyprland/workspaces"
        
    ],
    "modules-center": [
        "hyprland/window"
    ],
    "modules-right": [
        "mpd",
	"pulseaudio",
        "network",
        "cpu",
        "memory",
        "temperature",
        "backlight",
        "keyboard-state",
        "battery",
        "battery#bat2",
        "tray",
        "clock"
    ],
    "keyboard-state": {
        "numlock": true,
        "capslock": true,
        "format": "{name} {icon}",
        "format-icons": {
            "locked": "",
            "unlocked": ""
        }
    },
    "hyprland/workspaces": {
		"format": "{id}",
		"on-click": "activate",
		"format-icons": {
			"urgent": "",
			"active": "",
			"default": ""
			},
		"tooltip": false
	},
    "hyprland/mode": {
        "format": "<span style=\"italic\">{}</span>"
    },
    "hyprland/scratchpad": {
        "format": "{icon} {count}",
        "show-empty": false,
        "format-icons": ["", ""],
        "tooltip": true,
        "tooltip-format": "{app}: {title}"
    },
    "mpd": {
        "format": "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ",
        "format-disconnected": "Disconnected ",
        "format-stopped": "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ",
        "unknown-tag": "N/A",
        "interval": 5,
        "consume-icons": {
            "on": " "
        },
        "random-icons": {
            "off": "<span color=\"#f53c3c\"></span> ",
            "on": " "
        },
        "repeat-icons": {
            "on": " "
        },
        "single-icons": {
            "on": "1 "
        },
        "state-icons": {
            "paused": "",
            "playing": ""
        },
        "tooltip-format": "MPD (connected)",
        "tooltip-format-disconnected": "MPD (disconnected)"
    },
    "idle_inhibitor": {
        "format": "{icon}",
        "format-icons": {
            "activated": "",
            "deactivated": ""
        }
    },
    "tray": {
        // "icon-size": 18,
        "spacing": 10
    },
    "clock": {
        // "timezone": "Europe/Copenhagen",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "format-alt": "{:%d-%m-%Y}"
    },
    "cpu": {
        "format": "{usage}% ",
        "tooltip": false
    },
    "memory": {
        "format": "{}% "
    },
    "temperature": {
        // "thermal-zone": 2,
        // "hwmon-path": "/sys/class/hwmon/hwmon2/temp1_input",
        "critical-threshold": 80,
        // "format-critical": "{temperatureC}°C {icon}",
        "format": "{temperatureC}°C {icon}",
        "format-icons": ["", "", ""],
	"tooltip": false
    },
    "backlight": {
        // "device": "acpi_video1",
        "format": "{percent}% {icon}",
        "format-icons": ["", "", "", "", "", "", "", "", ""],
	"tooltip": false
    },
    "battery": {
        "states": {
            // "good": 95,
            "warning": 30,
            "critical": 15
        },
        "format": "{capacity}% {icon}",
        "format-full": "{capacity}% {icon}",
        "format-charging": "{capacity}% ",
        "format-plugged": "{capacity}% ",
        "format-alt": "{time} {icon}",
        // "format-good": "", // An empty format will hide the module
        // "format-full": "",
        "format-icons": ["", "", "", "", ""],
	"tooltip": false
    },
    "battery#bat2": {
        "bat": "BAT2"
    },
    "power-profiles-daemon": {
      "format": "{icon}",
      "tooltip-format": "Power profile: {profile}\nDriver: {driver}",
      "tooltip": true,
      "format-icons": {
        "default": "",
        "performance": "",
        "balanced": "",
        "power-saver": ""
      }
    },
    "network": {
        // "interface": "wlp2*", // (Optional) To force the use of this interface
        "format-wifi": "{essid} ({signalStrength}%) ",
        "format-ethernet": "{ipaddr}/{cidr} ",
        "tooltip-format": "{ifname} via {gwaddr} ",
        "format-linked": "{ifname} (No IP) ",
        "format-disconnected": "Disconnected ⚠",
        "format-alt": "{ifname}: {ipaddr}/{cidr}",
	"tooltip": false
    },
    "pulseaudio": {
		"scroll-step": 5,
		"format": "<span color='#fab387'>{icon}</span> {volume}%",
		"format-icons": {
		"default": ["", "", ""]
		},
		"on-click": "pavucontrol",
		"tooltip": false
	},
    "custom/media": {
        "format": "{icon} {text}",
        "return-type": "json",
        "max-length": 40,
        "format-icons": {
            "spotify": "",
            "default": "🎜"
        },
        "escape": true,
        "exec": "$HOME/.config/waybar/mediaplayer.py 2> /dev/null" // Script in resources folder
        // "exec": "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null" // Filter player based on name
    },
    "custom/power": {
        "format" : "⏻ ",
		"tooltip": false,
		"menu": "on-click",
		"menu-file": "$HOME/.config/waybar/power_menu.xml", // Menu file in resources folder
		"menu-actions": {
			"shutdown": "shutdown",
			"reboot": "reboot",
			"suspend": "systemctl suspend",
			"hibernate": "systemctl hibernate"
		}
    }
}


WAYBARCONFIG

else 
	echo "Waybar config already exists."
fi

# Waybar Style File
if [ ! -f ~/.config/waybar/style.css ]; then
mkdir -p ~/.config/waybar
cat << "WAYBARCONFIGSTYLE" > ~/.config/waybar/style.css
/* Waybar Sytle Configuring File.
https://github.com/Alexays/Waybar
*/

* {
    /* `Nerd Font` is required to be installed for icons */
    font-family: JetBrainsMono Nerd Font, FontAwesome, Roboto, Helvetica, Arial, sans-serif;
    font-size: 14px;
}

window#waybar {
    background-color: rgba(13, 32, 60, 0.8);
    border-bottom: 0px solid rgba(23, 36, 45, 0.55);
    color: #ffffff;
    transition-property: background-color;
    transition-duration: .5s;
}

window#waybar.hidden {
    opacity: 0.2;
}

/*
window#waybar.empty {
    background-color: transparent;
}
window#waybar.solo {
    background-color: #FFFFFF;
}
*/

window#waybar.termite {
    background-color: #3F3F3F;
}

window#waybar.chromium {
    background-color: #000000;
    border: none;
}

button {
    /* Use box-shadow instead of border so the text isn't offset */
    box-shadow: inset 0 -3px transparent;
    /* Avoid rounded borders under each button name */
    border: none;
    border-radius: 0;
}

/* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
button:hover {
    background: inherit;
    box-shadow: inset 0 -3px #ffffff;
}

/* you can set a style on hover for any module like this */
#pulseaudio:hover {
    background-color: #a37800;
}

#workspaces button {
    padding: 0 5px;
    background-color: transparent;
    color: #ffffff;
}

#workspaces button:hover {
    background: rgba(0, 0, 0, 0.2);
}

#workspaces button.focused {
    background-color: #64727D;
    box-shadow: inset 0 -3px #ffffff;
}

#workspaces button.urgent {
    background-color: #eb4d4b;
}

#mode {
    background-color: #64727D;
    box-shadow: inset 0 -3px #ffffff;
}

#clock,
#battery,
#cpu,
#memory,
#disk,
#temperature,
#backlight,
#network,
#pulseaudio,
#wireplumber,
#custom-media,
#tray,
#mode,
#idle_inhibitor,
#scratchpad,
#power-profiles-daemon,
#mpd {
    padding: 0 10px;
    color: #ffffff;
}

#window,
#workspaces {
    margin: 0 4px;
}

/* If workspaces is the leftmost module, omit left margin */
.modules-left > widget:first-child > #workspaces {
    margin-left: 0;
}

/* If workspaces is the rightmost module, omit right margin */
.modules-right > widget:last-child > #workspaces {
    margin-right: 0;
}

#clock {
    background-color: #64727D;
}

#battery {
    background-color: #ffffff;
    color: #000000;
}

#battery.charging, #battery.plugged {
    color: #ffffff;
    background-color: #26A65B;
}

@keyframes blink {
    to {
        background-color: #ffffff;
        color: #000000;
    }
}

/* Using steps() instead of linear as a timing function to limit cpu usage */
#battery.critical:not(.charging) {
    background-color: #f53c3c;
    color: #ffffff;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: steps(12);
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

#power-profiles-daemon {
    padding-right: 15px;
}

#power-profiles-daemon.performance {
    background-color: #f53c3c;
    color: #ffffff;
}

#power-profiles-daemon.balanced {
    background-color: #2980b9;
    color: #ffffff;
}

#power-profiles-daemon.power-saver {
    background-color: #2ecc71;
    color: #000000;
}

label:focus {
    background-color: #000000;
}

#cpu {
    background-color: #2ecc71;
    color: #000000;
}

#memory {
    background-color: #9b59b6;
}

#disk {
    background-color: #964B00;
}

#backlight {
    background-color: #90b1b1;
}

#network {
    background-color: #2980b9;
}

#network.disconnected {
    background-color: #f53c3c;
}

#pulseaudio {
    background-color: #f1c40f;
    color: #000000;
}

#pulseaudio.muted {
    background-color: #90b1b1;
    color: #2a5c45;
}

#wireplumber {
    background-color: #fff0f5;
    color: #000000;
}

#wireplumber.muted {
    background-color: #f53c3c;
}

#custom-media {
    background-color: #66cc99;
    color: #2a5c45;
    min-width: 100px;
}

#custom-media.custom-spotify {
    background-color: #66cc99;
}

#custom-media.custom-vlc {
    background-color: #ffa000;
}

#temperature {
    background-color: #f0932b;
}

#temperature.critical {
    background-color: #eb4d4b;
}

#tray {
    background-color: #2980b9;
}

#tray > .passive {
    -gtk-icon-effect: dim;
}

#tray > .needs-attention {
    -gtk-icon-effect: highlight;
    background-color: #eb4d4b;
}

#idle_inhibitor {
    background-color: #2d3436;
}

#idle_inhibitor.activated {
    background-color: #ecf0f1;
    color: #2d3436;
}

#mpd {
    background-color: #66cc99;
    color: #2a5c45;
}

#mpd.disconnected {
    background-color: #f53c3c;
}

#mpd.stopped {
    background-color: #90b1b1;
}

#mpd.paused {
    background-color: #51a37a;
}

#language {
    background: #00b093;
    color: #740864;
    padding: 0 5px;
    margin: 0 5px;
    min-width: 16px;
}

#keyboard-state {
    background: #97e1ad;
    color: #000000;
    padding: 0 0px;
    margin: 0 5px;
    min-width: 16px;
}

#keyboard-state > label {
    padding: 0 5px;
}

#keyboard-state > label.locked {
    background: rgba(0, 0, 0, 0.2);
}

#scratchpad {
    background: rgba(0, 0, 0, 0.2);
}

#scratchpad.empty {
	background-color: transparent;
}

#privacy {
    padding: 0;
}

#privacy-item {
    padding: 0 5px;
    color: white;
}

#privacy-item.screenshare {
    background-color: #cf5700;
}

#privacy-item.audio-in {
    background-color: #1ca000;
}

#privacy-item.audio-out {
    background-color: #0069d4;
}

WAYBARCONFIGSTYLE

else 
	echo "Waybar style.css already exists."
fi

# Waybar Style File
if [ ! -f ~/.config/waybar/auto-reload-waybar.sh ]; then
mkdir -p ~/.config/waybar
cat << "WAYBARAUTORELOAD" > ~/.config/waybar/auto-reload-waybar.sh
#!/bin/bash

# start waybar if not started
if ! pgrep -x "waybar" > /dev/null; then
	waybar &
fi

# current checksums
current_checksum_config=$(md5sum ~/.config/waybar/config.jsonc)
current_checksum_style=$(md5sum ~/.config/waybar/style.css)

# loop forever
while true; do
	# new checksums
	new_checksum_config=$(md5sum ~/.config/waybar/config.jsonc)
	new_checksum_style=$(md5sum ~/.config/waybar/style.css)

	# if checksums are different
	if [ "$current_checksum_config" != "$new_checksum_config" ] || [ "$current_checksum_style" != "$new_checksum_style" ]; then
		# kill waybar
		killall waybar

		# start waybar
		waybar &

		# update checksums
		current_checksum_config=$new_checksum_config
		current_checksum_style=$new_checksum_style
	fi
done

WAYBARAUTORELOAD

chmod +x ~/.config/waybar/auto-reload-waybar.sh

else 
	echo "Waybar auto reload already exists."
fi

# Kitty config file START

if [ ! -f ~/.config/kitty/kitty.conf ]; then
mkdir -p ~/.config/kitty/themes
cat << "KITTYCONFIG" > ~/.config/kitty/kitty.conf
# A default configuration file can also be generated by running:
# kitty +runpy 'from kitty.config import *; print(commented_out_default_config())'
#
# The following command will bring up the interactive terminal GUI
# kitty +kitten themes
#
# kitty +kitten themes Catppuccin-Mocha
# kitty +kitten themes --reload-in=all Catppuccin-Mocha

background_opacity 0.98

font_family      JetBrainsMono Nerd Font
bold_font        auto
italic_font      auto
bold_italic_font auto

font_size 12
force_ltr no

adjust_line_height  0
adjust_column_width 0

adjust_baseline 0

disable_ligatures never

box_drawing_scale 0.001, 1, 1.5, 2

cursor #f2f2f2

cursor_text_color #f2f2f2

cursor_shape underline

cursor_beam_thickness 1.5

cursor_underline_thickness 2.0

cursor_blink_interval -1

cursor_stop_blinking_after 99.0

scrollback_lines 5000

scrollback_pager less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER

scrollback_pager_history_size 0

scrollback_fill_enlarged_window no

wheel_scroll_multiplier 5.0

touch_scroll_multiplier 1.0

mouse_hide_wait 3.0

mouse_map right click paste_from_clipboard

url_color #0087bd
url_style curly

open_url_with default

url_prefixes http https file ftp gemini irc gopher mailto news git

detect_urls yes

url_excluded_characters 

copy_on_select yes

strip_trailing_spaces never

select_by_word_characters @-./_~?&=%+#

click_interval -1.0

focus_follows_mouse no

pointer_shape_when_grabbed arrow

default_pointer_shape beam

pointer_shape_when_dragging beam

mouse_map left            click ungrabbed mouse_click_url_or_select
mouse_map shift+left      click grabbed,ungrabbed mouse_click_url_or_select
mouse_map ctrl+shift+left release grabbed,ungrabbed mouse_click_url

mouse_map ctrl+shift+left press grabbed discard_event

mouse_map middle        release ungrabbed paste_from_selection
mouse_map left          press ungrabbed mouse_selection normal
mouse_map ctrl+alt+left press ungrabbed mouse_selection rectangle
mouse_map left          doublepress ungrabbed mouse_selection word
mouse_map left          triplepress ungrabbed mouse_selection line

mouse_map ctrl+alt+left triplepress ungrabbed mouse_selection line_from_point

#mouse_map right               press ungrabbed mouse_selection extend
mouse_map shift+middle        release ungrabbed,grabbed paste_selection
mouse_map shift+left          press ungrabbed,grabbed mouse_selection normal
mouse_map shift+ctrl+alt+left press ungrabbed,grabbed mouse_selection rectangle
mouse_map shift+left          doublepress ungrabbed,grabbed mouse_selection word
mouse_map shift+left          triplepress ungrabbed,grabbed mouse_selection line

mouse_map shift+ctrl+alt+left triplepress ungrabbed,grabbed mouse_selection line_from_point

repaint_delay 10

input_delay 5

sync_to_monitor yes

enable_audio_bell no

visual_bell_duration 0.0

window_alert_on_bell no

bell_on_tab no

command_on_bell none

remember_window_size  yes
initial_window_width  800
initial_window_height 500

enabled_layouts *

window_resize_step_cells 2
window_resize_step_lines 2

window_border_width 0.0pt

draw_minimal_borders yes

window_margin_width 0

single_window_margin_width -1

window_padding_width 3

placement_strategy center

active_border_color #f2f2f2

inactive_border_color #cccccc

bell_border_color #ff5a00

inactive_text_alpha 1.0

hide_window_decorations no

resize_debounce_time 0.1

resize_draw_strategy static

resize_in_steps no

confirm_os_window_close 0

tab_bar_edge bottom

tab_bar_margin_width 0.0

tab_bar_margin_height 0.0 0.0

tab_bar_style fade

tab_bar_min_tabs 2

tab_switch_strategy previous

tab_fade 0.25 0.5 0.75 1

tab_separator " |"

tab_powerline_style angled

tab_activity_symbol none

tab_title_template "{title}"

active_tab_title_template none

active_tab_foreground   #000
active_tab_background   #eee
active_tab_font_style   bold-italic
inactive_tab_foreground #444
inactive_tab_background #999
inactive_tab_font_style normal

tab_bar_background none

background_image none

background_image_layout tiled

background_image_linear no

dynamic_background_opacity no

background_tint 0.0

dim_opacity 0.75

selection_foreground #000000

selection_background #fffacd

mark1_foreground black

mark1_background #98d3cb

mark2_foreground black

mark2_background #f2dcd3

mark3_foreground black

mark3_background #f274bc

shell .

editor .

close_on_child_death no

allow_remote_control yes

listen_on none

update_check_interval 0

startup_session none

clipboard_control write-clipboard write-primary

allow_hyperlinks yes

term xterm-kitty

wayland_titlebar_color system

macos_titlebar_color system

macos_option_as_alt no

macos_hide_from_tasks no

macos_quit_when_last_window_closed no

macos_window_resizable yes

macos_thicken_font 0

macos_traditional_fullscreen no

macos_show_window_title_in all

macos_custom_beam_cursor no

linux_display_server auto

kitty_mod ctrl+shift

clear_all_shortcuts no
map kitty_mod+c copy_to_clipboard
map kitty_mod+v paste_from_clipboard
map kitty_mod+up        scroll_line_up
map kitty_mod+down      scroll_line_down
map kitty_mod+page_up   scroll_page_up
map kitty_mod+page_down scroll_page_down
map kitty_mod+home      scroll_home
map kitty_mod+end       scroll_end
map kitty_mod+h         show_scrollback
map kitty_mod+w close_window
map kitty_mod+] next_window
map kitty_mod+[ previous_window
map kitty_mod+f move_window_forward
map kitty_mod+b move_window_backward
map kitty_mod+` move_window_to_top
map kitty_mod+r start_resizing_window
map kitty_mod+1 first_window
map kitty_mod+2 second_window
map kitty_mod+3 third_window
map kitty_mod+4 fourth_window
map kitty_mod+5 fifth_window
map kitty_mod+6 sixth_window
map kitty_mod+7 seventh_window
map kitty_mod+8 eighth_window
map kitty_mod+9 ninth_window
map kitty_mod+0 tenth_window
map kitty_mod+right next_tab
map kitty_mod+left  previous_tab
map kitty_mod+t     new_tab
map kitty_mod+q     close_tab
map shift+cmd+w     close_os_window
map kitty_mod+.     move_tab_forward
map kitty_mod+,     move_tab_backward
map kitty_mod+alt+t set_tab_title
map kitty_mod+l next_layout
map kitty_mod+equal     change_font_size all +2.0
map kitty_mod+minus     change_font_size all -2.0
map kitty_mod+backspace change_font_size all 0
map kitty_mod+e kitten hints
map kitty_mod+p>f kitten hints --type path --program -
map kitty_mod+p>shift+f kitten hints --type path
map kitty_mod+p>l kitten hints --type line --program -
map kitty_mod+p>w kitten hints --type word --program -
map kitty_mod+p>h kitten hints --type hash --program -
map kitty_mod+p>n kitten hints --type linenum
map kitty_mod+p>y kitten hints --type hyperlink
map kitty_mod+f11    toggle_fullscreen
map kitty_mod+f10    toggle_maximized
map kitty_mod+u      kitten unicode_input
map kitty_mod+f2     edit_config_file
map kitty_mod+escape kitty_shell window
map kitty_mod+a>m    set_background_opacity +0.1
map kitty_mod+a>l    set_background_opacity -0.1
map kitty_mod+a>1    set_background_opacity 1
map kitty_mod+a>d    set_background_opacity default
map kitty_mod+delete clear_terminal reset active
map kitty_mod+f5 load_config_file
map kitty_mod+f6 debug_config

include ~/.config/kitty/themes/kittytheme.conf

KITTYCONFIG

else 
	echo "Kitty config already exists."
fi

# Kitty Theme.conf Start

if [ ! -f $HOME/.config/kitty/themes/kittytheme.conf ]; then
mkdir -p $HOME/.config/kitty/themes
cat << "KITTYTHEMECONF" > $HOME/.config/kitty/themes/kittytheme.conf
# vim:ft=kitty

## name:     Catppuccin Kitty Mocha
## author:   Catppuccin Org
## license:  MIT
## upstream: https://github.com/catppuccin/kitty/blob/main/themes/mocha.conf
## blurb:    Soothing pastel theme for the high-spirited!


# The basic colors
foreground              #cdd6f4
background              #1e1e2e
selection_foreground    #1e1e2e
selection_background    #f5e0dc

# Cursor colors
cursor                  #f5e0dc
cursor_text_color       #1e1e2e

# URL underline color when hovering with mouse
url_color               #f5e0dc

# Kitty window border colors
active_border_color     #b4befe
inactive_border_color   #6c7086
bell_border_color       #f9e2af

# OS Window titlebar colors
wayland_titlebar_color system
macos_titlebar_color system

# Tab bar colors
active_tab_foreground   #11111b
active_tab_background   #cba6f7
inactive_tab_foreground #cdd6f4
inactive_tab_background #181825
tab_bar_background      #11111b

# Colors for marks (marked text in the terminal)
mark1_foreground #1e1e2e
mark1_background #b4befe
mark2_foreground #1e1e2e
mark2_background #cba6f7
mark3_foreground #1e1e2e
mark3_background #74c7ec

# The 16 terminal colors

# black
color0 #45475a
color8 #585b70

# red
color1 #f38ba8
color9 #f38ba8

# green
color2  #a6e3a1
color10 #a6e3a1

# yellow
color3  #f9e2af
color11 #f9e2af

# blue
color4  #89b4fa
color12 #89b4fa

# magenta
color5  #f5c2e7
color13 #f5c2e7

# cyan
color6  #94e2d5
color14 #94e2d5

# white
color7  #bac2de
color15 #a6adc8


KITTYTHEMECONF

else 
	echo "kittytheme.conf file already exists."
fi

# Kitty config file END

# Add User NOPASSWD to shutdown now and reboot
echo "$USER ALL=(ALL) NOPASSWD: /sbin/shutdown now, /sbin/reboot" | sudo tee /etc/sudoers.d/$USER && sudo visudo -c -f /etc/sudoers.d/$USER

# PyWAL install via pipx
pipx install pywal16
pipx ensurepath

# Wallpapers
if [ ! -d ~/Wallpapers ]; then
mkdir -p ~/Wallpapers
wget -O ~/Wallpapers/default_wallpaper-1.jpg https://github.com/ITmail-dk/Wallpapers/blob/main/02291f01-d081-44e8-a397-db5c37d5111d.png?raw=true
wget -O ~/Wallpapers/default_wallpaper-2.jpg https://github.com/ITmail-dk/Wallpapers/blob/main/473cae61-5c2f-4889-8425-c8a153999151.png?raw=true
wget -O ~/Wallpapers/default_wallpaper-3.jpg https://github.com/ITmail-dk/Wallpapers/blob/main/d1acf8b6-c06f-477c-826e-95e63c374603.png?raw=true

else 
	echo "Wallpapers folder already exists."
fi


echo -e "${YELLOW} auto-new-wallpaper-and-colors BIN START ${NC}"
sudo bash -c 'cat << "AUTONEWWALLPAPERANDCOLORSBIN" >> /usr/local/bin/auto-new-wallpaper-and-colors
#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/.local/bin

if [ ! -f "$HOME/.config/extract_colors.py" ]; then
    echo "$HOME/.config/extract_colors.py not found! Please ensure the Python script is in the same directory."
    exit 1
fi

RWALLP="$(find $HOME/Wallpapers -type f | shuf -n 1)"

notify-send -u low "Automatically new background and color theme" "Please wait while we find a new background image and some colors to match"

python3 $HOME/.config/extract_colors.py $RWALLP
feh --bg-scale $RWALLP
qtile cmd-obj -o cmd -f reload_config
kitty +kitten themes --reload-in=all Kittytheme

notify-send -u low "Automatically new background and color theme" "The background image and colors has been updated."

AUTONEWWALLPAPERANDCOLORSBIN'

sudo chmod +x /usr/local/bin/auto-new-wallpaper-and-colors

echo -e "${YELLOW} auto-new-wallpaper-and-colors BIN END ${NC}"


# Extract New-Colors file
if [ ! -f ~/.config/extract_colors.py ]; then
cat << "EXTRACTCOLORS" > ~/.config/extract_colors.py
import sys
import os
import colorgram
from PIL import Image, ImageDraw, ImageFont

def rgb_to_hex(rgb):
    return '#{:02x}{:02x}{:02x}'.format(rgb[0], rgb[1], rgb[2])

def luminance(rgb):
    r, g, b = rgb[0]/255.0, rgb[1]/255.0, rgb[2]/255.0
    a = [r, g, b]
    for i in range(len(a)):
        if a[i] <= 0.03928:
            a[i] = a[i] / 12.92
        else:
            a[i] = ((a[i] + 0.055) / 1.055) ** 2.4
    return 0.2126 * a[0] + 0.7152 * a[1] + 0.0722 * a[2]

def choose_text_color(background_color):
    if luminance(background_color) > 0.5:
        return (0, 0, 0)  # dark text for light background
    else:
        return (255, 255, 255)  # light text for dark background

def create_color_grid(colors, base16_colors, filename='color_grid.png'):
    grid_size = 4  # 4x4 grid
    square_size = 150  # Size of each small square
    img_size = square_size * grid_size  # Calculate total image size

    img = Image.new('RGB', (img_size, img_size))
    draw = ImageDraw.Draw(img)

    # Load a font
    try:
        font = ImageFont.truetype("arial.ttf", 30)
    except IOError:
        font = ImageFont.load_default()

    # Fill the grid with colors and add text labels
    for i, (key, value) in enumerate(base16_colors.items()):
        x = (i % grid_size) * square_size
        y = (i // grid_size) * square_size
        draw.rectangle([x, y, x + square_size, y + square_size], fill=value)
        # Choose text color based on background color luminance
        text_color = choose_text_color(tuple(int(value[i:i+2], 16) for i in (1, 3, 5)))
        # Add text label
        text_position = (x + 10, y + 10)
        draw.text(text_position, key, fill=text_color, font=font)

    img.save(filename)


def main(image_path):
    colors = colorgram.extract(image_path, 16)

    # Ensure there are exactly 16 colors by duplicating if necessary
    while len(colors) < 16:
        colors.append(colors[len(colors) % len(colors)])

    # Sort colors by luminance
    colors.sort(key=lambda col: luminance(col.rgb))

    # Assign colors to Base16 scheme slots ensuring the tonal range
    base16_colors = {
        'base00': rgb_to_hex(colors[0].rgb),
        'base01': rgb_to_hex(colors[5].rgb),
        'base02': rgb_to_hex(colors[12].rgb),
        'base03': rgb_to_hex(colors[9].rgb),
        'base04': rgb_to_hex(colors[4].rgb),
        'base05': rgb_to_hex(colors[10].rgb),
        'base06': rgb_to_hex(colors[6].rgb),
        'base07': rgb_to_hex(colors[14].rgb),
        'base08': rgb_to_hex(colors[2].rgb),
        'base09': rgb_to_hex(colors[3].rgb),
        'base0A': rgb_to_hex(colors[1].rgb),
        'base0B': rgb_to_hex(colors[11].rgb),
        'base0C': rgb_to_hex(colors[8].rgb),
        'base0D': rgb_to_hex(colors[13].rgb),
        'base0E': rgb_to_hex(colors[7].rgb),
        'base0F': rgb_to_hex(colors[15].rgb),
    }

    descriptions = [
        "Default Background",
        "Lighter Background (Used for status bars, line number and folding marks)",
        "Selection Background",
        "Comments, Invisibles, Line Highlighting",
        "Dark Foreground (Used for status bars)",
        "Default Foreground, Caret, Delimiters, Operators",
        "Light Foreground (Not often used)",
        "Light Background (Not often used)",
        "Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted",
        "Integers, Boolean, Constants, XML Attributes, Markup Link Url",
        "Classes, Markup Bold, Search Text Background",
        "Strings, Inherited Class, Markup Code, Diff Inserted",
        "Support, Regular Expressions, Escape Characters, Markup Quotes",
        "Functions, Methods, Attribute IDs, Headings",
        "Keywords, Storage, Selector, Markup Italic, Diff Changed",
        "Deprecated, Opening/Closing Embedded Language Tags",
    ]

    # Ensure the directory exists
    qtile_config_dir = os.path.expanduser('~/.config/qtile/')
    os.makedirs(qtile_config_dir, exist_ok=True)

    # Path to the output file
    output_file_path = os.path.join(qtile_config_dir, 'qtile_colors.py')

    # Write the colors to the Python file
    with open(output_file_path, 'w') as f:
        f.write("colors = {\n")
        for key, value in base16_colors.items():
            description = descriptions.pop(0)
            f.write(f'    "{key}": "{value}",  # {description}\n')
        f.write("}\n")

    # Ensure the directory exists
    kitty_config_dir = os.path.expanduser('~/.config/kitty/themes/')
    os.makedirs(kitty_config_dir, exist_ok=True)

    # Path to the output file
    output_file_path = os.path.join(kitty_config_dir, 'kittytheme.conf')

    with open(output_file_path, 'w') as f:
        f.write(f'background {base16_colors["base00"]}\n')
        f.write(f'foreground {base16_colors["base0F"]}\n')
        for index, (_, value) in enumerate(base16_colors.items()):
            f.write(f'color{index} {value}\n')
    # Create a PNG file with the extracted colors and labels
    create_color_grid(colors, base16_colors)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: extract_colors.py <image_path>")
    else:
        main(sys.argv[1])

EXTRACTCOLORS

else 
	echo "File ~/.config/extract_colors.py already exists."
fi


# Fonts - https://www.nerdfonts.com/font-downloads

# IBM Plex Mono

font_name=JetBrainsMono
curl -OL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font_name.zip"
mkdir -p  "$HOME/.fonts"
unzip "$font_name.zip" -d "$HOME/.fonts/$font_name/"
fc-cache -fv
rm $font_name.zip



# END
cd ~

# Install closing screen ##### ##### ##### ##### ##### ##### ##### ##### ##### ####
clear
if (whiptail --title "Installation Complete" --yesno "Hmade Installation is complete. \nDo you want to restart the computer ?\n\nSome practical information. \nWindows key + Enter opens a terminal \nWindows key + B opens a web browser \nWindows key + W closes the active window" 15 60); then
    cd ~
    clear
    echo -e "${RED} "
    echo -e "${RED}-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-"
    echo -e "${RED} "
    echo -e "${RED}      Enter your user password, to continue if necessary"
    echo -e "${RED} "
    echo -e "${RED}-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-"
    echo -e "${RED} ${NC}"
    sudo reboot
    echo -e "${GREEN}See you later alligator..."
    echo -e "${GREEN} "
    echo -e "${GREEN} ${NC}"
else
    cd ~
    clear
    echo -e "${GREEN} -'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-"
    echo -e "${GREEN} "
    echo -e "${GREEN}    You chose not to restart the computer, Installation complete."
    echo -e "${GREEN}    			Ready to restart..."
    echo -e "${GREEN} "
    echo -e "${GREEN} -'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'- ${NC}"
fi

# Install Done ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##
