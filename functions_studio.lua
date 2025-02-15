--would appreciate credits to TheEmptynessProject if you decide to use some of these functions
local custom = {}
function custom.protect(instanceToProtect, parent)
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
if not _G[custom.generateString(8, 2)] then
    _G[custom.generateString(8, 2)] = {}
end
function custom.createObject(class, properties)
    local tableHold = _G[custom.generateString(8, 2)]
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
function custom.getModifiedColors(baseColor, nColors, mode)
    local colors = {}
    local h, s, l = Color3.toHSV(baseColor)
    local hues = {}  -- This will hold the computed hue values

    if mode == "analogous" then
        local iterations = math.round(nColors / 2)
        for i = 1, iterations do
            table.insert(hues, (h - 0.1) % 1)
            table.insert(hues, (h + 0.1) % 1)
        end

    elseif mode == "triadic" then
        local iterations = math.round(nColors / 2)
        for i = 1, iterations do
            table.insert(hues, (h - 0.33) % 1)
            table.insert(hues, (h + 0.33) % 1)
        end

    elseif mode == "square" then
        local iterations = math.round(nColors / 3)
        for i = 1, iterations do
            table.insert(hues, (h + 0.25) % 1)
            table.insert(hues, (h + 0.5)  % 1)
            table.insert(hues, (h + 0.75) % 1)
        end

    elseif mode == "tetradic" then
        local iterations = math.round(nColors / 3)
        for i = 1, iterations do
            table.insert(hues, (h + 0.16) % 1)
            table.insert(hues, (h + 0.5)  % 1)
            table.insert(hues, (h + 0.66) % 1)
        end

    elseif mode == "complementary" then
        for i = 1, nColors do
            h = (h + 0.5) % 1
            table.insert(hues, h)
        end

    elseif mode == "split_complementary" then
        for i = 1, nColors do
            h = (h + 0.4 + 0.16 * (i - 1)) % 1
            table.insert(hues, h)
        end

    elseif mode == "split_complementary2" then
        for i = 1, nColors do
            h = (h + 0.4 + (0.16 * (i - 1)) % 2) % 1
            table.insert(hues, h)
        end

    elseif mode == "rgb" then
        for i = 1, nColors do
            table.insert(hues, h)
            h = (h + 1 / nColors) % 1
        end

    elseif mode == "custom1" then
        for i = 1, nColors do
            table.insert(hues, h)
            h = (h + 1 / (i + 1)) % 1
        end

    elseif mode == "logisticmap" then
        local r = 3.8
        local x = 0.2
        for i = 1, nColors do
            table.insert(hues, h)
            h = (h + x) % 1
            x = r * x * (1 - x)
        end

    elseif mode == "sinusoidal" then
        for i = 1, nColors do
            table.insert(hues, h)
            local factor = math.sin(h * math.pi * 2) + math.cos(h * math.pi * 2)
            h = (h + factor * 0.1) % 1
        end

    elseif mode == "quadratic" then
        for i = 1, nColors do
            table.insert(hues, h)
            local factor = h ^ 2
            h = (h + factor * 0.1) % 1
        end

    elseif mode == "cubic" then
        for i = 1, nColors do
            table.insert(hues, h)
            local factor = h ^ 3
            h = (h + factor * 0.1) % 1
        end

    elseif mode == "sawtooth" then
        for i = 1, nColors do
            table.insert(hues, h)
            local factor = h
            h = (h + factor * 0.1) % 1
        end

    elseif mode == "exponential" then
        for i = 1, nColors do
            table.insert(hues, h)
            local factor = math.exp(h)
            h = (h + factor * 0.1) % 1
        end

    elseif mode == "logarithmic" then
        for i = 1, nColors do
            table.insert(hues, h)
            local factor = math.log(h + 1)
            h = (h + factor * 0.1) % 1
        end

    elseif mode == "tentvariation" then
        for i = 1, nColors do
            table.insert(hues, h)
            local factor = (h > 0.5) and (1 - h) or h
            h = (h + factor * 0.1) % 1
        end

    elseif mode == "inversesquare" then
        for i = 1, nColors do
            table.insert(hues, h)
            local factor = 1 / (h ^ 2 + 1)
            h = (h + factor * 0.1) % 1
        end

    elseif mode == "horseshoe" then
        for i = 1, nColors do
            table.insert(hues, h)
            local factor = h * (2 - h)
            h = (h + factor * 0.1) % 1
        end

    else
        error("Unknown mode: " .. tostring(mode))
    end

    local total = #hues
    for i, hue in ipairs(hues) do
        local t = (total > 1) and ((i - 1) / (total - 1)) or 0
        table.insert(colors, ColorSequenceKeypoint.new(t, Color3.fromHSV(hue, s, l)))
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
                if _G[custom.generateString(8, 1)] then
                    if _G[custom.generateString(8, 1)].canDrag then
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
function custom.getCenterPosition(sizeX, sizeY) --except this one, i found this in a random script
    return UDim2.new(0.5, -(sizeX / 2), 0.5, -(sizeY / 2))
end
return custom
