--[[ 
    SEDSE UI (Modern & Minimal Rewrite)
    Sleek styling, rotating dropdown arrows, clean typography, and fixed layout sorting.
]]

local UserInputService = game:GetService("UserInputService") 
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {
    Font = Enum.Font.GothamMedium, -- Modern, clean font
    MenuKeybind = Enum.KeyCode.RightControl,
    Instances = {},   
    Connections = {}  
}

--// Modern Theme //--
local dim2, dim, rgb = UDim2.new, UDim.new, Color3.fromRGB
local Theme = {
    MainBG = rgb(20, 20, 20),      -- Sleeker dark background
    SidebarBG = rgb(15, 15, 15),
    TopbarBG = rgb(15, 15, 15),
    SectionBG = rgb(25, 25, 25),
    ElementBG = rgb(32, 32, 32),
    HoverBG = rgb(40, 40, 40),
    Accent = rgb(100, 140, 255),   -- Soft Modern Blue
    Text = rgb(240, 240, 240),
    MutedText = rgb(130, 130, 130),
    Outline = rgb(45, 45, 45)      -- Subtle borders
}

--// Helper Functions //--
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
    table.clear(Library.Connections)
    table.clear(Library.Instances)
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

--// Notification System //--
local NotifScreen = Library:Create("ScreenGui", {Parent = UIParent, Name = "SedseNotifs"})
table.insert(Library.Instances, NotifScreen)
local NotifContainer = Library:Create("Frame", {Parent = NotifScreen, Size = dim2(0, 300, 1, 0), Position = dim2(1, -310, 0, 0), BackgroundTransparency = 1})
Library:Create("UIListLayout", {Parent = NotifContainer, Padding = dim(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder})
Library:Create("UIPadding", {Parent = NotifContainer, PaddingBottom = dim(0, 20), PaddingRight = dim(0, 10)})

function Library:Notify(Config)
    local TypeColors = { Success = rgb(80, 220, 120), Error = rgb(255, 100, 100), Info = Theme.Accent }
    local Notif = Library:Create("Frame", {Parent = NotifContainer, Size = dim2(0, 280, 0, 50), BackgroundColor3 = Theme.MainBG, Position = dim2(1, 10, 0, 0)})
    Library:Create("UICorner", {Parent = Notif, CornerRadius = dim(0, 4)})
    Library:Create("UIStroke", {Parent = Notif, Color = Theme.Outline})
    local Bar = Library:Create("Frame", {Parent = Notif, Size = dim2(0, 3, 1, 0), BackgroundColor3 = TypeColors[Config.Type or "Info"] or Theme.Accent})
    Library:Create("UICorner", {Parent = Bar, CornerRadius = dim(0, 4)})
    
    Library:Create("TextLabel", {Parent = Notif, Text = Config.Content or "...", Size = dim2(1, -25, 1, 0), Position = dim2(0, 15, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Library.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
    
    Library:Tween(Notif, {Position = dim2(0, 0, 0, 0)}, 0.4)
    task.delay(Config.Duration or 5, function()
        Library:Tween(Notif, {Position = dim2(1, 10, 0, 0)}, 0.4).Completed:Connect(function() Notif:Destroy() end)
    end)
end

--// Main Window System //--
function Library:CreateWindow(Config)
    local Window = { Tabs = {} }
    
    local Screen = Library:Create("ScreenGui", {Parent = UIParent, Name = "SedseUI"})
    table.insert(Library.Instances, Screen)

    local Main = Library:Create("Frame", {Parent = Screen, Size = dim2(0, 650, 0, 450), Position = dim2(0.5, -325, 0.5, -225), BackgroundColor3 = Theme.MainBG})
    Library:Create("UICorner", {Parent = Main, CornerRadius = dim(0, 6)})
    Library:Create("UIStroke", {Parent = Main, Color = Theme.Outline})

    local Topbar = Library:Create("Frame", {Parent = Main, Size = dim2(1, 0, 0, 38), BackgroundColor3 = Theme.TopbarBG})
    Library:Create("UICorner", {Parent = Topbar, CornerRadius = dim(0, 6)})
    Library:Create("Frame", {Parent = Topbar, Size = dim2(1, 0, 0, 6), Position = dim2(0, 0, 1, -6), BackgroundColor3 = Theme.TopbarBG, BorderSizePixel = 0})
    Library:Create("Frame", {Parent = Topbar, Size = dim2(1, 0, 0, 1), Position = dim2(0, 0, 1, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0})
    Library:Draggify(Main, Topbar)

    Library:Create("TextLabel", {Parent = Topbar, Text = Config.Name or "Sedse UI", Size = dim2(1, -50, 1, 0), Position = dim2(0, 15, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Library.Font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})

    local CloseBtn = Library:Create("TextButton", {Parent = Topbar, Size = dim2(0, 24, 0, 24), Position = dim2(1, -32, 0.5, -12), BackgroundColor3 = Theme.TopbarBG, Text = "✕", TextColor3 = Theme.MutedText, Font = Library.Font, TextSize = 14})
    Library:Create("UICorner", {Parent = CloseBtn, CornerRadius = dim(0, 4)})
    CloseBtn.MouseButton1Click:Connect(function() Library:Destroy() end)

    local Sidebar = Library:Create("Frame", {Parent = Main, Position = dim2(0, 0, 0, 39), Size = dim2(0, 140, 1, -39), BackgroundColor3 = Theme.SidebarBG})
    local PageHolder = Library:Create("Frame", {Parent = Main, Position = dim2(0, 141, 0, 39), Size = dim2(1, -141, 1, -39), BackgroundTransparency = 1})
    Library:Create("UIListLayout", {Parent = Sidebar, Padding = dim(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder})
    Library:Create("UIPadding", {Parent = Sidebar, PaddingTop = dim(0, 10)})

    Library:ConnectGlobal(UserInputService.InputBegan, function(input, gpe) 
        if not gpe and input.KeyCode == Library.MenuKeybind then Main.Visible = not Main.Visible end 
    end)

    function Window:CreateTab(TabConfig)
        local Tab = { Name = TabConfig.Name or "Tab" }
        local TabBtn = Library:Create("TextButton", {Parent = Sidebar, Size = dim2(1, -16, 0, 30), BackgroundColor3 = Theme.MainBG, Text = "  " .. Tab.Name, TextColor3 = Theme.MutedText, Font = Library.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false})
        Library:Create("UICorner", {Parent = TabBtn, CornerRadius = dim(0, 4)})

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
            Library:Create("UICorner", {Parent = Section.Container, CornerRadius = dim(0, 6)})
            Library:Create("UIStroke", {Parent = Section.Container, Color = Theme.Outline})
            Library:Create("UIListLayout", {Parent = Section.Container, Padding = dim(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}) -- Fixed Sorting!
            Library:Create("UIPadding", {Parent = Section.Container, Padding = dim(0, 10)})
            
            Library:Create("TextLabel", {Parent = Section.Container, Text = SecConfig.Name or "Section", Size = dim2(1, 0, 0, 16), BackgroundTransparency = 1, TextColor3 = Theme.Accent, Font = Library.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
            Library:Create("Frame", {Parent = Section.Container, Size = dim2(1, 0, 0, 1), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0})

            function Section:CreateButton(BtnConfig)
                local B = Library:Create("TextButton", {Parent = Section.Container, Size = dim2(1, 0, 0, 30), BackgroundColor3 = Theme.ElementBG, Text = BtnConfig.Name or "Button", TextColor3 = Theme.Text, Font = Library.Font, TextSize = 12, AutoButtonColor = false})
                Library:Create("UICorner", {Parent = B, CornerRadius = dim(0, 4)})
                Library:Create("UIStroke", {Parent = B, Color = Theme.Outline})
                B.MouseButton1Click:Connect(function() 
                    Library:Tween(B, {BackgroundColor3 = Theme.HoverBG}, 0.1)
                    task.wait(0.1)
                    Library:Tween(B, {BackgroundColor3 = Theme.ElementBG}, 0.1)
                    if BtnConfig.Callback then BtnConfig.Callback() end 
                end)
            end

            -- Modern Switch Toggle
            function Section:CreateToggle(TogConfig)
                local State = TogConfig.CurrentValue or false
                local Btn = Library:Create("TextButton", {Parent = Section.Container, Size = dim2(1, 0, 0, 30), BackgroundColor3 = Theme.ElementBG, Text = "  " .. TogConfig.Name, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Font = Library.Font, TextSize = 12, AutoButtonColor = false})
                Library:Create("UICorner", {Parent = Btn, CornerRadius = dim(0, 4)})
                Library:Create("UIStroke", {Parent = Btn, Color = Theme.Outline})
                
                local SwitchBg = Library:Create("Frame", {Parent = Btn, Size = dim2(0, 28, 0, 14), Position = dim2(1, -38, 0.5, -7), BackgroundColor3 = State and Theme.Accent or Theme.MainBG})
                Library:Create("UICorner", {Parent = SwitchBg, CornerRadius = dim(1, 0)})
                Library:Create("UIStroke", {Parent = SwitchBg, Color = Theme.Outline})
                
                local SwitchDot = Library:Create("Frame", {Parent = SwitchBg, Size = dim2(0, 10, 0, 10), Position = State and dim2(1, -12, 0.5, -5) or dim2(0, 2, 0.5, -5), BackgroundColor3 = Theme.Text})
                Library:Create("UICorner", {Parent = SwitchDot, CornerRadius = dim(1, 0)})

                local function Update(val) 
                    State = val
                    Library:Tween(SwitchBg, {BackgroundColor3 = State and Theme.Accent or Theme.MainBG}, 0.2)
                    Library:Tween(SwitchDot, {Position = State and dim2(1, -12, 0.5, -5) or dim2(0, 2, 0.5, -5)}, 0.2)
                    if TogConfig.Callback then TogConfig.Callback(State) end 
                end
                Btn.MouseButton1Click:Connect(function() Update(not State) end)
                return { Set = Update }
            end

            -- Minimal Slider
            function Section:CreateSlider(SldConfig)
                local Min, Max, Value = SldConfig.Range[1], SldConfig.Range[2], SldConfig.CurrentValue or SldConfig.Range[1]
                local SFrame = Library:Create("Frame", {Parent = Section.Container, Size = dim2(1, 0, 0, 40), BackgroundColor3 = Theme.ElementBG})
                Library:Create("UICorner", {Parent = SFrame, CornerRadius = dim(0, 4)})
                Library:Create("UIStroke", {Parent = SFrame, Color = Theme.Outline})
                
                Library:Create("TextLabel", {Parent = SFrame, Text = "  " .. SldConfig.Name, Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, TextColor3 = Theme.MutedText, Font = Library.Font, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})
                local ValLbl = Library:Create("TextLabel", {Parent = SFrame, Text = tostring(Value), Size = dim2(0, 50, 0, 20), Position = dim2(1, -55, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Library.Font, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right})
                
                local BarBg = Library:Create("Frame", {Parent = SFrame, Size = dim2(1, -20, 0, 4), Position = dim2(0, 10, 0, 28), BackgroundColor3 = Theme.MainBG})
                Library:Create("UICorner", {Parent = BarBg, CornerRadius = dim(1, 0)})
                local Fill = Library:Create("Frame", {Parent = BarBg, Size = dim2((Value - Min)/(Max - Min), 0, 1, 0), BackgroundColor3 = Theme.Accent})
                Library:Create("UICorner", {Parent = Fill, CornerRadius = dim(1, 0)})
                
                local Dragging = false
                local function Update(pct)
                    Value = math.floor(Min + ((Max - Min) * pct)); Fill.Size = dim2(pct, 0, 1, 0); ValLbl.Text = tostring(Value)
                    if SldConfig.Callback then SldConfig.Callback(Value) end
                end

                BarBg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; Update(math.clamp((UserInputService:GetMouseLocation().X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)) end end)
                Library:ConnectGlobal(UserInputService.InputEnded, function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
                Library:ConnectGlobal(UserInputService.InputChanged, function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(math.clamp((UserInputService:GetMouseLocation().X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)) end end)
                return { Set = function(self, v) Update((v - Min)/(Max - Min)) end }
            end

            -- Rotating Arrow Dropdown
            function Section:CreateDropdown(DropConfig)
                local Selected = DropConfig.CurrentValue or DropConfig.Items[1] or "None"; local Open = false
                
                local Holder = Library:Create("Frame", {Parent = Section.Container, Size = dim2(1, 0, 0, 30), BackgroundColor3 = Theme.ElementBG, AutomaticSize = Enum.AutomaticSize.Y})
                Library:Create("UICorner", {Parent = Holder, CornerRadius = dim(0, 4)})
                Library:Create("UIStroke", {Parent = Holder, Color = Theme.Outline})
                
                local Btn = Library:Create("TextButton", {Parent = Holder, Size = dim2(1, 0, 0, 30), BackgroundTransparency = 1, Text = "  " .. DropConfig.Name .. " : " .. Selected, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Font = Library.Font, TextSize = 12, AutoButtonColor = false})
                
                -- The Single Arrow!
                local Arrow = Library:Create("TextLabel", {Parent = Btn, Text = "▼", Size = dim2(0, 20, 0, 20), Position = dim2(1, -25, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, TextColor3 = Theme.MutedText, Font = Library.Font, TextSize = 10})

                local Content = Library:Create("Frame", {Parent = Holder, Size = dim2(1, 0, 0, 0), Position = dim2(0, 0, 0, 30), BackgroundTransparency = 1, Visible = false, AutomaticSize = Enum.AutomaticSize.Y})
                Library:Create("UIListLayout", {Parent = Content, SortOrder = Enum.SortOrder.LayoutOrder})
                Library:Create("UIPadding", {Parent = Content, PaddingBottom = dim(0, 5)})

                Btn.MouseButton1Click:Connect(function()
                    Open = not Open
                    Content.Visible = Open
                    -- Rotate smoothly: 0 = ▼ (closed), 180 = ▲ (open)
                    Library:Tween(Arrow, {Rotation = Open and 180 or 0}, 0.2)
                end)

                for _, item in ipairs(DropConfig.Items) do
                    local IBtn = Library:Create("TextButton", {Parent = Content, Size = dim2(1, 0, 0, 26), BackgroundColor3 = Theme.HoverBG, Text = "  " .. item, TextColor3 = Theme.MutedText, Font = Library.Font, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false})
                    Library:Create("UICorner", {Parent = IBtn, CornerRadius = dim(0, 4)})
                    
                    IBtn.MouseButton1Click:Connect(function()
                        Selected = item; Btn.Text = "  " .. DropConfig.Name .. " : " .. Selected
                        Open = false; Content.Visible = false
                        Library:Tween(Arrow, {Rotation = 0}, 0.2)
                        if DropConfig.Callback then DropConfig.Callback(item) end
                    end)
                end
            end

            return Section
        end
        return Tab
    end
    return Window
end

return Library
