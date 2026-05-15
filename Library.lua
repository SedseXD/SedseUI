--[[ 
    MONOLITH FINGERPAINT LIBRARY (V9 - Final Optimized Build)
    Designed for: loadstring execution
]]

local uis = game:GetService("UserInputService") 
local tween_service = game:GetService("TweenService")
local http_service = game:GetService("HttpService")
local gui_service = game:GetService("GuiService")

-- 1. FIRST: Define helper functions that everything else depends on
local function get_ui_parent()
    local success, parent = pcall(function() return gethui and gethui() end)
    if success and parent then return parent end
    success, parent = pcall(function() return game:GetService("CoreGui") end)
    if success and parent then return parent end
    return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

-- 2. SECOND: Define the library table and state before adding functions to it
local library = {
    font = Font.new("rbxassetid://12187375716", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
}
library.__index = library

local connections = {}
local function track_connection(conn)
    if conn then table.insert(connections, conn) end
    return conn
end

-- 3. THIRD: Define the Unload/Cleanup logic
function library:Unload()
    -- Disconnect all UIS listeners
    for _, conn in ipairs(connections) do
        if conn then conn:Disconnect() end
    end
    table.clear(connections)

    -- Destroy UI
    local parent = get_ui_parent()
    if parent:FindFirstChild("MonolithUI") then parent.MonolithUI:Destroy() end
    if parent:FindFirstChild("MonolithNotifs") then parent.MonolithNotifs:Destroy() end
    
    print("Monolith Library Unloaded Successfully")
end

local function global_cleanup()
    local parent = get_ui_parent()
    if parent:FindFirstChild("MonolithUI") then parent.MonolithUI:Destroy() end
    if parent:FindFirstChild("MonolithNotifs") then parent.MonolithNotifs:Destroy() end
end

-- Run cleanup immediately on script start (for re-runs)
global_cleanup()

-- Shorthands & Theme
local dim2 = UDim2.new
local dim = UDim.new 
local rgb = Color3.fromRGB
local ui_parent = get_ui_parent()

local Theme = {
    MainBG = rgb(15, 15, 15),
    SidebarBG = rgb(18, 18, 18),
    TopbarBG = rgb(18, 18, 18),
    SectionBG = rgb(22, 22, 22),
    ElementBG = rgb(30, 30, 30),
    HoverBG = rgb(40, 40, 40),
    Accent = rgb(100, 150, 255),
    Text = rgb(240, 240, 240),
    MutedText = rgb(150, 150, 150),
    Outline = rgb(45, 45, 45)
}

-- Utility Functions
function library:tween(obj, props, time) 
    local t = tween_service:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

function library:create(class, props)
    local ins = Instance.new(class)
    for k, v in pairs(props) do ins[k] = v end
    return ins
end

function library:draggify(frame, drag_area)
    local dragging, startPos, startInput
    (drag_area or frame).InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; startInput = input.Position; startPos = frame.Position
        end
    end)
    -- TRACKED CONNECTION
    track_connection(uis.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            frame.Position = dim2(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
    -- TRACKED CONNECTION
    track_connection(uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
end

-- Notification Container Setup
local notif_screen = library:create("ScreenGui", {Parent = ui_parent, Name = "MonolithNotifs"})
local notif_container = library:create("Frame", {
    Parent = notif_screen, 
    Size = dim2(0, 300, 1, 0), 
    Position = dim2(1, -310, 0, 0), 
    BackgroundTransparency = 1
})
library:create("UIListLayout", {
    Parent = notif_container, 
    Padding = dim(0, 10), 
    VerticalAlignment = Enum.VerticalAlignment.Bottom, 
    HorizontalAlignment = Enum.HorizontalAlignment.Right
})
library:create("UIPadding", {Parent = notif_container, PaddingBottom = dim(0, 20), PaddingRight = dim(0, 10)})

-- Safe Lazy-Load Lucide Icons
local Icons
task.spawn(function()
    pcall(function()
        Icons = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
        if Icons then Icons.SetIconsType("lucide") end
    end)
end)

local function get_icon(iconName, color)
    if not iconName then return nil end
    local isAsset = iconName:match("^rbxassetid://") or iconName:match("^%d+$")
    if isAsset then
        local img = Instance.new("ImageLabel")
        img.BackgroundTransparency = 1
        img.Image = iconName:match("^%d+$") and "rbxassetid://"..iconName or iconName
        img.ImageColor3 = color or Color3.fromRGB(255, 255, 255)
        return img
    end
    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    task.spawn(function()
        local waited = 0
        while not Icons and waited < 5 do task.wait(0.1); waited = waited + 0.1 end
        if Icons then
            local iconStr = iconName:gsub("^lucide:", "")
            local ok, iconObj = pcall(function() return Icons.Image({ Icon = iconStr, Colors = {color or Color3.fromRGB(255, 255, 255)} }) end)
            if ok and iconObj and iconObj.IconFrame then
                iconObj.IconFrame.BackgroundTransparency = 1
                iconObj.IconFrame.Size = UDim2.new(1, 0, 1, 0)
                iconObj.IconFrame.Parent = holder
            end
        end
    end)
    return holder
end

local function color_icon(iconInstance, color)
    if not iconInstance then return end
    for _, v in pairs(iconInstance:GetDescendants()) do
        if v:IsA("ImageLabel") then
            tween_service:Create(v, TweenInfo.new(0.15), {ImageColor3 = color}):Play()
        end
    end
end

local function PremiumOverlay(parent)
    local overlay = library:create("Frame", { Parent = parent, Size = dim2(1, 0, 1, 0), BackgroundColor3 = Theme.MainBG, BackgroundTransparency = 0.3, ZIndex = 10 })
    library:create("UICorner", {Parent = overlay, CornerRadius = dim(0, 6)})
    local lock = get_icon("lucide:lock", Theme.Accent)
    if lock then lock.Parent = overlay; lock.AnchorPoint = Vector2.new(0.5, 0.5); lock.Position = dim2(0.5, 0, 0.5, 0); lock.Size = dim2(0, 16, 0, 16); lock.ZIndex = 11 end
    library:create("TextButton", { Parent = overlay, Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 12 })
end

-- LOADING ANIMATION LOGIC
local function BootSequence(windowFrame, windowName)
    local main = library:create("Frame", {
        Parent = windowFrame, Size = dim2(1, 0, 1, 0), BackgroundColor3 = rgb(0, 0, 0), 
        ZIndex = 1000, BorderSizePixel = 0
    })
    local logo = library:create("TextLabel", {
        Parent = main, Text = windowName, Position = dim2(0.5, 0, 0.4, 0), AnchorPoint = Vector2.new(0.5, 0.5),
        Size = dim2(0, 200, 0, 50), BackgroundTransparency = 1, TextColor3 = Theme.Text,
        FontFace = library.font, TextSize = 32, TextTransparency = 1, ZIndex = 1001
    })
    local barBg = library:create("Frame", {
        Parent = main, Size = dim2(0, 200, 0, 4), Position = dim2(0.5, 0, 0.6, 0), AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, ZIndex = 1001
    })
    library:create("UICorner", {Parent = barBg})
    local barFill = library:create("Frame", {
        Parent = barBg, Size = dim2(0, 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, ZIndex = 1002
    })
    library:create("UICorner", {Parent = barFill})
    local status = library:create("TextLabel", {
        Parent = main, Text = "Initializing...", Position = dim2(0.5, 0, 0.65, 0), AnchorPoint = Vector2.new(0.5, 0.5),
        Size = dim2(0, 200, 0, 20), BackgroundTransparency = 1, TextColor3 = Theme.MutedText,
        FontFace = library.font, TextSize = 14, TextTransparency = 1, ZIndex = 1001
    })

    return coroutine.wrap(function()
        library:tween(logo, {TextTransparency = 0}, 1)
        task.wait(0.5)
        library:tween(status, {TextTransparency = 0}, 0.5)
        local steps = {"Loading Core...", "Fetching Assets...", "Applying Theme...", "Finalizing..."}
        for i, step in ipairs(steps) do
            status.Text = step
            library:tween(barFill, {Size = dim2(i/ #steps, 0, 1, 0)}, 0.5)
            task.wait(0.6)
        end
        library:tween(logo, {TextTransparency = 1}, 0.5)
        library:tween(status, {TextTransparency = 1}, 0.5)
        library:tween(barFill, {BackgroundTransparency = 1}, 0.3)
        library:tween(barBg, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.5)
        local fadeOut = library:tween(main, {BackgroundTransparency = 1}, 1)
        fadeOut.Completed:Connect(function() main:Destroy() end)
        task.wait(1)
    end)
end

-- Window System
function library:window(props)
    local win = { items = {}, tabs = {} }
    local screen = library:create("ScreenGui", {Parent = ui_parent, Name = "MonolithUI", ResetOnSpawn = false})
    local main = library:create("Frame", {
        Parent = screen, Size = dim2(0, 650, 0, 450), Position = dim2(0.5, -325, 0.5, -225),
        BackgroundColor3 = Theme.MainBG, BorderSizePixel = 0
    })
    library:create("UICorner", {Parent = main, CornerRadius = dim(0, 8)})
    library:create("UIStroke", {Parent = main, Color = Theme.Outline, Thickness = 1})

    local topbar = library:create("Frame", { Parent = main, Size = dim2(1, 0, 0, 40), BackgroundColor3 = Theme.TopbarBG, BorderSizePixel = 0 })
    library:create("UICorner", {Parent = topbar, CornerRadius = dim(0, 8)})
    local topbar_filler = library:create("Frame", {Parent = topbar, Size = dim2(1, 0, 0, 10), Position = dim2(0, 0, 1, -10), BackgroundColor3 = Theme.TopbarBG, BorderSizePixel = 0}) 
    library:create("Frame", {Parent = topbar, Size = dim2(1, 0, 0, 1), Position = dim2(0, 0, 1, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0}) 
    library:draggify(main, topbar)

    local winIcon = get_icon(props.Icon or props.icon or "lucide:layout-dashboard", Theme.Text)
    if winIcon then winIcon.Size = dim2(0, 18, 0, 18); winIcon.Position = dim2(0, 12, 0.5, 0); winIcon.AnchorPoint = Vector2.new(0, 0.5); winIcon.Parent = topbar end
    local titleOff = winIcon and 38 or 12

    library:create("TextLabel", {
        Parent = topbar, Text = (props.name or props.Name or "Nebula UI"), Size = dim2(1, -(titleOff + 80), 1, 0), Position = dim2(0, titleOff, 0, 0),
        BackgroundTransparency = 1, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = library.font, TextSize = 18
    })

    local minBtn = library:create("TextButton", { Parent = topbar, Size = dim2(0, 30, 0, 24), Position = dim2(1, -70, 0.5, -12), BackgroundColor3 = Theme.TopbarBG, Text = "", AutoButtonColor = false })
    library:create("UICorner", {Parent = minBtn, CornerRadius = dim(0, 4)})
    local minIconObj = get_icon("lucide:minus", Theme.MutedText)
    if minIconObj then minIconObj.Size = dim2(0, 14, 0, 14); minIconObj.Position = dim2(0.5, 0, 0.5, 0); minIconObj.AnchorPoint = Vector2.new(0.5, 0.5); minIconObj.Parent = minBtn end

    local closeBtn = library:create("TextButton", { Parent = topbar, Size = dim2(0, 30, 0, 24), Position = dim2(1, -36, 0.5, -12), BackgroundColor3 = Theme.TopbarBG, Text = "", AutoButtonColor = false })
    library:create("UICorner", {Parent = closeBtn, CornerRadius = dim(0, 4)})
    local closeIconObj = get_icon("lucide:x", Theme.MutedText)
    if closeIconObj then closeIconObj.Size = dim2(0, 14, 0, 14); closeIconObj.Position = dim2(0.5, 0, 0.5, 0); closeIconObj.AnchorPoint = Vector2.new(0.5, 0.5); closeIconObj.Parent = closeBtn end

    minBtn.MouseEnter:Connect(function() library:tween(minBtn, {BackgroundColor3 = Theme.HoverBG}, 0.15); color_icon(minIconObj, Theme.Text) end)
    minBtn.MouseLeave:Connect(function() library:tween(minBtn, {BackgroundColor3 = Theme.TopbarBG}, 0.15); color_icon(minIconObj, Theme.MutedText) end)
    closeBtn.MouseEnter:Connect(function() library:tween(closeBtn, {BackgroundColor3 = rgb(200, 50, 50)}, 0.15); color_icon(closeIconObj, Theme.Text) end)
    closeBtn.MouseLeave:Connect(function() library:tween(closeBtn, {BackgroundColor3 = Theme.TopbarBG}, 0.15); color_icon(closeIconObj, Theme.MutedText) end)
    closeBtn.MouseButton1Click:Connect(function() screen:Destroy() end)

    local sidebar = library:create("ScrollingFrame", { 
    Parent = main, 
    Position = dim2(0, 0, 0, 41), 
    Size = dim2(0, 140, 1, -41), 
    BackgroundColor3 = Theme.SidebarBG, 
    BorderSizePixel = 0,
    -- Scrolling Properties
    ScrollBarThickness = 2, -- Make it thin for a clean look
    ScrollBarImageColor3 = Theme.Outline,
    CanvasSize = dim2(0, 0, 0, 0), 
    AutomaticCanvasSize = Enum.AutomaticSize.Y, -- This allows the scroll wheel to work as you add tabs
    ZIndex = 1
})
    -- This replaces the "Frame" border with a fixed UIStroke
library:create("UIStroke", {
    Parent = sidebar, 
    Color = Theme.Outline, 
    Thickness = 1, 
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
})
    local page_holder = library:create("Frame", { Parent = main, Position = dim2(0, 141, 0, 41), Size = dim2(1, -141, 1, -41), BackgroundTransparency = 1 })
    library:create("UIListLayout", {Parent = sidebar, Padding = dim(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center})
    library:create("UIPadding", {Parent = sidebar, PaddingTop = dim(0, 10)})
    local all_toggles = {}
    local toggleKey = Enum.KeyCode.RightControl
    local resizeHandle = library:create("TextButton", { Parent = main, Size = dim2(0, 20, 0, 20), Position = dim2(1, -20, 1, -20), BackgroundTransparency = 1, Text = "↘", TextColor3 = Theme.MutedText, TextSize = 14, FontFace = library.font, ZIndex = 100 })
    local resizing, rStartPos, rStartSize
    resizeHandle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = true; rStartPos = input.Position; rStartSize = main.Size end end)
    -- TRACKED CONNECTION
    track_connection(uis.InputChanged:Connect(function(input) if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - rStartPos; main.Size = dim2(0, math.max(450, rStartSize.X.Offset + delta.X), 0, math.max(300, rStartSize.Y.Offset + delta.Y)) end end))
    -- TRACKED CONNECTION
    track_connection(uis.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end end))

    local isMinimized = false
    local savedSize = main.Size
    minBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            savedSize = main.Size; resizeHandle.Visible = false; sidebar.Visible = false; page_holder.Visible = false; topbar_filler.Visible = false
            library:tween(main, {Size = dim2(0, savedSize.X.Offset, 0, 40)}, 0.25)
        else
            topbar_filler.Visible = true
            local t = library:tween(main, {Size = savedSize}, 0.25)
            t.Completed:Connect(function() if not isMinimized then sidebar.Visible = true; page_holder.Visible = true; resizeHandle.Visible = true end end)
        end
    end)

    win.toggle_menu = function(a, b) 
        local state = (type(a) == "boolean") and a or b; if state == nil then state = not main.Visible end; main.Visible = state
    end
    -- TRACKED CONNECTION
    local toggleKey = Enum.KeyCode.RightControl
track_connection(uis.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == toggleKey then win.toggle_menu() end
end))

    if props.Loading then
        local bootCoroutine = BootSequence(main, props.name or "Nebula UI")
        bootCoroutine()
    end

    function win:Tab(props)
        local tab = { name = props.name or props.Name or "Tab" }
        local btn = library:create("TextButton", { Parent = sidebar, Size = dim2(1, -16, 0, 32), BackgroundColor3 = Theme.MainBG, Text = "", AutoButtonColor = false })
        library:create("UICorner", {Parent = btn, CornerRadius = dim(0, 6)}); library:create("UIStroke", {Parent = btn, Color = Theme.Outline, Thickness = 1})
        local tIcon = get_icon(props.Icon or props.icon or "lucide:folder", Theme.MutedText)
        if tIcon then tIcon.Size = dim2(0, 16, 0, 16); tIcon.Position = dim2(0, 10, 0.5, 0); tIcon.AnchorPoint = Vector2.new(0, 0.5); tIcon.Parent = btn end
        local tOff = tIcon and 34 or 10
        local tLabel = library:create("TextLabel", { Parent = btn, Text = tab.name, Size = dim2(1, -tOff, 1, 0), Position = dim2(0, tOff, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.MutedText, TextXAlignment = Enum.TextXAlignment.Left, FontFace = library.font, TextSize = 13 })

        local page = library:create("ScrollingFrame", { Parent = page_holder, Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y })
        library:create("UIListLayout", {Parent = page, FillDirection = Enum.FillDirection.Horizontal, Padding = dim(0, 15), SortOrder = Enum.SortOrder.LayoutOrder})
        library:create("UIPadding", {Parent = page, PaddingLeft = dim(0, 15), PaddingRight = dim(0, 15), PaddingTop = dim(0, 15), PaddingBottom = dim(0, 15)})

        local left_col = library:create("Frame", { Parent = page, Size = dim2(0.5, -8, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
        library:create("UIListLayout", {Parent = left_col, Padding = dim(0, 10)})
        local right_col = library:create("Frame", { Parent = page, Size = dim2(0.5, -8, 0, 0), Position = dim2(0.5, 8, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
        library:create("UIListLayout", {Parent = right_col, Padding = dim(0, 10)})

        if #win.tabs == 0 then
            page.Visible = true; tLabel.TextColor3 = Theme.Text; btn.BackgroundColor3 = Theme.ElementBG; color_icon(tIcon, Theme.Text)
        end
        table.insert(win.tabs, {btn = btn, page = page, label = tLabel, icon = tIcon})

        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(win.tabs) do 
                t.page.Visible = false; t.label.TextColor3 = Theme.MutedText; color_icon(t.icon, Theme.MutedText)
                library:tween(t.btn, {BackgroundColor3 = Theme.MainBG}, 0.15)
            end
            page.Visible = true; tLabel.TextColor3 = Theme.Text; color_icon(tIcon, Theme.Text)
            library:tween(btn, {BackgroundColor3 = Theme.ElementBG}, 0.15)
        end)

        local section_api = {}
        function section_api:Label(p)
            local l = library:create("TextLabel", { Parent = p.Parent or self.elements, Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, Text = p.name or p.Name or "Label", TextColor3 = Theme.MutedText, FontFace = library.font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y })
            return { instance = l, set = function(txt) l.Text = txt end }
        end
        function section_api:Button(p)
            local b = library:create("TextButton", { Parent = p.Parent or self.elements, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = " " .. (p.name or p.Name or "Button"), TextColor3 = Theme.Text, FontFace = library.font, TextSize = 13, AutoButtonColor = false })
            library:create("UICorner", {Parent = b, CornerRadius = dim(0, 6)}); library:create("UIStroke", {Parent = b, Color = Theme.Outline, Thickness = 1})
            if p.Premium or p.premium then PremiumOverlay(b) end
            b.MouseButton1Click:Connect(function() library:tween(b, {BackgroundColor3 = Theme.HoverBG}, 0.1); task.wait(0.1); library:tween(b, {BackgroundColor3 = Theme.ElementBG}, 0.1); if p.Callback then p.Callback() end end)
            return {}
        end
        function section_api:Toggle(p)
    local tog = { enabled = p.default or false }
    local tog_key = Enum.KeyCode.Unknown
    local tog_picking = false

    local holder = library:create("Frame", {
        Parent = p.Parent or self.elements,
        Size = dim2(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    library:create("UIListLayout", { Parent = holder, Padding = dim(0, 6) })

    -- Row: [KB][  Toggle Name ──────── ■ ]
    local row = library:create("Frame", {
        Parent = holder,
        Size = dim2(1, 0, 0, 32),
        BackgroundTransparency = 1
    })

    local kbBtn = library:create("TextButton", {
        Parent = row,
        Size = dim2(0, 32, 1, 0),
        BackgroundColor3 = Theme.ElementBG,
        Text = "[?]",
        TextColor3 = Theme.MutedText,
        FontFace = library.font,
        TextSize = 9,
        AutoButtonColor = false
    })
    library:create("UICorner", { Parent = kbBtn, CornerRadius = dim(0, 6) })
    library:create("UIStroke", { Parent = kbBtn, Color = Theme.Outline, Thickness = 1 })

    local btn = library:create("TextButton", {
        Parent = row,
        Size = dim2(1, -38, 1, 0),
        Position = dim2(0, 38, 0, 0),
        BackgroundColor3 = Theme.ElementBG,
        Text = "  " .. (p.name or p.Name or "Toggle"),
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = library.font,
        TextSize = 13,
        AutoButtonColor = false
    })
    library:create("UICorner", { Parent = btn, CornerRadius = dim(0, 6) })
    library:create("UIStroke", { Parent = btn, Color = Theme.Outline, Thickness = 1 })

    if p.Premium or p.premium then PremiumOverlay(btn) end

    local indicator = library:create("Frame", {
        Parent = btn,
        Size = dim2(0, 16, 0, 16),
        Position = dim2(1, -24, 0.5, -8),
        BackgroundColor3 = tog.enabled and Theme.Accent or Theme.MainBG
    })
    library:create("UICorner", { Parent = indicator, CornerRadius = dim(0, 4) })
    library:create("UIStroke", { Parent = indicator, Color = Theme.Outline, Thickness = 1 })

    local container = library:create("Frame", {
        Parent = holder,
        Size = dim2(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Visible = tog.enabled,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    library:create("UIListLayout", { Parent = container, Padding = dim(0, 6) })
    library:create("UIPadding", { Parent = container, PaddingLeft = dim(0, 14) })

    -- Central fire function used by click, keybind, AND float button
    local function fire_toggle()
        tog.enabled = not tog.enabled
        container.Visible = tog.enabled
        library:tween(indicator, { BackgroundColor3 = tog.enabled and Theme.Accent or Theme.MainBG }, 0.2)
        if p.Callback then p.Callback(tog.enabled) end
    end

    btn.MouseButton1Click:Connect(fire_toggle)

    -- Keybind picking
    kbBtn.MouseButton1Click:Connect(function()
        tog_picking = true
        kbBtn.Text = "···"
        library:tween(kbBtn, { BackgroundColor3 = Theme.HoverBG }, 0.15)
    end)

    track_connection(uis.InputBegan:Connect(function(input, gpe)
        if tog_picking and input.UserInputType == Enum.UserInputType.Keyboard then
            tog_picking = false
            tog_key = input.KeyCode
            local n = tog_key.Name
            kbBtn.Text = #n > 4 and n:sub(1, 4) or n
            library:tween(kbBtn, { BackgroundColor3 = Theme.ElementBG }, 0.15)
        elseif not gpe and tog_key ~= Enum.KeyCode.Unknown and input.KeyCode == tog_key then
            fire_toggle()
        end
    end))

    -- Register in the global toggle list for mobile float buttons
    local tog_entry = {
        name = p.name or p.Name or "Toggle",
        fire = fire_toggle,
        tog = tog,
        float_btn = nil
    }
    table.insert(all_toggles, tog_entry)

    function tog:Slider(np) np = np or {}; np.Parent = container; return section_api:Slider(np) end
    function tog:Dropdown(np) np = np or {}; np.Parent = container; return section_api:Dropdown(np) end
    function tog:Colorpicker(np) np = np or {}; np.Parent = container; return section_api:Colorpicker(np) end
    function tog:Keybind(np) np = np or {}; np.Parent = container; return section_api:Keybind(np) end
    function tog:set(state)
        tog.enabled = state
        container.Visible = state
        library:tween(indicator, { BackgroundColor3 = state and Theme.Accent or Theme.MainBG }, 0.2)
        if p.Callback then p.Callback(state) end
    end
    return tog
end
        function section_api:Dropdown(p)
            local isMulti = p.multi or p.Multi
            local selected = isMulti and (p.default or {}) or (p.default or (p.items and p.items[1]) or "None")
            local open = false
            local holder = library:create("Frame", { Parent = p.Parent or self.elements, Size = dim2(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
            
            library:create("UIListLayout", {Parent = holder, Padding = dim(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
            
            local function get_val_str() return isMulti and (#selected > 0 and table.concat(selected, ", ") or "None") or selected end
            
            local btn = library:create("TextButton", { Parent = holder, LayoutOrder = 1, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = "  " .. (p.Name or p.name or "Dropdown") .. " : " .. get_val_str(), TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = library.font, TextSize = 13, AutoButtonColor=false })
            library:create("UICorner", {Parent = btn, CornerRadius = dim(0, 6)}); library:create("UIStroke", {Parent = btn, Color = Theme.Outline, Thickness = 1})
            if p.Premium or p.premium then PremiumOverlay(btn) end
            
            local iconDown = get_icon("lucide:chevron-down", Theme.MutedText)
            local iconUp = get_icon("lucide:chevron-up", Theme.MutedText)
            
            if iconDown and iconUp then
                iconDown.Size = dim2(0, 16, 0, 16)
                iconDown.Position = dim2(1, -26, 0.5, 0)
                iconDown.AnchorPoint = Vector2.new(0, 0.5)
                iconDown.Parent = btn
                iconDown.Visible = true
                iconUp.Size = dim2(0, 16, 0, 16)
                iconUp.Position = dim2(1, -26, 0.5, 0)
                iconUp.AnchorPoint = Vector2.new(0, 0.5)
                iconUp.Parent = btn
                iconUp.Visible = false
            end
            
            local container = library:create("Frame", { Parent = holder, LayoutOrder = 2, Size = dim2(1, 0, 0, 0), BackgroundTransparency = 1, Visible = false, AutomaticSize = Enum.AutomaticSize.Y })
            
            library:create("UIListLayout", {Parent = container, Padding = dim(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
            library:create("UIPadding", {Parent = container, PaddingLeft = dim(0, 8)})
            
            local searchBox = library:create("TextBox", { Parent = container, LayoutOrder = 1, Size = dim2(1, 0, 0, 28), BackgroundColor3 = Theme.MainBG, TextColor3 = Theme.Text, PlaceholderText = "Search...", PlaceholderColor3 = Theme.MutedText, FontFace = library.font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Text = "" })
            library:create("UICorner", {Parent = searchBox, CornerRadius = dim(0, 4)}); library:create("UIPadding", {Parent = searchBox, PaddingLeft = dim(0, 8)})
            
            local itemBtns = {}
            
            local function updateItems()
                for _, iBtn in pairs(itemBtns) do
                    local isSel = isMulti and table.find(selected, iBtn.name) or (selected == iBtn.name)
                    iBtn.btn.BackgroundColor3 = isSel and Theme.Accent or Theme.HoverBG
                    iBtn.btn.TextColor3 = isSel and Theme.MainBG or Theme.MutedText
                end
                btn.Text = "  " .. (p.Name or p.name or "Dropdown") .. " : " .. get_val_str()
            end
            
            btn.MouseButton1Click:Connect(function() 
                open = not open; 
                container.Visible = open 
                if iconDown and iconUp then
                    iconDown.Visible = not open
                    iconUp.Visible = open
                end
            end)
            
            local function build_items(itemList)
                for _, iBtn in pairs(itemBtns) do iBtn.btn:Destroy() end
                itemBtns = {}
                
                if not isMulti then
                    if not table.find(itemList, selected) then 
                        selected = itemList[1] or "None" 
                        if p.Callback then p.Callback(selected) end
                    end
                end

                for index, item in pairs(itemList or {}) do
                    local ibtn = library:create("TextButton", { Parent = container, LayoutOrder = index + 1, Size = dim2(1, 0, 0, 26), BackgroundColor3 = Theme.HoverBG, Text = "  " .. item, TextColor3 = Theme.MutedText, TextXAlignment = Enum.TextXAlignment.Left, FontFace = library.font, TextSize = 12, AutoButtonColor = false })
                    library:create("UICorner", {Parent = ibtn, CornerRadius = dim(0, 6)}); table.insert(itemBtns, {btn = ibtn, name = item})
                    
                    ibtn.MouseButton1Click:Connect(function()
                        if isMulti then 
                            local idx = table.find(selected, item); 
                            if idx then table.remove(selected, idx) else table.insert(selected, item) end 
                        else 
                            selected = item; 
                            open = false; 
                            container.Visible = false 
                            if iconDown and iconUp then
                                iconDown.Visible = true
                                iconUp.Visible = false
                            end
                        end
                        updateItems(); if p.Callback then p.Callback(selected) end
                    end)
                end
                updateItems()
            end

            build_items(p.items or {})

            searchBox:GetPropertyChangedSignal("Text"):Connect(function() 
                local q = searchBox.Text:lower(); 
                for _, iBtn in pairs(itemBtns) do iBtn.btn.Visible = (q == "" or iBtn.name:lower():find(q) ~= nil) end 
            end)
            
            return {
                set_items = function(self, new_items)
                    build_items(new_items)
                end,
                set_value = function(self, val)
                    selected = val
                    updateItems()
                    if p.Callback then p.Callback(selected) end
                end
            }
        end

        function section_api:Colorpicker(p)
            local open = false
            local color = p.default or rgb(255, 0, 0)
            local h, s, v = color:ToHSV()
            local holder = library:create("Frame", { Parent = p.Parent or self.elements, Size = dim2(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
            library:create("UIListLayout", {Parent = holder, Padding = dim(0, 4)})
            local btn = library:create("TextButton", { Parent = holder, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = "  " .. (p.Name or p.name or "Colorpicker"), TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = library.font, TextSize = 13, AutoButtonColor=false })
            library:create("UICorner", {Parent = btn, CornerRadius = dim(0, 6)}); library:create("UIStroke", {Parent = btn, Color = Theme.Outline, Thickness = 1})
            if p.Premium or p.premium then PremiumOverlay(btn) end
            local disp = library:create("Frame", { Parent = btn, Size = dim2(0, 20, 0, 16), Position = dim2(1, -28, 0.5, -8), BackgroundColor3 = color })
            library:create("UICorner", {Parent = disp, CornerRadius = dim(0, 4)})
            local container = library:create("Frame", { Parent = holder, Size = dim2(1, 0, 0, 130), BackgroundTransparency = 1, Visible = false })
            local wheelBg = library:create("Frame", {Parent = container, Size = dim2(1, 0, 1, 0), BackgroundColor3 = Theme.SectionBG})
            library:create("UICorner", {Parent = wheelBg, CornerRadius = dim(0, 6)})
            local wheel = library:create("ImageButton", { Parent = wheelBg, Size = dim2(0, 100, 0, 100), Position = dim2(0, 10, 0, 10), BackgroundTransparency = 1, Image = "rbxassetid://6020299385" })
            local pickerDot = library:create("ImageLabel", { Parent = wheel, Size = dim2(0, 12, 0, 12), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://3678860011" })
            local valSlider = library:create("TextButton", { Parent = wheelBg, Size = dim2(0, 15, 0, 100), Position = dim2(0, 120, 0, 10), BackgroundColor3 = rgb(255, 255, 255), Text = "", AutoButtonColor = false })
            library:create("UICorner", {Parent = valSlider, CornerRadius = dim(0, 4)})
            local valGrad = library:create("UIGradient", { Parent = valSlider, Rotation = 90, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromHSV(h,s,1)), ColorSequenceKeypoint.new(1, rgb(0,0,0))} })
            local valIndicator = library:create("Frame", { Parent = valSlider, Size = dim2(1, 4, 0, 4), Position = dim2(0.5, 0, 1-v, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.Text, BorderSizePixel = 0 })

            btn.MouseButton1Click:Connect(function() open = not open; container.Visible = open end)
            local function update_color()
                local finalColor = Color3.fromHSV(h, s, v)
                disp.BackgroundColor3 = finalColor
                valGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromHSV(h,s,1)), ColorSequenceKeypoint.new(1, rgb(0,0,0))}
                if p.Callback then p.Callback(finalColor) end
            end

            local angle = (h * math.pi * 2) - (math.pi / 2)
            pickerDot.Position = dim2(0.5 + math.cos(angle) * 0.5 * s, 0, 0.5 + math.sin(angle) * 0.5 * s, 0)

            local draggingWheel, draggingVal = false, false
            local inset = gui_service:GetGuiInset()
            wheel.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingWheel = true end end)
            valSlider.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingVal = true end end)
            -- TRACKED CONNECTION
            track_connection(uis.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingWheel = false; draggingVal = false end end))
            -- TRACKED CONNECTION
            track_connection(uis.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    local mLoc = uis:GetMouseLocation()
                    local correctedMouse = Vector2.new(mLoc.X, mLoc.Y - inset.Y)
                    if draggingWheel then
                        local wheelCenter = wheel.AbsolutePosition + (wheel.AbsoluteSize / 2)
                        local offset = correctedMouse - wheelCenter
                        local rad = wheel.AbsoluteSize.X / 2
                        if offset.Magnitude > rad then offset = offset.Unit * rad end
                        pickerDot.Position = dim2(0.5 + (offset.X / wheel.AbsoluteSize.X), 0, 0.5 + (offset.Y / wheel.AbsoluteSize.Y), 0)
                        local angle = math.atan2(-offset.Y, offset.X)
                        h = (angle / (math.pi * 2)) + 0.5
                        h = h % 1; s = offset.Magnitude / rad; update_color()
                    elseif draggingVal then
                        local relativeY = correctedMouse.Y - valSlider.AbsolutePosition.Y
                        local clampedY = math.clamp(relativeY, 0, valSlider.AbsoluteSize.Y)
                        valIndicator.Position = dim2(0.5, 0, 0, clampedY); v = 1 - (clampedY / valSlider.AbsoluteSize.Y); update_color()
                    end
                end
            end))
            return {
                set = function(self, new_color)
                    h, s, v = new_color:ToHSV()
                    update_color()
                    local angle = (h * math.pi * 2) - (math.pi / 2)
                    pickerDot.Position = dim2(0.5 + math.cos(angle) * 0.5 * s, 0, 0.5 + math.sin(angle) * 0.5 * s, 0)
                    local hY = valSlider.AbsoluteSize.Y > 0 and valSlider.AbsoluteSize.Y or 100
                    valIndicator.Position = dim2(0.5, 0, 0, (1-v) * hY)
                end
            }
        end

        function section_api:Keybind(p)
    local key = p.default or Enum.KeyCode.Unknown
    local btn = library:create("TextButton", { Parent = p.Parent or self.elements, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = "  " .. (p.Name or p.name or "Keybind") .. " : [" .. key.Name .. "]", TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = library.font, TextSize = 13, AutoButtonColor=false })
    library:create("UICorner", {Parent = btn, CornerRadius = dim(0, 6)}); library:create("UIStroke", {Parent = btn, Color = Theme.Outline, Thickness = 1})
    if p.Premium or p.premium then PremiumOverlay(btn) end
    local picking = false
    btn.MouseButton1Click:Connect(function() 
        picking = true
        btn.Text = "  " .. (p.Name or p.name or "Keybind") .. " : [...]" 
    end)
    track_connection(uis.InputBegan:Connect(function(input, gpe)
        if picking and input.UserInputType == Enum.UserInputType.Keyboard then
            picking = false
            key = input.KeyCode
            btn.Text = "  " .. (p.Name or p.name or "Keybind") .. " : [" .. key.Name .. "]"
            if p.Callback then p.Callback(key) end  -- ← pass the new key, only on pick
        end
        -- REMOVED: the elseif that fired callback on every keypress
    end))
    return {}
end

        function section_api:Status(p)
            local holder = library:create("Frame", { Parent = p.Parent or self.elements, Size = dim2(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
            library:create("UIListLayout", {Parent = holder, Padding = dim(0, 4)})
            library:create("TextLabel", { Parent = holder, Text = "  " .. (p.Name or p.name or "Status"), Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, TextColor3 = Theme.Accent, FontFace = library.font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
            local stat_api = {}
            function stat_api:AddStatus(txt)
                local lbl = library:create("TextLabel", { Parent = holder, Text = "  " .. txt, Size = dim2(1, 0, 0, 16), BackgroundTransparency = 1, TextColor3 = Theme.MutedText, FontFace = library.font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
                return { set = function(self, newTxt) lbl.Text = "  " .. newTxt end }
            end
            return stat_api
        end

        function section_api:List(p)
            local list_api = { items = {} }
            local holder = library:create("Frame", { Parent = p.Parent or self.elements, Size = dim2(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
            library:create("UIListLayout", {Parent = holder, Padding = dim(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
            library:create("TextLabel", { Parent = holder, Text = "  " .. (p.Name or p.name or "List"), Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, TextColor3 = Theme.Accent, FontFace = library.font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
            function list_api:Add(name)
                local itemBtn = library:create("Frame", { Parent = holder, Size = dim2(1, 0, 0, 28), BackgroundColor3 = Theme.ElementBG, LayoutOrder = #list_api.items })
                library:create("UICorner", {Parent = itemBtn, CornerRadius = dim(0, 4)})
                library:create("TextLabel", { Parent = itemBtn, Text = "  " .. name, Size = dim2(1, -40, 1, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, FontFace = library.font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
                table.insert(list_api.items, itemBtn)
                local up = library:create("TextButton", {Parent = itemBtn, Size = dim2(0, 20, 1, 0), Position = dim2(1, -40, 0, 0), BackgroundTransparency = 1, Text = "▲", TextColor3 = Theme.MutedText})
                local dn = library:create("TextButton", {Parent = itemBtn, Size = dim2(0, 20, 1, 0), Position = dim2(1, -20, 0, 0), BackgroundTransparency = 1, Text = "▼", TextColor3 = Theme.MutedText})
                local function swap(dir)
                    local idx = table.find(list_api.items, itemBtn)
                    if idx and list_api.items[idx + dir] then
                        local other = list_api.items[idx + dir]; list_api.items[idx] = other; list_api.items[idx + dir] = itemBtn; itemBtn.LayoutOrder = idx + dir; other.LayoutOrder = idx
                        if p.Callback then local res = {}; for _, v in ipairs(list_api.items) do table.insert(res, v:FindFirstChildOfClass("TextLabel").Text:gsub("^%s+", "")) end; p.Callback(res) end
                    end
                end
                up.MouseButton1Click:Connect(function() swap(-1) end); dn.MouseButton1Click:Connect(function() swap(1) end)
                return itemBtn
            end
            if p.items then for _, v in ipairs(p.items) do list_api:Add(v) end end
            return list_api
        end

        function tab:Section(props)
            local s = {}
            local parent_col = (string.lower(props.side or "left") == "right") and right_col or left_col
            s.elements = library:create("Frame", { Parent = parent_col, Size = dim2(1, 0, 0, 0), BackgroundColor3 = Theme.SectionBG, AutomaticSize = Enum.AutomaticSize.Y })
            library:create("UICorner", {Parent = s.elements, CornerRadius = dim(0, 8)}); library:create("UIStroke", {Parent = s.elements, Color = Theme.Outline, Thickness = 1})
            library:create("UIListLayout", {Parent = s.elements, Padding = dim(0, 8)}); library:create("UIPadding", {Parent = s.elements, PaddingTop = dim(0, 10), PaddingBottom = dim(0, 10), PaddingLeft = dim(0, 10), PaddingRight = dim(0, 10)})
            library:create("TextLabel", { Parent = s.elements, Text = props.name or props.Name or "Section", Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, TextColor3 = Theme.Accent, FontFace = library.font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center })
            library:create("Frame", {Parent = s.elements, Size = dim2(1, 0, 0, 1), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0})
            setmetatable(s, { __index = section_api })
            return s
        end

        return tab
    end

-- ╔══════════════════════════════════════════╗
-- ║   UI SETTINGS (always last, deferred)   ║
-- ╚══════════════════════════════════════════╝
task.defer(function()

    -- Robust color matcher (epsilon avoids float noise; 0.01 ≈ 2.5/255)
    local function colorMatches(a, b)
        return math.abs(a.R - b.R) < 0.01
           and math.abs(a.G - b.G) < 0.01
           and math.abs(a.B - b.B) < 0.01
    end

    -- Scans every descendant and recolors anything that matched the old value.
    -- UIStroke uses direct assignment (TweenService doesn't reliably tween it).
    local function apply_theme(key, new_color)
        local old = Theme[key]
        Theme[key] = new_color
        for _, v in ipairs(screen:GetDescendants()) do
            pcall(function()
                if v:IsA("UIStroke") then
                    if colorMatches(v.Color, old) then v.Color = new_color end
                elseif v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                    if colorMatches(v.BackgroundColor3, old) then
                        library:tween(v, { BackgroundColor3 = new_color }, 0.2)
                    end
                    if colorMatches(v.TextColor3, old) then
                        library:tween(v, { TextColor3 = new_color }, 0.2)
                    end
                elseif v:IsA("ImageLabel") or v:IsA("ImageButton") then
                    if colorMatches(v.BackgroundColor3, old) then
                        library:tween(v, { BackgroundColor3 = new_color }, 0.2)
                    end
                    if colorMatches(v.ImageColor3, old) then
                        library:tween(v, { ImageColor3 = new_color }, 0.2)
                    end
                elseif v:IsA("GuiObject") then
                    if colorMatches(v.BackgroundColor3, old) then
                        library:tween(v, { BackgroundColor3 = new_color }, 0.2)
                    end
                end
            end)
        end
    end

    local defaultTheme = {}
    for k, v in pairs(Theme) do defaultTheme[k] = v end

    local st = win:Tab({ name = "UI Settings", icon = "lucide:settings-2" })

    -- ── LEFT: Color pickers ───────────────────────────────────────────────
    local colorSection = st:Section({ name = "Colors", side = "left" })

    colorSection:Colorpicker({
        name = "Accent",
        default = Theme.Accent,
        Callback = function(c) apply_theme("Accent", c) end
    })
    colorSection:Colorpicker({
        name = "Background",
        default = Theme.MainBG,
        Callback = function(c) apply_theme("MainBG", c) end
    })
    colorSection:Colorpicker({
        name = "Sidebar & Topbar",
        default = Theme.SidebarBG,
        Callback = function(c)
            -- Sidebar and topbar share the same starting color so update both
            apply_theme("SidebarBG", c)
            apply_theme("TopbarBG", c)
        end
    })
    colorSection:Colorpicker({
        name = "Elements",
        default = Theme.ElementBG,
        Callback = function(c) apply_theme("ElementBG", c) end
    })
    colorSection:Colorpicker({
        name = "Text",
        default = Theme.Text,
        Callback = function(c) apply_theme("Text", c) end
    })

    -- ── RIGHT: Controls ───────────────────────────────────────────────────
    local controlSection = st:Section({ name = "Controls", side = "right" })

    controlSection:Keybind({
        name = "Toggle Menu",
        default = toggleKey,
        Callback = function(key)
            toggleKey = key  -- updates the shared upvalue from Change 1
        end
    })

    controlSection:Slider({
        name = "UI Opacity",
        min = 10, max = 100, default = 100, decimals = 0,
        Callback = function(val)
            library:tween(main, { BackgroundTransparency = 1 - (val / 100) }, 0.2)
        end
    })

    -- ── RIGHT: Misc ────────────────────────────────────────────────────────
    local miscSection = st:Section({ name = "Misc", side = "right" })

    miscSection:Button({
        name = "Reset Theme to Default",
        Callback = function()
            for k, v in pairs(defaultTheme) do
                if typeof(v) == "Color3" then apply_theme(k, v) end
            end
            library:create_notification({ name = "Theme reset to defaults.", duration = 3 })
        end
    })

    miscSection:Button({
        name = "Close Menu",
        Callback = function() win.toggle_menu(false) end
    })

    -- ── MOBILE BUTTONS ─────────────────────────────────────────────────────
    local mobileSection = st:Section({ name = "Mobile Buttons", side = "left" })

    if #all_toggles == 0 then
        mobileSection:Label({ name = "No toggles registered in this script." })
    else
        -- Dedicated ScreenGui for floating buttons so they sit above everything
        local float_screen = library:create("ScreenGui", {
            Parent = ui_parent,
            Name  = "MonolithFloats",
            ResetOnSpawn  = false,
            DisplayOrder  = 999
        })

        -- Build a floating pill button for a toggle entry
        local function make_float(entry, idx)
            local cols   = 3
            local col    = (idx - 1) % cols
            local row_n  = math.floor((idx - 1) / cols)

            local label = #entry.name > 9 and entry.name:sub(1, 8) .. "…" or entry.name

            local fb = library:create("TextButton", {
                Parent          = float_screen,
                Size            = dim2(0, 82, 0, 44),
                Position        = dim2(0, 8 + col * 92, 1, -(58 + row_n * 52)),
                BackgroundColor3 = entry.tog.enabled and Theme.Accent or Theme.ElementBG,
                Text            = label,
                TextColor3      = entry.tog.enabled and Theme.MainBG or Theme.Text,
                FontFace        = library.font,
                TextSize        = 11,
                AutoButtonColor = false,
                ZIndex          = 5
            })
            library:create("UICorner", {
                Parent       = fb,
                CornerRadius = dim(0, 22)   -- pill shape
            })
            library:create("UIStroke", {
                Parent    = fb,
                Color     = Theme.Accent,
                Thickness = 1.5
            })

            -- Drag support so players can reposition on mobile
            library:draggify(fb)

            fb.MouseButton1Click:Connect(function()
                entry.fire()
                library:tween(fb, {
                    BackgroundColor3 = entry.tog.enabled and Theme.Accent or Theme.ElementBG,
                    TextColor3       = entry.tog.enabled and Theme.MainBG  or Theme.Text
                }, 0.15)
            end)

            entry.float_btn = fb
        end

        -- Collect toggle names for the dropdown
        local toggle_names = {}
        for _, t in ipairs(all_toggles) do
            table.insert(toggle_names, t.name)
        end

        mobileSection:Label({ name = "Select toggles to give a floating button." })

        mobileSection:Dropdown({
            name    = "Floating Buttons",
            items   = toggle_names,
            multi   = true,
            default = {},
            Callback = function(selected_list)
                -- Tear down all existing float buttons first
                for _, t in ipairs(all_toggles) do
                    if t.float_btn then
                        t.float_btn:Destroy()
                        t.float_btn = nil
                    end
                end
                -- Rebuild for the newly selected set
                local idx = 1
                for _, sel_name in ipairs(selected_list) do
                    for _, t in ipairs(all_toggles) do
                        if t.name == sel_name then
                            make_float(t, idx)
                            idx = idx + 1
                            break
                        end
                    end
                end
            end
        })
    end
end) -- end task.defer

return win
end
-- Add this right before the end of the Library.lua file on your GitHub:
function library:create_notification(props)
    local name = props.name or props.Name or "Notification"
    local duration = props.duration or 4
    
    local notif = library:create("Frame", {
        Parent = notif_container,
        Size = dim2(1, 0, 0, 40),
        BackgroundColor3 = Theme.ElementBG,
        BackgroundTransparency = 1
    })
    library:create("UICorner", {Parent = notif, CornerRadius = dim(0, 6)})
    local stroke = library:create("UIStroke", {Parent = notif, Color = Theme.Outline, Thickness = 1, Transparency = 1})
    
    local title = library:create("TextLabel", {
        Parent = notif,
        Size = dim2(1, -20, 1, 0),
        Position = dim2(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Text,
        FontFace = library.font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1
    })
    
    library:tween(notif, {BackgroundTransparency = 0}, 0.3)
    library:tween(stroke, {Transparency = 0}, 0.3)
    library:tween(title, {TextTransparency = 0}, 0.3)
    
    task.delay(duration, function()
        local fade = library:tween(notif, {BackgroundTransparency = 1}, 0.5)
        library:tween(stroke, {Transparency = 1}, 0.5)
        library:tween(title, {TextTransparency = 1}, 0.5)
        fade.Completed:Connect(function()
            notif:Destroy()
        end)
    end)
end

-- REPLACE "return library" WITH THIS:
return library, library

