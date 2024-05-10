# WLED-Klipper-Helper

Status: Not working - do not use (yet)

A helper script for installing and configuring WLED with Klipper.
This script will automatically add triggers to your macros to control WLED's behavior based on your printers status.

## For Ender 3 V3 KE, Ender 3V3 and Creality K1, as well as anything using the nebula pad

curl -sSL "<https://raw.githubusercontent.com/iamlite/WLED-Klipper-Helper/main/start.sh?$(date> +%s)" | sudo sh

## For any other klipper installs. Make sure to edit the INSTALL_DIR variable to choose where it is installed

curl -sSL "<https://raw.githubusercontent.com/iamlite/WLED-Klipper-Helper/main/start.sh?$(date> +%s)" | sudo INSTALL_DIR=/YOUR/CUSTOM/PATH/WLED-Klipper-Helper sh

```bash
  ├─ Config/
  │  └─ presets.conf
  ├─ Scripts/
  │  ├─ menu.sh
  │  ├─ macro_search.sh
  │  ├─ assign_presets.sh
  │  ├─ setup_wled.sh
  │  └─ view_edit_presets.sh
  ├─ .gitignore
  ├─ README.md
  └─ start.sh
```
