# Slider

Creates a numeric slider inside a Section's content area (parented to `Section.Items["Content"].Instance`). It contains a title Text label, a draggable `RealSlider` track (`TextButton`) with a theme-bound gradient Accent fill, a Value readout label (number + suffix), and Minus/Plus stepper buttons. Dragging/clicking the track or using +/- changes the value; every change is clamped to `[Min, Max]`, rounded to `Decimals`, written to `Flags[Flag]`, and passed to the Callback. Supports Premium-locked and Disabled states via overlays. The Slider row is 35px tall.

Builder: `Section:Slider(Params) -> Slider object`

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| Name | string | `"Slider"` | The slider's title text (Text label) and search-registration name. Also accepts `Params.name`. |
| Flag | string | `Params.Name or Params.name` (i.e. the Slider's Name) | Key under which the current value is stored in the global `Flags` table, and the key registered in `SetFlags` for external setting. Falls back to (`Params.Name or Params.name`). Also accepts `Params.flag`. |
| Default | number | `0` | Initial value; `Slider:Set(Slider.Default)` is called once near the end of construction. Also accepts `Params.default`. |
| Min | number | `0` | Minimum value used for clamping and for computing the accent fill ratio. Also accepts `Params.min`. |
| Max | number | `100` | Maximum value used for clamping and for computing the accent fill ratio. Also accepts `Params.max`. |
| Decimals | number | `0` | Rounding precision passed to `Library:Round` for each set value. NOTE: the same value is **also** used as the +/- step increment (Plus calls `Set(Value + Decimals)`, Minus calls `Set(Value - Decimals)`), so a `Decimals` of `0` makes the steppers no-ops. Also accepts `Params.decimals`. |
| Suffix | string | `""` | Text appended after the numeric value in the readout, formatted as `string.format("%s%s", Slider.Value, Slider.Suffix)`. Also accepts `Params.suffix`. |
| Premium | boolean | `false` | If `true`, builds a premium overlay over the Slider at construction, locking interaction behind premium status. Also accepts `Params.premium`. |
| Disabled | boolean | `false` | If `true`, builds a disabled overlay at construction and blocks `Set()`. Enabled by any truthy one of `Params.Disable`, `Params.disable`, `Params.Disabled`, or `Params.disabled` (evaluated in that order). |
| Callback | function | `function() end` | Invoked (via `Library:SafeCall`) on every value change with the new clamped/rounded value. Also accepts `Params.callback`. |

### Returns

Returns the Slider table (including internal fields `Value=0`, `Sliding=false`, `Items`) with its metatable set to `Library` so the fluent builder chain continues. On every `Set` it mirrors the value into `Flags[Slider.Flag]`. After construction registers `SetFlags[Slider.Flag] = function(Value) Slider:Set(Value) end` for external setting by flag. If `Slider.Page.Page.Search` is truthy, inserts a SearchData entry `{ Item = Items["Slider"], Name = Slider.Name }` into `Slider.Page.Page.SearchItems`. Calls `Slider:Set(Slider.Default)` and `TrackWindowPremiumControl(Slider)` before returning.

### Methods

- `Slider:Set(Value)` — Core setter. Returns early if `IsLockedOrDisabled(Slider)`. Otherwise sets `Slider.Value = Library:Round(math.clamp(Value, Slider.Min, Slider.Max), Slider.Decimals)`, tweens `Items["Accent"]` size to `UDim2.new((Value-Min)/(Max-Min), 0, 1, 0)` with a Quart/Out tween, sets `Items["Value"].Instance.Text = string.format("%s%s", Slider.Value, Slider.Suffix)`, writes `Flags[Slider.Flag] = Slider.Value`, then calls `Library:SafeCall(Slider.Callback, Slider.Value)`.
- `Slider:GetSize(Input)` — Converts an input position into a slider value. Computes `SizeX = (Input.Position.X - RealSlider.AbsolutePosition.X) / RealSlider.AbsoluteSize.X`, then returns `((Max - Min) * SizeX) + Min` (un-clamped and un-rounded; `Set` handles clamping/rounding). Used by the drag/click handlers; also callable with any object exposing `.Position.X` (the mobile fallback passes `{ Position = Vector3.new(x, y, 0) }`).
- `Slider:SetText(Text)` — Sets `Items["Text"].Instance.Text = tostring(Text)`. Updates the title label only; does not change `Slider.Name` or the registered search entry.
- `Slider:SetVisibility(Bool)` — Sets `Items["Slider"].Instance.Visible = Bool` (toggles the whole Slider row container).
- `Slider:UpdateDisable(State)` — Coerces `State` to boolean via `(State and true or false)`, stores it on `Slider.Disabled`, and calls `UpdateDisabledOverlay(Items, "Slider", IsEnabled, Slider)`. When disabled, `Set()` returns early.
- `Slider:UpdatePrem(State)` — Coerces `State` to boolean via `(State and true or false)`, stores it on `Slider.Premium`, and calls `UpdatePremiumOverlay(Items, "Slider", IsEnabled, Slider)`. Present in source alongside the requested methods.

### Callback

`Callback(Value)` receives the clamped and rounded numeric value (`Slider.Value`, a number). Called as `Library:SafeCall(Slider.Callback, Slider.Value)` on every change, including the initial `Slider:Set(Slider.Default)` during construction.

### Gotchas

- `Flag` defaults to the slider's Name when not provided; the value is mirrored into the global `Flags` table under that key on every `Set`. See [Config & Flags](../config-and-flags.md).
- `SetFlags[Slider.Flag]` is registered (after the initial `Set(Default)`) so external code can drive the slider by flag, which calls `Slider:Set(Value)`.
- The +/- stepper buttons increment/decrement by `Decimals` (not by `1`), so leaving `Decimals` at the default `0` makes the +/- buttons effectively no-ops.
- `Set()` and all drag/click interaction are gated by `IsLockedOrDisabled(Slider)`: premium-locked or disabled sliders ignore input.
- Disabled state has four accepted aliases evaluated in order: `Disable`, `disable`, `Disabled`, `disabled`.
- Dragging is tracked via the internal `Sliding` flag; `RealSlider`'s `InputBegan` starts a drag and sets a per-input `Changed` connection (`InputChanged`) that clears `Sliding` on `UserInputState.End`, and a global `UserInputService.InputChanged` handler updates the value while `Sliding`.
- A mobile fallback path (when `IsMobile`, i.e. `UserInputService.TouchEnabled`) wires `RealSlider.MouseButton1Down` (building a fake input `{ Position = Vector3.new(x, y, 0) }`) and a global `UserInputService.InputEnded` handler for touch.
- `Items["Value"]` is created with placeholder Text `"50%"`, which is immediately overwritten by the initial `Slider:Set(Slider.Default)`.
- `TrackWindowPremiumControl(Slider)` is called at the end of construction for premium tracking.

### Example

```lua
local Slider = Section:Slider({
    Name = "Walk Speed",
    Flag = "WalkSpeed",
    Default = 16,
    Min = 0,
    Max = 200,
    Decimals = 1,
    Suffix = " studs",
    Callback = function(Value)
        print("WalkSpeed is now", Value)
    end
})

Slider:Set(50)        -- programmatically set (clamped/rounded, fires callback)
Slider:SetText("Speed")
```

---

**See also:** [Toggle](./toggle.md) · [Button](./button.md) · [Textbox](./textbox.md) · [Input overview](../components.md) · [Theming](../theming.md) · [Config & Flags](../config-and-flags.md) · [API Reference](../api-reference.md) · [Index](../../README.md)
