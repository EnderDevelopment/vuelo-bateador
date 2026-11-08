# Roblox Luau Flight and Auto-Batting Script

Vuelo y Bateador is a Roblox Luau script for adding player flight and automatic baseball batting to your own Roblox experience. It uses a server script and a client script to handle flight controls and hit nearby unanchored parts named `Ball` when the player has a `Bat` tool equipped.

## Install

1. Add `FlightBatServer.server.lua` to `ServerScriptService`.
2. Add `FlightBatClient.client.lua` to `StarterPlayer > StarterPlayerScripts`.
3. Create a `Tool` named `Bat` and place it in `StarterPack` or give it to players another way.
4. Name each baseball part `Ball`. Each ball must be an unanchored `BasePart` in `Workspace`.

The server script creates the `FlightBatRemote` RemoteEvent in `ReplicatedStorage` when the server starts.

## Use

1. Start a play test.
2. Press **F** to toggle flight. Use **W/A/S/D** to move relative to the camera, **Space** to rise, and **Left Ctrl** to descend.
3. Press **G** to toggle automatic batting. With the `Bat` tool equipped, the nearest unanchored `Ball` within 12 studs is hit automatically.
4. To tune the experience, edit `MAX_FLIGHT_SPEED`, `BAT_RANGE`, and `BAT_COOLDOWN` near the top of the server script.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/1458c8d8-84a4-4caa-858b-0467eef9aca0?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=1458c8d8-84a4-4caa-858b-0467eef9aca0
