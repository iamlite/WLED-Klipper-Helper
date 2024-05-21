<div align="center">
<img align="center" width="75%" alt="logo" src="/assets/logo.png">
</div>

---

<div align="center">

  <img src="https://vbr.nathanchung.dev/badge?page_id=iamlite.wledklipperhelper.visitor-badge&style=for-the-badge&color=blue" alt="visitors" />
  <img src="https://img.shields.io/github/stars/iamlite/WLED-Klipper-Helper?style=for-the-badge&color=yellow" alt="stars"/>
  <img src="https://img.shields.io/github/v/release/iamlite/WLED-Klipper-Helper?style=for-the-badge&color=red" alt="version"/>
  <img src="https://img.shields.io/github/last-commit/iamlite/WLED-Klipper-Helper?style=for-the-badge" alt="last-commit"/>
  <a href="https://discord.gg/uYBuFXUmcU">
    <img src="https://img.shields.io/discord/640575167772491786?style=for-the-badge&logo=discord&label=Discord&color=gold" alt="Discord"/>
  </a>

</div>

---

WLED-Klipper-Helper is a helper script designed to assist users in integrating WLED instances with Klipper & Moonraker for 3D printers. The script manages configuration files, creates symlinks, and edits G-code macro files to insert calls to a macro that controls LEDs via WLED based on printer statuses or events.

#### Features

- **Easy Setup Wizard:** Fully guided setup to integrate WLED with klipper/moonraker.
- **Configuration Management:** Check, create, and manage Klipper configuration files needed for WLED integration.
- **Symlink Creation:** Creates necessary symlinks
- **Automated Search and Injection of Macros:** Automatically search for macros and inject them into your configuration.
- **Moonraker Update Manager:** Update manager built into your UI to keep script up to date.
- **QOL Features:** Lots of small QOL features related to WLED

---

#### Planned Features

- 🔥**Automate progress macro generation -** Some kind of way to automate the generation of the progress macro that will update WLED status based on print progress.
- **Add ability to edit macros**

---

### Installation

For Creality K1, K1C, (Probably) K2, Ender 3 V3 KE, and Ender 3 V3 Core XZ, as well as anything using the creality nebula pad
Please note that you need to have Guilouz helper script installed to run curl properly. You can get it [here](https://github.com/Guilouz/Creality-Helper-Script).

```shell
curl -sSL "https://raw.githubusercontent.com/iamlite/WLED-Klipper-Helper/main/start.sh" | sudo sh
```

For any other klipper installs. You can use an environment variable to set a custom path. Make sure to edit the INSTALL_DIR variable to choose where it is installed

```shell
curl -sSL "https://raw.githubusercontent.com/iamlite/WLED-Klipper-Helper/main/start.sh?" | sudo INSTALL_DIR=/YOUR/CUSTOM/PATH/WLED-Klipper-Helper sh
```

This will install the script and set everything up for you.

If the method above doesn't work, you can clone the repository and run the script manually.

---

### Quick Start

#### Step 1

To start the script, run:

```shell
sh /usr/data/WLED-Klipper-Helper/Scripts/menu.sh
```

If you installed in a different directory, change the path to suit your needs.

#### Step 2

First run will prompt you to configure the klipper config directory.

Select (1) **Easy Setup Wizard** and follow the instructions.

#### Step 3

Shiny lights!

---

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your improvements.
Join our [Discord](https://discord.gg/uYBuFXUmcU)

---

## Acknowledgements

- [WLED](https://github.com/Aircoookie/WLED)
- [Moonraker](https://github.com/ArdaKul/moonraker)
- [Klipper](https://github.com/Klipper3d/klipper)
