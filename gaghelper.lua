local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Işınlanma konumları (istediğiniz gibi değiştirebilirsiniz)
local TELEPORT_POSITIONS = {
	Vector3.new(-285, 1, -14),    -- Buton 1 ışınlanma pozisyonu
	Vector3.new(-113, 5, 1),    -- Buton 2 ışınlanma pozisyonu
	Vector3.new(127, 5, 168)      -- Buton 3 ışınlanma pozisyonu
}

-- Buton konumları (UDim2 formatında - istediğiniz gibi değiştirebilirsiniz)
local BUTTON_POSITIONS = {
	UDim2.new(0, 5, 0, 25),   -- Buton 1 ekran pozisyonu (X: 100, Y: 10)
	UDim2.new(0, 5, 0, 70),   -- Buton 2 ekran pozisyonu (X: 190, Y: 10)
	UDim2.new(0, 5, 0, 115)    -- Buton 3 ekran pozisyonu (X: 280, Y: 10)
}

-- Buton renkleri
local BUTTON_COLORS = {
	Color3.fromRGB(255, 100, 100),  -- Kırmızı
	Color3.fromRGB(100, 255, 100),  -- Yeşil
	Color3.fromRGB(100, 100, 255)   -- Mavi
}

-- Buton isimleri
local BUTTON_NAMES = {
	"GEAR",
	"Event", 
	"ASC"
}

-- Okunaklı font seçenekleri (en iyileri)
local FONT_OPTIONS = {
	Enum.Font.FredokaOne,      -- Çok okunaklı, kalın
	Enum.Font.Oswald,          -- Geniş ve net
	Enum.Font.Arcade,          -- Oyun stili, net
	Enum.Font.GothamBlack,     -- Modern ve kalın
	Enum.Font.GothamBold,      -- Önceki kullanım
	Enum.Font.Highway,         -- Büyük ve net
	Enum.Font.SourceSansBold,  -- Basit ve okunaklı
	Enum.Font.Antique,         -- Kalın ve net
}

-- Seçilen font (istediğiniz fontu buradan değiştirebilirsiniz)
local SELECTED_FONT = Enum.Font.GothamBlack

-- Eski butonları temizle
local function CleanupOldButtons()
	local screenGui = playerGui:FindFirstChild("TeleportButtonsGui")
	if screenGui then
		screenGui:Destroy()
	end
end

-- Buton oluştur
local function CreateTeleportButton(index)
	local button = Instance.new("TextButton")
	button.Name = "TeleportButton" .. index
	button.Size = UDim2.new(0, 80, 0, 40)
	button.Position = BUTTON_POSITIONS[index]
	button.BackgroundColor3 = BUTTON_COLORS[index]
	button.Text = BUTTON_NAMES[index]
	button.TextColor3 = Color3.new(1, 1, 1)  -- Beyaz yazı
	--button.TextScaled = true
	button.TextSize = 16
	button.Font = SELECTED_FONT
	button.TextStrokeColor3 = Color3.new(0, 0, 0)  -- Siyah outline
	button.TextStrokeTransparency = 0  -- Outline tam opak
	button.ZIndex = 10 -- Diğer elementlerin üstünde görünmesi için
	
	-- Buton stilleri
	button.AutoButtonColor = true
	button.BackgroundTransparency = 0.2  -- Daha az şeffaf
	
	-- Köşe yuvarlatma
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button
	
	-- Buton kenarlığı
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.new(0, 0, 0)  -- Beyaz kenarlık
	stroke.Thickness = 1.5
	stroke.Parent = button
	
	-- Gradient efekti (isteğe bağlı, daha güzel görünüm için)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, BUTTON_COLORS[index]),
		ColorSequenceKeypoint.new(1, Color3.new(
			math.clamp(BUTTON_COLORS[index].R * 0.7, 0, 1),
			math.clamp(BUTTON_COLORS[index].G * 0.7, 0, 1),
			math.clamp(BUTTON_COLORS[index].B * 0.7, 0, 1)
		))
	})
	gradient.Parent = button
	
	-- Işınlanma fonksiyonu
	button.MouseButton1Click:Connect(function()
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local humanoidRootPart = character.HumanoidRootPart
			
			-- Işınlanma efekti
			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local tween = TweenService:Create(button, tweenInfo, {
				BackgroundTransparency = 0.6,
				TextTransparency = 0.5,
				TextStrokeTransparency = 0.3
			})
			tween:Play()
			
			-- Işınlanma
			humanoidRootPart.CFrame = CFrame.new(TELEPORT_POSITIONS[index])
			
			-- Butonu eski haline getir
			wait(0.5)
			local tweenBack = TweenService:Create(button, tweenInfo, {
				BackgroundTransparency = 0.2,
				TextTransparency = 0,
				TextStrokeTransparency = 0
			})
			tweenBack:Play()
			
			print(BUTTON_NAMES[index] .. " konumuna ışınlandı: " .. tostring(TELEPORT_POSITIONS[index]))
		else
			warn("Karakter bulunamadı!")
		end
	end)
	
	-- Hover efekti
	button.MouseEnter:Connect(function()
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(button, tweenInfo, {
			Size = UDim2.new(0, 85, 0, 42),
			BackgroundTransparency = 0.1
		})
		tween:Play()
	end)
	
	button.MouseLeave:Connect(function()
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(button, tweenInfo, {
			Size = UDim2.new(0, 80, 0, 40),
			BackgroundTransparency = 0.2
		})
		tween:Play()
	end)
	
	return button
end

-- Ana fonksiyon
local function InitializeTeleportButtons()
	-- Eski butonları temizle
	CleanupOldButtons()
	
	-- ScreenGui oluştur
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TeleportButtonsGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	screenGui.Parent = playerGui
	
	-- Butonları oluştur
	for i = 1, 3 do
		local button = CreateTeleportButton(i)
		button.Parent = screenGui
	end
	
	print("Teleport butonları başarıyla yüklendi!")
	print("Kullanılan font: " .. tostring(SELECTED_FONT))
end

-- Script başlatıldığında butonları oluştur
InitializeTeleportButtons()

-- Oyun yüklenmesini bekle ve karakter hazır olduğunda kontrol et
player.CharacterAdded:Connect(function(character)
	wait(1)
	print("Karakter yüklendi, butonlar aktif!")
end)

print("Grow a Garden Teleport Butonları aktif!")
