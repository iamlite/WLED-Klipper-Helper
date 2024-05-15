# Klipper-WLED-Helper

Klipper-WLED-Helper is a helper script designed to assist users in integrating WLED instances with Klipper firmware for 3D printers. The script manages configuration files, creates symlinks, and edits G-code macro files to insert calls to a macro that controls LEDs via WLED based on printer statuses or events.

## Features

- **Configuration Management:** Check and manage Klipper configuration files.
- **Symlink Creation:** Create necessary symlinks for WLED integration.
- **G-code Macro Editing:** Insert calls to the WLED control macro in G-code files.
- **WLED Control:** Automate WLED control based on printer status or events.

## Installation

### For Creality K1, K1C, (Probably) K2, Ender 3 V3 KE, and Ender 3 V3 Core XZ, as well as anything using the creality nebula pad

```shell
curl -sSL "https://raw.githubusercontent.com/iamlite/WLED-Klipper-Helper/main/start.sh" | sudo sh
```

### For any other klipper installs. You can use an environment variable to set a custom path. Make sure to edit the INSTALL_DIR variable to choose where it is installed

```shell
curl -sSL "https://raw.githubusercontent.com/iamlite/WLED-Klipper-Helper/main/start.sh?" | sudo INSTALL_DIR=/YOUR/CUSTOM/PATH/WLED-Klipper-Helper sh
```

## Usage

- To start the script, run:

```shell
sh /usr/data/WLED-Klipper-Helper/Scripts/menu.sh
```

or if you installed it in a custom path, run:

```shell
sh /YOUR/INSTALL/PATH/Scripts/menu.sh
```

- Follow the on-screen prompts to configure your WLED and Klipper integration.
- Once configured, you can use the script to automate WLED control based on printer status or events.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your improvements.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

Special thanks to the Klipper and WLED communities for their continuous support and contributions.

---

**Maintainer:** Tariel D. (GitHub: [iamlite](https://github.com/iamlite))
