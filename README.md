# DCS Scratchpad

Resizable and movable DCS World in-game Scratchpad for quick persistent notes - especially useful in VR.

## Installation

Copy the `Scripts` folder into your DCS Saved games folder.

## Usage

- Toggle the scratchpad with `CTRL+Shift+X`
- Use `Esc` to remove the text field focus, but keep the scratchpad open

## Settings

Some settings can be changed in your DCS saved games folder under `Config/ScratchpadConfig.lua` (if the file does not exist, start DCS once after mod installation):

- `hotkey` change the hotkey used to toggle the scratchpad
- `fontSize` increase or decrease the font size of the Scratchpads textarea

## Scratchpad Content

The Scratchpads content is persisted into `Scratchpad\0000.txt` (in your saved games folder; if the file does not exist, start DCS once after mod installation/upgrade). You can also change the file in your favorite text editor before starting DCS.

### Multiple Pages

When DCS starts, the Scratchpad looks for all text files inside the `Scratchpad\` directory (in your DCS saved games folder that do not exceed a file size of 1MB). If there is more than one, it will show buttons (←/→) that can be used to switch between all those text files. The file `Scratchpad\0000.txt`, where the content is persisted into by default, can be freely renamed, it is _not_ necessary to use the `000x` naming scheme.

## Insert Mark Point Coordinates

This is unfortunately _only_ available for servers (the client hosting a server, or in singleplayer). If you are the server, there will be a `+ L/L` button below the text area of the Scratchpad that can be used to automatically append the coordinates of all currently existing mark points (the mark labels that can be added in the F10 map) to the currently opened page.

## Kudos

- to [DCS-SimpleRadioStandalone](https://github.com/ciribob/DCS-SimpleRadioStandalone) which acted as a good reference of how to setup a simple window in DCS
