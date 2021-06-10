# Jetson Nano Overlay for MCP2515 Jetpack 4.5

This repository contains a CAN MCP2515 Overlay for the Nvidia Jetson Nano to replace the existing overlay which at the time of writing this was not working.

The Overlay was adapted from a combination of the Seeed-linux-dtoverlays repository (https://github.com/Seeed-Studio/seeed-linux-dtoverlays) as well as the jetson-mcp251x.dts source found in the Linux_for_Tegra source files. The makefile has been adapted from Seeed-linux-dtoverlays.

## How to Use

Step 1: Clone this repo
'''
git clone https://github.com/mikesanne/JetsonNano.git 
cd JetsonNano
'''

Step 2: Run the makefile
'''
make overlays/jetsonnano/jetson-mcp251x_new.dtbo 
'''

Step 3: Remove the existing mcp251x overlays in /boot/ 
'''
Remove tegra210-p3448-0000-p3449-0000-a01-mcp251x.dtbo and tegra210-p3448-0000-p3449-0000-a02-mcp251x.dtbo from boot
'''
This is required otherwise there will be a name conflict preventing you from running jetson-io

Step 4: Add jetson-mcp251x_new.dtbo to /boot/
'''
cd overlays/jetsonnano/
sudo cp jetson-mcp251x_new.dtbo /boot/
'''

Step 5: Run jetson-io and configure for MCP251x
'''
sudo /opt/nvidia/jetson-io/jetsion-io.py

Configure Jetson for compatible hardware
MCP251x CAN Controller
Save and reboot to reconfigure pins
'''

Step 6: Bring Up CAN interface
'''
sudo ip link set can0 up type can bitrate 500000
sudo ip link set can1 up type can bitrate 500000
'''

Note: This repository is designed to be used with Jetson Nano and MCP251x
	The interrupt pins used are Pin31 and Pin32 for INT 1 and INT 2 respectively.

## Making Changes
All changes to the configuration can be made in the file overlays/jetsonnano/jetson-mcp251x_new.dts

In order to adjust for the oscillator speed please edit the dts file under fragment@0. Change the clock-frequency to the required clock frequency on line 30 of the file.

The INT pins used for can0 and can1 (Pin 31 and Pin 32) can be changed on line 51 for can0 and 82 for can1 respectively.

## Disclaimer
I am not an expert in the field of generating overlays. I merely needed a working CAN communication for the Jetson Nano in order to complete my MSc. Thesis. After looking online I was unable to find a working solution and as such I have created my own file. This has been tested using Joy-it's SBC-CAN01 using a 16 MHz oscillator.
