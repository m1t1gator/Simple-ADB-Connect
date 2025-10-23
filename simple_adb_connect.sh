#!/bin/bash

# Simple ADB Connect Script for Crostini - User-friendly Android shell access
# Network: 192.168.1.0/24

LOG_DIR="$HOME/adb-logs"
LOG_FILE="$LOG_DIR/adb-log-$(date +%Y-%m-%d-%H%M).txt"
mkdir -p "$LOG_DIR" && chmod 700 "$LOG_DIR"

# Function to log actions for auditing
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
            sudo apt update && sudo apt install android-sdk-platform-tools-common android-tools-adb -y
            log_action "Installed ADB"
            ;;
        2) exit 0 ;;
        *) echo "Invalid choice"; exit 1 ;;
    esac
fi

# Main menu
while true; do
    echo ""
    echo "=== Simple ADB Connect Menu ==="
    echo "1. Pair a new Android device (USB or Wireless)"
    echo "2. Connect to a paired Android and get shell"
    echo "3. List connected devices"
    echo "4. Disconnect all devices"
    echo "5. Exit"
    read -p "Choose [1-5]: " choice

    case $choice in
        1) # Pair a new device
            echo "Pairing a new Android device"
            echo "1. Use USB cable (easier)"
            echo "2. Use Wireless (Android 11+, needs pairing code)"
            read -p "Choose [1-2]: " pair_choice
            if [ "$pair_choice" = "1" ]; then
                echo "Connect Android via USB. On Android: Settings > About phone > Tap Build number 7x > Developer options > Enable USB debugging"
                read -p "Press Enter when USB debugging is enabled and device is connected..."
                adb devices
                read -p "Enter Android IP (check Settings > About phone > Status > IP address, e.g., 192.168.1.100): " ip
                adb tcpip 5555
                adb connect "$ip:5555"
                log_action "Paired device via USB: $ip"
                echo "Device paired. Disconnect USB. Try option 2 to shell in."
            elif [ "$pair_choice" = "2" ]; then
                echo "On Android: Developer options > Wireless debugging > Pair device with pairing code"
                read -p "Enter Android IP (e.g., 192.168.1.100): " ip
                read -p "Enter pairing port (from Android, e.g., 12345): " port
                read -p "Enter pairing code (6 digits): " code
                adb pair "$ip:$port" "$code"
                adb connect "$ip:5555"
                log_action "Paired device via Wireless: $ip"
                echo "Device paired. Try option 2 to shell in."
            else
                echo "Invalid choice"
            fi
            ;;
        2) # Connect and shell
            echo "Listing paired devices..."
            adb devices
            echo "Enter the IP:port of the device to shell into (e.g., 192.168.1.100:5555)"
            echo "Available devices:"
            adb devices | grep device | awk '{print NR ". " $1}'
            read -p "Choose number or type IP:port: " device_choice
            if [[ "$device_choice" =~ ^[0-9]+$ ]]; then
                device_ip=$(adb devices | grep device | awk -v num="$device_choice" 'NR==num {print $1}')
            else
                device_ip="$device_choice"
            fi
            if [ -n "$device_ip" ]; then
                adb connect "$device_ip"
                adb -s "$device_ip" shell
                log_action "Shelled into device: $device_ip"
            else
                echo "No valid device selected"
            fi
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
