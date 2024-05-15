# Klipper-WLED-Helper

Klipper-WLED-Helper is a helper script designed to assist users in integrating WLED instances with Klipper & Moonraker for 3D printers. The script manages configuration files, creates symlinks, and edits G-code macro files to insert calls to a macro that controls LEDs via WLED based on printer statuses or events.

## Features

- **Configuration Management:** Check and manage Klipper configuration files.
- **Symlink Creation:** Create necessary symlinks for WLED integration.
- **G-code Macro Editing:** Insert calls to the WLED control macro in G-code files.
- **WLED Control:** Automate WLED control based on printer status or events.

---

## Installation

For Creality K1, K1C, (Probably) K2, Ender 3 V3 KE, and Ender 3 V3 Core XZ, as well as anything using the creality nebula pad

```shell
curl -sSL "https://raw.githubusercontent.com/iamlite/WLED-Klipper-Helper/main/start.sh" | sudo sh
```

For any other klipper installs. You can use an environment variable to set a custom path. Make sure to edit the INSTALL_DIR variable to choose where it is installed

```shell
curl -sSL "https://raw.githubusercontent.com/iamlite/WLED-Klipper-Helper/main/start.sh?" | sudo INSTALL_DIR=/YOUR/CUSTOM/PATH/WLED-Klipper-Helper sh
```

This will install the script and set everything up for you.

---

## Quick Start

### Step 1

To start the script, run:

```shell
sh /usr/data/WLED-Klipper-Helper/Scripts/menu.sh
```

or if you installed it in a custom path, run:

```shell
sh /YOUR/INSTALL/PATH/Scripts/menu.sh
```

### Step 2

First run will prompt you to configure the klipper config directory.

Select (1) **Easy Setup Wizard** and follow the instructions.

### Step 3

Shiny lights!

---

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your improvements.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [WLED](https://github.com/Aircoookie/WLED)
- [Moonraker](https://github.com/ArdaKul/moonraker)
- [Klipper](https://github.com/Klipper3d/klipper)
