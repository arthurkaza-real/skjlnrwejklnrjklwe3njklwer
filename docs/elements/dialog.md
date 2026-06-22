# Dialog (Window:Dialog)

Creates a single modal dialog (350px wide, `AutomaticSize.Y` height, accent `UIStroke` border) centered over a dimmed, click-blocking `DialogBackground` overlay (`BackgroundTransparency` 0.2). It renders a Title and Description from the `Data` table and a horizontal fill-flexed button row. The dialog's descendants fade in for a smooth appearance. Any previously open dialog is destroyed first via `:_DestroyNow` (one dialog at a time). Use the returned `Prompt` to add buttons, a textbox, a secondary text link, or to dismiss it.

**Builder:** `Window:Dialog(Data) -> Prompt object`

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| Title | string | none | Heading text shown at top of the dialog (TextLabel, top-left aligned, wrapped). Read as `Data.Title` only (no lowercase alias). RichText is **not** enabled on this label. |
| Description | string | none | Body text under the title (TextTransparency 0.5, top-left aligned, wrapped). Read as `Data.Description` only (no lowercase alias). |

### Methods

The returned `Prompt` object (also stored as `Window.CurrentDialog`) exposes:

- `Prompt:AddButton(Name: string, Callback: function) -> table` — Adds a fill-flexed accent-gradient button (LayoutOrder via the Buttons row) with `Name` as its label. On `MouseButton1Down` it plays a press animation (tweens the inner button width to 0 then back), invokes `Callback` via `Library:SafeCall` with no arguments, then calls `Prompt:Exit()` to close the dialog. Returns the internal `ButtonItems` table.
- `Prompt:AddTextbox(Placeholder: string, Callback: function) -> table` — Adds a single-line input row (LayoutOrder 3) using `Placeholder` as `PlaceholderText` (`ClearTextOnFocus = false`). `Callback` fires on every Text change (`GetPropertyChangedSignal('Text')`) via `Library:SafeCall` and receives the current text string (only if `Callback` is non-nil). Returns a `TextboxItems` table with a `:Get()` method returning the live text.
- `Prompt:AddSecondaryAction(Text: string, Callback: function) -> Library object` — Adds a small accent-colored, text-only link (LayoutOrder 5, e.g. `'Bought a key?'`). On `MouseButton1Down` it invokes `Callback` via `Library:SafeCall` with no arguments (only if `Callback` is non-nil) and does **NOT** close the dialog. Returns the created `TextButton` (Library wrapper object).
- `Prompt:Exit()` — Dismisses the dialog: if it is still the `CurrentDialog`, clears `Window.CurrentDialog`, then `FadeDescendants(false)` on the dialog frame and destroys it on completion. If no dialog remains, tweens the dim overlay's `BackgroundTransparency` to 1 and, after `Library.Animation.Time + 0.05`, hides `DialogBackground` and resets its transparency to 0.2. Called automatically after an `AddButton` press.

### What the Callback receives

- **`AddButton` Callback:** called with **no arguments** (via `Library:SafeCall`), then `Exit()` runs automatically.
- **`AddTextbox` Callback:** called with the **current text (string)** on every change (via `Library:SafeCall`), only when non-nil.
- **`AddSecondaryAction` Callback:** called with **no arguments** (via `Library:SafeCall`), only when non-nil; the dialog stays open.

### Gotchas

> Only one dialog can be open at once. Calling `Window:Dialog` again destroys the current one (via the internal `:_DestroyNow`) before opening the new one.

- `AddButton` automatically closes the dialog after the callback; `AddSecondaryAction` does **NOT** close it.
- `Title`/`Description` are read strictly as `Data.Title` and `Data.Description` — no lowercase aliases, unlike most Window params.
- Buttons share the row evenly via `UIListLayout` `FillDirection.Horizontal` + `HorizontalFlex = UIFlexAlignment.Fill` (8px padding).
- Click handlers fire on `MouseButton1Down` (not `MouseButton1Click`).
- The textbox `:Get()` returns the live text and does not clear on focus (`ClearTextOnFocus = false`).
- `Prompt:_DestroyNow()` is an internal helper (clears `CurrentDialog` and immediately destroys the frame) used by the library — it is **not** part of the public API.

### Example

```lua
local Prompt = Window:Dialog({
    Title = "Redeem Key",
    Description = "Enter your premium key below."
})

local Box = Prompt:AddTextbox("Paste key here...", function(Text)
    print("current:", Text)
end)

Prompt:AddButton("Confirm", function()
    print("entered:", Box:Get())
end)

Prompt:AddButton("Cancel", function()
    print("cancelled")
end)

Prompt:AddSecondaryAction("Bought a key?", function()
    print("open purchase link")
end)
```

---

**See also:** [Notification (Window:Notify)](./notify.md) · [Dialog overview](../dialogs-and-notifications.md) · [Theming](../theming.md) · [Config & Flags](../config-and-flags.md) · [API Reference](../api-reference.md) · [Index](../../README.md)
