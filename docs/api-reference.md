# API Reference

A flat cheat sheet of every public builder, its argument fields (with defaults), and its
methods. Defaults are the literal source defaults. Most fields also accept a **lowercase alias**
(`Name`/`name`, `Flag`/`flag`, etc.); only exceptions are called out. For full behavior, callback
signatures, and gotchas, follow the per-topic links.

- [Library (top level)](#library-top-level)
- [Window](#window)
- [Layout: Page / SubPage / Section](#layout-page--subpage--section)
- [Input components](#input-components)
- [Pickers](#pickers)
- [Display elements](#display-elements)
- [Dialogs & notifications](#dialogs--notifications)
- [Settings & config sections](#settings--config-sections)
- [Webhooks](#webhooks)
- [Theme keys](#theme-keys)

---

## Library (top level)

`loadstring(game:HttpGet(url))()` → the `Library` table (also at `getgenv().Library`).

| Method | Description |
| --- | --- |
| `Library:Window(Params)` → `Window` | Build the root window. See [Window](#window). |
| `Library:CheckForAutoLoad()` | Restore the saved autoload config. Call **last**, after the whole UI is built. |
| `Library:GetConfig()` → `table` | Snapshot of all current flag values. |
| `Library:LoadConfig(Config)` | Apply a config table (drives every `SetFlags[flag]`). |
| `Library:GetConfigsList()` → `table` | List saved config names on disk. |
| `Library:ChangeTheme(Key, Color)` | Set `Library.Theme[Key]` and recolor live. See [Theming](theming.md). |
| `<wrapped>:AddToTheme(Properties)` | Register an instance for theming. |
| `Library:Exit()` | Tear down: disconnect connections, close threads, destroy ScreenGuis, clear the global. |

Globals worth knowing: `Library.Flags` (live flag values), `Library.Theme` (active colors),
`Library.MenuKeybind` (default `RightControl`), `Library.Directory` (`"AtherHub"`),
`Library.AutoSave` (`true`). Details: [Config & Flags](config-and-flags.md).

---

## Window

`Library:Window(Params)` → `Window`. Details: [window.md](window.md).

| Field | Type | Default |
| --- | --- | --- |
| `Name` | string (RichText) | `'<font color="rgb(175, 102, 126)">ather.</font>hub'` |
| `Logo` | string (icon) | `"rbxassetid://133218922939038"` |
| `Folder` | string | appended to `Library.Directory` |
| `Keybinds` | (see window.md) | — |
| `ScriptId` | string | — (also `scriptId`/`scriptid`) |
| `PurchaseURL` | string | — (also `purchaseURL`/`PurchaseUrl`/`UpgradeURL`) |
| `KeyFile` | string | `Library.Directory .. "/key.txt"` (also `keyfile`) |

**Methods:** `:Page(Params)`, `:CreateSettingsPage()`, `:WebhookPage(Params)`, `:Notify(Data)`,
`:Dialog(Data)`, `:SetOpen(Bool)`, `:Center()`, `:Minimize(Bool)`, `:FullScreen(Bool)`,
`:SetKeybindsTab(Bool)`, `:SetKeybindsTabPosition(Name)`, `:RegisterKeybindEntry(Entry)`,
and the premium gate `:RedeemKey(Key, Label)`, `:CheckPremiumKey(Key)`, `:SetStatus(Type)`,
`:ShowUpgradePrompt(Feature)`, `:ShowKeyRedemptionDialog()` — see [Settings & Premium](settings-and-premium.md).

---

## Layout: Page / SubPage / Section

Hierarchy: `Window:Page → Page:SubPage → SubPage:Section`. Per-element pages: [Page](elements/page.md) · [SubPage](elements/subpage.md) · [Section](elements/section.md) (overview: [pages-and-sections.md](pages-and-sections.md)).

**`Window:Page(Params)` → `Page`**

| Field | Type | Default |
| --- | --- | --- |
| `Name` | string | `"Page"` |
| `Description` | string | — |
| `Icon` | string (icon) | `"rbxassetid://111233133354469"` |
| `Search` | boolean | `false` |

Methods: `Page:Turn(Bool)`, `Page:SubPage(Params)`.

**`Page:SubPage(Params)` → `SubPage`**

| Field | Type | Default |
| --- | --- | --- |
| `Icon` | string (icon) | `"rbxassetid://134546249616852"` |
| `Name` | string | `""` |

Methods: `SubPage:Section(Params)`.

**`SubPage:Section(Params)` → `Section`**

| Field | Type | Default |
| --- | --- | --- |
| `Name` | string | `"Section"` |
| `Side` | number | `1` (`1` = left column, `2` = right column) |

The `Section` is what you call all component builders on (`:Toggle`, `:Slider`, `:Dropdown`, …).

---

## Input components

All on a `Section`. Per-element pages: [Toggle](elements/toggle.md) · [Button](elements/button.md) · [Slider](elements/slider.md) · [Textbox](elements/textbox.md) (overview: [components.md](components.md)). Common optional fields:
`Premium` (boolean, `false`), `Disabled` (boolean, `false`; also `Disable`/`disable`/`disabled`).

**`Section:Toggle(Params)` → `Toggle`**

| Field | Type | Default |
| --- | --- | --- |
| `Name` | string | `"Toggle"` |
| `Flag` | string | = `Name` |
| `Default` | boolean | `false` |
| `Callback` | `function(value: boolean)` | — |

Methods: `:Set(Bool)`, `:SetText(Text)`, `:SetVisibility(Bool)`, `:UpdateDisable(State)`,
`:UpdatePrem(State)`, `:SetKey(Key)`, `:SetKeyMode(Mode)`, and the picker hosts
`:Colorpicker(Data)` / `:Keybind(Data)` (see [Pickers](pickers.md)).

**`Section:Button(Params)` → `Button`**

| Field | Type | Default |
| --- | --- | --- |
| `Name` | string | `"Button"` |
| `Callback` | `function()` | — (no arguments) |

Methods: `:Press()`, `:SetText(Text)`, `:SetVisibility(Bool)`, `:UpdateDisable(State)`.

**`Section:Slider(Params)` → `Slider`**

| Field | Type | Default |
| --- | --- | --- |
| `Name` | string | `"Slider"` |
| `Flag` | string | = `Name` |
| `Default` | number | `0` |
| `Min` | number | `0` |
| `Max` | number | `100` |
| `Decimals` | number | `0` |
| `Suffix` | string | `""` |
| `Callback` | `function(value: number)` | — |

Methods: `:Set(Value)`, `:SetText(Text)`, `:GetSize(Input)`, `:SetVisibility(Bool)`, `:UpdateDisable(State)`.

**`Section:Textbox(Params)` → `Textbox`**

| Field | Type | Default |
| --- | --- | --- |
| `Name` | string | `"Textbox"` |
| `Flag` | string | = `Name` |
| `Default` | string | `""` |
| `Placeholder` | string | `""` |
| `Numeric` | boolean | `false` (digits only) |
| `Finished` | boolean | `false` (fire on FocusLost/Enter instead of every keystroke) |
| `Callback` | `function(text)` | — |

Methods: `:Set(Value)`, `:SetText(Text)`, `:SetVisibility(Bool)`, `:UpdateDisable(State)`.

---

## Pickers

Per-element pages: **[Colorpicker](elements/colorpicker.md)** · **[Keybind](elements/keybind.md)** · **[Dropdown](elements/dropdown.md)** (overview: [pickers.md](pickers.md)).

**Colorpicker** — attached, never standalone: `Toggle:Colorpicker(Data)` / `Label:Colorpicker(Data)` → `Colorpicker`. Do **not** pass `Parent` (injected for you).

| Field | Type | Default (via attach wrapper) |
| --- | --- | --- |
| `Flag` | string | from `Name` / auto |
| `Default` | `Color3` \| hex string \| `{r,g,b}` | `Color3.fromRGB(255,255,255)` |
| `Alpha` | number `0–1` | `0` |
| `Callback` | `function(Color: Color3, Alpha: number)` | no-op |

Methods: `:Set(Color, Alpha)`, `:SetOpen(Bool)`, `:SetVisibility(Bool)`, `:Update(IsFromAlpha)`,
`:SlidePalette(Input)`, `:SlideHue(Input)`, `:SlideAlpha(Input)`.

**Keybind** — attached: `Toggle:Keybind(Data)` / `Label:Keybind(Data)` → `Keybind`.

| Field | Type | Default (via attach wrapper) |
| --- | --- | --- |
| `Name` | string | parent's name |
| `Flag` | string | from `Name` / auto |
| `Default` | `Enum.KeyCode` / `Enum.UserInputType` | `Enum.KeyCode.E` (pass `Enum.KeyCode.Backspace` for none) |
| `Mode` | `"Toggle"` \| `"Hold"` \| `"Always"` | `"Toggle"` |
| `Callback` | `function(toggled: boolean)` | no-op |

Methods: `:Set(Key)`, `:SetOpen(Bool)`, `:SetMode(Mode)`, `:Press(Bool)`.

**Dropdown** — standalone: `Section:Dropdown(Params)` → `Dropdown`.

| Field | Type | Default |
| --- | --- | --- |
| `Name` | string | `"Dropdown"` |
| `Items` | `table<string>` | `{}` |
| `Flag` | string | = `Name` |
| `Default` | string \| `table<string>` (multi) | `""` |
| `Multi` | boolean | `false` |
| `MaxSize` | number (px popup height) | `250` |
| `Premium` | boolean | `false` |
| `Disabled` | boolean | `false` |
| `Callback` | `function(value)` — string (single) or array (multi) | — |
| `Parent` | wrapper object | owning section content |

Methods: `:Set(Value)`, `:Add(Value)`, `:Remove(Option)`, `:Refresh(List)`, `:SetText(Text)`,
`:SetOpen(Bool)`, `:SetVisibility(Bool)`, `:UpdatePrem(State)`, `:UpdateDisable(State)`.

---

## Display elements

All on a `Section`. Per-element pages: [Label](elements/label.md) · [Status](elements/status.md) · [Paragraph](elements/paragraph.md) · [List](elements/list.md) · [Preview](elements/preview.md) (overview: [display-elements.md](display-elements.md)).

| Builder | Key fields | Methods |
| --- | --- | --- |
| `Section:Label(Params)` → `Label` | `Name` (`"Label"`), `Premium`, `Disabled` | `:SetText`, `:SetVisibility`, `:UpdateDisable`, `:Colorpicker(Data)`, `:Keybind(Data)` |
| `Section:Status(Params)` / `Section:Paragraph(Params)` | `Name` | `:AddStatus(Text)` → `{ :Set(Text) }`, `:SetText`, `:SetVisibility` |
| `Section:List(Params)` → `List` | `Items` (array of row tables), `Callback` | `:Add(Name)` → `{ :AddStat(Text) }`, `:GetLabelUnderMouse(MouseY)` |
| `Section:Preview(Params)` → `Preview` | `Name` (`"Preview"`) | `:SetHeight(H)`, `:Clear()` |

---

## Dialogs & notifications

Per-element pages: [Dialog](elements/dialog.md) · [Notification](elements/notify.md) (overview: [dialogs-and-notifications.md](dialogs-and-notifications.md)). Both read fields in
**TitleCase only** (no lowercase aliases).

**`Window:Dialog(Data)` → `Prompt`**

| Field | Type | Default |
| --- | --- | --- |
| `Title` | string | — |
| `Description` | string | — |

Prompt methods: `:AddButton(Name, Callback)` (callback gets no args, then auto-closes),
`:AddTextbox(Placeholder, Callback)` → `{ :Get() }` (callback gets current text on change),
`:AddSecondaryAction(Text, Callback)` (no args, does **not** close), `:Exit()`.

**`Window:Notify(Data)` → raw `Frame`** (self-destroys after `Duration`)

| Field | Type | Default |
| --- | --- | --- |
| `Title` | string | `"Notification"` |
| `Description` | string | `""` |
| `Duration` | number (seconds) | `5` |
| `Icon` | string | `"bell"` (parsed but **not rendered** in this version) |

---

## Settings & config sections

Details: [settings-and-premium.md](settings-and-premium.md) and [config-and-flags.md](config-and-flags.md).
These build into the page/sub-tab they are called on and take no extra args.

| Method | Builds |
| --- | --- |
| `Window:CreateSettingsPage()` → `SettingsPage` | Settings page (General/Premium sub-tabs) |
| `SettingsPage:CreateConfigsSection()` | Config save / load / delete / refresh UI |
| `SettingsPage:CreateShareConfigsSection()` | Share / import config UI |
| `SettingsPage:CreateThemingSection()` | Live theme editor (one picker per theme key) |
| `SettingsPage:CreatePremiumSection()` | Premium key entry / status |

---

## Webhooks

Details: [webhooks.md](webhooks.md).

**`Window:WebhookPage(Params)` → `Page`** (with an overridden `:Section`)

Page methods: `:SetURL(url)`, `:GetURL()`, `:SetUsername(name)`, `:SetAvatarURL(url)`,
`:TestAll()`, `:Enqueue(body)`.

**WebhookSection** (from the webhook page's `:Section(Params)`):
`:Field(FieldParams)`, `:Filter(FilterParams)`, `:Thumbnail(ThumbParams)`, `:SetColor(color)`,
`:SetSample(sample)`, `:GetSample()`, `:Fire(payload)`, `:Test()`, `:RefreshPreview()`,
`:GetValues()`, `:SetEnabled(state)`, `:IsEnabled()`.

---

## Theme keys

The default `Library.Theme` (index space-containing keys as bracket strings). Details: [theming.md](theming.md).

| Key | Default `Color3.fromRGB` |
| --- | --- |
| `Background` | `18, 18, 20` |
| `Inline` | `15, 15, 16` |
| `Accent Start` | `175, 102, 126` |
| `Accent End` | `114, 75, 135` |
| `Text` | `220, 229, 247` |
| `Text 2` | `145, 151, 163` |
| `Element` | `24, 24, 27` |
| `Hovered Element` | `32, 32, 36` |
| `Topbar` | `28, 28, 29` |

---

[← Back to README](../README.md)
