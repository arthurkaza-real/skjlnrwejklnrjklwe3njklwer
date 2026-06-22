# Paragraph

A simple wrapping text block for multi-line descriptive text. The constructor creates an auto-height (`AutomaticSize.Y`) frame under `Items["Paragraph"]` containing a single full-width `TextLabel` under `Items["Text"]` that is `TextWrapped`, top-left aligned (`TextXAlignment.Left`, `TextYAlignment.Top`), and theme-bound `TextColor3 = 'Text'`. Unlike Status it has no `Statuses` container and no `AddStatus` method; it is a static (but updatable) paragraph. Registered in the page search index (by `Name`) when the parent page has Search enabled.

**Constructor:** `Section:Paragraph(Params) -> Paragraph object (setmetatable to Library)`

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| Name | string | `"Paragraph"` | The paragraph body text. Read as `Params.Name` or `Params.name` (lowercase alias). At the end of construction the element calls `SetText(Paragraph.Name)` to initialize its text. |

### Methods

- `Paragraph:SetText(Text)` — Sets the label text to `tostring(Text)` by assigning `Items["Text"].Instance.Text`. The label is `TextWrapped`, so long strings wrap to multiple lines and the frame auto-grows in Y.
- `Paragraph:SetVisibility(Bool)` — Shows or hides the whole paragraph frame by setting `Items["Paragraph"].Instance.Visible = Bool`. Unlike `Status:SetVisibility` this is correct and functional. Takes a boolean.

### Callback

n/a — Paragraph takes no `Callback`.

### Returns

Returns the Paragraph table via `setmetatable(Paragraph, Library)`. Fields: `Name`, `Window`, `Page`, `Section`, `Items` (table of created Instance wrappers: `Paragraph`, `Text`). No `.Flag` and no global registration.

### Gotchas

- Difference vs [Status](./status.md): Paragraph has **no** `AddStatus` method and **no** `Statuses` sub-container; its single label is `TextWrapped`, auto-height, top-left aligned for long body text, whereas Status uses a fixed-height title plus a list of status lines.
- `Paragraph:SetVisibility` correctly toggles `Items["Paragraph"]` (the frame); `Status:SetVisibility` is bugged (references a nonexistent `Items["Label"]`).
- Default `Name` is `"Paragraph"` (Status defaults to `"Label"`).
- When the parent page has Search enabled (`Page.Page.Search`), a `SearchData {Item = Items["Paragraph"], Name = Paragraph.Name}` is inserted into `Page.Page.SearchItems`.

### Example

```lua
local Para = Section:Paragraph({ Name = "This is a long descriptive paragraph that wraps across multiple lines." })
Para:SetText("Updated description text.")
Para:SetVisibility(false)
```

---

**See also:** [Label](./label.md) · [Status](./status.md) · [List](./list.md) · [Preview](./preview.md) · [Display overview](../display-elements.md) · [Theming](../theming.md) · [Config & Flags](../config-and-flags.md) · [API Reference](../api-reference.md) · [Index](../../README.md)
