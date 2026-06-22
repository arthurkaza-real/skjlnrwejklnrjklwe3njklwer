# List

A multi-column, searchable, drag-reorderable list/table display. On construction it `Destroy`s the page's `RightColumn` and sets the `LeftColumn`'s `UIPadding` `PaddingRight` to `UDim.new(0,15)` so the list spans the full page width, then builds a 250px container holding: a 200px `ScrollingFrame` rows holder (`AutomaticCanvasSize.Y`, vertical `UIListLayout`, rounded, Inline stroke), a bottom Fade frame with a vertical `UIGradient`, and a 35px Search frame containing a `TextBox` (`PlaceholderText` `'Search..'`) and a search `ImageLabel` icon. Each entry of `Items` becomes a row via `List:Add`, and each column value in a row is added via `row:AddStat`. Rows alternate themes (even rows `'Inline'`, odd rows `'Background'`), are drag-reorderable (swap `LayoutOrder` while held), and are live-filtered by case-insensitive substring match of the search text against each row's `Name`.

**Constructor:** `Section:List(Params) -> List object (setmetatable to Library)`

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| Items | table&lt;table&lt;string&gt;&gt; | `{}` (empty table) | Array of rows; each row is itself an array of column strings. Read as `Params.Items` or `Params.items` (lowercase alias), stored as `List.ListItems`. For each row the constructor calls `List:Add(row[1])` (using the FIRST element as the row's Name/search key), then iterates the ENTIRE row (`for _, Value2 in Value`) calling `NewStat:AddStat(Value2)`, so the first element is rendered as a visible column in addition to being the Name. Example row: `{"Alice", "100", "Online"}` renders three columns and uses `"Alice"` as the search key. |
| Callback | function | `function() end` (no-op) | Read as `Params.Callback` or `Params.callback` (lowercase alias) and stored as `List.Callback`. NOTE: in this source `List.Callback` is never invoked anywhere in the constructor or any method (drag, search, and add logic never call it), so it is inert as written. |

### Methods

- `List:Add(Name)` — Creates and appends a row `TextButton` to `Items["Holder"]` using `Name` as the row's Name (search key). Alternates `BackgroundColor3`/theme by current `#List.Items` parity (even -> `'Inline'`, odd -> `'Background'`), rounds the first row (when `#List.Items == 0`) and adds a bottom cover frame, and builds a horizontal-flex `StatHolder` (`HorizontalFlex` Fill) with 10px side padding. Inserts the row into `List.Items` and returns the `NewStat` object `{ Name, StatHolder, OrigColor, Button, Order = 0, AddStat }`.
- `NewStat:AddStat(Text)` — Method on the row object returned by `List:Add`. Creates and returns a `TextLabel` column (`AutomaticSize.X`, base `TextColor3` white but theme-bound `TextColor3 = 'Text'`) inside the row's `StatHolder` showing `Text`. Call once per column value.
- `List:GetLabelUnderMouse(MouseY)` — Iterates `List.Items` and returns the row (`NewStat`) whose `Button` vertically contains the absolute `MouseY` (`MouseY` between `AbsolutePosition.Y` and `AbsolutePosition.Y + AbsoluteSize.Y`), or `nil` if none. Used internally by the drag-reorder `InputChanged` handler; also callable publicly.

### Callback

`Params.Callback` is stored as `List.Callback` but is **NOT** invoked anywhere in this source. It receives nothing as written.

### Returns

Returns the List table via `setmetatable(List, Library)`. Fields: `Callback`, `ListItems` (the raw `Items` array), `Window`, `Page`, `Section`, `Options` (`{}`), `Items` (created Instance wrappers: `List`, `Holder`, `Fade`, `Search`, `Input`, `Icon__`). No `.Flag` and no global registration.

### Gotchas

- Construction side effects: `List.Page.Items.RightColumn.Instance:Destroy()` and `List.Page.Items.LeftColumn ... UIPadding.PaddingRight = UDim.new(0,15)` — the list takes over the full page width.
- Row format: each entry of `Items` is a table of column strings. `row[1]` becomes the row Name (search key); the constructor then iterates the whole row calling `AddStat` on each element, so element 1 is rendered as a column in addition to being the Name.
- Drag-reorder: each row `Button` connects `MouseButton1Down` to start dragging and tween to `Theme['Hovered Element']`; a global `InputChanged` (`MouseMovement` or `Touch`) swaps `LayoutOrder` with the row under the cursor via `GetLabelUnderMouse`; `InputEnded` (`MouseButton1` or `Touch`) tweens the row back to `OrigColor` and clears `Dragging`. Supports mouse and touch.
- Search: a `GetPropertyChangedSignal('Text')` handler on `Items["Input"]` filters rows by `string.find(string.lower(Value.Name), string.lower(inputText))`, toggling each row `Button`'s `Visible`.

> The stored `Callback` is inert (never invoked) in this version of the source — do not rely on it firing.

### Example

```lua
local List = Section:List({
    Items = {
        { "Alice", "100", "Online" },
        { "Bob", "87", "Away" },
    },
    Callback = function() end -- note: not invoked in this source
})

-- add a row manually:
local Row = List:Add("Carol")
Row:AddStat("Carol")
Row:AddStat("42")
Row:AddStat("Offline")
```

---

**See also:** [Label](./label.md) · [Status](./status.md) · [Paragraph](./paragraph.md) · [Preview](./preview.md) · [Display overview](../display-elements.md) · [Theming](../theming.md) · [Config & Flags](../config-and-flags.md) · [API Reference](../api-reference.md) · [Index](../../README.md)
