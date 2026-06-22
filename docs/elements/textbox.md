# Textbox

Creates a labeled text input field inside a Section (a 52px-tall row: a `TextLabel` caption above a rounded input box). The user types into the input; the value is reported through the Callback and stored in `Flags[Flag]`. Supports placeholder text, a default value, numeric-only filtering, and a "commit only when finished" mode. Supports Premium and Disabled overlays. On mobile, clicking the inline button captures focus on the input.

Builder: `Section:Textbox(Params) -> Textbox object`

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| Name | string | `"Textbox"` | The caption text shown above the input (`TextLabel.Text`). Also accepts `Params.name`. Also used as the fallback Flag when no `Flag`/`flag` is supplied. |
| Flag | string | `Params.Name or Params.name` (the supplied Name, NOT the literal `"Textbox"` default) | Key under which the value is stored in `Flags` and registered in `SetFlags`. Also accepts `Params.flag`. Computed as `Params.Flag or Params.flag or (Params.Name or Params.name)`; note the fallback reads the raw Name param BEFORE the `"Textbox"` default is applied, so if neither Flag nor Name is given the Flag is `nil`. Set Flag or Name explicitly. |
| Default | string | `""` (empty string) | Initial value applied via `Textbox:Set` on creation. Also accepts `Params.default`. |
| Placeholder | string | `""` (empty string) | `PlaceholderText` shown in the input when empty. Also accepts `Params.placeholder`. |
| Callback | function | `function() end` (no-op) | Invoked (via `Library:SafeCall`) with the current value whenever `Textbox:Set` runs. Also accepts `Params.callback`. |
| Finished | boolean | `false` | When `true`, `Set` (and thus Callback) is bound to the input's `FocusLost` event — committed only when focus is lost (Enter on desktop, tap-out on mobile, switching fields, or losing focus programmatically). When `false`, `Set` is bound to the input's Text `GetPropertyChangedSignal`, firing on every keystroke. Also accepts `Params.finished`. |
| Numeric | boolean | `false` | When `true`, `Set` rejects non-numeric input: if `tonumber(Value)` is nil and `string.len(tostring(Value)) > 0`, the previous `Textbox.Value` is restored (an empty string is allowed through). Effectively keeps the field digits-only. Also accepts `Params.numeric`. |
| Premium | boolean | `false` | When `true`, `BuildPremiumOverlay` is invoked over the textbox row. Also accepts `Params.premium`. |
| Disabled | boolean | `false` | When `true`, `BuildDisabledOverlay` is invoked; `Set` is a no-op while locked/disabled (`IsLockedOrDisabled`). Read from the first truthy of `Params.Disable`, `Params.disable`, `Params.Disabled`, `Params.disabled`. |

### Returns

Returns the Textbox object via `setmetatable(Textbox, Library)`. Registers `SetFlags[Flag] = function(Value) Textbox:Set(Value) end`, and (through the creation-time `Set`) stores the current value in `Flags[Flag]`. The object exposes `Name`, `Flag`, `Default`, `Placeholder`, `Callback`, `Finished`, `Numeric`, `Premium`, `Disabled`, `Window`, `Page`, `Section`, `Value`, and `Items`. On creation `TrackWindowPremiumControl(Textbox)` is called.

### Methods

- `Textbox:Set(Value)` — Programmatically sets the value. No-op if `IsLockedOrDisabled(Textbox)`. If `Numeric` is true and `Value` is non-numeric (`tonumber` fails) with length > 0, the previous `Textbox.Value` is restored. Then assigns `Textbox.Value = Value`, `Items["Input"].Instance.Text = Value`, `Flags[Textbox.Flag] = Value`, and invokes the Callback via `Library:SafeCall(Textbox.Callback, Value)`.
- `Textbox:SetText(Text)` — Sets the caption label above the input to `tostring(Text)` (`Items["Text"].Instance.Text`). Does not change the input value.
- `Textbox:SetVisibility(Bool)` — Sets `Items["Textbox"].Instance.Visible = Bool`, showing/hiding the whole textbox row.
- `Textbox:UpdatePrem(State)` — Coerces `State` to boolean (`State and true or false`), sets `Textbox.Premium`, and calls `UpdatePremiumOverlay` for the premium overlay.
- `Textbox:UpdateDisable(State)` — Coerces `State` to boolean (`State and true or false`), sets `Textbox.Disabled`, and calls `UpdateDisabledOverlay` for the disabled overlay.

### Callback

`Callback(Value)` is called via `Library:SafeCall` from inside `Textbox:Set`. `Value` is the input text as a **string** — it is NOT converted with `tonumber` even when `Numeric` is true. When `Numeric` is true and the input is non-numeric (length > 0), `Value` is the restored previous `Textbox.Value` (still a string) rather than the rejected text; an empty string passes through. The same `Value` is stored in `Flags[Textbox.Flag]`. So with `Numeric` you receive numeric-only text, but always typed as a string, never a number.

### Gotchas

- Disabled is read from four possible keys: `Disable`, `disable`, `Disabled`, `disabled` (first truthy wins).
- Flag fallback is `(Params.Name or Params.name)`, evaluated before the `"Textbox"` Name default; if neither Flag nor Name is provided, **Flag is `nil`**. Set Flag or Name explicitly.
- `Finished=true` connects `Set` to the input's `FocusLost` event; `Finished=false` connects to `GetPropertyChangedSignal("Text")` so the Callback fires on each keystroke.
- Numeric filtering happens inside `Set` via `tonumber` + `string.len`; a non-numeric string longer than 0 reverts to the prior `Textbox.Value`; empty string is allowed through.
- The `Value` passed to the Callback (and stored in `Flags`) is the raw string, never coerced to a number, even with `Numeric=true`.
- Order at creation: build UI, define methods, connect Finished/keystroke handler, register search item, call `Textbox:Set(Textbox.Default)`, set `SetFlags[Flag]`, then `TrackWindowPremiumControl(Textbox)`.
- The inline button tweens its background color on hover (Hovered Element / Element theme colors). On mobile (`IsMobile`) clicking the inline button calls `CaptureFocus` on the input.
- If `Textbox.Page.Page.Search` is set, a `{Item, Name}` record is appended to `Textbox.Page.Page.SearchItems`.

### Example

```lua
local NameBox = Section:Textbox({
    Name = "Player Name",
    Flag = "TargetName",
    Default = "",
    Placeholder = "Enter a username",
    Finished = true, -- only fire on Enter / focus lost
    Numeric = false,
    Callback = function(Value)
        print("committed:", Value)
    end,
})

local FovBox = Section:Textbox({
    Name = "FOV",
    Flag = "AimFov",
    Default = "100",
    Numeric = true,    -- digits only (still passed as a string)
    Finished = false,  -- fire on every keystroke
    Callback = function(Value)
        print("fov text:", Value, "as number:", tonumber(Value))
    end,
})

FovBox:Set("120")
```

---

**See also:** [Toggle](./toggle.md) · [Button](./button.md) · [Slider](./slider.md) · [Input overview](../components.md) · [Theming](../theming.md) · [Config & Flags](../config-and-flags.md) · [API Reference](../api-reference.md) · [Index](../../README.md)
