# cdj3k-root
Enable root SSH access on your CDJ-3000.

## Why?
Customers should have full access to modify their gear. Rooting your CDJ is a great way to debug errors, explore building custom software, or [play DOOM during your next set](https://x.com/_ichi_nichi_/status/1840214687696437594).

## Quick guide
> [!CAUTION]
> This tool is experimental software with the potential to brick your CDJ. **USE AT YOUR OWN RISK**.

1. [Download](https://github.com/connorworley/cdj3k-root/releases) an update file or [build one yourself](#building-from-source) and place it on a FAT32 USB drive.
2. Copy the set of SSH public keys that you want to have root access to a file named `authorized_keys` at the root of the same USB drive. Only ECDSA keys appear to be compatible with all CDJ hardware revisions.
3. Plug the drive into your CDJ and run the firmware update process. After the update completes, manually power cycle the CDJ. Depending on the hardware revision of your CDJ, it will automatically reboot itself or ask you to manually power cycle it two more times before booting normally. Each step of the process produces log files, so keep your USB drive connected the entire time in case something goes wrong.
4. Your CDJ is rooted!

## Unrooting
SSH into your CDJ and run `~/.unroot.sh`. Depending on the hardware revision of your CDJ, it will automatically reboot itself or ask you to manually power cycle it.

## Building from source
To build from source, you will need to acquire a valid firmware encryption key. Instructions to do this are not provided here. Once you have the key, save it to `aes256.key` in the repo root and run `make` to build a new update file.

## License
cdj3k-root uses the MIT License. The project contains no Pioneer DJ/AlphaTheta code.

## Contact
[DM me](https://x.com/_ichi_nichi_). If this project gains enough traction I may set up a Discord server.