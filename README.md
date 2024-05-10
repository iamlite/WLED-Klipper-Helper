# WLED-Klipper-Helper

Status: Not working - do not use (yet)

A helper script for installing and configuring WLED with Klipper.
This script will automatically add triggers to your macros to control WLED's behavior based on your printers status.

curl -sSL "https://raw.githubusercontent.com/iamlite/WLED-Klipper-Helper/main/start.sh?$(date +%s)" | sudo sh

curl -sSL "https://raw.githubusercontent.com/iamlite/WLED-Klipper-Helper/main/start.sh?$(date +%s)" | INSTALL_DIR=/usr/data2/WLED-Klipper-Helper sudo sh



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
