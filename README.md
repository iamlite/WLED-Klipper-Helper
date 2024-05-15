# Klipper-WLED-Helper

Klipper-WLED-Helper is a helper script designed to assist users in integrating WLED instances with Klipper & Moonraker for 3D printers. The script manages configuration files, creates symlinks, and edits G-code macro files to insert calls to a macro that controls LEDs via WLED based on printer statuses or events.

## Features

- **Easy Setup Wizard:** Fully guided setup to integrate WLED with klipper/moonraker.
- **Configuration Management:** Check, create, and manage Klipper configuration files needed for WLED integration.
- **Symlink Creation:** Creates necessary symlinks
- **Automated Search and Injection of Macros:** Automatically search for macros and inject them into your configuration.
- **QOL Features:** Lots of small QOL features related to WLED
- **Automate progress macro generation:** Automate progress macro generation macro. (Coming soon)

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
