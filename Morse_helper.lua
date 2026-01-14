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
local TweenService = game:GetService("TweenService")

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "MorseGui"
gui.ResetOnSpawn = false

task.wait(0.5)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,160)
frame.Position = UDim2.new(0.5,-160,0.5,-80)
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
box.PlaceholderText = "Texto → movimiento Morse"
box.Font = Enum.Font.Gotham
box.TextScaled = true
box.BackgroundColor3 = Color3.fromRGB(50,50,65)
box.TextColor3 = Color3.new(1,1,1)

local function tweenTo(root, goal, speed)
    local dist = (root.Position - goal.Position).Magnitude
    local time = dist / speed
    local tween = TweenService:Create(
        root,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        {CFrame = goal}
    )
    tween:Play()
    tween.Completed:Wait()
end

local SYMBOL_TIME = 0.65

local function moveInMorse(morse)
    local player = Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

    local direction = 1
    local SIDE = 2
    local SPEED = 8

    local i = 1
    while i <= #morse do
        local s = morse:sub(i,i)

        if s == "." then
            local t = os.clock()
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(math.max(0, SYMBOL_TIME - (os.clock() - t)))

        elseif s == "-" then
            local t = os.clock()
            local startCF = root.CFrame
            local offset = startCF.RightVector * SIDE * direction
            tweenTo(root, startCF + offset, SPEED)
            tweenTo(root, startCF, SPEED)
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
end

box.FocusLost:Connect(function(enter)
    if not enter or box.Text == "" then return end
    local morse = textToMorse(box.Text)
    box.Text = "Ejecutando..."
    moveInMorse(morse)
    task.wait(1)
    box.Text = "Listo ✔"
end)

]])()
