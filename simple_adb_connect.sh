#!/bin/bash

# Blue Team ADB Shell Script for Crostini
# User: m1t1g4tor | Network: 192.168.1.0/24 | Logs: ~/nmap-scans

LOG_DIR="/home/m1t1g4tor/nmap-scans"
LOG_FILE="$LOG_DIR/adb-log-$(date +%Y-%m-%d-%H%M).txt"
mkdir -p "$LOG_DIR" && chmod 700 "$LOG_DIR"

# Function to log actions
log_action() {
    echo "[$(date)] $1" >> "$LOG_FILE"
    chmod 600 "$LOG_FILE"
}

# Check if ADB is installed
if ! command -v adb >/dev/null 2>&1; then
    echo "ADB not found. Install it?"
    echo "1. Yes, install ADB"
    echo "2. Exit"
    read -p "Choose [1-2]: " choice
    case $choice in
        1)
            sudo apt update && sudo apt install android-tools-adb -y
            if [ $? -ne 0 ]; then
                echo "ADB installation failed. Check repository or permissions."
                exit 1
            fi
            log_action "Installed ADB"
            ;;
        2) exit 0 ;;
        *) echo "Invalid choice"; exit 1 ;;
    esac
fi

# Main menu
while true; do
    echo ""
    echo "=== Blue Team Android Shell Menu ==="
    echo "0. Help"
    echo "1. Pair a new Android device (USB or Wireless)"
    echo "2. Connect to a paired Android and get shell"
    echo "3. List connected devices"
    echo "4. Disconnect all devices"
    echo "5. Exit"
    read -p "Choose [0-5]: " choice

    case $choice in
        0) # Help
            echo "Help: Ensure USB/wireless debugging is enabled on Android. For wireless, device and Crostini must be on the same network (e.g., 192.168.1.0/24). Check IP in Settings > About phone > Status."
            ;;
        1) # Pair a new device
            echo "Pairing a new Android device"
            echo "1. Use USB cable (easier)"
            echo "2. Use Wireless (Android 11+, needs pairing code)"
            read -p "Choose [1-2]: " pair_choice
            if [ "$pair_choice" = "1" ]; then
                echo "Connect Android via USB. Enable Developer options > USB debugging."
                read -p "Press Enter when ready..."
                if ! adb devices | grep -q device; then
                    echo "No USB device detected. Check connection and debugging settings."
                    continue
                fi
                read -p "Enter Android IP (e.g., 192.168.1.100): " ip
                if [[ ! "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                    echo "Invalid IP format."
                    continue
                fi
                adb tcpip 5555
                adb connect "$ip:5555"
                if [ $? -ne 0 ]; then
                    echo "Failed to connect to $ip:5555."
                    continue
                fi
                log_action "Paired device via USB: $ip"
                echo "Device paired. Disconnect USB. Use option 2 to shell in."
            elif [ "$pair_choice" = "2" ]; then
                echo "On Android: Developer options > Wireless debugging > Pair device with pairing code"
                read -p "Enter Android IP (e.g., 192.168.1.100): " ip
                if [[ ! "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                    echo "Invalid IP format."
                    continue
                fi
                read -p "Enter pairing port (e.g., 12345): " port
                read -p "Enter pairing code (6 digits): " code
                adb pair "$ip:$port" "$code"
                if [ $? -ne 0 ]; then
                    echo "Pairing failed. Check IP, port, or code."
                    continue
                fi
                adb connect "$ip:5555"
                log_action "Paired device via Wireless: $ip"
                echo "Device paired. Use option 2 to shell in."
            else
                echo "Invalid choice"
            fi
            echo "Reminder: Disable debugging after use for security."
            ;;
        2) # Connect and shell
            if ! adb devices | grep -q device; then
                echo "No devices found. Pair a device first."
                continue
            fi
            echo "Available devices:"
            adb devices | grep device | awk '{print NR ". " $1}'
            read -p "Enter number or IP:port (e.g., 192.168.1.100:5555): " device_choice
            if [[ "$device_choice" =~ ^[0-9]+$ ]]; then
                device_ip=$(adb devices | grep device | awk -v num="$device_choice" 'NR==num {print $1}')
            else
                device_ip="$device_choice"
            fi
            if [ -z "$device_ip" ]; then
                echo "No valid device selected."
                continue
            fi
            adb connect "$device_ip"
            if [ $? -ne 0 ]; then
                echo "Failed to connect to $device_ip."
                continue
            fi
            adb -s "$device_ip" shell
            log_action "Shelled into device: $device_ip"
            echo "Reminder: Disable debugging after use."
            ;;
        3) # List devices
            echo "Connected devices:"
            adb devices
            log_action "Listed connected devices"
            ;;
        4) # Disconnect all
            adb disconnect
            log_action "Disconnected all devices"
            echo "All devices disconnected"
            ;;
        5) # Exit
            echo "Exiting. Disable USB/Wireless debugging on Androids for security."
            log_action "Script exited"
            exit 0
            ;;
        *) echo "Invalid choice" ;;
    esac
done
