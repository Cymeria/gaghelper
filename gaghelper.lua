-- TeleportButonScript
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Ekran GUI'sini oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGUI"
screenGui.Parent = playerGui

-- Buton container'ı oluştur
local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.Size = UDim2.new(0, 220, 0, 120)
buttonContainer.Position = UDim2.new(1, -300, 0, 2) -- Sağdan 240px sola, üstten 20px aşağı
--buttonContainer.Position = UDim2.new(0.5, -110, 0.5, -60) -- Ekranın ortası
buttonContainer.BackgroundTransparency = 1 -- Şeffaf arkaplan
buttonContainer.Parent = screenGui

-- Gear butonu oluştur
local gearButton = Instance.new("TextButton")
gearButton.Name = "GearButton"
gearButton.Size = UDim2.new(0, 100, 0, 50)
gearButton.Position = UDim2.new(0, 0, 0, 0)
gearButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
gearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
gearButton.Text = "GEAR"
gearButton.Font = Enum.Font.GothamBold
gearButton.TextSize = 14
gearButton.Parent = buttonContainer

-- Event butonu oluştur
local eventButton = Instance.new("TextButton")
eventButton.Name = "EventButton"
eventButton.Size = UDim2.new(0, 100, 0, 50)
eventButton.Position = UDim2.new(0, 120, 0, 0)
eventButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
eventButton.TextColor3 = Color3.fromRGB(255, 255, 255)
eventButton.Text = "EVENT"
eventButton.Font = Enum.Font.GothamBold
eventButton.TextSize = 14
eventButton.Parent = buttonContainer

-- Buton efektleri - Gear
gearButton.MouseEnter:Connect(function()
	gearButton.BackgroundColor3 = Color3.fromRGB(0, 140, 225)
end)

gearButton.MouseLeave:Connect(function()
	gearButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
end)

-- Buton efektleri - Event
eventButton.MouseEnter:Connect(function()
	eventButton.BackgroundColor3 = Color3.fromRGB(225, 80, 0)
end)

eventButton.MouseLeave:Connect(function()
	eventButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
end)

-- Işınlanma koordinatları (istediğiniz gibi değiştirebilirsiniz)
local gearPosition = Vector3.new(-285, 4, -14)  -- Gear bölgesi koordinatları
local eventPosition = Vector3.new(-113, 5, 1) -- Event bölgesi koordinatları

-- Işınlanma fonksiyonu - Gear
local function teleportToGear()
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local hrp = character.HumanoidRootPart
		
		-- Buton efektleri
		gearButton.Text = "Işınlanıyor..."
		gearButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
		
		-- Işınlanma efektleri için
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(gearButton, tweenInfo, {BackgroundTransparency = 0.5})
		tween:Play()
		
		-- Işınlanma
		hrp.CFrame = CFrame.new(gearPosition)
		
		-- 1 saniye bekle
		wait(1)
		
		-- Butonu eski haline getir
		gearButton.Text = "GEAR"
		gearButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		gearButton.BackgroundTransparency = 0
		
		-- Koordinatları güncelle
		--updateCoordinates()
	end
end

-- Işınlanma fonksiyonu - Event
local function teleportToEvent()
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local hrp = character.HumanoidRootPart
		
		-- Buton efektleri
		eventButton.Text = "Işınlanıyor..."
		eventButton.BackgroundColor3 = Color3.fromRGB(200, 70, 0)
		
		-- Işınlanma efektleri için
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(eventButton, tweenInfo, {BackgroundTransparency = 0.5})
		tween:Play()
		
		-- Işınlanma
		hrp.CFrame = CFrame.new(eventPosition)
		
		-- 1 saniye bekle
		wait(1)
		
		-- Butonu eski haline getir
		eventButton.Text = "EVENT"
		eventButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
		eventButton.BackgroundTransparency = 0
		
		-- Koordinatları güncelle
		--updateCoordinates()
	end
end

-- Buton tıklama event'leri
gearButton.MouseButton1Click:Connect(teleportToGear)
eventButton.MouseButton1Click:Connect(teleportToEvent)
