# Config & Flags

The Flag/config system is the persistence layer of the library. Every interactive component that is given a `Flag` string registers its current value (and a setter) into a pair of global tables, and the config methods (`Library:GetConfig`, `Library:LoadConfig`, `Library:GetConfigsList`, `Library:CheckForAutoLoad`) snapshot, restore, list, and auto-apply those values as JSON files on disk. This page documents how flags are registered, the serialization format used for special component types, the config methods themselves, and the two in-UI sections (`CreateConfigsSection` and `CreateShareConfigsSection`) that expose this functionality to the end user. For the components that actually produce flags, see [Components](components.md); for the in-UI live theme editor (which is intentionally out of scope here) see [Theming](theming.md).

## The Flag field

When you create a component (Toggle, Slider, Dropdown, Textbox, Keybind, [Colorpicker](pickers.md), etc.) you may give it a `Flag` string. Setting it opts that component into persistence: the component writes its live value into `Library.Flags[Flag]` and a setter function into `Library.SetFlags[Flag]`. `Library.Flags` is what `Library:GetConfig` serializes, and `Library.SetFlags` is what `Library:LoadConfig` replays. A component with **no** `Flag` is never persisted.

`Flag = "<string>"` (a field on the component's argument table)

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| Flag | string | none | Read by components (Toggle/Slider/Dropdown/Textbox/Keybind/Colorpicker, etc.). When set, the component writes its value to `Library.Flags[Flag]` and a setter to `Library.SetFlags[Flag]`. These are what `GetConfig` serializes and `LoadConfig` restores. A component with no `Flag` is not persisted. |

- The setter is registered via the upvalue `SetFlags = Library.SetFlags` (captured at line 321), e.g. `SetFlags[Toggle.Flag] = function(Value) Toggle:Set(Value) end`. Replaying a config therefore drives the **real** components and fires their callbacks.

What the Callback receives: the Flag field itself has no callback. Restoring a config calls each registered setter, which internally invokes that component's own `:Set`, which in turn fires that component's `Callback`. In other words, loading a config behaves exactly as if the user had moved every control by hand.

> Value storage by type: keybind flags store a table with a `.Key` field (plus `.Mode`); colorpicker flags store a table with a `.Color`/`.HexValue`/`.Alpha`; everything else (toggle boolean, slider number, dropdown selection, textbox string) is stored raw. See `GetConfig`/`LoadConfig` below for the exact encodings.

```lua
-- Components register flags via the Flag field:
SectionLeft:Toggle({ Name = "Toggle", Flag = "Toggle", Default = false, Callback = function(v) print(v) end })
SectionLeft:Slider({ Name = "Slider", Flag = "Slider", Default = 50, Min = 0, Max = 100, Callback = function(v) print(v) end })

-- A component with no Flag is NOT saved/restored:
SectionLeft:Button({ Name = "Run", Callback = function() print("clicked") end })
```

## Flag storage tables

Two tables on the `Library` table hold all flag state. They are created at construction (line 206-243): `Library.Flags = {}` holds current values keyed by flag string, and `Library.SetFlags` holds setter functions keyed by the same flag string.

`Library.Flags` / `Library.SetFlags` (plain tables, populated by components)

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| Library.Flags | table<string, any> | `{}` | Current value for every flagged component, keyed by Flag string. This is the map `GetConfig` iterates and JSON-encodes. |
| Library.SetFlags | table<string, function> | `{}` (internal) | Setter function for every flagged component, keyed by Flag string. `LoadConfig` looks up `Library.SetFlags[Index]` and calls it to restore a value. |

- Methods that operate on these tables:
  - `Library:GetConfig()` -- snapshot `Library.Flags` to a JSON string (see below).
  - `Library:LoadConfig(Config)` -- replay a JSON string through `Library.SetFlags` (see below).

What the Callback receives: not applicable (these are data tables, not callbacks).

> Config files live in `Library.Directory .. Library.Folders.Configs` (`"AtherHub/Configs"`) as `.json` files. The autoload file is `Library.Directory .. "/autoload.json"` (`"AtherHub/autoload.json"`).

```lua
-- Read a flag's current value directly:
print(Library.Flags["Toggle"])      -- true/false
print(Library.Flags["Slider"])      -- a number

-- Drive a flagged component programmatically via its setter:
Library.SetFlags["Slider"](75)      -- moves the slider AND fires its Callback
```

## Library:GetConfig / Library:LoadConfig

The core save/restore pair. `GetConfig` serializes the current flag map to a JSON string; `LoadConfig` parses such a string and replays it. Both wrap their work in `Library:SafeCall` (defined at line 889), which `pcall`s and `warn`s on failure.

`Library:GetConfig()` / `Library:LoadConfig(Config)`

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| Config (LoadConfig only) | string | required | A JSON string previously produced by `GetConfig`. `LoadConfig` `JSONDecode`s it (outside `SafeCall`) and then replays each decoded entry through the registered setters. `GetConfig` takes no arguments. |

- `Library:GetConfig()` -- inside `Library:SafeCall`, iterates `Library.Flags` and builds a `Config` table: for a table `Value` with a `.Key` field it stores `{ Key = tostring(Value.Key), Mode = Value.Mode }` (keybinds); for a table `Value` with a `.Color` field it stores `{ Color = "#" .. Value.HexValue, Alpha = Value.Alpha }` (colorpickers); otherwise it stores the raw `Value`. Returns `HttpService:JSONEncode(Config)`. On failure it warns `"Failed to get config:\n"..Result` and returns `nil`.
- `Library:LoadConfig(Config)` -- `JSONDecode`s `Config`, then inside `Library:SafeCall`, for each `Index`/`Value` it looks up `Library.SetFlags[Index]`; if absent it `continue`s. For a table `Value` with `.Key` it calls `SetFunction(Value)`; for a table `Value` with `.Color` it calls `SetFunction(Value.Color, Value.Alpha)`; otherwise `SetFunction(Value)`. Returns `(Success, Result)` from the `SafeCall`.

What the Callback receives: not applicable directly. The setters invoked by `LoadConfig` call each component's `:Set`, which fires that component's own `Callback` (a boolean for toggles, a number for sliders, the selection for dropdowns, the string for textboxes, the Keybind object for keybinds, the Color3 for colorpickers, etc.).

> - `GetConfig` returns `nil` on failure (after a `warn`), while `LoadConfig` surfaces the `(Success, Result)` pair from `SafeCall` -- check both differently.
> - Encoding asymmetry: keybinds round-trip as `{ Key, Mode }`; colorpickers are stored as `{ Color = "#"..HexValue, Alpha }` but restored by calling the setter with `(Value.Color, Value.Alpha)` (two positional args). Custom setters must accept that shape.
> - A flag present in the JSON but with no matching `Library.SetFlags[Index]` is silently skipped (the `continue`).

```lua
-- Snapshot to a JSON string and write it:
local json = Library:GetConfig()
writefile("AtherHub/Configs/MyConfig.json", json)

-- Restore it later (drives every component + its callbacks):
local ok, err = Library:LoadConfig(readfile("AtherHub/Configs/MyConfig.json"))
if not ok then warn("load failed:", err) end
```

## Library:GetConfigsList

Enumerates the saved config files on disk and pushes the names into a refreshable element (typically a dropdown). It does not return the list; it hands it to the element's `:Refresh`.

`Library:GetConfigsList(Element)`

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| Element | object | required | An object exposing a `:Refresh(list)` method (e.g. a Dropdown). `GetConfigsList` calls `Element:Refresh(returnList)` with the array of discovered config names. |

- `Library:GetConfigsList(Element)` -- calls `listfiles(Library.Directory .. Library.Folders.Configs)` (`"AtherHub/Configs"`), and for each file ending in `".json"` extracts the base name by scanning backwards from the `".json"` position to the previous `"/"` or `"\\"` and slicing out the name (no extension, no path). Then calls `Element:Refresh(returnList)` with the resulting array of config names. Returns nothing.

What the Callback receives: not applicable; the result is delivered by calling `Element:Refresh(list)` rather than via a callback or return value.

> `Element` must implement `:Refresh(list)` or this call will error. The in-UI [Config section](#createconfigssection) passes its "Configs" dropdown here.

```lua
-- Refresh a dropdown with the list of saved configs:
Library:GetConfigsList(ConfigsDropdown)   -- ConfigsDropdown:Refresh(...) is called internally
```

## Library:CheckForAutoLoad

Applies the saved autoload config on startup. It is intended to be the **final** call after the entire UI is built.

`Library:CheckForAutoLoad()` (defined at line 2029 as `Library.CheckForAutoLoad = function() ... end` -- no `Self` parameter)

### Arguments

This method takes no arguments.

- `Library:CheckForAutoLoad()` -- if `not isfile(Library.Directory .. "/autoload.json")` then it returns. Otherwise it `readfile`s it; if the content is `nil` or `""` it returns. Otherwise it calls `Library:LoadConfig(ConfigContent)` and ignores the return. It is defined **without** a `Self` parameter (`Library.CheckForAutoLoad = function()`), so the colon-passed self is silently dropped -- call it as `Library:CheckForAutoLoad()` or `Library.CheckForAutoLoad()`; both work because self is never referenced.

What the Callback receives: not applicable.

> - Returns nothing. It returns early (silently) when `autoload.json` is missing or empty; otherwise it delegates to `Library:LoadConfig` and ignores that result.
> - It reads `Library.Directory` at call time, so if `Window({ Folder = ... })` changed `Library.Directory`, the new directory's `autoload.json` is used -- call `CheckForAutoLoad` **after** creating the Window.
> - It is defined without a `Self` parameter even though it is invoked with a colon; this works only because the body never references self and reads `Library` directly via the upvalue. The commented example at the bottom of the source (line ~9692) shows `Library:CheckForAutoLoad()` as the last line, confirming the intended order: build the UI, then auto-load.

```lua
-- After building your entire window/pages/components, restore the auto-load config:
Library:CheckForAutoLoad()
```

## CreateConfigsSection

The in-UI config manager. It builds a Section titled "Settings" (`Side = 1`) on the given sub-tab (`Self`, normally the "General" sub-tab returned by `Window:CreateSettingsPage()`) and wires up a configs dropdown, a name textbox, Create/Delete/Load/Save buttons, a UI-toggle keybind, an Auto Save/Load toggle, and -- when the Window has a keybinds tab -- controls for showing and positioning that tab. Configs are read/written as JSON files under `Library.Directory .. Library.Folders.Configs .. "/"`.

`SettingsPage:CreateConfigsSection()` (registered on `Library`, so callable with `:` on the General sub-tab; takes no arguments beyond `Self`)

### Arguments

This method takes no arguments beyond `Self`. It registers the following global flags via the controls it creates:

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| ConfigsDropdown | flag (string) | -- | The "Configs" dropdown (`Items = {}`, `Multi = false`). Its callback receives the selected config name (stored as `ConfigSelected`). |
| ConfigName | flag (string) | -- | The "Config name" textbox (`Placeholder = "Config name"`). Its callback receives the typed name (stored as `ConfigName`). |
| UIToggleKeybind | flag (keybind) | `Enum.KeyCode.X`, `Mode = "Toggle"` | The "UI Keybind" keybind. Its callback receives the Keybind object and sets `Library.MenuKeybind = Flags["UIToggleKeybind"].Key`. |
| Auto Save | flag (boolean) | `true` | The "Auto Save/Load" toggle. Its callback receives a boolean and sets `Library.AutoSave`. |
| ShowKeybindsTab | flag (boolean) | `Library.Windoww.KeybindsTabVisible ~= false` | Added only when `Library.Windoww.HasKeybindsTab` is truthy. Callback receives a boolean and calls `Library.Windoww:SetKeybindsTab`. |
| KeybindsTabPosition | flag (string) | `Library.Windoww.KeybindsTabPosition or "Center Left"` | Added only when `Library.Windoww.HasKeybindsTab` is truthy. Dropdown `Items = {"Top Left","Center Left","Bottom Left","Top Right","Center Right","Bottom Right"}`. Callback receives the chosen position string and calls `Library.Windoww:SetKeybindsTabPosition`. |

- `SettingsPage:CreateConfigsSection()` -- builds all of the above controls (in order: Dropdown "Configs", Textbox "Config name", Buttons "Create"/"Delete"/"Load"/"Save", Label "UI Keybind" with a chained Keybind, Toggle "Auto Save/Load", and the optional keybinds-tab controls), then calls `Library:GetConfigsList(ConfigsDropdown)` to populate the dropdown. Returns nothing (`nil`).

What the Callbacks receive (per control, internally):
- Configs Dropdown -> the selected config name (`Value`, stored as `ConfigSelected`).
- "Config name" Textbox -> the typed name (`Value`, stored as `ConfigName`).
- "UI Keybind" Keybind -> the Keybind object (then sets `Library.MenuKeybind = Flags["UIToggleKeybind"].Key`).
- "Auto Save/Load" Toggle -> a boolean (sets `Library.AutoSave`).
- "Show Keybinds Tab" Toggle -> a boolean (calls `Library.Windoww:SetKeybindsTab`).
- "Keybinds Tab Position" Dropdown -> the chosen position string (calls `Library.Windoww:SetKeybindsTabPosition`).

Button behavior:
- **Create** -- if `ConfigName` is non-nil and non-empty, writes `<ConfigName>.json` into the Configs folder **and** `autoload.json` into `Library.Directory` (`Library.Directory .. "/autoload.json"`), both using `Library:GetConfig()`; an empty/nil name is ignored. Then calls `Library:GetConfigsList(ConfigsDropdown)`.
- **Delete / Load / Save** -- each opens `Library.Windoww:Dialog` (Title "Warning") with Confirm and Cancel buttons, acts on the currently selected config (`ConfigSelected`), and only proceeds if `isfile(<folder>/<ConfigSelected>.json)`. Delete uses `delfile` then refreshes via `Library:GetConfigsList`; Load uses `readfile` + `Library:LoadConfig(ConfigContent)`; Save re-writes the file with `Library:GetConfig()` inside a `pcall`.

> - Must be added to a one-column sub-tab (`Side = 1`). `Window:CreateSettingsPage()` destroys the right column, so `Side = 2` sections will not render.
> - The keybinds-tab controls (`ShowKeybindsTab`, `KeybindsTabPosition`) are added **only** when `Library.Windoww and Library.Windoww.HasKeybindsTab`.
> - `Library:GetConfigsList(ConfigsDropdown)` is called at the very end (and again after Create/Delete) to keep the dropdown in sync with the files on disk.

```lua
local SettingsPage = Window:CreateSettingsPage()
SettingsPage:CreateConfigsSection()
```

## CreateShareConfigsSection

The in-UI share/import manager. It builds a Section titled "Share Configs" (`Side = 1`) on `Self`, letting the user export the current config to the clipboard, paste JSON or a URL, name the import, and import either from the pasted text/URL or directly from the clipboard. Input matching `^https?://` is fetched via `game:HttpGet`; the result is validated as JSON (it must decode to a table), the save name is sanitized into a filename, written into the Configs folder, and applied via `Library:LoadConfig`.

`SettingsPage:CreateShareConfigsSection()` (registered on `Library`; takes no arguments beyond `Self`)

### Arguments

This method takes no arguments beyond `Self`. It registers the following global flags:

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| ShareConfig_PastedText | flag (string) | -- | The "Paste Config / URL" textbox (`Placeholder = "Paste JSON or a URL..."`). Its callback receives the typed/pasted string (`Value or ""`, stored as `ImportedText`). |
| ShareConfig_ImportName | flag (string) | -- | The "Save As" textbox (`Placeholder = "ImportedConfig"`). Its callback receives the name string (`Value or ""`, stored as `ImportName`). |

- `SettingsPage:CreateShareConfigsSection()` -- builds, in order: Button "Export Current (Copy)", Textbox "Paste Config / URL", Textbox "Save As", Button "Import from Pasted Text / URL", Button "Import from Clipboard". Returns nothing (`nil`). All user feedback is via `Library.Windoww:Notify`, each guarded by `if Library.Windoww`.

What the Callbacks receive (per control, internally):
- "Paste Config / URL" Textbox -> the typed/pasted string (`Value or ""`, stored as `ImportedText`).
- "Save As" Textbox -> the name string (`Value or ""`, stored as `ImportName`).
- The three Buttons take no-arg callbacks; import success/failure is surfaced via `Library.Windoww:Notify`.

Button / internal behavior:
- **Export Current (Copy)** -- `pcall`s `Library:GetConfig()`; if it fails/empty it notifies "Export Failed"; otherwise if `setclipboard` exists it copies and notifies "Copied", else it notifies that `setclipboard` is unavailable.
- **Import from Pasted Text / URL** and **Import from Clipboard** -- both feed text into the internal `importText(text, name)`:
  - empty input fails;
  - input matching `^https?://` is fetched with `game:HttpGet` (failure => "Could not fetch URL");
  - the body is `HttpService:JSONDecode`'d and must be a table (else "Invalid config JSON");
  - `finalName` defaults to `"ImportedConfig"` when empty, is sanitized via `gsub("[^%w%-_ ]","")`, and is re-defaulted to `"ImportedConfig"` if it becomes empty;
  - it is written as `<finalName>.json` into the Configs folder (failure => "Could not write file");
  - it is applied via `Library:LoadConfig(source)` and returns `true, finalName` on success.
- **Import from Clipboard** -- resolves the reader via `rawget(getgenv and getgenv() or _G, "getclipboard")` or `getclipboard`; notifies if unavailable; `pcall`s it and requires a non-empty string clipboard before calling `importText(clip, ImportName)`.

> - Must be added to a one-column sub-tab (`Side = 1`).
> - URL imports require an executor with `game:HttpGet`; clipboard import requires a `getclipboard`-style function, and export requires `setclipboard` -- missing functions degrade to a Notify rather than an error.
> - Imported JSON must decode to a table or the import is rejected as "Invalid config JSON".

```lua
local SettingsPage = Window:CreateSettingsPage()
SettingsPage:CreateShareConfigsSection()
```

## End-to-end example

```lua
local Library = loadstring(game:HttpGet("https://your-url/ui.lua"))()

local Window = Library:Window({ Name = "My Hub" })
local Page    = Window:Page({ Name = "Main", Icon = "lucide:house" })
local SubPage = Page:SubPage({ Name = "Main" })
local Section = SubPage:Section({ Name = "General", Side = 1 })

-- Flagged components are what get saved/restored:
Section:Toggle({ Name = "God Mode", Flag = "GodMode", Default = false, Callback = function(v) print(v) end })
Section:Slider({ Name = "Speed", Flag = "Speed", Default = 16, Min = 0, Max = 100, Callback = function(v) print(v) end })

-- Add the in-UI config manager (one-column settings sub-tab):
local SettingsPage = Window:CreateSettingsPage()
SettingsPage:CreateConfigsSection()
SettingsPage:CreateShareConfigsSection()

-- Programmatic save/load:
writefile("AtherHub/Configs/MyConfig.json", Library:GetConfig())
Library:LoadConfig(readfile("AtherHub/Configs/MyConfig.json"))

-- Restore the auto-load config as the final step:
Library:CheckForAutoLoad()
```

## See also

[Components](components.md) | [Colorpicker](pickers.md) | [Theming](theming.md) | [Index](../README.md)
