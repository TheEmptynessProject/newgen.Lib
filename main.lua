repeat
    task.wait()
until game:IsLoaded()
local OldKick = nil
OldKick =
    hookmetamethod(
    game,
    "__namecall",
    function(self, ...)
        if getnamecallmethod() == "Kick" then
            return
        end
        return OldKick(self, ...)
    end
)

local custom =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TheEmptynessProject/newgen.Lib/main/functions.lua"))()

local themes = {
    Default = {
        Font = Enum.Font.Ubuntu,
        TitleBG = Color3.fromRGB(50, 50, 50), -- Dark gray with a slight blue tint
        TabBG = Color3.fromRGB(32, 32, 32), -- Darker gray
        SectionsBG = Color3.fromRGB(38, 38, 38), -- Even darker gray
        MainBG = Color3.fromRGB(44, 44, 44) -- Deep black
    }
}
------------------------------------------------------------------------------------
function _destroy()
    for i, v in pairs(getgenv()[custom.generateString(8, 2)]) do
        if v.ClassName == "ScreenGui" then
            v:Destroy()
        end
    end
    getgenv()[custom.generateString(8, 1)].lib = false
    getgenv()[custom.generateString(8, 2)] = {}
end
local library = {toggleBind = Enum.KeyCode.Q}
if getgenv()[custom.generateString(8, 1)] and getgenv()[custom.generateString(8, 1)].lib then
    _destroy()
end
function library:Init(a)
    local opts = custom.formatTable(a)
    if not getgenv()[custom.generateString(8, 1)] then
        getgenv()[custom.generateString(8, 1)] = {}
    end

    local settings = getgenv()[custom.generateString(8, 1)]

    settings.lib = true
    settings.customUI = opts.customui or false
    settings.rgbSpeed = opts.rgbspeed or 500
    settings.rgbMode = opts.rgbmode or "complementary"
    settings.titleColors = opts.colors or 2
    settings.chat = opts.chat or {only = false, lightmode = false, rgbtext = false}
    settings.plist = opts.plist or {only = false, lightmode = false, stats = {}}
    settings.canDrag = true
    settings.bg = opts.bg or {total = 100, radius = 2, connectradius = 50}

    local ScreenGui =
        custom.createObject(
        "ScreenGui",
        {
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        }
    )
    custom.protect(ScreenGui, game:GetService("CoreGui"))

    local alwaysOnScreenGui =
        custom.createObject(
        "ScreenGui",
        {
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        }
    )
    custom.protect(alwaysOnScreenGui, game:GetService("CoreGui"))

    if not settings.blur then
        settings.blur =
            custom.createObject(
            "BlurEffect",
            {
                Size = 0,
                Parent = game:GetService("Lighting")
            }
        )
    end

    local canvas =
        custom.createObject(
        "Frame",
        {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.7,
            Parent = ScreenGui
        }
    )

    local dotRadius = settings.bg.radius or 2
    local togen = settings.bg.total or 100
    local dots = {}
    local connectionRadius = settings.bg.connectradius or 50
    local mouse = Vector2.new(0, 0)
    local maxConnections = 10
    local connectingEnabled = true

    local function createDot(position, velocity)
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, dotRadius * 2, 0, dotRadius * 2)
        dot.Position = UDim2.new(0, position.X, 0, position.Y)
        dot.BackgroundColor3 = Color3.new(1, 1, 1)
        dot.BackgroundTransparency = 0.5
        dot.Parent = canvas

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(100, 0)
        corner.Parent = dot

        table.insert(dots, {Dot = dot, Velocity = velocity, ConnectedDots = {}, ConnectedMouse = {}})
    end

    local function DivideSmaller(X, Y)
        return math.atan2(Y, X) * 180 / math.pi
    end

    local function updateDots()
        for _, dotData in ipairs(dots) do
            local dot = dotData.Dot
            local velocity = dotData.Velocity
            local dotPosition = dot.Position

            if dotPosition.X.Offset < 0 or dotPosition.X.Offset > canvas.AbsoluteSize.X - dotRadius * 2 then
                velocity = Vector2.new(-velocity.X, velocity.Y)
            end
            if dotPosition.Y.Offset < 0 or dotPosition.Y.Offset > canvas.AbsoluteSize.Y - dotRadius * 2 then
                velocity = Vector2.new(velocity.X, -velocity.Y)
            end

            local newPosition = dotPosition + UDim2.new(0, velocity.X, 0, velocity.Y)
            dot.Position = newPosition

            dotData.Velocity = velocity

            local connectedCount = #dotData.ConnectedDots

            local distanceToMouse = (Vector2.new(dotPosition.X.Offset, dotPosition.Y.Offset) - mouse).Magnitude
            if distanceToMouse < connectionRadius and connectingEnabled then
                if not dotData.ConnectedMouse[dot] then
                    local line = Instance.new("Frame")
                    line.BackgroundColor3 = Color3.new(1, 1, 1)
                    line.Parent = canvas
                    line.BorderSizePixel = 0
                    line.BackgroundTransparency = 0.5
                    line.AnchorPoint = Vector2.new(0.5, 0.5)
                    dotData.ConnectedMouse[dot] = line
                end
                if dotData.ConnectedMouse[dot] then
                    local thing = dotData.ConnectedMouse[dot]
                    local XLength = dot.AbsolutePosition.X - mouse.X
                    local YLength = dot.AbsolutePosition.Y - mouse.Y
                    thing.Rotation = DivideSmaller(XLength, YLength)
                    local CenterPosition =
                        (mouse + Vector2.new(dotRadius, dotRadius) + dot.AbsolutePosition +
                        Vector2.new(dotRadius, dotRadius)) /
                        2
                    thing.Position = UDim2.fromOffset(CenterPosition.X, CenterPosition.Y)
                    thing.Size = UDim2.fromOffset(distanceToMouse, 1)
                end
            elseif distanceToMouse > connectionRadius and dotData.ConnectedMouse[dot] then
                dotData.ConnectedMouse[dot]:Destroy()
                dotData.ConnectedMouse[dot] = nil
            end

            for _, otherDotData in ipairs(dots) do
                if dotData ~= otherDotData then
                    local otherDot = otherDotData.Dot
                    local vector =
                        Vector2.new(
                        dotPosition.X.Offset - otherDot.Position.X.Offset,
                        dotPosition.Y.Offset - otherDot.Position.Y.Offset
                    )
                    local distance = vector.Magnitude

                    if distance <= connectionRadius and connectingEnabled then
                        if not dotData.ConnectedDots[otherDot] then
                            local line = Instance.new("Frame")
                            line.BackgroundColor3 = Color3.new(1, 1, 1)
                            line.BackgroundTransparency = 0.5
                            line.Parent = canvas
                            line.BorderSizePixel = 0
                            line.AnchorPoint = Vector2.new(0.5, 0.5)
                            dotData.ConnectedDots[otherDot] = line
                            otherDotData.ConnectedDots[dot] = line
                        end
                        if dotData.ConnectedDots[otherDot] then
                            local thing = dotData.ConnectedDots[otherDot]
                            local XLength = dot.AbsolutePosition.X - otherDot.AbsolutePosition.X
                            local YLength = dot.AbsolutePosition.Y - otherDot.AbsolutePosition.Y
                            local CenterPosition =
                                (otherDot.AbsolutePosition + Vector2.new(dotRadius, dotRadius) + dot.AbsolutePosition +
                                Vector2.new(dotRadius, dotRadius)) /
                                2
                            thing.Rotation = DivideSmaller(XLength, YLength)
                            thing.Position = UDim2.fromOffset(CenterPosition.X, CenterPosition.Y)
                            thing.Size = UDim2.fromOffset(distance, 1)
                        end
                    elseif distance > connectionRadius and dotData.ConnectedDots[otherDot] then
                        dotData.ConnectedDots[otherDot]:Destroy()
                        dotData.ConnectedDots[otherDot] = nil
                        otherDotData.ConnectedDots[dot]:Destroy()
                        otherDotData.ConnectedDots[dot] = nil
                    end
                end
            end
        end
    end

    for _ = 1, togen do
        local randomVelocity =
            Vector2.new(
            (math.random() < 0.5 and -1 or 1) * (math.random() * 4.5 + 0.5),
            (math.random() < 0.5 and -1 or 1) * (math.random() * 4.5 + 0.5)
        )
        createDot(
            Vector2.new(
                math.random(0, canvas.AbsoluteSize.X - dotRadius * 2),
                math.random(0, canvas.AbsoluteSize.Y - dotRadius * 2)
            ),
            randomVelocity
        )
    end

    local inputService = game:GetService("UserInputService")
    inputService.InputChanged:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                mouse = Vector2.new(input.Position.X, input.Position.Y)
            end
        end
    )

    game:GetService("RunService").Heartbeat:Connect(
        function()
            updateDots()
        end
    )
    --LOAD CUSTOM CHAT
    if not settings.chat.loaded and (settings.customUI or settings.chat.only) then
        settings.chat.loaded = true
        local Players = game:GetService("Players")
        local TweenService = game:GetService("TweenService")

        game.TextChatService.BubbleChatConfiguration.MaxBubbles = 0
        game.TextChatService.BubbleChatConfiguration.Enabled = false

        local function createChatBubble(player, message)
            if not player.Character.Head:FindFirstChild("BillboardGui") then
                local BillboardGui = Instance.new("BillboardGui")
                BillboardGui.Size = UDim2.new(0, 100, 0, 150)
                BillboardGui.AlwaysOnTop = true
                BillboardGui.Adornee = player.Character.Head
                BillboardGui.Parent = player.Character.Head
                BillboardGui.SizeOffset = Vector2.new(0, 1)

                local frame = Instance.new("Frame")
                frame.Parent = BillboardGui
                frame.BackgroundTransparency = 1
                frame.Size = UDim2.new(1, 0, 1, 0)

                local list = Instance.new("UIListLayout")
                list.Padding = UDim.new(0, 6)
                list.Parent = frame
                list.FillDirection = Enum.FillDirection.Vertical
                list.HorizontalAlignment = Enum.HorizontalAlignment.Center
                list.VerticalAlignment = Enum.VerticalAlignment.Bottom
                list.SortOrder = Enum.SortOrder.LayoutOrder
            end

            local frame2 = Instance.new("Frame")
            frame2.Parent = player.Character.Head:FindFirstChild("BillboardGui").Frame
            frame2.BackgroundTransparency = 1
            frame2.Size = UDim2.new(1, 0, 0, 50)

            local TextLabel = Instance.new("TextLabel")
            if settings.chat.lightmode then
                TextLabel.Size = UDim2.new(1, 0, 1, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.TextColor3 = Color3.new(0, 0, 0)
                TextLabel.Font = Enum.Font.Ubuntu
                TextLabel.TextSize = 14
                TextLabel.TextWrapped = true
                TextLabel.Text = message
                TextLabel.Parent = frame2
                TextLabel.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8)
                TextLabel.TextTransparency = 1
            else
                TextLabel.Size = UDim2.new(1, 0, 1, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.TextColor3 = Color3.new(1, 1, 1)
                TextLabel.Font = Enum.Font.Ubuntu
                TextLabel.TextSize = 14
                TextLabel.TextWrapped = true
                TextLabel.Text = message
                TextLabel.Parent = frame2
                TextLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
                TextLabel.TextTransparency = 1
            end

            if settings.chat.rgbtext then
                spawn(
                    function()
                        while true do
                            for i = 0, 1, 1 / settings.rgbSpeed do
                                TextLabel.TextColor3 = Color3.fromHSV(i, 1, 1)
                                task.wait()
                            end
                        end
                    end
                )
            end

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 12)
            corner.Parent = TextLabel

            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            local tween =
                TweenService:Create(TextLabel, tweenInfo, {BackgroundTransparency = 0.2, TextTransparency = 0})
            tween:Play()

            task.wait(15)

            local destroyTween =
                TweenService:Create(TextLabel, tweenInfo, {BackgroundTransparency = 1, TextTransparency = 1})
            destroyTween:Play()
            destroyTween.Completed:Connect(
                function()
                    frame2:Destroy()
                end
            )
        end

        Players.PlayerAdded:Connect(
            function(player)
                player.Chatted:Connect(
                    function(message)
                        createChatBubble(player, message)
                    end
                )
            end
        )

        for _, player in ipairs(Players:GetPlayers()) do
            player.Chatted:Connect(
                function(message)
                    createChatBubble(player, message)
                end
            )
        end
    end

    if not settings.plist.loaded and (settings.customUI or settings.plist.only) then
        settings.plist.loaded = true

        local Players = game:GetService("Players")
        local TweenService = game:GetService("TweenService")
        local UserInputService = game:GetService("UserInputService")
        local nA = "N/A"

        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

        local Frame = Instance.new("ScrollingFrame")
        local UIListLayout = Instance.new("UIListLayout")
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        Frame.Parent = alwaysOnScreenGui
        Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Frame.BorderColor3 = Color3.fromRGB(100, 100, 100)
        Frame.BorderSizePixel = 5
        Frame.Position = UDim2.new(0.875, 0, 0.034, 0)
        Frame.Size = UDim2.new(0, 185, 0, 360)
        Frame.CanvasSize = UDim2.new(0, 0, 0, 0)
        Frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Frame.ScrollBarThickness = 5
        Frame.ScrollBarImageColor3 = Color3.new(1, 1, 1)

        UIListLayout.Parent = Frame
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Padding = UDim.new(0, 5)

        UserInputService.InputBegan:Connect(
            function(input, gameProcessedEvent)
                if input.KeyCode == Enum.KeyCode.Tab then
                    local isVisible = Frame.Visible

                    local tween =
                        TweenService:Create(
                        Frame,
                        tweenInfo,
                        {
                            Size = UDim2.new(0, 185, 0, isVisible and 0 or 360),
                            Position = UDim2.new(0.875, 0, isVisible and 0 or 0.034, isVisible and -50 or -0),
                            ScrollBarThickness = isVisible and 0 or 5
                        }
                    )
                    tween:Play()
                    if isVisible then
                        tween:Play()
                        tween.Completed:Connect(
                            function()
                                Frame.Visible = not isVisible
                            end
                        )
                    else
                        Frame.Visible = not isVisible
                        tween:Play()
                    end
                end
            end
        )

        local function playCharacterAddedAnimation(playername)
            local tween = TweenService:Create(playername, tweenInfo, {TextColor3 = Color3.new(0, 1, 0)})
            tween:Play()
        end

        local function playCharacterRemovedAnimation(playername)
            local tween = TweenService:Create(playername, tweenInfo, {TextColor3 = Color3.new(1, 1, 0)})
            tween:Play()
        end

        local function addCharacterAddedConnection(player, playername)
            return player.CharacterAdded:Connect(
                function()
                    playCharacterAddedAnimation(playername)
                end
            )
        end

        local function addCharacterRemovedConnection(player, playername)
            return player.CharacterRemoving:Connect(
                function()
                    playCharacterRemovedAnimation(playername)
                end
            )
        end

        local playerFrames = {}

        local function addPlayer(player)
            local Frame_2 = Instance.new("Frame")
            local playername = Instance.new("TextButton")
            local statsHolder = Instance.new("ScrollingFrame")
            local UIListLayout_2 = Instance.new("UIListLayout")
            local statDemo = Instance.new("TextLabel")

            Frame_2.Parent = Frame
            Frame_2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Frame_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Frame_2.BorderSizePixel = 0
            Frame_2.Size = UDim2.new(0, 100, 0, 50)

            playername.Parent = Frame_2
            playername.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            playername.BorderColor3 = Color3.fromRGB(0, 0, 0)
            playername.BorderSizePixel = 0
            playername.Position = UDim2.new(0.100000001, 0, 0, 0)
            playername.Size = UDim2.new(0.400000006, 50, 1, 0)
            playername.Font = Enum.Font.SourceSans
            playername.Text = player.Name
            playername.TextColor3 = Color3.fromRGB(255, 255, 255)
            playername.TextSize = 14.000
            playername.TextWrapped = true
            playername.TextXAlignment = Enum.TextXAlignment.Left
            playername.AutoButtonColor = false

            statsHolder.Parent = Frame_2
            statsHolder.Active = true
            statsHolder.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
            statsHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
            statsHolder.BorderSizePixel = 0
            statsHolder.Position = UDim2.new(1, 0, 0, 0)
            statsHolder.Size = UDim2.new(0, 80, 0, 50)
            statsHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
            statsHolder.ScrollBarThickness = 0

            UIListLayout_2.Parent = statsHolder
            UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
            UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

            statDemo.Parent = statsHolder
            statDemo.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
            statDemo.BorderColor3 = Color3.fromRGB(0, 0, 0)
            statDemo.BorderSizePixel = 0
            statDemo.Size = UDim2.new(1, 0, 0, 50)
            statDemo.Font = Enum.Font.SourceSans
            statDemo.TextColor3 = Color3.fromRGB(255, 255, 255)
            statDemo.TextSize = 14.000

            playername.MouseButton1Click:Connect(
                function()
                    setclipboard(playername.Text)
                end
            )
            if #settings.plist.stats > 0 then
            else
            end
            if not player:FindFirstChild("leaderstats") then
                repeat
                    statDemo.Text = "" .. nA .. ": " .. nA
                    task.wait(2)
                until player:FindFirstChild("leaderstats")
            end
            for i, v in pairs(player.leaderstats:GetChildren()) do
                local thread =
                    coroutine.create(
                    function()
                        while task.wait() do
                            local success, val =
                                pcall(
                                function()
                                    return v.Value
                                end
                            )

                            if success then
                                statDemo.Text = "" .. v.Name .. ": " .. math.round(val)
                            else
                                statDemo.Text = "" .. v.Name .. ": " .. nA
                            end
                        end
                    end
                )

                coroutine.resume(thread)
            end

            local characterAddedConnection
            local characterRemovedConnection

            if not player.Character then
                characterAddedConnection = addCharacterAddedConnection(player, playername)
            else
                playCharacterAddedAnimation(playername)
            end

            characterRemovedConnection = addCharacterRemovedConnection(player, playername)

            player.CharacterAdded:Connect(
                function()
                    if characterAddedConnection then
                        characterAddedConnection:Disconnect()
                        characterAddedConnection = nil
                    end
                    playCharacterAddedAnimation(playername)
                end
            )

            player.CharacterRemoving:Connect(
                function()
                    if characterRemovedConnection then
                        characterRemovedConnection:Disconnect()
                        characterRemovedConnection = nil
                    end
                    playCharacterRemovedAnimation(playername)
                end
            )

            local destroyTween = TweenService:Create(playername, tweenInfo, {TextColor3 = Color3.new(1, 0, 0)})
            Players.PlayerRemoving:Connect(
                function(ppp)
                    if ppp == player then
                        destroyTween:Play()
                        destroyTween.Completed:Connect(
                            function()
                                Frame_2:Destroy()
                                playerFrames[player] = nil
                            end
                        )
                    end
                end
            )
        end

        Players.PlayerAdded:Connect(
            function(player)
                addPlayer(player)
            end
        )

        for _, player in ipairs(Players:GetPlayers()) do
            addPlayer(player)
        end
    end
    local tooltipText =
        custom.createObject(
        "TextBox",
        {
            Parent = ScreenGui,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            ZIndex = 2,
            Size = UDim2.new(0, 300, 0, 50),
            Font = Enum.Font.Ubuntu,
            MultiLine = true,
            PlaceholderColor3 = Color3.fromRGB(0, 0, 0),
            Text = "",
            TextColor3 = Color3.fromRGB(0, 0, 0),
            TextSize = 16.000,
            TextWrapped = true,
            Visible = false,
            TextEditable = false,
            AutomaticSize = Enum.AutomaticSize.Y
        }
    )
    local function refreshToolText(tooltip)
        if not tooltip then
            tooltipText.Visible = false
        elseif tooltip then
            tooltipText.Visible = true
            tooltipText.Text = tooltip
        end
    end

    local function updateTooltipPosition()
        local mouse = game.Players.LocalPlayer:GetMouse()
        tooltipText.Position = UDim2.new(0, mouse.X + 15, 0, mouse.Y - 10)
    end

    local main =
        custom.createObject(
        "Frame",
        {
            Parent = ScreenGui,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1.000,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = custom.getCenterPosition(700, 600),
            Size = UDim2.new(0, 700, 0, 605),
            ClipsDescendants = true
        }
    )

    custom.enableDrag(main, {0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out})

    local MAINGUI_enabled = false
    local lastToggleTime = 0
    local timetoLast = 0.5

    local function update()
        if tick() - lastToggleTime < timetoLast then
            return
        end

        if MAINGUI_enabled then
            custom.animate(
                main,
                {timetoLast, Enum.EasingStyle.Quad, Enum.EasingDirection.Out},
                {Size = UDim2.new(0, 700, 0, 0)},
                function()
                    main.Visible = false
                end
            )
            custom.animate(settings.blur, {timetoLast, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Size = 0})
            refreshToolText(nil)
            connectingEnabled = false
            custom.animate(
                canvas,
                {timetoLast, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out},
                {BackgroundTransparency = 1},
                function()
                    canvas.Visible = false
                end
            )
            for _, child in ipairs(canvas:GetChildren()) do
                if child:IsA("Frame") then
                    custom.animate(
                        child,
                        {timetoLast, Enum.EasingStyle.Quint, Enum.EasingDirection.Out},
                        {BackgroundTransparency = 1}
                    )
                end
            end
            settings.canDrag = false
        else
            main.Visible = true
            custom.animate(
                main,
                {timetoLast, Enum.EasingStyle.Quad, Enum.EasingDirection.Out},
                {Size = UDim2.new(0, 700, 0, 605)}
            )
            custom.animate(settings.blur, {timetoLast, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Size = 50})
            canvas.Visible = true
            connectingEnabled = true
            custom.animate(
                canvas,
                {timetoLast, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out},
                {BackgroundTransparency = 0.7}
            )
            for _, child in ipairs(canvas:GetChildren()) do
                if child:IsA("Frame") then
                    custom.animate(
                        child,
                        {timetoLast, Enum.EasingStyle.Quint, Enum.EasingDirection.In},
                        {BackgroundTransparency = 0.5}
                    )
                end
            end
            settings.canDrag = true
        end
        lastToggleTime = tick()
        MAINGUI_enabled = not MAINGUI_enabled
    end

    update()

    game:GetService("UserInputService").InputBegan:Connect(
        function(input)
            if game:GetService("UserInputService"):GetFocusedTextBox() then
                return
            end
            if input.KeyCode == library.toggleBind then
                update()
            end
        end
    )

    local title_line =
        custom.createObject(
        "Frame",
        {
            Parent = main,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 700, 0, 5),
            ZIndex = 2
        }
    )

    local gradient_line =
        custom.createObject(
        "UIGradient",
        {
            Rotation = 0,
            Parent = title_line
        }
    )

    spawn(
        function()
            while true do
                for i = 0, 1, 1 / settings.rgbSpeed do
                    local numColors = settings.titleColors --max = 20
                    local color = Color3.fromHSV(i, 1, 1)
                    tooltipText.TextColor3 = color

                    local temp = getModifiedColors(color, numColors, settings.rgbMode, settings.customAngle)

                    local colorSequence = ColorSequence.new(temp)

                    gradient_line.Color = colorSequence

                    task.wait()
                end
            end
        end
    )

    local Title =
        custom.createObject(
        "Frame",
        {
            Parent = main,
            BackgroundColor3 = themes.Default.TitleBG,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.new(0, 700, 0, 101)
        }
    )

    local holder_2 =
        custom.createObject(
        "ScrollingFrame",
        {
            Parent = Title,
            Active = true,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1.000,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0.25, 0, 0.25, 0),
            Size = UDim2.new(0, 350, 0, 50),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            ZIndex = 2,
            CanvasSize = UDim2.new(2, 0, 0, 0),
            ScrollBarThickness = 0,
            VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left
        }
    )
    local TitleList =
        custom.createObject(
        "UIListLayout",
        {
            Parent = holder_2,
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 50)
        }
    )
    --[[local icon_Titlebutton =
        custom.createObject(
        "ImageButton",
        {
            Parent = Title,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0.0357142873, 0, 0.150000006, 0),
            Size = UDim2.new(0, 70, 0, 70),
            Image = getcustomasset("icon.png")
        }
    )]]
    local title_info = {count = 0}
    title_info = custom.formatTable(title_info)

    function title_info:Title()
        title_info.count = title_info.count + 1
        local toggled = title_info.count == 1

        --[[local Titlebutton =
            custom.createObject(
            "ImageButton",
            {
                Parent = holder_2,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, -2, 0),
                Size = UDim2.new(0, 50, 0, 50),
				Image = getcustomasset("cog.png")
            }
        )]]
        local Titlebutton =
            custom.createObject(
            "TextButton",
            {
                Parent = holder_2,
                BackgroundTransparency = 0.8,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(0, 50, 0, 50),
                Font = themes.Default.Font,
                TextColor3 = Color3.fromRGB(0, 0, 0),
                TextSize = 14.000
            }
        )
        local TAB = --------------------------------------------------------------------------------------------------------------------------------------------------------------
            custom.createObject(
            "Frame",
            {
                Parent = Title,
                BackgroundColor3 = themes.Default.TabBG,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 100),
                Size = UDim2.new(0, 200, 0, 500)
            }
        )
        local UICorner =
            custom.createObject(
            "UICorner",
            {
                CornerRadius = UDim.new(0, 10),
                Parent = TAB
            }
        )
        local TAB_hideCorner = --------------------------------------------------------------------------------------------------------------------------------------------------------------
            custom.createObject(
            "Frame",
            {
                Parent = TAB,
                BackgroundColor3 = themes.Default.TabBG,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0.000166503902, 0),
                Size = UDim2.new(0, 200, 0, 50)
            }
        )
        local TAB_hideCorner_2 = --------------------------------------------------------------------------------------------------------------------------------------------------------------
            custom.createObject(
            "Frame",
            {
                Parent = TAB,
                BackgroundColor3 = themes.Default.TabBG,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0.75, 0, 0.60016638, 0),
                Size = UDim2.new(0, 50, 0, 200)
            }
        )
        local holder =
            custom.createObject(
            "ScrollingFrame",
            {
                Parent = TAB,
                Active = true,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1.000,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0.0500000007, 0, 0.0386002213, 0),
                Size = UDim2.new(0, 180, 0, 460),
                ZIndex = 2,
                ScrollBarThickness = 0
            }
        )
        local TABList =
            custom.createObject(
            "UIListLayout",
            {
                Parent = holder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder
            }
        )
        Titlebutton.MouseButton1Click:Connect(
            function()
                toggled = not toggled
                print("Clicked")
            end
        )

        local tab_info = {count = 0}
        tab_info = custom.formatTable(tab_info)

        function tab_info:Tab(name)
            tab_info.count = tab_info.count + 1
            local toggled = tab_info.count == 1

            local TabButton =
                custom.createObject(
                "TextButton",
                {
                    Parent = holder,
                    BackgroundTransparency = 0.8,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 200, 0, 50),
                    Font = themes.Default.Font,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    TextSize = 14.000,
                    Text = name
                }
            )
            local Sections = --------------------------------------------------------------------------------------------------------------------------------------------------------------
                custom.createObject(
                "Frame",
                {
                    Parent = TAB,
                    BackgroundColor3 = themes.Default.SectionsBG,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 200, 0, 0),
                    Size = UDim2.new(0, 100, 0, 500)
                }
            )
            local holder_4 =
                custom.createObject(
                "ScrollingFrame",
                {
                    Parent = Sections,
                    Active = true,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1.000,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.100000001, 0, 0.0380000621, 0),
                    Size = UDim2.new(0, 80, 0, 460),
                    ZIndex = 2,
                    ScrollBarThickness = 0,
                    Visible = toggled
                }
            )
            local sectionList =
                custom.createObject(
                "UIListLayout",
                {
                    Parent = holder_4,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder
                }
            )
            TabButton.MouseButton1Click:Connect(
                function()
                    holder_4.Visible = false
                end
            )
            local section_info = {count = 0}
            section_info = custom.formatTable(section_info)

            function section_info:Section()
                section_info.count = section_info.count + 1
                local toggled = section_info.count == 1
                local sectionButton =
                    custom.createObject(
                    "TextButton",
                    {
                        Parent = holder_4,
                        BackgroundTransparency = 0.8,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 100, 0, 50),
                        Font = themes.Default.Font,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        TextSize = 14.000
                    }
                )
                local actual = --------------------------------------------------------------------------------------------------------------------------------------------------------------
                    custom.createObject(
                    "Frame",
                    {
                        Parent = Sections,
                        BackgroundColor3 = themes.Default.MainBG,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 100, 0, 0),
                        Size = UDim2.new(0, 400, 0, 500)
                    }
                )
                local UICorner_3 =
                    custom.createObject(
                    "UICorner",
                    {
                        CornerRadius = UDim.new(0, 10),
                        Parent = actual
                    }
                )
                local actual_hideCorner = --------------------------------------------------------------------------------------------------------------------------------------------------------------
                    custom.createObject(
                    "Frame",
                    {
                        Parent = actual,
                        BackgroundColor3 = themes.Default.MainBG,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 400, 0, 50)
                    }
                )
                local holder_3 =
                    custom.createObject(
                    "ScrollingFrame",
                    {
                        Parent = actual,
                        Active = true,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1.000,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0.0250000004, 0, 0.0379999988, 0),
                        Size = UDim2.new(0, 380, 0, 470),
                        ZIndex = 2,
                        ScrollBarThickness = 0
                    }
                )
                local actual_list =
                    custom.createObject(
                    "UIListLayout",
                    {
                        Parent = holder_3,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 20)
                    }
                )
                local actual_hideCorner_2 = --------------------------------------------------------------------------------------------------------------------------------------------------------------
                    custom.createObject(
                    "Frame",
                    {
                        Parent = actual,
                        BackgroundColor3 = themes.Default.MainBG,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0.200000003, 0),
                        Size = UDim2.new(0, 50, 0, 400)
                    }
                )
                local UICorner_4 =
                    custom.createObject(
                    "UICorner",
                    {
                        CornerRadius = UDim.new(0, 10),
                        Parent = actual
                    }
                )
                sectionButton.MouseButton1Click:Connect(
                    function()
                        toggled = not toggled
                        print("Clicked")
                    end
                )
                local actual_info = {count = 0}
                actual_info = custom.formatTable(actual_info)
                function actual_info:Button(name, tip, call)
                    local btnText = name or "Button"
                    local func = call or function()
                        end
                    local tooltip = tip or nil
                    actual_info.count = actual_info.count + 1

                    local actual_button =
                        custom.createObject(
                        "TextButton",
                        {
                            Parent = holder_3,
                            BackgroundTransparency = 0.8,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = UDim2.new(0, 380, 0, 50),
                            Font = themes.Default.Font,
                            TextColor3 = Color3.fromRGB(0, 0, 0),
                            TextSize = 14.000,
                            Text = btnText
                        }
                    )
                    local connection

                    actual_button.MouseEnter:Connect(
                        function()
                            refreshToolText(tooltip)
                            connection =
                                game:GetService("RunService").RenderStepped:Connect(
                                function()
                                    updateTooltipPosition()
                                end
                            )
                        end
                    )

                    actual_button.MouseLeave:Connect(
                        function()
                            refreshToolText(nil)
                            connection:Disconnect()
                        end
                    )
                    actual_button.MouseButton1Click:Connect(
                        function()
                            custom.createRipple(actual_button)
                            func()
                        end
                    )
                end
                function actual_info:Toggle()
                    actual_info.count = actual_info.count + 1
                    local toggled = actual_info.count == 1

                    local actual_toggle =
                        custom.createObject(
                        "TextButton",
                        {
                            Parent = holder_3,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BackgroundTransparency = 0.8,
                            BorderSizePixel = 0,
                            Size = UDim2.new(0, 380, 0, 50),
                            Font = Enum.Font.Ubuntu,
                            TextColor3 = Color3.fromRGB(0, 0, 0),
                            TextSize = 14.000,
                            TextStrokeColor3 = Color3.fromRGB(255, 0, 0),
                            TextWrapped = true
                        }
                    )

                    local frame =
                        custom.createObject(
                        "Frame",
                        {
                            Parent = actual_toggle,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(255, 0, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.new(0.0394736826, 0, 0.195662841, 0),
                            Size = UDim2.new(0, 355, 0, 30)
                        }
                    )
                    local stroke =
                        custom.createObject(
                        "UIStroke",
                        {
                            Parent = frame,
                            Color = Color3.fromRGB(255, 0, 0),
                            Thickness = 1,
                            LineJoinMode = Enum.LineJoinMode.Miter
                        }
                    )
                    local stroke2 =
                        custom.createObject(
                        "UIStroke",
                        {
                            Parent = actual_toggle,
                            Color = Color3.fromRGB(255, 0, 0),
                            Thickness = 1,
                            LineJoinMode = Enum.LineJoinMode.Miter,
                            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                        }
                    )
                    local connection

                    actual_toggle.MouseEnter:Connect(
                        function()
                            refreshToolText("Hi")
                            connection =
                                game:GetService("RunService").RenderStepped:Connect(
                                function()
                                    updateTooltipPosition()
                                end
                            )
                        end
                    )
                    actual_toggle.MouseLeave:Connect(
                        function()
                            refreshToolText(nil)
                            connection:Disconnect()
                        end
                    )
                    actual_toggle.MouseButton1Click:Connect(
                        function()
                            toggled = not toggled
                            if toggled then
                                custom.animate(
                                    stroke,
                                    {0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out},
                                    {Color = Color3.new(0, 1, 0)},
                                    function()
                                        custom.animate(
                                            stroke2,
                                            {0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out},
                                            {Color = Color3.new(0, 1, 0)}
                                        )
                                    end
                                )
                            else
                                custom.animate(
                                    stroke2,
                                    {0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out},
                                    {Color = Color3.new(1, 0, 0)},
                                    function()
                                        custom.animate(
                                            stroke,
                                            {0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out},
                                            {Color = Color3.new(1, 0, 0)}
                                        )
                                    end
                                )
                            end
                        end
                    )
                end
                function actual_info:Slider()
                    actual_info.count = actual_info.count + 1
                    local toggled = actual_info.count == 1
                    local default, min, max = 50, 0, 100
                    local slider =
                        custom.createObject(
                        "Frame",
                        {
                            Size = UDim2.new(0, 380, 0, 50),
                            ClipsDescendants = true,
                            BackgroundColor3 = Color3.new(1, 1, 1),
                            BackgroundTransparency = 0.8,
                            Parent = holder_3
                        }
                    )

                    local fill =
                        custom.createObject(
                        "Frame",
                        {
                            Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                            BackgroundColor3 = Color3.new(0, 0, 0),
                            BackgroundTransparency = 0,
                            Parent = slider
                        }
                    )

                    local title =
                        custom.createObject(
                        "TextLabel",
                        {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 0.2,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Font = Enum.Font.Ubuntu,
                            TextColor3 = Color3.fromRGB(0, 0, 0),
                            TextSize = 14.000,
                            Parent = slider
                        }
                    )
                    local holding = false
                    game:GetService("UserInputService").InputChanged:Connect(
                        function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement and holding and MAINGUI_enabled then
                                settings.canDrag = false
                                local sizeX =
                                    math.clamp(
                                    (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X,
                                    0,
                                    1
                                )
                                local targetSize = UDim2.new(sizeX, 0, 1, 0)

                                custom.animate(fill, {0.3}, {Size = targetSize})

                                local value = math.floor(((max - min) * sizeX) + min)
                                title.Text = "test" .. ": " .. value
                            end
                        end
                    )
                    slider.InputBegan:Connect(
                        function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 and MAINGUI_enabled then
                                settings.canDrag = false
                                holding = true
                                local sizeX =
                                    math.clamp(
                                    (input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X,
                                    0,
                                    1
                                )
                                local targetSize = UDim2.new(sizeX, 0, 1, 0)

                                custom.animate(fill, {0.3}, {Size = targetSize})

                                local value = math.floor(((max - min) * sizeX) + min)
                                title.Text = "test" .. ": " .. value
                            end
                        end
                    )

                    slider.InputEnded:Connect(
                        function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                settings.canDrag = true
                                holding = false
                            end
                        end
                    )
                    local connection

                    slider.MouseEnter:Connect(
                        function()
                            refreshToolText("Hi")
                            connection =
                                game:GetService("RunService").RenderStepped:Connect(
                                function()
                                    updateTooltipPosition()
                                end
                            )
                        end
                    )
                    slider.MouseLeave:Connect(
                        function()
                            refreshToolText(nil)
                            connection:Disconnect()
                        end
                    )
                end
                return actual_info
            end
            return section_info
        end
        return tab_info
    end
    return title_info
end
local lib =
    library:Init(
    {
        customUI = true,
        rgbSpeed = 200,
        rgbMode = "tentvariation",
        colors = 10,
        --max 20
        chat = {only = false, lightmode = false, rgbtext = false},
        plist = {only = false, lightmode = false, stats = {}},
        bg = {total = 100, radius = 2, connectradius = 50}
    }
)
local tab = main:NewTab("brt")
local tab2 = main:NewTab("brt2")
local sec = tab:NewSection("bruh", 1)
local sec2 = tab2:NewSection("bruh4", 2)
local but =
    sec:CreateButton(
    "Thing",
    nil,
    function()
        print("Clicked")
    end
)
local but =
    sec2:CreateButton(
    "Thing2",
    nil,
    function()
        print("Clicked2")
    end
)
print(#getgenv()[custom.generateString(8, 2)])
