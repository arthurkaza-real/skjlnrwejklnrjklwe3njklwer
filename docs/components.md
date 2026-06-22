# Input Components

The interactive controls users actually manipulate. Each is built by calling the matching
builder method on a [Section](elements/section.md), returns a fluent object, and (where it has a
`Flag`) mirrors its value into `Library.Flags`. Each has its own page with its full argument
table and methods:

| Component | Builder | What it does |
| --- | --- | --- |
| [Toggle](elements/toggle.md) | `Section:Toggle(Params)` | A boolean on/off switch; can also host a [Colorpicker](elements/colorpicker.md) / [Keybind](elements/keybind.md). |
| [Button](elements/button.md) | `Section:Button(Params)` | A clickable action button (callback receives no arguments). |
| [Slider](elements/slider.md) | `Section:Slider(Params)` | A numeric slider with min/max, decimals, suffix, and +/- steppers. |
| [Textbox](elements/textbox.md) | `Section:Textbox(Params)` | A text input with placeholder, numeric-only, and commit-on-finish modes. |

> For value storage and external setters see [Config & Flags](config-and-flags.md); for the
> inline picker sub-elements a Toggle can host see [Pickers](pickers.md); for accent/overlay
> colors see [Theming](theming.md). Static [Label](elements/label.md) rows and other read-only
> elements live under [Display elements](display-elements.md).

## See also

[Pickers](pickers.md) · [Display elements](display-elements.md) · [Pages & Sections](pages-and-sections.md) · [Theming](theming.md) · [Config & Flags](config-and-flags.md) · [API Reference](api-reference.md) · [Index](../README.md)
