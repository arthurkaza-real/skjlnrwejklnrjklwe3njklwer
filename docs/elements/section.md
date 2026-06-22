# Section

A `Section` is the boxed, titled container that holds UI components. It renders a title `TextLabel` (TextSize 14, using `Library.Font`) followed by an inlaid rounded Frame (the bordered "Inline" content box, themed to Background) with a rounded `UICorner`. All component builders (Toggle, Slider, Dropdown, Button, etc.) are called on the Section object and parent into its internal Content frame via a vertical `UIListLayout` (6px padding). The Section's outer Frame is placed into either the left or right column of its parent SubPage according to `Side`.

**Constructor:** `SubPage:Section(Params) -> Section`

Defined as `Library.Section = function(Self, Params)`; `Self` is the SubPage (its `ColumnsData` provides the two columns). Conventionally called as `SubPage:Section({...})`.

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| Name | string | `"Section"` | Title text shown at the top of the section box. Also accepts the lowercase alias `Params.name`. Defaults to the literal string `"Section"` if omitted. |
| Side | number | `1` | Which column of the parent SubPage the section is placed in. Also accepts the lowercase alias `Params.side`. `Side = 1` is the left column (`ColumnsData[1]` / `LeftColumn`); `Side = 2` is the right column (`ColumnsData[2]` / `RightColumn`). Used directly as the index into `Section.Page.ColumnsData[Section.Side]`, so only `1` or `2` are valid; other values index `nil` and the Parent assignment will fail. |

### Methods

None. `Section` exposes no methods of its own — it is a pure layout container. You call component builder methods (inherited via the Library metatable) on it, e.g. `Section:Toggle(...)`, `Section:Slider(...)`.

### Callback

None. `Section` takes no `Callback`. It is a pure layout container; callbacks belong to the individual components you create on it.

### Returns

Returns the Section table with the Library metatable attached via `setmetatable(Section, Library)`, so every component builder method (Toggle, Slider, Dropdown, Button, Label, Textbox, Keybind, Colorpicker, etc.) can be chained off it. The table stores `Name`, `Side`, `Window` (the resolved parent Window), `Page = Self` (the parent SubPage), and `Items` (the created instances: `Section`, `Text`, `Inline`, `Content`). It is **not** registered under any `.Flag` and is not added to any global table.

### Gotchas

- Section is the container you call component builders on — e.g. `Section:Toggle({...})`, `Section:Slider({...})`. It is not interactive itself.
- Normally created from a SubPage (`SubPage:Section`), since it indexes `Section.Page.ColumnsData[Side]` to find the target column; calling it on an object without a `ColumnsData[Side]` entry will fail when parenting the Section frame.
- `Side` maps directly to a column index: `1` = left column, `2` = right column. Only indices `1` and `2` exist in `ColumnsData`.
- The constructor resolves the owning Window via `ParentWindow = rawget(Self, "Window")`; if that is not a table it falls back to using `Self` as the Window. This Window reference is stored as `Section.Window` and later used by components for premium/disabled gating.
- Components added to a Section flow top-to-bottom inside its Content frame (`UIListLayout`, 6px Padding) with internal `UIPadding` (top 10, bottom 14, left 28, right 28). The Inline box adds its own `UIPadding` (top 1, bottom 10) and a `UICorner`.
- `Name` defaults to the literal string `"Section"` if omitted; `Side` defaults to `1`.

### Example

```lua
local LeftSection = MovementSubPage:Section({
    Name = "Section Left",
    Side = 1, -- left column
})

local RightSection = MovementSubPage:Section({
    Name = "Section Right",
    Side = 2, -- right column
})

-- Build components on the Section
LeftSection:Toggle({
    Name = "Toggle",
    Flag = "Toggle",
    Default = false,
    Callback = function(Value)
        print(Value)
    end,
})
```

---

**See also:** [Page](./page.md) · [SubPage](./subpage.md) · [Layout overview](../pages-and-sections.md) · [Theming](../theming.md) · [Config & Flags](../config-and-flags.md) · [API Reference](../api-reference.md) · [Index](../../README.md)
