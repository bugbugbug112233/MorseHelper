loadstring([[
local Morse = {
    A=".-",B="-...",C="-.-.",D="-..",E=".",F="..-.",
    G="--.",H="....",I="..",J=".---",K="-.-",L=".-..",
    M="--",N="-.",O="---",P=".--.",Q="--.-",R=".-.",
    S="...",T="-",U="..-",V="...-",W=".--",X="-..-",
    Y="-.--",Z="--..",
    ["0"]="-----",["1"]=".----",["2"]="..---",["3"]="...--",
    ["4"]="....-",["5"]=".....",["6"]="-....",["7"]="--...",
    ["8"]="---..",["9"]="----."
}

local Reverse = {}
for letter, code in pairs(Morse) do
    Reverse[code] = letter
end

local function textToMorse(text)
    text = text:upper()
    local morse = ""
    for i = 1, #text do
        local c = text:sub(i,i)
        if Morse[c] then
            morse ..= Morse[c] .. " "
        elseif c == " " then
            morse ..= "   "
        end
    end
    return morse
end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "MorseGui"
gui.ResetOnSpawn = false
local okParent = pcall(function() gui.Parent = CoreGui end)
if not okParent then
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

task.wait(0.5)

local function makeLabel(parent, text, pos, size, textSize)
    local l = Instance.new("TextLabel", parent)
    l.BackgroundTransparency = 1
    l.Position = pos
    l.Size = size
    l.Text = text
    l.Font = Enum.Font.Gotham
    l.TextSize = textSize or 14
    l.TextColor3 = Color3.new(1,1,1)
    l.TextWrapped = true
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Top
    return l
end

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,160)
frame.Position = UDim2.new(0.5,-340,0.5,-80)
frame.BackgroundColor3 = Color3.fromRGB(30,30,45)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,16)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "MORSE HELPER"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0.9,0,0,40)
box.Position = UDim2.new(0.05,0,0.45,0)
box.PlaceholderText = "Text → Morse Movement"
box.Text = ""
box.Font = Enum.Font.Gotham
box.TextScaled = true
box.BackgroundColor3 = Color3.fromRGB(50,50,65)
box.TextColor3 = Color3.new(1,1,1)

makeLabel(frame, ". = jump   - = side step (out and back)",
    UDim2.new(0.05,0,0.8,0), UDim2.new(0.9,0,0,24), 12)

local SYMBOL_TIME = 0.65
local SIDE = 2.5
local running = false

local function walkTo(hum, root, pos, timeout)
    hum:MoveTo(pos)
    local t = os.clock()
    while os.clock() - t < timeout do
        local a = Vector3.new(root.Position.X, 0, root.Position.Z)
        local b = Vector3.new(pos.X, 0, pos.Z)
        if (a - b).Magnitude < 0.5 then break end
        task.wait()
    end
end

local function moveInMorse(morse)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

    local oldAutoRotate = hum.AutoRotate
    hum.AutoRotate = false

    local home = root.Position
    local right = root.CFrame.RightVector
    local direction = 1

    local ok, err = pcall(function()
        local i = 1
        while i <= #morse do
            if hum.Health <= 0 then return end
            local s = morse:sub(i,i)

            if s == "." then
                local t = os.clock()
                hum.Jump = true
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait(math.max(0, SYMBOL_TIME - (os.clock() - t)))

            elseif s == "-" then
                local t = os.clock()
                walkTo(hum, root, home + right * SIDE * direction, 0.4)
                walkTo(hum, root, home, 0.4)
                direction *= -1
                task.wait(math.max(0, SYMBOL_TIME - (os.clock() - t)))

            elseif s == " " then
                local count = 0
                while morse:sub(i,i) == " " do
                    count += 1
                    i += 1
                end
                i -= 1

                if count >= 3 then
                    task.wait(2)
                else
                    task.wait(1)
                end
            end

            i += 1
        end
    end)

    hum:Move(Vector3.zero)
    hum.AutoRotate = oldAutoRotate
    if not ok then warn("Morse error: " .. tostring(err)) end
end

box.FocusLost:Connect(function(enter)
    if not enter or box.Text == "" or running then return end
    running = true
    local morse = textToMorse(box.Text)
    box.Text = "Running..."
    moveInMorse(morse)
    task.wait(1)
    box.Text = "Done!"
    task.wait(1)
    box.Text = ""
    running = false
end)

local frame2 = Instance.new("Frame", gui)
frame2.Size = UDim2.new(0,260,0,330)
frame2.Position = UDim2.new(0.5,40,0.5,-165)
frame2.BackgroundColor3 = Color3.fromRGB(30,30,45)
frame2.BorderSizePixel = 0
Instance.new("UICorner", frame2).CornerRadius = UDim.new(0,16)
frame2.Active = true
frame2.Draggable = true

local title2 = Instance.new("TextLabel", frame2)
title2.Size = UDim2.new(1,0,0,40)
title2.BackgroundTransparency = 1
title2.Text = "MORSE DECODER"
title2.Font = Enum.Font.GothamBold
title2.TextScaled = true
title2.TextColor3 = Color3.new(1,1,1)

local list = Instance.new("ScrollingFrame", frame2)
list.Position = UDim2.new(0.05,0,0,45)
list.Size = UDim2.new(0.9,0,0,110)
list.BackgroundColor3 = Color3.fromRGB(40,40,58)
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.CanvasSize = UDim2.new(0,0,0,0)
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", list).CornerRadius = UDim.new(0,8)
local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,4)

local statusLbl = makeLabel(frame2, "Player: none", UDim2.new(0.05,0,0,162), UDim2.new(0.9,0,0,20), 14)
local morseLbl = makeLabel(frame2, "Morse: ", UDim2.new(0.05,0,0,186), UDim2.new(0.9,0,0,44), 14)
local textLbl = makeLabel(frame2, "Text: ", UDim2.new(0.05,0,0,234), UDim2.new(0.9,0,0,52), 18)
textLbl.Font = Enum.Font.GothamBold

local clearBtn = Instance.new("TextButton", frame2)
clearBtn.Position = UDim2.new(0.05,0,0,294)
clearBtn.Size = UDim2.new(0.9,0,0,26)
clearBtn.Text = "Clear"
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 14
clearBtn.TextColor3 = Color3.new(1,1,1)
clearBtn.BackgroundColor3 = Color3.fromRGB(80,50,60)
clearBtn.BorderSizePixel = 0
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0,8)

local target = nil
local buttons = {}
local buffer, decoded, rawLog = "", "", ""
local lastEvent = 0
local spaceAdded = true
local wasAir = false
local lastLateral = 0

local function refresh()
    local shownRaw = rawLog
    if #shownRaw > 40 then shownRaw = "…" .. shownRaw:sub(-40) end
    morseLbl.Text = "Morse: " .. shownRaw
    textLbl.Text = "Text: " .. decoded
end

local function resetDecoder()
    buffer, decoded, rawLog = "", "", ""
    spaceAdded = true
    wasAir = false
    lastLateral = 0
    refresh()
end

local function commitLetter()
    if buffer ~= "" then
        decoded ..= (Reverse[buffer] or "?")
        buffer = ""
        rawLog ..= " "
        refresh()
    end
end

local function addSymbol(s)
    buffer ..= s
    rawLog ..= s
    lastEvent = os.clock()
    spaceAdded = false
    refresh()
end

local function colorButtons()
    for plr, btn in pairs(buttons) do
        btn.BackgroundColor3 = (plr == target) and Color3.fromRGB(70,120,200) or Color3.fromRGB(55,55,75)
    end
end

local function selectPlayer(plr)
    if target == plr then
        target = nil
        statusLbl.Text = "Player: none"
    else
        target = plr
        statusLbl.Text = "Player: " .. plr.Name
    end
    resetDecoder()
    colorButtons()
end

local function addPlayerButton(plr)
    if buttons[plr] then return end
    local b = Instance.new("TextButton", list)
    b.Size = UDim2.new(1,-8,0,26)
    b.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(55,55,75)
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.MouseButton1Click:Connect(function() selectPlayer(plr) end)
    buttons[plr] = b
end

for _, p in ipairs(Players:GetPlayers()) do addPlayerButton(p) end
Players.PlayerAdded:Connect(addPlayerButton)
Players.PlayerRemoving:Connect(function(p)
    if buttons[p] then buttons[p]:Destroy() buttons[p] = nil end
    if target == p then selectPlayer(p) end
end)

clearBtn.MouseButton1Click:Connect(resetDecoder)

RunService.Heartbeat:Connect(function()
    if not target then return end
    local char = target.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local now = os.clock()
    local vel = root.AssemblyLinearVelocity

    local air = vel.Y > 30
    if air and not wasAir then
        addSymbol(".")
    end
    wasAir = air

    local flat = Vector3.new(vel.X, 0, vel.Z)
    local lat = math.abs(flat:Dot(root.CFrame.RightVector))
    local fwd = math.abs(flat:Dot(root.CFrame.LookVector))
    local movingSide = lat > 6 and lat > fwd * 1.5
    if movingSide then
        if now - lastLateral > 0.15 then
            addSymbol("-")
        end
        lastLateral = now
    end

    if buffer ~= "" and now - lastEvent > 1.15 then
        commitLetter()
    end
    if buffer == "" and not spaceAdded and decoded ~= "" and now - lastEvent > 2.15 then
        decoded ..= " "
        rawLog ..= "/ "
        spaceAdded = true
        refresh()
    end
end)

]])()
