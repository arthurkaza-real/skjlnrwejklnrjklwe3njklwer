# Keybind

A keybind **picker** attached to an existing [Toggle](./toggle.md) or [Label](./label.md). Clicking the inline key button enters capture mode (button text becomes `press a key`); the next non-mouse keyboard / `UserInputType` press is bound. Pressing `Escape`, or clicking the button a second time while picking, clears the key to `None` (stored as the string for `Backspace`). Right-clicking (`MouseButton2Down`) the key button toggles a small floating window containing a **Mode** dropdown (`Toggle` / `Hold` / `Always`). Once bound, pressing the bound key drives `Keybind.Toggled` per the chosen Mode and invokes the `Callback`. The bound key, mode and toggled state are persisted to `Flags` under the keybind's `Flag` as a sub-table.

**Builder:** `Toggle:Keybind(Data) -> Keybind` or `Label:Keybind(Data) -> Keybind` (both normalize `Data` and forward to the internal `Library:CreateKeybind({Parent, Name, Page, Section, Flag, Default, Mode, Callback}) -> (Keybind, Items)`)

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Parent` | table (Library element/instance wrapper) | required | The container element the key button is created inside. Used as `Data.Parent.Instance` for the `KeyButton`'s parent. Supplied automatically by the `Toggle:Keybind` / `Label:Keybind` wrappers (they pass `Items["SubElements"]`); not something an end user sets directly. Read ONLY by `Library:CreateKeybind`; no lowercase alias. |
| `Flag` | string | `Data.Flag` (no fallback inside `CreateKeybind`). Via wrappers: Toggle → `Data.Name`/`Data.name` or `Toggle.Name`; Label → `Library:NextFlag()` (auto-generated). lowercase `flag` resolved only by the wrapper | Key under which keybind state is stored in `Flags` as `{Mode, Key, Toggled}` and registered in `SetFlags[Flag]`. The Mode dropdown's own flag is derived as `Flag .. "ModeDropdown"`. Inside `CreateKeybind` only `Data.Flag` is read. |
| `Default` | `EnumItem` (`KeyCode`) or `EnumItem` (`UserInputType`) | `nil` inside `CreateKeybind` (no `Default` ⇒ no initial bind). Via wrappers: `Enum.KeyCode.E` (both Toggle and Label) | Initial key to bind on creation. Read by `CreateKeybind` as `Data.Default`; if truthy the keybind is initialized via `Keybind:Set({Mode = Data.Mode or "Toggle", Key = Data.Default})`. Pass `Enum.KeyCode.Backspace` to start unbound (`None`). lowercase `default` resolved only by the wrapper. |
| `Mode` | string | `"Toggle"` (fallback for the initial `Set` when `Default` is present; via wrappers also defaults to `"Toggle"`) | Initial keybind mode. Read by `CreateKeybind` as `Data.Mode` (only when `Default` is present, to seed the initial `Set`). Must be one of `"Toggle"`, `"Hold"`, `"Always"`. The Mode dropdown itself is constructed with `Default = "Toggle"` regardless. lowercase `mode` resolved only by the wrapper. |
| `Callback` | function | `nil` inside `CreateKeybind` (each call site is guarded by `if Data.Callback then`). Via wrappers: `function() end` | Invoked via `Library:SafeCall(Data.Callback, Keybind.Toggled)` whenever the keybind state changes. Read directly as `Data.Callback` inside `CreateKeybind`. lowercase `callback` resolved only by the wrapper. |
| `Name` | string | Via wrappers: `Data.Name`/`Data.name` or the parent's Name (`Toggle.Name` / `Label.Name`) | Display/identifier name. **NOTE:** `Library:CreateKeybind` does NOT read `Data.Name` at all (the `KeyButton` uses `Name = "\0"`); `Name` is only consumed by the wrappers (which accept `Name`/`name`) and passed through for bookkeeping. It has no effect inside the picker constructor. |
| `Page` | table | passed through by wrappers | Bookkeeping field forwarded by the wrappers into `Library:CreateKeybind`'s `Data`. Not otherwise read by the keybind picker logic. No lowercase alias. |
| `Section` | table | passed through by wrappers | Bookkeeping field forwarded by the wrappers into `Library:CreateKeybind`'s `Data`. Not otherwise read by the keybind picker logic. No lowercase alias. |

### Methods

- `Keybind:Set(Key)` — Binds/updates the keybind. Three input forms (checked in order):
  1. Any value whose `tostring` contains `"Enum"` (a `KeyCode` or `UserInputType` EnumItem) → sets `Keybind.Key = tostring(Key)`, computes display text (`Backspace` shown as `None`, stripping `"KeyCode."`/`"UserInputType."`), sets `Keybind.Value` and the button text, persists `Library.Flags[Flag]`, and fires `Callback(Keybind.Toggled)`.
  2. A table `{ Key = <KeyName string e.g. "E" or "Backspace">, Mode = <optional "Toggle"/"Hold"/"Always"> }` → sets `Keybind.Key = tostring(Key.Key)`, applies Mode via `Keybind:SetMode` (defaulting to `"Toggle"` when `Key.Mode` is omitted), updates Value/button text, and fires `Callback`.
  3. A plain string equal to one of `"Toggle"`/`"Hold"`/`"Always"` (matched via `table.find`) → only changes the Mode via `SetMode` and fires `Callback`.
  After any branch it sets `Keybind.Picking = false`. NOTE the table form passes `Key.Key` as a **KeyName STRING** (e.g. `"E"`), not an Enum; the initial auto-bind from `Default` passes the raw `EnumItem` as `Key.Key`.
- `Keybind:SetOpen(Bool)` — Opens (`true`) or closes (`false`) the floating Mode window (`Items["KeybindWindow"]`). Debounced via an internal `Debounce` flag (returns early if a tween is in progress). On open: positions the window beneath the `KeyButton`, reparents it to `Library.Holder`, makes it `Visible`, tweens + `FadeDescendants(true)`, starts a `RenderStepped` connection to keep it pinned under the button, closes every OTHER frame in `Library.OpenFrames`, then registers `Library.OpenFrames[Keybind] = Keybind`. On close: tweens up + `FadeDescendants(false)`, reparents back to `Library.UnusedHolder`, removes itself from `Library.OpenFrames`, and disconnects the `RenderStepped` connection.
- `Keybind:SetMode(Mode)` — Sets the keybind mode by calling the internal Mode dropdown's `:Set(Mode)` (expects `"Toggle"`, `"Hold"`, or `"Always"`; the dropdown's own Callback assigns `Keybind.Mode`). Then persists `Flags[Keybind.Flag] = {Mode, Key, Toggled}` and, if `Data.Callback` exists, fires `Library:SafeCall(Data.Callback, Keybind.Toggled)`.
- `Keybind:Press(Bool)` — Applies a press according to the current `Keybind.Mode`: `"Toggle"` → `Keybind.Toggled = not Keybind.Toggled` (`Bool` ignored); `"Hold"` → `Keybind.Toggled = Bool` (true on press / false on release); `"Always"` → `Keybind.Toggled = true`. Then persists `Flags[Keybind.Flag] = {Mode, Key, Toggled}` and, if `Data.Callback` exists, fires `Library:SafeCall(Data.Callback, Keybind.Toggled)`. Called automatically by the global `InputBegan`/`InputEnded` handlers when the bound key is pressed/released; `Bool` defaults to `nil` when called with no argument.

### Callback

The `Callback` receives a **SINGLE** argument: the current `Keybind.Toggled` boolean. It is invoked via `Library:SafeCall(Data.Callback, Keybind.Toggled)`, and only when `Data.Callback` is non-nil (every call site is guarded). It fires on: `Keybind:Set` (all three forms), `Keybind:SetMode`, and `Keybind:Press` (when the bound key is pressed/released — flipped for `Toggle`, true/false for `Hold`, forced true for `Always`). NOTE the Mode dropdown's own Callback does NOT call `Data.Callback`; it only updates `Keybind.Mode` and writes `Flags`.

### Returns

`Library:CreateKeybind` returns two values: the `Keybind` object and the `Items` table (`return Keybind, Items`). The `Toggle:Keybind` / `Label:Keybind` wrappers return **only** the `Keybind` object (`NewKeybind`). The `Keybind` object initializes with `{ Flag, IsOpen = false, Key = "", Mode = "", Value = "", Toggled = false, Picking = false, Items = {} }`. State is persisted to `Flags[Flag] = { Mode = <string>, Key = <stringified Enum>, Toggled = <boolean> }` (note: `Set` writes via `Library.Flags`, while `SetMode`/`Press`/the dropdown callback write via the `Flags` upvalue), and a loader is registered as `SetFlags[Flag] = function(Value) Keybind:Set(Value) end`.

### Gotchas

> Available **MODES** are exactly: `"Toggle"`, `"Hold"`, `"Always"` — defined as the Mode dropdown items `{ "Toggle", "Hold", "Always" }` and validated in `Set` via `table.find({"Toggle","Hold","Always"}, Key)`.

- Attach ONLY via `Toggle:Keybind(Data)` or `Label:Keybind(Data)`. `Library:CreateKeybind` is the internal constructor those wrappers call; it is not intended to be called directly by end users (it requires `Data.Parent` to be a valid element wrapper).
- Lowercase aliases (`Name`/`name`, `Flag`/`flag`, `Default`/`default`, `Mode`/`mode`, `Callback`/`callback`) are resolved by the wrappers, not by `Library:CreateKeybind`. `CreateKeybind` itself reads only `Data.Parent`, `Data.Flag`, `Data.Default`, `Data.Mode`, `Data.Callback` (exact-case).
- The `KeyButton`'s literal initial Text is `"BackSpace"` (before any `Set`). After binding, the display strips `"KeyCode."`/`"UserInputType."` and shows `Backspace` as `None`.
- Picking flow: clicking the `KeyButton` sets `Picking = true` and text `press a key`, then connects a one-shot `UserInputService.InputBegan`. A 0.2s debounce (`tick() - startTime < 0.2`) ignores the opening tap; `MouseButton1`, `Touch` and `MouseMovement` inputs are filtered out. `Escape` calls `Set({Key = "Backspace", Mode = Keybind.Mode})`; a Keyboard input binds `Input.KeyCode`; otherwise binds `Input.UserInputType`. A second click while `Picking` cancels and clears to `Backspace`.
- Persisted `Flags` entry is a table: `Flags[Flag] = { Mode = <string>, Key = <stringified Enum/key>, Toggled = <boolean> }`. Loading goes through `SetFlags[Flag]` → `Keybind:Set(Value)`.
- The global input handlers ignore the bind when `Keybind.Value == "None"`. The `KeyButton` click handler returns early if `Keybind.Disabled` is truthy — but the keybind picker never assigns `Keybind.Disabled` itself (it is only set on Toggle/Label/etc.), so for a standalone keybind it is effectively always falsy.
- Right-clicking the `KeyButton` (`MouseButton2Down`) calls `Keybind:SetOpen(not Keybind.IsOpen)`. While the Mode window is open, a left-click/Touch outside both the window and the Mode dropdown's `OptionHolder` closes it via `SetOpen(false)`.
- `InputEnded` only does anything for `"Hold"` (`Press(false)`) and `"Always"` (`Press(true)`); it ignores GPE (game-processed) events and the `None` state.
- Defaults when attaching via the wrappers: Default key = `Enum.KeyCode.E` (both Toggle and Label), Mode = `"Toggle"`. Inside `CreateKeybind` there are no such fallbacks — omitting `Default` means no initial bind.

### Example

```lua
-- Attached to a Toggle
local MyToggle = Section:Toggle({
    Name = "Aimbot",
    Flag = "Aimbot",
    Default = false,
    Callback = function(Value) end
})

MyToggle:Keybind({
    Name = "Aimbot Key",
    Flag = "AimbotKey",
    Default = Enum.KeyCode.E,   -- or Enum.UserInputType.MouseButton2
    Mode = "Hold",              -- "Toggle" | "Hold" | "Always"
    Callback = function(Toggled)
        print("keybind toggled:", Toggled)
    end
})

-- Attached to a Label (Flag defaults to Library:NextFlag(), Default key to Enum.KeyCode.E)
Section:Label({Name = "UI Keybind"}):Keybind({
    Flag = "UIToggleKeybind",
    Default = Enum.KeyCode.X,
    Mode = "Toggle",
    Callback = function(Toggled)
        -- e.g. read the bound key string from Flags
        Library.MenuKeybind = Flags["UIToggleKeybind"].Key
    end
})
```

---

**See also:** [Colorpicker](./colorpicker.md) · [Dropdown](./dropdown.md) · [Picker overview](../pickers.md) · [Theming](../theming.md) · [Config & Flags](../config-and-flags.md) · [API Reference](../api-reference.md) · [Index](../../README.md)
