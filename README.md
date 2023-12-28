# DCS Scratchpad

Resizable and movable DCS World in-game Scratchpad for quick persistent notes - especially useful in VR.

## Installation

Copy the `Scripts` folder into your DCS Saved games folder.

## Usage

- Toggle the scratchpad with `CTRL+Shift+X`
- Use `Esc` to remove the text field focus, but keep the scratchpad open

## Settings

Some settings can be changed in your DCS saved games folder under `Config/ScratchpadConfig.lua` (if the file does not exist, start DCS once after mod installation):

- `hotkey` hotkey to toggle the Scratchpad (`CTRL+Shift+X` by default) ¹
- `hotkeyNextPage` hotkey to switch to the next page (not set by default) ¹
- `hotkeyPrevPage` hotkey to switch to the next page (not set by default) ¹
- `hotkeyInsertCoordinates` hotkey to add coordinates from the F10 map (not set by default) ¹
- `hotkeyReloadPages` hotkey to reload all pages from disk (useful if they were modified by other tools; not set by default) ¹
- `fontSize` increase or decrease the font size of the Scratchpads textarea (`14` by default)

_¹ check `DCS World\dxgui\bind\KeyNames.txt` to find how to reference a key; only the keys can be used, that work without having to press `Shift` - so `(` cannot be used, but `Shift+9` can_

## Scratchpad Content

The Scratchpads content is persisted into `Scratchpad\0000.txt` (in your saved games folder; if the file does not exist, start DCS once after mod installation/upgrade). You can also change the file in your favorite text editor before starting DCS.

### Multiple Pages

When DCS starts, the Scratchpad looks for all text files inside the `Scratchpad\` directory (in your DCS saved games folder that do not exceed a file size of 1MB). If there is more than one, it will show buttons (←/→) that can be used to switch between all those text files. The file `Scratchpad\0000.txt`, where the content is persisted into by default, can be freely renamed, it is _not_ necessary to use the `000x` naming scheme.

## Insert Coordinates from F10 map

This is only available in single player or for servers that have _Allow Player Export_ enabled. If available, you'll have a checkbox at the bottom for the Scratchpad. The mode to insert coordinates is active while the checkbox is checked. While active, you'll have a white dot in the center of your screen and an additional `+ L/L` button below the text area of the Scratchpad. Open the F10 map and align the white dot with your location of interest and hit the `+ L/L` button. This will add the coordinates of the location below the white cursor to your Scratchpad.

## Extensions

Scratchpad supports extensions. Most prominent use-case is to add a virtual keyboard. There are some example extensions in `Saved Games\DCS.openbeta\Scripts\Scratchpad\Extensions\Disabled\`. To
enable any of them, copy the file over to `Saved Games\DCS.openbeta\Scripts\Scratchpad\Extensions\`.

The available APIs to the extensions are:

```lua
-- Log to `Saved Games\DCS.openbeta\Logs\Scratchpad.log`
log(text)

-- Format coordinates with `format` being either `DMS` or `DDM`, `isLat` `true` if the provided `d`
-- is the latitude, and `false` if it is the longitude, and `opts` allow to fine-tune the format
-- (checkout `Scripts/Hooks/scratchpad-hook.lua` `function coordsType()` for examples).
formatCoord(format, isLat, d, opts)

-- Add a `listener` that is executed every time the user adds a coordinate (via the +L/L button).
-- See `Extensions/Disabled/ns430.lua` for an example.
addCoordinateListener(listener(text, lat, lon, alt))

-- Add a button positioned at `left`/`top` (relative to the plugin's container), with the size of
-- `width`/`height`, the given `title` and the `onClick` callback that is executed when the button
-- is pressed.
addButton(left, top, width, height, title, onClick(text))

-- The `text` given to the `addCoordinateListener` and `onClick` callbacks can be mutated with the
-- following methods:
  text:getText()
  text:setText(text)
  text:insertAtCursor(text)
  text:insertBelowCursor(text)
  text:insertTop(text)
  text:insertBottom(text)

-- Provides the start and end offsets of the current selection from page being displayed. No argements
-- passed. Accomodates multibyte characters.
getSelection() - return 4 numbers: start, end, startByte, endByte

-- Provides the value of the currentPage variable or the page being displayed. This is full path and file
-- name of the page shown. Takes no arguments.
getCurrentPage() - returns string

-- Each extension can register a text string to be displayed on the titlebar. It will share the titlebar
-- with other extension notices, if any, and the page name. Currently no guarantee is made about how much
-- of the string is displayed. A page notice is not requied for extension use.
setPageNotice(text) - text: string to display
                      returns nothing
```

## Kudos

- to [DCS-SimpleRadioStandalone](https://github.com/ciribob/DCS-SimpleRadioStandalone) which acted as a good reference of how to setup a simple window in DCS
