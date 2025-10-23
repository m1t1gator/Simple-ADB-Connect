Simple ADB Connect

A user-friendly Bash script for connecting to Android devices via ADB (Android Debug Bridge) in a Crostini environment (Linux container on ChromeOS). It supports both USB and wireless pairing, with a menu-driven interface for pairing, connecting, listing, and disconnecting devices.

Features

Installs ADB if not present (requires sudo and apt access).
Supports USB and wireless (Android 11+) device pairing.
Validates IP addresses and checks ADB command success.
Logs actions to $HOME/adb-logs for auditing.
Provides security reminders to disable debugging after use.

Requirements

Crostini environment on ChromeOS with apt access.
Android device with USB or wireless debugging enabled.
Network connectivity (e.g., 192.168.1.0/24) for wireless pairing.
USB passthrough enabled in Crostini for USB pairing (if needed).

Installation

Clone the repository:git clone https://github.com/m1t1gator/simple-adb-connect.git
cd simple-adb-connect


Make the script executable:chmod +x simple_adb_connect.sh



Usage

Run the script:./simple_adb_connect.sh


Follow the menu prompts:
0. Help: Display setup instructions.
1. Pair a new Android device: Pair via USB or wireless.
2. Connect to a paired Android: Open a shell to a device.
3. List connected devices: Show all connected devices.
4. Disconnect all devices: Disconnect all ADB devices.
5. Exit: Exit the script.



Notes

Ensure your Android device has USB debugging enabled (Settings > About phone > Tap Build number 7x > Developer options > USB debugging).
For wireless pairing, both the device and Crostini must be on the same network.
Logs are stored in $HOME/adb-logs with restricted permissions.
Disable USB/wireless debugging on your Android device after use for security.

License
This project is licensed under the MIT License - see the LICENSE file for details.
Contributing
Contributions are welcome! Please open an issue or pull request on GitHub.
