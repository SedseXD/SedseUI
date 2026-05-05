--[[ 
    SEDSE UI / MONOLITH FINGERPAINT LIBRARY (Rewritten & Standardized)
    Designed for: loadstring execution
    Format: Standard (Library:CreateWindow, Window:CreateTab, etc.)
]]

local UserInputService = game:GetService("UserInputService") 
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

local Library = {
    Font = Font.new("rbxassetid://12187375716", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    MenuKeybind = Enum.KeyCode.RightControl,
    Instances = {} -- Used to keep track of UIs for the Destroy method
}

-- Safe Parent Getter
local function GetUIParent()
    local success, parent = pcall(function() return gethui and gethui() end)
    if success and parent then return parent end
    success, parent = pcall(function() return game:GetService("CoreGui") end)
    if success and parent then return parent end
    return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local UIParent = GetUIParent()

-- Shorthands & Theme
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

function Library:Draggify(frame, drag_area)
    local dragging, startPos, startInput
    (drag_area or frame).InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; startInput = input.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            frame.Position = dim2(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

--// Notification System Setup //--
local NotifScreen = Library:Create("ScreenGui", {Parent = UIParent, Name = "SedseNotifications"})
table.insert(Library.Instances, NotifScreen)

local NotifContainer = Library:Create("Frame", {
    Parent = NotifScreen, Size = dim2(0, 300, 1, 0), Position = dim2(1, -310, 0, 0), BackgroundTransparency = 1
})
Library:Create("UIListLayout", { Parent = NotifContainer, Padding = dim(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right })
Library:Create("UIPadding", {Parent = NotifContainer, PaddingBottom = dim(0, 20), PaddingRight = dim(0, 10)})

function Library:Notify(Config)
    local Type = Config.Type or "Info"
    local Duration = Config.Duration or 5
    local Text = Config.Content or Config.Text or "Notification"
    
    local TypeColors = { Success = rgb(0, 200, 100), Error = rgb(200, 50, 50), Info = Theme.Accent }
    local AccentColor = TypeColors[Type] or TypeColors.Info
    local TypeIcons = { Success = "lucide:check-circle", Error = "lucide:alert-circle", Info = "lucide:info" }

    local Notif = Library:Create("Frame", {
        Parent = NotifContainer, Size = dim2(0, 280, 0, 60), BackgroundColor3 = Theme.MainBG, Position = dim2(1, 10, 0, 0), BorderSizePixel = 0
    })
    Library:Create("UICorner", {Parent = Notif, CornerRadius = dim(0, 6)})
    Library:Create("UIStroke", {Parent = Notif, Color = Theme.Outline, Thickness = 1})
    local Bar = Library:Create("Frame", { Parent = Notif, Size = dim2(0, 4, 1, 0), BackgroundColor3 = AccentColor, BorderSizePixel = 0 })
    Library:Create("UICorner", {Parent = Bar, CornerRadius = dim(0, 6)})
    
    local Label = Library:Create("TextLabel", {
        Parent = Notif, Text = Text, Size = dim2(1, -45, 1, 0), Position = dim2(0, 40, 0, 0),
        BackgroundTransparency = 1, TextColor3 = Theme.Text, FontFace = Library.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
    })

    Library:Tween(Notif, {Position = dim2(0, 0, 0, 0)}, 0.5)
    task.delay(Duration, function()
        local out = Library:Tween(Notif, {Position = dim2(1, 10, 0, 0)}, 0.5)
        out.Completed:Connect(function() Notif:Destroy() end)
    end)
end

--// Destroy & Settings //--
function Library:Destroy()
    for _, instance in pairs(Library.Instances) do
        if instance and instance.Parent then instance:Destroy() end
    end
end

function Library:SetMenuKeybind(Key)
    Library.MenuKeybind = Key
end

--// Premium & Icons Support //--
local function PremiumOverlay(parent)
    local overlay = Library:Create("Frame", { Parent = parent, Size = dim2(1, 0, 1, 0), BackgroundColor3 = Theme.MainBG, BackgroundTransparency = 0.3, ZIndex = 10 })
    Library:Create("UICorner", {Parent = overlay, CornerRadius = dim(0, 6)})
    Library:Create("TextButton", { Parent = overlay, Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Text = "🔒 Premium", TextColor3 = Theme.Accent, FontFace = Library.Font, ZIndex = 12 })
end

--// Loading Sequence //--
local function BootSequence(windowFrame, windowName)
    local main = Library:Create("Frame", {
        Parent = windowFrame, Size = dim2(1, 0, 1, 0), BackgroundColor3 = rgb(0, 0, 0), ZIndex = 1000, BorderSizePixel = 0
    })
    local logo = Library:Create("TextLabel", {
        Parent = main, Text = windowName, Position = dim2(0.5, 0, 0.4, 0), AnchorPoint = Vector2.new(0.5, 0.5), Size = dim2(0, 200, 0, 50), BackgroundTransparency = 1, TextColor3 = Theme.Text, FontFace = Library.Font, TextSize = 32, TextTransparency = 1, ZIndex = 1001
    })
    local barBg = Library:Create("Frame", {
        Parent = main, Size = dim2(0, 200, 0, 4), Position = dim2(0.5, 0, 0.6, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, ZIndex = 1001
    })
    Library:Create("UICorner", {Parent = barBg})
    local barFill = Library:Create("Frame", { Parent = barBg, Size = dim2(0, 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, ZIndex = 1002 })
    Library:Create("UICorner", {Parent = barFill})

    task.spawn(function()
        Library:Tween(logo, {TextTransparency = 0}, 1)
        task.wait(0.5)
        local steps = {0.2, 0.5, 0.8, 1}
        for _, pct in ipairs(steps) do
            Library:Tween(barFill, {Size = dim2(pct, 0, 1, 0)}, 0.5)
            task.wait(0.6)
        end
        Library:Tween(logo, {TextTransparency = 1}, 0.5)
        Library:Tween(barFill, {BackgroundTransparency = 1}, 0.3)
        Library:Tween(barBg, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.5)
        local fadeOut = Library:Tween(main, {BackgroundTransparency = 1}, 1)
        fadeOut.Completed:Connect(function() main:Destroy() end)
    end)
end

--// Window System //--
function Library:CreateWindow(Config)
    local WindowName = Config.Name or Config.Title or "Sedse UI"
    local Window = { Tabs = {} }
    
    local Screen = Library:Create("ScreenGui", {Parent = UIParent, Name = "SedseUI", ResetOnSpawn = false})
    table.insert(Library.Instances, Screen)

    local Main = Library:Create("Frame", {
        Parent = Screen, Size = dim2(0, 650, 0, 450), Position = dim2(0.5, -325, 0.5, -225), BackgroundColor3 = Theme.MainBG, BorderSizePixel = 0
    })
    Library:Create("UICorner", {Parent = Main, CornerRadius = dim(0, 8)})
    Library:Create("UIStroke", {Parent = Main, Color = Theme.Outline, Thickness = 1})

    local Topbar = Library:Create("Frame", { Parent = Main, Size = dim2(1, 0, 0, 40), BackgroundColor3 = Theme.TopbarBG, BorderSizePixel = 0 })
    Library:Create("UICorner", {Parent = Topbar, CornerRadius = dim(0, 8)})
    Library:Create("Frame", {Parent = Topbar, Size = dim2(1, 0, 0, 10), Position = dim2(0, 0, 1, -10), BackgroundColor3 = Theme.TopbarBG, BorderSizePixel = 0}) 
    Library:Create("Frame", {Parent = Topbar, Size = dim2(1, 0, 0, 1), Position = dim2(0, 0, 1, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0}) 
    Library:Draggify(Main, Topbar)

    Library:Create("TextLabel", {
        Parent = Topbar, Text = WindowName, Size = dim2(1, -50, 1, 0), Position = dim2(0, 15, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.Font, TextSize = 16
    })

    local CloseBtn = Library:Create("TextButton", { Parent = Topbar, Size = dim2(0, 30, 0, 24), Position = dim2(1, -36, 0.5, -12), BackgroundColor3 = Theme.TopbarBG, Text = "X", TextColor3 = Theme.MutedText, AutoButtonColor = false })
    Library:Create("UICorner", {Parent = CloseBtn, CornerRadius = dim(0, 4)})
    CloseBtn.MouseButton1Click:Connect(function() Screen:Destroy() end)

    local Sidebar = Library:Create("Frame", { Parent = Main, Position = dim2(0, 0, 0, 41), Size = dim2(0, 140, 1, -41), BackgroundColor3 = Theme.SidebarBG, BorderSizePixel = 0 })
    Library:Create("Frame", {Parent = Sidebar, Size = dim2(0, 1), Position = dim2(1, 0, 0, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0})
    local PageHolder = Library:Create("Frame", { Parent = Main, Position = dim2(0, 141, 0, 41), Size = dim2(1, -141, 1, -41), BackgroundTransparency = 1 })
    Library:Create("UIListLayout", {Parent = Sidebar, Padding = dim(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center})
    Library:Create("UIPadding", {Parent = Sidebar, PaddingTop = dim(0, 10)})

    -- Input Toggle Logic
    UserInputService.InputBegan:Connect(function(input, gpe) 
        if not gpe and input.KeyCode == Library.MenuKeybind then 
            Main.Visible = not Main.Visible 
        end 
    end)

    if Config.Loading then BootSequence(Main, WindowName) end

    --// Tab System //--
    function Window:CreateTab(TabConfig)
        local TabName = TabConfig.Name or "Tab"
        local Tab = { Name = TabName }

        local TabBtn = Library:Create("TextButton", { Parent = Sidebar, Size = dim2(1, -16, 0, 32), BackgroundColor3 = Theme.MainBG, Text = "  " .. TabName, TextColor3 = Theme.MutedText, FontFace = Library.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false })
        Library:Create("UICorner", {Parent = TabBtn, CornerRadius = dim(0, 6)}); Library:Create("UIStroke", {Parent = TabBtn, Color = Theme.Outline, Thickness = 1})

        local Page = Library:Create("ScrollingFrame", { Parent = PageHolder, Size = dim2(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y })
        Library:Create("UIListLayout", {Parent = Page, FillDirection = Enum.FillDirection.Horizontal, Padding = dim(0, 15), SortOrder = Enum.SortOrder.LayoutOrder})
        Library:Create("UIPadding", {Parent = Page, PaddingLeft = dim(0, 15), PaddingRight = dim(0, 15), PaddingTop = dim(0, 15), PaddingBottom = dim(0, 15)})

        local LeftCol = Library:Create("Frame", { Parent = Page, Size = dim2(0.5, -8, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
        Library:Create("UIListLayout", {Parent = LeftCol, Padding = dim(0, 10)})
        local RightCol = Library:Create("Frame", { Parent = Page, Size = dim2(0.5, -8, 0, 0), Position = dim2(0.5, 8, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y })
        Library:Create("UIListLayout", {Parent = RightCol, Padding = dim(0, 10)})

        if #Window.Tabs == 0 then
            Page.Visible = true; TabBtn.TextColor3 = Theme.Text; TabBtn.BackgroundColor3 = Theme.ElementBG
        end
        table.insert(Window.Tabs, {Btn = TabBtn, Page = Page})

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do 
                t.Page.Visible = false; t.Btn.TextColor3 = Theme.MutedText; Library:Tween(t.Btn, {BackgroundColor3 = Theme.MainBG}, 0.15)
            end
            Page.Visible = true; TabBtn.TextColor3 = Theme.Text; Library:Tween(TabBtn, {BackgroundColor3 = Theme.ElementBG}, 0.15)
        end)

        --// Section System //--
        function Tab:CreateSection(SecConfig)
            local SecName = SecConfig.Name or "Section"
            local Side = string.lower(SecConfig.Side or "left")
            local ParentCol = (Side == "right") and RightCol or LeftCol

            local Section = {}
            Section.Container = Library:Create("Frame", { Parent = ParentCol, Size = dim2(1, 0, 0, 0), BackgroundColor3 = Theme.SectionBG, AutomaticSize = Enum.AutomaticSize.Y })
            Library:Create("UICorner", {Parent = Section.Container, CornerRadius = dim(0, 8)}); Library:Create("UIStroke", {Parent = Section.Container, Color = Theme.Outline, Thickness = 1})
            Library:Create("UIListLayout", {Parent = Section.Container, Padding = dim(0, 8)}); Library:Create("UIPadding", {Parent = Section.Container, PaddingTop = dim(0, 10), PaddingBottom = dim(0, 10), PaddingLeft = dim(0, 10), PaddingRight = dim(0, 10)})
            
            Library:Create("TextLabel", { Parent = Section.Container, Text = SecName, Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, TextColor3 = Theme.Accent, FontFace = Library.Font, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center })
            Library:Create("Frame", {Parent = Section.Container, Size = dim2(1, 0, 0, 1), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0})

            --// Element Creation inside Section //--
            function Section:CreateLabel(LblConfig)
                local Lbl = Library:Create("TextLabel", { Parent = Section.Container, Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, Text = LblConfig.Text or "Label", TextColor3 = Theme.MutedText, FontFace = Library.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y })
                return { Set = function(self, newTxt) Lbl.Text = newTxt end }
            end

            function Section:CreateButton(BtnConfig)
                local B = Library:Create("TextButton", { Parent = Section.Container, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = " " .. (BtnConfig.Name or "Button"), TextColor3 = Theme.Text, FontFace = Library.Font, TextSize = 13, AutoButtonColor = false })
                Library:Create("UICorner", {Parent = B, CornerRadius = dim(0, 6)}); Library:Create("UIStroke", {Parent = B, Color = Theme.Outline, Thickness = 1})
                if BtnConfig.Premium then PremiumOverlay(B) end
                
                B.MouseButton1Click:Connect(function() 
                    Library:Tween(B, {BackgroundColor3 = Theme.HoverBG}, 0.1); task.wait(0.1); Library:Tween(B, {BackgroundColor3 = Theme.ElementBG}, 0.1)
                    if BtnConfig.Callback then BtnConfig.Callback() end 
                end)
            end

            function Section:CreateToggle(TogConfig)
                local TogState = TogConfig.CurrentValue or false
                local Btn = Library:Create("TextButton", { Parent = Section.Container, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG, Text = "  " .. (TogConfig.Name or "Toggle"), TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.Font, TextSize = 13, AutoButtonColor = false })
                Library:Create("UICorner", {Parent = Btn, CornerRadius = dim(0, 6)}); Library:Create("UIStroke", {Parent = Btn, Color = Theme.Outline, Thickness = 1})
                local Indicator = Library:Create("Frame", { Parent = Btn, Size = dim2(0, 16, 0, 16), Position = dim2(1, -24, 0.5, -8), BackgroundColor3 = TogState and Theme.Accent or Theme.MainBG })
                Library:Create("UICorner", {Parent = Indicator, CornerRadius = dim(0, 4)}); Library:Create("UIStroke", {Parent = Indicator, Color = Theme.Outline, Thickness = 1})

                local function UpdateToggle(value)
                    TogState = value
                    Library:Tween(Indicator, {BackgroundColor3 = TogState and Theme.Accent or Theme.MainBG}, 0.2)
                    if TogConfig.Callback then TogConfig.Callback(TogState) end
                end

                Btn.MouseButton1Click:Connect(function() UpdateToggle(not TogState) end)
                return { Set = function(self, val) UpdateToggle(val) end }
            end

            function Section:CreateSlider(SldConfig)
                local Min, Max, Value = SldConfig.Range[1] or 0, SldConfig.Range[2] or 100, SldConfig.CurrentValue or SldConfig.Range[1] or 0
                local Increment = SldConfig.Increment or 1

                local SFrame = Library:Create("Frame", { Parent = Section.Container, Size = dim2(1, 0, 0, 50), BackgroundColor3 = Theme.ElementBG })
                Library:Create("UICorner", {Parent = SFrame, CornerRadius = dim(0, 6)}); Library:Create("UIStroke", {Parent = SFrame, Color = Theme.Outline, Thickness = 1})
                
                Library:Create("TextLabel", { Parent = SFrame, Text = "  " .. (SldConfig.Name or "Slider"), Size = dim2(1, 0, 0, 25), BackgroundTransparency = 1, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Library.Font, TextSize = 13 })
                local ValLbl = Library:Create("TextLabel", { Parent = SFrame, Text = tostring(Value), Size = dim2(0, 50, 0, 25), Position = dim2(1, -55, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Right, FontFace = Library.Font, TextSize = 13 })
                local BarBg = Library:Create("Frame", { Parent = SFrame, Size = dim2(1, -20, 0, 6), Position = dim2(0, 10, 0, 32), BackgroundColor3 = Theme.MainBG })
                Library:Create("UICorner", {Parent = BarBg, CornerRadius = dim(1, 0)})
                local Fill = Library:Create("Frame", { Parent = BarBg, Size = dim2((Value - Min)/(Max - Min), 0, 1, 0), BackgroundColor3 = Theme.Accent })
                Library:Create("UICorner", {Parent = Fill, CornerRadius = dim(1, 0)})

                local Dragging = false
                local function UpdateSlider(pct, bypass)
                    if not bypass then
                        local rawValue = Min + ((Max - Min) * pct)
                        Value = math.floor(rawValue / Increment + 0.5) * Increment
                        Value = math.clamp(Value, Min, Max)
                        pct = (Value - Min) / (Max - Min)
                    end
                    Fill.Size = dim2(pct, 0, 1, 0)
                    ValLbl.Text = tostring(Value)
                    if SldConfig.Callback then SldConfig.Callback(Value) end
                end

                BarBg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; UpdateSlider(math.clamp((UserInputService:GetMouseLocation().X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
                UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider(math.clamp((UserInputService:GetMouseLocation().X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)) end end)

                return { Set = function(self, val) Value = val; UpdateSlider((Value - Min)/(Max - Min), true) end }
            end

            function Section:CreateInput(InputConfig)
                local Bg = Library:Create("Frame", { Parent = Section.Container, Size = dim2(1, 0, 0, 32), BackgroundColor3 = Theme.ElementBG })
                Library:Create("UICorner", {Parent = Bg, CornerRadius = dim(0, 6)}); Library:Create("UIStroke", {Parent = Bg, Color = Theme.Outline, Thickness = 1})
                local Box = Library:Create("TextBox", { Parent = Bg, Size = dim2(1, -16, 1, 0), Position = dim2(0, 8, 0, 0), BackgroundTransparency = 1, Text = "", PlaceholderText = InputConfig.PlaceholderText or "Type here...", TextColor3 = Theme.Text, PlaceholderColor3 = Theme.MutedText, FontFace = Library.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
                
                Box.FocusLost:Connect(function() if InputConfig.Callback then InputConfig.Callback(Box.Text) end end)
            end

            return Section
        end
        return Tab
    end
    return Window
end

return Library
