#!/bin/bash
# os tested debian -13
# title             :server tool script
# description       :tigervnc-scraping-server, log in to the actual X session on display :0 , uncompliaced firewall for pia , check radicale, check other server tools
# date              :2025
# version           :0.1
# notes             :install tigervnc-scraping-server w PIA VPN  ( with firewall on you will be totally blocked without tun0 vpn and local allowed in PIA)
#
SCRIPTNAME="fWVNC"  # What's the script name
HOMEDIR=${HOME}  # Set home directory
FW1="   " #setting var variable
FW2="not checked FW status"
echo "$FW1" #displaying var variable on terminal
echo "$FW2" #displaying var variable on terminal
VNC1="unknown" #setting var variable
VNC2="not verifyed"
echo "$VNC1" #displaying var variable on terminal
echo "$VNC2" #displaying var variable on terminal
#vnc varibile
VNCSERVER="/usr/bin/x0vncserver"   #Where the x0vncserver executable is located, default:
INTERFACE=$"192.168.0.130"   # Set home ip
VNCDIR="${HOMEDIR}/.vnc"   # Default VNC User directory
LOGFILE="${VNCDIR}/logfile"   # Set log file for debugging
PASSWDFILE="${VNCDIR}/passwd"   # The vnc passwd file. If it doesn't exist, you need to create it
GEOMETRY="1280x720"   # What's the Geometry  -Geometry 1280x720 1920x1080
DISPLAY=":0"  # Leave this on ":0", since we want to log in to the actual session
VNCPORT="5900"    #Set the port (default 5900)
# PID of the actual VNC server running
# The PID is actually created this way, so it is compatible with the vncserver command
# if you want to kill the VNC server manually, just type 
# x0vncserver -kill :0
PIDFILE="${VNCDIR}/${HOSTNAME}${DISPLAY}.pid"
#-SecurityTypes VncAuth,TLSVnc
# Add some color to the script
OK="[\033[1;32mok\033[0m]"
FAILED="[\033[1;31mfailed\033[0m]"
RUNNING="[\033[1;32mrunning\033[0m]"
NOTRUNNING="[\033[1;31mnot running\033[0m]"
#end VNC varibile
####  menumenu colors
COLOR_BLACK=0
COLOR_RED=1
COLOR_GREEN=2
COLOR_YELLOW=3
COLOR_BLUE=4
COLOR_MAGENTA=5
COLOR_CYAN=6
COLOR_WHITE=7
COLOR_OFF=9
FG_BLACK=$(echo -e "\033[3${COLOR_BLACK}m")
FG_RED=$(echo -e "\033[3${COLOR_RED}m")
FG_GREEN=$(echo -e "\033[3${COLOR_GREEN}m")
FG_YELLOW=$(echo -e "\033[3${COLOR_YELLOW}m")
FG_BLUE=$(echo -e "\033[3${COLOR_BLUE}m")
FG_MAGENTA=$(echo -e "\033[3${COLOR_MAGENTA}m")
FG_CYAN=$(echo -e "\033[3${COLOR_CYAN}m")
FG_WHITE=$(echo -e "\033[3${COLOR_WHITE}m")
FG_OFF=$(echo -e "\033[3${COLOR_OFF}m")
BG_BLACK=$(echo -e "\033[4${COLOR_BLACK}m")
BG_RED=$(echo -e "\033[4${COLOR_RED}m")
BG_GREEN=$(echo -e "\033[4${COLOR_GREEN}m")
BG_YELLOW=$(echo -e "\033[4${COLOR_YELLOW}m")
BG_BLUE=$(echo -e "\033[4${COLOR_BLUE}m")
BG_MAGENTA=$(echo -e "\033[4${COLOR_MAGENTA}m")
BG_CYAN=$(echo -e "\033[4${COLOR_CYAN}m")
BG_WHITE=$(echo -e "\033[4${COLOR_WHITE}m")
BG_OFF=$(echo -e "\033[4${COLOR_OFF}m")
FG_INFO=$(echo -e "${FG_CYAN}")
FG_DANGER=$(echo -e "${FG_RED}")
FG_WARNING=$(echo -e "${FG_YELLOW}")
FG_SUCCESS=$(echo -e "${FG_GREEN}")
BG_INFO=$(echo -e "${BG_CYAN}")
BG_DANGER=$(echo -e "${BG_RED}")
BG_WARNING=$(echo -e "${BG_YELLOW}")
BG_SUCCESS=$(echo -e "${BG_GREEN}")

# Disable word wrapping
echo -e "\033[?7l"

# Hide cursor
echo -e "\033[?25l"

# Define menu colors
MENU_FG_COLOR=${FG_WHITE}
MENU_BG_COLOR=${BG_CYAN}
MENU_HIGHLIGHT_FG_COLOR=${FG_CYAN}
MENU_HIGHLIGHT_BG_COLOR=${BG_BLACK}

# Define menu title colors
MENU_TITLE_FG_COLOR=${FG_BLACK}
MENU_TITLE_BG_COLOR=${BG_GREEN}

# Define menu width
MENU_WIDTH=50

# Define menu title padding
MENU_TITLE_PADDING=4

## end menu menu colors

# Function to get the process id of the VNC Server
fn_pid() {
    CHECKPID=$(ps -fu ${USER} | grep "[x]0vncserver" | awk '{print $2}')
    if [[ ${CHECKPID} =~ ^[0-9]+$ ]] 
    then
        VAR=${CHECKPID}
        return 0
    else
        return 1
    fi
}
#########################################################################
# Menu title
radiclemenu () {
echo "radicle menu"
MENU_TITLE="Use arrow keys to navigate, press Enter to select."
MENU_TITLE_LENGTH=${#MENU_TITLE}
if [[ $MENU_TITLE_LENGTH -gt $MENU_WIDTH ]]; then
    MENU_WIDTH=$MENU_TITLE_LENGTH
fi
MENU_TITLE_LENGTH=$((MENU_TITLE_LENGTH + MENU_TITLE_PADDING * 2))
if [[ $MENU_TITLE_LENGTH -gt $MENU_WIDTH ]]; then
    MENU_WIDTH=$MENU_TITLE_LENGTH
fi

# Menu options
options=("radicale status" "restart radicile" "start radicile" "mainmenu" "Option 5" "Option 6" "Option 7" "Option 8" "Option 9"  "Option 0" "Exit")
selected=0  # Index of the selected menu item

# Function to display the menu
display_menu() {
    clear
    local term_width=$(tput cols)
    local start_col=$(( (term_width - MENU_WIDTH) / 2 ))
    local padding=$((MENU_WIDTH - MENU_TITLE_LENGTH))
    local filler=$(printf '%*s' "$padding" '')
    local title_filler=$(printf '%*s' "$MENU_TITLE_PADDING" '')
    printf "\n\n"  # Add two empty rows above the menu title
    printf "%${start_col}s" ""
    echo -e "${MENU_TITLE_BG_COLOR}${MENU_TITLE_FG_COLOR}${title_filler}${MENU_TITLE}${title_filler}${FG_OFF}${BG_OFF}"
    for i in "${!options[@]}"; do
        local padding=$((MENU_WIDTH - ${#options[$i]} - 4))
        local filler=$(printf '%*s' "$padding" '')
        if [[ $i -eq $selected ]]; then
            printf "%${start_col}s" ""  # Align to center
            echo -e "${MENU_HIGHLIGHT_BG_COLOR}${MENU_HIGHLIGHT_FG_COLOR} > ${options[$i]} $filler ${FG_OFF}${BG_OFF}"
        else
            printf "%${start_col}s" ""  # Align to center
            echo -e "${MENU_BG_COLOR}${MENU_FG_COLOR}   ${options[$i]} $filler ${FG_OFF}${BG_OFF}"
        fi
    done
}

# Capture keypresses
while true; do
    display_menu
    read -rsn1 key  # Read a single key
    if [[ $key == $'\x1b' ]]; then
        read -rsn2 key  # Read the next two characters
        if [[ $key == "[A" ]]; then  # Up arrow
            ((selected--))
            if [[ $selected -lt 0 ]]; then
                selected=$((${#options[@]} - 1))
            fi
        elif [[ $key == "[B" ]]; then  # Down arrow
            ((selected++))
            if [[ $selected -ge ${#options[@]} ]]; then
                selected=0
            fi
        fi
    elif [[ $key == "" ]]; then  # Enter key
        case ${options[$selected]} in
            "radicale status")
                echo "radicale status"
                sudo systemctl status radicale
                ;;
            "restart radicile")
                echo "restart radicile"
                sudo systemctl restart radicale
                ;;
            "start radicile")
                echo "start radicile"
                sudo systemctl start radicale
                ;;
            #
             "mainmenu")
              echo "mainmenu"
              mainmenu1
              ;; 
            "Option 5")
                echo "You selected Option 5!"
                ;;
            "Option 6")
                echo "You selected Option 6!"
                ;;
            "Option 7")
                echo "You selected Option 7!"
                ;;
            "Option 8")
                echo "You selected Option 8!"
                ;;
            "Option 9")
                echo "You selected Option 9!"
                ;;
            "Option 0")
                echo "You selected Option 0!"
                ;;
            
            "Exit")
                echo "Exiting..."
                echo -e "\033[?7h"  # Re-enable word wrapping
                echo -e "\033[?25h"  # Show cursor
                exit 0
                ;;
        esac
        read -p "Press any key to continue..." -n1
    fi

done
}
######################################################################

# vncmenu

#############################################################
## Menu Menu Menu loop
# Menu title
vncmenu () {
MENU_TITLE="Use arrow keys to navigate, press Enter to select."
MENU_TITLE_LENGTH=${#MENU_TITLE}
if [[ $MENU_TITLE_LENGTH -gt $MENU_WIDTH ]]; then
    MENU_WIDTH=$MENU_TITLE_LENGTH
fi
MENU_TITLE_LENGTH=$((MENU_TITLE_LENGTH + MENU_TITLE_PADDING * 2))
if [[ $MENU_TITLE_LENGTH -gt $MENU_WIDTH ]]; then
    MENU_WIDTH=$MENU_TITLE_LENGTH
fi

# Menu options
options=("Start vnc" "restart vnc" "stopvnc" "statusvnc" "mainmenu" "Option 6" "Option 7" "Option 8" "Option 9"  "Option 0" "Exit")
selected=0  # Index of the selected menu item

# Function to display the menu
display_menu() {
    clear
    local term_width=$(tput cols)
    local start_col=$(( (term_width - MENU_WIDTH) / 2 ))
    local padding=$((MENU_WIDTH - MENU_TITLE_LENGTH))
    local filler=$(printf '%*s' "$padding" '')
    local title_filler=$(printf '%*s' "$MENU_TITLE_PADDING" '')
    printf "\n\n"  # Add two empty rows above the menu title
    printf "%${start_col}s" ""
    echo -e "${MENU_TITLE_BG_COLOR}${MENU_TITLE_FG_COLOR}${title_filler}${MENU_TITLE}${title_filler}${FG_OFF}${BG_OFF}"
    for i in "${!options[@]}"; do
        local padding=$((MENU_WIDTH - ${#options[$i]} - 4))
        local filler=$(printf '%*s' "$padding" '')
        if [[ $i -eq $selected ]]; then
            printf "%${start_col}s" ""  # Align to center
            echo -e "${MENU_HIGHLIGHT_BG_COLOR}${MENU_HIGHLIGHT_FG_COLOR} > ${options[$i]} $filler ${FG_OFF}${BG_OFF}"
        else
            printf "%${start_col}s" ""  # Align to center
            echo -e "${MENU_BG_COLOR}${MENU_FG_COLOR}   ${options[$i]} $filler ${FG_OFF}${BG_OFF}"
        fi
    done
}

# Capture keypresses
while true; do
    display_menu
    read -rsn1 key  # Read a single key
    if [[ $key == $'\x1b' ]]; then
        read -rsn2 key  # Read the next two characters
        if [[ $key == "[A" ]]; then  # Up arrow
            ((selected--))
            if [[ $selected -lt 0 ]]; then
                selected=$((${#options[@]} - 1))
            fi
        elif [[ $key == "[B" ]]; then  # Down arrow
            ((selected++))
            if [[ $selected -ge ${#options[@]} ]]; then
                selected=0
            fi
        fi
    elif [[ $key == "" ]]; then  # Enter key
        case ${options[$selected]} in
             #
          "Start vnc")
              echo "startvnc"
                            echo -n "Starting VNC Server on display ${DISPLAY} "
              echo "${VNCSERVER} -SecurityTypes VncAuth,TLSVnc -Geometry ${GEOMETRY} -localhost=0 -interface ${INTERFACE} -display ${DISPLAY} -passwordfile ${PASSWDFILE} -rfbport ${VNCPORT}"
              sleep 3
        fn_pid
        if [ $? -eq 0 ]
        then
            echo -e ${FAILED}
            echo -e "VNC Server is running (pid: ${VAR})"
	    echo
        else
            ${VNCSERVER} -SecurityTypes VncAuth,TLSVnc -Geometry ${GEOMETRY} -localhost=0 -interface ${INTERFACE} -display ${DISPLAY} -passwordfile ${PASSWDFILE} -rfbport ${VNCPORT} >> ${LOGFILE} 2>&1 &
	    if [ $? -eq 0 ]
	    then
            	fn_pid
            	echo ${VAR} > ${PIDFILE}
            	VNC1="vnc running"
            	
            	echo -e ${OK}
	    	echo
	else
		echo -e $FAILED
		VNC2="vnc failed start"
		echo
		fi

        fi

              ;;
#              
          "restart vnc")
              echo "restart vnc"
              echo -n "Restarting VNC Server on display ${DISPLAY} "
              echo "${VNCSERVER} -SecurityTypes VncAuth,TLSVnc -Geometry ${GEOMETRY} -localhost=0 -interface ${INTERFACE} -display ${DISPLAY} -passwordfile ${PASSWDFILE} -rfbport ${VNCPORT}"
              sleep 3
        fn_pid
        if [ $? -eq 0 ]
        then
            kill -9 ${VAR}

            if [ $? -eq 0 ]
            then 
                ${VNCSERVER} --SecurityTypes VncAuth,TLSVnc Geometry ${GEOMETRY} -localhost=0 -interface ${INTERFACE} -display ${DISPLAY} -passwordfile ${PASSWDFILE} -rfbport ${VNCPORT} >> ${LOGFILE} 2>&1 &
                echo -e ${OK}
		echo
                fn_pid 
                echo ${VAR} > ${PIDFILE}
                VNC1="vnc restarted"
               # exit 0
            else
                echo -e ${FAILED}
                echo "Couldn't stop VNC Server. Exiting."
                
		echo
		VNC1="vnc failed"
		VNC2="vnc fail start"
               # exit 1
            fi

        else

            ${VNCSERVER} -SecurityTypes VncAuth,TLSVnc -Geometry ${GEOMETRY} -localhost=0 -interface ${INTERFACE} -display ${DISPLAY} -passwordfile ${PASSWDFILE} -rfbport ${VNCPORT} >> ${LOGFILE} 2>&1 &
            if [ $? -eq 0 ]
            then
                echo -e ${OK}
		echo
                fn_pid
                echo ${VAR} > ${PIDFILE}
            else
                echo -e ${FAILED}
                echo "Couldn't start VNC Server. Exiting."
                VNC1="vnc failed"
                VNC2="vnc failed start"
		echo
               # exit 1
            fi
        fi
              ;;
#              
              "stopvnc")
              echo "stopvnc"
              sleep 3
              echo -n "Stopping VNC Server: "
        fn_pid
        if [ $? -eq 0 ]
        then
        x0vncserver -kill :0
            kill -9 ${VAR}
            echo -ne ${OK}
            echo -e " (pid: ${VAR})"
            
	    echo
	    VNC1="vnc stopped"
	    VNC2="vnc killed"
        else
            echo -e ${FAILED}
            echo -e "VNC Server is not running."
            
	    echo
	    VNC1="vnc unkown fail stop"
	    VNC2="vnc fdailed"
            #exit 1
        fi
              ;; 
#              
              "statusvnc")
              echo "status vnc"
              sleep 3
              echo -n "Status of the VNC server: "
        fn_pid
        if [ $? -eq 0 ]
        then
            echo -e "$RUNNING (pid: $VAR)"
            VNC1="some vnc running"
            VNC2="vnc running"
	    echo
            #exit 0
        else
            echo -e $NOTRUNNING
            VNC2="vnc not verifyed"
	    echo
        fi
              ;; 
#
             "mainmenu")
              echo "mainmenu"
              mainmenu1
              ;; 
            "Option 6")
                echo "You selected Option 6!"
                ;;
            "Option 7")
                echo "You selected Option 7!"
                ;;
            "Option 8")
                echo "You selected Option 8!"
                ;;
            "Option 9")
                echo "You selected Option 9!"
                ;;
            "Option 0")
                echo "You selected Option 0!"
                ;;
            
            "Exit")
                echo "Exiting..."
                echo -e "\033[?7h"  # Re-enable word wrapping
                echo -e "\033[?25h"  # Show cursor
                exit 0
                ;;
        esac
        read -p "Press any key to continue..." -n1
    fi

done
}
####################################
 
# submenu firewall
# Menu title
firewallmenu () {
echo "firewall menu"
echo "$FW"
echo "$FW"
MENU_TITLE="Use arrow keys to navigate, press Enter to select."
MENU_TITLE_LENGTH=${#MENU_TITLE}
if [[ $MENU_TITLE_LENGTH -gt $MENU_WIDTH ]]; then
    MENU_WIDTH=$MENU_TITLE_LENGTH
fi
MENU_TITLE_LENGTH=$((MENU_TITLE_LENGTH + MENU_TITLE_PADDING * 2))
if [[ $MENU_TITLE_LENGTH -gt $MENU_WIDTH ]]; then
    MENU_WIDTH=$MENU_TITLE_LENGTH
fi

# Menu options
options=("firewall up" "firewalldown" "firewall reset" "firewall disable" "firewall status" "mainmenu" "Option 7" "Option 8" "Option 9"  "Option 0" "Exit")
selected=0  # Index of the selected menu item

# Function to display the menu
display_menu() {
    clear
    local term_width=$(tput cols)
    local start_col=$(( (term_width - MENU_WIDTH) / 2 ))
    local padding=$((MENU_WIDTH - MENU_TITLE_LENGTH))
    local filler=$(printf '%*s' "$padding" '')
    local title_filler=$(printf '%*s' "$MENU_TITLE_PADDING" '')
    printf "\n\n"  # Add two empty rows above the menu title
    printf "%${start_col}s" ""
    echo -e "${MENU_TITLE_BG_COLOR}${MENU_TITLE_FG_COLOR}${title_filler}${MENU_TITLE}${title_filler}${FG_OFF}${BG_OFF}"
    for i in "${!options[@]}"; do
        local padding=$((MENU_WIDTH - ${#options[$i]} - 4))
        local filler=$(printf '%*s' "$padding" '')
        if [[ $i -eq $selected ]]; then
            printf "%${start_col}s" ""  # Align to center
            echo -e "${MENU_HIGHLIGHT_BG_COLOR}${MENU_HIGHLIGHT_FG_COLOR} > ${options[$i]} $filler ${FG_OFF}${BG_OFF}"
        else
            printf "%${start_col}s" ""  # Align to center
            echo -e "${MENU_BG_COLOR}${MENU_FG_COLOR}   ${options[$i]} $filler ${FG_OFF}${BG_OFF}"
        fi
    done
}

# Capture keypresses
while true; do
    display_menu
    read -rsn1 key  # Read a single key
    if [[ $key == $'\x1b' ]]; then
        read -rsn2 key  # Read the next two characters
        if [[ $key == "[A" ]]; then  # Up arrow
            ((selected--))
            if [[ $selected -lt 0 ]]; then
                selected=$((${#options[@]} - 1))
            fi
        elif [[ $key == "[B" ]]; then  # Down arrow
            ((selected++))
            if [[ $selected -ge ${#options[@]} ]]; then
                selected=0
            fi
        fi
    elif [[ $key == "" ]]; then  # Enter key
        case ${options[$selected]} in
        	#1     
          "firewall up")
              echo "firewall up1"
              sleep 3
              sudo ufw --force reset
#sudo ufw allow out on tun0 from any to any  pia is seperate
#
echo "deny all in-out"
sudo ufw default deny incoming
sudo ufw default deny outgoing
#ssh
echo "ssh in"
sudo ufw allow from 192.168.0.0/24 to any port 22
sudo ufw allow from 192.168.2.0/24 to any port 22
sudo ufw allow from 192.168.1.0/24 to any port 22
#vnc
echo "vnc in"
sudo ufw allow from 192.168.0.0/24 to any port 5900
sudo ufw allow from 192.168.2.0/24 to any port 5900
sudo ufw allow from 192.168.0.0/24 to any port 5901
sudo ufw allow from 192.168.2.0/24 to any port 5901
sudo ufw allow from 192.168.1.0/24 to any port 5900
sudo ufw allow from 192.168.1.0/24 to any port 5901

#radicale 
echo "radicale in"
sudo ufw allow from 192.168.0.0/24 to any port 5232 
sudo ufw allow from 192.168.1.0/24 to any port 5232
#radicle
#sudo ufw allow from 192.168.0.0/24 to any port 5232
#sudo ufw allow from 192.168.2.0/24 to any port 5232
#webdav
echo "webdav in"
sudo ufw allow from 192.168.0.0/24 to any port 8585
sudo ufw allow from 192.168.1.0/24 to any port 8585
#qbit
echo "qbit in"
sudo ufw allow from 192.168.0.0/24 to any port 8080
sudo ufw allow from 192.168.1.0/24 to any port 8080
#
echo "dns in"
sudo ufw allow dns
#
#tun0
#only allows out on pia which is tun0
echo "tun0"
sudo ufw allow out on tun0 from any to any

echo "turning it all on"
sudo ufw enable
FW1="firewall on pirate ready"
echo; read -rsn1 -p "Press any key to continue . . ."

                break
              ;;
#2           
          "firewalldown")
              echo "firewalldown"
              FW1="firewall shutdown"
              sleep 3
              ;;
#3         
          "firewall reset")
              echo "firewall reset"
              sleep 3
              sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
FW1="firewall reset to default not great"
FW2="firewall not verifyed"
echo " firewall reset"
echo; read -rsn1 -p "Press any key to continue . . ."
               # break
              ;;

# 4            
          "firewall disable")
              echo "firewall disable"
              sleep 3
              sudo ufw disable
                echo; read -rsn1 -p "Press any key to continue . . ."
                FW1="firewall disabled"
                FW2="firewall not verifyed"
               # break
              ;;
# 5   
          "firewall status")
              echo "firewall status"
              sleep 3
              sudo ufw status
                echo; read -rsn1 -p "Press any key to continue . . ."
                FW2="firewall status checked"
               # break
              ;;                      
            #
             "mainmenu")
              echo "mainmenu"
              mainmenu1
              ;; 
            "Option 7")
                echo "You selected Option 7!"
                ;;
            "Option 8")
                echo "You selected Option 8!"
                ;;
            "Option 9")
                echo "You selected Option 9!"
                ;;
            "Option 0")
                echo "You selected Option 0!"
                ;;
            
            "Exit")
                echo "Exiting..."
                echo -e "\033[?7h"  # Re-enable word wrapping
                echo -e "\033[?25h"  # Show cursor
                exit 0
                ;;
        esac
        read -p "Press any key to continue..." -n1
    fi

done
}

# main menu
####################################################
# Menu title
menuloop1 () {
echo "main menu"
MENU_TITLE="Use arrow keys to navigate, press Enter to select."
MENU_TITLE_LENGTH=${#MENU_TITLE}
if [[ $MENU_TITLE_LENGTH -gt $MENU_WIDTH ]]; then
    MENU_WIDTH=$MENU_TITLE_LENGTH
fi
MENU_TITLE_LENGTH=$((MENU_TITLE_LENGTH + MENU_TITLE_PADDING * 2))
if [[ $MENU_TITLE_LENGTH -gt $MENU_WIDTH ]]; then
    MENU_WIDTH=$MENU_TITLE_LENGTH
fi

# Menu options
options=("VNCmenu" "firewall menu" "Radicle Menu" "mainmenu" "Option 2" "Option 3" "Option 4" "Option 5" "Option 6" "Option 7" "Option 8" "Option 9"  "status" "Exit")
selected=0  # Index of the selected menu item

# Function to display the menu
display_menu() {
    clear
    local term_width=$(tput cols)
    local start_col=$(( (term_width - MENU_WIDTH) / 2 ))
    local padding=$((MENU_WIDTH - MENU_TITLE_LENGTH))
    local filler=$(printf '%*s' "$padding" '')
    local title_filler=$(printf '%*s' "$MENU_TITLE_PADDING" '')
    printf "\n\n"  # Add two empty rows above the menu title
    printf "%${start_col}s" ""    
    echo -e "${MENU_TITLE_BG_COLOR}${MENU_TITLE_FG_COLOR}${title_filler}${MENU_TITLE}${title_filler}${FG_OFF}${BG_OFF}"
    for i in "${!options[@]}"; do
        local padding=$((MENU_WIDTH - ${#options[$i]} - 4))
        local filler=$(printf '%*s' "$padding" '')
        if [[ $i -eq $selected ]]; then
            printf "%${start_col}s" ""  # Align to center
            echo -e "${MENU_HIGHLIGHT_BG_COLOR}${MENU_HIGHLIGHT_FG_COLOR} > ${options[$i]} $filler ${FG_OFF}${BG_OFF}"
        else
            printf "%${start_col}s" ""  # Align to center
            echo -e "${MENU_BG_COLOR}${MENU_FG_COLOR}   ${options[$i]} $filler ${FG_OFF}${BG_OFF}"
        fi
    done
}

# Capture keypresses
while true; do
    display_menu
    read -rsn1 key  # Read a single key
    if [[ $key == $'\x1b' ]]; then
        read -rsn2 key  # Read the next two characters
        if [[ $key == "[A" ]]; then  # Up arrow
            ((selected--))
            if [[ $selected -lt 0 ]]; then
                selected=$((${#options[@]} - 1))
            fi
        elif [[ $key == "[B" ]]; then  # Down arrow
            ((selected++))
            if [[ $selected -ge ${#options[@]} ]]; then
                selected=0
            fi
        fi
    elif [[ $key == "" ]]; then  # Enter key
        case ${options[$selected]} in
        	
        	"VNCmenu")
            	vncmenu
           		;;
        	"firewall menu")
            	firewallmenu
            	;;
        	"Radicle Menu")
            	radiclemenu
            	;;
            #
             "mainmenu")
              echo "mainmenu"
              mainmenu1
              ;; 
            "Option 2")
                echo "You selected Option 2!"
                ;;
            "Option 3")
                echo "You selected Option 3!"
                ;;
            "Option 4")
                echo "You selected Option 4!"
                ;;
            "Option 5")
                echo "You selected Option 5!"
                ;;
            "Option 6")
                echo "You selected Option 6!"
                ;;
            "Option 7")
                echo "You selected Option 7!"
                ;;
            "Option 8")
                echo "You selected Option 8!"
                ;;
            "Option 9")
                echo "You selected Option 9!"
                ;;
            "status")
                echo "You selected status"
                echo "$FW1" #displaying var variable on terminal
				echo "$FW2" #displaying var variable on terminal
				echo "$VNC1" #displaying var variable on terminal
				echo "$VNC2" #displaying var variable on terminal
                ;;
            
            "Exit")
                echo "Exiting..."
                echo -e "\033[?7h"  # Re-enable word wrapping
                echo -e "\033[?25h"  # Show cursor
                exit 0
                ;;
        esac
        read -p "Press any key to continue..." -n1
    fi

done
}

menuloop1

#menutest



## Menu Menu Menu loop default
# Menu title
menuloopx () {
MENU_TITLE="Use arrow keys to navigate, press Enter to select."
MENU_TITLE_LENGTH=${#MENU_TITLE}
if [[ $MENU_TITLE_LENGTH -gt $MENU_WIDTH ]]; then
    MENU_WIDTH=$MENU_TITLE_LENGTH
fi
MENU_TITLE_LENGTH=$((MENU_TITLE_LENGTH + MENU_TITLE_PADDING * 2))
if [[ $MENU_TITLE_LENGTH -gt $MENU_WIDTH ]]; then
    MENU_WIDTH=$MENU_TITLE_LENGTH
fi

# Menu options
options=("Option 1" "Option 2" "Option 3" "Option 4" "Option 5" "Option 6" "Option 7" "Option 8" "Option 9"  "Option 0" "Exit")
selected=0  # Index of the selected menu item

# Function to display the menu
display_menu() {
    clear
    local term_width=$(tput cols)
    local start_col=$(( (term_width - MENU_WIDTH) / 2 ))
    local padding=$((MENU_WIDTH - MENU_TITLE_LENGTH))
    local filler=$(printf '%*s' "$padding" '')
    local title_filler=$(printf '%*s' "$MENU_TITLE_PADDING" '')
    printf "\n\n"  # Add two empty rows above the menu title
    printf "%${start_col}s" ""
    echo -e "${MENU_TITLE_BG_COLOR}${MENU_TITLE_FG_COLOR}${title_filler}${MENU_TITLE}${title_filler}${FG_OFF}${BG_OFF}"
    for i in "${!options[@]}"; do
        local padding=$((MENU_WIDTH - ${#options[$i]} - 4))
        local filler=$(printf '%*s' "$padding" '')
        if [[ $i -eq $selected ]]; then
            printf "%${start_col}s" ""  # Align to center
            echo -e "${MENU_HIGHLIGHT_BG_COLOR}${MENU_HIGHLIGHT_FG_COLOR} > ${options[$i]} $filler ${FG_OFF}${BG_OFF}"
        else
            printf "%${start_col}s" ""  # Align to center
            echo -e "${MENU_BG_COLOR}${MENU_FG_COLOR}   ${options[$i]} $filler ${FG_OFF}${BG_OFF}"
        fi
    done
}

# Capture keypresses
while true; do
    display_menu
    read -rsn1 key  # Read a single key
    if [[ $key == $'\x1b' ]]; then
        read -rsn2 key  # Read the next two characters
        if [[ $key == "[A" ]]; then  # Up arrow
            ((selected--))
            if [[ $selected -lt 0 ]]; then
                selected=$((${#options[@]} - 1))
            fi
        elif [[ $key == "[B" ]]; then  # Down arrow
            ((selected++))
            if [[ $selected -ge ${#options[@]} ]]; then
                selected=0
            fi
        fi
    elif [[ $key == "" ]]; then  # Enter key
        case ${options[$selected]} in
            "Option 1")
                echo "You selected Option 1!"
                ;;
            "Option 2")
                echo "You selected Option 2!"
                ;;
            "Option 3")
                echo "You selected Option 3!"
                ;;
            "Option 4")
                echo "You selected Option 4!"
                ;;
            "Option 5")
                echo "You selected Option 5!"
                ;;
            "Option 6")
                echo "You selected Option 6!"
                ;;
            "Option 7")
                echo "You selected Option 7!"
                ;;
            "Option 8")
                echo "You selected Option 8!"
                ;;
            "Option 9")
                echo "You selected Option 9!"
                ;;
            "Option 0")
                echo "You selected Option 0!"
                ;;
            
            "Exit")
                echo "Exiting..."
                echo -e "\033[?7h"  # Re-enable word wrapping
                echo -e "\033[?25h"  # Show cursor
                exit 0
                ;;
        esac
        read -p "Press any key to continue..." -n1
    fi

done
}
exit
