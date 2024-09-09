#!/bin/bash
#DEV TEST
# nano /tmp/install.sh && chmod +x /tmp/install.sh && . /tmp/install.sh

# Set Echo colors
# for c in {0..255}; do tput setaf $c; tput setaf $c | cat -v; echo =$c; done
NC="\033[0m"
RED="\033[0;31m"
RED2="\033[38;5;196m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;94m"

FULLUSERNAME=$(awk -v user="$USER" -F":" 'user==$1{print $5}' /etc/passwd | rev | cut -c 4- | rev)

clear

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

clear
echo -e "${RED} "
echo -e "${RED}-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-"
echo -e "${RED} "
echo -e "${RED}      Starting the installation..."
echo -e "${RED}      Enter your user password, to continue if necessary"
echo -e "${RED} "
echo -e "${RED}-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-'-"
echo -e "${RED} ${NC}"

sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak.$(date +'%d-%m-%Y_%H%M%S')

if ! dpkg -s apt-transport-https >/dev/null 2>&1; then
    sudo apt -y install apt-transport-https
    sudo sed -i 's+http:+https:+g' /etc/apt/sources.list
else
    echo "apt-transport-https is already installed."
fi

# 1. Deaktivér linjer med 'deb cdrom:' i /etc/apt/sources.list
sudo sed -i '/^deb cdrom:/s/^/#/' /etc/apt/sources.list

# 2. Kontroller og tilføj Bookworm repositories, hvis de ikke allerede er der
if ! grep -q "^deb http://deb.debian.org/debian/ bookworm main non-free-firmware" /etc/apt/sources.list; then
    echo "Tilføjer Debian Bookworm repositories til /etc/apt/sources.list"
    sudo tee -a /etc/apt/sources.list <<EOL

deb http://deb.debian.org/debian/ bookworm main non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm main non-free-firmware

deb http://security.debian.org/debian-security bookworm-security main non-free-firmware
deb-src http://security.debian.org/debian-security bookworm-security main non-free-firmware

deb http://deb.debian.org/debian/ bookworm-updates main non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm-updates main non-free-firmware

EOL
else
    echo "Debian Bookworm repositories er allerede tilføjet."
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


clear

sudo sed -i 's/bookworm main/sid main/g' /etc/apt/sources.list

sudo sed -i 's/bookworm-security/testing-security/g' /etc/apt/sources.list

sudo sed -i 's/bookworm-updates/testing-updates/g' /etc/apt/sources.list

export DEBIAN_FRONTEND=noninteractive

sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

sudo apt -y install sddm --no-install-recommends

sudo apt install -y git wget curl fastfetch kitty wayland-protocols wayland-utils waybar wlogout hyprland hyprland-protocols

sudo apt install -y dbus acpi nwg-look xdg-utils xdp-tools xdg-desktop-portal-gtk xwayland qt6-wayland xsensors flameshot speedcrunch mc gparted mpd mpc ncmpcpp fzf ccrypt xarchiver notepadqq

sudo apt install -y thunar gvfs-backends xarchiver rofi dunst libnotify-bin notify-osd brightnessctl swaylock usbutils feh

# Network
sudo apt install -y network-manager 

# Printer
sudo apt install -y printer-driver-all cups cups-client cups-filters cups-pdf system-config-printer

#sudo apt install -y linux-headers-$(uname -r)

sudo apt install -y mate-polkit --no-install-recommends
#sudo apt install -y polkit-kde-agent-1 --no-install-recommends

# Audio
sudo apt install -y pipewire wireplumber pavucontrol pipewire-alsa pipewire-pulse pipewire-jack
 
# PipeWire Sound Server "Audio" - https://pipewire.org/
systemctl enable --user --now pipewire.socket pipewire-pulse.socket wireplumber.service

# Bluetooth
sudo apt install -y bluetooth bluez-firmware blueman bluez bluez-tools bluez-cups bluez-obexd bluez-meshd pulseaudio-module-bluetooth libspa-0.2-bluetooth libspa-0.2-jack


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


# Install GPU drivers
install_gpu_driver() {
  gpu_driver=""
  case "$(lspci | grep -E 'VGA|3D')" in
    *Intel*) gpu_driver="intel-media-va-driver intel-media-va-driver-non-free" ;;
    *AMD*)   gpu_driver="mesa-va-drivers libvdpau-va-gl1" ;;
    *NVIDIA*)gpu_driver="mesa-va-drivers nvidia-driver libvdpau-va-gl1 nvidia-vdpau-driver libnvcuvid1 libnvidia-encode1" ;;
  esac
  for pkg in $gpu_driver; do
    [ -n "$pkg" ] && sudo apt install --no-install-recommends -y "$pkg"
  done
}

install_gpu_driver

sleep 1
#clear

cd /tmp/ && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && sudo apt install -y /tmp/google-chrome-stable_current_amd64.deb && rm google-chrome-stable_current_amd64.deb

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
echo 'alias upup="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y"' >> ~/.bashrc
echo 'bind '"'"'"\C-f":"open "$(fzf)"\n"'"'" >> ~/.bashrc


# Config folders & files

echo -e "${GREEN} Hyprland config file START ${NC}"

if [ ! -f ~/.config/hypr/hyprland.conf ]; then
mkdir -p ~/.config/hypr
cat << "HYPRLANDCONFIG" > ~/.config/hypr/hyprland.conf
# This is an Hyprland config file.
# Refer to the wiki for more information.
# https://wiki.hyprland.org/Configuring/Configuring-Hyprland/

# Please note not all available settings / options are set here.
# For a full list, see the wiki

# You can split this configuration into multiple files
# Create your files separately and then link them to this file like this:
# source = ~/.config/hypr/myColors.conf


################
### MONITORS ###
################

# See https://wiki.hyprland.org/Configuring/Monitors/
monitor=,preferred,auto,1


###################
### MY PROGRAMS ###
###################

# See https://wiki.hyprland.org/Configuring/Keywords/

# Set programs that you use
$terminal = kitty
$filemanager = thunar
$runmenu = rofi -modi "drun,run,window,filebrowser" -show drun # Switch between -modi... Default key CTRL+TAB
$browser = google-chrome


#################
### AUTOSTART ###
#################

# Autostart necessary processes (like notifications daemons, status bars, etc.)
# Or execute your favorite apps at launch like this:

exec-once = dunst
# exec-once = waybar
# exec-once = nm-applet


#############################
### ENVIRONMENT VARIABLES ###
#############################

# See https://wiki.hyprland.org/Configuring/Environment-variables/

env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24


#####################
### LOOK AND FEEL ###
#####################

# Refer to https://wiki.hyprland.org/Configuring/Variables/

# https://wiki.hyprland.org/Configuring/Variables/#general
general {
    gaps_in = 5
    gaps_out = 10

    border_size = 1

    # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)

    # Set to true enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = false

    # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
    allow_tearing = false

    layout = dwindle
}

# https://wiki.hyprland.org/Configuring/Variables/#decoration
decoration {
    rounding = 3

    # Change transparency of focused and unfocused windows
    active_opacity = 1.0
    inactive_opacity = 1.0

    drop_shadow = true
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)

    # https://wiki.hyprland.org/Configuring/Variables/#blur
    blur {
        enabled = true
        size = 3
        passes = 1

        vibrancy = 0.1696
    }
}

# https://wiki.hyprland.org/Configuring/Variables/#animations
animations {
    enabled = true

    # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

    bezier = myBezier, 0.05, 0.9, 0.1, 1.05

    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
dwindle {
    pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
    preserve_split = true # You probably want this
}

# See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
master {
    new_status = master
}

# https://wiki.hyprland.org/Configuring/Variables/#misc
misc {
    force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo = false # If true disables the random hyprland logo / anime girl background. :(
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
### KEYBINDINGSS ###
####################
# See https://wiki.hyprland.org/Configuring/Keywords/
# Mod list - SHIFT, CAPS, CTRL/CONTROL, ALT, MOD2, MOD3, SUPER/WIN/LOGO/MOD4, MOD5

$mainMod = SUPER # Sets "Windows" key as main modifier

# Binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
bind = $mainMod, Return, exec, $terminal
bind = $mainMod, W, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, $filemanager
bind = $mainMod, F, togglefloating,
bind = $mainMod, R, exec, $runmenu
bind = $mainMod, P, pseudo, # dwindle
bind = $mainMod, J, togglesplit, # dwindle

# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

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
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Special Workspace (scratchpad)
bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod SHIFT, S, movetoworkspace, special:magic

# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow


bind = $mainMod, B, exec, $browser


# Audio
binde = , XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 1%+
binde = , XF86AudioLowerVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-
binde = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle || notify-send -u low "Audio muted" " "


bind = $mainMod ALT, up, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 1%+
bind = $mainMod ALT, down, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-
bind = $mainMod ALT, M, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

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

# Lockdown
bind = , XF86Lock, exec, hyprlock # Open screenlock

##############################
### WINDOWS AND WORKSPACES ###
##############################

# See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
# See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

# Example windowrule v1
# windowrule = float, ^(kitty)$

# Example windowrule v2
# windowrulev2 = float,class:^(kitty)$,title:^(kitty)$

windowrulev2 = suppressevent maximize, class:.* # You'll probably like this.

windowrulev2 = float,size 30% 50%,floatpos center,noborder,norounding,class:^(rofi|Rofi)$

#source = ~/.config/hypr/autostart.conf
HYPRLANDCONFIG

else 
	echo "Hyprland config already exists."
fi


echo -e "${GREEN} Kitty config file START ${NC}"

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

font_family      monospace
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

echo -e "${GREEN}Kitty Theme.conf Start${NC}"

if [ ! -f $HOME/.config/kitty/themes/kittytheme.conf ]; then
mkdir -p $HOME/.config/kitty/themes
cat << "KITTYTHEMECONF" > $HOME/.config/kitty/themes/kittytheme.conf
background #1b0200
foreground #ee712d
color0 #1b0200
color1 #240002
color2 #d74d00
color3 #d74d00
color4 #9c2101
color5 #d74d00
color6 #d74d00
color7 #d74d00
color8 #d74d00
color9 #830508
color10 #d74d00
color11 #d74d00
color12 #9a292f
color13 #e46324
color14 #ea6f10
color15 #ee712d

KITTYTHEMECONF

else 
	echo "kittytheme.conf file already exists."
fi

echo -e "${GREEN}Kitty config file END${NC}"

# Add User NOPASSWD to shutdown now and reboot
echo "$USER ALL=(ALL) NOPASSWD: /sbin/shutdown now, /sbin/reboot" | sudo tee /etc/sudoers.d/$USER && sudo visudo -c -f /etc/sudoers.d/$USER


echo -e "${GREEN}Wallpapers${NC}"

if [ ! -d ~/Wallpapers ]; then
mkdir -p ~/Wallpapers
wget -O ~/Wallpapers/default_wallpaper.jpg https://github.com/ITmail-dk/qmade/blob/main/default_wallpaper_by_natalia-y_on_unsplash.jpg?raw=true

else 
	echo "Wallpapers folder already exists."
fi

#if [ -f ~/.fehbg ]; then
#    . ~/.fehbg
#else
#    feh --bg-scale ~/Wallpapers/default_wallpaper.jpg
#fi

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





# END
cd ~

echo -e "${GREEN}Installation complete ready to restart.${NC}"
