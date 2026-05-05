--[[ 
    SEDSE UI / MONOLITH FINGERPAINT (Standardized Version)
    Full Rewrite with Automatic Cleanup, Dropdown Arrows, and Modern Syntax.
]]

local UserInputService = game:GetService("UserInputService") 
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

local Library = {
    Font = Font.new("rbxassetid://12187375716", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    MenuKeybind = Enum.KeyCode.RightControl,
    Instances = {},   -- For UI destruction
    Connections = {}  -- For cleaning up background inputs
}

--// Services & Themes //--
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
local NotifScreen = Library:Create("ScreenGui", {Parent = UIParent, Name = "SedseNotifications"})
table.insert(Library.Instances, NotifScreen)
local NotifContainer = Library:Create("Frame", {Parent = NotifScreen, Size = dim2(0, 300, 1, 0), Position = dim2(1, -310, 0, 0), BackgroundTransparency = 1})
Library:Create("UIListLayout", {Parent = NotifContainer, Padding = dim(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right})
Library:Create("UIPadding", {Parent = NotifContainer, PaddingBottom = dim(0, 20), PaddingRight = dim(0, 10)})

function Library:Notify(Config)
    local Type = Config.Type or "Info"
    local Text = Config.Content or "Notification"
    local TypeColors = { Success = rgb(0, 200, 100), Error = rgb(200, 50, 50), Info = Theme.Accent }
    
    local Notif = Library:Create("Frame", {Parent = NotifContainer, Size = dim2(0, 280, 0, 60), BackgroundColor3 = Theme.MainBG, Position = dim2(1, 10, 0, 0)})
    Library:Create("UICorner", {Parent = Notif, CornerRadius = dim(0, 6)})
    Library:Create("UIStroke", {Parent = Notif, Color = Theme.Outline})
    local Bar = Library:Create("Frame", {Parent = Notif, Size = dim2(0, 4, 1, 0), BackgroundColor3 = TypeColors[Type] or Theme.Accent})
    Library:Create("UICorner", {Parent = Bar})
    
    Library:Create("TextLabel", {Parent = Notif, Text = Text, Size = dim2(1, -40, 1, 0), Position = dim2(0, 20, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, FontFace = Library.Font, TextSize = 13, TextWrapped = true})
    
    Library:Tween(Notif, {Position = dim2(0, 0, 0, 0)}, 0.5)
    task.delay(Config.Duration or 5, function()
        Library:Tween(Notif, {Position = dim2(1, 10, 0, 0)}, 0.5).Completed:Connect(function() Notif:Destroy() end)
    end)
end

--// Boot Sequence //--
local function BootSequence(windowFrame, windowName)
    local boot = Library:Create("Frame", {Parent = windowFrame, Size = dim2(1, 0, 1, 0), BackgroundColor3 = rgb(0,0,0), ZIndex = 1000})
    local logo = Library:Create("TextLabel", {Parent = boot, Text = windowName, Position = dim2(0.5, 0, 0.45, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Theme.Text, FontFace = Library.Font, TextSize = 32, TextTransparency = 1, ZIndex = 1001})
    local bar = Library:Create("Frame", {Parent = boot, Size = dim2(0, 0, 0, 2), Position = dim2(0.5, -100, 0.6, 0), BackgroundColor3 = Theme.Accent, ZIndex = 1001})
    
    task.spawn(function()
        Library:Tween(logo, {TextTransparency = 0}, 1)
        Library:Tween(bar, {Size = dim2(0, 200, 0, 2)}, 2.5)
        task.wait(3)
        Library:Tween(boot, {BackgroundTransparency = 1}, 0.5)
        Library:Tween(logo, {TextTransparency = 1}, 0.5)
        Library:Tween(bar, {BackgroundTransparency = 1}, 0.5).Completed:Connect(function() boot:Destroy() end)
    end)
end

--// Main Window System //--
function Library:CreateWindow(Config)
    local WindowName = Config.Name or "Sedse UI"
    local Window = { Tabs = {} }
    
    local Screen = Library:Create("ScreenGui", {Parent = UIParent, Name = "SedseUI"})
    table.insert(Library.Instances, Screen)

    local Main = Library:Create("Frame", {Parent = Screen, Size = dim2(0, 650, 0, 450), Position = dim2(0.5, -325, 0.5, -225), BackgroundColor3 = Theme.MainBG})
    Library:Create("UICorner", {Parent = Main, CornerRadius = dim(0, 8)})
    Library:Create("UIStroke", {Parent = Main, Color = Theme.Outline})

    local Topbar = Library:Create("Frame", {Parent = Main, Size = dim2(1, 0, 0, 40), BackgroundColor3 = Theme.TopbarBG})
    Library:Create("UICorner", {Parent = Topbar, CornerRadius = dim(0, 8)})
    Library:Draggify(Main, Topbar)

    Library:Create("TextLabel", {Parent = Topbar, Text = WindowName, Size = dim2(1, -50, 1, 0), Position = dim2(0, 15, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, FontFace = Library.Font, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left})

    local CloseBtn = Library:Create("TextButton", {Parent = Topbar, Size = dim2(0, 30, 0, 24), Position = dim2(1, -36, 0.5, -12), BackgroundColor3 = Theme.TopbarBG, Text = "X", TextColor3 = Theme.MutedText, FontFace = Library.Font})
    CloseBtn.MouseButton1Click:Connect(function() Library:Destroy() end)

    local Sidebar = Library:Create("Frame", {Parent = Main, Position = dim2(0, 0, 0, 41), Size = dim2(0, 140, 1, -41), BackgroundColor3 = Theme.SidebarBG})
    local PageHolder = Library:Create("Frame", {Parent = Main, Position = dim2(0, 141, 0, 41), Size = dim2(1, -141, 1, -41), BackgroundTransparency = 1})
    Library:Create("UIListLayout", {Parent = Sidebar, Padding = dim(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center})
    Library:Create("UIPadding", {Parent = Sidebar, PaddingTop = dim(0, 10)})

    Library:ConnectGlobal(UserInputService.InputBegan, function(input, gpe) 
        if not gpe and input.KeyCode == Library.MenuKeybind then Main.Visible = not Main.Visible end 
    end)

    if Config.Loading then BootSequence(Main, WindowName) end

    function Window:CreateTab(TabConfig)
        local Tab = { Name = TabConfig.Name or "Tab" }
        local TabBtn = Library:Create("TextButton", {Parent = Sidebar, Size = dim2(1, -16, 0, 32), BackgroundColor3 = Theme.MainBG, Text = "  " .. Tab.Name, TextColor3 = Theme.MutedText, FontFace = Library.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false})
        Library:Create("UICorner", {Parent = TabBtn, CornerRadius = dim(0, 6)})
        Library:Create("UIStroke", {Parent = TabBtn, Color = Theme.Outline})

        local Page = Library:Create("ScrollingFrame", {Parent = PageHolder, Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y})
        Library:Create("UIListLayout", {Parent = Page, FillDirection = Enum.FillDirection.Horizontal, Padding = dim(0, 15)})
        Library:Create("UIPadding", {Parent = Page, PaddingLeft = dim(0, 15), PaddingRight = dim(0, 15), PaddingTop = dim(0, 15)})

        local LeftCol = Library:Create("Frame", {Parent = Page, Size = dim2(0.5, -8, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y})
        Library:Create("UIListLayout", {Parent = LeftCol, Padding = dim(0, 10)})
        local RightCol = Library:Create("Frame", {Parent = Page, Size = dim2(0.5, -8, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y})
        Library:Create("UIListLayout", {Parent = RightCol, Padding = dim(0, 10)})

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
            Library:Create("UIListLayout", {Parent = Section.Container, Padding = dim(0, 8)})
            Library:Create("UIPadding", {Parent = Section.Container, PaddingTop = dim(0, 10), PaddingBottom = dim(0, 10), PaddingLeft = dim(0, 10), PaddingRight = dim(0, 10)})
            
            Library:Create("TextLabel", {Parent = Section.Container, Text = SecConfig.Name or "Section", Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, TextColor3 = Theme.Accent, FontFace = Library.Font, TextSize = 14})

            function Section:CreateLabel(LblConfig)
                local Lbl = Library:Create("TextLabel", {Parent = Section.Container, Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, Text = LblConfig.Text or "Label", TextColor3 = Theme.MutedText, FontFace = Library.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.Y})
                return { Set = function(self, txt) Lbl.Text = txt end }
            end

            function Section:CreateButton(BtnConfig)
                local B = Library:Create("TextButton", {Parent = Section.Container, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = BtnConfig.Name or "Button", TextColor3 = Theme.Text, FontFace = Library.Font, TextSize = 13})
                Library:Create("UICorner", {Parent = B, CornerRadius = dim(0, 6)})
                Library:Create("UIStroke", {Parent = B, Color = Theme.Outline})
                B.MouseButton1Click:Connect(function() Library:Tween(B, {BackgroundColor3 = Theme.HoverBG}, 0.1); task.wait(0.1); Library:Tween(B, {BackgroundColor3 = Theme.ElementBG}, 0.1); if BtnConfig.Callback then BtnConfig.Callback() end end)
            end

            function Section:CreateToggle(TogConfig)
                local State = TogConfig.CurrentValue or false
                local Btn = Library:Create("TextButton", {Parent = Section.Container, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = "  " .. TogConfig.Name, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.Font, TextSize = 13})
                Library:Create("UICorner", {Parent = Btn, CornerRadius = dim(0, 6)})
                local Ind = Library:Create("Frame", {Parent = Btn, Size = dim2(0, 16, 0, 16), Position = dim2(1, -24, 0.5, -8), BackgroundColor3 = State and Theme.Accent or Theme.MainBG})
                Library:Create("UICorner", {Parent = Ind, CornerRadius = dim(0, 4)})

                local function Update(val) State = val; Library:Tween(Ind, {BackgroundColor3 = State and Theme.Accent or Theme.MainBG}, 0.2); if TogConfig.Callback then TogConfig.Callback(State) end end
                Btn.MouseButton1Click:Connect(function() Update(not State) end)
                return { Set = Update }
            end

            function Section:CreateSlider(SldConfig)
                local Min, Max, Value = SldConfig.Range[1], SldConfig.Range[2], SldConfig.CurrentValue or SldConfig.Range[1]
                local SFrame = Library:Create("Frame", {Parent = Section.Container, Size = dim2(1, 0, 0, 50), BackgroundColor3 = Theme.ElementBG})
                Library:Create("UICorner", {Parent = SFrame, CornerRadius = dim(0, 6)})
                local ValLbl = Library:Create("TextLabel", {Parent = SFrame, Text = tostring(Value), Size = dim2(0, 50, 0, 25), Position = dim2(1, -55, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Accent, FontFace = Library.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right})
                local BarBg = Library:Create("Frame", {Parent = SFrame, Size = dim2(1, -20, 0, 6), Position = dim2(0, 10, 0, 35), BackgroundColor3 = Theme.MainBG})
                local Fill = Library:Create("Frame", {Parent = BarBg, Size = dim2((Value - Min)/(Max - Min), 0, 1, 0), BackgroundColor3 = Theme.Accent})
                
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

            function Section:CreateDropdown(DropConfig)
                local Selected = DropConfig.CurrentValue or "None"; local Open = false
                local Holder = Library:Create("Frame", {Parent = Section.Container, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true})
                Library:Create("UICorner", {Parent = Holder, CornerRadius = dim(0, 6)})
                
                local Btn = Library:Create("TextButton", {Parent = Holder, Size = dim2(1, 0, 0, 32), BackgroundTransparency = 1, Text = "  " .. DropConfig.Name .. " : " .. Selected, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.Font, TextSize = 13})
                
                local Arrows = Library:Create("Frame", {Parent = Btn, Size = dim2(0, 20, 1, 0), Position = dim2(1, -25, 0, 0), BackgroundTransparency = 1})
                local UpArrow = Library:Create("TextLabel", {Parent = Arrows, Text = "▲", Size = dim2(1, 0, 0.5, 0), BackgroundTransparency = 1, TextColor3 = Theme.MutedText, TextSize = 8})
                local DownArrow = Library:Create("TextLabel", {Parent = Arrows, Text = "▼", Position = dim2(0, 0, 0.5, 0), Size = dim2(1, 0, 0.5, 0), BackgroundTransparency = 1, TextColor3 = Theme.Accent, TextSize = 8})

                local Content = Library:Create("Frame", {Parent = Holder, Size = dim2(1, 0, 0, 0), Position = dim2(0, 0, 0, 32), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y})
                Library:Create("UIListLayout", {Parent = Content})

                Btn.MouseButton1Click:Connect(function()
                    Open = not Open
                    Library:Tween(UpArrow, {TextColor3 = Open and Theme.Accent or Theme.MutedText}, 0.2)
                    Library:Tween(DownArrow, {TextColor3 = Open and Theme.MutedText or Theme.Accent}, 0.2)
                    Holder.ClipsDescendants = not Open -- This opens/closes the menu
                end)

                for _, item in pairs(DropConfig.Items) do
                    local IBtn = Library:Create("TextButton", {Parent = Content, Size = dim2(1, 0, 0, 25), BackgroundColor3 = Theme.HoverBG, Text = item, TextColor3 = Theme.MutedText, FontFace = Library.Font, TextSize = 12})
                    IBtn.MouseButton1Click:Connect(function()
                        Selected = item; Btn.Text = "  " .. DropConfig.Name .. " : " .. Selected
                        Open = false; Holder.ClipsDescendants = true
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
