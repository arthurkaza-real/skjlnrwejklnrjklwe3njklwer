# Getting Started

This page gets you from zero to a working menu. You will load the library, learn how the `getgenv().Library` global and the re-run guard work, see how the three accepted icon formats are resolved, and build a minimal first window (Window → Page → SubPage → Section → a Toggle). Everything is one file (`ui.lua`) that builds and returns a single fluent `Library` table; once you have that table, every builder method hangs off of it. For deeper coverage of each piece, follow the links to [Window](window.md), [Pages & Sections](pages-and-sections.md), [Components](components.md), [Theming](theming.md), and [Config & Flags](config-and-flags.md).

## Installation & Global

Load the script with `loadstring(game:HttpGet(...))()`. The file is a single script that builds a table named `Library` (the fluent builder API), assigns it to `getgenv().Library`, and returns it. Because of that, the same instance is reachable both from the loadstring return value and from the `getgenv().Library` global. At the very top of the file there is a re-run guard, so simply re-executing the script cleanly tears down a previously loaded UI before building a new one.

`Builder`: `local Library = loadstring(game:HttpGet("https://your-url/ui.lua"))()`

### Arguments

The script itself takes no arguments. `Library:Exit()` also takes no arguments (the colon-passed `self` is used internally for the holder ScreenGuis).

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| _(none)_ | — | — | The script accepts no parameters. It builds the `Library` table, stores it at `getgenv().Library`, and returns it. |

### Methods

- `Library:Exit()` — Tears down the UI. Iterates `Library.Connections` and calls `Connection.Connection:Disconnect()` on each, iterates `Library.Threads` and `coroutine.close()`s each, then (if present) destroys `Self.Holder.Instance` and `Self.UnusedHolder.Instance` (the two ScreenGui holders). Finally sets the internal `Library` upvalue to `nil` and `getgenv().Library = nil`. It is called automatically by the top-of-file re-run guard whenever a previous `Library` global with an `Exit` method exists.

### What the Callback receives

n/a — there is no callback at this layer.

### Default global fields & gotchas

The re-run guard at the top of the file is, in effect:

```lua
if getgenv().Library and getgenv().Library.Exit then getgenv().Library:Exit() end
```

> The guard means re-running the loadstring will call the old global's `:Exit()` first, preventing duplicate UIs. `getgenv().Library = Library` and `return Library` are the final two lines of the file, so the global and the return value are the same instance.

- A bad-executor shim is defined at the very top: `cloneref = cloneref or function(Object) return Object end`. A second shim, `gethui = gethui or function() return CoreGui end`, is defined later (after the icon helpers), not adjacent to `cloneref`.
- On construction the global is seeded with these default fields: `Library.Flags = {}`, `Library.MenuKeybind = tostring(Enum.KeyCode.RightControl)`, `Library.Directory = "AtherHub"`, `Library.Folders = { Assets = "/Assets", Configs = "/Configs" }`, `Library.FontSize = 14`, `Library.Animation = { Time = 0.3, Style = "Cubic", Direction = "Out" }`, `Library.Theme = nil` (set to `Themes.Preset` later), and `Library.AutoSave = true`. Internal bookkeeping tables include `Threads`, `Connections`, `Notifications`, `SetFlags`, `OpenFrames`, `ThemingStuff`, `ThemeMap`, `Holder`, `UnusedHolder`, and `Font`.
- On load it creates the workspace folders (`Directory`, `Directory .. "/Assets"`, `Directory .. "/Configs"`) and downloads/registers the custom font `"InterSemiBold"` (weight 400) from a GitHub TTF into `Library.Font` (a `Font` object).
- `Library:CheckForAutoLoad()` is intended to be the very last call after your whole UI is built, to restore the saved autoload config. See [Config & Flags](config-and-flags.md).

```lua
local Library = loadstring(game:HttpGet("https://your-url/ui.lua"))()
-- (or, after the script ran once:) local Library = getgenv().Library

local Window = Library:Window({
    Name = '<font color="rgb(175, 102, 126)">SAMET UI.</font>hub',
    Logo = "rbxassetid://133218922939038"
})

-- later, to fully close and clean up the UI:
Library:Exit()
```

## Icons

Every component that accepts an `Icon` (or `Logo`) string runs it through the same internal resolution layer. On load the script `HttpGet`s the Footagesus Icons library inside a `pcall`, loadstrings it, and—if it succeeded—calls `Icons.SetIconsType("lucide")` once. You never call these helpers directly; this section documents how the `Icon` / `Logo` strings you pass are interpreted. There are two internal helpers: `CreateIcon` (used for icons that become a standalone `GuiObject`) and `ApplyIconToContainer` (used when an icon is parented into an existing container).

`Builder` (internal): `CreateIcon(iconName, size, colorOrTheme)` / `ApplyIconToContainer(container, iconName, size, colorOrTheme)`

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `iconName` | `string` | required | The icon to resolve. Treated as an asset id if it matches `^rbxassetid://` or `^%d+$` (bare digits get `rbxassetid://` prepended via `GetAssetImage`). In `CreateIcon`, any other non-empty string is forwarded by name to `Icons.Image` (so `lucide:house` works). In `ApplyIconToContainer` it is explicitly classified via `IsLucideIcon` (`^lucide:`) vs `IsAssetId` before falling back. |
| `size` | `UDim2` | `UDim2.fromOffset(18, 18)` in `CreateIcon` (both asset and lucide branches); `UDim2.fromScale(1, 1)` in `ApplyIconToContainer` | Size for the produced icon instance / passed as the `Icons.Image` `Size` field. |
| `colorOrTheme` | `Color3 \| string` | `Color3.fromRGB(230, 230, 235)` | Tint. For asset-id `ImageLabel`s it is applied as `ImageColor3` only when it is a `Color3`. For the lucide/`Icons.Image` path it is wrapped as `Colors = { colorOrTheme }` whether it is a `Color3` or a string; if it is neither, `Colors` defaults to `{ Color3.fromRGB(230, 230, 235) }`. The fallback `ImageLabel` uses `colorOrTheme` as `ImageColor3` if it is a `Color3`, else `Color3.fromRGB(230, 230, 235)`. |

### Methods

- `CreateIcon(iconName, size, colorOrTheme)` — Returns a `GuiObject`: an `ImageLabel` for asset-id icons (or the `rbxassetid://0` fallback), or the Icons library's `IconFrame` (`BackgroundTransparency = 1`) for lucide/name icons. Resolution order: (1) if `iconName` matches `^rbxassetid://` or `^%d+$`, build an `ImageLabel` directly (bare digits get `rbxassetid://` prepended); (2) otherwise, if the Icons lib loaded, call `Icons.Image({ Icon = iconName, Size = ..., Colors = ... })` and return its `.IconFrame`; (3) fallback `ImageLabel` with `Image = "rbxassetid://0"`. It does **not** explicitly test for the `lucide:` prefix—non-asset names are simply forwarded to the Icons library.
- `ApplyIconToContainer(container, iconName, size, colorOrTheme)` — Branches explicitly: `IsAssetId` → direct `ImageLabel`; `IsLucideIcon` → `Icons.Image`; then a final non-prefixed `Icons.Image` attempt; otherwise returns `nil`. Parents the result into `container`, names it `"IconImage"`, sets `Position = UDim2.fromScale(0.5, 0.5)` and `AnchorPoint = Vector2.new(0.5, 0.5)`, and returns it (or `nil` if nothing resolved).

### What the Callback receives

n/a — these helpers take no callback.

### Accepted forms & gotchas

The accepted user-facing forms for any `Icon` / `Logo` field are exactly:

- `"lucide:<name>"` — a Lucide icon name (resolved by the Icons library).
- `"rbxassetid://<id>"` — a full asset id.
- `"<id>"` — a bare numeric string (gets `rbxassetid://` prepended automatically).

> If the Footagesus Icons lib failed to load (no internet, blocked, or a loadstring error), `Icons` is `nil`: lucide/name icons yield the `rbxassetid://0` fallback (`CreateIcon`) or `nil` (`ApplyIconToContainer`), but asset-id and bare-numeric strings still work.

- `Icons.SetIconsType("lucide")` is called once at load, only if the Icons lib loaded.
- `Icons.Image` is called inside a `pcall`; a failed or invalid lucide name does not error—it just falls through to the fallback.

```lua
-- Inside component params, the Icon field accepts all three forms:
local Combat  = Window:Page({ Name = "Combat",  Icon = "lucide:house" })                  -- lucide name
local Visuals = Window:Page({ Name = "Visuals", Icon = "rbxassetid://111233133354469" })  -- full asset
local Misc    = Window:Page({ Name = "Misc",    Icon = "134546249616852" })               -- bare numeric id
```

## Your first menu

This walkthrough builds the minimal hierarchy: **Window → Page → SubPage → Section → a Toggle**. Each level is created off the object returned by the level above it. The constructor for the window is `Library:Window(Params)`; you then call `:Page`, `:SubPage`, `:Section`, and `:Toggle` in turn. For the full parameter set of each builder, see [Window](window.md), [Pages & Sections](pages-and-sections.md), and [Components](components.md).

`Constructor`: `local Window = Library:Window({ Name = ..., Logo = ... })`

### Arguments (Window constructor)

These are the constructor params you will most likely touch first. The full list (including `Folder`, `Keybinds`, `ScriptId`, `PurchaseURL`, and `KeyFile`) lives in [Window](window.md).

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | `string` | `'<font color="rgb(175, 102, 126)">ather.</font>hub'` | Title shown in the top bar. The Title `TextLabel` has `RichText = true`, so it accepts Roblox rich-text markup such as `<font color="rgb(r,g,b)">...</font>`. Read as `Params.Name` or `Params.name`. |
| `Logo` | `string` | `"rbxassetid://133218922939038"` | Image for the small top-bar `ImageLabel` (with accent gradient) and the icon on the floating toggle button. Built via `CreateIcon`, so it supports `rbxassetid://` ids and lucide names like `"lucide:home"`. Read as `Params.Logo` or `Params.logo`. |

### Methods (the walkthrough chain)

- `Library:Window(Params)` — Creates the top-level draggable, resizable window and returns the Window object. See [Window](window.md).
- `Window:Page({ Name = ..., Icon = ... })` — Adds a page to the left rail and returns a Page object. See [Pages & Sections](pages-and-sections.md).
- `Page:SubPage({ Name = ... })` — Adds a sub-page under that page and returns a SubPage object. See [Pages & Sections](pages-and-sections.md).
- `SubPage:Section({ ... })` — Adds a section container into the sub-page and returns a Section object you attach components to. See [Pages & Sections](pages-and-sections.md).
- `Section:Toggle({ Name = ..., Default = ..., Flag = ..., Callback = ... })` — Adds a boolean toggle. See [Components](components.md).

### What the Callback receives

The Window constructor and the `:Page` / `:SubPage` / `:Section` builders take no callback. The `Toggle`'s `Callback` is fired with the toggle's current boolean value whenever it changes (and when its `Flag` value is replayed from a loaded config). Register a `Flag` on the toggle to make it persistable—see [Config & Flags](config-and-flags.md).

### Gotchas

> The window animates open on construction and starts `IsOpen = true` / `Visible = true`. There is no "start closed" or "start minimized" param. There are also no `Size`, `Position`, `Theme`, or `Color` params on the constructor—geometry is hardcoded and colors come from `Library.Theme` keys (see [Theming](theming.md)).

- Build the hierarchy top-down: each builder must be called on the object returned by the level above it (`Window` → `Page` → `SubPage` → `Section` → component).
- If you want toggles (and other flagged components) to persist, give each a unique `Flag` string, then call `Library:CheckForAutoLoad()` as the very last line after the whole UI is built. See [Config & Flags](config-and-flags.md).

```lua
local Library = loadstring(game:HttpGet("https://your-url/ui.lua"))()

-- 1) Window
local Window = Library:Window({
    Name = '<font color="rgb(175, 102, 126)">my.</font>hub',
    Logo = "lucide:home"
})

-- 2) Page (left rail)
local MainPage = Window:Page({ Name = "Main", Icon = "lucide:house" })

-- 3) SubPage (under the page)
local Home = MainPage:SubPage({ Name = "Home" })

-- 4) Section (container for components)
local Section = Home:Section({ Name = "Welcome" })

-- 5) Toggle (a component)
Section:Toggle({
    Name = "Enable Feature",
    Default = false,
    Flag = "EnableFeature",
    Callback = function(Value)
        print("toggle is now:", Value)
    end
})

-- restore the saved autoload config as the final step
Library:CheckForAutoLoad()
```

## See also

[Window](window.md) · [Pages & Sections](pages-and-sections.md) · [Components](components.md) · [Theming](theming.md) · [Config & Flags](config-and-flags.md) · [README index](../README.md)
