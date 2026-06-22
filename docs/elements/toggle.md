# Toggle

A boolean on/off control rendered as a rounded indicator square plus a label. Clicking the row (`Items["Toggle"]`) or the indicator with `MouseButton1Down` flips the value; right-clicking the row (`MouseButton2Down`) toggles an inline "Add Keybind" popup. A Toggle can also host sub-elements (a Colorpicker and/or a Keybind) on its right-aligned `SubElements` frame, and can optionally auto-register an inline keybind that toggles it (`KeybindUIToggle`) plus a mirror entry in the window's keybinds tab. The Callback fires with the new boolean value every time `Set` runs, including once at construction when `Toggle:Set(Toggle.Default)` is called.

Builder: `Section:Toggle(Params) -> Toggle object`

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| Name | string | `"Toggle"` | Display text of the toggle and the fallback for `Flag`. Read as `Params.Name` or `Params.name` or `"Toggle"`. |
| Flag | string | `Params.Name or Params.name` (i.e. the Name) | Key under which the live value is stored in `Flags[Flag]` and registered in `SetFlags[Flag]`. Read as `Params.Flag` or `Params.flag` or (`Params.Name or Params.name`). Defaults to the Name. |
| Premium | boolean | `false` | If truthy, builds a premium overlay (`BuildPremiumOverlay`) locking the toggle; a premium-locked toggle's keybinds-tab entry is hidden until unlocked. Read as `Params.Premium` or `Params.premium` or `false`. |
| Disabled | boolean | `false` | If truthy, builds a disabled overlay (`BuildDisabledOverlay`) and blocks interaction; `Set` and `SetOpen` short-circuit via `IsLockedOrDisabled` while disabled. Read with four aliases in order: `Params.Disable` or `Params.disable` or `Params.Disabled` or `Params.disabled` or `false`. |
| Default | boolean | `false` | Initial value applied at the very end of construction via `Toggle:Set(Toggle.Default)`, which writes Flags and fires the Callback once. Read as `Params.Default` or `Params.default` or `false`. |
| Callback | function | `function() end` | Invoked via `Library:SafeCall(Toggle.Callback, Bool)` with the new boolean value whenever `Set` runs (and once at construction with the resolved Default). Read as `Params.Callback` or `Params.callback` or `function() end`. |
| KeybindUIToggle | boolean | `false` | If truthy, automatically creates an inline Keybind sub-element (via `Toggle:Keybind`) whose callback toggles this toggle, sets `CanTheyAddAKeybind = false` (disabling the right-click Add-Keybind popup), and registers a mirror entry in the floating keybind tab when the window `HasKeybindsTab` and `RegisterKeybindEntry`. Read with three aliases in order: `Params.KeybindUIToggle`, then `Params.keybindUIToggle`, then `Params.KeybindToggle`, defaulting to `false`; stored as `(KUT and true or false)`. |
| KeybindUIMode | string | `"Toggle"` | Mode passed to the auto-created inline keybind when `KeybindUIToggle` is enabled. Read only as `Params.KeybindUIMode` or `"Toggle"` (no lowercase alias). Typically `"Toggle"`, `"Hold"`, or `"Always"`. |
| KeybindUIDefault | EnumItem (KeyCode) | `Enum.KeyCode.Backspace` | Default key for the auto-created inline keybind when `KeybindUIToggle` is enabled. Read only as `Params.KeybindUIDefault` or `Enum.KeyCode.Backspace` at the call site (no lowercase alias). |

### Returns

Returns `setmetatable(Toggle, Library)` (the Toggle table with the `Library` metatable). At construction it stores `Toggle.Value`, registers `SetFlags[Toggle.Flag] = function(Value) Toggle:Set(Value) end`, writes `Flags[Toggle.Flag]` via the initial Set, and calls `TrackWindowPremiumControl(Toggle)`. The Toggle also exposes fields: `Name`, `Flag`, `Premium`, `Disabled`, `Default`, `Callback`, `KeybindUIToggle`, `KeybindUIMode`, `KeybindUIRecord`, `InlineKeybind`, `Window`, `Page`, `Section`, `Value`, `Items`.

### Methods

- `Toggle:Set(Bool: boolean)` — Sets `Toggle.Value = Bool`, animates the inline indicator and label text, calls `Toggle.KeybindUIRecord:SetActive(Bool)` when a `KeybindUIRecord` exists, writes `Flags[Toggle.Flag] = Bool`, and fires the Callback via `Library:SafeCall(Toggle.Callback, Bool)`. No-op when `IsLockedOrDisabled(Toggle)` is true (premium-locked or disabled).
- `Toggle:SetOpen(Bool: boolean)` — Shows (`true`) or hides (`false`) the inline "Add Keybind" popup near the indicator (reparenting `Items["AddKeybind"]` to `Library.Holder` and positioning under the indicator). No-op when `IsLockedOrDisabled(Toggle)` is true or when `CanTheyAddAKeybind` is false (e.g. after a keybind was added or when `KeybindUIToggle` is on).
- `Toggle:SetVisibility(Bool: boolean)` — Sets `Items["Toggle"].Instance.Visible = Bool`. Not guarded by `IsLockedOrDisabled`.
- `Toggle:SetText(Text: any)` — Sets `Items["Text"].Instance.Text = tostring(Text)`. Not guarded.
- `Toggle:UpdateDisable(State: any)` — Coerces `State` to boolean (`State and true or false`), sets `Toggle.Disabled`, and calls `UpdateDisabledOverlay(Items, "Toggle", IsEnabled, Toggle)`.
- `Toggle:UpdatePrem(State: any)` — Coerces `State` to boolean, sets `Toggle.Premium`, and calls `UpdatePremiumOverlay(Items, "Toggle", IsEnabled, Toggle)`. If a `KeybindUIRecord` with a `Frame` exists, hides/shows that keybinds-tab entry (`Visible = not IsEnabled`) and calls `Toggle.Window:_RefreshKeybindEmpty()` when available.
- `Toggle:Colorpicker(Data: table) -> Colorpicker` — Hosts a Colorpicker sub-element parented into `Items["SubElements"]` via `Library:CreateColorpicker`. Reads `Data.Flag`/`flag` (default `Data.Name`/`name` or `Toggle.Name`), `Data.Default`/`default` (default `Color3.fromRGB(255,255,255)`), `Data.Callback`/`callback` (default `function() end`), `Data.Alpha`/`alpha` (default `0`). Returns the created Colorpicker object (`NewColorpicker`). See [Colorpicker](./colorpicker.md) for the full `Data` argument table and the returned object's methods.
- `Toggle:Keybind(Data: table) -> Keybind` — Hosts a Keybind sub-element parented into `Items["SubElements"]` via `Library:CreateKeybind`. Reads `Data.Name`/`name` (default `Toggle.Name`), `Data.Flag`/`flag` (default `Data.Name`/`name` or `Toggle.Name`), `Data.Default`/`default` (default `Enum.KeyCode.E`), `Data.Callback`/`callback` (default `function() end`), `Data.Mode`/`mode` (default `"Toggle"`). Returns the created Keybind object (`NewKeybind`). See [Pickers](../pickers.md) for the full Keybind `Data` argument table and the returned object's methods.
- `Toggle:SetKey(Key: EnumItem | table | string)` — Forwards to `Toggle.InlineKeybind:Set(Key)` when an `InlineKeybind` exists (created only when `KeybindUIToggle` is enabled). No-op otherwise.
- `Toggle:SetKeyMode(Mode: string)` — When `Mode` is one of `"Toggle"`, `"Hold"`, `"Always"` and an `InlineKeybind` exists, forwards to `Toggle.InlineKeybind:SetMode(Mode)`. No-op for invalid `Mode` or when no `InlineKeybind` exists.

### Callback

`Callback(Value: boolean)` — receives the new boolean value of the toggle. Fired on every `Set` (clicks, `SetKey`-driven keybind, programmatic `Set`) and once at construction with the resolved Default via `Toggle:Set(Toggle.Default)`.

### Gotchas

- Core fields each accept a lowercase alias read in order `Params.Field or Params.field` (`Name`/`name`, `Flag`/`flag`, `Premium`/`premium`, `Default`/`default`, `Callback`/`callback`).
- `Disabled` is the only core field with four aliases, read in order: `Disable`, `disable`, `Disabled`, `disabled`.
- `KeybindUIToggle` uses three aliases in order: `KeybindUIToggle`, `keybindUIToggle`, `KeybindToggle`. `KeybindUIMode` and `KeybindUIDefault` have **no** lowercase aliases (read only as `Params.KeybindUIMode` and `Params.KeybindUIDefault`).
- Only `Set` and `SetOpen` are guarded by `IsLockedOrDisabled(Toggle)`; `SetVisibility`, `SetText`, `UpdateDisable`, `UpdatePrem` are **not** guarded.
- `MouseButton1Down` on the row OR the indicator flips the value via `Toggle:Set(not Toggle.Value)`; `MouseButton2Down` on the row toggles the Add-Keybind popup via `Toggle:SetOpen(not IsKeybindThingOpen)`.
- Clicking the Add-Keybind popup (when `CanTheyAddAKeybind`) creates a keybind flagged `Toggle.Name .. "_Keybind"` (Default `Enum.KeyCode.Backspace`, Mode `"Toggle"`), closes the popup, and sets `CanTheyAddAKeybind = false` to prevent further adds.
- `KeybindUIToggle` path: creates `InlineKeybind = Toggle:Keybind{ Name=Toggle.Name, Flag=(Toggle.Flag or Toggle.Name).."_KeybindUI", Default=Params.KeybindUIDefault or Enum.KeyCode.Backspace, Mode=Toggle.KeybindUIMode or "Toggle", Callback = function(Toggled) if not IsPremiumLocked then Toggle:Set(Toggled and true or false) end }`. Stores `Toggle.InlineKeybind`, sets `CanTheyAddAKeybind=false`, and (if the window `HasKeybindsTab` + `RegisterKeybindEntry`) registers `Toggle.KeybindUIRecord` and wires the tab entry's key button to reopen the inline picker.
- Sub-elements (Colorpicker/Keybind) are parented into `Items["SubElements"]`, a right-aligned horizontal `UIListLayout` frame.
- If `Toggle.Page.Page.Search` is truthy, the toggle is registered as a searchable item (`{ Item = Items["Toggle"], Name = Toggle.Name }`) in `Toggle.Page.Page.SearchItems`.
- The default value is applied at the very end via `Toggle:Set(Toggle.Default)`, so the Callback always runs once at creation (even when Default is `false`).

### Example

```lua
local MyToggle = Section:Toggle({
    Name = "God Mode",
    Flag = "GodMode",
    Default = false,
    Callback = function(Value)
        print("God mode is now", Value)
    end
})

-- host sub-elements on the same row
local Picker = MyToggle:Colorpicker({
    Flag = "GodModeColor",
    Default = Color3.fromRGB(255, 0, 0),
    Alpha = 0,
    Callback = function(Color, Alpha)
        print(Color, Alpha)
    end
})

local Bind = MyToggle:Keybind({
    Name = "God Mode",
    Default = Enum.KeyCode.G,
    Mode = "Toggle",
    Callback = function(Toggled)
        print("keybind toggled:", Toggled)
    end
})

MyToggle:Set(true)
MyToggle:SetText("Invincible")
MyToggle:UpdateDisable(true)

-- auto inline keybind variant
local Aim = Section:Toggle({
    Name = "Aimbot",
    KeybindUIToggle = true,
    KeybindUIDefault = Enum.KeyCode.F,
    KeybindUIMode = "Hold",
    Callback = function(v) print("aimbot", v) end
})
Aim:SetKey(Enum.KeyCode.E)
Aim:SetKeyMode("Toggle")
```

---

**See also:** [Button](./button.md) · [Slider](./slider.md) · [Textbox](./textbox.md) · [Input overview](../components.md) · [Theming](../theming.md) · [Config & Flags](../config-and-flags.md) · [API Reference](../api-reference.md) · [Index](../../README.md)
