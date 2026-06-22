# Pickers

Pickers are interactive value-selection controls. Each one now has its own page with its full
argument table and method list:

| Picker | Builder | What it does |
| --- | --- | --- |
| [Colorpicker](elements/colorpicker.md) | `Toggle:Colorpicker(Data)` / `Label:Colorpicker(Data)` | HSV color + alpha picker, **attached** onto a Toggle or Label (never standalone). |
| [Keybind](elements/keybind.md) | `Toggle:Keybind(Data)` / `Label:Keybind(Data)` | Bind a key with a `Toggle`/`Hold`/`Always` mode, **attached** onto a Toggle or Label. |
| [Dropdown](elements/dropdown.md) | `Section:Dropdown(Params)` | A searchable option list, standalone, with single- or multi-select. |

> **Colorpicker** and **Keybind** are never created on their own — you *attach* them onto an
> existing [Toggle](elements/toggle.md) or [Label](elements/label.md). The **Dropdown** is a
> standalone control built on a `Section`. All three persist their value into `Library.Flags`
> under a `Flag` and fire a `Callback` on change — see [Config & Flags](config-and-flags.md).

## See also

[Input components](components.md) · [Display elements](display-elements.md) · [Theming](theming.md) · [Config & Flags](config-and-flags.md) · [API Reference](api-reference.md) · [Index](../README.md)
