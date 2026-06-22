# Button

Creates a clickable button element inside a Section's content area (parented to `Section.Items["Content"].Instance`). It renders a pill-shaped `ButtonBackground` (`TextButton`) with a theme-bound gradient accent and a centered Text label, plus an inner clickable `Button` overlay (`TextButton`) that animates a width collapse-and-restore when pressed before firing the callback. Supports Premium-locked and Disabled states via overlays. The `ButtonBackground` row is 25px tall and spans the full section width.

Builder: `Section:Button(Params) -> Button object`

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| Name | string | `"Button"` | The text shown on the button (set as the Text label) and used as the search-registration name. Also accepts `Params.name`. |
| Premium | boolean | `false` | If `true`, builds a premium overlay over the `ButtonBackground` at construction, locking interaction behind premium status. Also accepts `Params.premium`. |
| Disabled | boolean | `false` | If `true`, builds a disabled overlay at construction and blocks `Press()`. Enabled by any truthy one of `Params.Disable`, `Params.disable`, `Params.Disabled`, or `Params.disabled` (evaluated in that order). |
| Callback | function | `function() end` | Invoked (via `Library:SafeCall`) when the button is pressed and the element is not locked/disabled. Receives no arguments. Also accepts `Params.callback`. |

### Returns

Returns the Button table (fields `Name`, `Premium`, `Disabled`, `Callback`, `Window`, `Page`, `Section`, `Items`) with its metatable set to `Library` so the fluent builder chain continues. Does **not** register a `.Flag`. If `Button.Page.Page.Search` is truthy, inserts a SearchData entry `{ Item = Items["ButtonBackground"], Name = Button.Name }` into `Button.Page.Page.SearchItems`. Calls `TrackWindowPremiumControl(Button)` before returning.

### Methods

- `Button:Press()` — Programmatically triggers the button. If `IsLockedOrDisabled(Button)` is true, returns early and does nothing. Otherwise tweens the inner `Items["Button"]` size to `UDim2.new(0,0,1,0)`, `task.wait(0.2)`, tweens it back to `UDim2.new(1,-2,1,0)`, then calls `Library:SafeCall(Button.Callback)` with no arguments. The inner Button's `MouseButton1Down` handler also calls `Button:Press()`.
- `Button:SetText(Text)` — Sets `Items["Text"].Instance.Text = tostring(Text)`. Updates the visible label only; does not change `Button.Name` or the registered search entry.
- `Button:SetVisibility(Bool)` — Sets `Items["Button"].Instance.Visible = Bool`. Note: this toggles the inner clickable overlay's visibility, **not** the outer `ButtonBackground` row container.
- `Button:UpdateDisable(State)` — Coerces `State` to boolean via `(State and true or false)`, stores it on `Button.Disabled`, and calls `UpdateDisabledOverlay(Items, "ButtonBackground", IsEnabled, Button)`. When disabled, `Press()` returns early.
- `Button:UpdatePrem(State)` — Coerces `State` to boolean via `(State and true or false)`, stores it on `Button.Premium`, and calls `UpdatePremiumOverlay(Items, "ButtonBackground", IsEnabled, Button)`. Present in source alongside the requested methods.

### Callback

`Callback()` receives **nothing**. Called as `Library:SafeCall(Button.Callback)` with no arguments.

### Gotchas

- Disabled state has four accepted aliases evaluated in order: `Disable`, `disable`, `Disabled`, `disabled` (any one truthy enables it).
- Premium and Disabled overlays are only built at construction time when the corresponding flag is true; `UpdatePrem`/`UpdateDisable` then build/toggle them at runtime via `UpdatePremiumOverlay`/`UpdateDisabledOverlay`.
- `Press()` is guarded by `IsLockedOrDisabled(Button)`: if premium-locked or disabled, it does nothing (no animation, no callback).
- `SetVisibility` toggles the inner `Items["Button"]` overlay's `Visible`, not the outer `Items["ButtonBackground"]` row.
- The button auto-registers into page search (`Page.Page.SearchItems`) only when `Button.Page.Page.Search` is truthy.
- `TrackWindowPremiumControl(Button)` is called at the end of construction for premium tracking.
- The accent gradient and inner element background are theme-bound via `:AddToTheme` (gradient -> Accent Start/Accent End; inner Button -> Element, with Hovered Element on hover). See [Theming](../theming.md).

### Example

```lua
local Button = Section:Button({
    Name = "Execute",
    Callback = function()
        print("Button pressed")
    end
})

Button:SetText("Run Now")
Button:Press() -- fires the callback programmatically (with the collapse/restore press animation)
```

---

**See also:** [Toggle](./toggle.md) · [Slider](./slider.md) · [Textbox](./textbox.md) · [Input overview](../components.md) · [Theming](../theming.md) · [Config & Flags](../config-and-flags.md) · [API Reference](../api-reference.md) · [Index](../../README.md)
