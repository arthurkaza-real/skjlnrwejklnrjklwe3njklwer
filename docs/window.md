# Window

The **Window** is the top-level object of the UI. `Library:Window(Params)` creates the main draggable, resizable frame (original size `850x600`), mounts it under `Library.Holder`, and returns a table on which you call the control, dialog, premium, and keybind-tab methods documented below. It builds the title bar, the page rail, the content area, the dim dialog overlay, a draggable toggle button, a hidden premium status badge, and (optionally) a floating keybinds panel. On construction it bootstraps the save directory, writes an empty `autoload.json` if none exists, animates open, and starts visible with `IsOpen = true`.

## Library:Window

Creates the main window and returns the Window object. There is exactly one constructor; all other features (controls, dialogs, premium, keybinds, pages, notifications) are methods on the returned table.

`Constructor: Library:Window(Params) -> Window object`

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | string | `'<font color="rgb(175, 102, 126)">ather.</font>hub'` | Title shown in the top bar. The Title `TextLabel` has `RichText = true`, so it accepts Roblox rich-text markup such as `<font color="rgb(r,g,b)">...</font>` color tags. Read as `Params.Name` or `Params.name`. |
| `Logo` | string | `"rbxassetid://133218922939038"` | Image for the small top-bar `ImageLabel` (with accent gradient) **and** the icon on the floating toggle button (built via `CreateIcon`, which supports `rbxassetid://` ids and lucide icon names like `'lucide:home'`). Read as `Params.Logo` or `Params.logo`. |
| `Folder` | string | none | Optional subfolder appended to `Library.Directory` for this window's save data. When set, the parent dir and new subdir are created, `Library.Folders` subfolders are created, and an existing `autoload.json` is migrated from the old directory. Read as `Params.Folder` or `Params.folder`. |
| `Keybinds` | boolean | `false` | When truthy, enables the separate floating keybinds panel (sets `Window.HasKeybindsTab` / `KeybindsTabVisible` to a strict boolean). Defaults to `false` when both `Params.Keybinds` and `Params.keybinds` are nil. Read as `Params.Keybinds` or `Params.keybinds`. |
| `ScriptId` | any | none (`nil`) | Identifier used for the premium / LRM (license/key) integration; stored as `Window.ScriptId`. Read as `Params.ScriptId`, `Params.scriptId`, or `Params.scriptid`. |
| `PurchaseURL` | string | none (`nil`) | URL used for purchasing / upgrading to premium; stored as `Window.PurchaseURL`. Read as `Params.PurchaseURL`, `Params.purchaseURL`, `Params.PurchaseUrl`, or `Params.UpgradeURL`. |
| `KeyFile` | string | `Library.Directory .. "/key.txt"` | Path of the file used to persist the premium key; stored as `Window.KeyFile`. Read as `Params.KeyFile` or `Params.keyfile`, defaulting to `key.txt` inside the library's save directory. |

### Methods (window controls)

- `Window:SetOpen(Bool: boolean)` — Shows (`true`) or hides (`false`) the main window by fading all of `MainFrame`'s descendants. Sets `Window.IsOpen = Bool`. Has an internal `Debounce` that ignores calls while a previous fade is in progress (cleared by the `FadeDescendants` completion callback). Also iterates `Library.OpenFrames` and calls `:SetOpen(false)` on each (closing open dropdowns / floating frames). The toggle button calls this with `(not Window.IsOpen)` on `MouseButton1Down`.
- `Window:Center() -> UDim2` — Re-pins the main frame: reads its current `AbsolutePosition`, sets `MainFrame.AnchorPoint` to `(0,0)`, waits a frame, then sets `Position` to `UDim2.new(0, AbsPos.X, 0, AbsPos.Y)`. Returns that resulting `UDim2`.
- `Window:Minimize(Bool: boolean)` — Collapses to the title bar (`true`): tweens `MainFrame` to `(Title.TextBounds.X + 200) x 35`, sets `ResizeHandler.CanResize = false`, hides `Content` and `Pages`. Restores (`false`): tweens back to `OriginalSize` (`850x600`), sets `CanResize = true`, shows `Content` and `Pages`. Either branch closes all `Library.OpenFrames`. Sets `Window.IsMinimized = Bool`.
- `Window:FullScreen(Bool: boolean)` — Expands to fill the screen (`true`): tweens `MainFrame.Size` to `(1,0,1,0)` and `Position` to `(0,0)`. Restores (`false`): tweens to `OriginalSize` and `Position` `UDim2.new(0, Camera.ViewportSize.X/3 - 100, 0, Camera.ViewportSize.Y/3 - 100)`. Sets `Window.IsFullScreen = Bool`.
- `Window:Dialog(Data: table) -> Prompt` — Opens a single modal dialog over the dimmed overlay and returns a `Prompt` object stored as `Window.CurrentDialog`. Documented on its own page; see the pointer below.

### What the callback receives

The constructor takes **no callback**. `SetOpen`, `Minimize`, and `FullScreen` each take a single boolean. `Center` takes no arguments and returns a `UDim2`. `Dialog` takes a `Data` table and returns the `Prompt` object.

### Returned state

The returned Window table carries these state fields: `Name`, `Logo`, `HasKeybindsTab`, `KeybindsTabVisible`, `KeybindEntries`, `ScriptId`, `PurchaseURL`, `KeyFile`, `PremiumAPI`, `PremiumStatus` (`'Freemium'`), `HasPremiumFeatures` (`false`), `PremiumLabel`, `IsOpen` (`true`), `IsMinimized` (`false`), `IsFullScreen` (`false`), `ResizeHandler`, `PremiumState`, `PremiumControls`, `CurrentDialog`, `Pages`, and `Items`. It is **not** registered on any global flag table.

### Gotchas

- Geometry is hardcoded: `OriginalSize = UDim2.new(0,850,0,600)`; topbar `35px`; Pages rail `225` wide at `(15,46)` size `(0,225,1,-61)`; Content at `(225,51)` size `(1,-240,1,-66)`. There are **no** `Size`, `Position`, `Theme`, or `Color` params on the constructor.
- Colors come from `Library.Theme` keys (`Background`, `Topbar`, `Inline`, `Element`, `Text`, `Text 2`, `Accent Start`, `Accent End`) applied via `:AddToTheme` — not from Window params. See [Theming](theming.md).
- The `Folder` path is built in source as `Params.Folder or Params.folder .. "/"` — the `.. "/"` binds only to the lowercase alias due to operator precedence.
- If both `Params.Folder` / `Params.folder` are nil, no folder migration runs; regardless, an empty `autoload.json` is written if missing.
- If `IsMobile` is true, a `0.65` `UIScale` is parented to `Library.Holder`.
- The window animates open on construction and starts `IsOpen = true` / `Visible = true`; there is **no** "start closed" or "start minimized" param.
- The premium `StatusBadge` (lucide:crown icon + accent-gradient stroke + `'Freemium'` text) is built `Visible = false` and revealed elsewhere when premium controls exist.
- The floating keybinds panel (`Window.KeybindTabItems`, draggable, titled `'keybinds'`, `'no toggles bound'` empty state) is created only when `Keybinds` is truthy.
- The toggle button uses `CreateIcon(Window.Logo, 42x42 icon)` and is draggable; its `MouseButton1Down` handler calls `Window:SetOpen(not Window.IsOpen)`.

### Example

```lua
local Window = Library:Window({
    Name = '<font color="rgb(175, 102, 126)">ather.</font>hub',
    Logo = "rbxassetid://133218922939038",
    Keybinds = true,
    Folder = "MyHub"
})

-- control methods
Window:SetOpen(false)
local pos = Window:Center()
Window:Minimize(true)
Window:FullScreen(true)
```

> **Dialogs and notifications live elsewhere.** `Window:Dialog(Data)` and `Window:Notify(Data)` are documented in full on [Dialogs & Notifications](dialogs-and-notifications.md). On this page, `Dialog` is listed only as a control method because the Premium System (below) opens dialogs internally.

## Keybind Tab

An optional on-screen overlay panel that lists registered keybind entries, each with a name on the left and a bound-key tag on the right, plus an active/inactive highlight. It only functions when the window was created with the keybinds tab enabled (both `Window.HasKeybindsTab` and `Window.KeybindTabItems` present, which requires `Keybinds = true` on the constructor). Methods let you show/hide it, reposition it to one of six preset anchors, and add entry rows; each added entry returns a `Record` table with methods to update its key text, active styling, and removal.

`Builder: Window:SetKeybindsTab(Bool)`, `Window:SetKeybindsTabPosition(PositionName)`, `Window:RegisterKeybindEntry(Entry)`

### Arguments (the `Entry` table passed to `RegisterKeybindEntry`)

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | string | `"Toggle"` | Read as `Entry.Name`. The display name shown on the left of the entry row (falls back to `'Toggle'`). No lowercase alias. |
| `Toggle` | any | `nil` (none) | Read as `Entry.Toggle`. An arbitrary reference stored verbatim on the returned `Record` as `Record.Toggle` for the caller's own use; not otherwise interpreted. No lowercase alias. |

### Methods

- `Window:SetKeybindsTab(Bool)` — Shows (`true`) or hides (`false`) the keybinds overlay frame (`Window.KeybindTabItems['Frame'].Instance.Visible`). Coerced to boolean and stored as `Window.KeybindsTabVisible`. No-op if `Window.HasKeybindsTab` / `KeybindTabItems` are absent.
- `Window:SetKeybindsTabPosition(PositionName)` — Repositions the overlay to a named preset by looking up `Window.KeybindsTabPositions[PositionName]` and applying its `AnchorPoint` and `Position` to the `Frame`. Valid names: `'Top Left'`, `'Center Left'`, `'Bottom Left'`, `'Top Right'`, `'Center Right'`, `'Bottom Right'`. Unknown names are a no-op (early return). Stores `Window.KeybindsTabPosition`. The default value of `Window.KeybindsTabPosition` is `'Center Left'` (set as a field, not via this method). No-op if the keybinds tab is absent.
- `Window:RegisterKeybindEntry(Entry) -> Record | nil` — Adds a row to the overlay's `Content` frame from an `Entry` table `{Name = string, Toggle = any}`. Creates the row frame, name label (themed `Text`, initially `TextTransparency 0.4`), an accent `NameGradient` (disabled by default), and a key label initialized to `'[None]'`. Inserts the `Record` into `Window.KeybindEntries` and refreshes the empty-state. Returns the `Record`, or `nil` if the keybinds tab is unavailable.
- `Window:_RefreshKeybindEmpty()` — Internal (underscore). Toggles the overlay's `'Empty'` placeholder visibility based on whether any registered entry frame is currently `Visible`. Called automatically by `RegisterKeybindEntry`. No-op if the `Empty` item is absent.
- `Record:SetActive(Bool)` — Method on the `Record`. Stores `Record.Active` (coerced boolean). When `true`, enables the accent `NameGradient` and tweens the name to white with `TextTransparency 0`; when `false`, disables the gradient and tweens the name to `Library.Theme.Text` with `TextTransparency 0.4`.
- `Record:SetKey(KeyText)` — Method on the `Record`. Sets the displayed bound-key tag. If `KeyText` is nil, empty string, or the literal `'None'`, shows `'[None]'`; otherwise shows `'[' .. tostring(KeyText) .. ']'`.
- `Record:Remove()` — Method on the `Record`. Destroys the entry's `Frame` Instance (if present), removing the row from the overlay. Does not itself re-run the empty-state refresh.

### What the callback receives

These methods take direct arguments (`Bool`, `PositionName`, `Entry` / `KeyText`) and **do not** invoke user callbacks.

### Returned record

`SetKeybindsTab` and `SetKeybindsTabPosition` return nothing (early-return if no keybinds tab). `RegisterKeybindEntry` returns a `Record` table exposing fields `Frame`, `Name`, `NameGradient`, `Key`, `Toggle`, `Active`, and methods `SetActive` / `SetKey` / `Remove` — or `nil` if the keybinds tab is unavailable. None register a `.Flag`.

### Gotchas

- All three Window methods early-return (do nothing) unless the window was constructed with both `Window.HasKeybindsTab` and `Window.KeybindTabItems` (i.e. `Keybinds = true`); `RegisterKeybindEntry` returns `nil` in that case.
- Valid position names are exact, case-sensitive strings: `'Top Left'`, `'Center Left'`, `'Bottom Left'`, `'Top Right'`, `'Center Right'`, `'Bottom Right'`. Default `Window.KeybindsTabPosition` is `'Center Left'`.
- The `Entry` table reads only `Entry.Name` (default `'Toggle'`) and `Entry.Toggle` (stored verbatim on `Record.Toggle`). No lowercase aliases.
- Each registered entry's key label initializes to `'[None]'` until you call `Record:SetKey(...)`.
- Adding an entry automatically refreshes the overlay's empty-state placeholder via `Window:_RefreshKeybindEmpty()`.

### Example

```lua
-- Window must have been created with the keybinds tab enabled (Keybinds = true).
Window:SetKeybindsTabPosition("Bottom Right")
Window:SetKeybindsTab(true)

local Entry = Window:RegisterKeybindEntry({
    Name = "Fly",
    Toggle = MyFlyToggle,
})

Entry:SetKey("F")      -- shows [F]
Entry:SetActive(true)  -- highlight with accent gradient
-- Entry:Remove()      -- when done
```

## Premium System

A premium-gating system on the Window. Components created with the `Premium = true` flag are tracked in `Window.PremiumControls`; while the user is Freemium an overlay locks those controls, and when premium is granted the overlay is lifted and the saved autoload config is re-applied. Premium can be detected automatically from the Luarmor (LRM) loader (forwarded as `Library.LRMPremium` / `Library.LRMNote`, whose note must contain `'prem'`), or unlocked by redeeming a key validated against the Luarmor SDK (loaded lazily from `https://sdkapi-public.luarmor.net/library.lua` using `Window.ScriptId`). A valid key is persisted to `Window.KeyFile` (trimmed) and re-applied on next launch. The Window also shows a Premium/Freemium status badge whose styling updates with status.

`Builder: methods live directly on the Window object — call as Window:SetStatus(...), Window:UpdatePrem(...), Window:RedeemKey(...), etc.`

### Arguments

The premium methods take direct arguments rather than a single params table. The developer-facing arguments are `StatusType` (`SetStatus`), `State` (`UpdatePrem`), `Feature` (`ShowUpgradePrompt`), `Key` and `Label` (`RedeemKey`), and `Key` (`CheckPremiumKey` / `_SavePremiumKey`). There is no constructor params table for this system.

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `StatusType` | string | `"Freemium"` | Passed to `SetStatus`. Pass `"Premium"` to mark premium, `"Freemium"` otherwise. Defaults to `"Freemium"` if nil. |
| `State` | boolean | (none) | Passed to `UpdatePrem`. Coerced to boolean. **Inverted semantics:** `true` = LOCK (still freemium), `false` = UNLOCK. |
| `Feature` | string | (none) | Passed to `ShowUpgradePrompt`. Optional name of the feature that requires premium; shown in the prompt description. |
| `Key` | string | (none) | Passed to `RedeemKey` / `CheckPremiumKey` / `_SavePremiumKey`. The premium key to validate / persist. |
| `Label` | object | (none) | Passed to `RedeemKey`. Optional; any object with a `:SetText` method, updated with `'Premium Status - Premium'` or `'Premium Status - Invalid Key'`. |

### Methods (developer-facing surface)

- `Window:SetStatus(StatusType)` — Sets `Window.PremiumStatus` to `StatusType` (defaults to `"Freemium"` if nil). If `Window.PremiumTabLabel:SetText` exists, updates the Premium sub-tab label to `'Premium Status - <status>'` (wrapped in `pcall`), then calls `Window:ApplyStatusStyle()` (also `pcall`'d). Returns nothing.
- `Window:UpdatePrem(State)` — Coerces `State` to boolean, stores it as `Window.PremiumState`, then iterates `Window.PremiumControls` and calls `Control:UpdatePrem(IsEnabled)` only on controls that have both an `UpdatePrem` method **and** the `_OriginallyPremium` flag. `State = true` means LOCK (still freemium); `State = false` means UNLOCK. Returns nothing.
- `Window:ApplyStatusStyle()` — Restyles the status badge based on `Window.PremiumStatus == "Premium"`. Premium: enables `StatusBadgeGradient`, white stroke (`Transparency 0`), shows `StatusIconHolder`, sets `StatusText` to `'Premium'` at `x=33` with light color. Freemium: disables gradient, gray stroke (`Transparency 0.25`), hides icon, sets `StatusText` to `'Freemium'` at `x=12`. No-op (early return) if `Window.Items['StatusBadge']` is absent. Returns nothing. Also called once at the end of window construction.
- `Window:ShowUpgradePrompt(Feature) -> Dialog` — Opens a `Window:Dialog` titled `'Premium Required'` whose description names `Feature` (optional string) as a Premium feature. Adds a `'Copy Link'` button (only if `Window.PurchaseURL` is set) that copies the URL via `setclipboard`/`toclipboard` and notifies, a `'Close'` button, and — only if `Window.ScriptId` is set — a secondary action `'Bought a key?'` (via `Dialog:AddSecondaryAction`) that opens `ShowKeyRedemptionDialog`. Returns the Dialog object.
- `Window:ShowKeyRedemptionDialog() -> Dialog` — Opens a `Window:Dialog` titled `'Redeem Key'` with a textbox (`Dialog:AddTextbox`) to paste a key. The `'Redeem'` button defers, trims whitespace, errors-notifies on empty input, else calls `CheckPremiumKey`; on `'KEY_VALID'` it sets status Premium, `UpdatePrem(false)`, saves via `_SavePremiumKey`, and notifies success; on failure notifies error. Also has a `'Cancel'` button. Returns the Dialog object.
- `Window:LoadPremiumAPI()` — Lazily loads the Luarmor SDK. Returns `false` if `Window.ScriptId` is unset; returns the cached `Window.PremiumAPI` if already loaded. Otherwise `loadstring(game:HttpGet('https://sdkapi-public.luarmor.net/library.lua'))()` inside `pcall`, sets `api.script_id = Window.ScriptId`, caches it as `Window.PremiumAPI`, and returns it; returns `nil` on failure.
- `Window:CheckPremiumKey(Key) -> (code, res)` — Validates `Key` against the Luarmor SDK via `LoadPremiumAPI`. Returns `(nil, 'API unavailable')` if the api or `api.check_key` is missing. Calls `api.check_key(Key)` in `pcall`; returns `(nil, 'Request failed')` if it errors or the result isn't a table. On success returns `(res.code, res)` where `res.code` is the SDK code string (e.g. `'KEY_VALID'`) and `res` is the raw result table. Does not modify status.
- `Window:ApplySavedPremiumKey() -> boolean` — Returns `false` early if `Window.KeyFile` / `isfile` are unavailable or the file is missing. Reads the file (`pcall readfile`), returns `false` on empty/error, trims whitespace, re-validates via `CheckPremiumKey`. On `'KEY_VALID'`: sets Premium status, `UpdatePrem(false)`, re-applies autoload, rewrites the normalized key to disk if trimmed differed from the raw contents, returns `true`. Otherwise returns `false`.
- `Window:DetectInitialPremium() -> boolean` — Reads `Library.LRMPremium` / `Library.LRMNote`; `isPrem` is true only when both are present and `tostring(note):lower()` contains `'prem'`. Calls `SetStatus(Premium/Freemium)` and `UpdatePrem(not isPrem)`. If premium, re-applies autoload; otherwise starts the ~15s watchdog for late LRM auth. Returns the boolean `isPrem`.
- `Window:RedeemKey(Key, Label) -> boolean` — Programmatically redeems a premium `Key`. `Label` (optional) is any object with `:SetText`, set to `'Premium Status - Premium'` or `'Premium Status - Invalid Key'`. On empty/nil `Key`: sets Label text, notifies, returns `false`. Calls `CheckPremiumKey(Key)`; on `'KEY_VALID'` sets Premium status, `UpdatePrem(false)`, re-applies autoload, saves via `_SavePremiumKey(Key)`, sets Label, notifies success, returns `true`; else sets Label, notifies error, returns `false`. **Note:** `RedeemKey` does **not** trim `Key` itself — trimming happens inside `_SavePremiumKey`.

### Methods (internal helpers, underscore-prefixed)

- `Window:_RefreshBadgeVisibility()` — Sets the `StatusBadge` Instance's `.Visible` to `Window.HasPremiumFeatures` if the badge exists. Returns nothing.
- `Window:_SavePremiumKey(Key) -> boolean` — Centralized writer for the saved key. Returns `false` if `Key` is not a non-empty string, if its trimmed form is empty, or if `Window.KeyFile` is unset. Ensures `Library.Directory` exists (`makefolder`, `pcall`), then `writefile`'s the **trimmed** key to `Window.KeyFile` (`pcall`). Returns the boolean success of the write. This is where key trimming actually happens for `RedeemKey` and the redemption dialog.
- `Window:_ReapplyAutoLoadAfterPremium()` — Runs `Library:CheckForAutoLoad()` once (guarded by `Window._autoLoadReplayed`, deferred + `pcall`) so premium-gated toggles get their saved autoload values applied after premium is granted (LRM may authenticate after the initial autoload pass). Returns nothing.
- `Window:_StartPremiumWatchdog()` — Spawns a polling loop (guarded by `Window._premWatchdog`) that checks every `0.5s` for up to 30 attempts (~15s) for `Library.LRMPremium` / `LRMNote` with a note containing `'prem'`; on a hit it sets status Premium, `UpdatePrem(false)`, re-applies autoload, and exits. Returns nothing.

### What the callback receives

The premium methods take direct arguments (`StatusType`, `State`, `Feature`, `Key`, `Label`) rather than user callbacks. The internally-created Dialog buttons (`Copy Link`, `Close`, `Redeem`, `Cancel`) receive no arguments; the redemption textbox callback receives the typed value (string).

### Gotchas

- **`UpdatePrem` semantics are inverted:** pass `false` to UNLOCK premium controls and `true` to LOCK them. The code calls `Window:UpdatePrem(false)` after granting premium and `Window:UpdatePrem(not isPrem)` on detection.
- A control is only affected by lock/unlock if it has the internal `_OriginallyPremium` flag (set when created with `Premium = true`) and is registered in `Window.PremiumControls`.
- Key validation requires `Window.ScriptId`; without it `LoadPremiumAPI` returns `false` and `CheckPremiumKey` returns `(nil, 'API unavailable')`. The SDK is fetched from `https://sdkapi-public.luarmor.net/library.lua` and cached as `Window.PremiumAPI`.
- Saved keys are written to `Window.KeyFile` (developer-configurable; default referenced as `AtherHub/key.txt`). Trimming of surrounding whitespace occurs in `_SavePremiumKey`, not in `RedeemKey`.
- `ShowUpgradePrompt` only shows `'Copy Link'` when `Window.PurchaseURL` exists, and only the `'Bought a key?'` secondary action when `Window.ScriptId` exists.
- Premium can also be granted automatically with **no key** via the LRM loader forwarding `Library.LRMPremium` / `LRMNote` (note containing `'prem'`); `DetectInitialPremium` plus the internal watchdog handle late async authentication.
- `CheckPremiumKey` returns **two** values (`code`, `res`). `RedeemKey` captures both; `ShowKeyRedemptionDialog` only uses the first.
- Underscore-prefixed methods (`_SavePremiumKey`, `_ReapplyAutoLoadAfterPremium`, `_StartPremiumWatchdog`, `_RefreshBadgeVisibility`) are internal helpers; the developer-facing surface is `LoadPremiumAPI`, `CheckPremiumKey`, `RedeemKey`, `DetectInitialPremium`, `ApplySavedPremiumKey`, `ShowUpgradePrompt`, `ShowKeyRedemptionDialog`, `SetStatus`, `UpdatePrem`, and `ApplyStatusStyle`.

### Example

```lua
-- During window setup, after creating premium-gated controls:
Window:DetectInitialPremium()       -- auto-detect via Luarmor loader
Window:ApplySavedPremiumKey()       -- or unlock from a previously saved key

-- Manual gate inside a control's callback:
Section:Toggle({
    Name = "Aimbot",
    Premium = true,
    Callback = function(State)
        if Window.PremiumStatus ~= "Premium" then
            Window:ShowUpgradePrompt("Aimbot")
            return
        end
        -- premium logic here
    end
})

-- Redeem a key programmatically (Label optional, needs :SetText):
Window:RedeemKey("MY-KEY-1234", SomeLabel)
```

> For deeper coverage of premium configuration and saved settings, see [Settings & Premium](settings-and-premium.md).

## See also

[Dialogs & Notifications](dialogs-and-notifications.md) · [Settings & Premium](settings-and-premium.md) · [Colorpicker](pickers.md) · [Theming](theming.md) · [Config & Flags](config-and-flags.md) · [Index](../README.md)
