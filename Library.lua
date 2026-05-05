--[[ 
    SEDSE UI - FINAL RESTORED BUILD (FIXED)
    Comic Font + All Original Monolith Features + Modern Standardized Syntax
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

--// Icons //--
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
end

--// Notification System //--
local notif_screen = Library:create("ScreenGui", {Parent = ui_parent, Name = "MonolithNotifs"})
table.insert(Library.Instances, notif_screen)
local notif_container = Library:create("Frame", {Parent = notif_screen, Size = dim2(0, 300, 1, 0), Position = dim2(1, -310, 0, 0), BackgroundTransparency = 1})
Library:create("UIListLayout", {Parent = notif_container, Padding = dim(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right})
Library:create("UIPadding", {Parent = notif_container, PaddingBottom = dim(0, 20), PaddingRight = dim(0, 10)})

function Library:Notify(props)
    local nType = props.Type or "Info"; local duration = props.Duration or 5
    local type_colors = { Success = rgb(0, 200, 100), Error = rgb(200, 50, 50), Info = Theme.Accent }
    local accent_color = type_colors[nType] or type_colors.Info
    local type_icons = { Success = "lucide:check-circle", Error = "lucide:alert-circle", Info = "lucide:info" }

    local notif = Library:create("Frame", {Parent = notif_container, Size = dim2(0, 280, 0, 60), BackgroundColor3 = Theme.MainBG, Position = dim2(1, 10, 0, 0)})
    Library:create("UICorner", {Parent = notif, CornerRadius = dim(0, 6)}); Library:create("UIStroke", {Parent = notif, Color = Theme.Outline, Thickness = 1})
    local bar = Library:create("Frame", { Parent = notif, Size = dim2(0, 4, 1, 0), BackgroundColor3 = accent_color })
    Library:create("UICorner", {Parent = bar, CornerRadius = dim(0, 6)})
    local icon = get_icon(type_icons[nType] or type_icons.Info, accent_color)
    if icon then icon.Size = dim2(0, 20, 0, 20); icon.Position = dim2(0, 12, 0.5, 0); icon.AnchorPoint = Vector2.new(0, 0.5); icon.Parent = notif end
    Library:create("TextLabel", {Parent = notif, Text = props.Content or props.Text or "Notification", Size = dim2(1, -45, 1, 0), Position = dim2(0, 40, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, FontFace = Library.font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
    
    Library:tween(notif, {Position = dim2(0, 0, 0, 0)}, 0.5)
    task.delay(duration, function() Library:tween(notif, {Position = dim2(1, 10, 0, 0)}, 0.5).Completed:Connect(function() notif:Destroy() end) end)
end

--// Boot Sequence //--
local function BootSequence(windowFrame, windowName)
    local main = Library:create("Frame", {Parent = windowFrame, Size = dim2(1, 0, 1, 0), BackgroundColor3 = rgb(0, 0, 0), ZIndex = 1000})
    local logo = Library:create("TextLabel", {Parent = main, Text = windowName, Position = dim2(0.5, 0, 0.4, 0), AnchorPoint = Vector2.new(0.5, 0.5), Size = dim2(0, 200, 0, 50), BackgroundTransparency = 1, TextColor3 = Theme.Text, FontFace = Library.font, TextSize = 32, TextTransparency = 1, ZIndex = 1001})
    local barBg = Library:create("Frame", {Parent = main, Size = dim2(0, 200, 0, 4), Position = dim2(0.5, 0, 0.6, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.Outline, ZIndex = 1001})
    Library:create("UICorner", {Parent = barBg})
    local barFill = Library:create("Frame", {Parent = barBg, Size = dim2(0, 0, 1, 0), BackgroundColor3 = Theme.Accent, ZIndex = 1002})
    Library:create("UICorner", {Parent = barFill})

    task.spawn(function()
        Library:tween(logo, {TextTransparency = 0}, 1); task.wait(0.5)
        Library:tween(barFill, {Size = dim2(1, 0, 1, 0)}, 2)
        task.wait(2.2)
        Library:tween(logo, {TextTransparency = 1}, 0.5)
        Library:tween(main, {BackgroundTransparency = 1}, 0.5).Completed:Connect(function() main:Destroy() end)
    end)
end

--// Window Logic //--
function Library:CreateWindow(props)
    local win = { tabs = {} }
    local screen = Library:create("ScreenGui", {Parent = ui_parent, Name = "MonolithUI", ResetOnSpawn = false})
    table.insert(Library.Instances, screen)

    local main = Library:create("Frame", {Parent = screen, Size = dim2(0, 650, 0, 450), Position = dim2(0.5, -325, 0.5, -225), BackgroundColor3 = Theme.MainBG})
    Library:create("UICorner", {Parent = main, CornerRadius = dim(0, 8)}); Library:create("UIStroke", {Parent = main, Color = Theme.Outline, Thickness = 1})

    local topbar = Library:create("Frame", { Parent = main, Size = dim2(1, 0, 0, 40), BackgroundColor3 = Theme.TopbarBG })
    Library:create("UICorner", {Parent = topbar, CornerRadius = dim(0, 8)})
    Library:create("Frame", {Parent = topbar, Size = dim2(1, 0, 0, 10), Position = dim2(0, 0, 1, -10), BackgroundColor3 = Theme.TopbarBG, BorderSizePixel = 0}) 
    Library:create("Frame", {Parent = topbar, Size = dim2(1, 0, 0, 1), Position = dim2(0, 0, 1, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0}) 
    Library:draggify(main, topbar)

    local winIcon = get_icon(props.Icon or "lucide:layout-dashboard", Theme.Text)
    if winIcon then winIcon.Size = dim2(0, 18, 0, 18); winIcon.Position = dim2(0, 12, 0.5, 0); winIcon.AnchorPoint = Vector2.new(0, 0.5); winIcon.Parent = topbar end
    
    Library:create("TextLabel", {Parent = topbar, Text = (props.Name or "Sedse UI"), Size = dim2(1, -100, 1, 0), Position = dim2(0, 40, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.font, TextSize = 18})

    local closeBtn = Library:create("TextButton", { Parent = topbar, Size = dim2(0, 30, 0, 24), Position = dim2(1, -36, 0.5, -12), BackgroundColor3 = Theme.TopbarBG, Text = "✕", TextColor3 = Theme.MutedText, FontFace = Library.font, AutoButtonColor = false })
    Library:create("UICorner", {Parent = closeBtn, CornerRadius = dim(0, 4)})
    closeBtn.MouseButton1Click:Connect(function() Library:Destroy() end)

    local sidebar = Library:create("Frame", { Parent = main, Position = dim2(0, 0, 0, 41), Size = dim2(0, 140, 1, -41), BackgroundColor3 = Theme.SidebarBG, BorderSizePixel = 0 })
    Library:create("Frame", {Parent = sidebar, Size = dim2(0, 1), Position = dim2(1, 0, 0, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0})
    local page_holder = Library:create("Frame", { Parent = main, Position = dim2(0, 141, 0, 41), Size = dim2(1, -141, 1, -41), BackgroundTransparency = 1 })
    Library:create("UIListLayout", {Parent = sidebar, Padding = dim(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center})
    Library:create("UIPadding", {Parent = sidebar, PaddingTop = dim(0, 10)})

    Library:ConnectGlobal(uis.InputBegan, function(input, gpe) if not gpe and input.KeyCode == Library.MenuKeybind then main.Visible = not main.Visible end end)

    if props.Loading then BootSequence(main, props.Name or "Sedse UI") end

    function win:CreateTab(tprops)
        local tab = { name = tprops.Name or "Tab" }
        local btn = Library:create("TextButton", { Parent = sidebar, Size = dim2(1, -16, 0, 32), BackgroundColor3 = Theme.MainBG, Text = "  " .. tab.name, TextColor3 = Theme.MutedText, FontFace = Library.font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false })
        Library:create("UICorner", {Parent = btn, CornerRadius = dim(0, 6)}); Library:create("UIStroke", {Parent = btn, Color = Theme.Outline})

        local page = Library:create("ScrollingFrame", { Parent = page_holder, Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y })
        Library:create("UIListLayout", {Parent = page, FillDirection = Enum.FillDirection.Horizontal, Padding = dim(0, 15), SortOrder = Enum.SortOrder.LayoutOrder})
        Library:create("UIPadding", {Parent = page, Padding = dim(0, 15)})

        local left_col = Library:create("Frame", { Parent = page, Size = dim2(0.5, -8, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
        Library:create("UIListLayout", {Parent = left_col, Padding = dim(0, 10)})
        local right_col = Library:create("Frame", { Parent = page, Size = dim2(0.5, -8, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
        Library:create("UIListLayout", {Parent = right_col, Padding = dim(0, 10)})

        if #win.tabs == 0 then page.Visible = true; btn.TextColor3 = Theme.Text; btn.BackgroundColor3 = Theme.ElementBG end
        table.insert(win.tabs, {btn = btn, page = page})

        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(win.tabs) do t.page.Visible = false; t.btn.TextColor3 = Theme.MutedText; Library:tween(t.btn, {BackgroundColor3 = Theme.MainBG}, 0.15) end
            page.Visible = true; btn.TextColor3 = Theme.Text; Library:tween(btn, {BackgroundColor3 = Theme.ElementBG}, 0.15)
        end)

        function tab:CreateSection(sprops)
            local s = {}
            local parent_col = (string.lower(sprops.Side or "left") == "right") and right_col or left_col
            s.elements = Library:create("Frame", { Parent = parent_col, Size = dim2(1, 0, 0, 0), BackgroundColor3 = Theme.SectionBG, AutomaticSize = Enum.AutomaticSize.Y })
            Library:create("UICorner", {Parent = s.elements, CornerRadius = dim(0, 8)}); Library:create("UIStroke", {Parent = s.elements, Color = Theme.Outline})
            Library:create("UIListLayout", {Parent = s.elements, Padding = dim(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}); Library:create("UIPadding", {Parent = s.elements, Padding = dim(0, 10)})
            Library:create("TextLabel", { Parent = s.elements, Text = sprops.Name or "Section", Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, TextColor3 = Theme.Accent, FontFace = Library.font, TextSize = 14 })

            function s:CreateButton(p)
                local b = Library:create("TextButton", { Parent = s.elements, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = p.Name or "Button", TextColor3 = Theme.Text, FontFace = Library.font, TextSize = 13 })
                Library:create("UICorner", {Parent = b, CornerRadius = dim(0, 6)})
                if p.Premium then PremiumOverlay(b) end
                b.MouseButton1Click:Connect(function() if p.Callback then p.Callback() end end)
            end

            function s:CreateToggle(p)
                local state = p.CurrentValue or false
                local btn = Library:create("TextButton", { Parent = s.elements, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = "  " .. (p.Name or "Toggle"), TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.font, TextSize = 13 })
                Library:create("UICorner", {Parent = btn, CornerRadius = dim(0, 6)})
                local ind = Library:create("Frame", { Parent = btn, Size = dim2(0, 16, 0, 16), Position = dim2(1, -24, 0.5, -8), BackgroundColor3 = state and Theme.Accent or Theme.MainBG })
                Library:create("UICorner", {Parent = ind, CornerRadius = dim(0, 4)})
                
                local function Update(val) state = val; Library:tween(ind, {BackgroundColor3 = state and Theme.Accent or Theme.MainBG}, 0.2); if p.Callback then p.Callback(state) end end
                btn.MouseButton1Click:Connect(function() Update(not state) end)
                return { Set = Update }
            end

            function s:CreateSlider(p)
                local min, max, val = p.Range[1], p.Range[2], p.CurrentValue or p.Range[1]
                local sl = Library:create("Frame", { Parent = s.elements, Size = dim2(1, 0, 0, 45), BackgroundColor3 = Theme.ElementBG })
                Library:create("UICorner", {Parent = sl, CornerRadius = dim(0, 6)})
                local lbl = Library:create("TextLabel", { Parent = sl, Text = tostring(val), Size = dim2(0, 40, 0, 20), Position = dim2(1, -45, 0, 5), BackgroundTransparency = 1, TextColor3 = Theme.Accent, FontFace = Library.font })
                local bar = Library:create("Frame", { Parent = sl, Size = dim2(1, -20, 0, 6), Position = dim2(0, 10, 0, 30), BackgroundColor3 = Theme.MainBG })
                local fill = Library:create("Frame", { Parent = bar, Size = dim2((val-min)/(max-min), 0, 1, 0), BackgroundColor3 = Theme.Accent })
                
                local dragging = false
                local function Update(pct)
                    val = math.floor(min + ((max - min) * pct)); fill.Size = dim2(pct, 0, 1, 0); lbl.Text = tostring(val)
                    if p.Callback then p.Callback(val) end
                end
                bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; Update(math.clamp((uis:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)) end end)
                Library:ConnectGlobal(uis.InputEnded, function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                Library:ConnectGlobal(uis.InputChanged, function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(math.clamp((uis:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)) end end)
                return { Set = function(self, v) Update((v - min)/(max - min)) end }
            end

            function s:CreateDropdown(p)
                local selected = p.CurrentValue or "None"; local open = false
                local holder = Library:create("Frame", {Parent = s.elements, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true})
                Library:create("UICorner", {Parent = holder, CornerRadius = dim(0, 6)})
                local btn = Library:create("TextButton", {Parent = holder, Size = dim2(1, 0, 0, 32), BackgroundTransparency = 1, Text = "  " .. p.Name .. " : " .. (type(selected) == "table" and table.concat(selected, ", ") or selected), TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.font, TextSize = 13})
                local arrow = Library:create("TextLabel", {Parent = btn, Text = "▲", Size = dim2(0, 20, 0, 20), Position = dim2(1, -25, 0.5, -10), BackgroundTransparency = 1, TextColor3 = Theme.MutedText, FontFace = Library.font})

                local content = Library:create("Frame", {Parent = holder, Size = dim2(1, 0, 0, 0), Position = dim2(0, 0, 0, 32), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Visible = false})
                Library:create("UIListLayout", {Parent = content})
                
                btn.MouseButton1Click:Connect(function() open = not open; content.Visible = open; arrow.Text = open and "▼" or "▲" end)

                for _, item in pairs(p.Items) do
                    local ib = Library:create("TextButton", {Parent = content, Size = dim2(1, 0, 0, 25), BackgroundColor3 = Theme.HoverBG, Text = item, TextColor3 = Theme.MutedText, FontFace = Library.font, TextSize = 12})
                    ib.MouseButton1Click:Connect(function()
                        selected = item; btn.Text = "  " .. p.Name .. " : " .. selected; open = false; content.Visible = false; arrow.Text = "▲"
                        if p.Callback then p.Callback(item) end
                    end)
                end
            end

            return s
        end
        return tab
    end
    return win
end

return Library
