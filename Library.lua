--[[ 
    MONOLITH FINGERPAINT LIBRARY (V5 - Ather Integration + Lucide Icons)
    Designed for: loadstring execution
]]

local uis = game:GetService("UserInputService") 
local tween_service = game:GetService("TweenService")

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
local dim2 = UDim2.new
local dim = UDim.new 
local rgb = Color3.fromRGB

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

-- Library state
local library = {
    font = Font.new("rbxassetid://12187375716", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
}

-- Safe Lazy-Load Lucide Icons (Prevents HTTP Freezing)
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
            local ok, iconObj = pcall(function()
                return Icons.Image({ Icon = iconStr, Colors = {color or Color3.fromRGB(255, 255, 255)} })
            end)
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

-- Utility
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
    uis.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            frame.Position = dim2(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

local function PremiumOverlay(parent)
    local overlay = library:create("Frame", { Parent = parent, Size = dim2(1, 0, 1, 0), BackgroundColor3 = Theme.MainBG, BackgroundTransparency = 0.3, ZIndex = 10 })
    library:create("UICorner", {Parent = overlay, CornerRadius = dim(0, 6)})
    local lock = get_icon("lucide:lock", Theme.Accent)
    if lock then lock.Parent = overlay; lock.AnchorPoint = Vector2.new(0.5, 0.5); lock.Position = dim2(0.5, 0, 0.5, 0); lock.Size = dim2(0, 16, 0, 16); lock.ZIndex = 11 end
    library:create("TextButton", { Parent = overlay, Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 12 })
end

-- Window System
function library:window(props)
    local win = { items = {}, tabs = {} }
    local screen = library:create("ScreenGui", {Parent = ui_parent, Name = "MonolithUI", ResetOnSpawn = false})
    
    local main = library:create("Frame", {
        Parent = screen, Size = dim2(0, 650, 0, 450), Position = dim2(0.5, -325, 0.5, -225), BackgroundColor3 = Theme.MainBG, BorderSizePixel = 0
    })
    library:create("UICorner", {Parent = main, CornerRadius = dim(0, 8)})
    library:create("UIStroke", {Parent = main, Color = Theme.Outline, Thickness = 1})

    local topbar = library:create("Frame", { Parent = main, Size = dim2(1, 0, 0, 40), BackgroundColor3 = Theme.TopbarBG, BorderSizePixel = 0 })
    library:create("UICorner", {Parent = topbar, CornerRadius = dim(0, 8)})
    library:create("Frame", {Parent = topbar, Size = dim2(1, 0, 0, 10), Position = dim2(0, 0, 1, -10), BackgroundColor3 = Theme.TopbarBG, BorderSizePixel = 0}) 
    library:create("Frame", {Parent = topbar, Size = dim2(1, 0, 0, 1), Position = dim2(0, 0, 1, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0}) 
    library:draggify(main, topbar)

    -- Window Icon & Title
    local winIcon = get_icon(props.Icon or props.icon or "lucide:layout-dashboard", Theme.Text)
    if winIcon then winIcon.Size = dim2(0, 18, 0, 18); winIcon.Position = dim2(0, 12, 0.5, 0); winIcon.AnchorPoint = Vector2.new(0, 0.5); winIcon.Parent = topbar end
    local titleOff = winIcon and 38 or 12

    library:create("TextLabel", {
        Parent = topbar, Text = (props.name or props.Name or "Nebula UI"), Size = dim2(1, -titleOff, 1, 0), Position = dim2(0, titleOff, 0, 0),
        BackgroundTransparency = 1, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = library.font, TextSize = 18
    })

    local sidebar = library:create("Frame", { Parent = main, Position = dim2(0, 0, 0, 41), Size = dim2(0, 140, 1, -41), BackgroundColor3 = Theme.SidebarBG, BorderSizePixel = 0 })
    library:create("Frame", {Parent = sidebar, Size = dim2(0, 1), Position = dim2(1, 0, 0, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0})
    local page_holder = library:create("Frame", { Parent = main, Position = dim2(0, 141, 0, 41), Size = dim2(1, -141, 1, -41), BackgroundTransparency = 1 })
    library:create("UIListLayout", {Parent = sidebar, Padding = dim(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center})
    library:create("UIPadding", {Parent = sidebar, PaddingTop = dim(0, 10)})

    -- Window Resizer (↘)
    local resizeHandle = library:create("TextButton", { Parent = main, Size = dim2(0, 20, 0, 20), Position = dim2(1, -20, 1, -20), BackgroundTransparency = 1, Text = "↘", TextColor3 = Theme.MutedText, TextSize = 14, FontFace = library.font, ZIndex = 100 })
    local resizing, rStartPos, rStartSize
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = true; rStartPos = input.Position; rStartSize = main.Size end
    end)
    uis.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - rStartPos
            main.Size = dim2(0, math.max(450, rStartSize.X.Offset + delta.X), 0, math.max(300, rStartSize.Y.Offset + delta.Y))
        end
    end)
    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
    end)

    win.toggle_menu = function(a, b) 
        local state = (type(a) == "boolean") and a or b
        if state == nil then state = not main.Visible end
        main.Visible = state
    end

    function win:Tab(props)
        local tab = { name = props.name or props.Name or "Tab" }
        local btn = library:create("TextButton", { Parent = sidebar, Size = dim2(1, -16, 0, 32), BackgroundColor3 = Theme.MainBG, Text = "", AutoButtonColor = false })
        library:create("UICorner", {Parent = btn, CornerRadius = dim(0, 6)})
        library:create("UIStroke", {Parent = btn, Color = Theme.Outline, Thickness = 1})

        -- Tab Icon & Title
        local tIcon = get_icon(props.Icon or props.icon or "lucide:folder", Theme.MutedText)
        if tIcon then tIcon.Size = dim2(0, 16, 0, 16); tIcon.Position = dim2(0, 10, 0.5, 0); tIcon.AnchorPoint = Vector2.new(0, 0.5); tIcon.Parent = btn end
        local tOff = tIcon and 34 or 10

        local tLabel = library:create("TextLabel", { Parent = btn, Text = tab.name, Size = dim2(1, -tOff, 1, 0), Position = dim2(0, tOff, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.MutedText, TextXAlignment = Enum.TextXAlignment.Left, FontFace = library.font, TextSize = 13 })

        local page = library:create("ScrollingFrame", { Parent = page_holder, Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y })
        library:create("UIListLayout", {Parent = page, FillDirection = Enum.FillDirection.Horizontal, Padding = dim(0, 15), SortOrder = Enum.SortOrder.LayoutOrder})
        library:create("UIPadding", {Parent = page, PaddingLeft = dim(0, 15), PaddingRight = dim(0, 15), PaddingTop = dim(0, 15), PaddingBottom = dim(0, 15)})

        -- Columns
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

        -- Section API
        local section_api = {}
        
        function section_api:Label(p)
            local l = library:create("TextLabel", { Parent = p.Parent or self.elements, Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, Text = p.name or p.Name or "Label", TextColor3 = Theme.MutedText, FontFace = library.font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y })
            return { instance = l, set = function(txt) l.Text = txt end }
        end

        function section_api:Button(p)
            local b = library:create("TextButton", { Parent = p.Parent or self.elements, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = " " .. (p.name or p.Name or "Button"), TextColor3 = Theme.Text, FontFace = library.font, TextSize = 13, AutoButtonColor = false })
            library:create("UICorner", {Parent = b, CornerRadius = dim(0, 6)})
            library:create("UIStroke", {Parent = b, Color = Theme.Outline, Thickness = 1})
            if p.Premium or p.premium then PremiumOverlay(b) end
            b.MouseButton1Click:Connect(function()
                library:tween(b, {BackgroundColor3 = Theme.HoverBG}, 0.1); task.wait(0.1); library:tween(b, {BackgroundColor3 = Theme.ElementBG}, 0.1)
                if p.Callback then p.Callback() end
            end)
            return {}
        end

        function section_api:Toggle(p)
            local tog = { enabled = p.default or false }
            local holder = library:create("Frame", { Parent = p.Parent or self.elements, Size = dim2(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
            library:create("UIListLayout", {Parent = holder, Padding = dim(0, 6)})

            local btn = library:create("TextButton", { Parent = holder, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = "  " .. (p.name or p.Name or "Toggle"), TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = library.font, TextSize = 13, AutoButtonColor = false })
            library:create("UICorner", {Parent = btn, CornerRadius = dim(0, 6)}); library:create("UIStroke", {Parent = btn, Color = Theme.Outline, Thickness = 1})
            if p.Premium or p.premium then PremiumOverlay(btn) end

            local indicator = library:create("Frame", { Parent = btn, Size = dim2(0, 16, 0, 16), Position = dim2(1, -24, 0.5, -8), BackgroundColor3 = tog.enabled and Theme.Accent or Theme.MainBG })
            library:create("UICorner", {Parent = indicator, CornerRadius = dim(0, 4)}); library:create("UIStroke", {Parent = indicator, Color = Theme.Outline, Thickness = 1})

            local container = library:create("Frame", { Parent = holder, Size = dim2(1, 0, 0, 0), BackgroundTransparency = 1, Visible = tog.enabled, AutomaticSize = Enum.AutomaticSize.Y })
            library:create("UIListLayout", {Parent = container, Padding = dim(0, 6)}); library:create("UIPadding", {Parent = container, PaddingLeft = dim(0, 14)})

            btn.MouseButton1Click:Connect(function()
                tog.enabled = not tog.enabled; container.Visible = tog.enabled
                library:tween(indicator, {BackgroundColor3 = tog.enabled and Theme.Accent or Theme.MainBG}, 0.2)
                if p.Callback then p.Callback(tog.enabled) end
            end)

            function tog:Slider(np) np = np or {}; np.Parent = container; return section_api:Slider(np) end
            function tog:Dropdown(np) np = np or {}; np.Parent = container; return section_api:Dropdown(np) end
            function tog:Colorpicker(np) np = np or {}; np.Parent = container; return section_api:Colorpicker(np) end
            function tog:Keybind(np) np = np or {}; np.Parent = container; return section_api:Keybind(np) end

            return tog
        end

        function section_api:Slider(p)
            local min, max, default = p.min or 0, p.max or 100, p.default or p.min or 0
            local s = library:create("Frame", { Parent = p.Parent or self.elements, Size = dim2(1, 0, 0, 50), BackgroundColor3 = Theme.ElementBG })
            library:create("UICorner", {Parent = s, CornerRadius = dim(0, 6)}); library:create("UIStroke", {Parent = s, Color = Theme.Outline, Thickness = 1})
            if p.Premium or p.premium then PremiumOverlay(s) end
            
            local lbl = library:create("TextLabel", { Parent = s, Text = "  " .. (p.name or p.Name or "Slider"), Size = dim2(1, 0, 0, 25), BackgroundTransparency = 1, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = library.font, TextSize = 13 })
            local val_lbl = library:create("TextLabel", { Parent = s, Text = tostring(default), Size = dim2(0, 50, 0, 25), Position = dim2(1, -55, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Right, FontFace = library.font, TextSize = 13 })
            local bar_bg = library:create("Frame", { Parent = s, Size = dim2(1, -20, 0, 6), Position = dim2(0, 10, 0, 32), BackgroundColor3 = Theme.MainBG })
            library:create("UICorner", {Parent = bar_bg, CornerRadius = dim(1, 0)})
            local fill = library:create("Frame", { Parent = bar_bg, Size = dim2((default - min)/(max - min), 0, 1, 0), BackgroundColor3 = Theme.Accent })
            library:create("UICorner", {Parent = fill, CornerRadius = dim(1, 0)})

            local dragging = false
            local function update_slider()
                local mouse_x = uis:GetMouseLocation().X
                local percent = math.clamp((mouse_x - bar_bg.AbsolutePosition.X) / bar_bg.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + ((max - min) * percent))
                fill.Size = dim2(percent, 0, 1, 0); val_lbl.Text = tostring(value)
                if p.Callback then p.Callback(value) end
            end

            bar_bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; update_slider() end end)
            uis.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
            uis.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update_slider() end end)

            return {}
        end

        function section_api:Textbox(p)
            local bg = library:create("Frame", { Parent = p.Parent or self.elements, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG })
            library:create("UICorner", {Parent = bg, CornerRadius = dim(0, 6)}); library:create("UIStroke", {Parent = bg, Color = Theme.Outline, Thickness = 1})
            if p.Premium or p.premium then PremiumOverlay(bg) end

            local box = library:create("TextBox", { Parent = bg, Size = dim2(1, -16, 1, 0), Position = dim2(0, 8, 0, 0), BackgroundTransparency = 1, Text = "", PlaceholderText = p.placeholder or p.Placeholder or (p.name or "Textbox"), TextColor3 = Theme.Text, PlaceholderColor3 = Theme.MutedText, FontFace = library.font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
            box.FocusLost:Connect(function() if p.Callback then p.Callback(box.Text) end end)
            return {}
        end

        function section_api:Dropdown(p)
            local isMulti = p.multi or p.Multi
            local selected = isMulti and (p.default or {}) or (p.default or (p.items and p.items[1]) or "None")
            local open = false

            local holder = library:create("Frame", { Parent = p.Parent or self.elements, Size = dim2(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
            library:create("UIListLayout", {Parent = holder, Padding = dim(0, 4)})

            local get_val_str = function() return isMulti and (#selected > 0 and table.concat(selected, ", ") or "None") or selected end

            local btn = library:create("TextButton", { Parent = holder, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = "  " .. (p.Name or p.name or "Dropdown") .. " : " .. get_val_str(), TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = library.font, TextSize = 13, AutoButtonColor=false })
            library:create("UICorner", {Parent = btn, CornerRadius = dim(0, 6)}); library:create("UIStroke", {Parent = btn, Color = Theme.Outline, Thickness = 1})
            if p.Premium or p.premium then PremiumOverlay(btn) end

            local container = library:create("Frame", { Parent = holder, Size = dim2(1, 0, 0, 0), BackgroundTransparency = 1, Visible = false, AutomaticSize = Enum.AutomaticSize.Y })
            library:create("UIListLayout", {Parent = container, Padding = dim(0, 4)}); library:create("UIPadding", {Parent = container, PaddingLeft = dim(0, 8)})

            local searchBox = library:create("TextBox", { Parent = container, Size = dim2(1, 0, 0, 28), BackgroundColor3 = Theme.MainBG, TextColor3 = Theme.Text, PlaceholderText = "Search...", PlaceholderColor3 = Theme.MutedText, FontFace = library.font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Text = "" })
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

            btn.MouseButton1Click:Connect(function() open = not open; container.Visible = open end)

            for _, item in pairs(p.items or {}) do
                local ibtn = library:create("TextButton", { Parent = container, Size = dim2(1, 0, 0, 26), BackgroundColor3 = Theme.HoverBG, Text = "  " .. item, TextColor3 = Theme.MutedText, TextXAlignment = Enum.TextXAlignment.Left, FontFace = library.font, TextSize = 12, AutoButtonColor = false })
                library:create("UICorner", {Parent = ibtn, CornerRadius = dim(0, 6)})
                table.insert(itemBtns, {btn = ibtn, name = item})

                ibtn.MouseButton1Click:Connect(function()
                    if isMulti then
                        local idx = table.find(selected, item)
                        if idx then table.remove(selected, idx) else table.insert(selected, item) end
                    else
                        selected = item; open = false; container.Visible = false
                    end
                    updateItems(); if p.Callback then p.Callback(selected) end
                end)
            end

            searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                local q = searchBox.Text:lower()
                for _, iBtn in pairs(itemBtns) do iBtn.btn.Visible = (q == "" or iBtn.name:lower():find(q) ~= nil) end
            end)
            updateItems()
            return {}
        end

        function section_api:Colorpicker(p)
            local c = library:create("TextButton", { Parent = p.Parent or self.elements, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = "  " .. (p.Name or p.name or "Colorpicker"), TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = library.font, TextSize = 13, AutoButtonColor=false })
            library:create("UICorner", {Parent = c, CornerRadius = dim(0, 6)}); library:create("UIStroke", {Parent = c, Color = Theme.Outline, Thickness = 1})
            if p.Premium or p.premium then PremiumOverlay(c) end
            local disp = library:create("Frame", { Parent = c, Size = dim2(0, 20, 0, 16), Position = dim2(1, -28, 0.5, -8), BackgroundColor3 = rgb(255, 0, 0) })
            library:create("UICorner", {Parent = disp, CornerRadius = dim(0, 4)})
            return {}
        end

        function section_api:Keybind(p)
            local k = library:create("TextButton", { Parent = p.Parent or self.elements, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = "  " .. (p.Name or p.name or "Keybind") .. " : [NONE]", TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = library.font, TextSize = 13, AutoButtonColor=false })
            library:create("UICorner", {Parent = k, CornerRadius = dim(0, 6)}); library:create("UIStroke", {Parent = k, Color = Theme.Outline, Thickness = 1})
            if p.Premium or p.premium then PremiumOverlay(k) end
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
                        local other = list_api.items[idx + dir]
                        list_api.items[idx] = other; list_api.items[idx + dir] = itemBtn
                        itemBtn.LayoutOrder = idx + dir; other.LayoutOrder = idx
                        if p.Callback then
                            local res = {}
                            for _, v in ipairs(list_api.items) do 
                                local tLbl = v:FindFirstChildOfClass("TextLabel")
                                if tLbl then table.insert(res, tLbl.Text:gsub("^%s+", "")) end
                            end
                            p.Callback(res)
                        end
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

    return win
end

function library:init_config(win)
    local configTab = win:Tab({name = "Configs", icon = "lucide:settings"})
    local sec = configTab:Section({name = "Settings", side = "left"})
    sec:Button({name = "Save Config", Callback = function() print("Config Saved") end})
end

local notifications = {
    create_notification = function(props) print("Notification: " .. (props.name or "Hello")) end
}

return library, notifications
