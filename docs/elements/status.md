# Status

A labeled display element for showing a title plus a vertical stack of dynamic status lines. The constructor creates a fixed-height (35px, `AutomaticSize.Y`) frame stored under `Items["Paragraph"]`, a title `TextLabel` under `Items["Text"]` (text set from `Name`, theme-bound `TextColor3 = 'Text'`), and an `Items["Statuses"]` container (positioned at `y=18`, vertical `UIListLayout`) that holds status sub-labels added via `AddStatus`. The returned table is internally named `'Paragraph'` and shares `SetText`/`SetVisibility` with [Paragraph](./paragraph.md), but Status additionally exposes `AddStatus` and lays its title above a list of status lines. Registered in the page search index (by `Name`) when the parent page has Search enabled.

**Constructor:** `Section:Status(Params) -> Paragraph object (setmetatable to Library)`

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| Name | string | `"Label"` | Title text shown in the main label at the top of the status element. Read as `Params.Name` or `Params.name` (lowercase alias). At the end of construction the element calls `SetText(Paragraph.Name)` to initialize its title text. |

### Methods

- `Status:AddStatus(Text)` — Creates a new status `TextLabel` (`TextTransparency = 0.5`, theme-bound `TextColor3 = 'Text'`) inside `Items["Statuses"]` and returns it as `NewStatus`. `NewStatus` has its own `:Set(Text)` method that sets `NewStatus.Instance.Text = Text` (no `tostring`). `Text` is the initial string shown.
- `Status:SetText(Text)` — Sets the title label text to `tostring(Text)` by assigning `Items["Text"].Instance.Text`. Called once at construction with `Name`.
- `Status:SetVisibility(Bool)` — Intended to toggle visibility but reads `Items["Label"]`, which Status never creates (the frame is `Items["Paragraph"]`, the label is `Items["Text"]`). As written this indexes nil and errors. This is a source bug; do not rely on it. Takes a boolean.

### Callback

n/a — Status takes no `Callback`.

### Returns

Returns the Paragraph table via `setmetatable(Paragraph, Library)`. Fields: `Name`, `Window`, `Page`, `Section`, `Items` (table of created Instance wrappers: `Paragraph`, `Text`, `Statuses`). No `.Flag` and no global registration.

### Gotchas

- The returned object is internally named `'Paragraph'` even though the constructor is `Library:Status`.
- Default `Name` is `"Label"` (Paragraph defaults to `"Paragraph"`).
- `AddStatus` returns a separate `NewStatus` wrapper whose only injected public method is `:Set(Text)`, which assigns `NewStatus.Instance.Text = Text` directly (no `tostring`, unlike `SetText`).

> `Status:SetVisibility` is bugged: it references `Items["Label"]`, which is never created, so calling it errors. Use [Paragraph](./paragraph.md)'s `SetVisibility` (which correctly toggles `Items["Paragraph"]`) when you need a functional visibility toggle.

- When the parent page has Search enabled (`Page.Page.Search`), a `SearchData {Item = Items["Paragraph"], Name = Paragraph.Name}` is inserted into `Page.Page.SearchItems`.

### Example

```lua
local Status = Section:Status({ Name = "Player Info" })
local Health = Status:AddStatus("Health: 100")
Health:Set("Health: 80")
Status:SetText("Player Info (updated)")
```

---

**See also:** [Label](./label.md) · [Paragraph](./paragraph.md) · [List](./list.md) · [Preview](./preview.md) · [Display overview](../display-elements.md) · [Theming](../theming.md) · [Config & Flags](../config-and-flags.md) · [API Reference](../api-reference.md) · [Index](../../README.md)
