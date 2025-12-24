local a = {}
local b = game:GetService("UserInputService")
local c = game:GetService("TweenService")
local d = game:GetService("RunService")
local e = game:GetService("HttpService")
local f = game:GetService("Players")
local g =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"))(

)
local h = Instance.new("ScreenGui")
h.Name = "CSGOStyleUI"
h.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
h.ResetOnSpawn = false
h.Parent = game.CoreGui
local i = Instance.new("Frame")
i.Name = "NotificationHolder"
i.Size = UDim2.new(0, 300, 1, -20)
i.Position = UDim2.new(1, -310, 0, 10)
i.BackgroundTransparency = 1
i.Parent = h
local j = Instance.new("UIListLayout")
j.SortOrder = Enum.SortOrder.LayoutOrder
j.Padding = UDim.new(0, 8)
j.VerticalAlignment = Enum.VerticalAlignment.Top
j.Parent = i
local k = {Flags = {}, Elements = {}, ConfigFolder = "Isreal", CurrentConfig = "default"}
function k:SetValue(l, m)
    if l and l ~= "" then
        self.Flags[l] = m
    end
end
function k:GetValue(l)
    return self.Flags[l]
end
function k:RegisterElement(l, n)
    if l and l ~= "" then
        self.Elements[l] = n
    end
end
function k:SaveConfig(o)
    o = o or self.CurrentConfig
    local p = {}
    for l, m in pairs(self.Flags) do
        if typeof(m) == "Color3" then
            p[l] = {Type = "Color3", R = math.floor(m.R * 255), G = math.floor(m.G * 255), B = math.floor(m.B * 255)}
        elseif typeof(m) == "EnumItem" then
            p[l] = {Type = "KeyCode", Name = m.Name}
        else
            p[l] = {Type = typeof(m), Value = m}
        end
    end
    local q = e:JSONEncode(p)
    if writefile then
        local r = self.ConfigFolder
        local s = r .. "/" .. o .. ".json"
        if not isfolder(r) then
            makefolder(r)
        end
        writefile(s, q)
        return true
    else
        warn("File system not supported")
        return false
    end
end
function k:LoadConfig(o)
    o = o or self.CurrentConfig
    if readfile then
        local r = self.ConfigFolder
        local s = r .. "/" .. o .. ".json"
        if isfile(s) then
            local t, q =
                pcall(
                function()
                    return readfile(s)
                end
            )
            if t and q then
                local u, p =
                    pcall(
                    function()
                        return e:JSONDecode(q)
                    end
                )
                if u and p then
                    for l, v in pairs(p) do
                        local m
                        if v.Type == "Color3" then
                            m = Color3.fromRGB(v.R, v.G, v.B)
                        elseif v.Type == "KeyCode" then
                            m = Enum.KeyCode[v.Name]
                        else
                            m = v.Value
                        end
                        self.Flags[l] = m
                        local n = self.Elements[l]
                        if n and n.Set then
                            n:Set(m)
                        end
                    end
                    return true
                end
            end
        end
    end
    return false
end
function k:GetConfigList()
    local w = {}
    if isfolder and listfiles then
        local r = self.ConfigFolder
        if isfolder(r) then
            local x = listfiles(r)
            for y, z in pairs(x) do
                local A = z:match("([^/\\]+)%.json$")
                if A then
                    table.insert(w, A)
                end
            end
        end
    end
    if #w == 0 then
        w = {}
    end
    return w
end
function k:DeleteConfig(o)
    if delfile and isfile then
        local s = self.ConfigFolder .. "/" .. o .. ".json"
        if isfile(s) then
            delfile(s)
            return true
        end
    end
    return false
end
a.ConfigSystem = k
local function B(C, D, E)
    local F = TweenInfo.new(E or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local G = c:Create(C, F, D)
    G:Play()
    return G
end
local function H(I, J)
    local K = g[I]
    if not K then
        return nil
    end
    local L = K
    local M = Instance.new("ImageLabel")
    M.Size = UDim2.new(0, 16, 0, 16)
    M.BackgroundTransparency = 1
    M.Image = L
    M.Parent = J
    return M
end
local function N(J, O)
    local P = Instance.new("UICorner")
    P.CornerRadius = UDim.new(0, O or 6)
    P.Parent = J
    return P
end
local function Q(J, R, S)
    local T = Instance.new("UIStroke")
    T.Color = R or Color3.fromRGB(60, 60, 63)
    T.Thickness = S or 1
    T.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    T.Parent = J
    return T
end
local function U(J, V, W, X, Y)
    local Z = Instance.new("UIPadding")
    Z.PaddingLeft = UDim.new(0, V or 0)
    Z.PaddingRight = UDim.new(0, W or 0)
    Z.PaddingTop = UDim.new(0, X or 0)
    Z.PaddingBottom = UDim.new(0, Y or 0)
    Z.Parent = J
    return Z
end
local function _(a0, a1)
    local a2 = false
    local a3, a4, a5
    a1.InputBegan:Connect(
        function(a6)
            if a6.UserInputType == Enum.UserInputType.MouseButton1 then
                a2 = true
                a4 = a6.Position
                a5 = a0.Position
                a6.Changed:Connect(
                    function()
                        if a6.UserInputState == Enum.UserInputState.End then
                            a2 = false
                        end
                    end
                )
            end
        end
    )
    b.InputChanged:Connect(
        function(a6)
            if a6.UserInputType == Enum.UserInputType.MouseMovement then
                a3 = a6
            end
        end
    )
    d.RenderStepped:Connect(
        function()
            if a2 and a3 then
                local a7 = a3.Position - a4
                a0.Position = UDim2.new(a5.X.Scale, a5.X.Offset + a7.X, a5.Y.Scale, a5.Y.Offset + a7.Y)
            end
        end
    )
end
local b = game:GetService("UserInputService")
local d = game:GetService("RunService")
local function a8(a0, a1, a9)
    local aa = false
    local ab, a4, ac
    a1.InputBegan:Connect(
        function(a6)
            if a6.UserInputType == Enum.UserInputType.MouseButton1 and not a9.Minimized then
                aa = true
                a4 = a6.Position
                ac = a0.Size
                a6.Changed:Connect(
                    function()
                        if a6.UserInputState == Enum.UserInputState.End then
                            aa = false
                        end
                    end
                )
            end
        end
    )
    b.InputChanged:Connect(
        function(a6)
            if a6.UserInputType == Enum.UserInputType.MouseMovement then
                ab = a6
            end
        end
    )
    d.RenderStepped:Connect(
        function()
            if aa and ab and not a9.Minimized then
                local a7 = ab.Position - a4
                local ad = math.max(500, ac.X.Offset + a7.X)
                local ae = math.max(350, ac.Y.Offset + a7.Y)
                a0.Size = UDim2.new(0, ad, 0, ae)
            end
        end
    )
end
local af = {
    Background = Color3.fromRGB(35, 35, 38),
    BackgroundDark = Color3.fromRGB(28, 28, 30),
    BackgroundDarker = Color3.fromRGB(22, 22, 24),
    Secondary = Color3.fromRGB(30, 30, 32),
    Tertiary = Color3.fromRGB(40, 40, 43),
    Border = Color3.fromRGB(60, 60, 63),
    BorderLight = Color3.fromRGB(70, 70, 73),
    Accent = Color3.fromRGB(173, 173, 173),
    AccentHover = Color3.fromRGB(203, 203, 203),
    AccentDark = Color3.fromRGB(88, 88, 88),
    Text = Color3.fromRGB(245, 245, 250),
    TextDark = Color3.fromRGB(180, 180, 185),
    TextMuted = Color3.fromRGB(140, 140, 145),
    Toggle = Color3.fromRGB(106, 106, 106),
    ToggleOff = Color3.fromRGB(50, 50, 53),
    Header = Color3.fromRGB(25, 25, 27),
    ElementBg = Color3.fromRGB(32, 32, 35),
    ElementHover = Color3.fromRGB(42, 42, 45),
    Success = Color3.fromRGB(70, 200, 85),
    Warning = Color3.fromRGB(255, 176, 45),
    Danger = Color3.fromRGB(240, 63, 79),
    Divider = Color3.fromRGB(55, 55, 60),
    Unsupported = Color3.fromRGB(80, 80, 85),
    UnsupportedText = Color3.fromRGB(120, 120, 125)
}
local ag = {
    {Name = "Roboto", Font = Enum.Font.Roboto},
    {Name = "Roboto Mono", Font = Enum.Font.RobotoMono},
    {Name = "Ubuntu", Font = Enum.Font.Ubuntu},
    {Name = "Gotham", Font = Enum.Font.Gotham},
    {Name = "Code", Font = Enum.Font.Code}
}
local ah = Enum.Font.RobotoMono
local ai = 14
local aj = 14
local function applyUnsupported(frame, mainButton)
    local overlay = Instance.new("Frame")
    overlay.Name = "UnsupportedOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.4
    overlay.ZIndex = 999
    overlay.Parent = frame
    N(overlay, 6)
    local label = Instance.new("TextLabel")
    label.Name = "UnsupportedLabel"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "UNSUPPORTED FOR " .. getexecutorname():upper()
    label.TextColor3 = af.UnsupportedText
    label.Font = ah
    label.TextSize = ai
    label.ZIndex = 1000
    label.Parent = overlay
    if mainButton then
        mainButton.Active = false
    end
    for _, child in pairs(frame:GetDescendants()) do
        if child:IsA("TextButton") or child:IsA("ImageButton") then
            child.Active = false
        end
    end
end
function a:Notify(ak)
    ak = ak or {}
    local al = ak.Title or "Notification"
    local am = ak.Description or ""
    local E = ak.Duration or 3
    local an =
        ak.Type == "success" and af.Success or ak.Type == "warning" and af.Warning or ak.Type == "error" and af.Danger or
        af.Accent
    local ao = Instance.new("Frame")
    ao.Name = "Notification"
    ao.Size = UDim2.new(1, 0, 0, 0)
    ao.Position = UDim2.new(1, 0, 0, 0)
    ao.BackgroundColor3 = af.BackgroundDark
    ao.BackgroundTransparency = 1
    ao.BorderSizePixel = 0
    ao.ClipsDescendants = true
    ao.Parent = i
    N(ao, 6)
    local ap = Q(ao, an, 2)
    local aq = Instance.new("Frame")
    aq.Name = "Accent"
    aq.Size = UDim2.new(0, 4, 1, 0)
    aq.BackgroundColor3 = an
    aq.BackgroundTransparency = 1
    aq.BorderSizePixel = 0
    aq.Parent = ao
    local ar = Instance.new("UICorner")
    ar.CornerRadius = UDim.new(0, 6)
    ar.Parent = aq
    local as = Instance.new("Frame")
    as.Name = "Content"
    as.Size = UDim2.new(1, -14, 1, -16)
    as.Position = UDim2.new(0, 14, 0, 8)
    as.BackgroundTransparency = 1
    as.Parent = ao
    local at = Instance.new("UIListLayout")
    at.SortOrder = Enum.SortOrder.LayoutOrder
    at.Padding = UDim.new(0, 4)
    at.Parent = as
    local au = Instance.new("TextLabel")
    au.Name = "Title"
    au.Size = UDim2.new(1, -10, 0, 0)
    au.AutomaticSize = Enum.AutomaticSize.Y
    au.BackgroundTransparency = 1
    au.Text = al
    au.TextColor3 = an
    au.TextTransparency = 1
    au.Font = ah
    au.TextSize = ai + 1
    au.TextXAlignment = Enum.TextXAlignment.Left
    au.TextWrapped = true
    au.LayoutOrder = 1
    au.Parent = as
    local av = Instance.new("TextLabel")
    av.Name = "Description"
    av.Size = UDim2.new(1, -10, 0, 0)
    av.AutomaticSize = Enum.AutomaticSize.Y
    av.BackgroundTransparency = 1
    av.Text = am
    av.TextColor3 = af.TextDark
    av.TextTransparency = 1
    av.Font = ah
    av.TextSize = ai
    av.TextXAlignment = Enum.TextXAlignment.Left
    av.TextWrapped = true
    av.LayoutOrder = 2
    av.Parent = as
    local aw = Instance.new("Frame")
    aw.Name = "ProgressBar"
    aw.Size = UDim2.new(1, 0, 0, 3)
    aw.Position = UDim2.new(0, 0, 1, -3)
    aw.BackgroundColor3 = af.BackgroundDarker
    aw.BorderSizePixel = 0
    aw.Parent = ao
    local ax = Instance.new("Frame")
    ax.Name = "Fill"
    ax.Size = UDim2.new(1, 0, 1, 0)
    ax.BackgroundColor3 = an
    ax.BorderSizePixel = 0
    ax.Parent = aw
    N(ax, 2)
    task.wait()
    local ay = at.AbsoluteContentSize.Y + 24
    B(ao, {Size = UDim2.new(1, 0, 0, ay), BackgroundTransparency = 0}, 0.3)
    B(ao, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
    B(aq, {BackgroundTransparency = 0}, 0.3)
    B(au, {TextTransparency = 0}, 0.3)
    B(av, {TextTransparency = 0}, 0.3)
    task.delay(
        0.3,
        function()
            B(ax, {Size = UDim2.new(0, 0, 1, 0)}, E)
        end
    )
    task.delay(
        E + 0.3,
        function()
            B(ao, {Position = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
            B(aq, {BackgroundTransparency = 1}, 0.3)
            B(au, {TextTransparency = 1}, 0.3)
            B(av, {TextTransparency = 1}, 0.3)
            task.wait(0.3)
            ao:Destroy()
        end
    )
end
function a:CreateWindow(ak)
    ak = ak or {}

    local az = ak.Name or "CHEAT MENU"
    local aA = ak.Icon or "layout-dashboard"
    local aB = ak.ConfigFolder or "CipexLibrary"
    if not isfolder(aB) then
        makefolder(aB)
    end
    k.ConfigFolder = aB
    local aC = {}
    aC.Tabs = {}
    aC.CurrentTab = nil
    aC.Minimized = false
    aC.Font = ah
    aC.FontSize = ai
    aC.Accent = af.Accent
    aC.AccentElements = {}
    aC.Flags = k.Flags
    aC.TabButtons = {}
    aC.ScreenGui = h
    local aD = Instance.new("Frame")
    aD.Name = "MainFrame"
    aD.Size = UDim2.new(0.5, 0, 0.6, 0)
    aD.Position = UDim2.new(0.5, -350, 0.5, -210)
    aD.AnchorPoint = Vector2.new(0, 0)
    aD.BackgroundColor3 = af.Background
    aD.BorderSizePixel = 0
    aD.Parent = h
    local aE = Instance.new("UISizeConstraint")
    aE.Parent = aD
    aE.MaxSize = Vector2.new(700, 420)
    aC.MainFrame = aD
    N(aD, 8)
    Q(aD, af.Border, 1)
    local aF = Instance.new("Frame")
    aF.Name = "InnerContainer"
    aF.Size = UDim2.new(1, 0, 1, 0)
    aF.BackgroundTransparency = 1
    aF.ClipsDescendants = true
    aF.Parent = aD
    N(aF, 8)
    local aG = Instance.new("Frame")
    aG.Name = "Header"
    aG.Size = UDim2.new(1, 0, 0, 35)
    aG.BackgroundColor3 = af.Header
    aG.BorderSizePixel = 0
    aG.Parent = aF
    local aH = Instance.new("UICorner")
    aH.CornerRadius = UDim.new(0, 8)
    aH.Parent = aG
    local aI = Instance.new("Frame")
    aI.Name = "BottomCover"
    aI.Size = UDim2.new(1, 0, 0, 10)
    aI.Position = UDim2.new(0, 0, 1, -10)
    aI.BackgroundColor3 = af.Header
    aI.BorderSizePixel = 0
    aI.Parent = aG
    local aJ = Instance.new("Frame")
    aJ.Name = "Border"
    aJ.Size = UDim2.new(1, 0, 0, 1)
    aJ.Position = UDim2.new(0, 0, 1, 0)
    aJ.BackgroundColor3 = af.Border
    aJ.BorderSizePixel = 0
    aJ.Parent = aG
    local aK = H(aA, aG)
    if aK then
        aK.Position = UDim2.new(0, 12, 0.5, -8)
        aK.ImageColor3 = af.Accent
        table.insert(aC.AccentElements, {Type = "Icon", Element = aK})
    end
    local aL = Instance.new("TextLabel")
    aL.Name = "Title"
    aL.Size = UDim2.new(0, 300, 1, 0)
    aL.Position = UDim2.new(0, aK and 34 or 12, 0, 0)
    aL.BackgroundTransparency = 1
    aL.Text = az
    aL.TextColor3 = af.Text
    aL.Font = ah
    aL.TextSize = aj
    aL.TextXAlignment = Enum.TextXAlignment.Left
    aL.Parent = aG
    local aM = Instance.new("Frame")
    aM.Name = "Controls"
    aM.Size = UDim2.new(0, 65, 0, 28)
    aM.Position = UDim2.new(1, -70, 0.5, -14)
    aM.BackgroundTransparency = 1
    aM.Parent = aG
    local aN = Instance.new("UIListLayout")
    aN.FillDirection = Enum.FillDirection.Horizontal
    aN.HorizontalAlignment = Enum.HorizontalAlignment.Right
    aN.VerticalAlignment = Enum.VerticalAlignment.Center
    aN.Padding = UDim.new(0, 5)
    aN.SortOrder = Enum.SortOrder.LayoutOrder
    aN.Parent = aM
    local aO = Instance.new("TextButton")
    aO.Name = "Close"
    aO.Size = UDim2.new(0, 28, 0, 28)
    aO.BackgroundColor3 = af.Secondary
    aO.BorderSizePixel = 0
    aO.Text = ""
    aO.LayoutOrder = 10
    aO.AutoButtonColor = false
    aO.Parent = aM
    N(aO, 6)
    Q(aO, af.Border, 1)
    local aP = H("x", aO)
    if aP then
        aP.Size = UDim2.new(0, 14, 0, 14)
        aP.Position = UDim2.new(0.5, -7, 0.5, -7)
        aP.ImageColor3 = af.TextDark
    end
    aO.MouseEnter:Connect(
        function()
            B(aO, {BackgroundColor3 = af.Danger}, 0.15)
            if aP then
                aP.ImageColor3 = af.Text
            end
        end
    )
    aO.MouseLeave:Connect(
        function()
            B(aO, {BackgroundColor3 = af.Secondary}, 0.15)
            if aP then
                aP.ImageColor3 = af.TextDark
            end
        end
    )
    aO.MouseButton1Click:Connect(
        function()
            B(aD, {Size = UDim2.new(0, aD.Size.X.Offset, 0, 0)}, 0.3)
            task.wait(0.3)
            h:Destroy()
        end
    )
    local aQ = Instance.new("TextButton")
    aQ.Name = "Minimize"
    aQ.Size = UDim2.new(0, 28, 0, 28)
    aQ.BackgroundColor3 = af.Secondary
    aQ.BorderSizePixel = 0
    aQ.Text = ""
    aQ.AutoButtonColor = false
    aQ.Parent = aM
    N(aQ, 6)
    Q(aQ, af.Border, 1)
    local aR = H("minus", aQ)
    if aR then
        aR.Size = UDim2.new(0, 14, 0, 14)
        aR.Position = UDim2.new(0.5, -7, 0.5, -7)
        aR.ImageColor3 = af.TextDark
    end
    aQ.MouseEnter:Connect(
        function()
            B(aQ, {BackgroundColor3 = af.ElementHover}, 0.15)
            if aR then
                aR.ImageColor3 = af.Text
            end
        end
    )
    aQ.MouseLeave:Connect(
        function()
            B(aQ, {BackgroundColor3 = af.Secondary}, 0.15)
            if aR then
                aR.ImageColor3 = af.TextDark
            end
        end
    )
    local aS = Instance.new("TextButton")
    aS.Name = "Resize"
    aS.Size = UDim2.new(0, 20, 0, 20)
    aS.Position = UDim2.new(1, -20, 1, -20)
    aS.BackgroundTransparency = 1
    aS.Text = ""
    aS.Parent = aD
    local aT = H("move-diagonal-2", aS)
    if aT then
        aT.Size = UDim2.new(0, 12, 0, 12)
        aT.Position = UDim2.new(0.5, -6, 0.5, -6)
        aT.ImageColor3 = af.TextMuted
    end
    aS.MouseEnter:Connect(
        function()
            if aT and not aC.Minimized then
                aT.ImageColor3 = af.Accent
            end
        end
    )
    aS.MouseLeave:Connect(
        function()
            if aT then
                aT.ImageColor3 = af.TextMuted
            end
        end
    )
    local aU = aD.Size.Y.Offset
    local aV = aD.Size
    aQ.MouseButton1Click:Connect(
        function()
            aC.Minimized = not aC.Minimized
            if aC.Minimized then
                aV = aD.Size
                B(aD, {Size = UDim2.new(aD.Size.X.Scale, aD.Size.X.Offset, 0, 35)}, 0.3)
                aS.Visible = false
                if aR then
                    aR:Destroy()
                end
                aR = H("plus", aQ)
                if aR then
                    aR.Size = UDim2.new(0, 14, 0, 14)
                    aR.Position = UDim2.new(0.5, -7, 0.5, -7)
                    aR.ImageColor3 = af.Text
                end
            else
                B(aD, {Size = aV}, 0.3)
                aS.Visible = true
                if aR then
                    aR:Destroy()
                end
                aR = H("minus", aQ)
                if aR then
                    aR.Size = UDim2.new(0, 14, 0, 14)
                    aR.Position = UDim2.new(0.5, -7, 0.5, -7)
                    aR.ImageColor3 = af.Text
                end
            end
        end
    )
    local aW = Instance.new("Frame")
    aW.Name = "TabContainer"
    aW.Size = UDim2.new(1, 0, 0, 40)
    aW.Position = UDim2.new(0, 0, 0, 35)
    aW.BackgroundColor3 = af.BackgroundDark
    aW.BorderSizePixel = 0
    aW.Parent = aF
    local aX = Instance.new("Frame")
    aX.Name = "Border"
    aX.Size = UDim2.new(1, 0, 0, 1)
    aX.Position = UDim2.new(0, 0, 1, 0)
    aX.BackgroundColor3 = af.Border
    aX.BorderSizePixel = 0
    aX.Parent = aW
    local aY = Instance.new("ScrollingFrame")
    aY.Name = "TabList"
    aY.Size = UDim2.new(1, -20, 1, -10)
    aY.Position = UDim2.new(0, 10, 0, 5)
    aY.BackgroundTransparency = 1
    aY.BorderSizePixel = 0
    aY.ScrollBarThickness = 0
    aY.CanvasSize = UDim2.new(0, 0, 0, 0)
    aY.AutomaticCanvasSize = Enum.AutomaticSize.X
    aY.ScrollingDirection = Enum.ScrollingDirection.X
    aY.Parent = aW
    local aZ = Instance.new("UIListLayout")
    aZ.FillDirection = Enum.FillDirection.Horizontal
    aZ.SortOrder = Enum.SortOrder.LayoutOrder
    aZ.VerticalAlignment = Enum.VerticalAlignment.Center
    aZ.Padding = UDim.new(0, 6)
    aZ.Parent = aY
    local a_ = Instance.new("Frame")
    a_.Name = "ContentContainer"
    a_.Size = UDim2.new(1, 0, 1, -75)
    a_.Position = UDim2.new(0, 0, 0, 75)
    a_.BackgroundTransparency = 1
    a_.Parent = aF
    _(aD, aG)
    a8(aD, aS, aC)
    function aC:Notify(ak)
        a:Notify(ak)
    end
    function aC:UpdateFont(b0)
        aC.Font = b0
        for y, b1 in pairs(aC.Tabs) do
            for y, n in pairs(b1.Content:GetDescendants()) do
                if n:IsA("TextLabel") or n:IsA("TextButton") or n:IsA("TextBox") then
                    n.Font = b0
                end
            end
        end
    end
    function aC:UpdateFontSize(b2)
        aC.FontSize = b2
        for y, b1 in pairs(aC.Tabs) do
            for y, n in pairs(b1.Content:GetDescendants()) do
                if n:IsA("TextLabel") or n:IsA("TextButton") or n:IsA("TextBox") then
                    if n.Name == "SectionLabel" then
                        n.TextSize = b2 + 2
                    elseif n.Parent.Name ~= "TabList" then
                        n.TextSize = b2
                    end
                end
            end
        end
    end
    function aC:UpdateAccent(R)
        aC.Accent = R
        af.Accent = R
        af.AccentHover = Color3.new(math.min(1, R.R + 0.1), math.min(1, R.G + 0.1), math.min(1, R.B + 0.1))
        af.AccentDark = Color3.new(math.max(0, R.R - 0.1), math.max(0, R.G - 0.1), math.max(0, R.B - 0.1))
        af.Toggle = R
        if aC.CurrentTab then
            aC.CurrentTab.Button.BackgroundColor3 = R
            aC.CurrentTab.Stroke.Color = af.AccentHover
        end
        for y, v in pairs(aC.AccentElements) do
            if v.Element and v.Element.Parent then
                if v.Type == "Icon" then
                    v.Element.ImageColor3 = R
                elseif v.Type == "Background" then
                    v.Element.BackgroundColor3 = R
                elseif v.Type == "Stroke" then
                    v.Element.Color = af.AccentHover
                elseif v.Type == "Text" then
                    v.Element.TextColor3 = R
                elseif v.Type == "ScrollBar" then
                    v.Element.ScrollBarImageColor3 = R
                elseif v.Type == "CheckboxBox" then
                    if v.GetValue and v.GetValue() then
                        v.Element.BackgroundColor3 = R
                        if v.Stroke then
                            v.Stroke.Color = R
                        end
                    end
                elseif v.Type == "TabStroke" then
                    if v.IsSelected and v.IsSelected() then
                        v.Element.Color = af.AccentHover
                    end
                end
            end
        end
    end
    function aC:SaveConfig(o)
        return k:SaveConfig(o)
    end
    function aC:LoadConfig(o)
        return k:LoadConfig(o)
    end
    function aC:GetConfigList()
        return k:GetConfigList()
    end
    function aC:DeleteConfig(o)
        return k:DeleteConfig(o)
    end
    function aC:SetConfigSlot(o)
        k.CurrentConfig = o
    end
    function aC:CreateTab(b3, I)
        local b4 = {}
        b4.Name = b3
        local b5 = Instance.new("UIPadding")
        b5.PaddingLeft = UDim.new(0, 2.5)
        b5.PaddingRight = UDim.new(0, 0)
        b5.Parent = aY
        local b6 = Instance.new("TextButton")
        b6.Name = b3
        b6.Size = UDim2.new(0, 0, 0, 28)
        b6.AutomaticSize = Enum.AutomaticSize.X
        b6.BackgroundColor3 = af.ElementBg
        b6.BorderSizePixel = 0
        b6.Text = ""
        b6.AutoButtonColor = false
        b6.Parent = aY
        N(b6, 6)
        local b7 = Q(b6, af.Border, 1)
        local b8 = Instance.new("UIPadding")
        b8.PaddingLeft = UDim.new(0, 10)
        b8.PaddingRight = UDim.new(0, 12)
        b8.Parent = b6
        local b9 = Instance.new("UIListLayout")
        b9.FillDirection = Enum.FillDirection.Horizontal
        b9.VerticalAlignment = Enum.VerticalAlignment.Center
        b9.Padding = UDim.new(0, 6)
        b9.Parent = b6
        local ba
        if I then
            ba = H(I, b6)
            if ba then
                ba.Size = UDim2.new(0, 14, 0, 14)
                ba.ImageColor3 = af.TextMuted
                ba.LayoutOrder = 1
                b4.Icon = ba
            end
        end
        local bb = Instance.new("TextLabel")
        bb.Name = "Label"
        bb.Size = UDim2.new(0, 0, 0, 28)
        bb.AutomaticSize = Enum.AutomaticSize.X
        bb.BackgroundTransparency = 1
        bb.Text = b3:upper()
        bb.TextColor3 = af.TextMuted
        bb.Font = aC.Font
        bb.TextSize = aj
        bb.LayoutOrder = 2
        bb.Parent = b6
        local bc = Instance.new("ScrollingFrame")
        bc.Name = b3 .. "Content"
        bc.Size = UDim2.new(1, 0, 1, 0)
        bc.BackgroundTransparency = 1
        bc.BorderSizePixel = 0
        bc.ScrollBarThickness = 4
        bc.ScrollBarImageColor3 = af.Accent
        bc.CanvasSize = UDim2.new(0, 0, 0, 0)
        bc.Visible = false
        bc.Parent = a_
        table.insert(aC.AccentElements, {Type = "ScrollBar", Element = bc})
        local bd = Instance.new("UIListLayout")
        bd.SortOrder = Enum.SortOrder.LayoutOrder
        bd.Padding = UDim.new(0, 8)
        bd.Parent = bc
        U(bc, 10, 10, 10, 10)
        bd:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
            function()
                bc.CanvasSize = UDim2.new(0, 0, 0, bd.AbsoluteContentSize.Y + 20)
            end
        )
        b6.MouseEnter:Connect(
            function()
                if aC.CurrentTab ~= b4 then
                    B(b6, {BackgroundColor3 = af.ElementHover}, 0.15)
                end
            end
        )
        b6.MouseLeave:Connect(
            function()
                if aC.CurrentTab ~= b4 then
                    B(b6, {BackgroundColor3 = af.ElementBg}, 0.15)
                end
            end
        )
        b6.MouseButton1Click:Connect(
            function()
                for y, b1 in pairs(aC.Tabs) do
                    b1.Button.BackgroundColor3 = af.ElementBg
                    b1.Label.TextColor3 = af.TextMuted
                    b1.Stroke.Color = af.Border
                    b1.Content.Visible = false
                    if b1.Icon then
                        b1.Icon.ImageColor3 = af.TextMuted
                    end
                end
                b6.BackgroundColor3 = af.Accent
                bb.TextColor3 = af.Text
                b7.Color = af.AccentHover
                bc.Visible = true
                aC.CurrentTab = b4
                if b4.Icon then
                    b4.Icon.ImageColor3 = af.Text
                end
            end
        )
        b4.Button = b6
        b4.Label = bb
        b4.Stroke = b7
        b4.Content = bc
        table.insert(
            aC.AccentElements,
            {Type = "TabStroke", Element = b7, IsSelected = function()
                    return aC.CurrentTab == b4
                end}
        )
        if #aC.Tabs == 0 then
            b6.BackgroundColor3 = af.Accent
            bb.TextColor3 = af.Text
            b7.Color = af.AccentHover
            bc.Visible = true
            aC.CurrentTab = b4
            if b4.Icon then
                b4.Icon.ImageColor3 = af.Text
            end
        end
        table.insert(aC.Tabs, b4)
        function b4:AddDivider()
            local be = Instance.new("Frame")
            be.Name = "Divider"
            be.Size = UDim2.new(1, 0, 0, 20)
            be.BackgroundTransparency = 1
            be.Parent = bc
            local bf = Instance.new("Frame")
            bf.Name = "Line"
            bf.Size = UDim2.new(1, -20, 0, 1)
            bf.Position = UDim2.new(0, 10, 0.5, 0)
            bf.BackgroundColor3 = af.Divider
            bf.BorderSizePixel = 0
            bf.Parent = be
            local bg = Instance.new("UIGradient")
            bg.Color =
                ColorSequence.new(
                {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                }
            )
            bg.Transparency =
                NumberSequence.new(
                {
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.2, 0),
                    NumberSequenceKeypoint.new(0.8, 0),
                    NumberSequenceKeypoint.new(1, 1)
                }
            )
            bg.Parent = bf
            return be
        end
        function b4:AddLabeledDivider(bh)
            local be = Instance.new("Frame")
            be.Name = "LabeledDivider"
            be.Size = UDim2.new(1, 0, 0, 24)
            be.BackgroundTransparency = 1
            be.Parent = bc
            local bi = Instance.new("Frame")
            bi.Name = "LeftLine"
            bi.Size = UDim2.new(0.5, -50, 0, 1)
            bi.Position = UDim2.new(0, 10, 0.5, 0)
            bi.BackgroundColor3 = af.Divider
            bi.BorderSizePixel = 0
            bi.Parent = be
            local bj = Instance.new("UIGradient")
            bj.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
            bj.Parent = bi
            local bk = Instance.new("Frame")
            bk.Name = "RightLine"
            bk.Size = UDim2.new(0.5, -50, 0, 1)
            bk.Position = UDim2.new(0.5, 40, 0.5, 0)
            bk.BackgroundColor3 = af.Divider
            bk.BorderSizePixel = 0
            bk.Parent = be
            local bl = Instance.new("UIGradient")
            bl.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
            bl.Parent = bk
            local bm = Instance.new("TextLabel")
            bm.Name = "Label"
            bm.Size = UDim2.new(0, 80, 1, 0)
            bm.Position = UDim2.new(0.5, -40, 0, 0)
            bm.BackgroundTransparency = 1
            bm.Text = bh or "DIVIDER"
            bm.TextColor3 = af.TextMuted
            bm.Font = aC.Font
            bm.TextSize = aC.FontSize - 1
            bm.Parent = be
            return be
        end
        function b4:AddSpacer(bn)
            local bo = Instance.new("Frame")
            bo.Name = "Spacer"
            bo.Size = UDim2.new(1, 0, 0, bn or 10)
            bo.BackgroundTransparency = 1
            bo.Parent = bc
            return bo
        end
        function b4:CreateSection(bp, secIcon)
            local bq = {}
            local br = Instance.new("Frame")
            br.Name = bp
            br.Size = UDim2.new(1, 0, 0, 35)
            br.BackgroundColor3 = af.BackgroundDark
            br.BorderSizePixel = 0
            br.Parent = bc
            N(br, 8)
            Q(br, af.Border, 1)
            local bs = Instance.new("Frame")
            bs.Name = "Header"
            bs.Size = UDim2.new(1, 0, 0, 28)
            bs.BackgroundColor3 = af.BackgroundDarker
            bs.BorderSizePixel = 0
            bs.ClipsDescendants = true
            bs.Parent = br
            local bt = Instance.new("UICorner")
            bt.CornerRadius = UDim.new(0, 8)
            bt.Parent = bs
            local bu = Instance.new("Frame")
            bu.Name = "BottomCover"
            bu.Size = UDim2.new(1, 0, 0, 10)
            bu.Position = UDim2.new(0, 0, 1, -10)
            bu.BackgroundColor3 = af.BackgroundDarker
            bu.BorderSizePixel = 0
            bu.Parent = bs
            local aJ = Instance.new("Frame")
            aJ.Name = "Border"
            aJ.Size = UDim2.new(1, 0, 0, 1)
            aJ.Position = UDim2.new(0, 0, 1, 0)
            aJ.BackgroundColor3 = af.Border
            aJ.BorderSizePixel = 0
            aJ.Parent = bs
            local sectionIcon = secIcon or 'folder'
            local bv = H(sectionIcon, bs)
            if bv then
                bv.Position = UDim2.new(0, 10, 0.5, -7)
                bv.Size = UDim2.new(0, 14, 0, 14)
                bv.ImageColor3 = af.Accent
                table.insert(aC.AccentElements, {Type = "Icon", Element = bv})
            end
            local bw = Instance.new("TextLabel")
            bw.Name = "SectionLabel"
            bw.Size = UDim2.new(1, -40, 1, 0)
            bw.Position = UDim2.new(0, bv and 30 or 10, 0, 0)
            bw.BackgroundTransparency = 1
            bw.Text = bp
            bw.TextColor3 = af.Text
            bw.Font = aC.Font
            bw.TextSize = aC.FontSize + 2
            bw.TextXAlignment = Enum.TextXAlignment.Left
            bw.Parent = bs
            local bx = Instance.new("Frame")
            bx.Name = "Content"
            bx.Size = UDim2.new(1, 0, 1, -28)
            bx.Position = UDim2.new(0, 0, 0, 28)
            bx.BackgroundTransparency = 1
            bx.Parent = br
            local by = Instance.new("UIListLayout")
            by.SortOrder = Enum.SortOrder.LayoutOrder
            by.Padding = UDim.new(0, 4)
            by.Parent = bx
            U(bx, 8, 8, 6, 6)
            by:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
                function()
                    br.Size = UDim2.new(1, 0, 0, by.AbsoluteContentSize.Y + 40)
                end
            )
            function bq:AddDivider()
                local be = Instance.new("Frame")
                be.Name = "Divider"
                be.Size = UDim2.new(1, 0, 0, 12)
                be.BackgroundTransparency = 1
                be.Parent = bx
                local bf = Instance.new("Frame")
                bf.Name = "Line"
                bf.Size = UDim2.new(1, 0, 0, 1)
                bf.Position = UDim2.new(0, 0, 0.5, 0)
                bf.BackgroundColor3 = af.Border
                bf.BorderSizePixel = 0
                bf.Parent = be
                return be
            end
            function bq:CreateCheckbox(ak)
                ak = ak or {}
                local bz = ak.Name or "Checkbox"
                local l = ak.Flag or ""
                local bA = ak.Default or false
                local bB = ak.Callback or function()
                    end
                local isUnsupported = ak.Unsupported or false
                local bC = {}
                bC.Value = bA
                bC.Flag = l
                if l ~= "" then
                    k:SetValue(l, bA)
                    k:RegisterElement(l, bC)
                end
                local bD = Instance.new("Frame")
                bD.Name = "Checkbox"
                bD.Size = UDim2.new(1, 0, 0, 28)
                bD.BackgroundColor3 = af.ElementBg
                bD.BorderSizePixel = 0
                bD.Parent = bx
                N(bD, 6)
                Q(bD, af.Border, 1)
                local bE = Instance.new("TextButton")
                bE.Name = "Button"
                bE.Size = UDim2.new(1, 0, 1, 0)
                bE.BackgroundTransparency = 1
                bE.Text = ""
                bE.Parent = bD
                local bF = Instance.new("TextLabel")
                bF.Name = "Label"
                bF.Size = UDim2.new(1, -40, 1, 0)
                bF.Position = UDim2.new(0, 10, 0, 0)
                bF.BackgroundTransparency = 1
                bF.Text = bz
                bF.TextColor3 = af.Text
                bF.Font = aC.Font
                bF.TextSize = aC.FontSize
                bF.TextXAlignment = Enum.TextXAlignment.Left
                bF.Parent = bD
                local bG = Instance.new("Frame")
                bG.Name = "Box"
                bG.Size = UDim2.new(0, 18, 0, 18)
                bG.Position = UDim2.new(1, -28, 0.5, -9)
                bG.BackgroundColor3 = af.BackgroundDarker
                bG.BorderSizePixel = 0
                bG.Parent = bD
                N(bG, 4)
                local bH = Q(bG, af.Border, 1)
                local bI = H("check", bG)
                if bI then
                    bI.Size = UDim2.new(0, 12, 0, 12)
                    bI.Position = UDim2.new(0.5, -6, 0.5, -6)
                    bI.ImageColor3 = af.Text
                    bI.Visible = bA
                end
                table.insert(
                    aC.AccentElements,
                    {Type = "CheckboxBox", Element = bG, Stroke = bH, GetValue = function()
                            return bC.Value
                        end}
                )
                local function bJ()
                    if bC.Value then
                        bG.BackgroundColor3 = af.Toggle
                        bH.Color = af.Toggle
                        if bI then
                            bI.Visible = true
                        end
                    else
                        bG.BackgroundColor3 = af.BackgroundDarker
                        bH.Color = af.Border
                        if bI then
                            bI.Visible = false
                        end
                    end
                end
                bJ()
                if not isUnsupported then
                    bE.MouseEnter:Connect(
                        function()
                            B(bD, {BackgroundColor3 = af.ElementHover}, 0.1)
                        end
                    )
                    bE.MouseLeave:Connect(
                        function()
                            B(bD, {BackgroundColor3 = af.ElementBg}, 0.1)
                        end
                    )
                    bE.MouseButton1Click:Connect(
                        function()
                            bC.Value = not bC.Value
                            bJ()
                            if l ~= "" then
                                k:SetValue(l, bC.Value)
                            end
                            bB(bC.Value)
                        end
                    )
                end
                if isUnsupported then
                    applyUnsupported(bD, bE)
                end
                function bC:Set(m)
                    if not isUnsupported then
                        bC.Value = m
                        bJ()
                        if l ~= "" then
                            k:SetValue(l, m)
                        end
                        bB(m)
                    end
                end
                function bC:Get()
                    return bC.Value
                end
                if not isUnsupported then
                    bB(ak.Default)
                end
                return bC
            end
            function bq:CreateButton(ak)
                ak = ak or {}
                local bz = ak.Name or "Button"
                local I = ak.Icon
                local bB = ak.Callback or function()
                    end
                local isUnsupported = ak.Unsupported or false
                local bK = Instance.new("Frame")
                bK.Name = "Button"
                bK.Size = UDim2.new(1, 0, 0, 28)
                bK.BackgroundColor3 = af.Accent
                bK.BorderSizePixel = 0
                bK.Parent = bx
                N(bK, 6)
                Q(bK, af.Border, 1)
                table.insert(aC.AccentElements, {Type = "Background", Element = bK})
                local bL = Instance.new("TextButton")
                bL.Name = "Click"
                bL.Size = UDim2.new(1, 0, 1, 0)
                bL.BackgroundTransparency = 1
                bL.Text = ""
                bL.AutoButtonColor = false
                bL.Parent = bK
                local bM = Instance.new("Frame")
                bM.Name = "Content"
                bM.Size = UDim2.new(1, 0, 1, 0)
                bM.BackgroundTransparency = 1
                bM.Parent = bL
                local bN = Instance.new("UIListLayout")
                bN.FillDirection = Enum.FillDirection.Horizontal
                bN.VerticalAlignment = Enum.VerticalAlignment.Center
                bN.HorizontalAlignment = Enum.HorizontalAlignment.Center
                bN.Padding = UDim.new(0, 6)
                bN.Parent = bM
                if I then
                    local bO = H(I, bM)
                    if bO then
                        bO.Size = UDim2.new(0, 14, 0, 14)
                        bO.ImageColor3 = af.Text
                        bO.LayoutOrder = 1
                    end
                end
                local bP = Instance.new("TextLabel")
                bP.Name = "Label"
                bP.Size = UDim2.new(0, 0, 0, 28)
                bP.AutomaticSize = Enum.AutomaticSize.X
                bP.BackgroundTransparency = 1
                bP.Text = bz
                bP.TextColor3 = af.Text
                bP.Font = aC.Font
                bP.TextSize = aC.FontSize
                bP.LayoutOrder = 2
                bP.Parent = bM
                if not isUnsupported then
                    bL.MouseButton1Click:Connect(
                        function()
                            B(bK, {BackgroundColor3 = af.AccentHover}, 0.1)
                            task.wait(0.1)
                            B(bK, {BackgroundColor3 = af.Accent}, 0.1)
                            bB()
                        end
                    )
                    bL.MouseEnter:Connect(
                        function()
                            B(bK, {BackgroundColor3 = af.AccentHover}, 0.1)
                        end
                    )
                    bL.MouseLeave:Connect(
                        function()
                            B(bK, {BackgroundColor3 = af.Accent}, 0.1)
                        end
                    )
                end
                if isUnsupported then
                    applyUnsupported(bK, bL)
                end
                return bL
            end
            function bq:CreateSlider(ak)
                ak = ak or {}
                local bz = ak.Name or "Slider"
                local l = ak.Flag or ""
                local bQ = ak.Min or 0
                local bR = ak.Max or 100
                local bA = ak.Default or bQ
                local bS = ak.Increment or 1
                local bT = ak.Suffix or ""
                local bB = ak.Callback or function()
                    end
                local isUnsupported = ak.Unsupported or false
                local bU = {}
                bU.Value = bA
                bU.Flag = l
                if l ~= "" then
                    k:SetValue(l, bA)
                    k:RegisterElement(l, bU)
                end
                local bV = Instance.new("Frame")
                bV.Name = "Slider"
                bV.Size = UDim2.new(1, 0, 0, 38)
                bV.BackgroundColor3 = af.ElementBg
                bV.BorderSizePixel = 0
                bV.Parent = bx
                N(bV, 6)
                Q(bV, af.Border, 1)
                local bW = Instance.new("TextLabel")
                bW.Name = "Label"
                bW.Size = UDim2.new(0.6, 0, 0, 18)
                bW.Position = UDim2.new(0, 10, 0, 4)
                bW.BackgroundTransparency = 1
                bW.Text = bz
                bW.TextColor3 = af.Text
                bW.Font = aC.Font
                bW.TextSize = aC.FontSize
                bW.TextXAlignment = Enum.TextXAlignment.Left
                bW.Parent = bV
                local bX = Instance.new("TextLabel")
                bX.Name = "Value"
                bX.Size = UDim2.new(0.4, -10, 0, 18)
                bX.Position = UDim2.new(0.6, 0, 0, 4)
                bX.BackgroundTransparency = 1
                bX.Text = tostring(bA) .. bT
                bX.TextColor3 = af.Accent
                bX.Font = aC.Font
                bX.TextSize = aC.FontSize
                bX.TextXAlignment = Enum.TextXAlignment.Right
                bX.Parent = bV
                table.insert(aC.AccentElements, {Type = "Text", Element = bX})
                local bY = Instance.new("Frame")
                bY.Name = "Bar"
                bY.Size = UDim2.new(1, -20, 0, 6)
                bY.Position = UDim2.new(0, 10, 1, -14)
                bY.BackgroundColor3 = af.BackgroundDarker
                bY.BorderSizePixel = 0
                bY.Parent = bV
                N(bY, 3)
                local bZ = Instance.new("Frame")
                bZ.Name = "Fill"
                bZ.Size = UDim2.new((bA - bQ) / (bR - bQ), 0, 1, 0)
                bZ.BackgroundColor3 = af.Accent
                bZ.BorderSizePixel = 0
                bZ.Parent = bY
                table.insert(aC.AccentElements, {Type = "Background", Element = bZ})
                N(bZ, 3)
                local b_ = Instance.new("TextButton")
                b_.Name = "Button"
                b_.Size = UDim2.new(1, 0, 1, 10)
                b_.Position = UDim2.new(0, 0, 0, -5)
                b_.BackgroundTransparency = 1
                b_.Text = ""
                b_.Parent = bY
                local a2 = false
                if not isUnsupported then
                    b_.MouseButton1Down:Connect(
                        function()
                            a2 = true
                        end
                    )
                    b.InputEnded:Connect(
                        function(a6)
                            if a6.UserInputType == Enum.UserInputType.MouseButton1 then
                                a2 = false
                            end
                        end
                    )
                    local function c0()
                        local c1 = b:GetMouseLocation()
                        local c2 = math.clamp((c1.X - bY.AbsolutePosition.X) / bY.AbsoluteSize.X, 0, 1)
                        local m = math.floor((bQ + (bR - bQ) * c2) / bS + 0.5) * bS
                        m = math.clamp(m, bQ, bR)
                        bU:Set(m)
                    end
                    b_.MouseButton1Click:Connect(c0)
                    b.InputChanged:Connect(
                        function(a6)
                            if a2 and a6.UserInputType == Enum.UserInputType.MouseMovement then
                                c0()
                            end
                        end
                    )
                    bV.MouseEnter:Connect(
                        function()
                            B(bV, {BackgroundColor3 = af.ElementHover}, 0.1)
                        end
                    )
                    bV.MouseLeave:Connect(
                        function()
                            B(bV, {BackgroundColor3 = af.ElementBg}, 0.1)
                        end
                    )
                end
                if isUnsupported then
                    applyUnsupported(bV, b_)
                end
                function bU:Set(m)
                    if not isUnsupported then
                        m = math.clamp(m, bQ, bR)
                        bU.Value = m
                        bX.Text = tostring(m) .. bT
                        B(bZ, {Size = UDim2.new((m - bQ) / (bR - bQ), 0, 1, 0)}, 0.1)
                        if l ~= "" then
                            k:SetValue(l, m)
                        end
                        bB(m)
                    end
                end
                function bU:Get()
                    return bU.Value
                end
                if not isUnsupported then
                    bB(ak.Default)
                end
                return bU
            end
            function bq:CreateDropdown(ak)
                ak = ak or {}
                local bz = ak.Name or "Dropdown"
                local l = ak.Flag or ""
                local c3 = ak.Items or {}
                local bA = ak.Default or (c3[1] or "None")
                local bB = ak.Callback or function()
                    end
                local c4 = ak.Search ~= false
                local isUnsupported = ak.Unsupported or false
                local c5 = {}
                c5.Value = bA
                c5.Items = c3
                c5.Open = false
                c5.Flag = l
                if l ~= "" then
                    k:SetValue(l, bA)
                    k:RegisterElement(l, c5)
                end
                local c6 = Instance.new("Frame")
                c6.Name = "Dropdown"
                c6.Size = UDim2.new(1, 0, 0, 28)
                c6.BackgroundTransparency = 1
                c6.ClipsDescendants = false
                c6.ZIndex = 5
                c6.Parent = bx
                local c7 = Instance.new("TextButton")
                c7.Name = "Button"
                c7.Size = UDim2.new(1, 0, 0, 28)
                c7.BackgroundColor3 = af.ElementBg
                c7.BorderSizePixel = 0
                c7.Text = ""
                c7.AutoButtonColor = false
                c7.ZIndex = 6
                c7.Parent = c6
                N(c7, 6)
                local c8 = Q(c7, af.Border, 1)
                c8.ZIndex = 6
                local c9 = Instance.new("TextLabel")
                c9.Name = "Label"
                c9.Size = UDim2.new(0.5, -10, 1, 0)
                c9.Position = UDim2.new(0, 10, 0, 0)
                c9.BackgroundTransparency = 1
                c9.Text = bz
                c9.TextColor3 = af.TextDark
                c9.Font = aC.Font
                c9.TextSize = aC.FontSize
                c9.TextXAlignment = Enum.TextXAlignment.Left
                c9.ZIndex = 6
                c9.Parent = c7
                local ca = Instance.new("TextLabel")
                ca.Name = "Value"
                ca.Size = UDim2.new(0.5, -30, 1, 0)
                ca.Position = UDim2.new(0.5, 0, 0, 0)
                ca.BackgroundTransparency = 1
                ca.Text = bA
                ca.TextColor3 = af.Accent
                ca.Font = aC.Font
                ca.TextSize = aC.FontSize
                ca.TextXAlignment = Enum.TextXAlignment.Right
                ca.ZIndex = 6
                ca.Parent = c7
                table.insert(aC.AccentElements, {Type = "Text", Element = ca})
                local cb = H("chevron-down", c7)
                if cb then
                    cb.Size = UDim2.new(0, 14, 0, 14)
                    cb.Position = UDim2.new(1, -22, 0.5, -7)
                    cb.ImageColor3 = af.TextDark
                    cb.ZIndex = 6
                end
                local cc = Instance.new("Frame")
                cc.Name = "List"
                cc.Size = UDim2.new(1, 0, 0, 0)
                cc.Position = UDim2.new(0, 0, 0, 30)
                cc.BackgroundColor3 = af.BackgroundDarker
                cc.BorderSizePixel = 0
                cc.Visible = false
                cc.ZIndex = 50
                cc.ClipsDescendants = true
                cc.Parent = c6
                N(cc, 6)
                local cd = Q(cc, af.Accent, 1)
                cd.ZIndex = 50
                table.insert(aC.AccentElements, {Type = "Stroke", Element = cd})
                local ce
                local cf = 0
                if c4 then
                    cf = 32
                    local cg = Instance.new("Frame")
                    cg.Name = "SearchContainer"
                    cg.Size = UDim2.new(1, 0, 0, 28)
                    cg.BackgroundTransparency = 1
                    cg.ZIndex = 50
                    cg.Parent = cc
                    ce = Instance.new("TextBox")
                    ce.Name = "Search"
                    ce.Size = UDim2.new(1, -8, 0, 22)
                    ce.Position = UDim2.new(0, 4, 0, 3)
                    ce.BackgroundColor3 = af.ElementBg
                    ce.BorderSizePixel = 0
                    ce.Text = ""
                    ce.PlaceholderText = "Search..."
                    ce.TextColor3 = af.Text
                    ce.PlaceholderColor3 = af.TextMuted
                    ce.Font = aC.Font
                    ce.TextSize = aC.FontSize - 1
                    ce.ClearTextOnFocus = false
                    ce.ZIndex = 51
                    ce.Parent = cg
                    N(ce, 4)
                    Q(ce, af.Border, 1)
                    U(ce, 6, 6, 0, 0)
                    local ch = Instance.new("Frame")
                    ch.Name = "Divider"
                    ch.Size = UDim2.new(1, -8, 0, 1)
                    ch.Position = UDim2.new(0, 4, 1, 0)
                    ch.BackgroundColor3 = af.Border
                    ch.BorderSizePixel = 0
                    ch.ZIndex = 50
                    ch.Parent = cg
                end
                local ci = Instance.new("ScrollingFrame")
                ci.Name = "Container"
                ci.Size = UDim2.new(1, 0, 1, -cf)
                ci.Position = UDim2.new(0, 0, 0, cf)
                ci.BackgroundTransparency = 1
                ci.BorderSizePixel = 0
                ci.ScrollBarThickness = 3
                ci.ScrollBarImageColor3 = af.Accent
                ci.CanvasSize = UDim2.new(0, 0, 0, 0)
                ci.ZIndex = 50
                ci.Parent = cc
                table.insert(aC.AccentElements, {Type = "ScrollBar", Element = ci})
                local cj = Instance.new("UIListLayout")
                cj.SortOrder = Enum.SortOrder.LayoutOrder
                cj.Padding = UDim.new(0, 2)
                cj.Parent = ci
                U(ci, 4, 4, 4, 4)
                cj:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
                    function()
                        ci.CanvasSize = UDim2.new(0, 0, 0, cj.AbsoluteContentSize.Y + 8)
                    end
                )
                if not isUnsupported then
                    c7.MouseEnter:Connect(
                        function()
                            if not c5.Open then
                                B(c7, {BackgroundColor3 = af.ElementHover}, 0.1)
                            end
                        end
                    )
                    c7.MouseLeave:Connect(
                        function()
                            if not c5.Open then
                                B(c7, {BackgroundColor3 = af.ElementBg}, 0.1)
                            end
                        end
                    )
                    c7.MouseButton1Click:Connect(
                        function()
                            c5.Open = not c5.Open
                            if c5.Open then
                                cc.Visible = true
                                local bn = math.min(#c5.Items * 26 + 8 + cf, 130 + cf)
                                B(c6, {Size = UDim2.new(1, 0, 0, 28 + bn + 4)}, 0.2)
                                B(cc, {Size = UDim2.new(1, 0, 0, bn)}, 0.2)
                                if cb then
                                    B(cb, {Rotation = 180}, 0.2)
                                end
                                c8.Color = af.Accent
                                c7.BackgroundColor3 = af.ElementHover
                            else
                                B(c6, {Size = UDim2.new(1, 0, 0, 28)}, 0.2)
                                B(cc, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                                if cb then
                                    B(cb, {Rotation = 0}, 0.2)
                                end
                                c8.Color = af.Border
                                c7.BackgroundColor3 = af.ElementBg
                                task.delay(
                                    0.2,
                                    function()
                                        if not c5.Open then
                                            cc.Visible = false
                                            if ce then
                                                ce.Text = ""
                                            end
                                        end
                                    end
                                )
                            end
                        end
                    )
                end
                function c5:Refresh(ck)
                    for y, cl in pairs(ci:GetChildren()) do
                        if cl:IsA("TextButton") then
                            cl:Destroy()
                        end
                    end
                    c5.Items = ck or c3
                    for y, cm in pairs(c5.Items) do
                        local cn = Instance.new("TextButton")
                        cn.Name = "Item"
                        cn.Size = UDim2.new(1, 0, 0, 24)
                        cn.BackgroundColor3 = af.ElementBg
                        cn.BorderSizePixel = 0
                        cn.Text = cm
                        cn.TextColor3 = af.Text
                        cn.Font = aC.Font
                        cn.TextSize = aC.FontSize
                        cn.AutoButtonColor = false
                        cn.ZIndex = 50
                        cn.Parent = ci
                        N(cn, 4)
                        Q(cn, af.Border, 1)
                        if not isUnsupported then
                            cn.MouseButton1Click:Connect(
                                function()
                                    c5.Value = cm
                                    ca.Text = cm
                                    c5.Open = false
                                    B(c6, {Size = UDim2.new(1, 0, 0, 28)}, 0.2)
                                    B(cc, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                                    if cb then
                                        B(cb, {Rotation = 0}, 0.2)
                                    end
                                    c8.Color = af.Border
                                    c7.BackgroundColor3 = af.ElementBg
                                    task.delay(
                                        0.2,
                                        function()
                                            cc.Visible = false
                                            if ce then
                                                ce.Text = ""
                                            end
                                        end
                                    )
                                    if l ~= "" then
                                        k:SetValue(l, cm)
                                    end
                                    bB(cm)
                                end
                            )
                            cn.MouseEnter:Connect(
                                function()
                                    B(cn, {BackgroundColor3 = af.Accent}, 0.1)
                                end
                            )
                            cn.MouseLeave:Connect(
                                function()
                                    B(cn, {BackgroundColor3 = af.ElementBg}, 0.1)
                                end
                            )
                        end
                    end
                end
                if ce and not isUnsupported then
                    ce:GetPropertyChangedSignal("Text"):Connect(
                        function()
                            local co = ce.Text:lower()
                            for y, cl in pairs(ci:GetChildren()) do
                                if cl:IsA("TextButton") then
                                    if co == "" or cl.Text:lower():find(co) then
                                        cl.Visible = true
                                    else
                                        cl.Visible = false
                                    end
                                end
                            end
                        end
                    )
                end
                if isUnsupported then
                    applyUnsupported(c6, c7)
                end
                function c5:Set(m)
                    if not isUnsupported then
                        if table.find(c5.Items, m) then
                            c5.Value = m
                            ca.Text = m
                            if l ~= "" then
                                k:SetValue(l, m)
                            end
                            bB(m)
                        end
                    end
                end
                function c5:Get()
                    return c5.Value
                end
                if not isUnsupported then
                    bB(ak.Default)
                end
                c5:Refresh()
                return c5
            end
            function bq:CreateMultiDropdown(ak)
                ak = ak or {}
                local bz = ak.Name or "Multi Dropdown"
                local l = ak.Flag or ""
                local c3 = ak.Items or {}
                local bA = ak.Default or {}
                local bB = ak.Callback or function()
                    end
                local c4 = ak.Search ~= false
                local isUnsupported = ak.Unsupported or false
                local cp = {}
                cp.Values = {}
                cp.Items = c3
                cp.Open = false
                cp.Flag = l
                for y, cq in pairs(bA) do
                    cp.Values[cq] = true
                end
                if l ~= "" then
                    k:SetValue(l, cp.Values)
                    k:RegisterElement(l, cp)
                end
                local c6 = Instance.new("Frame")
                c6.Name = "MultiDropdown"
                c6.Size = UDim2.new(1, 0, 0, 28)
                c6.BackgroundTransparency = 1
                c6.ClipsDescendants = false
                c6.ZIndex = 5
                c6.Parent = bx
                local c7 = Instance.new("TextButton")
                c7.Name = "Button"
                c7.Size = UDim2.new(1, 0, 0, 28)
                c7.BackgroundColor3 = af.ElementBg
                c7.BorderSizePixel = 0
                c7.Text = ""
                c7.AutoButtonColor = false
                c7.ZIndex = 6
                c7.Parent = c6
                N(c7, 6)
                local c8 = Q(c7, af.Border, 1)
                c8.ZIndex = 6
                local c9 = Instance.new("TextLabel")
                c9.Name = "Label"
                c9.Size = UDim2.new(0.5, -10, 1, 0)
                c9.Position = UDim2.new(0, 10, 0, 0)
                c9.BackgroundTransparency = 1
                c9.Text = bz
                c9.TextColor3 = af.TextDark
                c9.Font = aC.Font
                c9.TextSize = aC.FontSize
                c9.TextXAlignment = Enum.TextXAlignment.Left
                c9.ZIndex = 6
                c9.Parent = c7
                local function cr()
                    local cs = {}
                    for cm, y in pairs(cp.Values) do
                        table.insert(cs, cm)
                    end
                    return #cs > 0 and table.concat(cs, ", ") or "None"
                end
                local ca = Instance.new("TextLabel")
                ca.Name = "Value"
                ca.Size = UDim2.new(0.5, -30, 1, 0)
                ca.Position = UDim2.new(0.5, 0, 0, 0)
                ca.BackgroundTransparency = 1
                ca.Text = cr()
                ca.TextColor3 = af.Accent
                ca.Font = aC.Font
                ca.TextSize = aC.FontSize
                ca.TextXAlignment = Enum.TextXAlignment.Right
                ca.TextTruncate = Enum.TextTruncate.AtEnd
                ca.ZIndex = 6
                ca.Parent = c7
                table.insert(aC.AccentElements, {Type = "Text", Element = ca})
                local cb = H("chevron-down", c7)
                if cb then
                    cb.Size = UDim2.new(0, 14, 0, 14)
                    cb.Position = UDim2.new(1, -22, 0.5, -7)
                    cb.ImageColor3 = af.TextDark
                    cb.ZIndex = 6
                end
                local cc = Instance.new("Frame")
                cc.Name = "List"
                cc.Size = UDim2.new(1, 0, 0, 0)
                cc.Position = UDim2.new(0, 0, 0, 30)
                cc.BackgroundColor3 = af.BackgroundDarker
                cc.BorderSizePixel = 0
                cc.Visible = false
                cc.ZIndex = 50
                cc.ClipsDescendants = true
                cc.Parent = c6
                N(cc, 6)
                local cd = Q(cc, af.Accent, 1)
                cd.ZIndex = 50
                table.insert(aC.AccentElements, {Type = "Stroke", Element = cd})
                local ce
                local cf = 0
                if c4 then
                    cf = 32
                    local cg = Instance.new("Frame")
                    cg.Name = "SearchContainer"
                    cg.Size = UDim2.new(1, 0, 0, 28)
                    cg.BackgroundTransparency = 1
                    cg.ZIndex = 50
                    cg.Parent = cc
                    ce = Instance.new("TextBox")
                    ce.Name = "Search"
                    ce.Size = UDim2.new(1, -8, 0, 22)
                    ce.Position = UDim2.new(0, 4, 0, 3)
                    ce.BackgroundColor3 = af.ElementBg
                    ce.BorderSizePixel = 0
                    ce.Text = ""
                    ce.PlaceholderText = "Search..."
                    ce.TextColor3 = af.Text
                    ce.PlaceholderColor3 = af.TextMuted
                    ce.Font = aC.Font
                    ce.TextSize = aC.FontSize - 1
                    ce.ClearTextOnFocus = false
                    ce.ZIndex = 51
                    ce.Parent = cg
                    N(ce, 4)
                    Q(ce, af.Border, 1)
                    U(ce, 6, 6, 0, 0)
                    local ch = Instance.new("Frame")
                    ch.Name = "Divider"
                    ch.Size = UDim2.new(1, -8, 0, 1)
                    ch.Position = UDim2.new(0, 4, 1, 0)
                    ch.BackgroundColor3 = af.Border
                    ch.BorderSizePixel = 0
                    ch.ZIndex = 50
                    ch.Parent = cg
                end
                local ci = Instance.new("ScrollingFrame")
                ci.Name = "Container"
                ci.Size = UDim2.new(1, 0, 1, -cf)
                ci.Position = UDim2.new(0, 0, 0, cf)
                ci.BackgroundTransparency = 1
                ci.BorderSizePixel = 0
                ci.ScrollBarThickness = 3
                ci.ScrollBarImageColor3 = af.Accent
                ci.CanvasSize = UDim2.new(0, 0, 0, 0)
                ci.ZIndex = 50
                ci.Parent = cc
                table.insert(aC.AccentElements, {Type = "ScrollBar", Element = ci})
                local cj = Instance.new("UIListLayout")
                cj.SortOrder = Enum.SortOrder.LayoutOrder
                cj.Padding = UDim.new(0, 2)
                cj.Parent = ci
                U(ci, 4, 4, 4, 4)
                cj:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
                    function()
                        ci.CanvasSize = UDim2.new(0, 0, 0, cj.AbsoluteContentSize.Y + 8)
                    end
                )
                if not isUnsupported then
                    c7.MouseEnter:Connect(
                        function()
                            if not cp.Open then
                                B(c7, {BackgroundColor3 = af.ElementHover}, 0.1)
                            end
                        end
                    )
                    c7.MouseLeave:Connect(
                        function()
                            if not cp.Open then
                                B(c7, {BackgroundColor3 = af.ElementBg}, 0.1)
                            end
                        end
                    )
                    c7.MouseButton1Click:Connect(
                        function()
                            cp.Open = not cp.Open
                            if cp.Open then
                                cc.Visible = true
                                local bn = math.min(#cp.Items * 26 + 8 + cf, 130 + cf)
                                B(c6, {Size = UDim2.new(1, 0, 0, 28 + bn + 4)}, 0.2)
                                B(cc, {Size = UDim2.new(1, 0, 0, bn)}, 0.2)
                                if cb then
                                    B(cb, {Rotation = 180}, 0.2)
                                end
                                c8.Color = af.Accent
                                c7.BackgroundColor3 = af.ElementHover
                            else
                                B(c6, {Size = UDim2.new(1, 0, 0, 28)}, 0.2)
                                B(cc, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                                if cb then
                                    B(cb, {Rotation = 0}, 0.2)
                                end
                                c8.Color = af.Border
                                c7.BackgroundColor3 = af.ElementBg
                                task.delay(
                                    0.2,
                                    function()
                                        if not cp.Open then
                                            cc.Visible = false
                                            if ce then
                                                ce.Text = ""
                                            end
                                        end
                                    end
                                )
                            end
                        end
                    )
                end
                function cp:Refresh(ck)
                    for y, cl in pairs(ci:GetChildren()) do
                        if cl:IsA("Frame") and cl.Name == "MultiItem" then
                            cl:Destroy()
                        end
                    end
                    cp.Items = ck or c3
                    for y, cm in pairs(cp.Items) do
                        local ct = Instance.new("Frame")
                        ct.Name = "MultiItem"
                        ct.Size = UDim2.new(1, 0, 0, 24)
                        ct.BackgroundColor3 = af.ElementBg
                        ct.BorderSizePixel = 0
                        ct.ZIndex = 50
                        ct.Parent = ci
                        N(ct, 4)
                        Q(ct, af.Border, 1)
                        local cn = Instance.new("TextButton")
                        cn.Name = "Button"
                        cn.Size = UDim2.new(1, 0, 1, 0)
                        cn.BackgroundTransparency = 1
                        cn.Text = ""
                        cn.ZIndex = 51
                        cn.Parent = ct
                        local cu = Instance.new("TextLabel")
                        cu.Name = "Label"
                        cu.Size = UDim2.new(1, -30, 1, 0)
                        cu.Position = UDim2.new(0, 6, 0, 0)
                        cu.BackgroundTransparency = 1
                        cu.Text = cm
                        cu.TextColor3 = af.Text
                        cu.Font = aC.Font
                        cu.TextSize = aC.FontSize
                        cu.TextXAlignment = Enum.TextXAlignment.Left
                        cu.ZIndex = 51
                        cu.Parent = ct
                        local cv = Instance.new("Frame")
                        cv.Name = "CheckBox"
                        cv.Size = UDim2.new(0, 14, 0, 14)
                        cv.Position = UDim2.new(1, -19, 0.5, -7)
                        cv.BackgroundColor3 = af.BackgroundDarker
                        cv.BorderSizePixel = 0
                        cv.ZIndex = 51
                        cv.Parent = ct
                        N(cv, 3)
                        local cw = Q(cv, af.Border, 1)
                        cw.ZIndex = 51
                        local bI = H("check", cv)
                        if bI then
                            bI.Size = UDim2.new(0, 10, 0, 10)
                            bI.Position = UDim2.new(0.5, -5, 0.5, -5)
                            bI.ImageColor3 = af.Text
                            bI.Visible = cp.Values[cm] or false
                            bI.ZIndex = 52
                        end
                        local function cx()
                            if cp.Values[cm] then
                                cv.BackgroundColor3 = af.Toggle
                                cw.Color = af.Toggle
                                if bI then
                                    bI.Visible = true
                                end
                            else
                                cv.BackgroundColor3 = af.BackgroundDarker
                                cw.Color = af.Border
                                if bI then
                                    bI.Visible = false
                                end
                            end
                            ca.Text = cr()
                        end
                        table.insert(
                            aC.AccentElements,
                            {Type = "CheckboxBox", Element = cv, Stroke = cw, GetValue = function()
                                    return cp.Values[cm]
                                end}
                        )
                        cx()
                        if not isUnsupported then
                            cn.MouseButton1Click:Connect(
                                function()
                                    if cp.Values[cm] then
                                        cp.Values[cm] = nil
                                    else
                                        cp.Values[cm] = true
                                    end
                                    cx()
                                    if l ~= "" then
                                        k:SetValue(l, cp.Values)
                                    end
                                    bB(cp.Values)
                                end
                            )
                            cn.MouseEnter:Connect(
                                function()
                                    B(ct, {BackgroundColor3 = af.ElementHover}, 0.1)
                                end
                            )
                            cn.MouseLeave:Connect(
                                function()
                                    B(ct, {BackgroundColor3 = af.ElementBg}, 0.1)
                                end
                            )
                        end
                    end
                end
                if ce and not isUnsupported then
                    ce:GetPropertyChangedSignal("Text"):Connect(
                        function()
                            local co = ce.Text:lower()
                            for y, cl in pairs(ci:GetChildren()) do
                                if cl:IsA("Frame") and cl.Name == "MultiItem" then
                                    local cy = cl:FindFirstChild("Label")
                                    if cy then
                                        if co == "" or cy.Text:lower():find(co) then
                                            cl.Visible = true
                                        else
                                            cl.Visible = false
                                        end
                                    end
                                end
                            end
                        end
                    )
                end
                if isUnsupported then
                    applyUnsupported(c6, c7)
                end
                function cp:Set(cz)
                    if not isUnsupported then
                        cp.Values = cz
                        cp:Refresh()
                        ca.Text = cr()
                        if l ~= "" then
                            k:SetValue(l, cz)
                        end
                        bB(cz)
                    end
                end
                function cp:Get()
                    return cp.Values
                end
                if not isUnsupported then
                    bB(ak.Default)
                end
                cp:Refresh()
                return cp
            end
            function bq:CreateColorpicker(ak)
                ak = ak or {}
                local bz = ak.Name or "Color"
                local l = ak.Flag or ""
                local bA = ak.Default or Color3.fromRGB(255, 255, 255)
                local bB = ak.Callback or function()
                    end
                local isUnsupported = ak.Unsupported or false
                local cA = {}
                cA.Value = bA
                cA.Flag = l
                if l ~= "" then
                    k:SetValue(l, bA)
                    k:RegisterElement(l, cA)
                end
                local cB = Instance.new("Frame")
                cB.Name = "Colorpicker"
                cB.Size = UDim2.new(1, 0, 0, 28)
                cB.BackgroundColor3 = af.ElementBg
                cB.BorderSizePixel = 0
                cB.Parent = bx
                N(cB, 6)
                Q(cB, af.Border, 1)
                local cC = Instance.new("TextLabel")
                cC.Name = "Label"
                cC.Size = UDim2.new(1, -50, 1, 0)
                cC.Position = UDim2.new(0, 10, 0, 0)
                cC.BackgroundTransparency = 1
                cC.Text = bz
                cC.TextColor3 = af.Text
                cC.Font = aC.Font
                cC.TextSize = aC.FontSize
                cC.TextXAlignment = Enum.TextXAlignment.Left
                cC.Parent = cB
                local cD = Instance.new("Frame")
                cD.Name = "DisplayBg"
                cD.Size = UDim2.new(0, 32, 0, 18)
                cD.Position = UDim2.new(1, -42, 0.5, -9)
                cD.BackgroundColor3 = af.BackgroundDarker
                cD.BorderSizePixel = 0
                cD.Parent = cB
                N(cD, 4)
                Q(cD, af.Border, 1)
                local cE = Instance.new("Frame")
                cE.Name = "Display"
                cE.Size = UDim2.new(1, -6, 1, -6)
                cE.Position = UDim2.new(0, 3, 0, 3)
                cE.BackgroundColor3 = bA
                cE.BorderSizePixel = 0
                cE.Parent = cD
                N(cE, 2)
                local cF = Instance.new("TextButton")
                cF.Name = "Button"
                cF.Size = UDim2.new(1, 0, 1, 0)
                cF.BackgroundTransparency = 1
                cF.Text = ""
                cF.Parent = cB
                if not isUnsupported then
                    cF.MouseEnter:Connect(
                        function()
                            B(cB, {BackgroundColor3 = af.ElementHover}, 0.1)
                        end
                    )
                    cF.MouseLeave:Connect(
                        function()
                            B(cB, {BackgroundColor3 = af.ElementBg}, 0.1)
                        end
                    )
                end
                local cG = Instance.new("Frame")
                cG.Name = "Picker"
                cG.Size = UDim2.new(0, 220, 0, 260)
                cG.BackgroundColor3 = af.Background
                cG.BorderSizePixel = 0
                cG.Visible = false
                cG.ZIndex = 100
                cG.Parent = h
                N(cG, 8)
                Q(cG, af.Accent, 2)
                local function cH()
                    local cI = aC.MainFrame.AbsolutePosition
                    local cJ = aC.MainFrame.AbsoluteSize
                    cG.Position = UDim2.new(0, cI.X + cJ.X + 10, 0, cI.Y)
                end
                local cK = Instance.new("Frame")
                cK.Name = "Header"
                cK.Size = UDim2.new(1, 0, 0, 28)
                cK.BackgroundColor3 = af.Header
                cK.BorderSizePixel = 0
                cK.ZIndex = 100
                cK.ClipsDescendants = true
                cK.Parent = cG
                N(cK, 8)
                local cL = Instance.new("Frame")
                cL.Name = "BottomCover"
                cL.Size = UDim2.new(1, 0, 0, 10)
                cL.Position = UDim2.new(0, 0, 1, -10)
                cL.BackgroundColor3 = af.Header
                cL.BorderSizePixel = 0
                cL.ZIndex = 100
                cL.Parent = cK
                local cM = Instance.new("TextLabel")
                cM.Name = "Title"
                cM.Size = UDim2.new(1, -20, 1, 0)
                cM.Position = UDim2.new(0, 10, 0, 0)
                cM.BackgroundTransparency = 1
                cM.Text = "COLOR PICKER"
                cM.TextColor3 = af.Accent
                cM.Font = aC.Font
                cM.TextSize = aC.FontSize
                cM.TextXAlignment = Enum.TextXAlignment.Left
                cM.ZIndex = 100
                cM.Parent = cK
                table.insert(aC.AccentElements, {Type = "Text", Element = cM})
                local cN = Instance.new("Frame")
                cN.Name = "Palette"
                cN.Size = UDim2.new(1, -20, 0, 150)
                cN.Position = UDim2.new(0, 10, 0, 38)
                cN.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                cN.BorderSizePixel = 0
                cN.ZIndex = 100
                cN.Parent = cG
                N(cN, 6)
                local cO = Instance.new("Frame")
                cO.Name = "Saturation"
                cO.Size = UDim2.new(1, 0, 1, 0)
                cO.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                cO.BorderSizePixel = 0
                cO.ZIndex = 101
                cO.Parent = cN
                local cP = Instance.new("UIGradient")
                cP.Transparency =
                    NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
                cP.Parent = cO
                N(cO, 6)
                local cQ = Instance.new("Frame")
                cQ.Name = "Brightness"
                cQ.Size = UDim2.new(1, 0, 1, 0)
                cQ.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                cQ.BorderSizePixel = 0
                cQ.ZIndex = 102
                cQ.Parent = cN
                local cR = Instance.new("UIGradient")
                cR.Transparency =
                    NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
                cR.Rotation = 90
                cR.Parent = cQ
                N(cQ, 6)
                local cS = Instance.new("Frame")
                cS.Name = "Selector"
                cS.Size = UDim2.new(0, 12, 0, 12)
                cS.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                cS.BorderSizePixel = 0
                cS.ZIndex = 103
                cS.Parent = cN
                N(cS, 6)
                Q(cS, Color3.fromRGB(0, 0, 0), 2)
                local cT = Instance.new("Frame")
                cT.Name = "HueSlider"
                cT.Size = UDim2.new(1, -20, 0, 16)
                cT.Position = UDim2.new(0, 10, 0, 196)
                cT.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                cT.BorderSizePixel = 0
                cT.ZIndex = 100
                cT.Parent = cG
                N(cT, 4)
                local cU = Instance.new("UIGradient")
                cU.Color =
                    ColorSequence.new(
                    {
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    }
                )
                cU.Parent = cT
                local cV = Instance.new("Frame")
                cV.Name = "Selector"
                cV.Size = UDim2.new(0, 6, 1, 4)
                cV.Position = UDim2.new(0, -3, 0, -2)
                cV.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                cV.BorderSizePixel = 0
                cV.ZIndex = 101
                cV.Parent = cT
                N(cV, 3)
                Q(cV, Color3.fromRGB(0, 0, 0), 1)
                local cW = Instance.new("TextButton")
                cW.Name = "Button"
                cW.Size = UDim2.new(1, 0, 1, 0)
                cW.BackgroundTransparency = 1
                cW.Text = ""
                cW.ZIndex = 102
                cW.Parent = cT
                local cX, cY, cq = bA:ToHSV()
                local function cZ()
                    local R = Color3.fromHSV(cX, cY, cq)
                    cA.Value = R
                    cE.BackgroundColor3 = R
                    if l ~= "" then
                        k:SetValue(l, R)
                    end
                    bB(R)
                end
                local function c_()
                    cN.BackgroundColor3 = Color3.fromHSV(cX, 1, 1)
                end
                cV.Position = UDim2.new(cX, -3, 0, -2)
                cS.Position = UDim2.new(cY, -6, 1 - cq, -6)
                c_()
                local d0 = false
                if not isUnsupported then
                    cN.InputBegan:Connect(
                        function(a6)
                            if a6.UserInputType == Enum.UserInputType.MouseButton1 then
                                d0 = true
                                local d1 = a6.Position
                                local d2 = math.clamp((d1.X - cN.AbsolutePosition.X) / cN.AbsoluteSize.X, 0, 1)
                                local d3 = math.clamp((d1.Y - cN.AbsolutePosition.Y) / cN.AbsoluteSize.Y, 0, 1)
                                cY = d2
                                cq = 1 - d3
                                cS.Position = UDim2.new(d2, -6, d3, -6)
                                cZ()
                            end
                        end
                    )
                    b.InputChanged:Connect(
                        function(a6)
                            if d0 and a6.UserInputType == Enum.UserInputType.MouseMovement then
                                local d1 = a6.Position
                                local d2 = math.clamp((d1.X - cN.AbsolutePosition.X) / cN.AbsoluteSize.X, 0, 1)
                                local d3 = math.clamp((d1.Y - cN.AbsolutePosition.Y) / cN.AbsoluteSize.Y, 0, 1)
                                cY = d2
                                cq = 1 - d3
                                cS.Position = UDim2.new(d2, -6, d3, -6)
                                cZ()
                            end
                        end
                    )
                    b.InputEnded:Connect(
                        function(a6)
                            if a6.UserInputType == Enum.UserInputType.MouseButton1 then
                                d0 = false
                            end
                        end
                    )
                    local d4 = false
                    cW.MouseButton1Down:Connect(
                        function()
                            d4 = true
                            local c1 = b:GetMouseLocation()
                            local c2 = math.clamp((c1.X - cT.AbsolutePosition.X) / cT.AbsoluteSize.X, 0, 1)
                            cX = c2
                            cV.Position = UDim2.new(c2, -3, 0, -2)
                            c_()
                            cZ()
                        end
                    )
                    b.InputEnded:Connect(
                        function(a6)
                            if a6.UserInputType == Enum.UserInputType.MouseButton1 then
                                d4 = false
                            end
                        end
                    )
                    b.InputChanged:Connect(
                        function(a6)
                            if d4 and a6.UserInputType == Enum.UserInputType.MouseMovement then
                                local c1 = b:GetMouseLocation()
                                local c2 = math.clamp((c1.X - cT.AbsolutePosition.X) / cT.AbsoluteSize.X, 0, 1)
                                cX = c2
                                cV.Position = UDim2.new(c2, -3, 0, -2)
                                c_()
                                cZ()
                            end
                        end
                    )
                end
                local d5 = Instance.new("TextButton")
                d5.Name = "Close"
                d5.Size = UDim2.new(1, -20, 0, 28)
                d5.Position = UDim2.new(0, 10, 1, -38)
                d5.BackgroundColor3 = af.Accent
                d5.BorderSizePixel = 0
                d5.Text = "CLOSE"
                d5.TextColor3 = af.Text
                d5.Font = aC.Font
                d5.TextSize = aC.FontSize
                d5.ZIndex = 100
                d5.AutoButtonColor = false
                d5.Parent = cG
                N(d5, 6)
                table.insert(aC.AccentElements, {Type = "Background", Element = d5})
                d5.MouseButton1Click:Connect(
                    function()
                        cG.Visible = false
                    end
                )
                d5.MouseEnter:Connect(
                    function()
                        B(d5, {BackgroundColor3 = af.AccentHover}, 0.1)
                    end
                )
                d5.MouseLeave:Connect(
                    function()
                        B(d5, {BackgroundColor3 = af.Accent}, 0.1)
                    end
                )
                if not isUnsupported then
                    cF.MouseButton1Click:Connect(
                        function()
                            cG.Visible = not cG.Visible
                            if cG.Visible then
                                cH()
                            end
                        end
                    )
                end
                _(cG, cK)
                if isUnsupported then
                    applyUnsupported(cB, cF)
                end
                function cA:Set(R)
                    if not isUnsupported then
                        cA.Value = R
                        cE.BackgroundColor3 = R
                        cX, cY, cq = R:ToHSV()
                        cV.Position = UDim2.new(cX, -3, 0, -2)
                        cS.Position = UDim2.new(cY, -6, 1 - cq, -6)
                        c_()
                        if l ~= "" then
                            k:SetValue(l, R)
                        end
                        bB(R)
                    end
                end
                function cA:Get()
                    return cA.Value
                end
                if not isUnsupported then
                    bB(ak.Default)
                end
                return cA
            end
            function bq:CreateKeybind(ak)
                ak = ak or {}
                local bz = ak.Name or "Keybind"
                local l = ak.Flag or ""
                local bA = ak.Default or Enum.KeyCode.RightShift
                local bB = ak.Callback or function()
                    end
                local isUnsupported = ak.Unsupported or false
                local d6 = {}
                d6.Value = bA
                d6.Flag = l
                if l ~= "" then
                    k:SetValue(l, bA)
                    k:RegisterElement(l, d6)
                end
                local d7 = Instance.new("Frame")
                d7.Name = "Keybind"
                d7.Size = UDim2.new(1, 0, 0, 28)
                d7.BackgroundColor3 = af.ElementBg
                d7.BorderSizePixel = 0
                d7.Parent = bx
                N(d7, 6)
                Q(d7, af.Border, 1)
                local d8 = Instance.new("TextLabel")
                d8.Name = "Label"
                d8.Size = UDim2.new(1, -70, 1, 0)
                d8.Position = UDim2.new(0, 10, 0, 0)
                d8.BackgroundTransparency = 1
                d8.Text = bz
                d8.TextColor3 = af.Text
                d8.Font = aC.Font
                d8.TextSize = aC.FontSize
                d8.TextXAlignment = Enum.TextXAlignment.Left
                d8.Parent = d7
                local d9 = Instance.new("TextButton")
                d9.Name = "Button"
                d9.Size = UDim2.new(0, 55, 0, 18)
                d9.Position = UDim2.new(1, -65, 0.5, -9)
                d9.BackgroundColor3 = af.BackgroundDarker
                d9.BorderSizePixel = 0
                d9.Text = typeof(bA) == "string" and "None" or bA.Name
                d9.TextColor3 = af.Accent
                d9.Font = aC.Font
                d9.TextSize = aC.FontSize - 1
                d9.AutoButtonColor = false
                d9.Parent = d7
                table.insert(aC.AccentElements, {Type = "Text", Element = d9})
                N(d9, 4)
                local da = Q(d9, af.Border, 1)
                local db = false
                if not isUnsupported then
                    d7.MouseEnter:Connect(
                        function()
                            if not db then
                                B(d7, {BackgroundColor3 = af.ElementHover}, 0.1)
                            end
                        end
                    )
                    d7.MouseLeave:Connect(
                        function()
                            if not db then
                                B(d7, {BackgroundColor3 = af.ElementBg}, 0.1)
                            end
                        end
                    )
                    d9.MouseButton1Click:Connect(
                        function()
                            db = true
                            d9.Text = "..."
                            da.Color = af.Accent
                            d7.BackgroundColor3 = af.ElementHover
                        end
                    )
                    b.InputBegan:Connect(
                        function(a6, dc)
                            if db then
                                if a6.UserInputType == Enum.UserInputType.Keyboard then
                                    if a6.KeyCode == Enum.KeyCode.Escape then
                                        d6.Value = nil
                                        d9.Text = "None"
                                    elseif a6.KeyCode ~= Enum.KeyCode.Unknown then
                                        d6.Value = a6.KeyCode
                                        d9.Text = a6.KeyCode.Name
                                        if l ~= "" then
                                            k:SetValue(l, a6.KeyCode)
                                        end
                                    end
                                    da.Color = af.Border
                                    d7.BackgroundColor3 = af.ElementBg
                                    db = false
                                end
                            elseif not dc and a6.KeyCode == d6.Value then
                                bB()
                            end
                        end
                    )
                end
                if isUnsupported then
                    applyUnsupported(d7, d9)
                end
                function d6:Set(dd)
                    if not isUnsupported then
                        if typeof(dd) == "EnumItem" then
                            d6.Value = dd
                            d9.Text = dd.Name
                            if l ~= "" then
                                k:SetValue(l, dd)
                            end
                        elseif dd == nil then
                            d6.Value = nil
                            d9.Text = "None"
                        end
                    end
                end
                function d6:Get()
                    return d6.Value
                end
                return d6
            end
            function bq:CreateTextbox(ak)
                ak = ak or {}
                local bz = ak.Name or "Textbox"
                local l = ak.Flag or ""
                local bA = ak.Default or ""
                local de = ak.Placeholder or "Enter text..."
                local bB = ak.Callback or function()
                    end
                local isUnsupported = ak.Unsupported or false
                local df = {}
                df.Value = bA
                df.Flag = l
                if l ~= "" then
                    k:SetValue(l, bA)
                    k:RegisterElement(l, df)
                end
                local dg = Instance.new("Frame")
                dg.Name = "Textbox"
                dg.Size = UDim2.new(1, 0, 0, 28)
                dg.BackgroundColor3 = af.ElementBg
                dg.BorderSizePixel = 0
                dg.Parent = bx
                N(dg, 6)
                Q(dg, af.Border, 1)
                local dh = Instance.new("TextLabel")
                dh.Name = "Label"
                dh.Size = UDim2.new(0.4, 0, 1, 0)
                dh.Position = UDim2.new(0, 10, 0, 0)
                dh.BackgroundTransparency = 1
                dh.Text = bz
                dh.TextColor3 = af.Text
                dh.Font = aC.Font
                dh.TextSize = aC.FontSize
                dh.TextXAlignment = Enum.TextXAlignment.Left
                dh.Parent = dg
                local di = Instance.new("TextBox")
                di.Name = "Input"
                di.Size = UDim2.new(0.55, -10, 0, 18)
                di.Position = UDim2.new(0.45, 0, 0.5, -9)
                di.BackgroundColor3 = af.BackgroundDarker
                di.BorderSizePixel = 0
                di.Text = bA
                di.PlaceholderText = de
                di.TextColor3 = af.Text
                di.PlaceholderColor3 = af.TextMuted
                di.Font = aC.Font
                di.TextSize = aC.FontSize
                di.ClearTextOnFocus = false
                di.Parent = dg
                N(di, 4)
                local dj = Q(di, af.Border, 1)
                U(di, 6, 6, 0, 0)
                if not isUnsupported then
                    dg.MouseEnter:Connect(
                        function()
                            B(dg, {BackgroundColor3 = af.ElementHover}, 0.1)
                        end
                    )
                    dg.MouseLeave:Connect(
                        function()
                            B(dg, {BackgroundColor3 = af.ElementBg}, 0.1)
                        end
                    )
                    di.Focused:Connect(
                        function()
                            dj.Color = af.Accent
                        end
                    )
                    di.FocusLost:Connect(
                        function(dk)
                            dj.Color = af.Border
                            df.Value = di.Text
                            if l ~= "" then
                                k:SetValue(l, di.Text)
                            end
                            bB(di.Text, dk)
                        end
                    )
                end
                if isUnsupported then
                    applyUnsupported(dg, nil)
                    di.TextEditable = false
                end
                function df:Set(m)
                    if not isUnsupported then
                        df.Value = m
                        di.Text = m
                        if l ~= "" then
                            k:SetValue(l, m)
                        end
                        bB(m, false)
                    end
                end
                function df:Get()
                    return df.Value
                end
                return df
            end
            function bq:CreateLabel(bh)
                local dl = Instance.new("Frame")
                dl.Name = "Label"
                dl.Size = UDim2.new(1, 0, 0, 22)
                dl.BackgroundTransparency = 1
                dl.Parent = bx
                local dm = Instance.new("TextLabel")
                dm.Name = "Text"
                dm.Size = UDim2.new(1, 0, 1, 0)
                dm.BackgroundTransparency = 1
                dm.Text = bh or "Label"
                dm.TextColor3 = af.TextMuted
                dm.Font = aC.Font
                dm.TextSize = aC.FontSize
                dm.TextXAlignment = Enum.TextXAlignment.Left
                dm.Parent = dl
                local dn = {}
                function dn:Set(dp)
                    dm.Text = dp
                end
                return dn
            end
            function bq:CreateParagraph(ak)
                ak = ak or {}
                local al = ak.Title or "Title"
                local dq = ak.Content or "Content"
                local isUnsupported = ak.Unsupported or false
                local dr = Instance.new("Frame")
                dr.Name = "Paragraph"
                dr.Size = UDim2.new(1, 0, 0, 0)
                dr.AutomaticSize = Enum.AutomaticSize.Y
                dr.BackgroundColor3 = af.BackgroundDarker
                dr.BorderSizePixel = 0
                dr.Parent = bx
                N(dr, 6)
                Q(dr, af.Border, 1)
                local ds = Instance.new("UIListLayout")
                ds.SortOrder = Enum.SortOrder.LayoutOrder
                ds.Padding = UDim.new(0, 4)
                ds.Parent = dr
                U(dr, 10, 10, 8, 8)
                local dt = Instance.new("TextLabel")
                dt.Name = "Title"
                dt.Size = UDim2.new(1, 0, 0, 0)
                dt.AutomaticSize = Enum.AutomaticSize.Y
                dt.BackgroundTransparency = 1
                dt.Text = al
                dt.TextColor3 = af.Accent
                dt.Font = aC.Font
                dt.TextSize = aC.FontSize + 1
                dt.TextXAlignment = Enum.TextXAlignment.Left
                dt.TextWrapped = true
                dt.LayoutOrder = 1
                dt.Parent = dr
                table.insert(aC.AccentElements, {Type = "Text", Element = dt})
                local du = Instance.new("TextLabel")
                du.Name = "Content"
                du.Size = UDim2.new(1, 0, 0, 0)
                du.AutomaticSize = Enum.AutomaticSize.Y
                du.BackgroundTransparency = 1
                du.Text = dq
                du.TextColor3 = af.TextDark
                du.Font = aC.Font
                du.TextSize = aC.FontSize
                du.TextXAlignment = Enum.TextXAlignment.Left
                du.TextWrapped = true
                du.LayoutOrder = 2
                du.Parent = dr
                if isUnsupported then
                    applyUnsupported(dr, nil)
                end
                local dv = {}
                function dv:Set(ak)
                    if not isUnsupported then
                        if ak.Title then
                            dt.Text = ak.Title
                        end
                        if ak.Content then
                            du.Text = ak.Content
                        end
                    end
                end
                return dv
            end
            return bq
        end
        return b4
    end

    function aC:CreateSettingsTab()
        local SettingsTab = aC:CreateTab("Settings", "settings")
        
        local AppearanceSection = SettingsTab:CreateSection("Appearance")
        
        AppearanceSection:CreateColorpicker({
            Name = "Accent Color",
            Flag = "ui_accent_color",
            Default = af.Accent,
            Callback = function(color)
                aC:UpdateAccent(color)
            end
        })
        
        local fontNames = {}
        for _, fontData in ipairs(ag) do
            table.insert(fontNames, fontData.Name)
        end
        
        AppearanceSection:CreateDropdown({
            Name = "Font",
            Flag = "ui_font",
            Items = fontNames,
            Default = "Roboto Mono",
            Callback = function(selected)
                for _, fontData in ipairs(ag) do
                    if fontData.Name == selected then
                        aC:UpdateFont(fontData.Font)
                        break
                    end
                end
            end
        })
        
        AppearanceSection:CreateSlider({
            Name = "Font Size",
            Flag = "ui_font_size",
            Min = 10,
            Max = 18,
            Default = 14,
            Increment = 1,
            Suffix = "px",
            Callback = function(size)
                aC:UpdateFontSize(size)
            end
        })
        
        SettingsTab:AddDivider()
        
        local ConfigSection = SettingsTab:CreateSection("Configuration")
        
        local configSlotDropdown
        
        configSlotDropdown = ConfigSection:CreateDropdown({
            Name = "Selected Config",
            Items = k:GetConfigList(),
            Default = nil,
            Callback = function(slot)
                k.CurrentConfig = slot
            end
        })
        
        local configName = ''
        ConfigSection:CreateTextbox({
            Name = "New Config",
            Placeholder = "Config name...",
            Callback = function(text, enterPressed)
                if text ~= "" then
                    configName = text
                end
            end
        })
        
        ConfigSection:AddDivider()

        ConfigSection:CreateButton({
            Name = "Create Config",
            Icon = "folder-plus",
            Callback = function()
                if configName ~= '' then 
                    k.CurrentConfig = configName
                    local configs = k:GetConfigList()
                    if not table.find(configs, configName) then
                        table.insert(configs, configName)
                    end
                    configSlotDropdown:Refresh(configs)
                    configSlotDropdown:Set(configName)

                    aC:Notify({
                        Title = "Config Saved",
                        Description = "Configuration created successfully!",
                        Type = "success",
                        Duration = 3
                    })
                end 
            end
        })
        
        ConfigSection:CreateButton({
            Name = "Save Config",
            Icon = "save",
            Callback = function()
                if aC:SaveConfig() then
                    aC:Notify({
                        Title = "Config Saved",
                        Description = "Configuration saved successfully!",
                        Type = "success",
                        Duration = 3
                    })
                end
            end
        })
        
        ConfigSection:CreateButton({
            Name = "Load Config",
            Icon = "folder-open",
            Callback = function()
                if aC:LoadConfig() then
                    aC:Notify({
                        Title = "Config Loaded",
                        Description = "Configuration loaded successfully!",
                        Type = "success",
                        Duration = 3
                    })
                else
                    aC:Notify({
                        Title = "Load Failed",
                        Description = "Could not load configuration",
                        Type = "error",
                        Duration = 3
                    })
                end
            end
        })
        
        ConfigSection:CreateButton({
            Name = "Delete Config",
            Icon = "trash-2",
            Callback = function()
                if aC:DeleteConfig(k.CurrentConfig) then
                    aC:Notify({
                        Title = "Config Deleted",
                        Description = "Configuration deleted!",
                        Type = "warning",
                        Duration = 3
                    })
                    configSlotDropdown:Refresh(k:GetConfigList())
                end
            end
        })
        
        SettingsTab:AddDivider()
        
        local MiscSection = SettingsTab:CreateSection("Miscellaneous")
        
        MiscSection:CreateKeybind({
            Name = "Toggle UI",
            Flag = "ui_toggle_key",
            Default = Enum.KeyCode.RightShift,
            Callback = function()
                aC.ScreenGui.Enabled = not aC.ScreenGui.Enabled
            end
        })
        
        MiscSection:AddDivider()
        
        MiscSection:CreateButton({
            Name = "Unload",
            Icon = "power",
            Callback = function()
                aC.ScreenGui:Destroy()
            end
        })
        
        return SettingsTab
    end

    return aC
end

return a
