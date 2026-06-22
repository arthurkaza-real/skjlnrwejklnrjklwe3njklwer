# Colorpicker

An HSV color picker with a saturation/value palette, a hue bar, and an alpha (opacity) bar, plus a small swatch button (`ColorpickerButton`) that toggles a popup window (`ColorpickerWindow`) open and closed. It is **never instantiated directly** — you attach it onto an existing [Toggle](./toggle.md) or [Label](./label.md). The picker tracks Hue/Saturation/Value/Alpha and exposes the resulting `Color3`, hex string, alpha and transparency through the global `Flags` table under its `Flag`, firing the `Callback` whenever the color or alpha changes.

**Builder:** `Toggle:Colorpicker(Data) -> Colorpicker` or `Label:Colorpicker(Data) -> Colorpicker` (both wrap the internal `Library:CreateColorpicker(Data) -> (Colorpicker, Items)`)

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Parent` | table (a Library object whose `.Instance` is a `GuiObject`) | required (injected automatically by the wrapper as `Items["SubElements"]`) | Host container the swatch button is parented into via `Data.Parent.Instance`. **You never pass this yourself** — the `Toggle:Colorpicker` / `Label:Colorpicker` wrappers inject it. Calling `CreateColorpicker` without a valid `Parent` errors. |
| `Flag` | string | `CreateColorpicker`: `Data.Flag` (no fallback). Via `Toggle:Colorpicker`: `Data.Flag` or `Data.flag` or `Data.Name` or `Data.name` or `Toggle.Name`. Via `Label:Colorpicker`: `Data.Flag` or `Data.flag` or `Library:NextFlag()` | Unique key used to register state in `Flags` and the `SetFlags` setter. `CreateColorpicker` itself reads ONLY exact-case `Data.Flag`; the lowercase alias and Name/`NextFlag` fallbacks are resolved in the wrapper before forwarding, so in practice `Flag` is always set. `Flags[Flag]` is written as `{Alpha, Color, HexValue, Transparency}`. |
| `Default` | `Color3` \| string (hex) \| table `{r,g,b}` | `CreateColorpicker`: `nil` (Set only runs if truthy). Via wrappers: `Color3.fromRGB(255, 255, 255)` | Initial color. Accepts a `Color3`, a hex string (e.g. `"#FF0000"` / `"FF0000"`, passed to `Color3.fromHex`), or a 3-element RGB table `{255,0,0}` (passed to `Color3.fromRGB`) — normalized inside `Set`. The wrappers always default this to white, so `Set` runs in practice. Lowercase alias `Data.default` is resolved only in the wrapper. |
| `Alpha` | number | `CreateColorpicker`: forwarded to `Set`, which defaults to `0` when nil. Via wrappers: `0` | Initial alpha (opacity) in range 0-1, where 0 is one end of the alpha bar and 1 the other. Passed as the second argument to the initial `Set`. Stored as `Colorpicker.Alpha = Alpha or 0`. `Transparency` in `Flags` is computed as `1 - Alpha`. Lowercase alias `Data.alpha` resolved only in the wrapper. |
| `Callback` | function | `CreateColorpicker`: `nil` (only invoked if truthy). Via wrappers: `function() end` (no-op) | Invoked (via `Library:SafeCall`) whenever the color or alpha changes, including the initial `Default` application, but ONLY if `Data.Callback` is truthy. Receives `(Color: Color3, Alpha: number)`. Lowercase alias `Data.callback` resolved only in the wrapper, which also substitutes a no-op default. |

### Methods

- `Colorpicker:Set(Color, Alpha)` — Sets the picker's color and alpha. If `Color` is a table it is treated as `{r,g,b}` and passed to `Color3.fromRGB(Color[1], Color[2], Color[3])`; if a string, passed to `Color3.fromHex`; otherwise used as-is (a `Color3`). Converts to HSV via `Color:ToHSV()` to set Hue/Saturation/Value, sets `Alpha = Alpha or 0` (defaults to 0), repositions the palette/hue/alpha draggers, and calls `Update()` (which fires the `Callback`). Also reachable via `SetFlags[Flag](Color, Alpha)`.
- `Colorpicker:SetOpen(Bool)` — Opens (`true`) or closes (`false`) the popup window (`ColorpickerWindow`). Has an internal `Debounce` guard (returns early if mid-transition). Opening positions the window under the swatch button, reparents it to `Library.Holder.Instance`, makes it visible, fades descendants in, starts a `RenderStepped` connection that keeps it pinned under the button, closes any other open frames in `Library.OpenFrames`, and registers itself in `Library.OpenFrames`. Closing tweens/fades it out, reparents it back to `Library.UnusedHolder.Instance`, removes itself from `Library.OpenFrames`, and disconnects the `RenderStepped` loop. Bound to `ColorpickerButton` `MouseButton1Down`, which calls `SetOpen(not Colorpicker.IsOpen)`.
- `Colorpicker:SetVisibility(Bool)` — Shows (`true`) or hides (`false`) the swatch button itself by setting `Items["ColorpickerButton"].Instance.Visible = Bool`.
- `Colorpicker:Update(IsFromAlpha)` — Recomputes `Color = Color3.fromHSV(Hue, Saturation, Value)` and `HexValue = Color:ToHex()` (no leading `#`), retints the swatch button and the palette (to `Color3.fromHSV(Hue, 1, 1)`), writes `Flags[Flag] = {Alpha, Color, HexValue, Transparency = 1 - Alpha}`, and — only if `Data.Callback` is truthy — fires `Library:SafeCall(Data.Callback, Color, Alpha)`. If `IsFromAlpha` is truthy, the Alpha bar's tint tween is skipped. Called automatically by `Set`/`SlidePalette`/`SlideHue`/`SlideAlpha`.
- `Colorpicker:SlidePalette(Input)` — Updates Saturation and Value from a pointer `Input` (clamped fractions of `Input.Position` relative to the Palette's `AbsolutePosition`/`AbsoluteSize`), moves the `PaletteDragger`, and calls `Update()`. Returns early (no-op) unless the internal `SlidingPalette` flag is active. Driven by `Palette` `InputBegan` and the global `InputChanged` handler (plus a mobile `MouseButton1Down` fallback when `IsMobile`); not normally called manually.
- `Colorpicker:SlideHue(Input)` — Updates Hue from a pointer `Input` (clamped fraction of `Input.Position.X` relative to the Hue bar), moves the `HueDragger`, and calls `Update()`. Returns early (no-op) unless the internal `SlidingHue` flag is active. Driven by `HueInline` `InputBegan` and the global `InputChanged` handler (plus a mobile fallback when `IsMobile`); not normally called manually.
- `Colorpicker:SlideAlpha(Input)` — Updates Alpha from a pointer `Input` (clamped fraction of `Input.Position.X` relative to the Alpha bar), moves the `AlphaDragger`, and calls `Update(true)` (so the alpha-bar tint is left unchanged). Returns early (no-op) unless the internal `SlidingAlpha` flag is active. Driven by `Alpha` `InputBegan` and the global `InputChanged` handler (plus a mobile fallback when `IsMobile`); not normally called manually.

### Callback

`Callback(Color: Color3, Alpha: number)` — invoked via `Library:SafeCall(Data.Callback, Colorpicker.Color, Colorpicker.Alpha)` inside `Update`, on **every** color/alpha change including the initial `Default`. It is only invoked when `Data.Callback` is truthy (the wrappers substitute a no-op `function() end` so it effectively always runs there). Note it receives **both** the `Color3` **and** the `Alpha` (two arguments), not just the color.

### Returns

`CreateColorpicker` returns two values: `(Colorpicker, Items)`. The `Toggle:Colorpicker` / `Label:Colorpicker` wrappers return **only** the `Colorpicker` object. The `Colorpicker` table exposes: `Hue` (number, default `0`), `Saturation` (`0`), `Value` (`0`), `Alpha` (`0`), `Color` (`Color3`, default `Color3.fromRGB(255,255,255)`), `HexValue` (string, default `"#FFFFFF"`), `Flag` (`= Data.Flag`), `IsOpen` (boolean, default `false`), and `Items` (table of created GuiObjects, e.g. `ColorpickerButton`, `ColorpickerWindow`, `Palette`, `Saturation`, `Value`, `PaletteDragger`, `Hue`, `HueInline`, `HueDragger`, `Alpha`, `AlphaDragger`, `Checkers`). Global state registered: `Flags[Flag] = {Alpha, Color, HexValue, Transparency = 1 - Alpha}` and `SetFlags[Flag] = function(Value, Alpha) Colorpicker:Set(Value, Alpha) end`.

### Gotchas

> Not constructed directly. Attach via `Toggle:Colorpicker(Data)` or `Label:Colorpicker(Data)`. These read `Data` (with lowercase aliases `Data.flag` / `Data.default` / `Data.callback` / `Data.alpha`) AND inject `Parent = Items["SubElements"]`, then forward to `Library:CreateColorpicker`, which returns `(Colorpicker, Items)` but the wrapper returns only `Colorpicker`.

- `CreateColorpicker` itself reads ONLY exact-case fields: `Data.Parent` (required, used as `Data.Parent.Instance`), `Data.Flag`, `Data.Default`, `Data.Alpha`, `Data.Callback`. The lowercase aliases and the `Color3.fromRGB(255,255,255)` / no-op-callback defaults exist ONLY in the wrappers, not in `CreateColorpicker`.
- `Flag` default differs by host: `Toggle:Colorpicker` uses `Data.Flag` or `Data.flag` or `Data.Name` or `Data.name` or `Toggle.Name` (a `Name` field can override the toggle name); `Label:Colorpicker` uses `Data.Flag` or `Data.flag` or `Library:NextFlag()`. `CreateColorpicker` has no `Flag` fallback of its own.
- The wrappers do NOT pass a `Default` of `nil`; they always pass `Color3.fromRGB(255,255,255)` when omitted, so `Colorpicker:Set` always runs in practice. If you call `CreateColorpicker` directly without `Data.Default`, the initial `Set` is skipped.
- `Set` accepts three `Color` forms: `Color3`, hex string (`Color3.fromHex`), or `{r,g,b}` RGB table (`Color3.fromRGB`). `Alpha` is a separate second argument and defaults to `0` when nil.
- The `Callback` receives **both** `Color3` **and** `Alpha` (two arguments), not just the color.
- Global state: `Flags[Flag] = {Alpha, Color, HexValue, Transparency = 1 - Alpha}`; `SetFlags[Flag] = function(Value, Alpha) Colorpicker:Set(Value, Alpha) end`.
- `HexValue`: the initial field value is `"#FFFFFF"`, but `Update` sets it via `Color3:ToHex()`, which returns hex **WITHOUT** a leading `#` (e.g. `"FFFFFF"`). `Color3.fromHex` (used in `Set`) accepts hex strings with or without the leading `#`.
- `SlidePalette` / `SlideHue` / `SlideAlpha` are internal input handlers gated on active-drag booleans (`SlidingPalette` / `SlidingHue` / `SlidingAlpha`) and are normally driven by user input rather than called directly.
- Mobile/touch fallback: when the global `IsMobile` is true, additional `MouseButton1Down` handlers on `Palette`/`HueInline`/`Alpha` plus a `UserInputService.InputEnded` handler are wired, for executors where `GuiObject.InputBegan` doesn't fire for touch.

### Example

```lua
local Section = Window:Page({Name = "Visuals"}):SubPage({Name = "ESP"}):Section({Name = "ESP"})

local Toggle = Section:Toggle({
    Name = "Box ESP",
    Default = false,
    Callback = function(state) print("esp", state) end
})

-- Attach a colorpicker (with alpha) onto the toggle.
-- Do NOT pass Parent yourself; the wrapper supplies it.
local Picker = Toggle:Colorpicker({
    Flag = "BoxColor",
    Default = Color3.fromRGB(255, 0, 0),
    Alpha = 1,
    Callback = function(Color, Alpha)
        print("color:", Color, "alpha:", Alpha)
    end
})

-- Programmatically change it later:
Picker:Set("#00FF00", 0.5)   -- hex string + 50% alpha
Picker:Set({0, 0, 255}, 1)    -- RGB table + full alpha
Picker:SetOpen(true)          -- open the popup
Picker:SetVisibility(false)   -- hide the swatch button

-- Or attach onto a Label instead (Flag auto-generated if omitted):
local Picker2 = Section:Label({Name = "Fill"}):Colorpicker({
    Default = Color3.fromRGB(0, 170, 255),
    Callback = function(Color, Alpha) print(Color, Alpha) end
})
```

---

**See also:** [Keybind](./keybind.md) · [Dropdown](./dropdown.md) · [Picker overview](../pickers.md) · [Theming](../theming.md) · [Config & Flags](../config-and-flags.md) · [API Reference](../api-reference.md) · [Index](../../README.md)
