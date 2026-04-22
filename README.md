# This is a fork of [exynos-usbdl](https://github.com/frederic/exynos-usbdl), that adds support for a new exploit, and a few targets using that exploit!

## Disclaimer
You will be solely responsible for any damage caused to your hardware/software/warranty/data/cat/etc...

## Description
Exynos bootrom supports booting from USB. This method of boot requires an USB host to send a signed bootloader to the bootrom via USB port.

The original version of the tool exploits a [vulnerability](https://fredericb.info/2020/06/exynos-usbdl-unsigned-code-loader-for-exynos-bootrom.html) in the USB download mode to load and run unsigned code in Secure World.

This fork can also exploit a new vulnerability to do just the same thing.

## How it (the new exploit) works:
Certain USB CONTROL requests have no length checks in the Exynos bootrom's EUB/EDL/USB-Boot mode, and also they allow reads on requests that should be write-only, and writes on requests that should be read-only.

Using this to our advantage, we can send USB CONTROL requests (not all work, as some have length checks, and some are not implemented depending on SoC, but GET_CONFIGURATION works on almost every SoC (maybe even all)) with higher than expected length to read/write into IRAM variables that we were never supposed to access. One of these variables happens to be a pointer to the current EP0 XferComplete handler function, which we can overwrite to gain ACE (for example, by pointing it to a not yet finished BL1 upload, that actually contains our payload)

With stock libusb, we can go up to `0x1000` length, but by patching out libusb's length checks, we can extend this further (up to `0xffff` from my limited testing, could possibly be more/less depending on SoC, and host device). As it currently stands, none of the targets supported by this fork need the length patch for libusb yet.

While we found this vulnerability without help from, or even knowledge about Christopher Wade, the [CVE](https://semiconductor.samsung.com/support/quality-support/product-security-updates/cve-2024-56426/) of this vulnerability is credited to their name (after discovering this, Cristopher confirmed via email that what we found is the same vulnerability). It seems like we were a year late, good job :D

This vulnerability should exist on most, if not all Exynos SoCs before, and including the Exynos 2400. (although we did not have the opportunity to try it on an Exynos 2400 yet). It might not have a proper "cool" name yet, like checkm8 for on older Apple SoCs (this vulnerability is comparable to/basically the Exynos equivalent of checkm8), but internally we called it "new exploit", and "GET_CONFIGURATION exploit".

## Caveat:
While the vunlerability itself is unpatchable, newer SoCs have the possibility to completely disable EUB mode using an eFuse, and Samsung did decide to do just this with their [April 2025 updates](https://blog.chimeratool.com/2025/10/21/samsungs-april-2025-exynos-update-permanently-disables-eub-mode/). Not cool, Samsung, not cool... And disabling bootloader unlock, and disabling Odin/Download mode is certainly not cool either... WTF Samsung, even Apple (mostly) allows restoring their devices to the official firmware...

With this, they did close the possibility of using this on their existing devices as long as they are updated (which is bad for us who want more freedom on our devices, but is technically better for security), but they also did a lot of harm to the repair industry by blocking off a way to restore bricked devices with a broken bootloader. Needless to say, I won't be buying a new Samsung device anytime soon.

## Currently supported targets:
| SoC | Old Exploit | New Exploit |
| --- | --- | --- |
| Exynos8890 | ✅ | ❌* |
| Exynos8895 | ✅ | ❌* |
| Exynos7870 | ✅ | ✅ |
| Exynos7885 | ❌ | ✅ |
| Exynos9610(=9611=9609) | ❌ | ✅ |
| Exynos9810 | ❌ | ✅ |
| Exynos9830(=990) | ❌ | ✅ |
| Exynos3830(=850) | ❌ | ✅ |


*: These SoCs should probably be vulnerable to this exploit, but they are not implemented due to the old exploit existing, and the lack of a device to test on.

## Access to USB download mode
Among all the booting methods supported by Exynos, two are configured in fuses and boot select ("OM") pins to be attempted on cold boot.
If the first boot method fails (including failed authentication), then second boot method is attempted.

On retail smartphones, the usual boot configuration is internal storage (UFS chip/eMMC) first, then USB download mode as fallback.
This means **USB download mode is only accessible if first boot method has failed**.

First boot method sabotage can be achieved either through software or hardware modification.
You can often flash other signed binaries in the BOOTLOADER partition using [Heimdall tool](https://gitlab.com/BenjaminDobell/Heimdall). This will brick the device until the BOOTLOADER partition is restored.
On some devices, there are known boot select test points (or similar things, like a blob of solder on A8 2018) on the motherboard which can be used to temporatily boot into USB download mode.
Technically destroying the eMMC/UFS chip also works, but that is *not* recommended.

## Usage
```
./exynos-usbdl <mode> <input_file> [<output_file>]
	mode: mode of operation
		n: normal
		e: exploit (old zero-length bulk transfer exploit)
		e2: new exploit (GET_CONFIGURATION)
	input_file: payload binary to load and execute
	output_file: file to write data returned by payload
```

## Payloads
Payloads are raw binary AArch64 executables. Some are provided in directory **payloads/**.

## Credits:
- [Chimera Tool](https://chimeratool.com): First discovery of the exploit circa 2021-2022. They provide the most advanced Exynos servicing capabilities in the market to a broad amount of devices, and that is thanks to this specific exploit, and many more.
- [Christopher Wade](https://github.com/Iskuri): For discovering the vulnerability a year before us.
- [halal-beef](https://github.com/halal-beef), and [all the people credited](https://github.com/halal-beef/houston-pub?tab=readme-ov-file#credits) in [his tool](https://github.com/halal-beef/houston-pub): For telling me about this being used in the wild, sending me USB packet dumps, and thus pointing me into the right direction in my existing journey of reverse-engineering Exynos bootrom and trying to find just a vulnerability like this. For writing their own tools, testing on their devices, and providing tons of help and useful info.
- Me, [VDavid003](https://github.com/vdavid003): For putting this tool together (well, extending it), and reverse-engineering most of the Exynos bootrom USB stack.
- [Frédéric](https://github.com/frederic/): For the original tool using the old exploit.

## License
Please see [LICENSE](/LICENSE).
