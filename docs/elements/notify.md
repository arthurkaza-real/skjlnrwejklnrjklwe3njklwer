# Notification (Window:Notify)

Spawns a toast-style notification card inside the window's `NotificationHolder`. It shows a GothamBold title and a word-wrapped Gotham description, animates in over 0.3s (background/stroke/text fade), and draws a bottom accent-gradient progress bar that drains linearly over `Duration` seconds. After `Duration` elapses the card fades out over 0.3s, waits 0.35s, then destroys itself. Colors pull from `Library.Theme` with hardcoded fallbacks.

**Builder:** `Window:Notify(Data) -> NotifFrame (raw Roblox Frame Instance)`

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| Title | string | `"Notification"` | Bold header text (GothamBold, size 14). Read only as `Data.Title` (no lowercase alias). |
| Description | string | `""` (empty string) | Body text under the title (Gotham, size 12), `TextWrapped` with `AutomaticSize.Y`. Read only as `Data.Description` (no lowercase alias). |
| Duration | number | `5` | Seconds the card stays before auto-dismiss. Also drives the linear progress-bar drain (TweenInfo of length `Duration`). Read only as `Data.Duration` (no lowercase alias). |
| Icon | string | `"bell"` | Captured into a local (`local Icon = Data.Icon or "bell"`) but **NEVER** rendered or referenced afterward in this implementation. No effect. Read only as `Data.Icon` (no lowercase alias). |

### Methods

None. `Window:Notify` returns the created `NotifFrame` (a **raw Roblox Frame Instance**, not a wrapped library object). The frame self-destroys ~`Duration + 0.35s` after creation.

### What the Callback receives

`Notify` takes **no callback** — it is purely declarative.

### Gotchas

> `Data` defaults to `{}` if omitted, so `Window:Notify()` with no args is valid and shows a default `'Notification'` toast for 5 seconds.

- Unlike most library components, `Notify` does **NOT** use the `Params.Field or Params.field` lowercase-alias convention; fields are read only in TitleCase.
- The `Icon` field is parsed but has **no effect** in this version — do not rely on it.
- Returns a raw Roblox `Frame`; the only safe use of the return value is direct Instance manipulation (it is self-destroying after `Duration`).
- Total lifetime is `task.delay(Duration, ...)` then a 0.3s fade tween plus `task.wait(0.35)` before `:Destroy()`.

### Example

```lua
Window:Notify({
    Title = "Saved",
    Description = "Your config was written to disk.",
    Duration = 4
})
```

---

**See also:** [Dialog (Window:Dialog)](./dialog.md) · [Dialog overview](../dialogs-and-notifications.md) · [Theming](../theming.md) · [Config & Flags](../config-and-flags.md) · [API Reference](../api-reference.md) · [Index](../../README.md)
