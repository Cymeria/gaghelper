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

-- Koordinat text label'ı oluştur (sağ alt köşe)
local coordTextLabel = Instance.new("TextLabel")
coordTextLabel.Name = "CoordText"
coordTextLabel.Size = UDim2.new(0, 200, 0, 40)
coordTextLabel.Position = UDim2.new(1, -210, 1, -50) -- Sağ alt köşe
coordTextLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
coordTextLabel.BackgroundTransparency = 0.3
coordTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
coordTextLabel.Text = "Koordinatlar: (0, 0, 0)"
coordTextLabel.Font = Enum.Font.Gotham
coordTextLabel.TextSize = 12
coordTextLabel.TextXAlignment = Enum.TextXAlignment.Left
coordTextLabel.Parent = screenGui

-- Padding ekle
local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 8)
padding.Parent = coordTextLabel

-- Işınlanma koordinatları (istediğiniz gibi değiştirebilirsiniz)
local gearPosition = Vector3.new(-285, 4, -14)  -- Gear bölgesi koordinatları
local eventPosition = Vector3.new(-113, 5, 1) -- Event bölgesi koordinatları

-- Karakterin koordinatlarını güncelleyen fonksiyon
local function updateCoordinates()
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local hrp = character.HumanoidRootPart
		local position = hrp.Position
		coordTextLabel.Text = string.format("Koordinatlar: (%.1f, %.1f, %.1f)", position.X, position.Y, position.Z)
	end
end

-- Koordinatları kopyalama fonksiyonu
local function copyCoordinatesToClipboard()
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local hrp = character.HumanoidRootPart
		local position = hrp.Position
		local coordString = string.format("Vector3.new(%.2f, %.2f, %.2f)", position.X, position.Y, position.Z)
		
		-- Text'i değiştirerek kopyalandığını belirt
		local originalText = coordTextLabel.Text
		coordTextLabel.Text = "Kopyalandı! " .. originalText
		
		-- Kopyalama işlemi (Roblox Studio'da çalışması için)
		pcall(function()
			setclipboard(coordString)
		end)
		
		-- 2 saniye sonra orijinal text'e dön
		wait(2)
		coordTextLabel.Text = originalText
	end
end

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
		updateCoordinates()
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
		updateCoordinates()
	end
end

-- Buton tıklama event'leri
gearButton.MouseButton1Click:Connect(teleportToGear)
eventButton.MouseButton1Click:Connect(teleportToEvent)

-- Koordinat text'ine tıklama event'i
coordTextLabel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		copyCoordinatesToClipboard()
	end
end)

-- Koordinatları sürekli güncelle
while true do
	updateCoordinates()
	wait(0.5) -- Her 0.5 saniyede bir güncelle
end