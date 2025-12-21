--[[
	Rivals UI - Lucide-Themed Exploit UI Library (Improved v23 - Section Tab Height + Background Fix)
	- Synapse X baseline (works on most executors that support Roblox Lua + UI)
	- Desktop-style window with sidebar tabs, top bar, search, and Lucide icon support (via external Lucide icon atlas)
	- Fully modular components + named config save/load ready
	- Demo() at bottom shows usage of every component and config features

	USAGE:
	loadstring(game:HttpGet("YOUR_GIST_OR_WEBHOST_URL"))().Demo()

	This is a single-file library; you can paste it directly into your executor.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------------------
-- Utility
---------------------------------------------------------------------

local function deepCopy(tbl)
	local t = {}
	for k, v in pairs(tbl) do
		t[k] = type(v) == "table" and deepCopy(v) or v
	end
	return t
end

local function tween(o, ti, props)
	local t = TweenService:Create(o, ti, props)
	t:Play()
	return t
end

local function makeDraggable(rootFrame, dragFrames)
    dragFrames = dragFrames or { rootFrame }
    if typeof(dragFrames) ~= "table" then
        dragFrames = { dragFrames }
    end

    local dragging = false
    local dragStart
    local startPos

    local function update(input)
        if not dragging then return end
        local delta = input.Position - dragStart
        rootFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    for _, dragHandle in ipairs(dragFrames) do
        if not dragHandle then continue end

        dragHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if input.UserInputState ~= Enum.UserInputState.Begin then return end
                dragging = true
                dragStart = input.Position
                startPos = rootFrame.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
    end

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            update(input)
        end
    end)
end

local function createRoundCorner(radius, parent)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function applyStroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness or 1
	s.Color = color or Color3.fromRGB(255, 255, 255)
	s.Transparency = transparency or 0.5
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

-- Mobile handling:
-- We SHOULD NOT shrink the window/columns/sections (layout space) on mobile.
-- Instead, keep the window at its configured size (so sections still take up full space)
-- and only scale *content* (text / controls) so everything remains readable.
--
-- Implementation:
-- 1) No ScreenGui UIScale (that would shrink the whole layout/sections).
-- 2) Add a WindowContent UIScale inside Main, scaling only Content + Sidebar children.
--    That keeps the window/section sizing intact while making controls smaller.
local function applyMobileContentScale(mainFrame, contentFrame, sidebarFrame, baseSize)
	local cam = workspace.CurrentCamera
	if not cam or not mainFrame or not contentFrame or not sidebarFrame then return nil end

	local vp = cam.ViewportSize
	local baseW = (typeof(baseSize) == "UDim2" and baseSize.X.Offset) or 900
	local baseH = (typeof(baseSize) == "UDim2" and baseSize.Y.Offset) or 550

	-- Decide if scaling is needed based on viewport vs base window.
	-- Use min dimension so landscape/portrait both behave.
	local limit = math.min(vp.X, vp.Y) * 0.9
	local baseMax = math.max(baseW, baseH)

	-- If screen is large enough, remove scaling.
	if limit >= baseMax then
		local existing = mainFrame:FindFirstChild("RivalsUI_ContentScale")
		if existing and existing:IsA("UIScale") then
			existing:Destroy()
		end
		return nil
	end

	local scale = math.clamp(limit / baseMax, 0.65, 1)

	local uiScale = mainFrame:FindFirstChild("RivalsUI_ContentScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Name = "RivalsUI_ContentScale"
		uiScale.Parent = mainFrame
	end
	uiScale.Scale = scale

	-- IMPORTANT: We do NOT want the whole window to scale down.
	-- So we counteract the scale on Main itself by applying inverse scaling to Main's descendants?
	-- Roblox UIScale affects all descendants, not self size. To keep sections taking up full
	-- space, we leave window size unchanged; scaling only makes child sizes *appear* smaller.
	-- Layout space remains defined by original UDim2 sizes of frames.
	-- This is desired: sections/columns still have same pixel allocation.

	return uiScale
end

---------------------------------------------------------------------
-- Icon Loader (Lucide / Craft / Geist / SF Symbols) - v2 integration
---------------------------------------------------------------------

local IconsURL = "https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"
local Icons

pcall(function()
	local src = game.HttpGetAsync and game:HttpGetAsync(IconsURL) or HttpService:GetAsync(IconsURL)
	Icons = loadstring(src)()
end)

if Icons then
	Icons.SetIconsType("lucide")
end

-- CreateIcon fully delegates to Icons.Image just like Creator.Image does
local function CreateIcon(iconName, size, colorOrTheme)
	if Icons then
		local colors = {}
		if typeof(colorOrTheme) == "string" then
			colors = { colorOrTheme }
		elseif typeof(colorOrTheme) == "Color3" then
			colors = { colorOrTheme }
	else
			colors = { Color3.fromRGB(230, 230, 235) }
		end

		local ok, iconObj = pcall(function()
			return Icons.Image({
				Icon = iconName,
				Size = size or UDim2.fromOffset(18, 18),
				Colors = colors,
			})
		end)

		if ok and iconObj and iconObj.IconFrame then
			local frame = iconObj.IconFrame
			frame.BackgroundTransparency = 1
			return frame
		end
	end

	-- fallback if Icons failed or missing
	local img = Instance.new("ImageLabel")
	img.BackgroundTransparency = 1
	img.Size = size or UDim2.fromOffset(18, 18)
	img.ImageColor3 = (typeof(colorOrTheme) == "Color3" and colorOrTheme) or Color3.fromRGB(230, 230, 235)
	img.Image = "rbxassetid://0"
	return img
end

---------------------------------------------------------------------
-- Library Table
---------------------------------------------------------------------

local RivalsUI = {}
RivalsUI.__index = RivalsUI

RivalsUI.Theme = {
	Background = Color3.fromRGB(15, 16, 22),
	Sidebar = Color3.fromRGB(17, 18, 26),
	Topbar = Color3.fromRGB(17, 18, 26),
	Section = Color3.fromRGB(21, 23, 33),
	Accent = Color3.fromRGB(103, 113, 227),
	AccentSoft = Color3.fromRGB(60, 65, 120),
	Text = Color3.fromRGB(235, 236, 243),
	SubText = Color3.fromRGB(150, 153, 173),
	Danger = Color3.fromRGB(235, 86, 86),
	Outline = Color3.fromRGB(32, 34, 50),
	Success = Color3.fromRGB(80, 200, 120),
	Warning = Color3.fromRGB(255, 184, 77),
}

RivalsUI.Config = {
	Folder = "RivalsUI",              -- base folder for this window (can be overridden per-window)
	ConfigsFolderName = "Configs",    -- nested folder containing all named config files
	MetaFile = "Meta.json",           -- stores DefaultConfigName and AutoLoadDefault in base folder
}

RivalsUI.ConfigMeta = {
	DefaultConfigName = nil,
	AutoLoadDefault = false,
}

-- keep track of currently open dropdown (only one active at a time)
RivalsUI._activeDropdown = nil

-- notifications holder ref
RivalsUI._notificationHolder = nil

-- last created window (for AutoLoad helper)
RivalsUI._lastWindow = nil

---------------------------------------------------------------------
-- Config Helpers (executor-side, JSON via HttpService)
---------------------------------------------------------------------

local function ensureFolder(path)
	if isfolder and not isfolder(path) then
		makefolder(path)
	end
end

function RivalsUI:SetConfigFolder(folderName)
	self.Config.Folder = tostring(folderName or "RivalsUI")
end

local function getMetaPath()
	return RivalsUI.Config.Folder .. "/" .. (RivalsUI.Config.MetaFile or "Meta.json")
end

local function getConfigsFolder()
	return RivalsUI.Config.Folder .. "/" .. (RivalsUI.Config.ConfigsFolderName or "Configs")
end

function RivalsUI:SaveMeta()
	if not (writefile and isfolder and makefolder) then return end
	ensureFolder(self.Config.Folder)
	writefile(getMetaPath(), HttpService:JSONEncode(self.ConfigMeta))
end

function RivalsUI:LoadMeta()
	if not (readfile and isfile) then return end
	local path = getMetaPath()
	if not isfile(path) then return end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(path))
	end)
	if ok and type(data) == "table" then
		for k, v in pairs(data) do
			self.ConfigMeta[k] = v
		end
	end
end

---------------------------------------------------------------------
-- Object Models
---------------------------------------------------------------------

local Window = {}
Window.__index = Window

local TabGroup = {}
TabGroup.__index = TabGroup

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

local ComponentBase = {}
ComponentBase.__index = ComponentBase

function ComponentBase:__tostring()
	return self.__type or "Component"
end

---------------------------------------------------------------------
-- Notifications (bottom-right, animated)
---------------------------------------------------------------------

local NotificationModule = {
	Width = 300,
	Margin = 16,
	UICorner = 10,
	UIPadding = 10,
	NotificationIndex = 0,
	Notifications = {},
}

local NotificationHolderProto = {}
NotificationHolderProto.__index = NotificationHolderProto

function NotificationModule.Init(parentGui)
	local holder = setmetatable({}, NotificationHolderProto)
	holder.Lower = false

	local frame = Instance.new("Frame")
	frame.Name = "RivalsUI_Notifications"
	frame.AnchorPoint = Vector2.new(1, 1)
	frame.Position = UDim2.new(1, -NotificationModule.Margin, 1, -NotificationModule.Margin)
	-- Use Scale width for mobile responsiveness (30% of screen), clamped by max width
	frame.Size = UDim2.new(0.3, 0, 1, -NotificationModule.Margin * 2)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = false
	frame.Parent = parentGui

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MaxSize = Vector2.new(NotificationModule.Width, 9999)
	sizeConstraint.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	layout.Padding = UDim.new(0, 10) -- slightly more margin between notifications
	layout.Parent = frame

	local padding = Instance.new("UIPadding")
	padding.PaddingBottom = UDim.new(0, 0)
	padding.PaddingTop = UDim.new(0, 0)
	padding.PaddingLeft = UDim.new(0, 0)
	padding.PaddingRight = UDim.new(0, 0)
	padding.Parent = frame

	holder.Frame = frame

	function holder:SetLower(val)
		self.Lower = val and true or false
		-- reserved if you want to shift notifications up later
	end

	return holder
end

function NotificationModule.New(config)
	local Notification = {
		Title = config.Title or "Notification",
		Content = config.Description or config.Content or nil,
		Duration = config.Duration or config.Lifetime or 5,
		CanClose = (config.CanClose == nil) and true or config.CanClose,
		Closed = false,
	}

	NotificationModule.NotificationIndex += 1
	NotificationModule.Notifications[NotificationModule.NotificationIndex] = Notification

	local holder = config.Holder
	if not holder or not holder.Frame then return Notification end

	local mainContainer = Instance.new("Frame")
	mainContainer.BackgroundTransparency = 1
	mainContainer.Size = UDim2.new(1, 0, 0, 0)
	mainContainer.Parent = holder.Frame

	local main = Instance.new("Frame")
	main.Name = "NotificationCard"
	main.Size = UDim2.new(1, 0, 0, 0)
	main.AnchorPoint = Vector2.new(1, 1)
	main.Position = UDim2.new(1, 50, 1, 0)
	main.BackgroundColor3 = RivalsUI.Theme.Section
	main.BorderSizePixel = 0
	main.AutomaticSize = Enum.AutomaticSize.Y
	main.ZIndex = 20
	createRoundCorner(NotificationModule.UICorner, main)
	applyStroke(main, RivalsUI.Theme.Outline, 1, 0.6)
	main.Parent = mainContainer

	local inner = Instance.new("Frame")
	inner.Size = UDim2.new(1, 0, 1, 0)
	inner.BackgroundTransparency = 1
	inner.ZIndex = 21
	inner.Parent = main

	local durationBar = Instance.new("Frame")
	durationBar.Name = "Duration"
	durationBar.Size = UDim2.new(0, 0, 0, 2)
	durationBar.Position = UDim2.new(0, 0, 1, -2)
	durationBar.BackgroundTransparency = 0.2
	durationBar.BackgroundColor3 = RivalsUI.Theme.Accent
	durationBar.BorderSizePixel = 0
	durationBar.ZIndex = 22
	durationBar.Parent = main

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, NotificationModule.UIPadding)
	padding.PaddingBottom = UDim.new(0, NotificationModule.UIPadding + 4)
	padding.PaddingLeft = UDim.new(0, NotificationModule.UIPadding)
	padding.PaddingRight = UDim.new(0, NotificationModule.UIPadding + 4)
	padding.Parent = inner

	local textContainer = Instance.new("Frame")
	textContainer.BackgroundTransparency = 1
	textContainer.Size = UDim2.new(1, 0, 1, 0)
	textContainer.AutomaticSize = Enum.AutomaticSize.Y
	textContainer.ZIndex = 21
	textContainer.Parent = inner

	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 4)
	list.Parent = textContainer

	local titleLabel = Instance.new("TextLabel")
	titleLabel.AutomaticSize = Enum.AutomaticSize.Y
	titleLabel.Size = UDim2.new(1, -20, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 14
	titleLabel.TextColor3 = RivalsUI.Theme.Text
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextWrapped = true
	titleLabel.Text = Notification.Title
	titleLabel.ZIndex = 22
	titleLabel.Parent = textContainer

	if Notification.Content then
		local bodyLabel = Instance.new("TextLabel")
		bodyLabel.AutomaticSize = Enum.AutomaticSize.Y
		bodyLabel.Size = UDim2.new(1, 0, 0, 0)
		bodyLabel.BackgroundTransparency = 1
		bodyLabel.Font = Enum.Font.Gotham
		bodyLabel.TextSize = 13
		bodyLabel.TextColor3 = RivalsUI.Theme.SubText
		bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
		bodyLabel.TextWrapped = true
		bodyLabel.Text = Notification.Content
		bodyLabel.ZIndex = 22
		bodyLabel.Parent = textContainer
	end

	local closeButton
	if Notification.CanClose then
		closeButton = Instance.new("ImageButton")
		closeButton.Size = UDim2.new(0, 16, 0, 16)
		closeButton.AnchorPoint = Vector2.new(1, 0)
		closeButton.Position = UDim2.new(1, -NotificationModule.UIPadding, 0, NotificationModule.UIPadding)
		closeButton.BackgroundTransparency = 1
		closeButton.ZIndex = 23
		closeButton.Parent = main

		local icon = CreateIcon("lucide:x", UDim2.fromOffset(16, 16), RivalsUI.Theme.SubText)
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.new(0.5, 0, 0.5, 0)
		icon.ZIndex = 24
		icon.Parent = closeButton
	end

	function Notification:Close()
		if self.Closed then return end
		self.Closed = true
		local tweenOut1 = TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
			Position = UDim2.new(1, 50, 1, 0),
			BackgroundTransparency = 1,
		})
		local tweenOut2 = TweenService:Create(mainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
			Size = UDim2.new(1, 0, 0, 0),
		})
		tweenOut1:Play()
		tweenOut2:Play()
		tweenOut2.Completed:Wait()
		mainContainer:Destroy()
	end

	task.spawn(function()
		RunService.RenderStepped:Wait()
		local finalHeight = main.AbsoluteSize.Y
		mainContainer.Size = UDim2.new(1, 0, 0, finalHeight)

		local tweenIn1 = TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 0,
		})
		tweenIn1:Play()

		if Notification.Duration and Notification.Duration > 0 then
			TweenService:Create(durationBar, TweenInfo.new(Notification.Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
				Size = UDim2.new(1, 0, 0, 2),
			}):Play()
			wait(Notification.Duration)
			Notification:Close()
		end
	end)

	if closeButton then
		closeButton.MouseButton1Click:Connect(function()
			Notification:Close()
		end)
	end

	return Notification
end

function Window:Notify(opts)
    opts = opts or {}
    
    local holder = self._notificationHolder or RivalsUI._notificationHolder
    if not holder or not holder.Frame then return end

    return NotificationModule.New({
        Title = opts.Title or (self.Settings and self.Settings.Title) or "Rivals UI",
        Description = opts.Description or "",
        Duration = opts.Lifetime or 4,
        CanClose = opts.CanClose,
        Holder = holder,
    })
end

---------------------------------------------------------------------
-- Window Creation
---------------------------------------------------------------------

local minimized = false 

function RivalsUI:IsVisible()
	return not minimized
end

function RivalsUI:Window(opts)
	opts = opts or {}
	local title = opts.Title or "Rivals UI"
	local subtitle = opts.Subtitle or ""
	local size = opts.Size or UDim2.fromOffset(900, 550)
	local keybind = opts.Keybind or Enum.KeyCode.RightControl
	local folder = opts.Folder -- optional custom folder name for this window

	-- apply optional per-window folder override BEFORE any meta operations
	if folder ~= nil then
		self:SetConfigFolder(folder)
	end

	-- load meta for this folder, ensuring DefaultConfigName/AutoLoadDefault are correct
	self:LoadMeta()

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "RivalsUI_Gui"
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.DisplayOrder = 1000 -- keep on top
	ScreenGui.Parent = gethui and gethui() or game:GetService("CoreGui")

	local Main = Instance.new("Frame")
	Main.Name = "MainWindow"
	Main.AnchorPoint = Vector2.new(0.5, 0.5)
	Main.Size = size
	Main.Position = UDim2.new(0.5, 0, 0.5, 0)
	Main.BackgroundColor3 = self.Theme.Background
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = false
	createRoundCorner(10, Main)
	applyStroke(Main, self.Theme.Outline, 1, 0.4)
	Main.Parent = ScreenGui

	-- init notification holder for this gui
    local holder = NotificationModule.Init(ScreenGui)
    self._notificationHolder = holder

	-- Sidebar (scrollable for many tabs)
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 200, 1, 0)
	Sidebar.BackgroundColor3 = self.Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Main
	createRoundCorner(10, Sidebar)
	applyStroke(Sidebar, self.Theme.Outline, 1, 0.6)

	local SidebarHeader = Instance.new("Frame")
	SidebarHeader.Name = "SidebarHeader"
	SidebarHeader.BackgroundTransparency = 1
	SidebarHeader.Size = UDim2.new(1, 0, 0, 80)
	SidebarHeader.Parent = Sidebar

	local SidebarPadding = Instance.new("UIPadding")
	SidebarPadding.PaddingTop = UDim.new(0, 16)
	SidebarPadding.PaddingLeft = UDim.new(0, 14)
	SidebarPadding.PaddingRight = UDim.new(0, 10)
	SidebarPadding.Parent = SidebarHeader

	local BrandLabel = Instance.new("TextLabel")
	BrandLabel.Name = "BrandLabel"
	BrandLabel.BackgroundTransparency = 1
	BrandLabel.Size = UDim2.new(1, -8, 0, 24)
	BrandLabel.Position = UDim2.new(0, 0, 0, 0)
	BrandLabel.Font = Enum.Font.GothamBold
	BrandLabel.TextSize = 17
	BrandLabel.TextXAlignment = Enum.TextXAlignment.Left
	BrandLabel.TextColor3 = self.Theme.Text
	BrandLabel.Text = title
	BrandLabel.Parent = SidebarHeader

	local SubLabel = Instance.new("TextLabel")
	SubLabel.Name = "SubLabel"
	SubLabel.BackgroundTransparency = 1
	SubLabel.Position = UDim2.new(0, 0, 0, 28)
	SubLabel.Size = UDim2.new(1, -8, 0, 8)
	SubLabel.Font = Enum.Font.Gotham
	SubLabel.TextSize = 12
	SubLabel.TextXAlignment = Enum.TextXAlignment.Left
	SubLabel.TextColor3 = self.Theme.SubText
	SubLabel.Text = subtitle
	SubLabel.Parent = SidebarHeader

	local SidebarFooter = Instance.new("Frame")
	SidebarFooter.Name = "SidebarFooter"
	SidebarFooter.AnchorPoint = Vector2.new(0, 1)
	SidebarFooter.Position = UDim2.new(0, 0, 1, -10)
	SidebarFooter.Size = UDim2.new(1, -10, 0, 30)
	SidebarFooter.BackgroundTransparency = 1
	SidebarFooter.Parent = Sidebar

	local FooterPadding = Instance.new("UIPadding")
	FooterPadding.PaddingLeft = UDim.new(0, 14)
	FooterPadding.PaddingRight = UDim.new(0, 10)
	FooterPadding.Parent = SidebarFooter

	-- Player avatar + name
	local FooterContent = Instance.new("Frame")
	FooterContent.BackgroundTransparency = 1
	FooterContent.Size = UDim2.new(1, 0, 1, 0)
	FooterContent.Parent = SidebarFooter

	local FooterLayout = Instance.new("UIListLayout")
	FooterLayout.FillDirection = Enum.FillDirection.Horizontal
	FooterLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	FooterLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	FooterLayout.Padding = UDim.new(0, 6)
	FooterLayout.Parent = FooterContent

	local AvatarHolder = Instance.new("Frame")
	AvatarHolder.Name = "AvatarHolder"
	AvatarHolder.Size = UDim2.new(0, 24, 0, 24)
	AvatarHolder.BackgroundTransparency = 1
	AvatarHolder.Parent = FooterContent

	local AvatarImage = Instance.new("ImageLabel")
	AvatarImage.Name = "AvatarImage"
	AvatarImage.Size = UDim2.new(1, 0, 1, 0)
	AvatarImage.BackgroundTransparency = 1
	AvatarImage.BorderSizePixel = 0
	AvatarImage.Parent = AvatarHolder

	local avatarCorner = Instance.new("UICorner")
	avatarCorner.CornerRadius = UDim.new(1, 0)
	avatarCorner.Parent = AvatarImage

	-- Get headshot from Roblox thumbnails API
	pcall(function()
		local thumbUrl = string.format(
			"https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=%d&height=%d",
			LocalPlayer.UserId,
			420,
			420
		)
		AvatarImage.Image = thumbUrl
	end)

	local UserLabel = Instance.new("TextLabel")
	UserLabel.BackgroundTransparency = 1
	UserLabel.Size = UDim2.new(1, -30, 1, 0)
	UserLabel.Font = Enum.Font.Gotham
	UserLabel.TextSize = 12
	UserLabel.TextXAlignment = Enum.TextXAlignment.Left
	UserLabel.TextWrapped = true
	UserLabel.TextColor3 = self.Theme.SubText
	UserLabel.Text = tostring(LocalPlayer.DisplayName or LocalPlayer.Name)
	UserLabel.Parent = FooterContent

	local UserLabelSizeConstraint = Instance.new("UITextSizeConstraint")
	UserLabelSizeConstraint.MaxTextSize = 14
	UserLabelSizeConstraint.MinTextSize = 10
	UserLabelSizeConstraint.Parent = UserLabel

	-- Scrollable tab list between header and footer
	local TabScroll = Instance.new("ScrollingFrame")
	TabScroll.Name = "TabScroll"
	TabScroll.BackgroundTransparency = 1
	TabScroll.BorderSizePixel = 0
	TabScroll.Position = UDim2.new(0, 0, 0, SidebarHeader.Size.Y.Offset)
	TabScroll.Size = UDim2.new(1, 0, 1, -(SidebarHeader.Size.Y.Offset + 50))
	TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabScroll.ScrollBarThickness = 4
	TabScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 61, 80)
	TabScroll.Parent = Sidebar

	local TabButtonsHolder = Instance.new("Frame")
	TabButtonsHolder.Name = "TabButtonsHolder"
	TabButtonsHolder.BackgroundTransparency = 1
	TabButtonsHolder.Size = UDim2.new(1, 0, 0, 0)
	TabButtonsHolder.Parent = TabScroll

	local TabButtonsLayout = Instance.new("UIListLayout")
	TabButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabButtonsLayout.Padding = UDim.new(0, 6)
	TabButtonsLayout.Parent = TabButtonsHolder

	local TabButtonsPadding = Instance.new("UIPadding")
	TabButtonsPadding.PaddingTop = UDim.new(0, 16)
	TabButtonsPadding.PaddingLeft = UDim.new(0, 8)
	TabButtonsPadding.PaddingRight = UDim.new(0, 8)
	TabButtonsPadding.Parent = TabButtonsHolder

	TabButtonsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabButtonsHolder.Size = UDim2.new(1, 0, 0, TabButtonsLayout.AbsoluteContentSize.Y + 8)
		TabScroll.CanvasSize = UDim2.new(0, 0, 0, TabButtonsLayout.AbsoluteContentSize.Y + 16)
	end)

	-- Content Area
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Position = UDim2.new(0, 200, 0, 0)
	Content.Size = UDim2.new(1, -200, 1, 0)
	Content.BackgroundColor3 = self.Theme.Background
	Content.BorderSizePixel = 0
	Content.Parent = Main

	-- Topbar
	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.Size = UDim2.new(1, 0, 0, 42)
	Topbar.BackgroundColor3 = self.Theme.Topbar
	Topbar.BorderSizePixel = 0
	Topbar.Parent = Content
	applyStroke(Topbar, self.Theme.Outline, 1, 0.6)

	local TopbarPadding = Instance.new("UIPadding")
	TopbarPadding.PaddingLeft = UDim.new(0, 12)
	TopbarPadding.PaddingRight = UDim.new(0, 12)
	TopbarPadding.Parent = Topbar

	local TopTitle = Instance.new("TextLabel")
	TopTitle.Name = "TopTitle"
	TopTitle.BackgroundTransparency = 1
	TopTitle.Position = UDim2.new(0, 12, 0, 12)
	TopTitle.Size = UDim2.new(0.5, -8, 1, -24)
	TopTitle.Font = Enum.Font.GothamBold
	TopTitle.TextSize = 15
	TopTitle.TextXAlignment = Enum.TextXAlignment.Left
	TopTitle.TextColor3 = self.Theme.Text
	TopTitle.Text = "Overview"
	TopTitle.Parent = Topbar

	-- Window Controls (Top-right) using Lucide icons
	local ControlsHolder = Instance.new("Frame")
	ControlsHolder.Name = "ControlsHolder"
	ControlsHolder.AnchorPoint = Vector2.new(1, 0.5)
	ControlsHolder.Position = UDim2.new(1, -4, 0.5, 0)
	ControlsHolder.Size = UDim2.new(0, 70, 0, 22)
	ControlsHolder.BackgroundTransparency = 1
	ControlsHolder.Parent = Topbar

	local ControlsLayout = Instance.new("UIListLayout")
	ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
	ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	ControlsLayout.Padding = UDim.new(0, 6)
	ControlsLayout.Parent = ControlsHolder

	local function makeIconCircleButton(iconName, bgColor)
		local btn = Instance.new("ImageButton")
		btn.BackgroundColor3 = bgColor
		btn.Size = UDim2.new(0, 18, 0, 18)
		btn.AutoButtonColor = true
		btn.BorderSizePixel = 0
		createRoundCorner(9, btn)
		applyStroke(btn, Color3.fromRGB(10, 10, 10), 1, 0.5)
		btn.Parent = ControlsHolder

		local icon = CreateIcon(iconName, UDim2.fromScale(1, 1), Color3.fromRGB(250, 250, 255))
		icon.BackgroundTransparency = 1
		icon.Size = UDim2.new(0.7, 0, 0.7, 0)
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.new(0.5, 0, 0.5, 0)
		icon.Parent = btn

		return btn
	end

	local MinimizeButton = makeIconCircleButton("lucide:minus", Color3.fromRGB(255, 165, 0))
	local CloseButton = makeIconCircleButton("lucide:x", Color3.fromRGB(220, 53, 69))

	-- Page Holder
	local PageContainer = Instance.new("Frame")
	PageContainer.Name = "PageContainer"
	PageContainer.Position = UDim2.new(0, 0, 0, 42)
	PageContainer.Size = UDim2.new(1, 0, 1, -42)
	PageContainer.BackgroundTransparency = 1
	PageContainer.ClipsDescendants = false
	PageContainer.Parent = Content

	local WindowObject = setmetatable({}, Window)

	WindowObject.ScreenGui = ScreenGui
	WindowObject.Main = Main
	WindowObject.Sidebar = Sidebar
	WindowObject.SidebarHeader = SidebarHeader
	WindowObject.Topbar = Topbar
	WindowObject.PageContainer = PageContainer
	WindowObject.TopTitle = TopTitle
	WindowObject.TabButtonsHolder = TabButtonsHolder
	WindowObject.TabButtonsLayout = TabButtonsLayout
	WindowObject._tabs = {}
	WindowObject._searchable = {}
	WindowObject._configBindings = {}
	WindowObject._closed = false
	WindowObject._dialogTemplate = {
		Title = "Are you sure?",
		Description = "This action will change something",
	}
	WindowObject.Settings = {
		Title = title,
		Size = size,
	}

	-- Make whole UI draggable via topbar (only while held)
	makeDraggable(Main, { Topbar })

	-- Mobile content scaling (DO NOT shrink layout/sections)
	local baseSize = size
	local contentScale = applyMobileContentScale(Main, Content, Sidebar, baseSize)
	local viewportConn
	if workspace.CurrentCamera then
		viewportConn = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			applyMobileContentScale(Main, Content, Sidebar, baseSize)
		end)
	end

	-- Minimized toggle button (mobile friendly + image)
	local MiniButton = Instance.new("ImageButton")
	MiniButton.Name = "RivalsMiniButton"
	MiniButton.Image = "rbxassetid://118045190930372"
	MiniButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	MiniButton.BackgroundTransparency = 1
	MiniButton.BorderSizePixel = 0
	MiniButton.AnchorPoint = Vector2.new(0, 1)
	MiniButton.Size = UDim2.new(0, 90, 0, 90)
	MiniButton.Position = UDim2.new(0, 16, 1, -16)
	MiniButton.Visible = true
	MiniButton.ScaleType = Enum.ScaleType.Fit
	MiniButton.ImageTransparency = 0
	MiniButton.Parent = ScreenGui

	-- keep draggable on desktop/tablet, and usable on mobile
	makeDraggable(MiniButton, MiniButton)

	function RivalsUI:toggleMinimize()
		minimized = not minimized
		Main.Visible = not minimized
	end

	MinimizeButton.MouseButton1Click:Connect(function()
		RivalsUI:toggleMinimize()
	end)
	MiniButton.MouseButton1Click:Connect(function()
		RivalsUI:toggleMinimize()
	end)

	-- Dialog Component (confirm/cancel) - centered with stretched buttons
	local function createDialog(titleText, descText, onConfirm)
		local overlay = Instance.new("TextButton")
		overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		overlay.BackgroundTransparency = 0.35
		overlay.BorderSizePixel = 0
		overlay.Size = UDim2.new(1, 0, 1, 0)
		overlay.Position = UDim2.new(0, 0, 0, 0)
		overlay.ZIndex = 300
		overlay.Text = ""
		overlay.AutoButtonColor = false
		overlay.Parent = Main

		local box = Instance.new("Frame")
		box.Size = UDim2.new(0, 360, 0, 145) -- reduced height to avoid wasted space
		box.BackgroundColor3 = Color3.fromRGB(17, 18, 26)
		box.BorderSizePixel = 0
		createRoundCorner(10, box)
		applyStroke(box, RivalsUI.Theme.Outline, 1, 0.7)
		box.ZIndex = 301
		box.Parent = overlay
		box.AnchorPoint = Vector2.new(0.5, 0.5)
		box.Position = UDim2.new(0.5, 0, 0.5, 0)

		local title = Instance.new("TextLabel")
		title.BackgroundTransparency = 1
		title.Position = UDim2.new(0, 16, 0, 10)
		title.Size = UDim2.new(1, -32, 0, 18)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 15
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextColor3 = RivalsUI.Theme.Text
		title.Text = titleText or WindowObject._dialogTemplate.Title
		title.ZIndex = 302
		title.Parent = box

		local desc = Instance.new("TextLabel")
		desc.BackgroundTransparency = 1
		desc.Position = UDim2.new(0, 16, 0, 34)
		desc.Size = UDim2.new(1, -32, 0, 56)
		desc.Font = Enum.Font.Gotham
		desc.TextWrapped = true
		desc.TextYAlignment = Enum.TextYAlignment.Top
		desc.TextSize = 13
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.TextColor3 = RivalsUI.Theme.SubText
		desc.Text = descText or WindowObject._dialogTemplate.Description
		desc.ZIndex = 302
		desc.Parent = box

		local buttonsHolder = Instance.new("Frame")
		buttonsHolder.BackgroundTransparency = 1
		buttonsHolder.Position = UDim2.new(0, 16, 1, -36)
		buttonsHolder.Size = UDim2.new(1, -32, 0, 26)
		buttonsHolder.ZIndex = 302
		buttonsHolder.Parent = box

		local layout = Instance.new("UIGridLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.CellSize = UDim2.new(0.5, -5, 1, 0)
		layout.CellPadding = UDim2.new(0, 10, 0, 0)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.Parent = buttonsHolder

		local function makeBtn(text, bg, fg)
			local b = Instance.new("TextButton")
			b.BackgroundColor3 = bg
			b.BorderSizePixel = 0
			b.Font = Enum.Font.Gotham
			b.TextSize = 13
			b.TextColor3 = fg
			b.Text = text
			b.AutoButtonColor = true
			createRoundCorner(6, b)
			applyStroke(b, RivalsUI.Theme.Outline, 1, 0.6)
			b.ZIndex = 303
			b.Parent = buttonsHolder
			return b
		end

		local cancelBtn = makeBtn("Cancel", Color3.fromRGB(30, 32, 46), RivalsUI.Theme.Text)
		local confirmBtn = makeBtn("Confirm", RivalsUI.Theme.Accent, Color3.fromRGB(240, 241, 249))

		cancelBtn.MouseButton1Click:Connect(function()
			overlay:Destroy()
		end)

		confirmBtn.MouseButton1Click:Connect(function()
			overlay:Destroy()
			if onConfirm then pcall(onConfirm) end
		end)

		overlay.MouseButton1Click:Connect(function()
			local pos = UserInputService:GetMouseLocation()
			local absPos = box.AbsolutePosition
			local absSize = box.AbsoluteSize
			if pos.X < absPos.X or pos.X > absPos.X + absSize.X or pos.Y < absPos.Y or pos.Y > absPos.Y + absSize.Y then
				overlay:Destroy()
			end
		end)

		return {
			Overlay = overlay,
			Frame = box,
		}
	end

	-- create input dialog used by config tab for new config names
	function WindowObject:InputDialog(options)
		options = options or {}
		local titleText = options.Title or "New Config"
		local descText = options.Description or "Enter a name for this config."
		local placeholder = options.Placeholder or "Config name"
		local confirmText = options.ConfirmText or "Create"
		local cancelText = options.CancelText or "Cancel"
		local callback = options.Callback

		local overlay = Instance.new("TextButton")
		overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		overlay.BackgroundTransparency = 0.35
		overlay.BorderSizePixel = 0
		overlay.Size = UDim2.new(1, 0, 1, 0)
		overlay.Position = UDim2.new(0, 0, 0, 0)
		overlay.ZIndex = 310
		overlay.Text = ""
		overlay.AutoButtonColor = false
		overlay.Parent = self.Main

		local box = Instance.new("Frame")
		box.Size = UDim2.new(0, 360, 0, 170) -- reduced from 190 for compact look
		box.BackgroundColor3 = Color3.fromRGB(17, 18, 26)
		box.BorderSizePixel = 0
		createRoundCorner(10, box)
		applyStroke(box, RivalsUI.Theme.Outline, 1, 0.7)
		box.ZIndex = 311
		box.Parent = overlay
		box.AnchorPoint = Vector2.new(0.5, 0.5)
		box.Position = UDim2.new(0.5, 0, 0.5, 0)

		local title = Instance.new("TextLabel")
		title.BackgroundTransparency = 1
		title.Position = UDim2.new(0, 16, 0, 10)
		title.Size = UDim2.new(1, -32, 0, 18)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 15
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextColor3 = RivalsUI.Theme.Text
		title.Text = titleText
		title.ZIndex = 312
		title.Parent = box

		local desc = Instance.new("TextLabel")
		desc.BackgroundTransparency = 1
		desc.Position = UDim2.new(0, 16, 0, 34)
		desc.Size = UDim2.new(1, -32, 0, 38)
		desc.Font = Enum.Font.Gotham
		desc.TextWrapped = true
		desc.TextYAlignment = Enum.TextYAlignment.Top
		desc.TextSize = 13
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.TextColor3 = RivalsUI.Theme.SubText
		desc.Text = descText
		desc.ZIndex = 312
		desc.Parent = box

		local InputBox = Instance.new("TextBox")
		InputBox.Name = "ConfigNameInput"
		InputBox.Size = UDim2.new(1, -32, 0, 26)
		InputBox.Position = UDim2.new(0, 16, 0, 80)
		InputBox.BackgroundColor3 = Color3.fromRGB(23, 24, 35)
		InputBox.BorderSizePixel = 0
		InputBox.Font = Enum.Font.Gotham
		InputBox.TextSize = 13
		InputBox.TextColor3 = RivalsUI.Theme.Text
		InputBox.PlaceholderText = placeholder
		InputBox.PlaceholderColor3 = RivalsUI.Theme.SubText
		InputBox.TextXAlignment = Enum.TextXAlignment.Left
		InputBox.ClearTextOnFocus = false
		InputBox.Text = ""
		createRoundCorner(6, InputBox)
		applyStroke(InputBox, RivalsUI.Theme.Outline, 1, 0.7)
		InputBox.ZIndex = 312
		InputBox.Parent = box

		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 6)
		pad.Parent = InputBox

		local buttonsHolder = Instance.new("Frame")
		buttonsHolder.BackgroundTransparency = 1
		buttonsHolder.Position = UDim2.new(0, 16, 1, -38)
		buttonsHolder.Size = UDim2.new(1, -32, 0, 26)
		buttonsHolder.ZIndex = 312
		buttonsHolder.Parent = box

		local layout = Instance.new("UIGridLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.CellSize = UDim2.new(0.5, -5, 1, 0)
		layout.CellPadding = UDim2.new(0, 10, 0, 0)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.Parent = buttonsHolder

		local function makeBtn(text, bg, fg)
			local b = Instance.new("TextButton")
			b.BackgroundColor3 = bg
			b.BorderSizePixel = 0
			b.Font = Enum.Font.Gotham
			b.TextSize = 13
			b.TextColor3 = fg
			b.Text = text
			b.AutoButtonColor = true
			createRoundCorner(6, b)
			applyStroke(b, RivalsUI.Theme.Outline, 1, 0.6)
			b.ZIndex = 313
			b.Parent = buttonsHolder
			return b
		end

		local cancelBtn = makeBtn(cancelText, Color3.fromRGB(30, 32, 46), RivalsUI.Theme.Text)
		local confirmBtn = makeBtn(confirmText, RivalsUI.Theme.Success, Color3.fromRGB(240, 241, 249))

		local function finish(okPress)
			local nameText = (InputBox.Text or ""):gsub("^%s*(.-)%s*$", "%1")
			if okPress and nameText ~= "" then
				if callback then
					pcall(callback, nameText)
				end
			end
			overlay:Destroy()
		end

		cancelBtn.MouseButton1Click:Connect(function()
			finish(false)
		end)

		confirmBtn.MouseButton1Click:Connect(function()
			finish(true)
		end)

		InputBox.FocusLost:Connect(function(enter)
			if enter then
				finish(true)
			end
		end)

		overlay.MouseButton1Click:Connect(function()
			local pos = UserInputService:GetMouseLocation()
			local absPos = box.AbsolutePosition
			local absSize = box.AbsoluteSize
			if pos.X < absPos.X or pos.X > absPos.X + absSize.X or pos.Y < absPos.Y or pos.Y > absPos.Y + absSize.Y then
				finish(false)
			end
		end)

		return {
			Overlay = overlay,
			Frame = box,
			Input = InputBox,
		}
	end

	-- Dialog API on window
	function WindowObject:Dialog(options)
		options = options or {}
		local titleText = options.Title or self._dialogTemplate.Title
		local descText = options.Description or self._dialogTemplate.Description
		local callback = options.Callback
		return createDialog(titleText, descText, callback)
	end

	function WindowObject:SetDefaultDialog(titleText, descText)
		self._dialogTemplate.Title = titleText or self._dialogTemplate.Title
		self._dialogTemplate.Description = descText or self._dialogTemplate.Description
	end

	-- Close: show dialog first, then destroy if confirmed
	function WindowObject:_destroy()
		if self._closed then return end
		self._closed = true
		pcall(function()
			if viewportConn then viewportConn:Disconnect() end
			ScreenGui:Destroy()
		end)
	end

	function WindowObject:Close()
		if self._closed then return end
		self:Dialog({
			Title = self._dialogTemplate.Title,
			Description = self._dialogTemplate.Description,
			Callback = function()
				self:_destroy()
			end,
		})
	end

	CloseButton.MouseButton1Click:Connect(function()
		WindowObject:Close()
	end)

	-- Global keybind to toggle visibility/minimize
	local uiVisible = true
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp or WindowObject._closed then return end
		if input.KeyCode == keybind then
			if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

			if not uiVisible then
				-- bring back from fully hidden
				uiVisible = true
				ScreenGui.Enabled = true
				Main.Visible = not minimized
				MiniButton.Visible = true
			else
				-- toggle between minimized and normal when visible
				RivalsUI:toggleMinimize()
			end
		end
	end)

	function WindowObject:TabGroup()
		local group = setmetatable({}, TabGroup)
		group.Window = self
		group._tabs = {}
		return group
	end

	function WindowObject:RegisterSearchable(component, labelInstance)
		component._searchLabel = labelInstance
		table.insert(self._searchable, component)
	end

	-- Config binding registration
	function WindowObject:_registerConfigBinding(key, setter)
		self._configBindings[key] = setter
	end

	function WindowObject:BuildConfigTable()
		local cfg = {}
		for key, setter in pairs(self._configBindings) do
			if setter._getter then
				cfg[key] = setter._getter()
			end
		end
		return cfg
	end

	function WindowObject:ApplyConfig(cfg)
		cfg = cfg or {}
		for key, setter in pairs(self._configBindings) do
			local value = cfg[key]
			if value ~= nil then
				setter(value)
			end
		end
	end

	-- remember last window for RivalsUI:AutoLoad helper
	RivalsUI._lastWindow = WindowObject

	return WindowObject
end

---------------------------------------------------------------------
-- TabGroup / Tab
---------------------------------------------------------------------

function TabGroup:Tab(opts)
	opts = opts or {}
	local name = opts.Name or "Tab"
	local iconName = opts.Icon or opts.Image or "lucide:folder"
	local isConfigTab = opts.ConfigTab or false

	local Button = Instance.new("TextButton")
	Button.Name = name .. "_TabButton"
	Button.Size = UDim2.new(1, 0, 0, 30)
	Button.BackgroundColor3 = Color3.fromRGB(21, 22, 32)
    Button.BackgroundTransparency = 1
	Button.AutoButtonColor = false
	Button.Text = ""
	Button.BorderSizePixel = 0
	createRoundCorner(7, Button)
	Button.Parent = self.Window.TabButtonsHolder

	local Icon = CreateIcon(iconName, UDim2.fromOffset(16, 16), RivalsUI.Theme.SubText)
	Icon.AnchorPoint = Vector2.new(0, 0.5)
	Icon.Position = UDim2.new(0, 8, 0.5, 0)
	Icon.Parent = Button

	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.Position = UDim2.new(0, 32, 0, 0)
	Label.Size = UDim2.new(1, -38, 1, 0)
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 13
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextColor3 = RivalsUI.Theme.SubText
	Label.Text = name
	Label.Parent = Button

	-- Divider under tabs, same width as buttons
	local TabDivider = self.Window.Sidebar:FindFirstChild("TabDivider")
	if not TabDivider then
		TabDivider = Instance.new("Frame")
		TabDivider.Name = "TabDivider"
		TabDivider.AnchorPoint = Vector2.new(0, 0)
		TabDivider.BackgroundColor3 = RivalsUI.Theme.Outline
		TabDivider.BackgroundTransparency = 0.35
		TabDivider.BorderSizePixel = 0
		TabDivider.Parent = self.Window.Sidebar
	end

	-- Move divider below SidebarHeader explicitly to account for multi-line subtitles
	TabDivider.Position = UDim2.new(0, 8, 0, self.Window.SidebarHeader.Size.Y.Offset + 4)
	TabDivider.Size = UDim2.new(1, -16, 0, 1)

	local Page = Instance.new("ScrollingFrame")
	Page.Name = name .. "_Page"
	Page.Size = UDim2.new(1, 0, 1, 0)
	Page.CanvasSize = UDim2.new(0, 0, 0, 0)
	Page.ScrollBarThickness = 4
	Page.ScrollBarImageColor3 = Color3.fromRGB(60, 61, 80)
	Page.BackgroundTransparency = 1
	Page.Visible = false
	Page.Parent = self.Window.PageContainer

	local PagePadding = Instance.new("UIPadding")
	PagePadding.PaddingTop = UDim.new(0, 12)
	PagePadding.PaddingLeft = UDim.new(0, 12)
	PagePadding.PaddingRight = UDim.new(0, 12)
	PagePadding.Parent = Page

	local Columns, LeftColumn, RightColumn, LeftLayout, RightLayout

	if isConfigTab then
		-- Single full-width column, configs + search bar will use entire width
		Columns = Instance.new("Frame")
		Columns.Name = "ConfigColumn"
		Columns.Size = UDim2.new(1, 0, 0, 0)
		Columns.BackgroundTransparency = 1
		Columns.Parent = Page

		LeftColumn = Columns -- reuse for API compatibility

		LeftLayout = Instance.new("UIListLayout")
		LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
		LeftLayout.Padding = UDim.new(0, 10)
		LeftLayout.Parent = Columns

		local function updateCanvasConfig()
			Columns.Size = UDim2.new(1, 0, 0, LeftLayout.AbsoluteContentSize.Y)
			Page.CanvasSize = UDim2.new(0, 0, 0, LeftLayout.AbsoluteContentSize.Y + 24)
		end

		LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasConfig)
		updateCanvasConfig()
	else
		-- Two independent vertical columns so sections never collide
		Columns = Instance.new("Frame")
		Columns.Name = "Columns"
		Columns.Size = UDim2.new(1, 0, 0, 0)
		Columns.BackgroundTransparency = 1
		Columns.Parent = Page

		local ColumnsLayout = Instance.new("UIListLayout")
		ColumnsLayout.FillDirection = Enum.FillDirection.Horizontal
		ColumnsLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ColumnsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		ColumnsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		ColumnsLayout.Padding = UDim.new(0, 12)
		ColumnsLayout.Parent = Columns

		LeftColumn = Instance.new("Frame")
		LeftColumn.Name = "LeftColumn"
		LeftColumn.Size = UDim2.new(0.5, -6, 1, 0)
		LeftColumn.BackgroundTransparency = 1
		LeftColumn.Parent = Columns

		RightColumn = Instance.new("Frame")
		RightColumn.Name = "RightColumn"
		RightColumn.Size = UDim2.new(0.5, -6, 1, 0)
		RightColumn.BackgroundTransparency = 1
		RightColumn.Parent = Columns

		LeftLayout = Instance.new("UIListLayout")
		LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
		LeftLayout.Padding = UDim.new(0, 10)
		LeftLayout.Parent = LeftColumn

		RightLayout = Instance.new("UIListLayout")
		RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
		RightLayout.Padding = UDim.new(0, 10)
		RightLayout.Parent = RightColumn

		local function updateCanvas()
			local maxHeight = math.max(LeftLayout.AbsoluteContentSize.Y, RightLayout.AbsoluteContentSize.Y)
			Columns.Size = UDim2.new(1, 0, 0, maxHeight)
			Page.CanvasSize = UDim2.new(0, 0, 0, maxHeight + 24)
		end

		LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
		RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
		updateCanvas()
	end

	local TabObject = setmetatable({}, Tab)
	TabObject.Window = self.Window
	TabObject.Group = self
	TabObject.Button = Button
	TabObject.Page = Page
	TabObject.LeftColumn = LeftColumn
	TabObject.RightColumn = RightColumn
	TabObject._sections = {}
	TabObject.IsConfigTab = isConfigTab

	-- Tab selection handling
	local function SetActive(active)
		if active then
			Button.BackgroundColor3 = Color3.fromRGB(33, 35, 52)
            Button.BackgroundTransparency = 0
			Label.TextColor3 = RivalsUI.Theme.Text
			Icon.ImageColor3 = RivalsUI.Theme.Text
			Page.Visible = true
			self.Window.TopTitle.Text = name
		else
			Button.BackgroundColor3 = Color3.fromRGB(21, 22, 32)
            Button.BackgroundTransparency = 1
			Label.TextColor3 = RivalsUI.Theme.SubText
			Icon.ImageColor3 = RivalsUI.Theme.SubText
			Page.Visible = false
		end
	end

	Button.MouseButton1Click:Connect(function()
		for _, other in ipairs(self._tabs) do
			other:_setActive(false)
		end
		TabObject:_setActive(true)
	end)

	function TabObject:_setActive(active)
		SetActive(active)
		self.Active = active
		if active and self.IsConfigTab and self.ConfigTabHeaderToggle then
			self.ConfigTabHeaderToggle.Visible = true
		elseif self.ConfigTabHeaderToggle then
			self.ConfigTabHeaderToggle.Visible = false
		end
	end

	function TabObject:Select()
		for _, other in ipairs(self.Group._tabs) do
			other:_setActive(false)
		end
		self:_setActive(true)
	end

	function TabObject:Section(opts)
		opts = opts or {}
		local side = string.lower(opts.Side or "left")
		local column
		if self.IsConfigTab then
			-- force single column regardless of side
			column = self.LeftColumn
		else
			column = (side == "right") and self.RightColumn or self.LeftColumn
		end

		local SectionFrame = Instance.new("Frame")
		SectionFrame.Name = (opts.Name or "Section") .. "_Section"
		SectionFrame.Size = UDim2.new(1, 0, 0, 0)
		SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
		SectionFrame.BackgroundColor3 = RivalsUI.Theme.Section
		SectionFrame.BorderSizePixel = 0
		createRoundCorner(8, SectionFrame)
		applyStroke(SectionFrame, RivalsUI.Theme.Outline, 1, 0.7)
		SectionFrame.Parent = column

		local SectionPadding = Instance.new("UIPadding")
		SectionPadding.PaddingTop = UDim.new(0, 10)
		SectionPadding.PaddingBottom = UDim.new(0, 10)
		SectionPadding.PaddingLeft = UDim.new(0, 10)
		SectionPadding.PaddingRight = UDim.new(0, 10)
		SectionPadding.Parent = SectionFrame

		local SectionLayout = Instance.new("UIListLayout")
		SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
		SectionLayout.Padding = UDim.new(0, 6)
		SectionLayout.Parent = SectionFrame

		local SectionObject = setmetatable({}, Section)
		SectionObject.Window = self.Window
		SectionObject.Tab = self
		SectionObject.Frame = SectionFrame
		SectionObject.Layout = SectionLayout

		-- AutomaticSize handles height automatically, no manual calculation needed

		-- Section tabs (optional)
		SectionObject._tabs = nil
		SectionObject._currentTabIndex = nil
		SectionObject._tabToContent = nil
		SectionObject._tabDropdownButton = nil
		SectionObject._tabDropdownLabel = nil
		SectionObject._tabDropdownOverlay = nil
		SectionObject._tabDropdownList = nil

		local tabsList = opts.Tabs or opts.tabs
		if type(tabsList) == "table" and #tabsList > 0 then
			SectionObject._tabs = {}
			for i, v in ipairs(tabsList) do
				SectionObject._tabs[i] = tostring(v)
			end
			SectionObject._currentTabIndex = 1
			SectionObject._tabToContent = {}

			-- top small tab dropdown row
			local TabsTopRow = Instance.new("Frame")
			TabsTopRow.Name = "TabsSelectorRow"
			TabsTopRow.Size = UDim2.new(1, 0, 0, 20)
			TabsTopRow.BackgroundTransparency = 1
			TabsTopRow.Parent = SectionFrame
			TabsTopRow.LayoutOrder = -1000

			local TabsTopLayout = Instance.new("UIListLayout")
			TabsTopLayout.FillDirection = Enum.FillDirection.Horizontal
			TabsTopLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
			TabsTopLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			TabsTopLayout.Padding = UDim.new(0, 6)
			TabsTopLayout.Parent = TabsTopRow

			local TabDropdownButton = Instance.new("TextButton")
			TabDropdownButton.Name = "SectionTabsDropdown"
			TabDropdownButton.BackgroundTransparency = 1
			TabDropdownButton.BorderSizePixel = 0
			TabDropdownButton.AutoButtonColor = false
			TabDropdownButton.Text = ""
			TabDropdownButton.Size = UDim2.new(0, 130, 0, 18)
			TabDropdownButton.Parent = TabsTopRow

			local TabLabel = Instance.new("TextLabel")
			TabLabel.BackgroundTransparency = 1
			TabLabel.Size = UDim2.new(1, -16, 1, 0)
			TabLabel.Font = Enum.Font.Gotham
			TabLabel.TextSize = 12
			TabLabel.TextXAlignment = Enum.TextXAlignment.Left
			TabLabel.TextColor3 = RivalsUI.Theme.Text
			TabLabel.Text = SectionObject._tabs[1]
			TabLabel.Parent = TabDropdownButton

			local ArrowIcon = CreateIcon("lucide:chevron-down", UDim2.fromOffset(12, 12), RivalsUI.Theme.SubText)
			ArrowIcon.AnchorPoint = Vector2.new(0, 0.5)
			ArrowIcon.Parent = TabDropdownButton

			local function snapArrowToText()
				local margin = 4
				ArrowIcon.Position = UDim2.new(0, TabLabel.TextBounds.X + margin, 0.5, 0)
			end

			TabLabel:GetPropertyChangedSignal("TextBounds"):Connect(snapArrowToText)
			TabLabel:GetPropertyChangedSignal("Text"):Connect(snapArrowToText)
			TabsTopRow:GetPropertyChangedSignal("AbsoluteSize"):Connect(snapArrowToText)
			snapArrowToText()

			-- clean underline
			local Underline = Instance.new("Frame")
			Underline.Name = "Underline"
			Underline.AnchorPoint = Vector2.new(0, 1)
			Underline.Position = UDim2.new(0, 0, 1, 0)
			Underline.Size = UDim2.new(0, 0, 0, 1)
			Underline.BackgroundColor3 = RivalsUI.Theme.Accent
			Underline.BorderSizePixel = 0
			Underline.Parent = TabDropdownButton

			local function updateUnderline()
				Underline.Size = UDim2.new(0, TabLabel.TextBounds.X, 0, 1)
			end

			TabLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateUnderline)
			updateUnderline()

			-- create one vertical holder for tab content inside the section
			local ContentHolder = Instance.new("Frame")
			ContentHolder.Name = "TabsContentHolder"
			ContentHolder.BackgroundTransparency = 1
			ContentHolder.Size = UDim2.new(1, 0, 0, 0)
			ContentHolder.AutomaticSize = Enum.AutomaticSize.Y
			ContentHolder.Parent = SectionFrame

			local ContentLayout = Instance.new("UIListLayout")
			ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ContentLayout.Padding = UDim.new(0, 6)
			ContentLayout.Parent = ContentHolder

			SectionObject._tabContentHolder = ContentHolder

			-- AutomaticSize handles sizing

			local function getOrCreateTabFrame(index)
				if SectionObject._tabToContent[index] then
					return SectionObject._tabToContent[index]
				end

				local f = Instance.new("Frame")
				f.Name = "TabContent_" .. tostring(index)
				f.Size = UDim2.new(1, 0, 0, 0)
				f.AutomaticSize = Enum.AutomaticSize.Y
				f.BackgroundTransparency = 1
				f.Visible = (index == SectionObject._currentTabIndex)
				f.Parent = ContentHolder

				local l = Instance.new("UIListLayout")
				l.SortOrder = Enum.SortOrder.LayoutOrder
				l.Padding = UDim.new(0, 6)
				l.Parent = f

				SectionObject._tabToContent[index] = {Frame = f, Layout = l}
				return SectionObject._tabToContent[index]
			end

			SectionObject._getOrCreateTabFrame = getOrCreateTabFrame

			-- overlay dropdown (for selecting which internal tab is active)
			local Overlay = Instance.new("TextButton")
			Overlay.Name = "SectionTabsOverlay"
			Overlay.BackgroundTransparency = 1
			Overlay.Size = UDim2.new(1, 0, 1, 0)
			Overlay.Position = UDim2.new(0, 0, 0, 0)
			Overlay.ZIndex = 90
			Overlay.Visible = false
			Overlay.Text = ""
			Overlay.AutoButtonColor = false
			Overlay.Parent = self.Window.ScreenGui

			local ListFrame = Instance.new("Frame")
			ListFrame.Name = "SectionTabsList"
			ListFrame.BackgroundColor3 = Color3.fromRGB(23, 24, 35)
			ListFrame.BorderSizePixel = 0
			ListFrame.Size = UDim2.new(0, 150, 0, 0)
			createRoundCorner(6, ListFrame)
			applyStroke(ListFrame, RivalsUI.Theme.Outline, 1, 0.8)
			ListFrame.Parent = Overlay
			ListFrame.ZIndex = 91

			local ListLayout = Instance.new("UIListLayout")
			ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ListLayout.Padding = UDim.new(0, 2)
			ListLayout.Parent = ListFrame

			local ListPadding = Instance.new("UIPadding")
			ListPadding.PaddingTop = UDim.new(0, 4)
			ListPadding.PaddingBottom = UDim.new(0, 4)
			ListPadding.PaddingLeft = UDim.new(0, 4)
			ListPadding.PaddingRight = UDim.new(0, 4)
			ListPadding.Parent = ListFrame

			local function rebuildTabsList()
				for _, child in ipairs(ListFrame:GetChildren()) do
					if child:IsA("TextButton") then
						child:Destroy()
					end
				end

				for i, tabName in ipairs(SectionObject._tabs) do
					local Btn = Instance.new("TextButton")
					Btn.Name = "Tab_" .. tostring(i)
					Btn.AutoButtonColor = true
					Btn.BackgroundColor3 = Color3.fromRGB(28, 29, 42)
					Btn.BorderSizePixel = 0
					Btn.Size = UDim2.new(1, 0, 0, 22)
					Btn.Font = Enum.Font.Gotham
					Btn.TextSize = 12
					Btn.TextColor3 = RivalsUI.Theme.Text
					Btn.TextXAlignment = Enum.TextXAlignment.Left
					Btn.Text = tabName
					createRoundCorner(4, Btn)
					Btn.Parent = ListFrame
					Btn.ZIndex = 92

					local Pad = Instance.new("UIPadding")
					Pad.PaddingLeft = UDim.new(0, 6)
					Pad.Parent = Btn

					Btn.MouseButton1Click:Connect(function()
						SectionObject._currentTabIndex = i
						TabLabel.Text = tabName
						updateUnderline()
						snapArrowToText()

						for idx, entry in pairs(SectionObject._tabToContent) do
							if entry and entry.Frame then
								entry.Frame.Visible = (idx == SectionObject._currentTabIndex)
							end
						end

						Overlay.Visible = false
					end)
				end

				local contentHeight = ListLayout.AbsoluteContentSize.Y
				local topPadding = ListPadding.PaddingTop.Offset
				local bottomPadding = ListPadding.PaddingBottom.Offset
				local desiredHeight = contentHeight + topPadding + bottomPadding
				ListFrame.Size = UDim2.new(0, 150, 0, math.clamp(desiredHeight, 20, 160))
			end

			ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				local contentHeight = ListLayout.AbsoluteContentSize.Y
				local topPadding = ListPadding.PaddingTop.Offset
				local bottomPadding = ListPadding.PaddingBottom.Offset
				local desiredHeight = contentHeight + topPadding + bottomPadding
				ListFrame.Size = UDim2.new(0, 150, 0, math.clamp(desiredHeight, 20, 160))
			end)

			rebuildTabsList()

			local function openOverlay()
				local absPos = TabDropdownButton.AbsolutePosition
				local absSize = TabDropdownButton.AbsoluteSize
				ListFrame.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 2)
				Overlay.Visible = true
			end

			local function closeOverlay()
				Overlay.Visible = false
			end

			TabDropdownButton.MouseButton1Click:Connect(function()
				if Overlay.Visible then
					closeOverlay()
				else
					openOverlay()
				end
			end)

			Overlay.MouseButton1Click:Connect(function()
				local pos = UserInputService:GetMouseLocation()
				local absPos = ListFrame.AbsolutePosition
				local absSize = ListFrame.AbsoluteSize
				if pos.X < absPos.X or pos.X > absPos.X + absSize.X or pos.Y < absPos.Y or pos.Y > absPos.Y + absSize.Y then
					closeOverlay()
				end
			end)

			SectionObject._tabDropdownButton = TabDropdownButton
			SectionObject._tabDropdownLabel = TabLabel
			SectionObject._tabDropdownOverlay = Overlay
			SectionObject._tabDropdownList = ListFrame

			getOrCreateTabFrame(SectionObject._currentTabIndex)

			function SectionObject:GetTab()
				if not self._tabs or not self._currentTabIndex then
					return nil
				end
				return self._tabs[self._currentTabIndex]
			end

			function SectionObject:_getContentParent(targetTabName)
				local index
				if targetTabName then
					for i, n in ipairs(self._tabs) do
						if n == targetTabName then index = i break end
					end
				end
				if not index then
					index = self._currentTabIndex or 1
				end
				local entry = self._getOrCreateTabFrame(index)
				return entry.Frame
			end
		else
			function SectionObject:GetTab()
				return nil
			end

			function SectionObject:_getContentParent()
				return self.Frame
			end
		end

		return SectionObject
	end

	-- Special: if this is the Config tab, create a header toggle "Auto Load Default" in top bar
	if isConfigTab then
		local ToggleHolder = Instance.new("Frame")
		ToggleHolder.Name = "ConfigTopToggleHolder"
		ToggleHolder.AnchorPoint = Vector2.new(1, 0.5)
		ToggleHolder.Position = UDim2.new(1, -90, 0.5, 0)
		ToggleHolder.Size = UDim2.new(0, 150, 0, 22)
		ToggleHolder.BackgroundTransparency = 1
		ToggleHolder.Visible = false
		ToggleHolder.Parent = self.Window.Topbar

		local Label = Instance.new("TextLabel")
		Label.BackgroundTransparency = 1
		Label.Size = UDim2.new(1, -52, 1, 0)
		Label.Font = Enum.Font.Gotham
		Label.TextSize = 12
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.TextColor3 = RivalsUI.Theme.SubText
		Label.Text = "Auto Load Default"
		Label.Parent = ToggleHolder

		local ToggleButton = Instance.new("TextButton")
		ToggleButton.Name = "AutoLoadToggle"
		ToggleButton.AnchorPoint = Vector2.new(1, 0.5)
		ToggleButton.Position = UDim2.new(1, 0, 0.5, 0)
		ToggleButton.Size = UDim2.new(0, 44, 0, 18)
		ToggleButton.BackgroundColor3 = Color3.fromRGB(32, 34, 50)
		ToggleButton.AutoButtonColor = false
		ToggleButton.Text = ""
		ToggleButton.BorderSizePixel = 0
		createRoundCorner(9, ToggleButton)
		applyStroke(ToggleButton, RivalsUI.Theme.Outline, 1, 0.6)
		ToggleButton.Parent = ToggleHolder

		local Knob = Instance.new("Frame")
		Knob.Name = "Knob"
		Knob.AnchorPoint = Vector2.new(0.5, 0.5)
		Knob.Position = UDim2.new(0, 9, 0.5, 0)
		Knob.Size = UDim2.new(0, 14, 0, 14)
		Knob.BackgroundColor3 = Color3.fromRGB(230, 231, 240)
		Knob.BorderSizePixel = 0
		createRoundCorner(7, Knob)
		Knob.Parent = ToggleButton

		local Value = RivalsUI.ConfigMeta.AutoLoadDefault and true or false

		local function refresh(animated)
			local goalPos = Value and UDim2.new(1, -9, 0.5, 0) or UDim2.new(0, 9, 0.5, 0)
			local goalColor = Value and RivalsUI.Theme.Accent or Color3.fromRGB(32, 34, 50)
			if animated then
				TweenService:Create(ToggleButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = goalColor }):Play()
				TweenService:Create(Knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = goalPos }):Play()
			else
				ToggleButton.BackgroundColor3 = goalColor
				Knob.Position = goalPos
			end
		end

		ToggleButton.MouseButton1Click:Connect(function()
			Value = not Value
			RivalsUI.ConfigMeta.AutoLoadDefault = Value
			RivalsUI:SaveMeta()
			refresh(true)
		end)

		refresh(false)
		TabObject.ConfigTabHeaderToggle = ToggleHolder
	end

	table.insert(self._tabs, TabObject)
	return TabObject
end

---------------------------------------------------------------------
-- Section helpers
---------------------------------------------------------------------

local function createRow(section, labelText, targetTabName)
	local parent = section:_getContentParent(targetTabName)

	local Row = Instance.new("Frame")
	Row.Name = labelText .. "_Row"
	Row.Size = UDim2.new(1, 0, 0, 28)
	Row.BackgroundTransparency = 1
	Row.Parent = parent

	local Label = Instance.new("TextLabel")
	Label.Name = "Label"
	Label.BackgroundTransparency = 1
	Label.Position = UDim2.new(0, 0, 0, 0)
	Label.Size = UDim2.new(1, -120, 1, 0)
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 13
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextColor3 = RivalsUI.Theme.Text
	Label.TextWrapped = true
	Label.Text = labelText
	Label.Parent = Row

	local RightHolder = Instance.new("Frame")
	RightHolder.Name = "RightHolder"
	RightHolder.AnchorPoint = Vector2.new(1, 0)
	RightHolder.Position = UDim2.new(1, 0, 0, 0)
	RightHolder.Size = UDim2.new(0, 110, 1, 0)
	RightHolder.BackgroundTransparency = 1
	RightHolder.Parent = Row

	return Row, Label, RightHolder
end

function Section:Header(opts)
	opts = opts or {}
	local text = opts.Name or opts.Text or "Header"
	local targetTab = opts.Tab

	local parent = self:_getContentParent(targetTab)

	local Label = Instance.new("TextLabel")
	Label.Name = "Header"
	Label.BackgroundTransparency = 1
	Label.Size = UDim2.new(1, 0, 0, 20)
	Label.Font = Enum.Font.GothamBold
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextColor3 = RivalsUI.Theme.Text
	Label.Text = text
	Label.Parent = parent

	return Label
end

function Section:Divider(opts)
	opts = opts or {}
	local targetTab = opts.Tab
	local parent = self:_getContentParent(targetTab)

	local Line = Instance.new("Frame")
	Line.Name = "Divider"
	Line.Size = UDim2.new(1, 0, 0, 2)
	Line.BackgroundColor3 = RivalsUI.Theme.Outline
	Line.BorderSizePixel = 0
	Line.BackgroundTransparency = 0.35
	Line.Parent = parent
	return Line
end

function Section:Paragraph(opts)
	opts = opts or {}
	local header = opts.Header or "Paragraph"
	local body = opts.Body or "Lorem ipsum dolor sit amet."
	local targetTab = opts.Tab

	local parent = self:_getContentParent(targetTab)

	local HeaderLabel = Instance.new("TextLabel")
	HeaderLabel.Name = "ParagraphHeader"
	HeaderLabel.BackgroundTransparency = 1
	HeaderLabel.Size = UDim2.new(1, 0, 0, 18)
	HeaderLabel.Font = Enum.Font.GothamBold
	HeaderLabel.TextSize = 13
	HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
	HeaderLabel.TextColor3 = RivalsUI.Theme.Text
	HeaderLabel.Text = header
	HeaderLabel.Parent = parent

	local BodyLabel = Instance.new("TextLabel")
	BodyLabel.Name = "ParagraphBody"
	BodyLabel.BackgroundTransparency = 1
	BodyLabel.Size = UDim2.new(1, 0, 0, 0)
	BodyLabel.Font = Enum.Font.Gotham
	BodyLabel.TextWrapped = true
	BodyLabel.TextSize = 13
	BodyLabel.TextXAlignment = Enum.TextXAlignment.Left
	BodyLabel.TextYAlignment = Enum.TextYAlignment.Top
	BodyLabel.TextColor3 = RivalsUI.Theme.SubText
	BodyLabel.Text = body
	BodyLabel.Parent = parent

	BodyLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
		BodyLabel.Size = UDim2.new(1, 0, 0, math.max(BodyLabel.TextBounds.Y, 18))
	end)

	return { Header = HeaderLabel, Body = BodyLabel }
end

-- Paragraph-style button with optional icon
function Section:ActionButton(opts)
	opts = opts or {}
	local header = opts.Header or "Action Button"
	local body = opts.Body or "Click to run an action."
	local iconName = opts.Icon
	local callback = opts.Callback or function() end
	local targetTab = opts.Tab

	local parent = self:_getContentParent(targetTab)

	local Container = Instance.new("TextButton")
	Container.Name = "ActionButton"
	Container.AutoButtonColor = true
	Container.Text = ""
	Container.BackgroundColor3 = Color3.fromRGB(28, 29, 42)
	Container.BorderSizePixel = 0
	Container.Size = UDim2.new(1, 0, 0, 56)
	createRoundCorner(6, Container)
	applyStroke(Container, RivalsUI.Theme.Outline, 1, 0.5)
	Container.Parent = parent

	local Pad = Instance.new("UIPadding")
	Pad.PaddingLeft = UDim.new(0, 10)
	Pad.PaddingRight = UDim.new(0, 10)
	Pad.PaddingTop = UDim.new(0, 8)
	Pad.PaddingBottom = UDim.new(0, 8)
	Pad.Parent = Container

	local Layout = Instance.new("UIListLayout")
	Layout.FillDirection = Enum.FillDirection.Horizontal
	Layout.VerticalAlignment = Enum.VerticalAlignment.Center
	Layout.Padding = UDim.new(0, 8)
	Layout.Parent = Container

	local IconHolder
	if iconName then
		IconHolder = Instance.new("Frame")
		IconHolder.Size = UDim2.new(0, 24, 1, 0)
		IconHolder.BackgroundTransparency = 1
		IconHolder.Parent = Container

		local icon = CreateIcon(iconName, UDim2.fromOffset(20, 20), RivalsUI.Theme.Text)
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.new(0.5, 0, 0.5, 0)
		icon.Parent = IconHolder
	end

	local TextHolder = Instance.new("Frame")
	TextHolder.BackgroundTransparency = 1
	TextHolder.Size = UDim2.new(1, 0, 1, 0)
	TextHolder.Parent = Container

	local TextLayout = Instance.new("UIListLayout")
	TextLayout.FillDirection = Enum.FillDirection.Vertical
	TextLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	TextLayout.Parent = TextHolder

	local HeaderLabel = Instance.new("TextLabel")
	HeaderLabel.BackgroundTransparency = 1
	HeaderLabel.Size = UDim2.new(1, 0, 0, 18)
	HeaderLabel.Font = Enum.Font.GothamBold
	HeaderLabel.TextSize = 13
	HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
	HeaderLabel.TextColor3 = RivalsUI.Theme.Text
	HeaderLabel.Text = header
	HeaderLabel.Parent = TextHolder

	local BodyLabel = Instance.new("TextLabel")
	BodyLabel.BackgroundTransparency = 1
	BodyLabel.Size = UDim2.new(1, 0, 0, 16)
	BodyLabel.Font = Enum.Font.Gotham
	BodyLabel.TextWrapped = true
	BodyLabel.TextSize = 12
	BodyLabel.TextXAlignment = Enum.TextXAlignment.Left
	BodyLabel.TextYAlignment = Enum.TextYAlignment.Top
	BodyLabel.TextColor3 = RivalsUI.Theme.SubText
	BodyLabel.Text = body
	BodyLabel.Parent = TextHolder

	Container.MouseButton1Click:Connect(function()
		pcall(callback)
	end)

	local comp = setmetatable({
		Instance = Container,
		Header = HeaderLabel,
		Body = BodyLabel,
		__type = "ActionButton",
	}, ComponentBase)

	self.Window:RegisterSearchable(comp, HeaderLabel)
	return comp
end

function Section:Label(opts)
	opts = opts or {}
	local text = opts.Text or "Label"
	local targetTab = opts.Tab

	local parent = self:_getContentParent(targetTab)

	local Label = Instance.new("TextLabel")
	Label.Name = "Label"
	Label.BackgroundTransparency = 1
	Label.Size = UDim2.new(1, 0, 0, 18)
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 13
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextColor3 = RivalsUI.Theme.Text
	Label.TextWrapped = true
	Label.Text = text
	Label.Parent = parent

	return Label
end

function Section:SubLabel(opts)
	opts = opts or {}
	local text = opts.Text or "SubLabel"
	local targetTab = opts.Tab

	local parent = self:_getContentParent(targetTab)

	local Label = Instance.new("TextLabel")
	Label.Name = "SubLabel"
	Label.BackgroundTransparency = 1
	Label.Size = UDim2.new(1, 0, 0, 16)
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 12
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextColor3 = RivalsUI.Theme.SubText
	Label.TextWrapped = true
	Label.Text = text
	Label.Parent = parent

	return Label
end

---------------------------------------------------------------------
-- Components
---------------------------------------------------------------------

function Section:Button(opts)
	opts = opts or {}
	local name = opts.Name or opts.Text or "Button"
	local callback = opts.Callback or function() end
	local icon = opts.Icon
	local targetTab = opts.Tab

	local Row, Label, Right = createRow(self, name, targetTab)

	local Button = Instance.new("TextButton")
	Button.Name = name .. "_Button"
	Button.Size = UDim2.new(0, 98, 0, 26)
	Button.AnchorPoint = Vector2.new(1, 0.5)
	Button.Position = UDim2.new(1, 0, 0.5, 0)
	Button.BackgroundColor3 = RivalsUI.Theme.AccentSoft
	Button.AutoButtonColor = false
	Button.Font = Enum.Font.Gotham
	Button.TextSize = 13
	Button.TextColor3 = Color3.fromRGB(240, 241, 249)
	Button.Text = "Execute"
	Button.BorderSizePixel = 0
	createRoundCorner(6, Button)
	applyStroke(Button, RivalsUI.Theme.Outline, 1, 0.6)
	Button.Parent = Right

	if icon then
		local Icon = CreateIcon(icon, UDim2.fromOffset(14, 14), Color3.fromRGB(240, 241, 249))
		Icon.AnchorPoint = Vector2.new(0, 0.5)
		Icon.Position = UDim2.new(0, 8, 0.5, 0)
		Icon.Parent = Button

		local TextLabel = Instance.new("TextLabel")
		TextLabel.BackgroundTransparency = 1
		TextLabel.Position = UDim2.new(0, 26, 0, 0)
		TextLabel.Size = UDim2.new(1, -26, 1, 0)
		TextLabel.Font = Enum.Font.Gotham
		TextLabel.TextSize = 13
		TextLabel.TextColor3 = Button.TextColor3
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel.Text = "Run"
		TextLabel.Parent = Button

		Button.Text = ""
	end

	Button.MouseButton1Click:Connect(function()
		pcall(callback)
	end)

	local comp = setmetatable({
		Instance = Row,
		Button = Button,
		Label = Label,
		__type = "Button",
	}, ComponentBase)

	self.Window:RegisterSearchable(comp, Label)
	return comp
end

function Section:Toggle(opts)
	opts = opts or {}
	local name = opts.Name or "Toggle"
	local default = opts.Default
	local callback = opts.Callback or function() end
	local configKey = opts.Config -- config key from opts
	local targetTab = opts.Tab

	local Row, Label, Right = createRow(self, name, targetTab)

	local ToggleButton = Instance.new("TextButton")
	ToggleButton.Name = name .. "_Toggle"
	ToggleButton.AnchorPoint = Vector2.new(1, 0.5)
	ToggleButton.Position = UDim2.new(1, 0, 0.5, 0)
	ToggleButton.Size = UDim2.new(0, 44, 0, 22)
	ToggleButton.BackgroundColor3 = Color3.fromRGB(32, 34, 50)
	ToggleButton.AutoButtonColor = false
	ToggleButton.Text = ""
	ToggleButton.BorderSizePixel = 0
	createRoundCorner(11, ToggleButton)
	applyStroke(ToggleButton, RivalsUI.Theme.Outline, 1, 0.6)
	ToggleButton.Parent = Right

	local Knob = Instance.new("Frame")
	Knob.Name = "Knob"
	Knob.AnchorPoint = Vector2.new(0.5, 0.5)
	Knob.Position = UDim2.new(0, 11, 0.5, 0)
	Knob.Size = UDim2.new(0, 18, 0, 18)
	Knob.BackgroundColor3 = Color3.fromRGB(230, 231, 240)
	Knob.BorderSizePixel = 0
	createRoundCorner(9, Knob)
	Knob.Parent = ToggleButton

	local Value = default and true or false

	local function refresh(animated)
		local goalPos = Value and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0)
		local goalColor = Value and RivalsUI.Theme.Accent or Color3.fromRGB(32, 34, 50)
		if animated then
			TweenService:Create(ToggleButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = goalColor }):Play()
			TweenService:Create(Knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = goalPos }):Play()
		else
			ToggleButton.BackgroundColor3 = goalColor
			Knob.Position = goalPos
		end
	end

	ToggleButton.MouseButton1Click:Connect(function()
		Value = not Value
		refresh(true)
		pcall(callback, Value)
	end)

	refresh(false)

	local comp = setmetatable({
		Instance = Row,
		Toggle = ToggleButton,
		Label = Label,
		Value = function() return Value end,
		Set = function(_, v)
			Value = v and true or false
			refresh(false)
			pcall(callback, Value)
		end,
		__type = "Toggle",
	}, ComponentBase)

	self.Window:RegisterSearchable(comp, Label)

	if configKey then
		self.Window:_registerConfigBinding(configKey, setmetatable({
			_getter = function() return Value end,
		}, {
			__call = function(_, v)
				comp:Set(v)
			end
		}))
	end

	return comp
end

function Section:Slider(opts)
	opts = opts or {}
	local name = opts.Name or "Slider"
	local min = tonumber(opts.Minimum or 0)
	local max = tonumber(opts.Maximum or 100)
	local default = tonumber(opts.Default or min)
	local precision = tonumber(opts.Precision or 0)
	local step = tonumber(opts.Step or 0) -- 0 = no stepping
	local unit = opts.Unit and tostring(opts.Unit) or nil
	local callback = opts.Callback or function() end
	local configKey = opts.Config -- config key from opts
	local targetTab = opts.Tab

	local parent = self:_getContentParent(targetTab)

	local Row = Instance.new("Frame")
	Row.Name = name .. "_Row"
	Row.Size = UDim2.new(1, 0, 0, 40)
	Row.BackgroundTransparency = 1
	Row.Parent = parent

	local Label = Instance.new("TextLabel")
	Label.Name = "Label"
	Label.BackgroundTransparency = 1
	Label.Position = UDim2.new(0, 0, 0, 0)
	Label.Size = UDim2.new(1, 0, 0, 18)
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 13
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextColor3 = RivalsUI.Theme.Text
	Label.Text = name
	Label.Parent = Row

	local ValueLabel = Instance.new("TextLabel")
	ValueLabel.Name = "ValueLabel"
	ValueLabel.BackgroundTransparency = 1
	ValueLabel.AnchorPoint = Vector2.new(1, 0)
	ValueLabel.Position = UDim2.new(1, 0, 0, 0)
	ValueLabel.Size = UDim2.new(0, 80, 0, 18)
	ValueLabel.Font = Enum.Font.Gotham
	ValueLabel.TextSize = 12
	ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
	ValueLabel.TextColor3 = RivalsUI.Theme.SubText
	ValueLabel.TextTruncate = Enum.TextTruncate.AtEnd
	ValueLabel.Parent = Row

	local BarHolder = Instance.new("Frame")
	BarHolder.Name = "BarHolder"
	BarHolder.Position = UDim2.new(0, 0, 0, 22)
	BarHolder.Size = UDim2.new(1, 0, 0, 16)
	BarHolder.BackgroundTransparency = 1
	BarHolder.Parent = Row

	local Bar = Instance.new("Frame")
	Bar.Name = "Bar"
	Bar.AnchorPoint = Vector2.new(0, 0.5)
	Bar.Position = UDim2.new(0, 0, 0.5, 0)
	Bar.Size = UDim2.new(1, 0, 0, 4)
	Bar.BackgroundColor3 = Color3.fromRGB(32, 34, 50)
	Bar.BorderSizePixel = 0
	createRoundCorner(3, Bar)
	Bar.Parent = BarHolder

	local Fill = Instance.new("Frame")
	Fill.Name = "Fill"
	Fill.AnchorPoint = Vector2.new(0, 0.5)
	Fill.Position = UDim2.new(0, 0, 0.5, 0)
	Fill.Size = UDim2.new(0, 0, 1, 0)
	Fill.BackgroundColor3 = RivalsUI.Theme.Accent
	Fill.BorderSizePixel = 0
	createRoundCorner(3, Fill)
	Fill.Parent = Bar

	local DragButton = Instance.new("TextButton")
	DragButton.Name = "DragButton"
	DragButton.BackgroundTransparency = 1
	DragButton.Size = UDim2.new(1, 0, 1, 0)
	DragButton.Text = ""
	DragButton.Parent = BarHolder

	local Value = default

	local function round(num, decimals)
		local mult = 10 ^ decimals
		return math.floor(num * mult + 0.5) / mult
	end

	local function applyStep(v)
		if step and step > 0 then
			local snapped = math.floor((v - min) / step + 0.5) * step + min
			return snapped
		end
		return v
	end

	local function formatValue(v)
		local s = tostring(v)
		if unit then
			return s .. unit
		end
		return s
	end

	local function setValue(v, fromInput)
		if max == min then
			Value = min
			Fill.Size = UDim2.new(0, 0, 1, 0)
			ValueLabel.Text = formatValue(Value)
			if fromInput then
				pcall(callback, Value)
			end
			return
		end

		v = math.clamp(v, min, max)
		v = applyStep(v)
		v = round(v, precision)
		Value = v
		local alpha = (v - min) / (max - min)
		Fill.Size = UDim2.new(alpha, 0, 1, 0)
		ValueLabel.Text = formatValue(v)
		if fromInput then
			pcall(callback, v)
		end
	end

	local dragging = false
	local dragInput

	DragButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if input.UserInputState ~= Enum.UserInputState.Begin then return end
			dragging = true
			dragInput = input
			local rel = (input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X
			setValue(min + (max - min) * rel, true)
		end
	end)

	DragButton.InputEnded:Connect(function(input)
		if input == dragInput and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			dragInput = nil
		end
	end)

	DragButton.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local rel = (input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X
			setValue(min + (max - min) * rel, true)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input == dragInput and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			dragInput = nil
		end
	end)

	setValue(default, false)

	local comp = setmetatable({
		Instance = Row,
		Label = Label,
		Value = function() return Value end,
		Set = function(_, v)
			setValue(v, false)
			pcall(callback, Value)
		end,
		__type = "Slider",
	}, ComponentBase)

	self.Window:RegisterSearchable(comp, Label)

	if configKey then
		self.Window:_registerConfigBinding(configKey, setmetatable({
			_getter = function() return Value end,
		}, {
			__call = function(_, v)
				comp:Set(v)
			end
		}))
	end

	return comp
end

function Section:Input(opts)
	opts = opts or {}
	local name = opts.Name or "Input"
	local placeholder = opts.Placeholder or ""
	local default = opts.Default or ""
	local callback = opts.Callback or function() end
	local onChanged = opts.onChanged or function() end
	local configKey = opts.Config -- config key from opts
	local targetTab = opts.Tab

	local Row, Label, Right = createRow(self, name, targetTab)

	local Box = Instance.new("TextBox")
	Box.Name = name .. "_Input"
	Box.AnchorPoint = Vector2.new(1, 0.5)
	Box.Position = UDim2.new(1, 0, 0.5, 0)
	Box.Size = UDim2.new(0, 110, 0, 24)
	Box.BackgroundColor3 = Color3.fromRGB(23, 24, 35)
	Box.BorderSizePixel = 0
	Box.Font = Enum.Font.Gotham
	Box.TextSize = 12
	Box.TextColor3 = RivalsUI.Theme.Text
	Box.PlaceholderText = placeholder
	Box.PlaceholderColor3 = RivalsUI.Theme.SubText
	Box.TextXAlignment = Enum.TextXAlignment.Left
	Box.ClearTextOnFocus = false
	Box.Text = default
	createRoundCorner(6, Box)
	applyStroke(Box, RivalsUI.Theme.Outline, 1, 0.7)
	Box.Parent = Right

	local Padding = Instance.new("UIPadding")
	Padding.PaddingLeft = UDim.new(0, 6)
	Padding.Parent = Box

	Box.FocusLost:Connect(function(enter)
		if enter then
			pcall(callback, Box.Text)
		end
	end)

	Box:GetPropertyChangedSignal("Text"):Connect(function()
		pcall(onChanged, Box.Text)
	end)

	local comp = setmetatable({
		Instance = Row,
		Box = Box,
		Label = Label,
		Value = function() return Box.Text end,
		Set = function(_, v)
			Box.Text = tostring(v or "")
			pcall(callback, Box.Text)
		end,
		__type = "Input",
	}, ComponentBase)

	self.Window:RegisterSearchable(comp, Label)

	if configKey then
		self.Window:_registerConfigBinding(configKey, setmetatable({
			_getter = function() return Box.Text end,
		}, {
			__call = function(_, v)
				comp:Set(v)
			end
		}))
	end

	return comp
end

---------------------------------------------------------------------
-- Dropdown (single & multi, optional search, proper dropdown below trigger)
---------------------------------------------------------------------

function Section:Dropdown(opts)
	opts = opts or {}
	local name = opts.Name or "Dropdown"
	local multi = opts.Multi or false
	local options = opts.Options or {}
	local default = opts.Default
	local callback = opts.Callback or function() end
	local enableSearch = opts.Search or false
	local configKey = opts.Config -- config key from opts
	local targetTab = opts.Tab

	local Row, Label, Right = createRow(self, name, targetTab)

	local Button = Instance.new("TextButton")
	Button.Name = name .. "_Dropdown"
	Button.AnchorPoint = Vector2.new(1, 0.5)
	Button.Position = UDim2.new(1, 0, 0.5, 0)
	Button.Size = UDim2.new(0, 110, 0, 24)
	Button.BackgroundColor3 = Color3.fromRGB(23, 24, 35)
	Button.AutoButtonColor = false
	Button.Font = Enum.Font.Gotham
	Button.TextSize = 12
	Button.TextColor3 = RivalsUI.Theme.Text
	Button.TextXAlignment = Enum.TextXAlignment.Left
	Button.TextTruncate = Enum.TextTruncate.AtEnd
	Button.Text = "Select"
	Button.BorderSizePixel = 0
	createRoundCorner(6, Button)
	applyStroke(Button, RivalsUI.Theme.Outline, 1, 0.7)
	Button.Parent = Right

	local Padding = Instance.new("UIPadding")
	Padding.PaddingLeft = UDim.new(0, 6)
	Padding.PaddingRight = UDim.new(0, 26)
	Padding.Parent = Button

	local icon = CreateIcon("lucide:chevron-down", UDim2.fromOffset(10, 10), RivalsUI.Theme.SubText)
	icon.AnchorPoint = Vector2.new(1, 0.5)
	icon.Position = UDim2.new(1, -6, 0.5, 0)
	icon.Parent = Button

	-- Overlay within ScreenGui so it blocks clicks behind
	local Overlay = Instance.new("TextButton")
	Overlay.Name = name .. "_Overlay"
	Overlay.BackgroundTransparency = 1
	Overlay.Size = UDim2.new(1, 0, 1, 0)
	Overlay.Position = UDim2.new(0, 0, 0, 0)
	Overlay.ZIndex = 100
	Overlay.Visible = false
	Overlay.Text = ""
	Overlay.AutoButtonColor = false
	Overlay.Parent = self.Window.ScreenGui

	local ListFrame = Instance.new("ScrollingFrame")
	ListFrame.Name = name .. "_DropdownList"
	ListFrame.BackgroundColor3 = Color3.fromRGB(23, 24, 35)
	ListFrame.BorderSizePixel = 0
	ListFrame.Size = UDim2.new(0, 180, 0, 0)
    ListFrame.Position = UDim2.new(0, 0, 1, 0)
	ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ListFrame.ScrollBarThickness = 3
	ListFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 61, 80)
	ListFrame.ClipsDescendants = true
	createRoundCorner(6, ListFrame)
	applyStroke(ListFrame, RivalsUI.Theme.Outline, 1, 0.8)
	ListFrame.Parent = Overlay
	ListFrame.ZIndex = 101

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ListLayout.Padding = UDim.new(0, 2)
	ListLayout.Parent = ListFrame
	ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

	local ListPadding = Instance.new("UIPadding")
	ListPadding.PaddingTop = UDim.new(0, 4)
	ListPadding.PaddingBottom = UDim.new(0, 4)
	ListPadding.PaddingLeft = UDim.new(0, 4)
	ListPadding.PaddingRight = UDim.new(0, 4)
	ListPadding.Parent = ListFrame

	local searchBox
	if enableSearch then
		searchBox = Instance.new("TextBox")
		searchBox.Name = "SearchBox"
		searchBox.Size = UDim2.new(1, 0, 0, 20)
		searchBox.Position = UDim2.new(0,0,0,0)
		searchBox.BackgroundColor3 = Color3.fromRGB(18, 19, 28)
		searchBox.BorderSizePixel = 0
		searchBox.Font = Enum.Font.Gotham
		searchBox.TextSize = 12
		searchBox.TextColor3 = RivalsUI.Theme.Text
		searchBox.PlaceholderText = "Search..."
        searchBox.TextXAlignment = Enum.TextXAlignment.Left
		searchBox.PlaceholderColor3 = RivalsUI.Theme.SubText
		createRoundCorner(4, searchBox)
		applyStroke(searchBox, RivalsUI.Theme.Outline, 1, 0.6)
		searchBox.Parent = ListFrame
		searchBox.ZIndex = 102
        searchBox.LayoutOrder = 0

		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 6)
		pad.Parent = searchBox
	end

	local Selected
	local SelectedMulti = {}

	local function updateText()
		if multi then
			local t = {}
			for v, state in pairs(SelectedMulti) do
				if state then table.insert(t, tostring(v)) end
			end
			if #t == 0 then
				Button.Text = "Select"
			else
				local joined = table.concat(t, ", ")
				if #joined > 22 then
					Button.Text = string.sub(joined, 1, 19) .. "..."
				else
					Button.Text = joined
				end
			end
		else
			if not Selected then
				Button.Text = "Select"
			else
				local str = tostring(Selected)
				if #str > 22 then
					Button.Text = string.sub(str, 1, 19) .. "..."
				else
					Button.Text = str
				end
			end
		end
	end

	local function fireCallback()
		if multi then
			-- return as an array of selected option values, not boolean map
			local arr = {}
			for v, state in pairs(SelectedMulti) do
				if state then
					table.insert(arr, v)
				end
			end
			pcall(callback, arr)
		else
			pcall(callback, Selected)
		end
	end

	local function setSelection(value, state)
		if multi then
			if state == nil then state = not SelectedMulti[value] end
			SelectedMulti[value] = state
			updateText()
			fireCallback()
		else
			Selected = value
			updateText()
			fireCallback()
		end
	end

	local OptionButtons = {}

	local function rebuild()
		for _, v in ipairs(OptionButtons) do
			v:Destroy()
		end
		OptionButtons = {}

		local filter = ""
		if enableSearch and searchBox then
			filter = string.lower(searchBox.Text or "")
		end

		for _, opt in ipairs(options) do
			local str = tostring(opt)
			if filter == "" or string.find(string.lower(str), filter, 1, true) then
				local OptButton = Instance.new("TextButton")
				OptButton.Name = str
				OptButton.AutoButtonColor = true
				OptButton.BackgroundColor3 = Color3.fromRGB(28, 29, 42)
				OptButton.BorderSizePixel = 0
				OptButton.Size = UDim2.new(1, 0, 0, 22)
				OptButton.Font = Enum.Font.Gotham
				OptButton.TextSize = 12
				OptButton.TextColor3 = RivalsUI.Theme.Text
				OptButton.TextXAlignment = Enum.TextXAlignment.Left
				OptButton.Text = str
				createRoundCorner(4, OptButton)
				OptButton.Parent = ListFrame
				OptButton.ZIndex = 102

				local Pad = Instance.new("UIPadding")
				Pad.PaddingLeft = UDim.new(0, 6)
				Pad.Parent = OptButton

				local function refreshSelectedColor()
					local isSelected
					if multi then
						isSelected = SelectedMulti[opt]
					else
						isSelected = (Selected == opt)
					end
					OptButton.BackgroundColor3 = isSelected and Color3.fromRGB(40, 42, 60) or Color3.fromRGB(28, 29, 42)
				end

				refreshSelectedColor()

				OptButton.MouseButton1Click:Connect(function()
					setSelection(opt)
					refreshSelectedColor()
					if not multi then
						Overlay.Visible = false
						if RivalsUI._activeDropdown == Overlay then
							RivalsUI._activeDropdown = nil
						end
					end
				end)

				table.insert(OptionButtons, OptButton)
			end
		end

		local contentHeight = ListLayout.AbsoluteContentSize.Y
		local topPadding = ListPadding.PaddingTop.Offset
		local bottomPadding = ListPadding.PaddingBottom.Offset
		local desiredHeight = contentHeight + topPadding + bottomPadding
		local finalHeight = math.clamp(desiredHeight, 30, 200)
		ListFrame.Size = UDim2.new(0, 180, 0, finalHeight)
		ListFrame.CanvasSize = UDim2.new(0, 0, 0, desiredHeight)
	end

	if enableSearch and searchBox then
		searchBox:GetPropertyChangedSignal("Text"):Connect(rebuild)
	end

	rebuild()

	local function openOverlay()
		if RivalsUI._activeDropdown and RivalsUI._activeDropdown ~= Overlay then
			RivalsUI._activeDropdown.Visible = false
		end

		RivalsUI._activeDropdown = Overlay

		local absPos = Button.AbsolutePosition
		local absSize = Button.AbsoluteSize
        ListFrame.Position = UDim2.fromOffset(
            absPos.X,
            absPos.Y + absSize.Y + (enableSearch and 4 or 4)
        )
		Overlay.Visible = true
	end

	local function closeOverlay()
		Overlay.Visible = false
		if RivalsUI._activeDropdown == Overlay then
			RivalsUI._activeDropdown = nil
		end
	end

	Button.MouseButton1Click:Connect(function()
		if Overlay.Visible then
			closeOverlay()
		else
			if enableSearch and searchBox then
				searchBox.Text = ""
			end
			rebuild()
			openOverlay()
		end
	end)

	Overlay.MouseButton1Click:Connect(function()
		local pos = UserInputService:GetMouseLocation()
		local absPos = ListFrame.AbsolutePosition
		local absSize = ListFrame.AbsoluteSize
		if pos.X < absPos.X or pos.X > absPos.X + absSize.X or pos.Y < absPos.Y or pos.Y > absPos.Y + absSize.Y then
			closeOverlay()
		end
	end)

	local comp = setmetatable({
		Instance = Row,
		Label = Label,
		Set = function(selfObj, value)
			if multi then
				SelectedMulti = {}
				if type(value) == "table" then
					-- value is expected to be an array of selected options from config
					for _, v in ipairs(value) do
						SelectedMulti[v] = true
					end
				elseif value ~= nil then
					SelectedMulti[value] = true
				end
				updateText()
				fireCallback()
				rebuild()
			else
				Selected = value
				updateText()
				fireCallback()
				rebuild()
			end
		end,
		Value = function()
			if multi then
				local arr = {}
				for v, state in pairs(SelectedMulti) do
					if state then table.insert(arr, v) end
				end
				return arr
			else
				return Selected
			end
		end,
		UpdateOptions = function(_, newOptions)
			options = newOptions or {}
			rebuild()
		end,
		Select = function(selfObj, value)
			selfObj:Set(value)
		end,
		__type = "Dropdown",
	}, ComponentBase)

	self.Window:RegisterSearchable(comp, Label)

	if default ~= nil then
		comp:Set(default)
	end

	if configKey then
		self.Window:_registerConfigBinding(configKey, setmetatable({
			_getter = function()
				return comp:Value()
			end,
		}, {
			__call = function(_, v)
				comp:Set(v)
			end
		}))
	end

	return comp
end

---------------------------------------------------------------------
-- Keybind
---------------------------------------------------------------------

function Section:Keybind(opts)
	opts = opts or {}
	local name = opts.Name or "Keybind"
	local callback = opts.Callback or function() end
	local onBinded = opts.onBinded or function() end
	local configKey = opts.Config -- config key from opts
	local targetTab = opts.Tab

	local Row, Label, Right = createRow(self, name, targetTab)

	local Button = Instance.new("TextButton")
	Button.Name = name .. "_Keybind"
	Button.AnchorPoint = Vector2.new(1, 0.5)
	Button.Position = UDim2.new(1, 0, 0.5, 0)
	Button.Size = UDim2.new(0, 80, 0, 24)
	Button.BackgroundColor3 = Color3.fromRGB(23, 24, 35)
	Button.AutoButtonColor = false
	Button.Font = Enum.Font.Gotham
	Button.TextSize = 12
	Button.TextColor3 = RivalsUI.Theme.Text
	Button.Text = "None"
	Button.BorderSizePixel = 0
	createRoundCorner(6, Button)
	applyStroke(Button, RivalsUI.Theme.Outline, 1, 0.7)
	Button.Parent = Right

	local CurrentKey
	local Listening = false

	local function displayKey()
		if not CurrentKey then
			Button.Text = "None"
		else
			Button.Text = CurrentKey.Name
		end
	end

	Button.MouseButton1Click:Connect(function()
		if Listening then return end
		Listening = true
		Button.Text = "Press..."
		local conn
		conn = UserInputService.InputBegan:Connect(function(input, gp)
			if gp then return end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				CurrentKey = input.KeyCode
				Listening = false
				displayKey()
				pcall(onBinded, CurrentKey)
				if conn then conn:Disconnect() end
			end
		end)
	end)

	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if CurrentKey and input.KeyCode == CurrentKey then
			pcall(callback, CurrentKey)
		end
	end)

	displayKey()

	local comp = setmetatable({
		Instance = Row,
		Label = Label,
		Value = function() return CurrentKey and CurrentKey.Name or nil end,
		Set = function(_, keyName)
			if typeof(keyName) == "EnumItem" then
				CurrentKey = keyName
			elseif type(keyName) == "string" then
				for _, enum in ipairs(Enum.KeyCode:GetEnumItems()) do
					if enum.Name == keyName then
						CurrentKey = enum
						break
					end
				end
			else
				CurrentKey = nil
			end
			displayKey()
			pcall(onBinded, CurrentKey)
		end,
		__type = "Keybind",
	}, ComponentBase)

	self.Window:RegisterSearchable(comp, Label)

	if configKey then
		self.Window:_registerConfigBinding(configKey, setmetatable({
			_getter = function() return comp:Value() end,
		}, {
			__call = function(_, v)
				comp:Set(v)
			end
		}))
	end

	return comp
end

---------------------------------------------------------------------
-- Colorpicker (dialog-style, HSV map + hue + optional alpha)
---------------------------------------------------------------------

function Section:Colorpicker(opts)
	opts = opts or {}
	local name = opts.Name or "Colorpicker"
	local default = opts.Default or Color3.new(1, 1, 1)
	local alphaDefault = opts.Alpha
	local callback = opts.Callback or function() end
	local configKey = opts.Config -- config key from opts
	local targetTab = opts.Tab

	local Row, Label, Right = createRow(self, name, targetTab)

	local Button = Instance.new("TextButton")
	Button.Name = name .. "_Colorpicker"
	Button.AnchorPoint = Vector2.new(1, 0.5)
	Button.Position = UDim2.new(1, 0, 0.5, 0)
	Button.Size = UDim2.new(0, 80, 0, 22)
	Button.BackgroundColor3 = default
	Button.AutoButtonColor = false
	Button.Text = ""
	Button.BorderSizePixel = 0
	createRoundCorner(6, Button)
	applyStroke(Button, RivalsUI.Theme.Outline, 1, 0.7)
	Button.Parent = Right

	local CurrentColor = default
	local CurrentAlpha = alphaDefault

	local function applyColor(c, a, fromInput)
		CurrentColor = c
		if a ~= nil then CurrentAlpha = math.clamp(a, 0, 1) end
		Button.BackgroundColor3 = c
		if fromInput then
			if CurrentAlpha ~= nil then
				pcall(callback, c, CurrentAlpha)
			else
				pcall(callback, c)
			end
		end
	end

	local function openPicker()
		local Main = self.Window.Main

		local overlay = Instance.new("TextButton")
		overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		overlay.BackgroundTransparency = 0.35
		overlay.BorderSizePixel = 0
		overlay.Size = UDim2.new(1, 0, 1, 0)
		overlay.Position = UDim2.new(0, 0, 0, 0)
		overlay.ZIndex = 250
		overlay.Text = ""
		overlay.AutoButtonColor = false
		overlay.Parent = Main

		local frameHeight = alphaDefault and 260 or 230
		local PickerFrame = Instance.new("Frame")
		PickerFrame.Name = name .. "_Picker"
		PickerFrame.Size = UDim2.new(0, 320, 0, frameHeight)
		PickerFrame.BackgroundColor3 = Color3.fromRGB(23, 24, 35)
		PickerFrame.BorderSizePixel = 0
		createRoundCorner(8, PickerFrame)
		applyStroke(PickerFrame, RivalsUI.Theme.Outline, 1, 0.8)
		PickerFrame.Parent = overlay
		PickerFrame.ZIndex = 251
		PickerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		PickerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

		local TitleLabel = Instance.new("TextLabel")
		TitleLabel.BackgroundTransparency = 1
		TitleLabel.Size = UDim2.new(1, -10, 0, 18)
		TitleLabel.Position = UDim2.new(0, 8, 0, 8)
		TitleLabel.Font = Enum.Font.GothamBold
		TitleLabel.TextSize = 13
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		TitleLabel.TextColor3 = RivalsUI.Theme.Text
		TitleLabel.Text = name
		TitleLabel.ZIndex = 252
		TitleLabel.Parent = PickerFrame

		local SatVibMap = Instance.new("ImageButton")
		SatVibMap.Name = "SatVibMap"
		SatVibMap.Position = UDim2.new(0, 10, 0, 34)
		SatVibMap.Size = UDim2.new(0, 160, 0, 130)
		SatVibMap.Image = "rbxassetid://4155801252"
		SatVibMap.BorderSizePixel = 0
		SatVibMap.ZIndex = 252
		SatVibMap.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
		SatVibMap.Parent = PickerFrame

		createRoundCorner(8, SatVibMap)
		applyStroke(SatVibMap, RivalsUI.Theme.Outline, 1, 0.7)

		local SatCursor = Instance.new("Frame")
		SatCursor.Size = UDim2.new(0, 10, 0, 10)
		SatCursor.AnchorPoint = Vector2.new(0.5, 0.5)
		SatCursor.Position = UDim2.new(0.5, 0, 0.5, 0)
		SatCursor.BackgroundColor3 = default
		SatCursor.BorderSizePixel = 0
		createRoundCorner(1, SatCursor)
		applyStroke(SatCursor, Color3.new(1, 1, 1), 2, 0)
		SatCursor.ZIndex = 253
		SatCursor.Parent = SatVibMap

		local HueSlider = Instance.new("Frame")
		HueSlider.Name = "HueSlider"
		HueSlider.Size = UDim2.fromOffset(8, 130)
		HueSlider.Position = UDim2.new(0, 180, 0, 34)
		HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		HueSlider.BorderSizePixel = 0
		HueSlider.ZIndex = 252
		HueSlider.Parent = PickerFrame
		createRoundCorner(4, HueSlider)

		local SequenceTable = {}
		for c = 0, 1, 0.1 do
			table.insert(SequenceTable, ColorSequenceKeypoint.new(c, Color3.fromHSV(c, 1, 1)))
		end

		local HueGradient = Instance.new("UIGradient")
		HueGradient.Rotation = 90
		HueGradient.Color = ColorSequence.new(SequenceTable)
		HueGradient.Parent = HueSlider

		local HueDrag = Instance.new("Frame")
		HueDrag.Size = UDim2.new(1, 4, 0, 4)
		HueDrag.AnchorPoint = Vector2.new(0.5, 0.5)
		HueDrag.Position = UDim2.new(0.5, 0, 0, 0)
		HueDrag.BackgroundColor3 = default
		HueDrag.BorderSizePixel = 0
		createRoundCorner(2, HueDrag)
		applyStroke(HueDrag, Color3.new(1, 1, 1), 2, 0)
		HueDrag.ZIndex = 253
		HueDrag.Parent = HueSlider

		local AlphaSlider, AlphaDrag
		if alphaDefault ~= nil then
			AlphaSlider = Instance.new("Frame")
			AlphaSlider.Name = "AlphaSlider"
			AlphaSlider.Size = UDim2.fromOffset(8, 130)
			AlphaSlider.Position = UDim2.new(0, 200, 0, 34)
			AlphaSlider.BackgroundTransparency = 1
			AlphaSlider.ZIndex = 252
			AlphaSlider.Parent = PickerFrame

			local checker = Instance.new("ImageLabel")
			checker.Image = "rbxassetid://14204231522"
			checker.ImageTransparency = 0.45
			checker.ScaleType = Enum.ScaleType.Tile
			checker.TileSize = UDim2.fromOffset(12, 12)
			checker.BackgroundTransparency = 1
			checker.Size = UDim2.fromScale(1, 1)
			checker.Parent = AlphaSlider
			createRoundCorner(4, checker)

			local AlphaColor = Instance.new("Frame")
			AlphaColor.Size = UDim2.fromScale(1, 1)
			AlphaColor.BackgroundColor3 = default
			AlphaColor.BorderSizePixel = 0
			AlphaColor.Parent = AlphaSlider
			createRoundCorner(4, AlphaColor)

			local grad = Instance.new("UIGradient")
			grad.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1),
			})
			grad.Rotation = 270
			grad.Parent = AlphaColor

			AlphaDrag = Instance.new("Frame")
			AlphaDrag.Size = UDim2.new(1, 4, 0, 4)
			AlphaDrag.AnchorPoint = Vector2.new(0.5, 0.5)
			AlphaDrag.Position = UDim2.new(0.5, 0, 0, 0)
			AlphaDrag.BackgroundColor3 = default
			AlphaDrag.BorderSizePixel = 0
			createRoundCorner(2, AlphaDrag)
			applyStroke(AlphaDrag, Color3.new(1, 1, 1), 2, 0)
			AlphaDrag.ZIndex = 253
			AlphaDrag.Parent = AlphaSlider
		end

		local OldDisplay = Instance.new("Frame")
		OldDisplay.BackgroundColor3 = CurrentColor
		OldDisplay.Size = UDim2.fromOffset(70, 22)
		OldDisplay.Position = UDim2.new(0, 10, 0, 34 + 130 + 10)
		OldDisplay.BorderSizePixel = 0
		createRoundCorner(6, OldDisplay)
		applyStroke(OldDisplay, RivalsUI.Theme.Outline, 1, 0.7)
		OldDisplay.ZIndex = 252
		OldDisplay.Parent = PickerFrame

		local NewDisplay = Instance.new("Frame")
		NewDisplay.BackgroundColor3 = CurrentColor
		NewDisplay.Size = UDim2.fromOffset(70, 22)
		NewDisplay.Position = UDim2.new(0, 90, 0, 34 + 130 + 10)
		NewDisplay.BorderSizePixel = 0
		createRoundCorner(6, NewDisplay)
		applyStroke(NewDisplay, RivalsUI.Theme.Outline, 1, 0.7)
		NewDisplay.ZIndex = 252
		NewDisplay.Parent = PickerFrame

		local Inputs = Instance.new("Frame")
		Inputs.BackgroundTransparency = 1
		Inputs.Position = UDim2.new(0, 180 + 20, 0, 34)
		Inputs.Size = UDim2.new(0, 110, 0, 110)
		Inputs.ZIndex = 252
		Inputs.Parent = PickerFrame

		local InputsLayout = Instance.new("UIListLayout")
		InputsLayout.Padding = UDim.new(0, 4)
		InputsLayout.FillDirection = Enum.FillDirection.Vertical
		InputsLayout.Parent = Inputs

		local function createInput(labelText, initial)
			local holder = Instance.new("Frame")
			holder.Size = UDim2.new(1, 0, 0, 24)
			holder.BackgroundTransparency = 1
			holder.Parent = Inputs
			holder.ZIndex = 252

			local lbl = Instance.new("TextLabel")
			lbl.BackgroundTransparency = 1
			lbl.Size = UDim2.new(0.5, 0, 1, 0)
			lbl.Font = Enum.Font.Gotham
			lbl.TextSize = 11
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.TextColor3 = RivalsUI.Theme.SubText
			lbl.Text = labelText
			lbl.ZIndex = 252
			lbl.Parent = holder

			local box = Instance.new("TextBox")
			box.Size = UDim2.new(0.5, -4, 1, 0)
			box.AnchorPoint = Vector2.new(1, 0)
			box.Position = UDim2.new(1, 0, 0, 0)
			box.BackgroundColor3 = Color3.fromRGB(18, 19, 28)
			box.BorderSizePixel = 0
			box.Font = Enum.Font.Gotham
			box.TextSize = 11
			box.TextXAlignment = Enum.TextXAlignment.Left
			box.TextColor3 = RivalsUI.Theme.Text
			box.ClearTextOnFocus = false
			box.Text = tostring(initial)
			createRoundCorner(4, box)
			applyStroke(box, RivalsUI.Theme.Outline, 1, 0.6)
			box.ZIndex = 252
			box.Parent = holder

			local pad = Instance.new("UIPadding")
			pad.PaddingLeft = UDim.new(0, 4)
			pad.Parent = box

			return box
		end

		local function ToRGB(color)
			return {
				R = math.floor(color.R * 255),
				G = math.floor(color.G * 255),
				B = math.floor(color.B * 255)
			}
		end

		local H, S, V = CurrentColor:ToHSV()
		local pendingHue, pendingSat, pendingVib = H, S, V
		local pendingAlpha = CurrentAlpha or 1

		local HexInput = createInput("Hex", "#" .. CurrentColor:ToHex())
		local rgb = ToRGB(CurrentColor)
		local RedInput = createInput("Red", rgb.R)
		local GreenInput = createInput("Green", rgb.G)
		local BlueInput = createInput("Blue", rgb.B)
		local AlphaInput
		if alphaDefault ~= nil then
			AlphaInput = createInput("Alpha", tostring(math.floor((pendingAlpha) * 100)) .. "%")
		end

		local ButtonsHolder = Instance.new("Frame")
		ButtonsHolder.BackgroundTransparency = 1
		ButtonsHolder.Position = UDim2.new(0, 0, 1, -40)
		ButtonsHolder.Size = UDim2.new(1, 0, 0, 32)
		ButtonsHolder.ZIndex = 252
		ButtonsHolder.Parent = PickerFrame

		local BtnLayout = Instance.new("UIListLayout")
		BtnLayout.FillDirection = Enum.FillDirection.Horizontal
		BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		BtnLayout.Padding = UDim.new(0, 10)
		BtnLayout.Parent = ButtonsHolder

		local function makeBtn(text, bg, fg)
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(0, 110, 0, 26)
			b.BackgroundColor3 = bg
			b.BorderSizePixel = 0
			b.Font = Enum.Font.Gotham
			b.TextSize = 13
			b.TextColor3 = fg
			b.Text = text
			b.AutoButtonColor = true
			createRoundCorner(6, b)
			applyStroke(b, RivalsUI.Theme.Outline, 1, 0.6)
			b.ZIndex = 253
			b.Parent = ButtonsHolder
			return b
		end

		local CancelBtn = makeBtn("Cancel", Color3.fromRGB(30, 32, 46), RivalsUI.Theme.Text)
		local ConfirmBtn = makeBtn("Apply", RivalsUI.Theme.Accent, Color3.fromRGB(240, 241, 249))

		local function updateVisuals()
			local color = Color3.fromHSV(pendingHue, pendingSat, pendingVib)
			SatVibMap.BackgroundColor3 = Color3.fromHSV(pendingHue, 1, 1)
			SatCursor.Position = UDim2.new(pendingSat, 0, 1 - pendingVib, 0)
			SatCursor.BackgroundColor3 = color
			NewDisplay.BackgroundColor3 = color
			HueDrag.BackgroundColor3 = Color3.fromHSV(pendingHue, 1, 1)
			HueDrag.Position = UDim2.new(0.5, 0, pendingHue, 0)

			local rgbNew = ToRGB(color)
			HexInput.Text = "#" .. color:ToHex()
			RedInput.Text = tostring(rgbNew.R)
			GreenInput.Text = tostring(rgbNew.G)
			BlueInput.Text = tostring(rgbNew.B)

			if alphaDefault ~= nil and AlphaSlider and AlphaDrag then
				local alphaColorFrame = AlphaSlider:FindFirstChildOfClass("Frame")
				if alphaColorFrame then
					alphaColorFrame.BackgroundColor3 = color
				end
				AlphaDrag.BackgroundColor3 = color
				AlphaDrag.Position = UDim2.new(0.5, 0, 1 - pendingAlpha, 0)
				if AlphaInput then
					AlphaInput.Text = tostring(math.floor(pendingAlpha * 100)) .. "%"
				end
			end
		end

		local function clamp(num, min, max)
			return math.clamp(tonumber(num) or 0, min, max)
		end

		HexInput.FocusLost:Connect(function(enter)
			if not enter then return end
			local hex = HexInput.Text:gsub("#", "")
			local ok, res = pcall(Color3.fromHex, hex)
			if ok and typeof(res) == "Color3" then
				pendingHue, pendingSat, pendingVib = res:ToHSV()
				updateVisuals()
			end
		end)

		local function updateFromRGBInput(box, component)
			box.FocusLost:Connect(function(enter)
				if not enter then return end
				local current = ToRGB(Color3.fromHSV(pendingHue, pendingSat, pendingVib))
				local clamped = clamp(box.Text, 0, 255)
				box.Text = tostring(clamped)
				current[component] = clamped
				local result = Color3.fromRGB(current.R, current.G, current.B)
				pendingHue, pendingSat, pendingVib = result:ToHSV()
				updateVisuals()
			end)
		end

		updateFromRGBInput(RedInput, "R")
		updateFromRGBInput(GreenInput, "G")
		updateFromRGBInput(BlueInput, "B")

		if alphaDefault ~= nil and AlphaInput then
			AlphaInput.FocusLost:Connect(function(enter)
				if not enter then return end
				local clamped = clamp(AlphaInput.Text:gsub("%%", ""), 0, 100)
				AlphaInput.Text = tostring(clamped) .. "%"
				pendingAlpha = clamped / 100
				updateVisuals()
			end)
		end

		local mouse = LocalPlayer:GetMouse()

		SatVibMap.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					local minX = SatVibMap.AbsolutePosition.X
					local maxX = minX + SatVibMap.AbsoluteSize.X
					local mouseX = math.clamp(mouse.X, minX, maxX)

					local minY = SatVibMap.AbsolutePosition.Y
					local maxY = minY + SatVibMap.AbsoluteSize.Y
					local mouseY = math.clamp(mouse.Y, minY, maxY)

					pendingSat = (mouseX - minX) / (maxX - minX)
					pendingVib = 1 - ((mouseY - minY) / (maxY - minY))
					updateVisuals()

					RunService.RenderStepped:Wait()
				end
			end
		end)

		HueSlider.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					local minY = HueSlider.AbsolutePosition.Y
					local maxY = minY + HueSlider.AbsoluteSize.Y
					local mouseY = math.clamp(mouse.Y, minY, maxY)

					pendingHue = ((mouseY - minY) / (maxY - minY))
					updateVisuals()

					RunService.RenderStepped:Wait()
				end
			end
		end)

		if alphaDefault ~= nil and AlphaSlider then
			AlphaSlider.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
						local minY = AlphaSlider.AbsolutePosition.Y
						local maxY = minY + AlphaSlider.AbsoluteSize.Y
						local mouseY = math.clamp(mouse.Y, minY, maxY)

						pendingAlpha = 1 - ((mouseY - minY) / (maxY - minY))
						updateVisuals()

						RunService.RenderStepped:Wait()
					end
				end
			end)
		end

		CancelBtn.MouseButton1Click:Connect(function()
			overlay:Destroy()
		end)

		ConfirmBtn.MouseButton1Click:Connect(function()
			local color = Color3.fromHSV(pendingHue, pendingSat, pendingVib)
			applyColor(color, alphaDefault ~= nil and pendingAlpha or nil, true)
			overlay:Destroy()
		end)

		overlay.MouseButton1Click:Connect(function()
			local pos = UserInputService:GetMouseLocation()
			local absPos = PickerFrame.AbsolutePosition
			local absSize = PickerFrame.AbsoluteSize
			if pos.X < absPos.X or pos.X > absPos.X + absSize.X or pos.Y < absPos.Y or pos.Y > absPos.Y + absSize.Y then
				overlay:Destroy()
			end
		end)

		updateVisuals()
	end

	Button.MouseButton1Click:Connect(openPicker)

	applyColor(default, CurrentAlpha, false)

	local comp = setmetatable({
		Instance = Row,
		Label = Label,
		SetColor = function(_, c, a)
			applyColor(c, a ~= nil and a or CurrentAlpha, true)
		end,
		Value = function()
			return CurrentColor, CurrentAlpha
		end,
		__type = "Colorpicker",
	}, ComponentBase)

	self.Window:RegisterSearchable(comp, Label)

	if configKey then
		self.Window:_registerConfigBinding(configKey, setmetatable({
			_getter = function()
				local c, a = comp:Value()
				return {Color = {c.R, c.G, c.B}, Alpha = a}
			end,
		}, {
			__call = function(_, v)
				if type(v) == "table" and v.Color then
					local c = Color3.new(v.Color[1], v.Color[2], v.Color[3])
					comp:SetColor(c, v.Alpha)
				end
			end
		}))
	end

	return comp
end

---------------------------------------------------------------------
-- ViewportFrame Component (for model previews / ESP previews)
---------------------------------------------------------------------

function Section:ViewportFrame(opts)
	opts = opts or {}
	local name = opts.Name or "ViewportFrame"
	local height = tonumber(opts.Height or 180)
	local model = opts.Model -- Instance (Model) to clone into viewport
	local fov = tonumber(opts.FOV or 45)
	local distance = tonumber(opts.Distance or 8)
	local lightColor = opts.LightColor or Color3.fromRGB(255, 255, 255)
	local backgroundColor = opts.BackgroundColor -- now optional; default transparent
	local ambient = opts.Ambient or Color3.fromRGB(80, 80, 80)
	local outlineColor = opts.OutlineColor or RivalsUI.Theme.Outline
	local targetTab = opts.Tab

	-- outer container row (full-width inside section)
	local parent = self:_getContentParent(targetTab)

	local Container = Instance.new("Frame")
	Container.Name = name .. "_ViewportRow"
	Container.Size = UDim2.new(1, 0, 0, height)
	Container.BackgroundTransparency = 1
	Container.Parent = parent

	local Header = Instance.new("TextLabel")
	Header.Name = "ViewportHeader"
	Header.BackgroundTransparency = 1
	Header.Size = UDim2.new(1, 0, 0, 18)
	Header.Font = Enum.Font.Gotham
	Header.TextSize = 13
	Header.TextXAlignment = Enum.TextXAlignment.Left
	Header.TextColor3 = RivalsUI.Theme.Text
	Header.Text = name
	Header.Parent = Container

	local FrameHolder = Instance.new("Frame")
	FrameHolder.Name = "Holder"
	FrameHolder.Position = UDim2.new(0, 0, 0, 22)
	FrameHolder.Size = UDim2.new(1, 0, 1, -24)
	FrameHolder.BackgroundColor3 = RivalsUI.Theme.Section
	FrameHolder.BorderSizePixel = 0
	createRoundCorner(8, FrameHolder)
	applyStroke(FrameHolder, outlineColor, 1, 0.7)
	FrameHolder.Parent = Container

	local VP = Instance.new("ViewportFrame")
	VP.Name = "Viewport"
	VP.BackgroundTransparency = backgroundColor and 0 or 1
	if backgroundColor then
		VP.BackgroundColor3 = backgroundColor
	end
	VP.Ambient = ambient
	VP.LightColor = lightColor
	VP.LightDirection = Vector3.new(0, -1, -0.5)
	VP.Size = UDim2.new(1, -4, 1, -4)
	VP.Position = UDim2.new(0, 2, 0, 2)
	VP.CurrentCamera = Instance.new("Camera")
	VP.CurrentCamera.Parent = VP
	VP.Parent = FrameHolder

	-- optional: subtle corner & stroke inside holder
	createRoundCorner(7, VP)

	local currentModel

	local function setModel(m)
		if currentModel then
			currentModel:Destroy()
			currentModel = nil
		end

		if typeof(m) == "Instance" and m:IsA("Model") then
			local clone = m:Clone()
			clone.Parent = VP
			currentModel = clone

			local primary = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)
			if primary then
				local cf, size = clone:GetBoundingBox()
				local radius = (size.Magnitude / 2)
				local cam = VP.CurrentCamera
				local dist = distance
				if radius > 0 then
					local fovRad = math.rad(fov)
					dist = math.max(dist, radius / math.tan(fovRad / 2)) + 2
				end

				cam.FieldOfView = fov
				cam.CFrame = CFrame.new(cf.Position + Vector3.new(0, radius * 0.3, dist), cf.Position)
			end
		end
	end

	if model then
		setModel(model)
	end

	local comp = setmetatable({
		Instance = Container,
		Viewport = VP,
		Header = Header,
		SetModel = function(_, m)
			setModel(m)
		end,
		SetFOV = function(_, newFov)
			fov = tonumber(newFov) or fov
			if VP.CurrentCamera and currentModel then
				local cf, size = currentModel:GetBoundingBox()
				local radius = (size.Magnitude / 2)
				local cam = VP.CurrentCamera
				local dist = distance
				if radius > 0 then
					local fovRad = math.rad(fov)
					dist = math.max(dist, radius / math.tan(fovRad / 2)) + 2
				end
				cam.FieldOfView = fov
				cam.CFrame = CFrame.new(cf.Position + Vector3.new(0, radius * 0.3, dist), cf.Position)
			end
		end,
		__type = "ViewportFrame",
	}, ComponentBase)

	self.Window:RegisterSearchable(comp, Header)
	return comp
end

---------------------------------------------------------------------
-- Config Tab Helper (named configs in /Configs subfolder)
---------------------------------------------------------------------

local function sanitizeConfigName(name)
	name = tostring(name or ""):gsub("^%s*(.-)%s*$", "%1")
	name = name:gsub("[%c\/:*?<>|]", "_")
	return name
end

local function getConfigFilePath(name)
	local cfgFolder = getConfigsFolder()
	return string.format("%s/%s.json", cfgFolder, name)
end

local function listConfigs()
	local files = {}
	if not listfiles or not isfolder then return files end
	local cfgFolder = getConfigsFolder()
	if not isfolder(cfgFolder) then
		return files
	end
	for _, path in ipairs(listfiles(cfgFolder)) do
		local short = path:match("[^/\\]+$") or path
		if short:sub(-5):lower() == ".json" then
			local name = short:sub(1, -6)
			table.insert(files, name)
		end
	end
	table.sort(files, function(a, b) return a:lower() < b:lower() end)
	return files
end

local function saveNamedConfig(name, window)
	if not (writefile and isfolder and makefolder) then return false, "Executor missing file APIs" end
	local cfgData = window:BuildConfigTable()
	ensureFolder(RivalsUI.Config.Folder)
	local cfgFolder = getConfigsFolder()
	ensureFolder(cfgFolder)
	local path = getConfigFilePath(name)
	writefile(path, HttpService:JSONEncode(cfgData))
	return true
end

local function loadNamedConfig(name, window)
	if not (readfile and isfile) then return false, "Executor missing file APIs" end
	local path = getConfigFilePath(name)
	if not isfile(path) then return false, "File not found" end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(path))
	end)
	if not ok or type(data) ~= "table" then
		return false, "Invalid config JSON"
	end
	window:ApplyConfig(data)
	return true
end

local function deleteNamedConfig(name)
	if not (isfile and delfile) then return false, "Executor missing file APIs" end
	local path = getConfigFilePath(name)
	if not isfile(path) then return false, "File not found" end
	delfile(path)
	return true
end

function RivalsUI:buildConfigTabUI(tab, window)
	-- Ensure base & configs folder exist (Meta.json stays in base)
	if isfolder and makefolder then
		ensureFolder(RivalsUI.Config.Folder)
		ensureFolder(getConfigsFolder())
	end

	-- full-width section for everything
	local section = tab:Section({ Side = "Left", Name = "Configs" })

	-- search + create row
	local TopRow = Instance.new("Frame")
	TopRow.Name = "ConfigSearchRow"
	TopRow.Size = UDim2.new(1, 0, 0, 34)
	TopRow.BackgroundTransparency = 1
	TopRow.Parent = section.Frame

	local RowLayout = Instance.new("UIListLayout")
	RowLayout.FillDirection = Enum.FillDirection.Horizontal
	RowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	RowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	RowLayout.Padding = UDim.new(0, 8)
	RowLayout.Parent = TopRow

	local SearchBoxHolder = Instance.new("Frame")
	SearchBoxHolder.Name = "SearchBoxHolder"
	SearchBoxHolder.Size = UDim2.new(1, -40, 1, 0)
	SearchBoxHolder.BackgroundColor3 = Color3.fromRGB(23, 24, 35)
	SearchBoxHolder.BorderSizePixel = 0
	createRoundCorner(8, SearchBoxHolder)
	applyStroke(SearchBoxHolder, RivalsUI.Theme.Outline, 1, 0.6)
	SearchBoxHolder.Parent = TopRow

	local SearchPad = Instance.new("UIPadding")
	SearchPad.PaddingLeft = UDim.new(0, 8)
	SearchPad.PaddingRight = UDim.new(0, 8)
	SearchPad.Parent = SearchBoxHolder

	local SearchIcon = CreateIcon("lucide:search", UDim2.fromOffset(14, 14), RivalsUI.Theme.SubText)
	SearchIcon.AnchorPoint = Vector2.new(0, 0.5)
	SearchIcon.Position = UDim2.new(0, 0, 0.5, 0)
	SearchIcon.Parent = SearchBoxHolder

	local SearchBox = Instance.new("TextBox")
	SearchBox.Name = "ConfigSearchBox"
	SearchBox.BackgroundTransparency = 1
	SearchBox.Position = UDim2.new(0, 20, 0, 0)
	SearchBox.Size = UDim2.new(1, -24, 1, 0)
	SearchBox.Font = Enum.Font.Gotham
	SearchBox.TextSize = 12
	SearchBox.TextXAlignment = Enum.TextXAlignment.Left
	SearchBox.TextColor3 = RivalsUI.Theme.Text
	SearchBox.PlaceholderText = "Search configs..."
	SearchBox.PlaceholderColor3 = RivalsUI.Theme.SubText
	SearchBox.ClearTextOnFocus = false
	SearchBox.Text = ""
	SearchBox.Parent = SearchBoxHolder

	local CreateButton = Instance.new("TextButton")
	CreateButton.Name = "CreateConfigButton"
	CreateButton.Size = UDim2.new(0, 32, 0, 30)
	CreateButton.BackgroundColor3 = Color3.fromRGB(40, 160, 100)
	CreateButton.AutoButtonColor = true
	CreateButton.Text = "+"
	CreateButton.Font = Enum.Font.GothamBold
	CreateButton.TextSize = 18
	CreateButton.TextColor3 = Color3.fromRGB(235, 235, 240)
	CreateButton.BorderSizePixel = 0
	createRoundCorner(8, CreateButton)
	applyStroke(CreateButton, Color3.fromRGB(20, 80, 50), 1, 0.3)
	CreateButton.Parent = TopRow

	-- extra small spacer between top row and list
	local Spacer = Instance.new("Frame")
	Spacer.Name = "ConfigsTopSpacer"
	Spacer.BackgroundTransparency = 1
	Spacer.Size = UDim2.new(1, 0, 0, 4)
	Spacer.Parent = section.Frame

	-- Configs list
	local ListHolder = Instance.new("Frame")
	ListHolder.Name = "ConfigsListHolder"
	ListHolder.BackgroundTransparency = 1
	ListHolder.Size = UDim2.new(1, 0, 0, 0)
	ListHolder.AutomaticSize = Enum.AutomaticSize.Y
	ListHolder.Parent = section.Frame

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ListLayout.Padding = UDim.new(0, 8)
	ListLayout.Parent = ListHolder

	-- AutomaticSize handles sizing so listener is removed

	local function refreshList()
		for _, child in ipairs(ListHolder:GetChildren()) do
			if child:IsA("Frame") and child.Name == "ConfigCard" then
				child:Destroy()
			end
		end

		local filter = string.lower(SearchBox.Text or "")
		local names = listConfigs()

		for _, cfgName in ipairs(names) do
			if filter == "" or string.find(string.lower(cfgName), filter, 1, true) then
				local isDefault = (RivalsUI.ConfigMeta.DefaultConfigName == cfgName)

				local Card = Instance.new("Frame")
				Card.Name = "ConfigCard"
				Card.Size = UDim2.new(1, 0, 0, 80)
				Card.BackgroundColor3 = Color3.fromRGB(24, 25, 36)
				Card.BorderSizePixel = 0
				createRoundCorner(8, Card)
				if isDefault then
					applyStroke(Card, RivalsUI.Theme.Warning, 1.5, 0) -- slightly slimmer border
				else
					applyStroke(Card, RivalsUI.Theme.Outline, 1, 0.6)
				end
				Card.Parent = ListHolder

				local Pad = Instance.new("UIPadding")
				Pad.PaddingTop = UDim.new(0, 8)
				Pad.PaddingBottom = UDim.new(0, 8)
				Pad.PaddingLeft = UDim.new(0, 10)
				Pad.PaddingRight = UDim.new(0, 10)
				Pad.Parent = Card

				local Top = Instance.new("Frame")
				Top.BackgroundTransparency = 1
				Top.Size = UDim2.new(1, 0, 0, 22)
				Top.Parent = Card

				local NameLabel = Instance.new("TextLabel")
				NameLabel.BackgroundTransparency = 1
				NameLabel.Size = UDim2.new(1, 0, 1, 0)
				NameLabel.Font = Enum.Font.GothamBold
				NameLabel.TextSize = 13
				NameLabel.TextXAlignment = Enum.TextXAlignment.Left
				NameLabel.TextColor3 = RivalsUI.Theme.Text
				NameLabel.Text = cfgName
				NameLabel.Parent = Top

				local DefaultTag
				if isDefault then
					DefaultTag = Instance.new("TextLabel")
					DefaultTag.BackgroundTransparency = 1
					DefaultTag.AnchorPoint = Vector2.new(1, 0.5)
					DefaultTag.Position = UDim2.new(1, 0, 0.5, 0)
					DefaultTag.Size = UDim2.new(0, 80, 0, 18)
					DefaultTag.Font = Enum.Font.Gotham
					DefaultTag.TextSize = 12
					DefaultTag.TextXAlignment = Enum.TextXAlignment.Right
					DefaultTag.TextColor3 = RivalsUI.Theme.Warning
					DefaultTag.Text = "Default"
					DefaultTag.Parent = Top
				end

				local ButtonsRow = Instance.new("Frame")
				ButtonsRow.BackgroundTransparency = 1
				ButtonsRow.Size = UDim2.new(1, 0, 0, 32)
				ButtonsRow.Position = UDim2.new(0, 0, 0, 30)
				ButtonsRow.Parent = Card

				local BtnLayout = Instance.new("UIListLayout")
				BtnLayout.FillDirection = Enum.FillDirection.Horizontal
				BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
				BtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
				BtnLayout.Padding = UDim.new(0, 6)
				BtnLayout.Parent = ButtonsRow

				local function makeSmallButton(text, color, textColor)
					local b = Instance.new("TextButton")
					b.Size = UDim2.new(0, 94, 0, 24)
					b.BackgroundColor3 = color
					b.BorderSizePixel = 0
					b.AutoButtonColor = true
					b.Font = Enum.Font.Gotham
					b.TextSize = 12
					b.TextColor3 = textColor
					b.Text = text
					createRoundCorner(6, b)
					applyStroke(b, RivalsUI.Theme.Outline, 1, 0.4)
					b.Parent = ButtonsRow
					return b
				end

				local OverwriteBtn = makeSmallButton("Overwrite", Color3.fromRGB(45, 50, 85), RivalsUI.Theme.Text)
				local LoadBtn = makeSmallButton("Load", RivalsUI.Theme.Accent, Color3.fromRGB(235, 235, 245))
				local DefaultBtn

				if isDefault then
					DefaultBtn = makeSmallButton("Default", RivalsUI.Theme.Warning, Color3.fromRGB(25, 20, 5))
					DefaultBtn.AutoButtonColor = false
					DefaultBtn.Active = false
					DefaultBtn.TextTransparency = 0.1
				else
					DefaultBtn = makeSmallButton("Make Default", Color3.fromRGB(60, 55, 35), RivalsUI.Theme.Warning)
				end

				-- New delete icon button
				local DeleteBtn = Instance.new("TextButton")
				DeleteBtn.Name = "DeleteConfigButton"
				DeleteBtn.Size = UDim2.new(0, 26, 0, 24)
				DeleteBtn.BackgroundColor3 = Color3.fromRGB(190, 60, 70)
				DeleteBtn.AutoButtonColor = true
				DeleteBtn.BorderSizePixel = 0
				DeleteBtn.Text = ""
				createRoundCorner(6, DeleteBtn)
				applyStroke(DeleteBtn, Color3.fromRGB(120, 35, 40), 1, 0.4)
				DeleteBtn.Parent = ButtonsRow

				local TrashIcon = CreateIcon("lucide:trash-2", UDim2.fromOffset(14, 14), Color3.fromRGB(245, 235, 235))
				TrashIcon.AnchorPoint = Vector2.new(0.5, 0.5)
				TrashIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
				TrashIcon.Parent = DeleteBtn

				OverwriteBtn.MouseButton1Click:Connect(function()
					window:Dialog({
						Title = "Overwrite Config",
						Description = "Are you sure you want to overwrite '" .. cfgName .. "'?",
						Callback = function()
							local ok, err = saveNamedConfig(cfgName, window)
							if ok then
								window:Notify({
									Title = window.Settings.Title,
									Description = "Config '" .. cfgName .. "' overwritten.",
									Lifetime = 3,
								})
							else
								window:Notify({
									Title = "Save Failed",
									Description = err or "Could not save config.",
									Lifetime = 4,
								})
							end
						end,
					})
				end)

				LoadBtn.MouseButton1Click:Connect(function()
					local ok, err = loadNamedConfig(cfgName, window)
					if ok then
						window:Notify({
							Title = window.Settings.Title,
							Description = "Config '" .. cfgName .. "' loaded.",
							Lifetime = 3,
						})
					else
						window:Notify({
							Title = "Load Failed",
							Description = err or "Could not load config.",
							Lifetime = 4,
						})
					end
				end)

				if not isDefault then
					DefaultBtn.MouseButton1Click:Connect(function()
						RivalsUI.ConfigMeta.DefaultConfigName = cfgName
						RivalsUI:SaveMeta()
						window:Notify({
							Title = window.Settings.Title,
							Description = "'" .. cfgName .. "' set as default config.",
							Lifetime = 3,
						})
						refreshList()
					end)
				end

				DeleteBtn.MouseButton1Click:Connect(function()
					window:Dialog({
						Title = "Delete Config",
						Description = "Are you sure you want to permanently delete '" .. cfgName .. "'?",
						Callback = function()
							local ok, err = deleteNamedConfig(cfgName)
							if ok then
								if RivalsUI.ConfigMeta.DefaultConfigName == cfgName then
									RivalsUI.ConfigMeta.DefaultConfigName = nil
									RivalsUI:SaveMeta()
								end
								window:Notify({
									Title = window.Settings.Title,
									Description = "Config '" .. cfgName .. "' deleted.",
									Lifetime = 3,
								})
								refreshList()
							else
								window:Notify({
									Title = "Delete Failed",
									Description = err or "Could not delete config.",
									Lifetime = 4,
								})
							end
						end,
					})
				end)
			end
		end
	end

	SearchBox:GetPropertyChangedSignal("Text"):Connect(refreshList)
	refreshList()

	CreateButton.MouseButton1Click:Connect(function()
		window:InputDialog({
			Title = "Create Config",
			Description = "Enter a name for the new config.",
			Placeholder = "MyConfig",
			ConfirmText = "Create",
			Callback = function(nameInput)
				local finalName = sanitizeConfigName(nameInput)
				if finalName == "" then return end

				-- Save current state into the new config by default
				local ok, err = saveNamedConfig(finalName, window)
				if ok then
					window:Notify({
						Title = window.Settings.Title,
						Description = "Config '" .. finalName .. "' created from current settings.",
						Lifetime = 3,
					})
					refreshList()
				else
					window:Notify({
						Title = "Create Failed",
						Description = err or "Could not create config.",
						Lifetime = 4,
					})
				end
			end,
		})
	end)

	return section
end

---------------------------------------------------------------------
-- AutoLoad Helper
---------------------------------------------------------------------

function RivalsUI:AutoLoad()
	-- Always reload meta from the current folder so DefaultConfigName matches Meta.json
	self:LoadMeta()

	if not self.ConfigMeta.AutoLoadDefault then
		return false, "AutoLoadDefault is disabled in Meta.json"
	end

	if not self.ConfigMeta.DefaultConfigName or self.ConfigMeta.DefaultConfigName == "" then
		return false, "No DefaultConfigName set in Meta.json"
	end

	if not self._lastWindow then
		return false, "No window created yet for AutoLoad to target"
	end

	local ok, err = loadNamedConfig(self.ConfigMeta.DefaultConfigName, self._lastWindow)
	return ok, err
end

---------------------------------------------------------------------
-- Demo Function (includes ESP tab using ViewportFrame previews + Section Tabs example)
---------------------------------------------------------------------

function RivalsUI.Demo()
	-- Load meta before creating window so folder-based meta is applied correctly
	RivalsUI:LoadMeta()

	local window = RivalsUI:Window({
		Title = "Rivals UI",
		Subtitle = "Executor UI Demo",
		Size = UDim2.fromOffset(920, 560),
		Keybind = Enum.KeyCode.RightControl,
		Folder = "RivalsUI" -- example: can be changed to any folder name per-window
	})

	local groups = {
		Main = window:TabGroup(),
	}

	local tabs = {
		Dashboard = groups.Main:Tab({ Name = "Dashboard", Icon = "lucide:home" }),
		Settings  = groups.Main:Tab({ Name = "Settings",  Icon = "lucide:settings" }),
		ESP       = groups.Main:Tab({ Name = "ESP",       Icon = "lucide:scan" }),
		Configs   = groups.Main:Tab({ Name = "Configs",   Icon = "lucide:folder", ConfigTab = true }),
	}

	local sections = {
		DashLeft = tabs.Dashboard:Section({ Side = "Left", Name = "Overview", Tabs = {"General", "Advanced"} }),
		DashRight = tabs.Dashboard:Section({ Side = "Right", Name = "Controls" }),
		SetLeft = tabs.Settings:Section({ Side = "Left", Name = "UI" }),
		SetRight = tabs.Settings:Section({ Side = "Right", Name = "Misc" }),
	}

	-- ESP tab sections: two on left for options, two on right for viewport previews
	local espSections = {
		EnemySettings = tabs.ESP:Section({ Side = "Left", Name = "Enemy ESP", Tabs = {"Player Tab", "Enemy Tab"} }),
		TeamSettings  = tabs.ESP:Section({ Side = "Left", Name = "Teammate ESP" }),
		EnemyPreview  = tabs.ESP:Section({ Side = "Right", Name = "Enemy Preview" }),
		TeamPreview   = tabs.ESP:Section({ Side = "Right", Name = "Teammate Preview" }),
	}

	-- Build dedicated configs tab UI via library method
	RivalsUI:buildConfigTabUI(tabs.Configs, window)

	------------------------------------------------------------------
	-- Dashboard Tab
	------------------------------------------------------------------

	sections.DashLeft:Header({ Name = "Session", Tab = "General" })
	sections.DashLeft:Paragraph({
		Header = "Welcome",
		Body = "This is the Rivals UI library (Lucide-styled). All components are configurable and support named JSON configs.",
		Tab = "General",
	})

	sections.DashLeft:Header({ Name = "Advanced Info", Tab = "Advanced" })
	sections.DashLeft:Label({ Text = "Current section tab: " .. tostring(sections.DashLeft:GetTab() or "nil"), Tab = "Advanced" })

	sections.DashLeft:Divider({ Tab = "General" })
	sections.DashLeft:Label({ Text = "Example Lucide Icons:", Tab = "General" })

	local IconRow = Instance.new("Frame")
	IconRow.BackgroundTransparency = 1
	IconRow.Size = UDim2.new(1, 0, 0, 26)
	IconRow.Parent = sections.DashLeft:_getContentParent("General")

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.Padding = UDim.new(0, 6)
	list.Parent = IconRow

	local function addIcon(name)
		local holder = Instance.new("Frame")
		holder.Size = UDim2.new(0, 26, 0, 26)
		holder.BackgroundTransparency = 1
		holder.Parent = IconRow
		local icon = CreateIcon(name, UDim2.fromOffset(20, 20), RivalsUI.Theme.Text)
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.new(0.5, 0, 0.5, 0)
		icon.Parent = holder
	end

	addIcon("lucide:home")
	addIcon("lucide:user")
	addIcon("lucide:bell")

	-- Right side: live controls
	sections.DashRight:Slider({
		Name = "WalkSpeed",
		Minimum = 8,
		Maximum = 32,
		Default = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed or 16,
		Precision = 0,
		Step = 0.5,
		Unit = "u/s",
		Callback = function(v)
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = v end
		end,
		Config = "WalkSpeed",
	})

	sections.DashRight:Slider({
		Name = "JumpPower",
		Minimum = 25,
		Maximum = 100,
		Default = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower or 50,
		Precision = 1,
		Step = 0.5,
		Unit = "u",
		Callback = function(v)
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum then hum.JumpPower = v end
		end,
		Config = "JumpPower",
	})

	sections.DashRight:Toggle({
		Name = "Fly Mode",
		Default = false,
		Callback = function(v)
			window:Notify({
				Title = window.Settings.Title,
				Description = (v and "Enabled" or "Disabled") .. " Fly Mode",
				Lifetime = 4,
			})
		end,
		Config = "FlyMode",
	})

	sections.DashRight:Input({
		Name = "Chat Spoof",
		Placeholder = "Enter chat message",
		Callback = function(text)
			print("Chat spoof message:", text)
		end,
		onChanged = function(text)
			-- live preview stub
		end,
		Config = "ChatSpoof",
	})

	sections.DashRight:Colorpicker({
		Name = "Accent Color",
		Default = RivalsUI.Theme.Accent,
		Alpha = 1,
		Callback = function(color, alpha)
			print("Accent color changed", color, alpha)
		end,
		Config = "AccentColor",
	})

	-- Action button example for notifications
	sections.DashRight:ActionButton({
		Header = "Test Notifications",
		Body = "Click to fire a sample RivalsUI notification.",
		Icon = "lucide:bell",
		Callback = function()
			window:Notify({
				Title = "Notification Test",
				Description = "This is a sample notification from the ActionButton.",
				Lifetime = 4,
			})
		end,
	})

	------------------------------------------------------------------
	-- Settings Tab
	------------------------------------------------------------------

	sections.SetLeft:Header({ Name = "UI Settings" })

	sections.SetLeft:Toggle({
		Name = "Blur Background",
		Default = false,
		Callback = function(enabled)
			local Lighting = game:GetService("Lighting")
			local blur = Lighting:FindFirstChild("RivalsUIBlur")
			if enabled then
				if not blur then
					blur = Instance.new("BlurEffect")
					blur.Name = "RivalsUIBlur"
					blur.Size = 12
					blur.Parent = Lighting
				end
			else
				if blur then blur:Destroy() end
			end
		end,
		Config = "UIBlur",
	})

	sections.SetLeft:Toggle({
		Name = "Notifications",
		Default = true,
		Callback = function(v)
			window:Notify({
				Title = "Notifications",
				Description = v and "Enabled" or "Disabled",
				Lifetime = 3,
			})
		end,
		Config = "Notifications",
	})

	sections.SetLeft:Dropdown({
		Name = "Theme",
		Options = {"Dark", "Dim", "Light"},
		Default = "Dark",
		Search = true,
		Callback = function(v)
			window:Notify({
				Title = "Theme",
				Description = "Selected: " .. tostring(v),
				Lifetime = 3,
			})
		end,
		Config = "Theme",
	})

	sections.SetLeft:Dropdown({
		Name = "Multi Select",
		Options = {"Apple", "Banana", "Orange", "Grape", "Mango"},
		Multi = true,
		Search = true,
		Default = {"Apple", "Orange"},
		Callback = function(values)
			local picked = {}
			for _, v in ipairs(values) do
				picked[#picked+1] = tostring(v)
			end
			window:Notify({
				Title = "Multi Select",
				Description = "Selected: " .. (#picked > 0 and table.concat(picked, ", ") or "None"),
				Lifetime = 3,
			})
		end,
		Config = "MultiDropdown",
	})

	sections.SetLeft:Keybind({
		Name = "Keybind Example",
		Callback = function(key)
			window:Notify({
				Title = "Keybind Pressed",
				Description = "Pressed " .. tostring(key and key.Name),
				Lifetime = 2,
			})
		end,
		onBinded = function(key)
			window:Notify({
				Title = "Keybind",
				Description = "Bound to " .. tostring(key and key.Name or "None"),
				Lifetime = 2,
			})
		end,
		Config = "MenuKey",
	})

	sections.SetRight:Header({ Name = "Notes" })
	sections.SetRight:Paragraph({
		Header = "Named Configs Only",
		Body = "Legacy single-file config has been removed. Use the Configs tab to create, save, load, delete, and set default named configs. Multi-dropdown selections are stored as arrays of selected values and restore correctly.",
	})

	------------------------------------------------------------------
	-- ESP Tab: Left sections for settings, Right sections for previews
	------------------------------------------------------------------

	-- Enemy ESP settings with section tabs example (Player Tab / Enemy Tab)
	espSections.EnemySettings:Toggle({
		Name = "Enabled",
		Default = true,
		Callback = function(v)
			print("Enemy ESP Enabled:", v)
		end,
		Config = "EnemyESP_Enabled",
		Tab = "Enemy Tab",
	})

	espSections.EnemySettings:Colorpicker({
		Name = "Box Color",
		Default = Color3.fromRGB(255, 80, 80),
		Alpha = 1,
		Callback = function(c)
			print("Enemy ESP Box Color:", c)
		end,
		Config = "EnemyESP_BoxColor",
		Tab = "Enemy Tab",
	})

	espSections.EnemySettings:Toggle({
		Name = "Show Health Bar",
		Default = true,
		Callback = function(v)
			print("Enemy ESP HealthBar:", v)
		end,
		Config = "EnemyESP_HealthBar",
		Tab = "Enemy Tab",
	})

	espSections.EnemySettings:Slider({
		Name = "Thickness",
		Minimum = 1,
		Maximum = 5,
		Default = 2,
		Precision = 0,
		Step = 1,
		Callback = function(v)
			print("Enemy ESP Thickness:", v)
		end,
		Config = "EnemyESP_Thickness",
		Tab = "Enemy Tab",
	})

	-- Example controls on Player Tab within same section
	espSections.EnemySettings:Toggle({
		Name = "Show Name",
		Default = true,
		Callback = function(v)
			print("Enemy ESP Show Name:", v)
		end,
		Config = "EnemyESP_ShowName",
		Tab = "Player Tab",
	})

	local test = espSections.EnemySettings:Dropdown({
		Name = "Name Style",
		Options = {"Username", "DisplayName", "Both"},
		Default = "Username",
		Callback = function(v)
			print("Enemy ESP Name Style:", v)
		end,
		Config = "EnemyESP_NameStyle",
		Tab = "Player Tab",
	})

	task.wait(0.5)

	-- Teammate ESP settings
	espSections.TeamSettings:Toggle({
		Name = "Enabled",
		Default = true,
		Callback = function(v)
			print("Teammate ESP Enabled:", v)
		end,
		Config = "TeamESP_Enabled",
	})

	espSections.TeamSettings:Colorpicker({
		Name = "Box Color",
		Default = Color3.fromRGB(80, 200, 120),
		Alpha = 1,
		Callback = function(c)
			print("Team ESP Box Color:", c)
		end,
		Config = "TeamESP_BoxColor",
	})

	espSections.TeamSettings:Toggle({
		Name = "Show Health Bar",
		Default = false,
		Callback = function(v)
			print("Team ESP HealthBar:", v)
		end,
		Config = "TeamESP_HealthBar",
	})

	espSections.TeamSettings:Slider({
		Name = "Thickness",
		Minimum = 1,
		Maximum = 5,
		Default = 2,
		Precision = 0,
		Step = 1,
		Callback = function(v)
			print("Team ESP Thickness:", v)
		end,
		Config = "TeamESP_Thickness",
	})

	-- Build simple dummy models for ESP previews (enemy & teammate)
	local function buildCharacterPreview(color, healthBar)
		local model = Instance.new("Model")
		model.Name = "PreviewCharacter"

		local torso = Instance.new("Part")
		torso.Name = "Torso"
		torso.Size = Vector3.new(2, 3, 1)
		torso.Color = Color3.fromRGB(200, 200, 200)
		torso.Anchored = true
		torso.CanCollide = false
		torso.Parent = model

		local head = Instance.new("Part")
		head.Name = "Head"
		head.Size = Vector3.new(1.5, 1.5, 1.5)
		head.Position = Vector3.new(0, torso.Size.Y / 2 + head.Size.Y / 2, 0)
		head.Anchored = true
		head.CanCollide = false
		head.Color = Color3.fromRGB(230, 230, 230)
		head.Parent = model

		model.PrimaryPart = torso

		-- Fake 2D box and health bar using BillboardGuis so we can show "ESP" style
		local boxGui = Instance.new("BillboardGui")
		boxGui.Name = "BoxESP"
		boxGui.Size = UDim2.new(4, 0, 6, 0)
		boxGui.Adornee = torso
		boxGui.AlwaysOnTop = true
		boxGui.Parent = model

		local boxFrame = Instance.new("Frame")
		boxFrame.Size = UDim2.new(1, 0, 1, 0)
		boxFrame.BackgroundTransparency = 1
		boxFrame.BorderSizePixel = 0
		boxFrame.Parent = boxGui

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 2
		stroke.Color = color
		stroke.Parent = boxFrame

		if healthBar then
			local hpGui = Instance.new("BillboardGui")
			hpGui.Name = "HealthBarESP"
			hpGui.Size = UDim2.new(0.2, 0, 6, 0)
			hpGui.StudsOffsetWorldSpace = Vector3.new(-1.3, 0, 0)
			hpGui.Adornee = torso
			hpGui.AlwaysOnTop = true
			hpGui.Parent = model

			local bg = Instance.new("Frame")
			bg.Size = UDim2.new(1, 0, 1, 0)
			bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			bg.BorderSizePixel = 0
			bg.Parent = hpGui

			local fill = Instance.new("Frame")
			fill.Size = UDim2.new(1, 0, 0.7, 0)
			fill.AnchorPoint = Vector2.new(0, 1)
			fill.Position = UDim2.new(0, 0, 1, -1)
			fill.BackgroundColor3 = Color3.fromRGB(50, 220, 80)
			fill.BorderSizePixel = 0
			fill.Parent = bg
		end

		return model
	end

	-- Enemy preview viewport
	local enemyPreviewModel = buildCharacterPreview(Color3.fromRGB(255, 80, 80), true)
	espSections.EnemyPreview:ViewportFrame({
		Name = "Enemy ESP Preview",
		Height = 220,
		Model = enemyPreviewModel,
		FOV = 35,
		Distance = 10,
		Ambient = Color3.fromRGB(90, 90, 110),
	})

	-- Teammate preview viewport
	local teamPreviewModel = buildCharacterPreview(Color3.fromRGB(80, 200, 120), true)
	espSections.TeamPreview:ViewportFrame({
		Name = "Teammate ESP Preview",
		Height = 220,
		Model = teamPreviewModel,
		FOV = 35,
		Distance = 10,
		Ambient = Color3.fromRGB(90, 90, 110),
	})

	------------------------------------------------------------------
	-- Finalize
	------------------------------------------------------------------

	-- Select default tab after everything is created
	tabs.Dashboard:Select()

	-- Use the simple AutoLoad helper on the last-created window
	local ok, err = RivalsUI:AutoLoad()
	if not ok and err then
		window:Notify({
			Title = "AutoLoad",
			Description = err,
			Lifetime = 3,
		})
	end

	return window
end

return RivalsUI
