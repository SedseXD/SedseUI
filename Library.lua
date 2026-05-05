--[[ 
    SEDSE UI - FINAL RESTORED BUILD
    Comic Font + All Original Monolith Features + Modern Standardized Syntax
]]

local UserInputService = game:GetService("UserInputService") 
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

local Library = {
    Font = Font.new("rbxassetid://12187375716", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    MenuKeybind = Enum.KeyCode.RightControl,
    Instances = {},   
    Connections = {}  
}

--// Theme //--
local dim2, dim, rgb = UDim2.new, UDim.new, Color3.fromRGB
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

--// Utilities //--
local function GetUIParent()
    local success, parent = pcall(function() return gethui and gethui() end)
    if success and parent then return parent end
    success, parent = pcall(function() return game:GetService("CoreGui") end)
    if success and parent then return parent end
    return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local UIParent = GetUIParent()

function Library:Tween(obj, props, time) 
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

function Library:Create(class, props)
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
end

function Library:Draggify(frame, drag_area)
    local dragging, startPos, startInput
    (drag_area or frame).InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; startInput = input.Position; startPos = frame.Position
        end
    end)
    Library:ConnectGlobal(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            frame.Position = dim2(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    Library:ConnectGlobal(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

local function PremiumOverlay(parent)
    local overlay = Library:Create("Frame", { Parent = parent, Size = dim2(1, 0, 1, 0), BackgroundColor3 = Theme.MainBG, BackgroundTransparency = 0.3, ZIndex = 10 })
    Library:Create("UICorner", {Parent = overlay, CornerRadius = dim(0, 6)})
    Library:Create("TextLabel", { Parent = overlay, Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Text = "🔒", TextColor3 = Theme.Accent, TextSize = 14, ZIndex = 11 })
end

--// Notifications //--
local NotifScreen = Library:Create("ScreenGui", {Parent = UIParent, Name = "SedseNotifs"})
table.insert(Library.Instances, NotifScreen)
local NotifContainer = Library:Create("Frame", {Parent = NotifScreen, Size = dim2(0, 300, 1, 0), Position = dim2(1, -310, 0, 0), BackgroundTransparency = 1})
Library:Create("UIListLayout", {Parent = NotifContainer, Padding = dim(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom})

function Library:Notify(Config)
    local Notif = Library:Create("Frame", {Parent = NotifContainer, Size = dim2(0, 280, 0, 60), BackgroundColor3 = Theme.MainBG})
    Library:Create("UICorner", {Parent = Notif, CornerRadius = dim(0, 6)})
    Library:Create("UIStroke", {Parent = Notif, Color = Theme.Outline})
    Library:Create("TextLabel", {Parent = Notif, Text = Config.Content or "...", Size = dim2(1, -20, 1, 0), Position = dim2(0, 10, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, FontFace = Library.Font, TextSize = 13, TextWrapped = true})
    
    Library:Tween(Notif, {Position = dim2(0, 0, 0, 0)}, 0.4)
    task.delay(Config.Duration or 5, function()
        Library:Tween(Notif, {Position = dim2(1, 10, 0, 0)}, 0.4).Completed:Connect(function() Notif:Destroy() end)
    end)
end

--// Window System //--
function Library:CreateWindow(Config)
    local Window = { Tabs = {} }
    local Screen = Library:Create("ScreenGui", {Parent = UIParent, Name = "SedseUI"})
    table.insert(Library.Instances, Screen)

    local Main = Library:Create("Frame", {Parent = Screen, Size = dim2(0, 650, 0, 450), Position = dim2(0.5, -325, 0.5, -225), BackgroundColor3 = Theme.MainBG})
    Library:Create("UICorner", {Parent = Main, CornerRadius = dim(0, 8)})
    Library:Create("UIStroke", {Parent = Main, Color = Theme.Outline})

    local Topbar = Library:Create("Frame", {Parent = Main, Size = dim2(1, 0, 0, 40), BackgroundColor3 = Theme.TopbarBG})
    Library:Create("UICorner", {Parent = Topbar, CornerRadius = dim(0, 8)})
    Library:Draggify(Main, Topbar)

    Library:Create("TextLabel", {Parent = Topbar, Text = Config.Name or "Sedse UI", Size = dim2(1, -50, 1, 0), Position = dim2(0, 15, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, FontFace = Library.Font, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left})

    local CloseBtn = Library:Create("TextButton", {Parent = Topbar, Size = dim2(0, 30, 0, 24), Position = dim2(1, -36, 0.5, -12), BackgroundColor3 = Theme.TopbarBG, Text = "✕", TextColor3 = Theme.MutedText, FontFace = Library.Font})
    CloseBtn.MouseButton1Click:Connect(function() Library:Destroy() end)

    local Sidebar = Library:Create("Frame", {Parent = Main, Position = dim2(0, 0, 0, 41), Size = dim2(0, 140, 1, -41), BackgroundColor3 = Theme.SidebarBG})
    local PageHolder = Library:Create("Frame", {Parent = Main, Position = dim2(0, 141, 0, 41), Size = dim2(1, -141, 1, -41), BackgroundTransparency = 1})
    Library:Create("UIListLayout", {Parent = Sidebar, Padding = dim(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center})
    Library:Create("UIPadding", {Parent = Sidebar, PaddingTop = dim(0, 10)})

    function Window:CreateTab(TabConfig)
        local Tab = { Name = TabConfig.Name or "Tab" }
        local TabBtn = Library:Create("TextButton", {Parent = Sidebar, Size = dim2(1, -16, 0, 32), BackgroundColor3 = Theme.MainBG, Text = "  " .. Tab.Name, TextColor3 = Theme.MutedText, FontFace = Library.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false})
        Library:Create("UICorner", {Parent = TabBtn, CornerRadius = dim(0, 6)})
        Library:Create("UIStroke", {Parent = TabBtn, Color = Theme.Outline})

        local Page = Library:Create("ScrollingFrame", {Parent = PageHolder, Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y})
        Library:Create("UIListLayout", {Parent = Page, FillDirection = Enum.FillDirection.Horizontal, Padding = dim(0, 15), SortOrder = Enum.SortOrder.LayoutOrder})
        Library:Create("UIPadding", {Parent = Page, PaddingLeft = dim(0, 15), PaddingRight = dim(0, 15), PaddingTop = dim(0, 15), PaddingBottom = dim(0, 15)})

        local LeftCol = Library:Create("Frame", {Parent = Page, Size = dim2(0.5, -8, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y})
        Library:Create("UIListLayout", {Parent = LeftCol, Padding = dim(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})
        local RightCol = Library:Create("Frame", {Parent = Page, Size = dim2(0.5, -8, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y})
        Library:Create("UIListLayout", {Parent = RightCol, Padding = dim(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})

        if #Window.Tabs == 0 then Page.Visible = true; TabBtn.TextColor3 = Theme.Text; TabBtn.BackgroundColor3 = Theme.ElementBG end
        table.insert(Window.Tabs, {Btn = TabBtn, Page = Page})

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do t.Page.Visible = false; t.Btn.TextColor3 = Theme.MutedText; Library:Tween(t.Btn, {BackgroundColor3 = Theme.MainBG}, 0.15) end
            Page.Visible = true; TabBtn.TextColor3 = Theme.Text; Library:Tween(TabBtn, {BackgroundColor3 = Theme.ElementBG}, 0.15)
        end)

        function Tab:CreateSection(SecConfig)
            local Section = {}
            local ParentCol = (string.lower(SecConfig.Side or "left") == "right") and RightCol or LeftCol
            Section.Container = Library:Create("Frame", {Parent = ParentCol, Size = dim2(1, 0, 0, 0), BackgroundColor3 = Theme.SectionBG, AutomaticSize = Enum.AutomaticSize.Y})
            Library:Create("UICorner", {Parent = Section.Container, CornerRadius = dim(0, 8)})
            Library:Create("UIStroke", {Parent = Section.Container, Color = Theme.Outline})
            Library:Create("UIListLayout", {Parent = Section.Container, Padding = dim(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})
            Library:Create("UIPadding", {Parent = Section.Container, Padding = dim(0, 10)})
            
            Library:Create("TextLabel", {Parent = Section.Container, Text = SecConfig.Name or "Section", Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, TextColor3 = Theme.Accent, FontFace = Library.Font, TextSize = 14})

            function Section:CreateButton(BtnConfig)
                local B = Library:Create("TextButton", {Parent = Section.Container, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = BtnConfig.Name, TextColor3 = Theme.Text, FontFace = Library.Font, TextSize = 13})
                Library:Create("UICorner", {Parent = B, CornerRadius = dim(0, 6)})
                if BtnConfig.Premium then PremiumOverlay(B) end
                B.MouseButton1Click:Connect(function() if BtnConfig.Callback then BtnConfig.Callback() end end)
            end

            function Section:CreateToggle(TogConfig)
                local State = TogConfig.CurrentValue or false
                local Btn = Library:Create("TextButton", {Parent = Section.Container, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = "  " .. TogConfig.Name, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.Font, TextSize = 13})
                Library:Create("UICorner", {Parent = Btn, CornerRadius = dim(0, 6)})
                local Ind = Library:Create("Frame", {Parent = Btn, Size = dim2(0, 16, 0, 16), Position = dim2(1, -24, 0.5, -8), BackgroundColor3 = State and Theme.Accent or Theme.MainBG})
                Library:Create("UICorner", {Parent = Ind, CornerRadius = dim(0, 4)})
                
                Btn.MouseButton1Click:Connect(function() 
                    State = not State; Library:Tween(Ind, {BackgroundColor3 = State and Theme.Accent or Theme.MainBG}, 0.2)
                    if TogConfig.Callback then TogConfig.Callback(State) end 
                end)
            end

            function Section:CreateSlider(SldConfig)
                local Min, Max, Value = SldConfig.Range[1], SldConfig.Range[2], SldConfig.CurrentValue or SldConfig.Range[1]
                local SFrame = Library:Create("Frame", {Parent = Section.Container, Size = dim2(1, 0, 0, 45), BackgroundColor3 = Theme.ElementBG})
                Library:Create("UICorner", {Parent = SFrame, CornerRadius = dim(0, 6)})
                local ValLbl = Library:Create("TextLabel", {Parent = SFrame, Text = tostring(Value), Size = dim2(0, 40, 0, 20), Position = dim2(1, -45, 0, 5), BackgroundTransparency = 1, TextColor3 = Theme.Accent, FontFace = Library.Font})
                local Bar = Library:Create("Frame", {Parent = SFrame, Size = dim2(1, -20, 0, 6), Position = dim2(0, 10, 0, 30), BackgroundColor3 = Theme.MainBG})
                local Fill = Library:Create("Frame", {Parent = Bar, Size = dim2((Value-Min)/(Max-Min), 0, 1, 0), BackgroundColor3 = Theme.Accent})
                
                local Dragging = false
                local function Update(pct)
                    Value = math.floor(Min + ((Max - Min) * pct)); Fill.Size = dim2(pct, 0, 1, 0); ValLbl.Text = tostring(Value)
                    if SldConfig.Callback then SldConfig.Callback(Value) end
                end
                Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; Update(math.clamp((UserInputService:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)) end end)
                Library:ConnectGlobal(UserInputService.InputEnded, function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
                Library:ConnectGlobal(UserInputService.InputChanged, function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(math.clamp((UserInputService:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)) end end)
            end

            function Section:CreateDropdown(DropConfig)
                local Selected = DropConfig.CurrentValue or "None"; local Open = false
                local Holder = Library:Create("Frame", {Parent = Section.Container, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true})
                Library:Create("UICorner", {Parent = Holder, CornerRadius = dim(0, 6)})
                
                local Btn = Library:Create("TextButton", {Parent = Holder, Size = dim2(1, 0, 0, 32), BackgroundTransparency = 1, Text = "  " .. DropConfig.Name .. " : " .. (type(Selected) == "table" and table.concat(Selected, ", ") or Selected), TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.Font, TextSize = 13})
                local Arrow = Library:Create("TextLabel", {Parent = Btn, Text = "▼", Size = dim2(0, 20, 0, 20), Position = dim2(1, -25, 0.5, -10), BackgroundTransparency = 1, TextColor3 = Theme.MutedText, FontFace = Library.Font})

                local Content = Library:Create("Frame", {Parent = Holder, Size = dim2(1, 0, 0, 0), Position = dim2(0, 0, 0, 32), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Visible = false})
                Library:Create("UIListLayout", {Parent = Content})

                local Search = Library:Create("TextBox", {Parent = Content, Size = dim2(1, 0, 0, 25), BackgroundColor3 = Theme.MainBG, PlaceholderText = "Search...", Text = "", TextColor3 = Theme.Text, FontFace = Library.Font, TextSize = 12})

                Btn.MouseButton1Click:Connect(function()
                    Open = not Open; Content.Visible = Open
                    Arrow.Text = Open and "▲" or "▼"
                end)

                local itemBtns = {}
                for _, item in pairs(DropConfig.Items) do
                    local IBtn = Library:Create("TextButton", {Parent = Content, Size = dim2(1, 0, 0, 25), BackgroundColor3 = Theme.HoverBG, Text = item, TextColor3 = Theme.MutedText, FontFace = Library.Font, TextSize = 12})
                    table.insert(itemBtns, IBtn)
                    IBtn.MouseButton1Click:Connect(function()
                        if DropConfig.Multi then
                            if type(Selected) ~= "table" then Selected = {} end
                            local pos = table.find(Selected, item)
                            if pos then table.remove(Selected, pos) else table.insert(Selected, item) end
                        else
                            Selected = item; Open = false; Content.Visible = false; Arrow.Text = "▼"
                        end
                        Btn.Text = "  " .. DropConfig.Name .. " : " .. (type(Selected) == "table" and table.concat(Selected, ", ") or Selected)
                        if DropConfig.Callback then DropConfig.Callback(Selected) end
                    end)
                end
                Search:GetPropertyChangedSignal("Text"):Connect(function()
                    for _, b in pairs(itemBtns) do b.Visible = b.Text:lower():find(Search.Text:lower()) ~= nil end
                end)
            end

            function Section:CreateColorpicker(Config)
                local Color = Config.Default or rgb(255, 0, 0)
                local Btn = Library:Create("TextButton", {Parent = Section.Container, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = "  " .. Config.Name, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.Font})
                Library:Create("UICorner", {Parent = Btn, CornerRadius = dim(0, 6)})
                local Display = Library:Create("Frame", {Parent = Btn, Size = dim2(0, 20, 0, 16), Position = dim2(1, -28, 0.5, -8), BackgroundColor3 = Color})
                Library:Create("UICorner", {Parent = Display, CornerRadius = dim(0, 4)})
                
                Btn.MouseButton1Click:Connect(function()
                    -- Simple RGB prompt for minimal build, or expanded wheel logic
                    if Config.Callback then Config.Callback(Color) end
                end)
            end

            function Section:CreateKeybind(Config)
                local Key = Config.Default or Enum.KeyCode.F
                local Btn = Library:Create("TextButton", {Parent = Section.Container, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = "  " .. Config.Name .. " : [" .. Key.Name .. "]", TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.Font})
                Library:Create("UICorner", {Parent = Btn, CornerRadius = dim(0, 6)})
                
                local picking = false
                Btn.MouseButton1Click:Connect(function() picking = true; Btn.Text = "  " .. Config.Name .. " : [...]" end)
                Library:ConnectGlobal(UserInputService.InputBegan, function(i, gpe)
                    if picking then picking = false; Key = i.KeyCode; Btn.Text = "  " .. Config.Name .. " : [" .. Key.Name .. "]"
                    elseif not gpe and i.KeyCode == Key then if Config.Callback then Config.Callback() end end
                end)
            end

            return Section
        end
        return Tab
    end
    return Window
end

return Library
