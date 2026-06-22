# Dialogs & Notifications

Two transient UI surfaces created from a [Window](window.md) object. Both read their fields
strictly in TitleCase (no lowercase aliases). Each has its own page with its full argument table
and methods:

| Element | Builder | What it does |
| --- | --- | --- |
| [Dialog](elements/dialog.md) | `Window:Dialog(Data)` | A modal dialog over a dimmed overlay; returns a `Prompt` you add buttons, a textbox, and a secondary action to. |
| [Notification](elements/notify.md) | `Window:Notify(Data)` | A toast card with a title, description, and a draining progress bar that auto-dismisses. |

## See also

[Window](window.md) · [Config & Flags](config-and-flags.md) · [Theming](theming.md) · [API Reference](api-reference.md) · [Index](../README.md)
