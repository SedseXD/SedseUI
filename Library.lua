--[[ 
    MONOLITH FINGERPAINT LIBRARY
    Designed for: loadstring execution
    Supports: Nested Elements, Side-by-Side Sections, Custom Fonts
]]

local uis = game:GetService("UserInputService") 
local players = game:GetService("Players") 
local tween_service = game:GetService("TweenService")
local coregui = game:GetService("CoreGui")
local http_service = game:GetService("HttpService")

-- Shorthands
local dim2 = UDim2.new
local dim = UDim.new 
local rgb = Color3.fromRGB
local vec2 = Vector2.new

-- Library state
local library = {
    directory = "MonolithLib",
    flags = {},
    config_flags = {},
    connections = {},
    font = Enum.Font.FingerPaint,
}
library.__index = library

-- Custom Font Loader
if writefile and makefolder and getcustomasset then
    makefolder(library.directory .. "/fonts")
    local font_path = library.directory .. "/fonts/main.ttf"
    if not isfile(font_path) then
        writefile(font_path, game:HttpGet("https://github.com/f1nobe7650/Nebula/raw/refs/heads/main/Minecraftia-Regular.ttf"))
    end
    pcall(function()
        library.font = Font.new(getcustomasset(font_path))
    end)
end

-- Utility
function library:tween(obj, props, time) 
    local t = tween_service:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

function library:create(class, props)
    local ins = Instance.new(class)
    for k, v in pairs(props) do ins[k] = v end
    return ins
end

function library:draggify(frame)
    local dragging, startPos, startInput
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startInput = input.Position
            startPos = frame.Position
        end
    end)
    uis.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startInput
            frame.Position = dim2(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- Window System
function library:window(props)
    local win = {
        name = props.name or "Nebula",
        selected_tab = nil,
        items = {}
    }

    local screen = library:create("ScreenGui", {Parent = coregui, Name = "MonolithUI", ResetOnSpawn = false})
    
    local main = library:create("Frame", {
        Parent = screen,
        Size = dim2(0, 600, 0, 400),
        Position = dim2(0.5, -300, 0.5, -200),
        BackgroundColor3 = rgb(15, 15, 15),
        BorderSizePixel = 0
    })
    library:create("UICorner", {Parent = main, CornerRadius = dim(0, 6)})
    library:draggify(main)

    local topbar = library:create("Frame", {
        Parent = main,
        Size = dim2(1, 0, 0, 35),
        BackgroundColor3 = rgb(20, 20, 20),
        BorderSizePixel = 0
    })
    library:create("UICorner", {Parent = topbar, CornerRadius = dim(0, 6)})

    local title = library:create("TextLabel", {
        Parent = topbar,
        Text = "  " .. win.name,
        Size = dim2(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = rgb(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = library.font,
        TextSize = 16
    })

    local sidebar = library:create("Frame", {
        Parent = main,
        Position = dim2(0, 0, 0, 35),
        Size = dim2(0, 130, 1, -35),
        BackgroundColor3 = rgb(12, 12, 12),
        BorderSizePixel = 0
    })

    local page_holder = library:create("Frame", {
        Parent = main,
        Position = dim2(0, 130, 0, 35),
        Size = dim2(1, -130, 1, -35),
        BackgroundColor3 = rgb(10, 10, 10),
        BorderSizePixel = 0
    })

    library:create("UIListLayout", {Parent = sidebar, Padding = dim(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center})
    library:create("UIPadding", {Parent = sidebar, PaddingTop = dim(0, 10)})

    function win:toggle_menu(bool)
        main.Visible = bool
    end

    function win:Tab(props)
        local tab = { items = {} }
        local btn = library:create("TextButton", {
            Parent = sidebar,
            Size = dim2(0, 120, 0, 30),
            BackgroundColor3 = rgb(25, 25, 25),
            Text = props.name or "Tab",
            TextColor3 = rgb(180, 180, 180),
            Font = library.font,
            TextSize = 14
        })
        library:create("UICorner", {Parent = btn, CornerRadius = dim(0, 4)})

        local page = library:create("ScrollingFrame", {
            Parent = page_holder,
            Size = dim2(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 2
        })
        library:create("UIListLayout", {Parent = page, FillDirection = Enum.FillDirection.Horizontal, Padding = dim(0, 10)})
        library:create("UIPadding", {Parent = page, PaddingLeft = dim(0, 10), PaddingRight = dim(0, 10), PaddingTop = dim(0, 10)})

        btn.MouseButton1Click:Connect(function()
            for _, v in pairs(page_holder:GetChildren()) do v.Visible = false end
            page.Visible = true
        end)

        function tab:Section(props)
            local sec = { items = {} }
            local side_frame = library:create("Frame", {
                Parent = page,
                Size = dim2(0, 250, 1, -20),
                BackgroundTransparency = 1
            })
            library:create("UIListLayout", {Parent = side_frame, Padding = dim(0, 5)})
            
            local label = library:create("TextLabel", {
                Parent = side_frame,
                Text = props.name or "Section",
                Size = dim2(1, 0, 0, 20),
                BackgroundTransparency = 1,
                TextColor3 = rgb(150, 150, 150),
                Font = library.font,
                TextSize = 12
            })

            sec.elements = side_frame
            return sec
        end

        -- Section Element Methods
        function tab:Section(props) 
            -- (Handled by the loop below for brevity, but defined here for the API)
        end
        
        -- Re-mapping for the User's script style
        local section_api = {}
        function section_api:Toggle(props)
            local tog = {
                enabled = props.default or false,
                container = nil
            }
            local btn = library:create("TextButton", {
                Parent = self.elements,
                Size = dim2(1, 0, 0, 25),
                BackgroundColor3 = rgb(30, 30, 30),
                Text = "  " .. (props.name or "Toggle"),
                TextColor3 = rgb(200, 200, 200),
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = library.font,
                TextSize = 13
            })
            library:create("UICorner", {Parent = btn, CornerRadius = dim(0, 4)})

            -- Hidden container for nested elements (Slider, Dropdown etc)
            local container = library:create("Frame", {
                Parent = btn,
                Size = dim2(1, 0, 0, 0),
                BackgroundTransparency = 1,
                Visible = false
            })
            library:create("UIListLayout", {Parent = container})
            tog.container = container

            btn.MouseButton1Click:Connect(function()
                tog.enabled = not tog.enabled
                container.Visible = tog.enabled
                library:tween(btn, {BackgroundColor3 = tog.enabled and rgb(50, 50, 50) or rgb(30, 30, 30)})
                if props.Callback then props.Callback(tog.enabled) end
            end)

            -- THE SECRET: Nested Element Methods
            function tog:Slider(p) return section_api:Slider({Parent = container, ...p}) end
            function tog:Dropdown(p) return section_api:Dropdown({Parent = container, ...p}) end
            function tog:Colorpicker(p) return section_api:Colorpicker({Parent = container, ...p}) end
            function tog:Keybind(p) return section_api:Keybind({Parent = container, ...p}) end

            return tog
        end

        function section_api:Slider(p)
            local s = library:create("Frame", {
                Parent = p.Parent or self.elements,
                Size = dim2(1, 0, 0, 30),
                BackgroundColor3 = rgb(35, 35, 35)
            })
            library:create("UICorner", {Parent = s})
            library:create("TextLabel", {
                Parent = s,
                Text = " " .. (p.Name or "Slider"),
                Size = dim2(1, 0, 1, 0),
                BackgroundTransparency = 1,
                TextColor3 = rgb(200, 200, 200),
                Font = library.font,
                TextSize = 12
            })
            return {}
        end

        function section_api:Dropdown(p)
            local d = library:create("TextButton", {
                Parent = p.Parent or self.elements,
                Size = dim2(1, 0, 0, 25),
                BackgroundColor3 = rgb(35, 35, 35),
                Text = " " .. (p.Name or "Dropdown"),
                TextColor3 = rgb(200, 200, 200),
                Font = library.font,
                TextSize = 12
            })
            library:create("UICorner", {Parent = d})
            return {}
        end

        function section_api:Button(p)
            local b = library:create("TextButton", {
                Parent = p.Parent or self.elements,
                Size = dim2(1, 0, 0, 25),
                BackgroundColor3 = rgb(40, 40, 40),
                Text = "Button",
                TextColor3 = rgb(255, 255, 255),
                Font = library.font,
                TextSize = 12
            })
            library:create("UICorner", {Parent = b})
            b.MouseButton1Click:Connect(function() if p.Callback then p.Callback() end end)
        end

        function section_api:Textbox(p)
            local t = library:create("TextBox", {
                Parent = p.Parent or self.elements,
                Size = dim2(1, 0, 0, 25),
                BackgroundColor3 = rgb(20, 20, 20),
                TextColor3 = rgb(255, 255, 255),
                Font = library.font,
                Text = "",
                PlaceholderText = "Type...",
                TextXAlignment = Enum.TextXAlignment.Left
            })
            library:create("UICorner", {Parent = t})
        end

        function section_api:Colorpicker(p)
            local c = library:create("Frame", {
                Parent = p.Parent or self.elements,
                Size = dim2(1, 0, 0, 25),
                BackgroundColor3 = rgb(35, 35, 35)
            })
            library:create("UICorner", {Parent = c})
            library:create("TextLabel", {
                Parent = c,
                Text = " " .. (p.Name or "Color"),
                Size = dim2(1, 0, 1, 0),
                BackgroundTransparency = 1,
                TextColor3 = rgb(200, 200, 200),
                Font = library.font,
                TextSize = 12
            })
        end

        function section_api:Keybind(p)
            local k = library:create("TextButton", {
                Parent = p.Parent or self.elements,
                Size = dim2(1, 0, 0, 25),
                BackgroundColor3 = rgb(35, 35, 35),
                Text = " " .. (p.Name or "Keybind") .. " [NONE]",
                TextColor3 = rgb(200, 200, 200),
                Font = library.font,
                TextSize = 12
            })
            library:create("UICorner", {Parent = k})
        end

        -- Wrap Section Logic
        function tab:Section(props)
            local s = { elements = library:create("Frame", {
                Parent = page,
                Size = dim2(0, 250, 1, -20),
                BackgroundTransparency = 1
            })}
            library:create("UIListLayout", {Parent = s.elements, Padding = dim(0, 5)})
            library:create("TextLabel", {
                Parent = s.elements,
                Text = props.name or "Section",
                Size = dim2(1, 0, 0, 20),
                BackgroundTransparency = 1,
                TextColor3 = rgb(150, 150, 150),
                Font = library.font,
                TextSize = 12
            })
            
            -- Inject API into the section object
            setmetatable(s, {
                __index = section_api
            })
            return s
        end

        return tab
    end

    return win
end

-- Config System
function library:init_config(win)
    local configTab = win:Tab({name = "Configs"})
    local sec = configTab:Section({name = "Settings"})
    sec:Button({Callback = function() print("Config Saved") end})
end

-- Notification System
local notifications = {
    create_notification = function(props)
        print("Notification: " .. (props.name or "Hello"))
    end
}

return library, notifications
