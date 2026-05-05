--[[ 
    SEDSE UI / MONOLITH FINGERPAINT - ULTIMATE BUILD
    Contains EVERY original feature (Lucide Icons, HSV Wheel, Resize Handle, Minimize)
    Upgraded to Standard Syntax & Auto-Cleanup.
]]

local uis = game:GetService("UserInputService") 
local tween_service = game:GetService("TweenService")
local gui_service = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

local Library = {
    font = Font.new("rbxassetid://12187375716", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    MenuKeybind = Enum.KeyCode.RightControl,
    Instances = {},   
    Connections = {}  
}

-- Safe Parent Getter
local function get_ui_parent()
    local success, parent = pcall(function() return gethui and gethui() end)
    if success and parent then return parent end
    success, parent = pcall(function() return game:GetService("CoreGui") end)
    if success and parent then return parent end
    return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local ui_parent = get_ui_parent()

-- Shorthands & Theme
local dim2, dim, rgb = UDim2.new, UDim.new, Color3.fromRGB
local Theme = {
    MainBG = rgb(15, 15, 15), SidebarBG = rgb(18, 18, 18), TopbarBG = rgb(18, 18, 18),
    SectionBG = rgb(22, 22, 22), ElementBG = rgb(30, 30, 30), HoverBG = rgb(40, 40, 40),
    Accent = rgb(100, 150, 255), Text = rgb(240, 240, 240), MutedText = rgb(150, 150, 150),
    Outline = rgb(45, 45, 45)
}

--// Utilities //--
function Library:tween(obj, props, time) 
    local t = tween_service:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

function Library:create(class, props)
    local ins = Instance.new(class)
    for k, v in pairs(props) do ins[k] = v end
    return ins
end

function Library:ConnectGlobal(Signal, Callback)
    local Connection = Signal:Connect(Callback)
    table.insert(Library.Connections, Connection)
    return Connection
end

function Library:Destroy()
    for _, con in ipairs(Library.Connections) do if con.Connected then con:Disconnect() end end
    for _, ins in ipairs(Library.Instances) do if ins and ins.Parent then ins:Destroy() end end
    table.clear(Library.Connections)
    table.clear(Library.Instances)
end

function Library:draggify(frame, drag_area)
    local dragging, startPos, startInput
    (drag_area or frame).InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; startInput = input.Position; startPos = frame.Position
        end
    end)
    Library:ConnectGlobal(uis.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            frame.Position = dim2(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    Library:ConnectGlobal(uis.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

--// Lucide Icons System (Original) //--
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
        img.BackgroundTransparency = 1; img.Image = iconName:match("^%d+$") and "rbxassetid://"..iconName or iconName
        img.ImageColor3 = color or rgb(255, 255, 255)
        return img
    end
    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    task.spawn(function()
        local waited = 0
        while not Icons and waited < 5 do task.wait(0.1); waited = waited + 0.1 end
        if Icons then
            local iconStr = iconName:gsub("^lucide:", "")
            local ok, iconObj = pcall(function() return Icons.Image({ Icon = iconStr, Colors = {color or rgb(255, 255, 255)} }) end)
            if ok and iconObj and iconObj.IconFrame then
                iconObj.IconFrame.BackgroundTransparency = 1; iconObj.IconFrame.Size = dim2(1, 0, 1, 0); iconObj.IconFrame.Parent = holder
            end
        end
    end)
    return holder
end

local function color_icon(iconInstance, color)
    if not iconInstance then return end
    for _, v in pairs(iconInstance:GetDescendants()) do
        if v:IsA("ImageLabel") then Library:tween(v, {ImageColor3 = color}, 0.15) end
    end
end

local function PremiumOverlay(parent)
    local overlay = Library:create("Frame", { Parent = parent, Size = dim2(1, 0, 1, 0), BackgroundColor3 = Theme.MainBG, BackgroundTransparency = 0.3, ZIndex = 10 })
    Library:create("UICorner", {Parent = overlay, CornerRadius = dim(0, 6)})
    local lock = get_icon("lucide:lock", Theme.Accent)
    if lock then lock.Parent = overlay; lock.AnchorPoint = Vector2.new(0.5, 0.5); lock.Position = dim2(0.5, 0, 0.5, 0); lock.Size = dim2(0, 16, 0, 16); lock.ZIndex = 11 end
    Library:create("TextButton", { Parent = overlay, Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 12 })
end

--// Notification Container //--
local notif_screen = Library:create("ScreenGui", {Parent = ui_parent, Name = "MonolithNotifs"})
table.insert(Library.Instances, notif_screen)
local notif_container = Library:create("Frame", {Parent = notif_screen, Size = dim2(0, 300, 1, 0), Position = dim2(1, -310, 0, 0), BackgroundTransparency = 1})
Library:create("UIListLayout", {Parent = notif_container, Padding = dim(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right})
Library:create("UIPadding", {Parent = notif_container, PaddingBottom = dim(0, 20), PaddingRight = dim(0, 10)})

function Library:Notify(props)
    local nType = props.Type or props.type or "Info"; local duration = props.Duration or props.duration or 5
    local type_colors = { Success = rgb(0, 200, 100), Error = rgb(200, 50, 50), Info = Theme.Accent }
    local accent_color = type_colors[nType] or type_colors.Info
    local type_icons = { Success = "lucide:check-circle", Error = "lucide:alert-circle", Info = "lucide:info" }

    local notif = Library:create("Frame", {Parent = notif_container, Size = dim2(0, 280, 0, 60), BackgroundColor3 = Theme.MainBG, Position = dim2(1, 10, 0, 0)})
    Library:create("UICorner", {Parent = notif, CornerRadius = dim(0, 6)}); Library:create("UIStroke", {Parent = notif, Color = Theme.Outline, Thickness = 1})
    local bar = Library:create("Frame", { Parent = notif, Size = dim2(0, 4, 1, 0), BackgroundColor3 = accent_color, BorderSizePixel = 0 })
    Library:create("UICorner", {Parent = bar, CornerRadius = dim(0, 6)})
    local icon = get_icon(type_icons[nType] or type_icons.Info, accent_color)
    if icon then icon.Size = dim2(0, 20, 0, 20); icon.Position = dim2(0, 12, 0.5, 0); icon.AnchorPoint = Vector2.new(0, 0.5); icon.Parent = notif end
    Library:create("TextLabel", {Parent = notif, Text = props.Content or props.content or props.Text or "Notification", Size = dim2(1, -45, 1, 0), Position = dim2(0, 40, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, FontFace = Library.font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
    
    Library:tween(notif, {Position = dim2(0, 0, 0, 0)}, 0.5)
    task.delay(duration, function() Library:tween(notif, {Position = dim2(1, 10, 0, 0)}, 0.5).Completed:Connect(function() notif:Destroy() end) end)
end

--// Boot Sequence //--
local function BootSequence(windowFrame, windowName)
    local main = Library:create("Frame", {Parent = windowFrame, Size = dim2(1, 0, 1, 0), BackgroundColor3 = rgb(0, 0, 0), ZIndex = 1000, BorderSizePixel = 0})
    local logo = Library:create("TextLabel", {Parent = main, Text = windowName, Position = dim2(0.5, 0, 0.4, 0), AnchorPoint = Vector2.new(0.5, 0.5), Size = dim2(0, 200, 0, 50), BackgroundTransparency = 1, TextColor3 = Theme.Text, FontFace = Library.font, TextSize = 32, TextTransparency = 1, ZIndex = 1001})
    local barBg = Library:create("Frame", {Parent = main, Size = dim2(0, 200, 0, 4), Position = dim2(0.5, 0, 0.6, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.Outline, ZIndex = 1001})
    Library:create("UICorner", {Parent = barBg})
    local barFill = Library:create("Frame", {Parent = barBg, Size = dim2(0, 0, 1, 0), BackgroundColor3 = Theme.Accent, ZIndex = 1002})
    Library:create("UICorner", {Parent = barFill})
    local status = Library:create("TextLabel", {Parent = main, Text = "Initializing...", Position = dim2(0.5, 0, 0.65, 0), AnchorPoint = Vector2.new(0.5, 0.5), Size = dim2(0, 200, 0, 20), BackgroundTransparency = 1, TextColor3 = Theme.MutedText, FontFace = Library.font, TextSize = 14, TextTransparency = 1, ZIndex = 1001})

    task.spawn(function()
        Library:tween(logo, {TextTransparency = 0}, 1); task.wait(0.5); Library:tween(status, {TextTransparency = 0}, 0.5)
        local steps = {"Loading Core...", "Fetching Assets...", "Applying Theme...", "Finalizing..."}
        for i, step in ipairs(steps) do status.Text = step; Library:tween(barFill, {Size = dim2(i/#steps, 0, 1, 0)}, 0.5); task.wait(0.6) end
        Library:tween(logo, {TextTransparency = 1}, 0.5); Library:tween(status, {TextTransparency = 1}, 0.5); Library:tween(barFill, {BackgroundTransparency = 1}, 0.3); Library:tween(barBg, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.5)
        Library:tween(main, {BackgroundTransparency = 1}, 1).Completed:Connect(function() main:Destroy() end)
    end)
end

--// Window Creation //--
function Library:CreateWindow(props)
    local win = { tabs = {} }
    local screen = Library:create("ScreenGui", {Parent = ui_parent, Name = "MonolithUI", ResetOnSpawn = false})
    table.insert(Library.Instances, screen)

    local main = Library:create("Frame", {Parent = screen, Size = dim2(0, 650, 0, 450), Position = dim2(0.5, -325, 0.5, -225), BackgroundColor3 = Theme.MainBG})
    Library:create("UICorner", {Parent = main, CornerRadius = dim(0, 8)}); Library:create("UIStroke", {Parent = main, Color = Theme.Outline, Thickness = 1})

    local topbar = Library:create("Frame", { Parent = main, Size = dim2(1, 0, 0, 40), BackgroundColor3 = Theme.TopbarBG })
    Library:create("UICorner", {Parent = topbar, CornerRadius = dim(0, 8)})
    local topbar_filler = Library:create("Frame", {Parent = topbar, Size = dim2(1, 0, 0, 10), Position = dim2(0, 0, 1, -10), BackgroundColor3 = Theme.TopbarBG, BorderSizePixel = 0}) 
    Library:create("Frame", {Parent = topbar, Size = dim2(1, 0, 0, 1), Position = dim2(0, 0, 1, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0}) 
    Library:draggify(main, topbar)

    local winIcon = get_icon(props.Icon or props.icon or "lucide:layout-dashboard", Theme.Text)
    if winIcon then winIcon.Size = dim2(0, 18, 0, 18); winIcon.Position = dim2(0, 12, 0.5, 0); winIcon.AnchorPoint = Vector2.new(0, 0.5); winIcon.Parent = topbar end
    local titleOff = winIcon and 38 or 12

    Library:create("TextLabel", {Parent = topbar, Text = (props.Name or props.name or "Sedse UI"), Size = dim2(1, -(titleOff + 80), 1, 0), Position = dim2(0, titleOff, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.font, TextSize = 18})

    -- Minimize & Close
    local minBtn = Library:create("TextButton", { Parent = topbar, Size = dim2(0, 30, 0, 24), Position = dim2(1, -70, 0.5, -12), BackgroundColor3 = Theme.TopbarBG, Text = "", AutoButtonColor = false })
    Library:create("UICorner", {Parent = minBtn, CornerRadius = dim(0, 4)})
    local minIconObj = get_icon("lucide:minus", Theme.MutedText)
    if minIconObj then minIconObj.Size = dim2(0, 14, 0, 14); minIconObj.Position = dim2(0.5, 0, 0.5, 0); minIconObj.AnchorPoint = Vector2.new(0.5, 0.5); minIconObj.Parent = minBtn end

    local closeBtn = Library:create("TextButton", { Parent = topbar, Size = dim2(0, 30, 0, 24), Position = dim2(1, -36, 0.5, -12), BackgroundColor3 = Theme.TopbarBG, Text = "", AutoButtonColor = false })
    Library:create("UICorner", {Parent = closeBtn, CornerRadius = dim(0, 4)})
    local closeIconObj = get_icon("lucide:x", Theme.MutedText)
    if closeIconObj then closeIconObj.Size = dim2(0, 14, 0, 14); closeIconObj.Position = dim2(0.5, 0, 0.5, 0); closeIconObj.AnchorPoint = Vector2.new(0.5, 0.5); closeIconObj.Parent = closeBtn end

    minBtn.MouseEnter:Connect(function() Library:tween(minBtn, {BackgroundColor3 = Theme.HoverBG}, 0.15); color_icon(minIconObj, Theme.Text) end)
    minBtn.MouseLeave:Connect(function() Library:tween(minBtn, {BackgroundColor3 = Theme.TopbarBG}, 0.15); color_icon(minIconObj, Theme.MutedText) end)
    closeBtn.MouseEnter:Connect(function() Library:tween(closeBtn, {BackgroundColor3 = rgb(200, 50, 50)}, 0.15); color_icon(closeIconObj, Theme.Text) end)
    closeBtn.MouseLeave:Connect(function() Library:tween(closeBtn, {BackgroundColor3 = Theme.TopbarBG}, 0.15); color_icon(closeIconObj, Theme.MutedText) end)
    closeBtn.MouseButton1Click:Connect(function() Library:Destroy() end)

    local sidebar = Library:create("Frame", { Parent = main, Position = dim2(0, 0, 0, 41), Size = dim2(0, 140, 1, -41), BackgroundColor3 = Theme.SidebarBG, BorderSizePixel = 0 })
    Library:create("Frame", {Parent = sidebar, Size = dim2(0, 1), Position = dim2(1, 0, 0, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0})
    local page_holder = Library:create("Frame", { Parent = main, Position = dim2(0, 141, 0, 41), Size = dim2(1, -141, 1, -41), BackgroundTransparency = 1 })
    Library:create("UIListLayout", {Parent = sidebar, Padding = dim(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center})
    Library:create("UIPadding", {Parent = sidebar, PaddingTop = dim(0, 10)})

    -- Resize Handle
    local resizeHandle = Library:create("TextButton", { Parent = main, Size = dim2(0, 20, 0, 20), Position = dim2(1, -20, 1, -20), BackgroundTransparency = 1, Text = "↘", TextColor3 = Theme.MutedText, TextSize = 14, FontFace = Library.font, ZIndex = 100 })
    local resizing, rStartPos, rStartSize
    resizeHandle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = true; rStartPos = input.Position; rStartSize = main.Size end end)
    Library:ConnectGlobal(uis.InputChanged, function(input) if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - rStartPos; main.Size = dim2(0, math.max(450, rStartSize.X.Offset + delta.X), 0, math.max(300, rStartSize.Y.Offset + delta.Y)) end end)
    Library:ConnectGlobal(uis.InputEnded, function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end end)

    local isMinimized = false; local savedSize = main.Size
    minBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            savedSize = main.Size; resizeHandle.Visible = false; sidebar.Visible = false; page_holder.Visible = false; topbar_filler.Visible = false
            Library:tween(main, {Size = dim2(0, savedSize.X.Offset, 0, 40)}, 0.25)
        else
            topbar_filler.Visible = true
            Library:tween(main, {Size = savedSize}, 0.25).Completed:Connect(function() if not isMinimized then sidebar.Visible = true; page_holder.Visible = true; resizeHandle.Visible = true end end)
        end
    end)

    Library:ConnectGlobal(uis.InputBegan, function(input, gpe) if not gpe and input.KeyCode == Library.MenuKeybind then main.Visible = not main.Visible end end)

    if props.Loading or props.loading then BootSequence(main, props.Name or props.name or "Sedse UI") end

    function win:CreateTab(tprops)
        local tab = { name = tprops.Name or tprops.name or "Tab" }
        local btn = Library:create("TextButton", { Parent = sidebar, Size = dim2(1, -16, 0, 32), BackgroundColor3 = Theme.MainBG, Text = "", AutoButtonColor = false })
        Library:create("UICorner", {Parent = btn, CornerRadius = dim(0, 6)}); Library:create("UIStroke", {Parent = btn, Color = Theme.Outline, Thickness = 1})
        local tIcon = get_icon(tprops.Icon or tprops.icon or "lucide:folder", Theme.MutedText)
        if tIcon then tIcon.Size = dim2(0, 16, 0, 16); tIcon.Position = dim2(0, 10, 0.5, 0); tIcon.AnchorPoint = Vector2.new(0, 0.5); tIcon.Parent = btn end
        local tOff = tIcon and 34 or 10
        local tLabel = Library:create("TextLabel", { Parent = btn, Text = tab.name, Size = dim2(1, -tOff, 1, 0), Position = dim2(0, tOff, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.MutedText, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.font, TextSize = 13 })

        local page = Library:create("ScrollingFrame", { Parent = page_holder, Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y })
        Library:create("UIListLayout", {Parent = page, FillDirection = Enum.FillDirection.Horizontal, Padding = dim(0, 15), SortOrder = Enum.SortOrder.LayoutOrder})
        Library:create("UIPadding", {Parent = page, PaddingLeft = dim(0, 15), PaddingRight = dim(0, 15), PaddingTop = dim(0, 15), PaddingBottom = dim(0, 15)})

        local left_col = Library:create("Frame", { Parent = page, Size = dim2(0.5, -8, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
        Library:create("UIListLayout", {Parent = left_col, Padding = dim(0, 10)})
        local right_col = Library:create("Frame", { Parent = page, Size = dim2(0.5, -8, 0, 0), Position = dim2(0.5, 8, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
        Library:create("UIListLayout", {Parent = right_col, Padding = dim(0, 10)})

        if #win.tabs == 0 then page.Visible = true; tLabel.TextColor3 = Theme.Text; btn.BackgroundColor3 = Theme.ElementBG; color_icon(tIcon, Theme.Text) end
        table.insert(win.tabs, {btn = btn, page = page, label = tLabel, icon = tIcon})

        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(win.tabs) do 
                t.page.Visible = false; t.label.TextColor3 = Theme.MutedText; color_icon(t.icon, Theme.MutedText); Library:tween(t.btn, {BackgroundColor3 = Theme.MainBG}, 0.15)
            end
            page.Visible = true; tLabel.TextColor3 = Theme.Text; color_icon(tIcon, Theme.Text); Library:tween(btn, {BackgroundColor3 = Theme.ElementBG}, 0.15)
        end)

        function tab:CreateSection(sprops)
            local s = {}
            local parent_col = (string.lower(sprops.Side or sprops.side or "left") == "right") and right_col or left_col
            s.elements = Library:create("Frame", { Parent = parent_col, Size = dim2(1, 0, 0, 0), BackgroundColor3 = Theme.SectionBG, AutomaticSize = Enum.AutomaticSize.Y })
            Library:create("UICorner", {Parent = s.elements, CornerRadius = dim(0, 8)}); Library:create("UIStroke", {Parent = s.elements, Color = Theme.Outline, Thickness = 1})
            Library:create("UIListLayout", {Parent = s.elements, Padding = dim(0, 8)}); Library:create("UIPadding", {Parent = s.elements, PaddingTop = dim(0, 10), PaddingBottom = dim(0, 10), PaddingLeft = dim(0, 10), PaddingRight = dim(0, 10)})
            Library:create("TextLabel", { Parent = s.elements, Text = sprops.Name or sprops.name or "Section", Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, TextColor3 = Theme.Accent, FontFace = Library.font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center })
            Library:create("Frame", {Parent = s.elements, Size = dim2(1, 0, 0, 1), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0})

            function s:CreateLabel(p)
                local l = Library:create("TextLabel", { Parent = p.Parent or s.elements, Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, Text = p.Text or p.text or p.Name or "Label", TextColor3 = Theme.MutedText, FontFace = Library.font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y })
                return { Set = function(self, txt) l.Text = txt end }
            end
            
            function s:CreateButton(p)
                local b = Library:create("TextButton", { Parent = p.Parent or s.elements, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = " " .. (p.Name or p.name or "Button"), TextColor3 = Theme.Text, FontFace = Library.font, TextSize = 13, AutoButtonColor = false })
                Library:create("UICorner", {Parent = b, CornerRadius = dim(0, 6)}); Library:create("UIStroke", {Parent = b, Color = Theme.Outline, Thickness = 1})
                if p.Premium or p.premium then PremiumOverlay(b) end
                b.MouseButton1Click:Connect(function() Library:tween(b, {BackgroundColor3 = Theme.HoverBG}, 0.1); task.wait(0.1); Library:tween(b, {BackgroundColor3 = Theme.ElementBG}, 0.1); if p.Callback then p.Callback() end end)
            end

            function s:CreateToggle(p)
                local tog = { enabled = p.CurrentValue or p.default or false }
                local holder = Library:create("Frame", { Parent = p.Parent or s.elements, Size = dim2(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
                Library:create("UIListLayout", {Parent = holder, Padding = dim(0, 6)})
                local btn = Library:create("TextButton", { Parent = holder, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = "  " .. (p.Name or p.name or "Toggle"), TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.font, TextSize = 13, AutoButtonColor = false })
                Library:create("UICorner", {Parent = btn, CornerRadius = dim(0, 6)}); Library:create("UIStroke", {Parent = btn, Color = Theme.Outline, Thickness = 1})
                if p.Premium or p.premium then PremiumOverlay(btn) end
                local indicator = Library:create("Frame", { Parent = btn, Size = dim2(0, 16, 0, 16), Position = dim2(1, -24, 0.5, -8), BackgroundColor3 = tog.enabled and Theme.Accent or Theme.MainBG })
                Library:create("UICorner", {Parent = indicator, CornerRadius = dim(0, 4)}); Library:create("UIStroke", {Parent = indicator, Color = Theme.Outline, Thickness = 1})
                
                -- Container for Nested Elements (Original feature!)
                local container = Library:create("Frame", { Parent = holder, Size = dim2(1, 0, 0, 0), BackgroundTransparency = 1, Visible = tog.enabled, AutomaticSize = Enum.AutomaticSize.Y })
                Library:create("UIListLayout", {Parent = container, Padding = dim(0, 6)}); Library:create("UIPadding", {Parent = container, PaddingLeft = dim(0, 14)})
                
                local function Update(val)
                    tog.enabled = val; container.Visible = tog.enabled; Library:tween(indicator, {BackgroundColor3 = tog.enabled and Theme.Accent or Theme.MainBG}, 0.2)
                    if p.Callback then p.Callback(tog.enabled) end
                end
                btn.MouseButton1Click:Connect(function() Update(not tog.enabled) end)
                
                tog.Set = function(self, val) Update(val) end
                tog.Container = container
                return tog
            end

            function s:CreateSlider(p)
                local min, max, default = p.Range and p.Range[1] or p.min or 0, p.Range and p.Range[2] or p.max or 100, p.CurrentValue or p.default or 0
                local sl = Library:create("Frame", { Parent = p.Parent or s.elements, Size = dim2(1, 0, 0, 50), BackgroundColor3 = Theme.ElementBG })
                Library:create("UICorner", {Parent = sl, CornerRadius = dim(0, 6)}); Library:create("UIStroke", {Parent = sl, Color = Theme.Outline, Thickness = 1})
                if p.Premium or p.premium then PremiumOverlay(sl) end
                Library:create("TextLabel", { Parent = sl, Text = "  " .. (p.Name or p.name or "Slider"), Size = dim2(1, 0, 0, 25), BackgroundTransparency = 1, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.font, TextSize = 13 })
                local val_lbl = Library:create("TextLabel", { Parent = sl, Text = tostring(default), Size = dim2(0, 50, 0, 25), Position = dim2(1, -55, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Right, FontFace = Library.font, TextSize = 13 })
                local bar_bg = Library:create("Frame", { Parent = sl, Size = dim2(1, -20, 0, 6), Position = dim2(0, 10, 0, 32), BackgroundColor3 = Theme.MainBG })
                Library:create("UICorner", {Parent = bar_bg, CornerRadius = dim(1, 0)})
                local fill = Library:create("Frame", { Parent = bar_bg, Size = dim2((default - min)/(max - min), 0, 1, 0), BackgroundColor3 = Theme.Accent })
                Library:create("UICorner", {Parent = fill, CornerRadius = dim(1, 0)})
                
                local dragging = false
                local function update_slider(pct)
                    local value = math.floor(min + ((max - min) * pct)); fill.Size = dim2(pct, 0, 1, 0); val_lbl.Text = tostring(value)
                    if p.Callback then p.Callback(value) end
                end
                bar_bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; update_slider(math.clamp((uis:GetMouseLocation().X - bar_bg.AbsolutePosition.X) / bar_bg.AbsoluteSize.X, 0, 1)) end end)
                Library:ConnectGlobal(uis.InputEnded, function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
                Library:ConnectGlobal(uis.InputChanged, function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update_slider(math.clamp((uis:GetMouseLocation().X - bar_bg.AbsolutePosition.X) / bar_bg.AbsoluteSize.X, 0, 1)) end end)
                return { Set = function(self, v) update_slider((v - min)/(max - min)) end }
            end

            function s:CreateInput(p)
                local bg = Library:create("Frame", { Parent = p.Parent or s.elements, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG })
                Library:create("UICorner", {Parent = bg, CornerRadius = dim(0, 6)}); Library:create("UIStroke", {Parent = bg, Color = Theme.Outline, Thickness = 1})
                if p.Premium or p.premium then PremiumOverlay(bg) end
                local box = Library:create("TextBox", { Parent = bg, Size = dim2(1, -16, 1, 0), Position = dim2(0, 8, 0, 0), BackgroundTransparency = 1, Text = "", PlaceholderText = p.PlaceholderText or p.placeholder or (p.Name or "Textbox"), TextColor3 = Theme.Text, PlaceholderColor3 = Theme.MutedText, FontFace = Library.font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
                box.FocusLost:Connect(function() if p.Callback then p.Callback(box.Text) end end)
                return { Set = function(self, t) box.Text = t end }
            end

            function s:CreateDropdown(p)
                local isMulti = p.Multi or p.multi
                local selected = isMulti and (p.CurrentValue or p.default or {}) or (p.CurrentValue or p.default or (p.Items and p.Items[1]) or "None")
                local open = false
                local holder = Library:create("Frame", { Parent = p.Parent or s.elements, Size = dim2(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
                Library:create("UIListLayout", {Parent = holder, Padding = dim(0, 4)})
                local get_val_str = function() return isMulti and (#selected > 0 and table.concat(selected, ", ") or "None") or selected end
                
                local btn = Library:create("TextButton", { Parent = holder, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = "  " .. (p.Name or p.name or "Dropdown") .. " : " .. get_val_str(), TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.font, TextSize = 13, AutoButtonColor=false })
                Library:create("UICorner", {Parent = btn, CornerRadius = dim(0, 6)}); Library:create("UIStroke", {Parent = btn, Color = Theme.Outline, Thickness = 1})
                if p.Premium or p.premium then PremiumOverlay(btn) end
                
                -- Up/Down Arrow
                local arrow = Library:create("TextLabel", {Parent = btn, Text = "▲", Size = dim2(0, 20, 0, 20), Position = dim2(1, -25, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, TextColor3 = Theme.MutedText, FontFace = Library.font, TextSize = 10})

                local container = Library:create("Frame", { Parent = holder, Size = dim2(1, 0, 0, 0), BackgroundTransparency = 1, Visible = false, AutomaticSize = Enum.AutomaticSize.Y })
                Library:create("UIListLayout", {Parent = container, Padding = dim(0, 4)}); Library:create("UIPadding", {Parent = container, PaddingLeft = dim(0, 8)})
                local searchBox = Library:create("TextBox", { Parent = container, Size = dim2(1, 0, 0, 28), BackgroundColor3 = Theme.MainBG, TextColor3 = Theme.Text, PlaceholderText = "Search...", PlaceholderColor3 = Theme.MutedText, FontFace = Library.font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Text = "" })
                Library:create("UICorner", {Parent = searchBox, CornerRadius = dim(0, 4)}); Library:create("UIPadding", {Parent = searchBox, PaddingLeft = dim(0, 8)})
                
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
                    open = not open; container.Visible = open
                    arrow.Text = open and "▼" or "▲"
                    Library:tween(arrow, {TextColor3 = open and Theme.Accent or Theme.MutedText}, 0.2)
                end)
                
                for _, item in pairs(p.Items or p.items or {}) do
                    local ibtn = Library:create("TextButton", { Parent = container, Size = dim2(1, 0, 0, 26), BackgroundColor3 = Theme.HoverBG, Text = "  " .. item, TextColor3 = Theme.MutedText, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.font, TextSize = 12, AutoButtonColor = false })
                    Library:create("UICorner", {Parent = ibtn, CornerRadius = dim(0, 6)}); table.insert(itemBtns, {btn = ibtn, name = item})
                    ibtn.MouseButton1Click:Connect(function()
                        if isMulti then local idx = table.find(selected, item); if idx then table.remove(selected, idx) else table.insert(selected, item) end else selected = item; open = false; container.Visible = false; arrow.Text = "▲"; Library:tween(arrow, {TextColor3 = Theme.MutedText}, 0.2) end
                        updateItems(); if p.Callback then p.Callback(selected) end
                    end)
                end
                searchBox:GetPropertyChangedSignal("Text"):Connect(function() local q = searchBox.Text:lower(); for _, iBtn in pairs(itemBtns) do iBtn.btn.Visible = (q == "" or iBtn.name:lower():find(q) ~= nil) end end)
                updateItems()
            end

            -- Original HSV Colorpicker
            function s:CreateColorpicker(p)
                local open = false
                local color = p.CurrentValue or p.default or rgb(255, 0, 0)
                local h, sl, v = color:ToHSV()
                local holder = Library:create("Frame", { Parent = p.Parent or s.elements, Size = dim2(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
                Library:create("UIListLayout", {Parent = holder, Padding = dim(0, 4)})
                local btn = Library:create("TextButton", { Parent = holder, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = "  " .. (p.Name or p.name or "Colorpicker"), TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.font, TextSize = 13, AutoButtonColor=false })
                Library:create("UICorner", {Parent = btn, CornerRadius = dim(0, 6)}); Library:create("UIStroke", {Parent = btn, Color = Theme.Outline, Thickness = 1})
                if p.Premium or p.premium then PremiumOverlay(btn) end
                local disp = Library:create("Frame", { Parent = btn, Size = dim2(0, 20, 0, 16), Position = dim2(1, -28, 0.5, -8), BackgroundColor3 = color })
                Library:create("UICorner", {Parent = disp, CornerRadius = dim(0, 4)})
                local container = Library:create("Frame", { Parent = holder, Size = dim2(1, 0, 0, 130), BackgroundTransparency = 1, Visible = false })
                local wheelBg = Library:create("Frame", {Parent = container, Size = dim2(1, 0, 1, 0), BackgroundColor3 = Theme.SectionBG})
                Library:create("UICorner", {Parent = wheelBg, CornerRadius = dim(0, 6)})
                local wheel = Library:create("ImageButton", { Parent = wheelBg, Size = dim2(0, 100, 0, 100), Position = dim2(0, 10, 0, 10), BackgroundTransparency = 1, Image = "rbxassetid://6020299385" })
                local pickerDot = Library:create("ImageLabel", { Parent = wheel, Size = dim2(0, 12, 0, 12), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://3678860011" })
                local valSlider = Library:create("TextButton", { Parent = wheelBg, Size = dim2(0, 15, 0, 100), Position = dim2(0, 120, 0, 10), BackgroundColor3 = rgb(255, 255, 255), Text = "", AutoButtonColor = false })
                Library:create("UICorner", {Parent = valSlider, CornerRadius = dim(0, 4)})
                local valGrad = Library:create("UIGradient", { Parent = valSlider, Rotation = 90, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromHSV(h,sl,1)), ColorSequenceKeypoint.new(1, rgb(0,0,0))} })
                local valIndicator = Library:create("Frame", { Parent = valSlider, Size = dim2(1, 4, 0, 4), Position = dim2(0.5, 0, 1-v, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.Text, BorderSizePixel = 0 })

                btn.MouseButton1Click:Connect(function() open = not open; container.Visible = open end)
                local function update_color()
                    local finalColor = Color3.fromHSV(h, sl, v)
                    disp.BackgroundColor3 = finalColor
                    valGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromHSV(h,sl,1)), ColorSequenceKeypoint.new(1, rgb(0,0,0))}
                    if p.Callback then p.Callback(finalColor) end
                end

                local angle = (h * math.pi * 2) - (math.pi / 2)
                pickerDot.Position = dim2(0.5 + math.cos(angle) * 0.5 * sl, 0, 0.5 + math.sin(angle) * 0.5 * sl, 0)

                local draggingWheel, draggingVal = false, false
                local inset = gui_service:GetGuiInset()
                wheel.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingWheel = true end end)
                valSlider.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingVal = true end end)
                Library:ConnectGlobal(uis.InputEnded, function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingWheel = false; draggingVal = false end end)
                Library:ConnectGlobal(uis.InputChanged, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        local mLoc = uis:GetMouseLocation()
                        local correctedMouse = Vector2.new(mLoc.X, mLoc.Y - inset.Y)
                        if draggingWheel then
                            local wheelCenter = wheel.AbsolutePosition + (wheel.AbsoluteSize / 2)
                            local offset = correctedMouse - wheelCenter
                            local rad = wheel.AbsoluteSize.X / 2
                            if offset.Magnitude > rad then offset = offset.Unit * rad end
                            pickerDot.Position = dim2(0.5 + (offset.X / wheel.AbsoluteSize.X), 0, 0.5 + (offset.Y / wheel.AbsoluteSize.Y), 0)
                            local cAngle = math.atan2(-offset.Y, offset.X)
                            h = (cAngle / (math.pi * 2)) + 0.5
                            h = h % 1; sl = offset.Magnitude / rad; update_color()
                        elseif draggingVal then
                            local relativeY = correctedMouse.Y - valSlider.AbsolutePosition.Y
                            local clampedY = math.clamp(relativeY, 0, valSlider.AbsoluteSize.Y)
                            valIndicator.Position = dim2(0.5, 0, 0, clampedY); v = 1 - (clampedY / valSlider.AbsoluteSize.Y); update_color()
                        end
                    end
                end)
            end

            function s:CreateKeybind(p)
                local key = p.CurrentValue or p.default or Enum.KeyCode.Unknown
                local btn = Library:create("TextButton", { Parent = p.Parent or s.elements, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = "  " .. (p.Name or p.name or "Keybind") .. " :[" .. key.Name .. "]", TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.font, TextSize = 13, AutoButtonColor=false })
                Library:create("UICorner", {Parent = btn, CornerRadius = dim(0, 6)}); Library:create("UIStroke", {Parent = btn, Color = Theme.Outline, Thickness = 1})
                if p.Premium or p.premium then PremiumOverlay(btn) end
                local picking = false
                btn.MouseButton1Click:Connect(function() picking = true; btn.Text = "  " .. (p.Name or p.name or "Keybind") .. " : [...]" end)
                Library:ConnectGlobal(uis.InputBegan, function(input, gpe)
                    if picking and input.UserInputType == Enum.UserInputType.Keyboard then picking = false; key = input.KeyCode; btn.Text = "  " .. (p.Name or p.name or "Keybind") .. " : [" .. key.Name .. "]"
                    elseif not gpe and input.KeyCode == key and key ~= Enum.KeyCode.Unknown then if p.Callback then p.Callback() end end
                end)
            end

            function s:CreateStatus(p)
                local holder = Library:create("Frame", { Parent = p.Parent or s.elements, Size = dim2(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
                Library:create("UIListLayout", {Parent = holder, Padding = dim(0, 4)})
                Library:create("TextLabel", { Parent = holder, Text = "  " .. (p.Name or p.name or "Status"), Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, TextColor3 = Theme.Accent, FontFace = Library.font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
                local stat_api = {}
                function stat_api:AddStatus(txt)
                    local lbl = Library:create("TextLabel", { Parent = holder, Text = "  " .. txt, Size = dim2(1, 0, 0, 16), BackgroundTransparency = 1, TextColor3 = Theme.MutedText, FontFace = Library.font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
                    return { Set = function(self, newTxt) lbl.Text = "  " .. newTxt end }
                end
                return stat_api
            end

            function s:CreateList(p)
                local list_api = { items = {} }
                local holder = Library:create("Frame", { Parent = p.Parent or s.elements, Size = dim2(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
                Library:create("UIListLayout", {Parent = holder, Padding = dim(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
                Library:create("TextLabel", { Parent = holder, Text = "  " .. (p.Name or p.name or "List"), Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, TextColor3 = Theme.Accent, FontFace = Library.font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
                function list_api:Add(name)
                    local itemBtn = Library:create("Frame", { Parent = holder, Size = dim2(1, 0, 0, 28), BackgroundColor3 = Theme.ElementBG, LayoutOrder = #list_api.items })
                    Library:create("UICorner", {Parent = itemBtn, CornerRadius = dim(0, 4)})
                    Library:create("TextLabel", { Parent = itemBtn, Text = "  " .. name, Size = dim2(1, -40, 1, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, FontFace = Library.font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
                    table.insert(list_api.items, itemBtn)
                    local up = Library:create("TextButton", {Parent = itemBtn, Size = dim2(0, 20, 1, 0), Position = dim2(1, -40, 0, 0), BackgroundTransparency = 1, Text = "▲", TextColor3 = Theme.MutedText, FontFace = Library.font})
                    local dn = Library:create("TextButton", {Parent = itemBtn, Size = dim2(0, 20, 1, 0), Position = dim2(1, -20, 0, 0), BackgroundTransparency = 1, Text = "▼", TextColor3 = Theme.MutedText, FontFace = Library.font})
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
                if p.Items then for _, v in ipairs(p.Items) do list_api:Add(v) end end
                return list_api
            end

            return s
        end
        return tab
    end
    return Window
end

return Library
