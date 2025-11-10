-- Grow a Garden Teleport Script - DÜZELTİLMİŞ
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local savedPosition = nil

-- ⚙️ AYARLAR - Bu kısmı değiştirebilirsin
local BUTON_AYARLARI = {
    -- Buton metinleri
    ButonMetinleri = {"Gear", "Event", "ASC"},
    
    -- Buton isimleri (Explorer'da görünecek)
    ButonIsimleri = {"GearButton", "EventButton", "ASCButton"},
    
    -- Işınlanma koordinatları
    IsinlanmaKoordinatlari = {
        Vector3.new(-285, 1, -14),    -- Gear butonu için
        Vector3.new(-113, 5, 1),      -- Event butonu için
        Vector3.new(127, 5, 168)      -- ASC butonu için
    },
    
    -- Buton renkleri
    ButonRenkleri = {
        Color3.fromRGB(74, 124, 255),  -- Mavi (Gear)
        Color3.fromRGB(255, 87, 87),   -- Kırmızı (Event)
        Color3.fromRGB(76, 175, 80),   -- Yeşil (ASC)
        Color3.fromRGB(255, 193, 7),   -- Sarı (Kaydetme)
        Color3.fromRGB(156, 39, 176)   -- Mor (Işınlanma)
    }
}

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
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.new(0, 0, 0)
    shadow.Thickness = 2
    shadow.Parent = button
    
    return button
end

-- Buton tıklama animasyonu
local function AnimateButton(button)
    local originalSize = button.Size
    local originalPosition = button.Position
    
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(button, tweenInfo, {
        Size = originalSize - UDim2.new(0, 4, 0, 4),
        Position = originalPosition + UDim2.new(0, 2, 0, 2)
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
    local BUTTON_SIZE = UDim2.new(0, 100, 0, 35)
    local BUTTON4_1_SIZE = UDim2.new(0, 28, 0, 35)
    local BUTTON4_2_SIZE = UDim2.new(0, 70, 0, 35)
    
    -- Buton pozisyonları
    local BUTTON_POSITIONS = {
        UDim2.new(0, 5, 0, 25),   -- Buton 1 (Gear)
        UDim2.new(0, 5, 0, 65),   -- Buton 2 (Event)
        UDim2.new(0, 5, 0, 105),  -- Buton 3 (ASC)
        UDim2.new(0, 5, 0, 145)   -- Buton 4-1 (Kaydetme)
    }
    
    local BUTTON4_2_POSITION = UDim2.new(0, 35, 0, 145)
    
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
    
    -- 4-1 Buton (Kaydetme)
    local saveButton = CreateButton(
        "SavePositionButton",
        BUTTON_POSITIONS[4],
        BUTTON4_1_SIZE,
        "💾",
        BUTON_AYARLARI.ButonRenkleri[4]
    )
    saveButton.Parent = screenGui
    
    saveButton.MouseButton1Click:Connect(function()
        AnimateButton(saveButton)
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            savedPosition = character.HumanoidRootPart.Position
            print("Konum kaydedildi: " .. tostring(savedPosition))
            saveButton.Text = "✓"
            wait(1)
            saveButton.Text = "💾"
        end
    end)
    
    -- 4-2 Buton (Kayıtlı Konuma Işınlanma)
    local teleportButton = CreateButton(
        "TeleportToSavedButton",
        BUTTON4_2_POSITION,
        BUTTON4_2_SIZE,
        " Git > ",
        BUTON_AYARLARI.ButonRenkleri[5]
    )
    teleportButton.Parent = screenGui
    
    teleportButton.MouseButton1Click:Connect(function()
        AnimateButton(teleportButton)
        if savedPosition then
            if TeleportToPosition(savedPosition) then
                print("Kayıtlı konuma ışınlandı: " .. tostring(savedPosition))
            else
                teleportButton.Text = "Hata!"
                wait(1)
                teleportButton.Text = "Kayıtlı Konuma Git"
            end
        else
            teleportButton.Text = "Konum Yok!"
            wait(1)
            teleportButton.Text = "Kayıtlı Konuma Git"
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
if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
    CreateTeleportGUI()
else
    player.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
    wait(0.5)
    CreateTeleportGUI()
end

print("🎮 Grow a Garden Teleport Sistemi AKTİF!")
print("⚙️ Butonlar: Gear, Event, ASC olarak ayarlandı")
