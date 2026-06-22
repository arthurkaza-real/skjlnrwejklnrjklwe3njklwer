# Display Elements

Read-only elements that present information rather than collect a value. None register a `Flag`
and (with one noted exception) none take a `Callback`. Each has its own page with its full
argument table and methods:

| Element | Builder | What it does |
| --- | --- | --- |
| [Label](elements/label.md) | `Section:Label(Params)` | A single-row static label that can also host an inline [Colorpicker](elements/colorpicker.md) / [Keybind](elements/keybind.md). |
| [Status](elements/status.md) | `Section:Status(Params)` | A title plus a vertical stack of dynamic status lines (`AddStatus`). |
| [Paragraph](elements/paragraph.md) | `Section:Paragraph(Params)` | A wrapping, auto-height block of descriptive text. |
| [List](elements/list.md) | `Section:List(Params)` | A multi-column, searchable, drag-reorderable table. |
| [Preview](elements/preview.md) | `Section:Preview(Params)` | A bordered canvas you parent your own GUI instances into. |

> For interactive inputs see [Input components](components.md) (Toggle, Button, Slider, Textbox)
> and [Pickers](pickers.md) (Colorpicker, Keybind, Dropdown).

## See also

[Input components](components.md) · [Pickers](pickers.md) · [Theming](theming.md) · [Config & Flags](config-and-flags.md) · [API Reference](api-reference.md) · [Index](../README.md)
