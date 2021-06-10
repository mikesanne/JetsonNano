This repository contains a CAN MCP2515 Overlay for the Nvidia Jetson Nano

The Overlay was adapted from a combination of the Seeed-linux-dtoverlays repository as well as the jetson-mcp251x.dts source found in the Linux_for_Tegra source files. The makefile has been adapted from Seeed-linux-dtoverlays.

How to Use

Step 1: Clone this repo
	cd JetsonNano

Step 2: make overlays/jetsonnano/jetson-mcp251x_new.dtbo 

Step 3: Remove tegra210-p3448-0000-p3449-0000-a01-mcp251x.dtbo and tegra210-p3448-0000-p3449-0000-a02-mcp251x.dtbo from boot

Step 4: Add jetson-mcp251x_new.dtbo to /boot/

Step 5: Run sudo /opt/nvidia/jetson-io/jetsion-io.py
	Configure Jetson for compatible hardware
	MCP251x CAN Controller
	Save and reboot to reconfigure pins

Step 6: sudo ip link set can0 up type can bitrate 500000
	sudo ip link set can1 up type can bitrate 500000


Note: This repository is designed to be used with Jetson Nano and MCP251x
	The interrupt pins used are Pin31 and Pin32 for INT 1 and INT 2 respectively.

Making Changes
All changes to the configuration can be made in the file overlays/jetsonnano/jetson-mcp251x_new.dts

In order to adjust for the oscillator speed please edit the dts file under fragment@0. Change the clock-frequency to the required clock frequency on line 30 of the file

In order to change the INT pins change the interrupts on line 51 for can0 and 82 for can0 

Disclaimer
This is the first time I have ever implemented a dts overlay. I am not an expert in the field. I merely needed a working CAN communication for the Jetson Nano in order to complete my MSc. Thesis. After looking online I was unable to find one and as such I have created my own file. This has been tested using Joy-it's SBC-CAN01 using a 16 MHz oscillator.
