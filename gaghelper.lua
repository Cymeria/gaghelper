-- Grow a Garden Teleport Script - LOCAL STORAGE
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local savedPosition1 = nil -- 4. buton için konum
local savedPosition2 = nil -- 5. buton için konum

-- ⚙️ AYARLAR - Bu kısmı değiştirebilirsin
local BUTON_AYARLARI = {
    -- Buton metinleri
    ButonMetinleri = {"Gear", "Event", "ASC"},
    
    -- Buton isimleri (Explorer'da görünecek)
    ButonIsimleri = {"GearButton", "EventButton", "ASCButton"},
    
    -- Işınlanma koordinatları
    IsinlanmaKoordinatlari = {
        Vector3.new(-236, 3, -14),    -- Gear butonu için
        Vector3.new(-113, 5, 1),      -- Event butonu için
        Vector3.new(72, 3, 163)      -- ASC butonu için
    },
    
    -- Buton renkleri
    ButonRenkleri = {
        Color3.fromRGB(74, 124, 255),  -- Mavi (Gear)
        Color3.fromRGB(255, 87, 87),   -- Kırmızı (Event)
        Color3.fromRGB(76, 135, 60),   -- Yeşil (ASC)
        Color3.fromRGB(255, 193, 7),   -- Sarı (Kaydetme 1)
        Color3.fromRGB(156, 39, 176),  -- Mor (Işınlanma 1)
        Color3.fromRGB(255, 152, 0),   -- Turuncu (Kaydetme 2)
        Color3.fromRGB(0, 150, 136)    -- Turkuaz (Işınlanma 2)
    }
}

-- 📁 LOCAL STORAGE FONKSİYONLARI
local function SavePositionToStorage(position, slot)
    local success, errorMessage = pcall(function()
        -- LocalStorage'a kaydet
        local storageData = {
            X = position.X,
            Y = position.Y, 
            Z = position.Z,
            Timestamp = os.time(),
            Slot = slot
        }
        
        -- JSON formatında kaydet (string olarak)
        local jsonData = game:GetService("HttpService"):JSONEncode(storageData)
        
        -- LocalStorage'a kaydet
        if plugin then
            plugin:SetSetting("GardenSavedPosition_" .. slot, jsonData)
        else
            -- Studio dışında çalışıyorsa player'in datasını kullan
            print("LOCAL_SAVE_SLOT_" .. slot .. ":" .. jsonData)
        end
        
        return true
    end)
    
    if success then
        print("✅ Konum " .. slot .. " LocalStorage'a kaydedildi")
        return true
    else
        print("❌ LocalStorage kaydı başarısız: " .. tostring(errorMessage))
        return false
    end
end

local function LoadPositionFromStorage(slot)
    local success, result = pcall(function()
        -- LocalStorage'dan yükle
        local savedData = nil
        
        if plugin then
            savedData = plugin:GetSetting("GardenSavedPosition_" .. slot)
        else
            -- Studio dışı için alternatif
            print("🔍 LocalStorage'tan konum " .. slot .. " yükleniyor...")
            return nil
        end
        
        if savedData then
            local positionData = game:GetService("HttpService"):JSONDecode(savedData)
            return Vector3.new(positionData.X, positionData.Y, positionData.Z)
        end
        
        return nil
    end)
    
    if success and result then
        print("✅ LocalStorage'dan konum " .. slot .. " yüklendi: " .. tostring(result))
        return result
    else
        print("📭 LocalStorage'da kayıtlı konum " .. slot .. " bulunamadı")
        return nil
    end
end

-- Önce PlayerGui'nin hazır olmasını bekle
if not player:FindFirstChild("PlayerGui") then
    player:WaitForChild("PlayerGui")
end

-- Mevcut butonları temizle
local function ClearExistingButtons()
    local screenGui = player.PlayerGui:FindFirstChild("TeleportGui")
    if screenGui then
        screenGui:Destroy()
    end
end

-- Buton oluşturma fonksiyonu
local function CreateButton(name, position, size, text, backgroundColor)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = backgroundColor
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.ZIndex = 1
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.new(0, 0, 0)
    shadow.Thickness = 1.5
    shadow.Parent = button
    
    return button
end

-- Buton tıklama animasyonu
local function AnimateButton(button)
    local originalSize = button.Size
    local originalPosition = button.Position
    
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(button, tweenInfo, {
        Size = originalSize - UDim2.new(0, 3, 0, 3),
        Position = originalPosition + UDim2.new(0, 1.5, 0, 1.5)
    })
    tween:Play()
    
    tween.Completed:Connect(function()
        local returnTween = TweenService:Create(button, tweenInfo, {
            Size = originalSize,
            Position = originalPosition
        })
        returnTween:Play()
    end)
end

-- Teleport fonksiyonu
local function TeleportToPosition(position)
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(position)
            return true
        end
    end
    return false
end

-- GUI oluşturma (ANA FONKSİYON)
local function CreateTeleportGUI()
    -- Önce mevcut butonları temizle
    ClearExistingButtons()
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = player.PlayerGui
    
    -- Buton boyutları
    local BUTTON_SIZE = UDim2.new(0, 100, 0, 30)
    local BUTTON4_1_SIZE = UDim2.new(0, 30, 0, 30)
    local BUTTON4_2_SIZE = UDim2.new(0, 65, 0, 30)
    local BUTTON5_1_SIZE = UDim2.new(0, 30, 0, 30)
    local BUTTON5_2_SIZE = UDim2.new(0, 65, 0, 30)
    
    -- Buton pozisyonları
    local BUTTON_POSITIONS = {
        UDim2.new(0, 5, 0, 15),   -- Buton 1 (Gear)
        UDim2.new(0, 5, 0, 50),   -- Buton 2 (Event)
        UDim2.new(0, 5, 0, 85),   -- Buton 3 (ASC)
        UDim2.new(0, 5, 0, 120),  -- Buton 4-1 (Kaydetme)
        UDim2.new(0, 38, 0, 120), -- Buton 4-2 (Git)
        UDim2.new(0, 5, 0, 155),  -- Buton 5-1 (Kaydetme)
        UDim2.new(0, 38, 0, 155)  -- Buton 5-2 (Git2)
    }
    
    -- İlk 3 butonu oluştur (Gear, Event, ASC)
    for i = 1, 3 do
        local button = CreateButton(
            BUTON_AYARLARI.ButonIsimleri[i],  -- Buton ismi
            BUTTON_POSITIONS[i],              -- Pozisyon
            BUTTON_SIZE,                      -- Boyut
            BUTON_AYARLARI.ButonMetinleri[i], -- Metin (Gear, Event, ASC)
            BUTON_AYARLARI.ButonRenkleri[i]   -- Renk
        )
        button.Parent = screenGui
        
        button.MouseButton1Click:Connect(function()
            AnimateButton(button)
            if TeleportToPosition(BUTON_AYARLARI.IsinlanmaKoordinatlari[i]) then
                print(BUTON_AYARLARI.ButonMetinleri[i] .. " konumuna ışınlandı: " .. tostring(BUTON_AYARLARI.IsinlanmaKoordinatlari[i]))
            end
        end)
    end
    
    -- 4-1 Buton (Kaydetme 1)
    local saveButton1 = CreateButton(
        "SavePositionButton1",
        BUTTON_POSITIONS[4],
        BUTTON4_1_SIZE,
        "💾",
        BUTON_AYARLARI.ButonRenkleri[4]
    )
    saveButton1.Parent = screenGui
    
    saveButton1.MouseButton1Click:Connect(function()
        AnimateButton(saveButton1)
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local currentPosition = character.HumanoidRootPart.Position
            savedPosition1 = currentPosition
            
            -- LocalStorage'a kaydet (Slot 1)
            local saveSuccess = SavePositionToStorage(currentPosition, 1)
            
            if saveSuccess then
                saveButton1.Text = "✓"
                print("📍 Konum 1 kaydedildi: " .. tostring(savedPosition1))
            else
                saveButton1.Text = "❌"
                print("❌ Konum 1 kaydedilemedi!")
            end
            
            wait(1)
            saveButton1.Text = "💾"
        end
    end)
    
    -- 4-2 Buton (Kayıtlı Konum 1'e Işınlanma)
    local teleportButton1 = CreateButton(
        "TeleportToSavedButton1",
        BUTTON_POSITIONS[5],
        BUTTON4_2_SIZE,
        "Git 1",
        BUTON_AYARLARI.ButonRenkleri[5]
    )
    teleportButton1.Parent = screenGui
    
    teleportButton1.MouseButton1Click:Connect(function()
        AnimateButton(teleportButton1)
        if savedPosition1 then
            if TeleportToPosition(savedPosition1) then
                print("📍 Konum 1'e ışınlandı: " .. tostring(savedPosition1))
            else
                teleportButton1.Text = "Hata!"
                wait(1)
                teleportButton1.Text = "Git 1"
            end
        else
            teleportButton1.Text = "Kayıt Yok!"
            wait(1)
            teleportButton1.Text = "Git 1"
        end
    end)
    
    -- 5-1 Buton (Kaydetme 2)
    local saveButton2 = CreateButton(
        "SavePositionButton2",
        BUTTON_POSITIONS[6],
        BUTTON5_1_SIZE,
        "💾",
        BUTON_AYARLARI.ButonRenkleri[6]
    )
    saveButton2.Parent = screenGui
    
    saveButton2.MouseButton1Click:Connect(function()
        AnimateButton(saveButton2)
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local currentPosition = character.HumanoidRootPart.Position
            savedPosition2 = currentPosition
            
            -- LocalStorage'a kaydet (Slot 2)
            local saveSuccess = SavePositionToStorage(currentPosition, 2)
            
            if saveSuccess then
                saveButton2.Text = "✓"
                print("📍 Konum 2 kaydedildi: " .. tostring(savedPosition2))
            else
                saveButton2.Text = "❌"
                print("❌ Konum 2 kaydedilemedi!")
            end
            
            wait(1)
            saveButton2.Text = "💾"
        end
    end)
    
    -- 5-2 Buton (Kayıtlı Konum 2'ye Işınlanma)
    local teleportButton2 = CreateButton(
        "TeleportToSavedButton2",
        BUTTON_POSITIONS[7],
        BUTTON5_2_SIZE,
        "Git 2",
        BUTON_AYARLARI.ButonRenkleri[7]
    )
    teleportButton2.Parent = screenGui
    
    teleportButton2.MouseButton1Click:Connect(function()
        AnimateButton(teleportButton2)
        if savedPosition2 then
            if TeleportToPosition(savedPosition2) then
                print("📍 Konum 2'ye ışınlandı: " .. tostring(savedPosition2))
            else
                teleportButton2.Text = "Hata!"
                wait(1)
                teleportButton2.Text = "Git 2"
            end
        else
            teleportButton2.Text = "Kayıt Yok!"
            wait(1)
            teleportButton2.Text = "Git 2"
        end
    end)
    
    -- Hover efektleri
    local function SetupHoverEffects(button)
        local originalColor = button.BackgroundColor3
        
        button.MouseEnter:Connect(function()
            local tween = TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.new(
                    math.min(originalColor.R * 1.3, 1),
                    math.min(originalColor.G * 1.3, 1),
                    math.min(originalColor.B * 1.3, 1)
                )
            })
            tween:Play()
        end)
        
        button.MouseLeave:Connect(function()
            local tween = TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = originalColor
            })
            tween:Play()
        end)
    end
    
    -- Tüm butonlara hover efekti
    for _, obj in pairs(screenGui:GetChildren()) do
        if obj:IsA("TextButton") then
            SetupHoverEffects(obj)
        end
    end
    
    print("✅ Teleport GUI başarıyla oluşturuldu!")
    print("📋 Butonlar: " .. table.concat(BUTON_AYARLARI.ButonMetinleri, ", "))
end

-- KARAKTER DEĞİŞİKLİĞİ İZLEME
player.CharacterAdded:Connect(function(character)
    character:WaitForChild("HumanoidRootPart")
    wait(0.5)
    CreateTeleportGUI()
end)

-- İLK YÜKLEME
-- Önce LocalStorage'dan konumları yükle
savedPosition1 = LoadPositionFromStorage(1)
savedPosition2 = LoadPositionFromStorage(2)

-- Sonra GUI'yi oluştur
if player.Character and player:FindFirstChild("PlayerGui") then
    CreateTeleportGUI()
else
    if player.Character then
        player.Character:WaitForChild("HumanoidRootPart")
    else
        player.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
    end
    wait(0.5)
    CreateTeleportGUI()
end

print("🎮 Grow a Garden Teleport Sistemi AKTİF!")
print("💾 2 farklı konum kaydı desteği")
print("⚙️ Butonlar: Gear, Event, ASC, Konum 1, Konum 2")



--Toggles the infinite jump between on or off on every script run
_G.infinjump = not _G.infinjump

if _G.infinJumpStarted == nil then
	--Ensures this only runs once to save resources
	_G.infinJumpStarted = true

	--The actual infinite jump
	local plr = game:GetService('Players').LocalPlayer
	
	function doJump()
		if _G.infinjump then
			humanoid = game:GetService'Players'.LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
			humanoid:ChangeState('Jumping')
			wait()
			humanoid:ChangeState('Seated')
		end
	end
	
	--PC Support
	local m = plr:GetMouse()
	m.KeyDown:connect(function(k)
		if k:byte() == 32 then
			doJump()
		end
	end)
	
	--Mobile support
	local uis = game:GetService("UserInputService")
	task.spawn(function()
		local pg = plr:WaitForChild("PlayerGui")
		local btn = pg:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton", 3)
		if btn then
			btn.MouseButton1Down:Connect(doJump)
		else
			uis.JumpRequest:Connect(doJump)
		end
	end)
end











	--Notifies readiness
	game.StarterGui:SetCore("SendNotification", {Title="Cymeria"; Text="Yükleme Tamamlandı!"; Duration=5;})

