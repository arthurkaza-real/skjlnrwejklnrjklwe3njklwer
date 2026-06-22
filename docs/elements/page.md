# Page

A `Page` is a top-level navigation entry (tab) inside a Window. It renders a clickable entry in the window's Pages sidebar (an icon background, the page name, and a description subtitle) plus an associated content frame that is shown or hidden when the page is selected. The first Page added to a window is auto-activated. Pages host SubPages (via `Page:SubPage`), which in turn host Sections and components. When `Search` is enabled, the page gains a search bar that filters the page's registered `SearchItems` by case-insensitive substring match.

**Constructor:** `Window:Page(Params) -> Page`

The colon call passes the Window as `Self`, which becomes `Page.Window`. (Internally defined as `Library.Page = function(Self, Params)`.)

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| Name | string | `"Page"` | The page's display name shown in the sidebar entry (used as the Text label). Read as `Params.Name` or `Params.name` (lowercase alias supported). |
| Description | string | `"Nigger cupcake"` | Secondary subtitle text shown under the page name in the sidebar entry. Read as `Params.Description` or `Params.description` (lowercase alias supported). The literal default in source is the string `"Nigger cupcake"`. |
| Icon | string | `"rbxassetid://111233133354469"` | The page's icon shown in the sidebar entry's icon container. If `IsAssetId(Icon)` returns true (a Roblox asset id), it is rendered as an `ImageLabel` via `GetAssetImage`; otherwise it is treated as a lucide icon string and applied via `ApplyIconToContainer`, with an empty-image `ImageLabel` fallback if that fails. Read as `Params.Icon` or `Params.icon` (lowercase alias supported). |
| Search | boolean | `false` | When truthy, adds a search bar (frame + TextBox + magnifier icon) near the top of the page content, shifts the Columns content frame down (Position y=115, Size y=-115) to make room, and wires a Text-changed handler that filters `Page.SearchItems` by case-insensitive substring of the typed text (setting each matched item's `Element.Instance.Visible`). Read as `Params.Search` or `Params.search` (lowercase alias supported). |

### Methods

- `Page:Turn(Bool: boolean)` — Activates (`Bool=true`) or deactivates (`Bool=false`) the page. Sets `Page.Active=Bool`; tweens the Columns frame position (different y offsets depending on whether `Search` is enabled), toggles the icon-stroke gradient/stroke color, tweens the Text and Description transparency/color (Accent End when active, Text when inactive), tweens the Inactive entry background, and fades the page descendants. When active it reparents `Items["Page"]` to `Window.Items["Content"]`; when inactive it reparents to `Library.UnusedHolder` after `Library.Animation.Time` (only if still inactive). Has an internal Debounce that ignores re-entrant calls while an animation is running. Clicking a sidebar entry already calls `Turn` on every page in the window (turning the clicked one on, the rest off), so manual calls are rarely needed.

### Callback

None. `Library:Page` does not read a `Callback` field and invokes no user callback. Page selection is handled internally: `Items["Inactive"]:Connect("MouseButton1Down", ...)` iterates `Page.Window.Pages` and calls `Value:Turn(Value == Page)` on each (with an early return if the clicked page is already active).

### Returns

Returns the Page object via `setmetatable(Page, Library)`, so it inherits Library methods such as `:SubPage` and `:Section`. The page is appended to `Window.Pages` with `table.insert`. It is **not** registered under any Flag. The object exposes the fields: `Name`, `Description`, `Icon`, `Search`, `Window` (the owning window passed as `Self`), `SubPages` (table), `Items` (table of created UI instances), `SearchItems` (table populated by searchable components), `CurrentPage` (initially `nil`), and `Active` (boolean, initially `false`).

### Gotchas

- The colon call (`Window:Page(...)`) is what passes the Window as `Self`; calling it without the Window receiver will break `Page.Window`.
- Exactly four argument-table fields are read: `Name`, `Description`, `Icon`, `Search`. No other `Params.X` accesses exist. All four support a lowercase alias (`name`, `description`, `icon`, `search`) via the `or` chain.
- The default `Description` is the literal string `"Nigger cupcake"` and the default `Icon` is the literal `"rbxassetid://111233133354469"`.
- The first page created in a window (when `#Window.Pages == 0`, checked **before** the `table.insert`) is auto-activated via `Page:Turn(true)`.
- Only one public method exists on the Page object: `Page:Turn(Bool)`. There is no `Page:Section` / `Page:SubPage` defined on the Page itself — `:SubPage` and `:Section` are inherited from the Library metatable.
- `Icon` supports both Roblox asset ids (rendered as `ImageLabel`) and lucide icon strings (rendered via `ApplyIconToContainer` with an empty-`ImageLabel` fallback); branching uses the `IsAssetId` helper.
- Search filtering operates on `Page.SearchItems` entries (each having `.Name` and `.Item`); these are populated internally by searchable components, not by the Page constructor.
- The sidebar click is bound to the `MouseButton1Down` event of the Inactive `TextButton` entry, not a generic click event.
- Components are **not** attached directly to a Page: create a SubPage with `Page:SubPage(Params)`, then add Sections to the SubPage and components to those Sections.

### Example

```lua
local Window = Library:Window({ Name = "My UI" })

local Combat = Window:Page({
    Name = "Combat",
    Description = "combat page",
    Icon = "lucide:house",
    Search = false,
})

-- Pages host SubPages, which host Sections and components
local CombatSub = Combat:SubPage({ Icon = "rbxassetid://134546249616852" })
local Section = CombatSub:Section({ Name = "Section", Side = 1 })

Section:Toggle({
    Name = "Toggle",
    Flag = "Toggle",
    Default = false,
    Callback = function(Value)
        print(Value)
    end
})

-- Manually switch to this page (usually done automatically on sidebar click)
Combat:Turn(true)
```

---

**See also:** [SubPage](./subpage.md) · [Section](./section.md) · [Layout overview](../pages-and-sections.md) · [Theming](../theming.md) · [Config & Flags](../config-and-flags.md) · [API Reference](../api-reference.md) · [Index](../../README.md)
