# Pages, SubPages & Sections

The three-level layout hierarchy that organizes your UI. The build path always flows top-down:
`Window:Page(...)` → `Page:SubPage(...)` → `SubPage:Section(...)` → component builders such as
`Section:Toggle(...)`. Components are never attached directly to a Page or SubPage — they always
live inside a Section. Each layout element has its own page with its full argument table and methods:

| Element | Builder | What it does |
| --- | --- | --- |
| [Page](elements/page.md) | `Window:Page(Params)` | A top-level entry in the window's left sidebar; hosts SubPages. |
| [SubPage](elements/subpage.md) | `Page:SubPage(Params)` | An icon tab inside a Page; owns the two content columns (left/right). |
| [Section](elements/section.md) | `SubPage:Section(Params)` | A boxed, titled container placed in column `Side` (`1` left / `2` right); holds components. |

## Putting it together: the layout hierarchy

The full chain is `Window:Page` → `Page:SubPage` → `SubPage:Section` → component builders:

- **Window** owns the sidebar of **Pages**. The first Page is auto-activated; clicking a sidebar entry calls `Turn` on every Page (one on, the rest off).
- Each **Page** owns a horizontal tab strip of **SubPages** (60px icon buttons). The first SubPage is auto-activated. Clicking a SubPage tab swaps the visible two-column content area.
- Each **SubPage** owns exactly two columns — `ColumnsData[1]` (left) and `ColumnsData[2]` (right) — that split the width 50/50.
- Each **Section** drops into one of those two columns based on `Side` (`1` = left, `2` = right) and stacks its components vertically.

> Components live only inside Sections. A Page or SubPage on its own has no place to put a Toggle,
> Slider, or Dropdown — always go `Page:SubPage(...)` then `SubPage:Section(...)` before calling
> any component builder. See [Theming](theming.md) for how the Accent/Background/Text colors are
> resolved, and [Config & Flags](config-and-flags.md) for why Pages, SubPages, and Sections are
> deliberately **not** registered under any Flag.

## See also

[Window](window.md) · [Input components](components.md) · [Pickers](pickers.md) · [Display elements](display-elements.md) · [Theming](theming.md) · [API Reference](api-reference.md) · [Index](../README.md)
