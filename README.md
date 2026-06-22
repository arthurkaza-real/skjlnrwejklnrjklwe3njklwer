# UI Library

A single-file, fluent Roblox UI library for script menus — draggable/resizable window, paged
navigation, a full set of input components, rich **pickers** (Colorpicker, Keybind, Dropdown),
a live theme editor, config save/load with autoload, a premium-key gate, notifications,
dialogs, and a Discord-webhook page.

Everything lives in [`ui.lua`](ui.lua). Loading it returns a single `Library` table — every
builder method hangs off of it, and the same instance is also exposed at `getgenv().Library`.

> Original credit: *“Made by samet.”* This repository documents the public API of `ui.lua`.

---

## Installation

```lua
local Library = loadstring(game:HttpGet("https://your-url/ui.lua"))()
-- after it has run once, the same table is also available globally:
-- local Library = getgenv().Library
```

The script has a **re-run guard** at the top: re-executing it calls the previous build's
`Library:Exit()` first, so you never stack duplicate UIs. Call `Library:Exit()` yourself to
tear everything down.

See **[Getting Started](docs/getting-started.md)** for the full walkthrough (global, icons,
your first menu).

---

## The hierarchy

You build top-down; each level is created off the object the level above returns.

```
Library:Window(Params)            -> Window      -- the draggable/resizable frame
  Window:Page(Params)             -> Page        -- left-rail entry (icon + name)
    Page:SubPage(Params)          -> SubPage     -- tab strip inside a page
      SubPage:Section(Params)     -> Section     -- a column container (Side = 1 left / 2 right)
        Section:Toggle(Params)    -> Toggle      -- components are built on a Section
        Section:Slider(Params)    -> Slider
        Section:Dropdown(Params)  -> Dropdown
        ... etc.
```

There is **no `:Tab` method** — the levels are `Page → SubPage → Section`.

Special pages off the Window: `Window:CreateSettingsPage()`, `Window:WebhookPage(Params)`.

---

## Quick start

```lua
local Library = loadstring(game:HttpGet("https://your-url/ui.lua"))()

local Window = Library:Window({
    Name = '<font color="rgb(175, 102, 126)">my.</font>hub',  -- RichText title
    Logo = "lucide:home",
})

local Combat = Window:Page({ Name = "Combat", Icon = "lucide:swords" })
local Main   = Combat:SubPage({ Name = "Main" })

local Left  = Main:Section({ Name = "Aimbot", Side = 1 })   -- left column
local Right = Main:Section({ Name = "Misc",   Side = 2 })   -- right column

local aimbot = Left:Toggle({
    Name = "Enabled",
    Flag = "AimbotEnabled",   -- a Flag makes it persistable
    Default = false,
    Callback = function(on) print("aimbot:", on) end,
})

-- attach a keybind onto the toggle
aimbot:Keybind({ Flag = "AimbotKey", Default = Enum.KeyCode.E, Mode = "Hold" })

Left:Slider({
    Name = "FOV", Flag = "AimbotFOV",
    Default = 90, Min = 0, Max = 360, Decimals = 0, Suffix = "°",
    Callback = function(v) print("fov:", v) end,
})

Right:Dropdown({
    Name = "Target Part", Flag = "TargetPart",
    Items = { "Head", "Torso", "HumanoidRootPart" },
    Default = "Head",
    Callback = function(v) print("target:", v) end,
})

-- attach a colorpicker onto a label
Right:Label({ Name = "ESP Color" }):Colorpicker({
    Flag = "EspColor", Default = Color3.fromRGB(255, 0, 0), Alpha = 1,
    Callback = function(color, alpha) print(color, alpha) end,
})

-- a settings page with config + theme editors
local Settings = Window:CreateSettingsPage()
Settings:CreateConfigsSection()
Settings:CreateThemingSection()

-- restore the saved autoload config — call this LAST, after the whole UI is built
Library:CheckForAutoLoad()
```

---

## Component catalog

Every element has its own page with its full parameter table and methods. Grouped by category
(category hubs in **bold**):

| Element | Builder | Category | Page |
| --- | --- | --- | --- |
| Window | `Library:Window(Params)` | Window | [window.md](docs/window.md) |
| Page | `Window:Page(Params)` | **[Layout](docs/pages-and-sections.md)** | [page.md](docs/elements/page.md) |
| SubPage | `Page:SubPage(Params)` | **[Layout](docs/pages-and-sections.md)** | [subpage.md](docs/elements/subpage.md) |
| Section | `SubPage:Section(Params)` | **[Layout](docs/pages-and-sections.md)** | [section.md](docs/elements/section.md) |
| Toggle | `Section:Toggle(Params)` | **[Input](docs/components.md)** | [toggle.md](docs/elements/toggle.md) |
| Button | `Section:Button(Params)` | **[Input](docs/components.md)** | [button.md](docs/elements/button.md) |
| Slider | `Section:Slider(Params)` | **[Input](docs/components.md)** | [slider.md](docs/elements/slider.md) |
| Textbox | `Section:Textbox(Params)` | **[Input](docs/components.md)** | [textbox.md](docs/elements/textbox.md) |
| **Colorpicker** | `Toggle:Colorpicker(Data)` / `Label:Colorpicker(Data)` | **[Picker](docs/pickers.md)** | [colorpicker.md](docs/elements/colorpicker.md) |
| **Keybind** | `Toggle:Keybind(Data)` / `Label:Keybind(Data)` | **[Picker](docs/pickers.md)** | [keybind.md](docs/elements/keybind.md) |
| **Dropdown** | `Section:Dropdown(Params)` | **[Picker](docs/pickers.md)** | [dropdown.md](docs/elements/dropdown.md) |
| Label | `Section:Label(Params)` | **[Display](docs/display-elements.md)** | [label.md](docs/elements/label.md) |
| Status | `Section:Status(Params)` | **[Display](docs/display-elements.md)** | [status.md](docs/elements/status.md) |
| Paragraph | `Section:Paragraph(Params)` | **[Display](docs/display-elements.md)** | [paragraph.md](docs/elements/paragraph.md) |
| List | `Section:List(Params)` | **[Display](docs/display-elements.md)** | [list.md](docs/elements/list.md) |
| Preview | `Section:Preview(Params)` | **[Display](docs/display-elements.md)** | [preview.md](docs/elements/preview.md) |
| Dialog | `Window:Dialog(Data)` | **[Dialog](docs/dialogs-and-notifications.md)** | [dialog.md](docs/elements/dialog.md) |
| Notification | `Window:Notify(Data)` | **[Dialog](docs/dialogs-and-notifications.md)** | [notify.md](docs/elements/notify.md) |
| Settings page | `Window:CreateSettingsPage()` | Settings | [settings-and-premium.md](docs/settings-and-premium.md) |
| Webhook page | `Window:WebhookPage(Params)` | Webhook | [webhooks.md](docs/webhooks.md) |

> **Pickers** are the headline feature: the Colorpicker and Keybind are *attached* onto an
> existing Toggle or Label (never created standalone), while the Dropdown is its own component
> with single- and multi-select modes. See [colorpicker.md](docs/elements/colorpicker.md),
> [keybind.md](docs/elements/keybind.md), and [dropdown.md](docs/elements/dropdown.md).

---

## Documentation

- **[Getting Started](docs/getting-started.md)** — install, the `getgenv` global, icon formats, your first menu.
- **[Window](docs/window.md)** — `Library:Window` params, window controls, the keybind tab, premium overview.
- **[Pages, SubPages & Sections](docs/pages-and-sections.md)** — the layout hierarchy and column `Side` (one page each: [Page](docs/elements/page.md), [SubPage](docs/elements/subpage.md), [Section](docs/elements/section.md)).
- **[Input Components](docs/components.md)** — one page each: [Toggle](docs/elements/toggle.md), [Button](docs/elements/button.md), [Slider](docs/elements/slider.md), [Textbox](docs/elements/textbox.md).
- **[Pickers](docs/pickers.md)** — one page each: [Colorpicker](docs/elements/colorpicker.md), [Keybind](docs/elements/keybind.md), [Dropdown](docs/elements/dropdown.md).
- **[Display Elements](docs/display-elements.md)** — one page each: [Label](docs/elements/label.md), [Status](docs/elements/status.md), [Paragraph](docs/elements/paragraph.md), [List](docs/elements/list.md), [Preview](docs/elements/preview.md).
- **[Dialogs & Notifications](docs/dialogs-and-notifications.md)** — one page each: [Dialog](docs/elements/dialog.md), [Notification](docs/elements/notify.md).
- **[Config & Flags](docs/config-and-flags.md)** — the Flag system, save/load, autoload, config sections.
- **[Theming](docs/theming.md)** — theme keys, `ChangeTheme`, the live theme editor.
- **[Settings Page & Premium](docs/settings-and-premium.md)** — `CreateSettingsPage` and the premium-key gate.
- **[Discord Webhooks](docs/webhooks.md)** — `Window:WebhookPage` and webhook sections.
- **[API Reference](docs/api-reference.md)** — flat cheat sheet of every builder, argument, and method.

---

## Conventions you'll see everywhere

- **Argument tables.** Every builder takes one table. Most fields accept a lowercase alias too
  (e.g. `Name`/`name`, `Flag`/`flag`, `Default`/`default`, `Callback`/`callback`).
- **Flags.** Give a component a `Flag` string and its value is mirrored into `Library.Flags[Flag]`
  and a setter is registered in `SetFlags[Flag]`. This is what config save/load and autoload use.
  If you omit `Flag`, most components fall back to the `Name`. See [Config & Flags](docs/config-and-flags.md).
- **Icons.** Any `Icon`/`Logo` string accepts `"lucide:<name>"`, `"rbxassetid://<id>"`, or a bare
  numeric id `"123456"`. See [Getting Started → Icons](docs/getting-started.md#icons).
- **Premium / Disabled.** Most components accept `Premium = true` (gated behind a premium key) and
  `Disabled = true` (interaction blocked). `Disabled` also reads `Disable`/`disable`/`disabled`.
- **Theme keys.** Colors come from `Library.Theme` — index space-containing keys as strings, e.g.
  `Library.Theme["Accent Start"]`. See [Theming](docs/theming.md).

---

## Teardown

```lua
Library:Exit()   -- disconnects all connections, closes threads, destroys the ScreenGuis, clears getgenv().Library
```
