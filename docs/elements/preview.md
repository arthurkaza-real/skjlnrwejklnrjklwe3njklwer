# Preview

A passive display container that creates a bordered, rounded canvas frame (with an optional title label above it) into which the caller parents their own Roblox GUI instances. It exposes the raw inner Canvas Roblox Frame via the returned object's `.Canvas` field, and provides methods to resize the canvas height and clear all canvas children. Useful for embedding custom-rendered content (ESP previews, viewports, drawings) inside a Section.

**Constructor:** `Section:Preview(Params) -> Preview object`

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| Name | string | `"Preview"` | The title text shown in a small left-aligned label above the canvas. Also accepts `Params.name`. If set to an empty string (or omitted as empty), no label `TextLabel` is created (the label is only built when `Name` is non-nil and not `""`). |
| Height | number | `140` | The pixel height of the inner Border/canvas area. Also accepts `Params.height`. The outer container is sized to `UDim2.new(1,0,0,16 + Height)` (16px reserved above for the label row); the Border is sized to `Height`. |

### Methods

- `Preview:SetHeight(H)` — Resizes the preview to a new pixel height `H` (number). Sets `Preview.Height = H`, updates the outer container size to `UDim2.new(1,0,0,16 + H)`, and updates the Border size to `UDim2.new(1,0,0,H)`. Does not return a value.
- `Preview:Clear()` — Iterates `Preview.Canvas:GetChildren()` and calls `:Destroy()` on each, emptying the canvas. Takes no arguments and returns nothing.

### Callback

n/a — Preview has no `Callback` field and never invokes one.

### Returns

Returns the Preview object via `setmetatable(Preview, Library)`, so it inherits the full Library builder API. Exposes `Preview.Canvas` (the raw Roblox Frame Instance of the inner clipping canvas, `ClipsDescendants = true`, inset 2px on each side) for parenting custom GUIs. **NOT** registered in any `Flags` or `SetFlags` table; no premium tracking. The object also carries `Preview.Name`, `Preview.Height`, `Preview.Window`, `Preview.Page`, `Preview.Section`, and `Preview.Items` (table of internal Items: `Preview`, optional `Label`, `Border`, `Canvas`).

### Gotchas

- Has no Flag and no Callback; purely a passive display container.
- `Preview.Canvas` is the public field to parent custom GUI instances into; it is a clipping (`ClipsDescendants = true`) Frame inset 2px on each side inside the bordered area (`Size UDim2.new(1,-4,1,-4)`, `Position UDim2.new(0,2,0,2)`).
- The Label is only created when `Preview.Name` is non-nil and not the empty string; an empty `Name` suppresses the title.
- The outer container height is always `16 + Height` (the extra 16px is the label row), even when no label is shown.
- The inner Canvas Frame is the only internal Item with a real Name (`"Canvas"`); all other internal instances use the obfuscated `"\0"` name.

### Example

```lua
local Preview = Section:Preview({
    Name = "ESP Preview",
    Height = 180,
})

-- Parent your own GUI into the canvas
local box = Instance.new("Frame")
box.Size = UDim2.new(0, 50, 0, 50)
box.Parent = Preview.Canvas

Preview:SetHeight(220)
Preview:Clear()
```

---

**See also:** [Label](./label.md) · [Status](./status.md) · [Paragraph](./paragraph.md) · [List](./list.md) · [Display overview](../display-elements.md) · [Theming](../theming.md) · [Config & Flags](../config-and-flags.md) · [API Reference](../api-reference.md) · [Index](../../README.md)
