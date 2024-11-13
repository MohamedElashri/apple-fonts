# Font Installer Script

This shell script downloads and installs a set of popular Apple fonts (SF Pro, SF Compact, SF Mono, SF Arabic, and NY) on Unix-based systems. It handles dependency checking, downloads the required `.dmg` files, extracts the fonts, and places them in your system fonts directory for easy access.

## Requirements

Ensure you have the following packages installed:
- `p7zip-full`
- `curl`

On Ubuntu/Debian systems, install them with:
```bash
sudo apt-get update && sudo apt-get install -y p7zip-full curl
```

## Usage

### Quick Run Command

You can run this script with a single command:
```bash
curl -sL https://raw.githubusercontent.com/MohamedElashri/apple-fonts/refs/heads/main/install.sh | bash
```

> **Note**: Although you can run the script directly, it’s **highly recommended** to read the code first to understand what it does, especially if you’re using `sudo`. Simply download and open the script in a text editor:

```bash
curl -O https://raw.githubusercontent.com/MohamedElashri/apple-fonts/refs/heads/main/install.sh
cat font_installer.sh
```

## Running the Script

To run the script after reviewing it, use the following command:
```bash
bash install.sh
```

This command will:
1. Check if required packages (`p7zip-full`, `curl`) are installed, and notify you if any are missing.
2. Download and extract Apple font files from Apple’s design resources.
3. Move the fonts into the system fonts directory (`/usr/share/fonts/applefonts`) for use on Unix-based systems.
4. Clean up any temporary files created during the installation.

## Additional Information

The script has been tested on Debian-based distributions. While it should work on other Unix-based systems, it may require slight adjustments for complete compatibility. Contributions are welcome!

### License

This script is provided under the [MIT License](LICENSE).

