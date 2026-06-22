# Label

A single-row static text label inside a Section's Content area. It shows text (settable later via `SetText`) and acts as a host container for inline right-aligned sub-elements: a [Colorpicker](./colorpicker.md) (`Label:Colorpicker`) and/or a [Keybind](./keybind.md) (`Label:Keybind`). The root row is a 20px-tall Frame; sub-elements are parented into an internal right-anchored horizontal `UIListLayout` (Padding 8) so multiple stack from the right. Supports Premium and Disabled overlays and is added to the page search index when the page has Search enabled.

**Constructor:** `Section:Label(Params) -> Label object`

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| Name | string | `"Label"` | The text shown by the label. Also accepts `Params.name`. Used as the initial `TextLabel.Text` (the constructor calls `Label:SetText(Label.Name)` after building) and as the default `Name` for a hosted Keybind. |
| Premium | boolean | `false` | When true, `BuildPremiumOverlay` is invoked over the label row. Also accepts `Params.premium`. |
| Disabled | boolean | `false` | When true, `BuildDisabledOverlay` is invoked over the label row. Read from the first truthy of `Params.Disable`, `Params.disable`, `Params.Disabled`, `Params.disabled`. |

### Methods

- `Label:SetText(Text)` — Sets `Items["Text"].Instance.Text = Text` directly (no `tostring` conversion).
- `Label:SetVisibility(Bool)` — Sets `Items["Label"].Instance.Visible = Bool`, showing/hiding the whole label row.
- `Label:UpdatePrem(State)` — Coerces `State` to boolean (`State and true or false`), sets `Label.Premium`, and calls `UpdatePremiumOverlay` for the premium overlay.
- `Label:UpdateDisable(State)` — Coerces `State` to boolean (`State and true or false`), sets `Label.Disabled`, and calls `UpdateDisabledOverlay` for the disabled overlay.
- `Label:Colorpicker(Data)` — Hosts an inline Colorpicker parented into `Items["SubElements"]` (right-aligned). `Data` fields (each with a lowercase alias): `Flag` (default `Library:NextFlag()`), `Default` (Color3, default `Color3.fromRGB(255,255,255)`), `Callback` (default `function() end`), `Alpha` (default `0`). Calls `Library:CreateColorpicker` and returns the created Colorpicker object (the first return value; the second `ColorpickerItems` is discarded). See [Colorpicker](./colorpicker.md) for the returned object's methods.
- `Label:Keybind(Data)` — Hosts an inline Keybind parented into `Items["SubElements"]` (right-aligned). `Data` fields (each with a lowercase alias): `Name` (default `Label.Name`), `Flag` (default `Library:NextFlag()`), `Default` (KeyCode, default `Enum.KeyCode.E`), `Callback` (default `function() end`), `Mode` (default `"Toggle"`). Calls `Library:CreateKeybind` and returns the created Keybind object (first return value; `KeybindItems` discarded). See [Keybind](./keybind.md) for the returned object's methods.

### Callback

The Label itself has **no** `Callback`. Hosted sub-elements have their own: `Label:Colorpicker` fires its `Data.Callback` with the chosen color/alpha; `Label:Keybind` fires its `Data.Callback` per its `Mode`.

### Returns

Returns the Label object via `setmetatable(Label, Library)`. It is **not** registered to any Flag and not stored in `Flags`. The object exposes `Name`, `Premium`, `Disabled`, `Window`, `Page`, `Section`, and `Items` (`Items` contains `Label`, `Text`, `SubElements` frames). On creation `TrackWindowPremiumControl(Label)` is called.

### Gotchas

- Label has no Flag and is never written to the `Flags` table; only its hosted Colorpicker/Keybind sub-elements register flags (each defaulting to `Library:NextFlag()`).
- `Disabled` is read from four possible keys: `Disable`, `disable`, `Disabled`, `disabled` (first truthy wins).
- Sub-elements are parented into `Items["SubElements"]`, a right-anchored Frame with a Horizontal `UIListLayout` (`HorizontalAlignment` Right, Padding 8), so added pickers/keybinds stack from the right.
- On creation the constructor calls `Label:SetText(Label.Name)` and `TrackWindowPremiumControl(Label)`.
- If `Label.Page.Page.Search` is set, a `{Item, Name}` record is appended to `Label.Page.Page.SearchItems`.
- `Label:Colorpicker` and `Label:Keybind` return only the first value from `CreateColorpicker`/`CreateKeybind`; the items table is not returned. Cross-reference [Colorpicker](./colorpicker.md) and [Keybind](./keybind.md) for the returned objects' full APIs.

### Example

```lua
local MyLabel = Section:Label({
    Name = "Aimbot Settings",
})

-- host an inline colorpicker on the label
MyLabel:Colorpicker({
    Default = Color3.fromRGB(255, 0, 0),
    Alpha = 0,
    Callback = function(Color, Alpha)
        print("color", Color, Alpha)
    end,
})

-- host an inline keybind on the label
MyLabel:Keybind({
    Default = Enum.KeyCode.F,
    Mode = "Toggle",
    Callback = function(Key)
        print("keybind fired", Key)
    end,
})

MyLabel:SetText("Updated label")
```

---

**See also:** [Status](./status.md) · [Paragraph](./paragraph.md) · [List](./list.md) · [Preview](./preview.md) · [Display overview](../display-elements.md) · [Theming](../theming.md) · [Config & Flags](../config-and-flags.md) · [API Reference](../api-reference.md) · [Index](../../README.md)
