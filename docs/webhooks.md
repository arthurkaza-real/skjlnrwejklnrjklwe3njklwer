# Discord Webhooks

The Webhook system lets a [Window](window.md) host a dedicated Discord-integration page that owns a webhook URL, a bot identity (username/avatar), and a bounded outgoing HTTP queue. Inside that page you add **WebhookSections**: each renders a live Discord-style embed preview and can fire that embed to the configured URL, gated by its own enable toggle, embed fields, pre-send filters, cooldown, dedup, and an optional `@everyone` mention. This page documents `Window:WebhookPage(Params)` and every method on the page, plus the `WebhookSection` builders (`Field`, `Filter`, `Thumbnail`, `SetColor`, `SetSample`, `Fire`, `Test`) and their argument tables.

## WebhookPage

Creates a dedicated Discord-integration page. Internally it builds a standard Library [Page](pages-and-sections.md) (sidebar entry + icon, with Search forced off), creates one hidden internal SubPage (`_webhook_internal`, `DisplayName=false`) that holds the two content columns, and hides the page's SubPages tab strip (`Page.Items['SubPages'].Instance.Visible=false`). In the space normally used by the tab strip it builds a header Frame containing a "Webhook URL" TextBox and a gradient-outlined "Test Webhook" button. The page owns the shared `_WebhookConfig` (URL/Username/AvatarURL) and a bounded outgoing HTTP queue (max 20 entries, oldest dropped via `PageEnqueueWebhook`) used by all of its sections. WebhookSections added through the overridden `:Section` are placed into the two columns of the internal SubPage.

`Constructor: Window:WebhookPage(Params) -> Page`

> The returned object is the underlying `Library.Page(Self, {...})` Page, extended with webhook state: `Page._WebhookConfig = {URL, Username, AvatarURL}`, `Page._WebhookSections` (array, initially `{}`), `Page._WebhookQueue` (`{}`), `Page._WebhookQueueRunning` (`false`), and `Page._InternalSubPage` (the hidden two-column SubPage). `Page.Section` is overridden to build a WebhookSection. The URL is registered under `URLFlag` (`Flags[urlFlag]`) and `SetFlags[urlFlag]=setURL` for config persistence. The methods `SetURL`/`GetURL`/`SetUsername`/`SetAvatarURL`/`TestAll`/`Enqueue` are attached.

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | string | `"Webhooks"` | Page name shown in the sidebar. Forwarded to `Library.Page` as `Name`. |
| `Description` | string | `"Discord integration"` | Page description. Forwarded to `Library.Page` as `Description`. |
| `Icon` | string | `"lucide:webhook"` | Sidebar/page icon. Forwarded to `Library.Page`, and also reused as the internal SubPage's `Icon`. |
| `URL` | string | `""` | Initial Discord webhook URL. Stored in `_WebhookConfig.URL` and shown in the header TextBox (`TextBox.Text` is set from `_WebhookConfig.URL` at build time). Additionally, if `Params.URL` is non-nil and non-empty, `setURL(Params.URL)` is invoked at construction so the url flag is registered immediately. |
| `Username` | string | `"AtherHub"` | Bot username sent as the `username` field in every webhook body built by this page and its sections. Stored in `_WebhookConfig.Username`. |
| `AvatarURL` | string | `""` | Bot avatar URL. Stored in `_WebhookConfig.AvatarURL`. Sent as `avatar_url` in the body only when non-empty. |
| `URLFlag` | string | `"webhook/url"` | Flag key used to persist the webhook URL for config save/load. `SetFlags[URLFlag]` is wired to `setURL`, so loading a saved config restores the URL. See [Config & Flags](config-and-flags.md). |

### Methods

- `Page:Section(SectionParams)` — Overridden section builder. Instead of a standard section it returns a [WebhookSection](#webhooksection) hosted in one column of the page's internal SubPage. Implemented as `BuildWebhookSection(self, InternalSubPage, SectionParams)`.
- `Page:SetURL(url)` — Sets the webhook URL programmatically by calling the internal `setURL(url)`: coerces to string (`tostring(value or "")`, so `nil -> ""`), stores in `_WebhookConfig.URL`, sets `Flags[URLFlag]=value`, and updates the header TextBox text if it differs. Does not refresh previews.
- `Page:GetURL()` — Returns the current webhook URL string from `Page._WebhookConfig.URL`.
- `Page:SetUsername(name)` — Sets `_WebhookConfig.Username` (`tostring(name or "Webhook")`, so `nil`/`false -> "Webhook"`) and calls `RefreshPreview` on every registered section so the displayed username updates.
- `Page:SetAvatarURL(url)` — Sets `_WebhookConfig.AvatarURL` (`tostring(url or "")`, so `nil -> ""`). Empty means no `avatar_url` is included in sent bodies. Does not refresh previews.
- `Page:TestAll()` — Iterates every registered WebhookSection and calls `sec:Test()` on each, each wrapped in `pcall(function() sec:Test() end)`. Each Test sends a sample embed only for sections that are enabled and have a URL set.
- `Page:Enqueue(body)` — Queues a raw webhook body table via `PageEnqueueWebhook(Page, body)` and starts the queue runner. Returns `true` if queued, or `false` when no URL is configured. `body` is the raw Discord-webhook-shaped table (e.g. `{username=..., embeds={...}, avatar_url=..., content=...}`).

**Callback:** WebhookPage itself takes no `Callback` param. The header "Test Webhook" button is built-in: when clicked with a URL set it enqueues a fixed test embed — `{title="Webhook Test", description="If you can see this, your webhook is wired up.", color=ColorToInt(Accent Start), footer={text="Sent by "..Username}, timestamp}` — using the page Username (and `avatar_url` when `AvatarURL` is set); it shows a Library notify but invokes no user callback. The URL TextBox calls `setURL` on `FocusLost` (saves on Enter/click-out).

### Gotchas

- Forces `Search=false` on the underlying `Library.Page` and sets `Page.Items['SubPages'].Instance.Visible=false` so the page looks flat.
- Only `Name`, `Description`, `Icon` (and `Search=false`) are forwarded to `Library.Page`; `Icon` is also reused for the internal SubPage.
- The header is a Frame at Position `(15,12)`, Size `(1,-30, 0,55)`, ZIndex 4, built into `Page.Items['Page'].Instance`; it holds the URL background Frame and the Test button via a horizontal `UIListLayout`. (Source comment says "75px" but the actual frame top is 12px and height 55px.)
- The internal SubPage columns get `PaddingTop=16` plus an inner 6px pad on the side touching the divider (left column `PaddingRight=6`, right column `PaddingLeft=6`) so section enable-strokes are not clipped.
- `_WebhookConfig` defaults: `URL=""`, `Username="AtherHub"`, `AvatarURL=""`. These are the source of `username`/`avatar_url`/`content` for every body sent by this page and its sections.
- `PageEnqueueWebhook` caps the queue at 20 pending entries: while `#queue >= 20` it removes the oldest, then inserts `{url, body}` and starts `PageRunQueue`. Returns `false` (does not enqueue) if the page URL is empty.
- `setURL` is also wired to `SetFlags[urlFlag]` so config load restores the URL (and the TextBox text).

### Example

```lua
local Window = Library:Window({ Name = "My Hub" })
local Webhooks = Window:WebhookPage({
    Name = "Webhooks",
    Description = "Discord integration",
    Icon = "lucide:webhook",
    URL = "https://discord.com/api/webhooks/123/abc",
    Username = "MyHubBot",
    AvatarURL = "",
    URLFlag = "webhook/url",
})

Webhooks:SetUsername("RenamedBot")
print(Webhooks:GetURL())

local Section = Webhooks:Section({ Name = "Catches", Side = 1 })
-- ... configure section ...
Webhooks:TestAll()
```

## WebhookSection

A section inside a [WebhookPage](#webhookpage) that renders a live Discord-style embed preview and can fire that embed to the page's webhook URL. It has its own enable toggle (animated gradient knob/pill + animated gradient border that gates all firing), supports configurable embed metadata (title/footer/color/description/thumbnail), declarative embed Fields (each optionally gated by an auto-created Toggle), pre-send Filters, cooldown and dedup gating, and an optional `@everyone` mention toggle. Standard Library components ([Toggle](components.md)/[Dropdown](pickers.md)/[Slider](components.md)/[Textbox](components.md)/[Label](display-elements.md)/[Paragraph](display-elements.md) etc.) can be added to it normally via `Section.Items['Content']`; for Toggle/Dropdown/Slider/Textbox the section overrides the constructor so changing them auto-refreshes the preview (deferred, skipped while the page is inactive). The section is a `setmetatable({...}, Library)` object.

`Builder: WebhookPage:Section(Params) -> WebhookSection`

> Built via `BuildWebhookSection(WebhookPage, HostSubPage, Params)`. The section is appended to `WebhookPage._WebhookSections`. The enable state is registered under `EnableFlag` (`Flags` + `SetFlags`); when `EveryoneOption` is set, the `@everyone` state is registered under `'<base>/everyone'`. Standard component builders (`Section:Toggle/Dropdown/Slider/Textbox/Label/Paragraph/...`) work on it via `Section.Items['Content']`.

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | string | `"Webhook Section"` | Section title shown in the section header (TitleLabel). Also the default for `_TitleEmbed` when `TitleEmbed` is not set, and the base for auto-derived flag keys when `Flag` is not set. |
| `Description` | string | `nil` | Optional description text rendered below the section's top row (DescriptionLabel). The label is only created when `Description` is non-nil. |
| `Side` | number | `1` | Which column of the host internal SubPage holds the section: indexes `HostSubPage.ColumnsData[Side]`. `1` = left column, `2` = right column. |
| `TitleEmbed` | string \| function | `Params.Name or "Webhook"` | Discord embed title. May be a string (resolved via `ResolveValue`, supporting `{var}` substitution) or a `function(payload, values)` returning the title. Stored as `_TitleEmbed = Params.TitleEmbed or Params.Name or "Webhook"`. An empty resolved title omits the embed title. |
| `Footer` | string \| function | `""` | Embed footer text. String (with `{var}` substitution) or `function(payload, values)`. Stored as `_Footer`. An empty resolved footer is omitted from the embed. |
| `Color` | number \| Color3 | `0xAF667E` | Embed accent color. Accepts an integer (e.g. `0xAF667E`) or a Color3 (converted to int via `ColorToInt` at build time). Stored as `_Color`; editable later with `:SetColor`. |
| `ThumbnailURL` | string \| number | `nil` | Fallback embed thumbnail used when no `:Thumbnail` source resolves. Stored as `_ThumbnailURL`. Resolved via `ResolveThumbnailURL`: accepts a full `https` URL, `rbxthumb://` URL, `rbxassetid://N`, or a raw numeric asset id. |
| `EmbedDescription` | string \| function | `nil` | Embed description (body text under the title). String (with `{var}` substitution) or `function(payload, values)`. Stored as `_Description`; only resolved/included when non-nil and non-empty. |
| `EveryoneOption` | boolean | `false` | When truthy (coerced to a strict boolean via `and true or false`), renders an "@everyone mention" toggle row at the bottom of the section (LayoutOrder 10000). When that toggle is on, the built body includes `content="@everyone"`. A `'<base>/everyone'` flag is registered. |
| `Sample` | table | `{ }` | Sample payload table used to render the preview and as the payload for `:Test`. Stored as `_Sample`. Settable via `:SetSample`, readable via `:GetSample`. |
| `Cooldown` | number | `0` | Minimum seconds between successful `:Fire` calls. Stored as `_Cooldown = tonumber(Params.Cooldown) or 0`. `0` disables cooldown. Does not affect `:Test`. |
| `Dedup` | function | `nil` | Optional dedup `function(payload, values)` returning a signature. Stored as `_Dedup`. On `:Fire` it is `pcall`'d; if it returns a signature equal to the previous fire's signature, `:Fire` is blocked with `"dedup"`; otherwise the new signature is remembered. Ignored by `:Test`. |
| `OnFire` | function | `nil` | Stored as `_OnFire`. Called as `OnFire(payload, body)` via `Library:SafeCall` when a `:Fire` passes all gates, just before the body is enqueued (`body` is the built Discord webhook table). |
| `EnableFlag` | string | `(Params.Flag or Params.Name or "Webhook").."/enabled"` | Flag key persisting the section's enable state for config save/load. If not given it is derived from `Flag`, then `Name`, then `"Webhook"`, suffixed with `'/enabled'`. Stored as `Section._EnableFlag` and wired to `SetFlags`. |
| `Flag` | string | `nil` | Base flag key for this section. Used as the prefix for auto-derived keys: enable flag (`'<base>/enabled'`), `@everyone` flag (`'<base>/everyone'`), and per-field include toggles (`'<base>/include/<sanitized name>'`). The base falls back to `Name`, then `"Webhook"`. |
| `Default` | boolean | `nil` | Initial enabled state of the section. Checked first; if nil, `DefaultEnabled` is used; if still nil, defaults to `false`. Applied via `setEnabled` at construction (which registers the enable flag). |
| `DefaultEnabled` | boolean | `nil` | Alternate initial enabled state, used only when `Default` is nil. If both `Default` and `DefaultEnabled` are nil the section starts disabled. |
| `EnableCallback` | function | `nil` | Read as `Params.EnableCallback` inside `setEnabled`. Called as `EnableCallback(enabled)` via `Library:SafeCall` whenever the section's enable state changes (toggle click, `:SetEnabled`, construction default, or flag load). Receives a strict boolean. |

### Methods

- `Section:Field(FieldParams)` — Adds a Discord embed field and returns the internal field table. `FieldParams`: `Name` (string\|function, default `"Field"`) field label, supports `{var}`/`function(payload,values)`; `Value` (string\|function, default `""`) field value, `{var}`/function; `Inline` (boolean, default `false`); `ShowIf` (`function(payload,values)->bool`) extra gate evaluated after the auto-toggle; `Empty` (string, used when the resolved value is nil/empty; the embed falls back to `Empty` or `"—"`); `Order` (number, default `#fields+1`) sort order; `Toggle` (`true | string | table`) when set and not `false`, auto-creates a `Section:Toggle` gating this field in preview AND embed (`true` -> "Include `<Name>`", string -> custom label, table -> merged Toggle params incl. `Premium`/`Callback`); `ToggleDefault` (boolean) initial toggle state, defaults to `toggleParams.Default` when the Toggle table sets one, otherwise `true`; `ToggleFlag` (string) overrides the auto-derived include flag (else `toggleParams.Flag`, else `'<base>/include/<sanitized lowercased name>'`). After insert it re-sorts `_Fields` by `Order` and calls `RefreshPreview`.
- `Section:Filter(FilterParams)` — Adds a pre-send filter and returns the filter table; returns `nil` (silent no-op) when `FilterParams.Condition` is not a function. `FilterParams`: `Condition` (`function(payload,values)->bool`, **REQUIRED**) must return truthy for `:Fire` to proceed; `Name` (string, default `"Filter"`) used in the block reason `'filter:<Name>'`. All filters must pass (AND). Filters are ignored by `:Test`. Does NOT call `RefreshPreview`.
- `Section:Thumbnail(ThumbParams)` — Sets the embed thumbnail source. Source is read as `ThumbParams.Source or ThumbParams.Asset or ThumbParams.URL` and may be a full URL, `rbxthumb://`, `rbxassetid://N`, a raw numeric id, or a `function(payload,values)` returning one of those. Stores `Section._Thumbnail = {Source=...}`, calls `RefreshPreview`, and returns that table. Falls back to the constructor `ThumbnailURL` when this resolves empty.
- `Section:SetColor(color)` — Sets `Section._Color` (integer or Color3; Color3 is converted to int when the embed is built) and calls `RefreshPreview`.
- `Section:SetSample(sample)` — Replaces `Section._Sample` (nil becomes an empty table) used for the preview and `:Test`, then calls `RefreshPreview`.
- `Section:GetSample()` — Returns the current `Section._Sample` table.
- `Section:Fire(payload)` — Builds and queues the embed for the given payload (defaults to `{}`). Returns `ok, reason`. Gates in order: section disabled -> `false, "section disabled"`; page `_WebhookConfig.URL` nil/empty -> `false, "no url"`; cooldown active (`_Cooldown>0` and within window) -> `false, "cooldown"`; dedup signature matches previous -> `false, "dedup"`; any filter `Condition` fails or errors -> `false, "filter:<Name>"`. On success: builds body via `BuildEmbedPayload`, records `_LastFireTime`, calls `OnFire(payload, body)` via `SafeCall`, enqueues via `PageEnqueueWebhook`, and returns `queued, (queued and "queued" or "no url")`.
- `Section:Test()` — Sends the embed built from `Section._Sample`, ignoring filters/cooldown/dedup but still requiring the section enabled and a non-empty page URL. Returns `false, "section disabled"` (with a notify) when disabled; `false, "no url"` (with a notify) when no URL; otherwise enqueues and returns `queued, (queued and "queued" or "no url")`, also showing a Library notify.
- `Section:RefreshPreview()` — Calls the internal `RefreshPreview(Section)`, re-rendering the Discord-style preview frame from the current sample, fields, include-toggles, color, thumbnail, and the parent page username.
- `Section:GetValues()` — Returns a snapshot table of all current Flags values (copied key/value), plus `out._enabled` set to `Section._Enabled`. Used internally as the `values` argument passed to field/filter/value/dedup functions.
- `Section:SetEnabled(state)` — Programmatically enables/disables the section via `setEnabled(state and true or false)`: updates `_Enabled`, sets `Flags[EnableFlag]`, animates the knob/border, and fires `EnableCallback`. Gates whether `:Fire`/`:Test` will send.
- `Section:IsEnabled()` — Returns `Section._Enabled` (boolean).

**Callback:** There is no single `Callback` param. `EnableCallback` receives the new enabled state as a strict boolean. `OnFire` receives `(payload, body)` where `payload` is the table passed to `:Fire` and `body` is the constructed Discord webhook table. Field/Filter/Thumbnail `Source` / `TitleEmbed` / `Footer` / `EmbedDescription` function values all receive `(payload, values)` where `values = Section:GetValues()`. `Dedup` receives `(payload, values)` and returns a comparison signature. Auto-created include toggles (from Field's `Toggle` option) and user-added Toggle/Dropdown/Slider/Textbox wrap the user `Callback` so the preview refreshes after it runs.

### Gotchas

- Initial enable state reads BOTH `Default` and `DefaultEnabled`: `Default` wins, then `DefaultEnabled`, else `false`; applied via `setEnabled` at construction.
- The `@everyone` state always initializes to `false` (`setEveryone(false)`); `Default`/`DefaultEnabled` do NOT affect it. When enabled the body gets `content="@everyone"` and `Flags['<base>/everyone']` is set; the flag is restorable via `SetFlags`.
- Embed `username`/`avatar_url` always come from the parent `WebhookPage._WebhookConfig` (set via `Page:SetUsername` / `Page:SetAvatarURL`), NOT from section params; `avatar_url` is included only when `AvatarURL` is non-empty.
- Per-field auto-toggles are created with `Section:Toggle` and render in the section's Content area in declaration order; their flag defaults to `'<base>/include/<sanitized lowercased field name>'` (sanitize = `gsub('%W','_'):lower()`). The toggle gates the field in BOTH preview and sent embed (`Flags[autoFlag]==true`).
- String values for `TitleEmbed`/`Footer`/`EmbedDescription`/Field `Name`/Field `Value` are resolved via `ResolveValue` and support `{var}` substitution; functions receive `(payload, values)`.
- Adding a Toggle/Dropdown/Slider/Textbox via the section overrides `Library[kind]` for this section instance: it wraps `params.Callback` (or `params.callback`) so the preview is scheduled to refresh (`task.defer`, coalesced) after the user callback runs; the rebuild is skipped while `Section.WebhookPage.Active == false`.
- Empty-field handling: when a field's resolved `Value` is nil or `""`, it is replaced by `field.Empty` or `"—"` (em dash).
- Cooldown is `tonumber`-coerced (default `0`). Filter `Condition` is REQUIRED (a function) or `:Filter` is a silent no-op returning `nil`. `:Filter` does not refresh the preview.
- Both `:Test` and `:Fire` hard-require an enabled section AND a non-empty page `_WebhookConfig.URL` before sending; the queue is bounded at 20 (oldest dropped).

### Example

```lua
local Webhooks = Window:WebhookPage({ Name = "Webhooks", URL = "https://discord.com/api/webhooks/..." })

local Section = Webhooks:Section({
    Name = "Rare Catch",
    Side = 1,
    Color = 0xAF667E,
    EveryoneOption = true,
    Cooldown = 5,
    Sample = { fish = "Megalodon", weight = 9001 },
    Flag = "webhook/rarecatch",
    Default = false,
    EnableCallback = function(enabled) print("section enabled:", enabled) end,
    OnFire = function(payload, body) print("sending", payload.fish) end,
})

Section:Field({
    Name = "Fish",
    Value = function(payload, values) return payload.fish end,
    Inline = true,
    Toggle = "Show fish name",
    ToggleDefault = true,
})
Section:Field({ Name = "Weight", Value = "{weight} kg", Inline = true, Empty = "unknown" })

Section:Thumbnail({ Source = "rbxassetid://133218922939038" })

Section:Filter({
    Name = "min weight",
    Condition = function(payload, values) return (payload.weight or 0) >= 100 end,
})

Section:Toggle({ Name = "Ping on rare", Flag = "webhook/rarecatch/ping", Default = true })

if Section:IsEnabled() then
    Section:Fire({ fish = "Megalodon", weight = 9001 })
end
Section:Test()
```

## See also

[Pages & Sections](pages-and-sections.md) · [Theming](theming.md) · [Config & Flags](config-and-flags.md) · [Index](../README.md)
