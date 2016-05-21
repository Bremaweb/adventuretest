# Central Message
## Overview
* Description: Simple API to display short messages at the center of the screen
* Author: Wuzzy
* License of everything: WTFPL
* Shortname: `central_message`
* Version: 0.2.0 (using Semantic Versioning 2.0.0, see [SemVer](http://semver.org/))

## Longer description
This Minetest mod allows other mods to display a short message at the center of the screen.
Each message is displayed for 5 seconds, then it is removed.
When multiple messages are pushed quickly in succession, the messages will be “stacked”
on the screen.

This mod can be useful to inform about all sorts of events and is an alternative to use the chat log
to display special events.

Some usage examples:
* Messages about game events, like victory, defeat, next round starting, etc.
* Error message directed to a single player
* Informational messages
* Administational messages to warn players about a coming server shutdown

## Settings
This mod can be configured via `minetest.conf`.

Currently, these settings are recognized:

* `central_message_max`: Limit the number of messages displayed at once, by providing a number. Use `inf` here for no limit. Default: 7
* `central_message_color`: Set the message color of all messages. Value must be `ColorString` (see `lua_api.txt`). Default: `0xFFFFFF` (white)


## API
### `cmsg.push_message_player(player, message)`
Display a new message to one player only.

#### Parameters
* `player`: An `ObjectRef` to the player to which to send the message
* `message`: A `string` containing the message to be displayed to the player

#### Return value
Always `nil`.


### `cmsg.push_message_all(message)`
Display a new message to all connected players.

#### Parameters
* `player`: An `ObjectRef` to the player to which to send the message
* `message`: A `string` containing the message to be displayed to all players

#### Return value
Always `nil`.
