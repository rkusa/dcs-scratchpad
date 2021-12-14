# DCS Scratchpad

Resizable and movable DCS World in-game Scratchpad for quick persistent notes - especially useful in VR.

## Installation

Copy the `Scripts` folder into your DCS Saved games folder.

## Usage

- Toggle the scratchpad with `CTRL+Shift+X`
- Use `Esc` to remove the text field focus, but keep the scratchpad open

## Settings

Some settings can be changed in your DCS saved games folder under `Config/ScratchpadConfig.lua` (if the file does not exist, start DCS once after mod installation):

- `hotkey` change the hotkey used to toggle the scratchpad (check `DCS World\dxgui\bind\KeyNames.txt` to find how to reference a key; only the keys can be used, that work without having to press `Shift` - so `(` cannot be used, but `Shift+9` can)
- `fontSize` increase or decrease the font size of the Scratchpads textarea

## Scratchpad Content

The Scratchpads content is persisted into `Scratchpad\0000.txt` (in your saved games folder; if the file does not exist, start DCS once after mod installation/upgrade). You can also change the file in your favorite text editor before starting DCS.

### Multiple Pages

When DCS starts, the Scratchpad looks for all text files inside the `Scratchpad\` directory (in your DCS saved games folder that do not exceed a file size of 1MB). If there is more than one, it will show buttons (←/→) that can be used to switch between all those text files. The file `Scratchpad\0000.txt`, where the content is persisted into by default, can be freely renamed, it is _not_ necessary to use the `000x` naming scheme.

## Insert Coordinates from F10 map

This is only available in single player or for servers that have _Allow Player Export_ enabled. If available, you'll have a checkbox at the bottom for the Scratchpad. The mode to insert coordinates is active while the checkbox is checked. While active, you'll have a white dot in the center of your screen and an additional `+ L/L` button below the text area of the Scratchpad. Open the F10 map and align the white dot with your location of interest and hit the `+ L/L` button. This will add the coordinates of the location below the white cursor to your Scratchpad.

## Kudos

- to [DCS-SimpleRadioStandalone](https://github.com/ciribob/DCS-SimpleRadioStandalone) which acted as a good reference of how to setup a simple window in DCS
