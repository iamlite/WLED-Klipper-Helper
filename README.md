# WLED-Klipper-Helper

Status: Not working - do not use (yet)

A helper script for installing and configuring WLED with Klipper.
This script will automatically add triggers to your macros to control WLED's behavior based on your printers status. 


curl -s -o start.sh https://raw.github.com/iamlite/WLED-Klipper-Helper/main/start.sh

chmod +x start.sh

./start.sh

```
/wled_klipper_helper
│
├── main.sh               # Main menu script
├── setup_wled.sh         # Script to setup WLED in moonraker.cfg
├── setup_presets.sh      # Script to guide users through creating WLED presets
├── add_macros.sh         # Script to handle macro searching and editing
├── view_edit_presets.sh  # Script to view and edit preset numbers
└── config                # Directory for configuration files and logs
    ├── presets.conf      # Stores user-defined preset numbers
    └── wled_config.conf  # Stores configuration details entered by the user
```