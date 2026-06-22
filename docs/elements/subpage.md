# SubPage

A `SubPage` is a single tab in the horizontal tab strip rendered inside a Page (the Page's `Items["SubPages"]` ScrollingFrame). Each SubPage renders a 60px-wide icon button (with an optional name label beneath the icon) in that strip, and owns its own two-column content area: a `LeftColumn` and a `RightColumn` ScrollingFrame held in a hidden `Page` Frame. Clicking a SubPage's icon switches the Page to show that SubPage's columns (its content Frame is reparented into `Page.Page.Items["Columns"]`); the first SubPage added to a Page is auto-activated. Sections (and therefore all component builders) are created on a SubPage via `SubPage:Section({...})`.

**Constructor:** `Page:SubPage(Params) -> SubPage`

Defined as `Library.SubPage = function(Self, Params)`; `Self` is the parent Page returned by `Window:Page(...)`. Conventionally called as `Page:SubPage({...})`.

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| Icon | string | `"rbxassetid://134546249616852"` | Icon shown in the SubPage tab button. Also accepts the lowercase alias `Params.icon`. Accepts either a Roblox asset id string (e.g. `"rbxassetid://123"`, detected via `IsAssetId`, rendered as an `ImageLabel` created with `GetAssetImage`) or a lucide icon string (e.g. `"lucide:crown"`, rendered via `ApplyIconToContainer` / `ResolveIconImage`). If a lucide icon fails to resolve it falls back to an empty `ImageLabel`. |
| Name | string | `""` (empty string) | Text label rendered beneath the icon in the tab (`TextLabel`, TextSize 10, GothamMedium). Also accepts the lowercase alias `Params.name`. The NameLabel is only created when `Page.DisplayName` is truthy **and** `Page.Name` is a non-empty string (`#Page.Name > 0`). |
| DisplayName | boolean | `true` | Controls whether the name label is shown under the icon. Also accepts the lowercase alias `Params.displayName`. Read with an explicit nil-check: `(Params.DisplayName ~= nil and Params.DisplayName) or (Params.displayName ~= nil and Params.displayName) or true`. Because of the `or true` fallback it defaults to true, so to hide the label you must pass `DisplayName = false` explicitly. Even when true the label only appears if `Name` is non-empty. |

### Methods

- `SubPage:Turn(Bool: boolean)` — Activates (`Bool = true`) or deactivates (`Bool = false`) this SubPage and sets `Page.Active = Bool`. When activating it tweens the shadow in (`ImageTransparency 0.7`), enables the icon accent `UIGradient`, sets the icon (and NameLabel, if present) to white/opaque, enables the NameLabel accent gradient, and (after `FadeDescendants`) parents this SubPage's content Frame into `Page.Page.Items["Columns"].Instance`; if `Page.Page.Search` is set it also records `Page.Page.CurrentPage = Page`. When deactivating it dims the shadow/icon/label back to theme colors, disables the gradients, and after `Library.Animation.Time` reparents the content Frame back to `Library.UnusedHolder` (guarded by re-checking `Page.Active`). Guarded by an internal `Debounce` local so overlapping calls return early. Driven internally by clicking the tab but exposed publicly. Calling `Turn(true)` directly does **not** `Turn(false)` the other SubPages.

### Callback

None. `SubPage` takes no `Callback` and exposes no user-facing change/selection callback; interaction is via clicking the tab (`MouseButton1Down` on `Items["Inactive"]`), which iterates `Page.Page.SubPages` and calls `Value:Turn(Value == Page)`.

### Returns

Returns the SubPage table (the local `Page`) with the Library metatable attached via `setmetatable(Page, Library)`, so all Library builder methods (notably `:Section`) are callable on it. The table stores `Window = Self.Window`, `Page = Self` (the parent Page), `ColumnsData` (the two column instances), `Items` (all created instances), `Switching = false` and `Active = false`. It is appended to its parent Page's `SubPages` array via `table.insert(Page.Page.SubPages, Page)`. It is **not** registered under any `.Flag` and is not stored in a global flags table.

### Gotchas

- Created from a Page (the object returned by `Window:Page`), not directly from the global Library in normal usage. The constructor parents the tab button into `Page.Page.Items["SubPages"].Instance`, so that Page must already exist.
- The first SubPage added to a Page is automatically activated: if `#Page.Page.SubPages == 0` at creation time, `Page:Turn(true)` is called **before** the SubPage is inserted into the `SubPages` array.
- Each SubPage provides exactly two content columns: `ColumnsData[1] = LeftColumn.Instance`, `ColumnsData[2] = RightColumn.Instance`. Section indexes these via `Section.Side`.
- `DisplayName` defaults to true and uses an explicit nil-check with an `or true` fallback, so pass `DisplayName = false` to suppress the name label. A label is only created when `DisplayName` is truthy **and** `Name` is a non-empty string.
- Clicking a SubPage tab iterates `Page.Page.SubPages` and calls `Value:Turn(Value == Page)`; if the clicked SubPage is already `Active` the loop returns early (no-op).
- `Icon` supports both Roblox asset ids (rendered as an `ImageLabel`) and lucide icons (resolved via `ApplyIconToContainer` / `ResolveIconImage`); a failed lucide resolve falls back to an empty `ImageLabel`.
- The content area uses a horizontal `UIListLayout` with `HorizontalFlex Fill` so the Left and Right columns split the width 50/50.

### Example

```lua
local CombatPage = Window:Page({ Name = "Combat", Icon = "rbxassetid://111233133354469" })

-- A SubPage with an icon and a visible name label
local CombatSubPage = CombatPage:SubPage({
    Name = "Combat",
    Icon = "lucide:crown",
    DisplayName = true,
})

-- An icon-only SubPage (no label)
local MovementSubPage = CombatPage:SubPage({
    Icon = "rbxassetid://134546249616852",
    DisplayName = false,
})

-- Build Sections on the SubPage, then components on the Section
local LeftSection = MovementSubPage:Section({ Name = "Movement", Side = 1 })
```

---

**See also:** [Page](./page.md) · [Section](./section.md) · [Layout overview](../pages-and-sections.md) · [Theming](../theming.md) · [Config & Flags](../config-and-flags.md) · [API Reference](../api-reference.md) · [Index](../../README.md)