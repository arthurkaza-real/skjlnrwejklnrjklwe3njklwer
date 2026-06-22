# Theming

The theme system controls every color in the UI through a single active color table, `Library.Theme`. Themed instances register the properties they want driven by a theme key (or a computed function), and the library re-applies those colors whenever a key changes — so a single call can recolor the entire interface at runtime. This page covers the default theme keys and their `Color3` values, the runtime theming methods (`Library:ChangeTheme`, `:AddToTheme`, `Library:ChangeItemTheme`), and the in-UI `CreateThemingSection` live editor. For the color UI used by the editor see [Colorpicker](pickers.md); for where the theme editor lives in the Settings page and config persistence see [Config & Flags](config-and-flags.md).

## Theme System

`Library.Theme` is the active color table that every themed instance pulls from. The default theme is `Themes.Preset` (defined lines 334-346) and is assigned to `Library.Theme` at line 348 (`Library.Theme` is `nil` at table construction, line 224). Themed objects register via `Object:AddToTheme({ Property = "ThemeKey" })` on objects wrapped by `Library:Create`; the property is immediately set from `Library.Theme[key]` and the mapping is recorded. `AddToTheme` also accepts a function value (the property is set to the function's return value). `Library:ChangeTheme(key, color)` updates `Library.Theme[key]` and re-applies to every registered item whose mapped value string-equals that key, and re-runs any function-valued properties.

**Builder:** `Library.Theme` (active theme table, set to `Themes.Preset` on load at line 348); mutated/read via `Library:ChangeTheme`, `Library:AddToTheme`, `Library:ChangeItemTheme`.

### Arguments

These are the default keys present in `Themes.Preset` (the exact 9 keys assigned to `Library.Theme` on load). Each maps a theme key string to a `Color3`.

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Background` | `Color3` | `Color3.fromRGB(18, 18, 20)` | Default theme key `"Background"` in `Themes.Preset` (main panel background). |
| `Inline` | `Color3` | `Color3.fromRGB(15, 15, 16)` | Default theme key `"Inline"`. |
| `Accent Start` | `Color3` | `Color3.fromRGB(175, 102, 126)` | Default theme key `"Accent Start"` (gradient/accent start color). |
| `Accent End` | `Color3` | `Color3.fromRGB(114, 75, 135)` | Default theme key `"Accent End"` (gradient/accent end color). |
| `Text` | `Color3` | `Color3.fromRGB(220, 229, 247)` | Default theme key `"Text"` (primary text color). |
| `Text 2` | `Color3` | `Color3.fromRGB(145, 151, 163)` | Default theme key `"Text 2"` (secondary/dim text color). |
| `Element` | `Color3` | `Color3.fromRGB(24, 24, 27)` | Default theme key `"Element"` (component surface color). |
| `Hovered Element` | `Color3` | `Color3.fromRGB(32, 32, 36)` | Default theme key `"Hovered Element"` (component hover color). |
| `Topbar` | `Color3` | `Color3.fromRGB(28, 28, 29)` | Default theme key `"Topbar"` (top bar color). |

`Library.Theme` is a `table<string, Color3>`.

### Methods

- `Library:ChangeTheme(Theme, Color)` — Sets `Library.Theme[Theme] = Color`, then iterates `Library.ThemingStuff` (the array of registered `{Item, Properties}`) and for each property whose mapped value is a string equal to `Theme`, sets `Item.Item[Property] = Color`; properties whose mapped value is a function are re-evaluated (`Item.Item[Property] = Value()`). `Theme` is the theme key string (e.g. `"Accent End"`); `Color` is the new `Color3`. Note: function-valued properties are re-run on **every** `ChangeTheme` call regardless of which key changed. Returns nothing.
- `<wrappedInstance>:AddToTheme(Properties)` — Registers an instance (`Self` must be a `Library:Create` wrapper exposing `Self.Instance`) for theming. `Properties` maps a Roblox property name to either a theme key string (property set to `Library.Theme[key]`) or a function (property set to the function's return value). Appends `{Item=Object, Properties=Properties}` to `Library.ThemingStuff` and stores `Library.ThemeMap[Object] = ThemeData`. Returns `Self` (the wrapped instance object) for chaining.
- `Library:ChangeItemTheme(Properties)` — Intended to update the stored theme mapping for `Self.Instance`. Guards with `if not Library.ThemingStuff[Object] then return end` and then sets `Library.ThemingStuff[Object].Properties = Properties` and `Library.ThemingStuff[Object] = Library.ThemeMap[Object]`. Returns nothing.

**Callback:** n/a — the theme methods take no callback. (The live editor's pickers fire a `Color3` callback; see `CreateThemingSection` below.)

### Gotchas

- Key names contain spaces (`"Accent Start"`, `"Accent End"`, `"Text 2"`, `"Hovered Element"`) — index them as bracket strings, e.g. `Library.Theme["Accent Start"]`.
- The default theme is exactly the 9 keys above. `Library.Theme = Themes.Preset` is set at line 348; `Library.Theme` is `nil` at table construction (line 224), so do not read it before the library has finished loading.
- `AddToTheme` is defined on the `Library` metatable, so it is callable on any object returned by `Library:Create` (they `setmetatable` to `Library`).
- `AddToTheme` value can be a string (theme key) **or** a function (computed value); `ChangeTheme` re-runs function values on **each** theme change, not only when the relevant key changes.
- In `AddToTheme`, if the mapped key is not present in `Library.Theme` it first sets the property to the literal string value — a likely-buggy edge case; only use keys that already exist in `Library.Theme`.
- Bookkeeping tables: `Library.ThemingStuff` is an **array** of `{Item, Properties}` (populated via `table.insert`); `Library.ThemeMap` is keyed `Object -> ThemeData`.
- **`Library:ChangeItemTheme` is effectively a no-op as written.** Because `ThemingStuff` is an array, indexing it by `Object` (`ThemingStuff[Object]`) is virtually always `nil`, so the guard returns early. `ThemeMap` is the table actually keyed by `Object`.

### Example

```lua
-- Recolor the accent end across the whole UI at runtime:
Library:ChangeTheme("Accent End", Color3.fromRGB(166, 147, 243))

-- Register a custom-created instance for theming (string key + function value):
local Box = Library:Create("Frame", { Parent = Library.Holder.Instance, Size = UDim2.fromOffset(100,100) })
Box:AddToTheme({
    BackgroundColor3 = "Background",
    BorderColor3 = function() return Library.Theme["Accent Start"] end,
})
```

## CreateThemingSection (live theme editor)

`CreateThemingSection` builds the in-UI live theme editor inside a new Section titled `"Theme"` (`Side = 1`) on the sub-tab it is called on (`Self`). It iterates every key/value in `Library.Theme` and, for each, creates a Label (named after the theme key) with a chained [Colorpicker](pickers.md) whose `Flag` is the theme key and whose `Default` is the current color. Changing a picker sets `Library.Theme[key] = color` and calls `Library:ChangeTheme(key, color)` so the UI re-themes live. Takes no arguments beyond `Self`.

**Builder:** `Library.CreateThemingSection(Self)` — invoked as `SettingsPage:CreateThemingSection()` -> `nil`

### Arguments

`CreateThemingSection` takes no arguments beyond `Self` (the sub-tab it builds into). It generates one Label + Colorpicker pair per key for each entry it finds in `Library.Theme` at build time.

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| _(none)_ | — | — | No parameters. The section is generated from the current contents of `Library.Theme`. |

Returns nothing (`nil`). It registers one Colorpicker flag per `Library.Theme` key (the flag name equals the theme key, e.g. `"Background"`, `"Accent Start"`).

### Methods

- _(none)_ — `CreateThemingSection` exposes no methods on its return value; it returns `nil`.

### Callback

`CreateThemingSection` has no section-level callback. Each generated Colorpicker has its own `Callback` that receives the chosen `Color3` (`Value`); it sets `Library.Theme[Index] = Value` and calls `Library:ChangeTheme(Index, Value)`, where `Index` is the theme key captured by the loop.

### Gotchas

- One Label + Colorpicker pair is generated **per key present in `Library.Theme` at build time**, so custom theme keys you added also get pickers. With the default theme the keys are: `"Background"`, `"Inline"`, `"Accent Start"`, `"Accent End"`, `"Text"`, `"Text 2"`, `"Element"`, `"Hovered Element"`, `"Topbar"`.
- Each Colorpicker is created with `Flag = <theme key>` (the loop's `Index`) and `Default = <current theme color>` (the loop's `Value`).
- The loop uses `for Index, Value in Library.Theme do` (generalized iteration); inside, the Colorpicker `Callback` parameter is also named `Value`, shadowing the loop's `Value` within the callback body.
- Must be added to a one-column sub-tab (`Side = 1`). See [Config & Flags](config-and-flags.md) for `CreateSettingsPage`, which destroys the right column so only `Side = 1` sections render.

### Example

```lua
local SettingsPage = Window:CreateSettingsPage()
SettingsPage:CreateThemingSection()
```

## See also

- [Colorpicker](pickers.md) — the color UI each generated theme picker uses.
- [Config & Flags](config-and-flags.md) — `CreateSettingsPage` and how flags/configs persist the theme pickers.
- [Index](../README.md) — documentation home.
