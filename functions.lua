local custom = {}
function custom.protect(instanceToProtect, parent)
    local name = instanceToProtect.Name

    local OldNamecall = nil
    OldNamecall =
        hookmetamethod(
        parent,
        "__namecall",
        function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            if method == "FindFirstChild" or method == "FindFirstChildOfClass" or method == "FindFirstChildWhichIsA" then
                local result = OldNamecall(self, ...)

                if result and result == instanceToProtect then
                    return nil
                end

                return result
            elseif method == "GetChildren" or method == "GetDescendants" then
                local result = OldNamecall(self, ...)

                for i = #result, 1, -1 do
                    if result[i] == instanceToProtect then
                        table.remove(result, i)
                    end
                end

                return result
            end
            return OldNamecall(self, unpack(args))
        end
    )

    local OldIndex = nil
    OldIndex =
        hookmetamethod(
        parent,
        "__index",
        function(self, key)
            if key == name then
                return nil
            end
            return OldIndex(self, key)
        end
    )

    instanceToProtect.Parent = parent
    return instanceToProtect
end
function custom.generateString(length, seed)
    local word = {}

    for i = 1, length do
        local real = (math.floor(i * (tonumber(os.date("%d")) * 32)))
        math.randomseed(seed + real)
        word[i] = string.char(math.random(33, 126))
    end

    return table.concat(word)
end
function custom.formatTable(tbl)
    if tbl then
        local oldTable = tbl
        local newTable = {}

        local formattedTable = {}

        for option, value in next, oldTable do
            newTable[option:lower()] = value
        end

        setmetatable(
            formattedTable,
            {
                __newindex = function(t, k, v)
                    rawset(newTable, k:lower(), v)
                end,
                __index = function(t, k, v)
                    return newTable[k:lower()]
                end
            }
        )

        return formattedTable
    else
        return {}
    end
end
if not getgenv()[custom.generateString(8, 2)] then
    getgenv()[custom.generateString(8, 2)] = {}
end
function custom.createObject(class, properties)
    local tableHold = getgenv()[custom.generateString(8, 2)]
    local obj = Instance.new(class)

    local forcedProperties = {
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Name = custom.generateString(32, tick() + #tableHold)
    }

    for prop, value in next, properties do
        obj[prop] = value
    end

    for prop, value in next, forcedProperties do
        pcall(
            function()
                obj[prop] = value
            end
        )
    end
    table.insert(tableHold, obj)
    return obj
end
function custom.animate(obj, info, properties, callback)
    local anim = game:GetService("TweenService"):Create(obj, TweenInfo.new(unpack(info)), properties)
    anim:Play()

    if callback then
        anim.Completed:Connect(callback)
    end
end
local function getModifiedColors(baseColor, nColors, mode)
    local colors = {}
    local timing = 0
    local h, s, l = Color3.toHSV(baseColor)

    if mode == "analogous" then
        for _ = 1, math.round(nColors / 2) do
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV((h - 0.1) % 1, s, l)))
            timing = timing + 1 / nColors
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV((h + 0.1) % 1, s, l)))
            if math.round(nColors / 2) > 1 then
                timing = timing + 1 / nColors
            end
        end
    elseif mode == "triadic" then
        for _ = 1, math.round(nColors / 2) do
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV((h - 0.33) % 1, s, l)))
            timing = timing + 1 / nColors
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV((h + 0.33) % 1, s, l)))
            if math.round(nColors / 2) > 1 then
                timing = timing + 1 / nColors
            end
        end
    elseif mode == "square" then
        for _ = 1, math.round(nColors / 3) do
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV((h + 0.25) % 1, s, l)))
            timing = timing + 1 / (nColors - 1)
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV((h + 0.5) % 1, s, l)))
            timing = timing + 1 / (nColors - 1)
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV((h + 0.75) % 1, s, l)))
            if math.round(nColors / 3) > 1 then
                timing = timing + 1 / nColors
            end
        end
    elseif mode == "tetradic" then
        for _ = 1, math.round(nColors / 3) do
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV((h + 0.16) % 1, s, l)))
            timing = timing + 1 / (nColors - 1)
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV((h + 0.5) % 1, s, l)))
            timing = timing + 1 / (nColors - 1)
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV((h + 0.66) % 1, s, l)))
            if math.round(nColors / 3) > 1 then
                timing = timing + 1 / nColors
            end
        end
    elseif mode == "complementary" then
        for i = 1, nColors do
            h = (h + 0.5) % 1
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV(h, s, l)))
            timing = timing + 1 / (nColors - 1)
        end
    elseif mode == "split_complementary" then
        for i = 1, nColors do
            h = (h + 0.4 + (0.16 * (i - 1))) % 1
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV(h, s, l)))
            timing = timing + 1 / (nColors - 1)
        end
    elseif mode == "split_complementary2" then
        for i = 1, nColors do
            h = (h + 0.4 + (0.16 * (i - 1)) % 2) % 1
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV(h, s, l)))
            timing = timing + 1 / (nColors - 1)
        end
    elseif mode == "rgb" then
        for i = 1, nColors do
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV(h, s, l)))
            h = (h + 1 / nColors) % 1
            timing = timing + 1 / (nColors - 1)
        end
    elseif mode == "custom1" then
        for i = 1, nColors do
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV(h, s, l)))
            h = (h + 1 / (i + 1)) % 1
            timing = timing + 1 / (nColors - 1)
        end
    elseif mode == "logisticmap" then
        local r = 3.8
        local x = 0.2
        for i = 1, nColors do
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV(h, s, l)))
            h = (h + x) % 1
            x = r * x * (1 - x)
            timing = timing + 1 / (nColors - 1)
        end
    elseif mode == "sinusoidal" then
        for i = 1, nColors do
            local factor = math.sin(h * math.pi * 2) + math.cos(h * math.pi * 2)
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV(h, s, l)))
            h = (h + factor * 0.1) % 1
            timing = timing + 1 / (nColors - 1)
        end
    elseif mode == "quadratic" then
        for i = 1, nColors do
            local factor = h ^ 2
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV(h, s, l)))
            h = (h + factor * 0.1) % 1
            timing = timing + 1 / (nColors - 1)
        end
    elseif mode == "cubic" then
        for i = 1, nColors do
            local factor = h ^ 3
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV(h, s, l)))
            h = (h + factor * 0.1) % 1
            timing = timing + 1 / (nColors - 1)
        end
    elseif mode == "sawtooth" then
        for i = 1, nColors do
            local factor = h - math.floor(h)
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV(h, s, l)))
            h = (h + factor * 0.1) % 1
            timing = timing + 1 / (nColors - 1)
        end
    elseif mode == "exponential" then
        for i = 1, nColors do
            local factor = math.exp(h)
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV(h, s, l)))
            h = (h + factor * 0.1) % 1
            timing = timing + 1 / (nColors - 1)
        end
    elseif mode == "logarithmic" then
        for i = 1, nColors do
            local factor = math.log(h + 1)
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV(h, s, l)))
            h = (h + factor * 0.1) % 1
            timing = timing + 1 / (nColors - 1)
        end
    elseif mode == "tentvariation" then
        for i = 1, nColors do
            local factor = h
            if h > 0.5 then
                factor = 1 - h
            end
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV(h, s, l)))
            h = (h + factor * 0.1) % 1
            timing = timing + 1 / (nColors - 1)
        end
    elseif mode == "inversesquare" then
        for i = 1, nColors do
            local factor = 1 / (h ^ 2 + 1)
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV(h, s, l)))
            h = (h + factor * 0.1) % 1
            timing = timing + 1 / (nColors - 1)
        end
    elseif mode == "horseshoe" then
        for i = 1, nColors do
            local factor = h * (2 - h)
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV(h, s, l)))
            h = (h + factor * 0.1) % 1
            timing = timing + 1 / (nColors - 1)
        end
    elseif mode == "piecewiselinear" then
        for i = 1, nColors do
            local factor = h
            if h > 0.5 then
                factor = 1 - h
            end
            table.insert(colors, ColorSequenceKeypoint.new(timing, Color3.fromHSV(h, s, l)))
            h = (h + factor * 0.1) % 1
            timing = timing + 1 / (nColors - 1)
        end
    end

    return colors
end

function custom.enableDrag(obj, opts)
    local start, objPosition, dragging

    obj.InputBegan:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                start = input.Position
                objPosition = obj.Position
            end
        end
    )

    obj.InputEnded:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end
    )

    game:GetService("UserInputService").InputChanged:Connect(
        function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                if getgenv()[custom.generateString(8, 1)] then
                    if getgenv()[custom.generateString(8, 1)].canDrag then
                        local delta = input.Position - start
                        local targetPosition =
                            UDim2.new(
                            objPosition.X.Scale,
                            objPosition.X.Offset + delta.X,
                            objPosition.Y.Scale,
                            objPosition.Y.Offset + delta.Y
                        )
                        custom.animate(obj, opts, {Position = targetPosition})
                    end
                else
                    local delta = input.Position - start
                    local targetPosition =
                        UDim2.new(
                        objPosition.X.Scale,
                        objPosition.X.Offset + delta.X,
                        objPosition.Y.Scale,
                        objPosition.Y.Offset + delta.Y
                    )
                    custom.animate(obj, opts, {Position = targetPosition})
                end
            end
        end
    )
end
function custom.createRipple(obj)
    local oldthing = obj.ClipsDescendants
    obj.ClipsDescendants = true
    local mouse = game.Players.LocalPlayer:GetMouse()
    local x = mouse.X - obj.AbsolutePosition.X
    local y = mouse.Y - obj.AbsolutePosition.Y

    local ripple =
        custom.createObject(
        "Frame",
        {
            Size = UDim2.new(0, 0, 0, 0),
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = obj,
            Position = UDim2.new(0, x, 0, y),
            BackgroundTransparency = 0.4
        }
    )

    local corner =
        custom.createObject(
        "UICorner",
        {
            CornerRadius = UDim.new(100, 0),
            Parent = ripple
        }
    )

    custom.animate(
        ripple,
        {0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out},
        {
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(0, x - 15, 0, y - 15)
        }
    )

    custom.animate(
        ripple,
        {0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out},
        {
            BackgroundTransparency = 1
        },
        function()
            ripple:Destroy()
            task.wait(0.25)
            obj.ClipsDescendants = oldthing
        end
    )
end

function custom.hasProperty(obj, property)
    local success =
        pcall(
        function()
            local test = obj[property]
        end
    )
    if success then
        return obj[property]
    else
        return false
    end
end
function custom.getCenterPosition(sizeX, sizeY)
    return UDim2.new(0.5, -(sizeX / 2), 0.5, -(sizeY / 2))
end
return custom
