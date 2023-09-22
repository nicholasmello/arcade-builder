# Arcade Builder
This is a builder script and supporting files for creating a custom arcade
machine image using buildroot to load on raspberry pis.

## Usage
`./builder setup BOARDNAME`

Valid board names include rpi4-arcade-min, rpi4-arcade, and rpi4-arcade-dev.
After running setup, a builds directory will be created above the project
directory to store buildroot and builds. To compile the project run make in the
project directory located at `../builds/BOARDNAME`

To setup and run make together run
`./builder build BOARDNAME`

## Project Structure
### package
This folder contains additional packages not found in buildroot that are to be
added to the project.
### partials
These contain partial buildroot config files which will be combined to create a
build
### configs
Config files in this directory correspond to each board and list the partial
config files that will be combined to create that build.
### skeleton
Contains a local skeleton that will be added on top of the buildroot default
one. Overwrites all files that are duplicated in both places.

## Load procedure
After running make on a build, there will be an image file to load an sd card
at `./output/images/sdcard.img`. This can be loaded onto an sd card with your
favorite imager such as the
[Rasberry Pi Imager](https://www.raspberrypi.com/software/)
