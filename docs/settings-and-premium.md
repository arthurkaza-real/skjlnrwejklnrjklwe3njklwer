# Settings Page & Premium

This page documents the dedicated **Settings** page helper (`Window:CreateSettingsPage`), the **Premium** sub-tab builder (`Window:CreatePremiumSection`), and the full **Premium System** that gates `Premium`-flagged components behind a Freemium/Premium status. The Settings page is a one-column page whose "General" sub-tab is where you attach the config, share, and theming sections; the Premium sub-tab and the underlying gating methods (status, key redemption, upgrade prompts) live on the `Window` object. For the config and theming sections themselves, see [Config & Flags](config-and-flags.md) and [Theming](theming.md) rather than this page.

## Window:CreateSettingsPage

Creates a dedicated "Settings" Page on the Window and returns its "General" sub-tab so config/theming sections can be attached directly to it. Internally it builds a Page named `Settings` (Icon `rbxassetid://103129505225192`, Description `Configs & Theming`), then a SubPage named `General` (same Icon). It destroys the General sub-tab's `RightColumn` (forcing a one-column layout) and sets the LeftColumn's `UIPadding.PaddingRight` to `UDim.new(0, 15)`. The returned General SubPage gets an added `.SettingsPage` field pointing at the parent Page so callers can attach more sub-tabs (e.g. Premium) later.

Builder: `Library.CreateSettingsPage(Self)` — invoked as `Window:CreateSettingsPage()` -> `GeneralSubTab` (a SubPage object)

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| _(none)_ | — | — | Takes no arguments beyond `Self` (the Window). It reads no fields off `Self` other than calling `Self:Page(...)`, and accepts no argument table. |

### Methods

The four `CreateXSection` functions are registered on `Library`, so they are callable with `:` on the returned General SubPage object. Section/sub-page builder methods (`Section`, `SubPage`, `Toggle`, etc.) are inherited from the normal Page/SubPage API.

- `GeneralSubTab:CreateConfigsSection()` — Adds the config save/load/delete/create/refresh UI to this sub-tab. See [Config & Flags](config-and-flags.md).
- `GeneralSubTab:CreateShareConfigsSection()` — Adds the share/import config UI to this sub-tab. See [Config & Flags](config-and-flags.md).
- `GeneralSubTab:CreateThemingSection()` — Adds the live theme editor to this sub-tab. See [Theming](theming.md).
- `GeneralSubTab:CreatePremiumSection()` — Adds a Premium sub-tab to the parent SettingsPage and returns it (see [CreatePremiumSection](#windowcreatepremiumsection) below). Returns `nil` when the Window has no premium features (`Window.HasPremiumFeatures` falsy) or no Window/SettingsPage can be resolved.

**Callback:** n/a — `CreateSettingsPage` takes no Callback.

**Returns:** the General SubPage object. The returned SubPage has an added `.SettingsPage` field referencing the parent "Settings" Page (used by `CreatePremiumSection`). It does **not** register a `.Flag` and has no global registration.

> **Gotchas**
> - `Self` is the Window. The function accepts no argument table.
> - It destroys the General sub-tab's `RightColumn` (`GeneralSubTab.Items.RightColumn.Instance:Destroy()`), so **every section attached to it must use `Side = 1`**; `Side = 2` sections will not render.
> - The returned value is the General SubPage, **not** the parent Page. `CreatePremiumSection` relies on the returned object's `.SettingsPage` field (or its `.Page`) to find the parent page.

```lua
local SettingsPage = Window:CreateSettingsPage()
SettingsPage:CreateConfigsSection()
SettingsPage:CreateShareConfigsSection()
SettingsPage:CreateThemingSection()
SettingsPage:CreatePremiumSection()
```

## Window:CreatePremiumSection

Adds a "Premium" sub-tab (Icon `lucide:crown`) to the resolved SettingsPage and populates it with a premium status label, an optional purchase button, and (when keys are supported) a key textbox plus a redeem button. It resolves the Window from `Self.Window` or `(Self.Page and Self.Page.Window)` or `Library.Windoww`, and the parent page from `Self.SettingsPage` or `Self.Page`. The new Premium sub-tab destroys its `RightColumn` and sets LeftColumn `UIPadding.PaddingRight` to `UDim.new(0, 15)`.

Builder: `Library.CreatePremiumSection(Self)` — invoked as `SettingsPage:CreatePremiumSection()` on the General sub-tab returned by `CreateSettingsPage` -> `PremiumSubTab` (SubPage) or `nil`

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| _(none)_ | — | — | Takes no arguments beyond `Self`. Behaviour is driven entirely by fields read off the resolved `Window`: `HasPremiumFeatures`, `PremiumStatus`, `PremiumState`, `PurchaseURL`, and `ScriptId`. |

### Methods

This builder creates no methods of its own. The controls it adds use the standard component API:

- The "Purchase Premium" Button is added **only** when `Window.PurchaseURL` is set; its callback copies `Window.PurchaseURL` to the clipboard via `setclipboard` (else `toclipboard`) inside a `pcall` and notifies "Link Copied".
- The "Premium Key" Textbox (Flag `PremiumKey`, Placeholder `Paste your key here`) and the "Redeem Key" Button are added **only** when `Window.ScriptId` is set; Redeem calls `Window:RedeemKey(currentKey, PremLabel)`.

**Callback:** n/a at section level. Internally: the "Premium Key" Textbox callback receives the typed key string (`Value`, stored in a local `currentKey`); the "Redeem Key" Button callback calls `Window:RedeemKey(currentKey, PremLabel)`; the "Purchase Premium" Button callback takes no argument.

**Returns:** the new Premium SubPage object (`PremiumSubTab`), or `nil` when no Window can be resolved, when `Window.HasPremiumFeatures` is falsy, or when no parent SettingsPage can be resolved. The key textbox registers the flag `PremiumKey`. The status Label is stored on `Window.PremiumTabLabel`.

**Build order / behaviour:**

- Resolves Window via `Self.Window` or `(Self.Page and Self.Page.Window)` or `Library.Windoww`; returns `nil` early if none found.
- Returns `nil` immediately when `Window.HasPremiumFeatures` is falsy (no premium features => no tab).
- Resolves the parent page via `SettingsPage = Self.SettingsPage or Self.Page or nil`; returns `nil` if neither exists.
- Builds the Premium sub-tab (`SettingsPage:SubPage{ Name = "Premium", Icon = "lucide:crown" }`), destroys its `RightColumn`, sets LeftColumn `PaddingRight` to `UDim.new(0, 15)`, then a Section `Premium` (`Side = 1`).
- `status` starts as `"Freemium"`; it is set to `"Premium"` if `Window.PremiumStatus == "Premium"` **OR** `Window.PremiumState == false`. The Label text is `"Premium Status - " .. status`, and the Label is saved to `Window.PremiumTabLabel`.
- Spawns a task that every `0.4s` mirrors `Window.PremiumStatus` (or `"Freemium"`) onto the label via `PremLabel:SetText` as a safety net.

> **Gotchas**
> - Must be called on the object returned by `CreateSettingsPage` (which carries `.SettingsPage`), or on something whose `.SettingsPage`/`.Page` resolves to the settings page.
> - The Premium sub-tab is one-column (its `RightColumn` is destroyed), so the section uses `Side = 1`.
> - With no `Window.PurchaseURL`, there is no purchase button; with no `Window.ScriptId`, there is no key textbox or redeem button — the tab can therefore show only a status label.

```lua
local SettingsPage = Window:CreateSettingsPage()
local PremiumTab = SettingsPage:CreatePremiumSection()
-- PremiumTab is nil when Window.HasPremiumFeatures is false
```

## Premium System

A premium-gating system on the `Window`. Components created with the `Premium = true` flag are tracked in `Window.PremiumControls`; while the user is **Freemium** an overlay locks those controls, and when premium is granted the overlay is lifted and the saved autoload config is re-applied. Premium can be detected automatically from the Luarmor (LRM) loader (forwarded as `Library.LRMPremium` / `Library.LRMNote`, whose note must contain `prem`), or unlocked by redeeming a key validated against the Luarmor SDK (loaded lazily from `https://sdkapi-public.luarmor.net/library.lua` using `Window.ScriptId`). A valid key is persisted to `Window.KeyFile` (trimmed) and re-applied on next launch. The Window also shows a Premium/Freemium status badge whose styling updates with status.

These are methods on the `Window` object returned by `Library:Window(...)`. Call as `Window:SetStatus(...)`, `Window:RedeemKey(...)`, etc. They are not constructors and register no `.Flag`.

### Arguments

The premium methods take direct arguments rather than a single options table. The arguments across the developer-facing methods are:

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `StatusType` | `string` | `"Freemium"` (when nil) | Passed to `Window:SetStatus`. Use `"Premium"` to mark premium, `"Freemium"` otherwise. Stored as `Window.PremiumStatus`. |
| `State` | `boolean` | _(required)_ | Passed to `Window:UpdatePrem`. Coerced to boolean. **Inverted semantics:** `true` = LOCK (still freemium), `false` = UNLOCK. Stored as `Window.PremiumState`. |
| `Feature` | `string` | `nil` (optional) | Passed to `Window:ShowUpgradePrompt`. The feature name shown in the "Premium Required" dialog description. |
| `Key` | `string` | _(required)_ | Passed to `Window:RedeemKey` / `Window:CheckPremiumKey` / `Window:_SavePremiumKey`. The premium key to validate/persist. |
| `Label` | `object with :SetText` | `nil` (optional) | Passed to `Window:RedeemKey`. Any object exposing `:SetText`; set to `Premium Status - Premium` or `Premium Status - Invalid Key`. |

### Methods

Developer-facing surface:

- `Window:SetStatus(StatusType)` — Sets `Window.PremiumStatus` to `StatusType` (defaults to `"Freemium"` if nil). If `Window.PremiumTabLabel:SetText` exists, updates the Premium sub-tab label to `Premium Status - <status>` (wrapped in `pcall`), then calls `Window:ApplyStatusStyle()` (also `pcall`'d). Returns nothing.
- `Window:UpdatePrem(State)` — Coerces `State` to boolean, stores it as `Window.PremiumState`, then iterates `Window.PremiumControls` and calls `Control:UpdatePrem(IsEnabled)` only on controls that have **both** an `UpdatePrem` method **and** the `_OriginallyPremium` flag. `State = true` means LOCK (still freemium); `State = false` means UNLOCK. Returns nothing.
- `Window:ApplyStatusStyle()` — Restyles the status badge based on `Window.PremiumStatus == "Premium"`. Premium: enables `StatusBadgeGradient`, white stroke (Transparency `0`), shows `StatusIconHolder`, sets `StatusText` to `Premium` at `x=33` with light color. Freemium: disables gradient, gray stroke (Transparency `0.25`), hides icon, sets `StatusText` to `Freemium` at `x=12`. No-op (early return) if `Window.Items['StatusBadge']` is absent. Returns nothing; also called once at the end of window construction.
- `Window:ShowUpgradePrompt(Feature)` — Opens a `Window:Dialog` titled `Premium Required` whose description names `Feature` (optional string) as a Premium feature. Adds a `Copy Link` button (only if `Window.PurchaseURL` is set) that copies the URL via `setclipboard`/`toclipboard` and notifies, a `Close` button, and — only if `Window.ScriptId` is set — a secondary action `Bought a key?` (via `Dialog:AddSecondaryAction`) that opens `ShowKeyRedemptionDialog`. Returns the Dialog object.
- `Window:ShowKeyRedemptionDialog()` — Opens a `Window:Dialog` titled `Redeem Key` with a textbox (`Dialog:AddTextbox`) to paste a key. The `Redeem` button defers, trims whitespace from the entered value, error-notifies on empty input, else calls `CheckPremiumKey`; on `KEY_VALID` it sets status Premium, `UpdatePrem(false)`, saves via `_SavePremiumKey`, and notifies success; on failure notifies error. Also has a `Cancel` button. Returns the Dialog object.
- `Window:LoadPremiumAPI()` — Lazily loads the Luarmor SDK. Returns `false` if `Window.ScriptId` is unset; returns the cached `Window.PremiumAPI` if already loaded. Otherwise `loadstring(game:HttpGet('https://sdkapi-public.luarmor.net/library.lua'))()` inside `pcall`, sets `api.script_id = Window.ScriptId`, caches it as `Window.PremiumAPI`, and returns it; returns `nil` on failure.
- `Window:CheckPremiumKey(Key)` — Validates `Key` against the Luarmor SDK via `LoadPremiumAPI`. Returns `(nil, 'API unavailable')` if the api or `api.check_key` is missing. Calls `api.check_key(Key)` in `pcall`; returns `(nil, 'Request failed')` if it errors or the result isn't a table. On success returns `(res.code, res)` where `res.code` is the SDK code string (e.g. `'KEY_VALID'`) and `res` is the raw result table. Does **not** modify status.
- `Window:ApplySavedPremiumKey()` — Returns `false` early if `Window.KeyFile`/`isfile` are unavailable or the file is missing. Reads the file (`pcall readfile`), returns `false` on empty/error, trims whitespace, re-validates via `CheckPremiumKey`. On `'KEY_VALID'`: sets Premium status, `UpdatePrem(false)`, re-applies autoload, rewrites the normalized key to disk if the trimmed form differed from the raw contents, returns `true`. Otherwise returns `false`.
- `Window:RedeemKey(Key, Label)` — Programmatically redeems a premium `Key`. `Label` (optional) is any object with `:SetText`; it is set to `Premium Status - Premium` or `Premium Status - Invalid Key`. On empty/nil `Key`: sets Label text, notifies, returns `false`. Calls `CheckPremiumKey(Key)`; on `'KEY_VALID'` sets Premium status, `UpdatePrem(false)`, re-applies autoload, saves via `_SavePremiumKey(Key)`, sets Label, notifies success, returns `true`; else sets Label, notifies error, returns `false`. **Note:** `RedeemKey` does NOT trim `Key` itself — trimming happens inside `_SavePremiumKey`.
- `Window:DetectInitialPremium()` — Reads `Library.LRMPremium` / `Library.LRMNote`; `isPrem` is true only when both are present and `tostring(note):lower()` contains `prem`. Calls `SetStatus(Premium/Freemium)` and `UpdatePrem(not isPrem)`. If premium, re-applies autoload; otherwise starts the ~15s watchdog for late LRM auth. Returns the boolean `isPrem`.

Internal helpers (underscore-prefixed):

- `Window:_RefreshBadgeVisibility()` — Sets the `StatusBadge` Instance `Visible` to `Window.HasPremiumFeatures` if the badge exists. Returns nothing.
- `Window:_SavePremiumKey(Key)` — Centralized writer for the saved key. Returns `false` if `Key` is not a non-empty string, if its trimmed form is empty, or if `Window.KeyFile` is unset. Ensures `Library.Directory` exists (`makefolder`, `pcall`), then `writefile`'s the **TRIMMED** key to `Window.KeyFile` (`pcall`). Returns the boolean success of the write. This is where key trimming actually happens for `RedeemKey` and the redemption dialog.
- `Window:_ReapplyAutoLoadAfterPremium()` — Runs `Library:CheckForAutoLoad()` once (guarded by `Window._autoLoadReplayed`, deferred + `pcall`) so premium-gated toggles get their saved autoload values applied after premium is granted (LRM may authenticate after the initial autoload pass). Returns nothing.
- `Window:_StartPremiumWatchdog()` — Spawns a polling loop (guarded by `Window._premWatchdog`) that checks every `0.5s` for up to 30 attempts (~15s) for `Library.LRMPremium`/`LRMNote` with a note containing `prem`; on a hit it sets status Premium, `UpdatePrem(false)`, re-applies autoload, and exits. Returns nothing.

**Callback:** n/a — the premium methods take direct arguments (`StatusType`, `State`, `Feature`, `Key`, `Label`) rather than user callbacks. The internally-created Dialog buttons (`Copy Link`, `Close`, `Redeem`, `Cancel`) receive no arguments; the redemption textbox callback receives the typed `Value` (string). For `RedeemKey`, the optional `Label` is whatever object you pass and only needs a `:SetText` method.

> **Gotchas**
> - **`UpdatePrem` semantics are inverted:** pass `false` to UNLOCK premium controls and `true` to LOCK them. The code calls `Window:UpdatePrem(false)` after granting premium and `Window:UpdatePrem(not isPrem)` on detection.
> - A control is only affected by lock/unlock if it has the internal `_OriginallyPremium` flag (set when created with `Premium = true`) and is registered in `Window.PremiumControls`.
> - Key validation requires `Window.ScriptId`; without it `LoadPremiumAPI` returns `false` and `CheckPremiumKey` returns `(nil, 'API unavailable')`. The SDK is fetched from `https://sdkapi-public.luarmor.net/library.lua` and cached as `Window.PremiumAPI`.
> - Saved keys are written to `Window.KeyFile` (developer-configurable; default referenced as `AtherHub/key.txt`). Trimming of surrounding whitespace occurs in `_SavePremiumKey`, not in `RedeemKey`.
> - `ShowUpgradePrompt` only shows `Copy Link` when `Window.PurchaseURL` exists, and only the `Bought a key?` secondary action when `Window.ScriptId` exists.
> - Premium can also be granted automatically with no key via the LRM loader forwarding `Library.LRMPremium`/`LRMNote` (note containing `prem`); `DetectInitialPremium` plus the internal watchdog handle late async authentication.
> - `CheckPremiumKey` returns **two** values (`code, res`). `RedeemKey` captures both; `ShowKeyRedemptionDialog` only uses the first.

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

---

See also: [Config & Flags](config-and-flags.md) · [Theming](theming.md) · [Colorpicker](pickers.md) · [README index](../README.md)
