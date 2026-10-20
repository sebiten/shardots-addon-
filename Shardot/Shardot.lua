local addonName, namespace = ...
local events = CreateFrame("Frame")
local db, frame, bar, number, label, background, shardIcon
local class, isWarlock, supported
local preview = false
local previewValue = 3
local dots = {}
local comboColors = {
    {1, 0.76, 0.24}, {1, 0.60, 0.12}, {1, 0.39, 0.07},
    {1, 0.20, 0.06}, {0.95, 0.06, 0.04},
}
local OpenOptions
local lastValue, lastMaximum
local SHARD_ID = 6265
local getItemCount = C_Item and C_Item.GetItemCount or GetItemCount
local isSecret = issecretvalue or function() return false end
local spanish = GetLocale() == "esES" or GetLocale() == "esMX"
local numberFonts = {
    {spanish and "Predeterminada" or "Default", STANDARD_TEXT_FONT},
    {"Arial", "Fonts\\ARIALN.TTF"},
    {"Morpheus", "Fonts\\MORPHEUS.TTF"},
    {"Skurri", "Fonts\\SKURRI.TTF"},
}
local defaults = {
    x = 0, y = -150, scale = 1, alpha = 1, locked = true,
    bar = true, label = false, background = false, hidezero = false,
    shardGoal = 20, dotSize = 22, dotGap = 2, comboNumber = false, shardIcon = false,
    metal = true, comboGradient = true,
    shardTextColor = "FFFFFF", shardFont = 1,
    comboShape = "squares", dotWidth = 22, borderSize = 1,
    emptyColor = "252B2B", borderColor = "111617", shine = false,
}

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffb898ffShardot:|r " .. message)
end

local function LoadSettings()
    if type(ShardotDB) ~= "table" then ShardotDB = {} end
    db = ShardotDB
    if db.comboShape == nil then db.dotGap = 2 end
    -- Apply the requested clean presentation once when upgrading older profiles.
    if db.visualVersion ~= 1 then
        db.background, db.label = false, false
        db.visualVersion = 1
    end
    for key, value in pairs(defaults) do
        if type(db[key]) ~= type(value) then db[key] = value end
    end
    db.scale = math.max(0.5, math.min(3, db.scale))
    db.alpha = math.max(0.1, math.min(1, db.alpha))
    db.shardGoal = math.max(1, math.min(200, math.floor(db.shardGoal)))
    db.dotSize = math.max(10, math.min(40, db.dotSize))
    db.dotGap = math.max(0, math.min(20, db.dotGap))
    db.dotWidth = math.max(10, math.min(60, db.dotWidth))
    db.borderSize = math.max(0, math.min(3, db.borderSize))
    if db.comboShape ~= "squares" and db.comboShape ~= "circles" then db.comboShape = "squares" end
    for _, key in ipairs({"emptyColor", "borderColor"}) do
        if not db[key]:match("^%x%x%x%x%x%x$") then db[key] = defaults[key] end
    end
    if not numberFonts[db.shardFont] then db.shardFont = 1 end
    if not db.shardTextColor:match("^%x%x%x%x%x%x$") then db.shardTextColor = defaults.shardTextColor end
    if type(db.color) ~= "table" then db.color = nil end
    if db.color then
        for i = 1, 3 do
            if type(db.color[i]) ~= "number" or db.color[i] < 0 or db.color[i] > 1 then
                db.color = nil
                break
            end
        end
    end
end

local function ApplyStyle()
    lastValue, lastMaximum = nil, nil
    local segmentWidth = db.comboShape == "circles" and db.dotSize or db.dotWidth
    local width = isWarlock and 156 or math.max(db.label and 156 or 0, 5 * segmentWidth + 4 * db.dotGap + 16)
    local height = isWarlock and 70 or math.max(70,
        db.dotSize + (db.label and 30 or 16) + (db.comboNumber and 34 or 0))
    local iconMode = isWarlock and db.shardIcon
    if iconMode then
        width = db.label and 156 or 64
        height = 64 + (db.label and 20 or 0) + (db.bar and 14 or 0)
    end
    frame:SetSize(width, height)
    frame:SetScale(db.scale)
    frame:SetAlpha(db.alpha)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", db.x, db.y)
    frame:EnableMouse(not db.locked)
    background:SetShown(db.background)
    label:SetShown(db.label)
    bar:SetShown(isWarlock and db.bar)
    number:SetShown(isWarlock or db.comboNumber)
    local r, g, b = 1, 0.72, 0.2
    if isWarlock then r, g, b = 0.68, 0.42, 1 end
    if db.color then r, g, b = unpack(db.color) end
    bar:SetStatusBarColor(r, g, b)
    number:SetTextColor(r, g, b)
    number:SetFont(STANDARD_TEXT_FONT, iconMode and 18 or 30, "OUTLINE")
    if isWarlock then
        local hex = db.shardTextColor
        number:SetTextColor(tonumber(hex:sub(1, 2), 16) / 255,
            tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255)
        -- Keep the default font if an optional built-in font is unavailable.
        number:SetFont(numberFonts[db.shardFont][2], iconMode and 18 or 30, "OUTLINE")
    end
    number:ClearAllPoints()
    number:SetPoint("CENTER", frame, "CENTER", 0, db.label and 2 or 6)
    if shardIcon then
        shardIcon:SetShown(iconMode)
        if iconMode then
            shardIcon:ClearAllPoints()
            shardIcon:SetPoint("CENTER", frame, "CENTER", 0, (db.bar and 7 or 0) - (db.label and 10 or 0))
            number:ClearAllPoints()
            number:SetPoint("BOTTOMRIGHT", shardIcon, "BOTTOMRIGHT", -2, 2)
        end
    end
    if not isWarlock then
        number:ClearAllPoints()
        number:SetPoint("BOTTOM", 0, 0)
    end
    for i = 1, #dots do
        local dot = dots[i]
        local border = db.metal and db.borderSize or 0
        dot:SetSize(segmentWidth - border * 2, db.dotSize - border * 2)
        dot:ClearAllPoints()
        dot:SetPoint("CENTER", frame, "CENTER", (i - 3) * (segmentWidth + db.dotGap),
            db.comboNumber and 7 or (db.label and -5 or 0))
        dot:SetStatusBarColor(r, g, b)
        dot.rim:SetShown(border > 0)
        dot.rim:ClearAllPoints()
        dot.rim:SetPoint("TOPLEFT", dot, "TOPLEFT", -border, border)
        dot.rim:SetPoint("BOTTOMRIGHT", dot, "BOTTOMRIGHT", border, -border)
        dot.sheen:SetShown(db.shine)
        local function Tint(texture, hex)
            texture:SetColorTexture(tonumber(hex:sub(1, 2), 16) / 255,
                tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255, 1)
        end
        Tint(dot.empty, db.emptyColor)
        Tint(dot.rim, db.borderColor)
        local round = db.comboShape == "circles"
        if dot.round ~= round then
            for _, pair in ipairs(dot.masks) do
                if round then pair[1]:AddMaskTexture(pair[2]) else pair[1]:RemoveMaskTexture(pair[2]) end
            end
            dot.round = round
        end
    end
end

local function Update()
    if not frame then return end
    if not supported and not preview and db.locked then frame:Hide(); return end

    -- Druids only need combo points in cat form. A restricted value is not inspected.
    if class == "DRUID" and not preview and db.locked then
        local powerType = UnitPowerType("player")
        if not isSecret(powerType) and powerType ~= 3 then frame:Hide(); return end
    end

    local value, maximum
    if preview or not supported then
        value, maximum = isWarlock and 12 or previewValue, isWarlock and db.shardGoal or 5
    elseif isWarlock then
        -- Count carried items only: neither bank nor reagent/account bank.
        value = getItemCount(SHARD_ID, false, false, false, false)
        maximum = db.shardGoal
    else
        value = GetComboPoints("player", "target")
        maximum = 5
    end

    if db.hidezero and db.locked and not preview and not isSecret(value) and value == 0 then
        frame:Hide()
        return
    end
    local secret = isSecret(value) or isSecret(maximum)
    if not secret and lastValue == value and lastMaximum == maximum and frame:IsShown() then return end
    if secret then lastValue, lastMaximum = nil, nil else lastValue, lastMaximum = value, maximum end
    frame:Show()
    -- Forward restricted values to native display sinks; never compare, cache or format in Lua.
    if isWarlock or db.comboNumber then number:SetFormattedText("%d", value) end
    if isWarlock and db.bar then
        bar:SetMinMaxValues(0, maximum)
        bar:SetValue(value)
    end
    for i = 1, #dots do
        -- Each native bar clamps the same value into its own one-point interval.
        -- This also works without Lua arithmetic or comparisons on secret values.
        local dot = dots[i]
        if db.comboGradient then
            local colorIndex = i
            if not secret then colorIndex = math.max(1, math.min(5, math.floor(value))) end
            local color = comboColors[colorIndex]
            dot:SetStatusBarColor(color[1], color[2], color[3])
            if db.comboNumber and (not secret or i == 1) then
                number:SetTextColor(color[1], color[2], color[3])
            end
        end
        dot:SetValue(value)
    end
end

local function CreateDisplay()
    frame = CreateFrame("Frame", "ShardotFrame", UIParent)
    frame:SetSize(156, 70)
    frame:SetFrameStrata("MEDIUM")
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        if not db.locked then self:StartMoving() end
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local x, y = self:GetCenter()
        local parentScale = UIParent:GetEffectiveScale() / self:GetEffectiveScale()
        db.x = x - UIParent:GetWidth() * parentScale / 2
        db.y = y - UIParent:GetHeight() * parentScale / 2
        ApplyStyle()
    end)
    background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.04, 0.04, 0.06, 0.8)
    if isWarlock then
        shardIcon = frame:CreateTexture(nil, "ARTWORK")
        shardIcon:SetSize(48, 48)
        local getIcon = C_Item and C_Item.GetItemIconByID or GetItemIcon
        shardIcon:SetTexture((getIcon and getIcon(SHARD_ID)) or "Interface\\Icons\\INV_Misc_Gem_Amethyst_02")
    end
    number = frame:CreateFontString(nil, "OVERLAY")
    number:SetFont(STANDARD_TEXT_FONT, 30, "OUTLINE")
    label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOP", 0, -6)
    label:SetTextColor(0.85, 0.85, 0.9)
    label:SetText(isWarlock and (spanish and "Fragmentos de alma" or "Soul Shards")
        or (spanish and "Puntos de combo" or "Combo Points"))
    bar = CreateFrame("StatusBar", nil, frame)
    bar:SetPoint("BOTTOMLEFT", 8, 8)
    bar:SetPoint("BOTTOMRIGHT", -8, 8)
    bar:SetHeight(5)
    bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
    local track = bar:CreateTexture(nil, "BACKGROUND")
    track:SetAllPoints()
    track:SetColorTexture(1, 1, 1, 0.12)
    if not isWarlock then
        for i = 1, 5 do
            local dot = CreateFrame("StatusBar", nil, frame)
            dot:SetMinMaxValues(i - 1, i)
            dot:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
            local empty = dot:CreateTexture(nil, "BACKGROUND")
            empty:SetAllPoints()
            empty:SetColorTexture(0.3, 0.3, 0.34, 0.85)
            local mask = dot:CreateMaskTexture()
            mask:SetAllPoints(dot)
            mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            dot.masks = {{empty, mask}, {dot:GetStatusBarTexture(), mask}}
            dot.empty = empty
            empty:SetDrawLayer("BACKGROUND", 3)
            local function Circle(padding, offsetY, layer, r, g, b, a)
                local texture = dot:CreateTexture(nil, "BACKGROUND", nil, layer)
                texture:SetPoint("TOPLEFT", dot, "TOPLEFT", -padding, padding + offsetY)
                texture:SetPoint("BOTTOMRIGHT", dot, "BOTTOMRIGHT", padding, -padding + offsetY)
                texture:SetColorTexture(r, g, b, a)
                local circleMask = dot:CreateMaskTexture()
                circleMask:SetAllPoints(texture)
                circleMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                dot.masks[#dot.masks + 1] = {texture, circleMask}
                return texture
            end
            dot.rim = Circle(2, 0, 1, 0.34, 0.25, 0.13, 1)
            dot.sheen = dot:CreateTexture(nil, "OVERLAY")
            dot.sheen:SetPoint("TOPLEFT", dot, "TOPLEFT", 0, 0)
            dot.sheen:SetPoint("BOTTOMRIGHT", dot, "RIGHT", 0, 0)
            dot.sheen:SetColorTexture(1, 0.92, 0.75, 0.12)
            dot.masks[#dot.masks + 1] = {dot.sheen, mask}
            dot.round = false
            dots[i] = dot
        end
    end
    ApplyStyle()
end

local function Command(input)
    local command, args = input:match("^%s*(%S*)%s*(.-)%s*$")
    command = command:lower()
    if command == "" or command == "config" or command == "options" then OpenOptions(); return
    elseif command == "unlock" then db.locked = false
    elseif command == "lock" then
        frame:StopMovingOrSizing()
        db.locked = true
        preview = false
    elseif command == "test" then preview = not preview
    elseif command == "reset" then
        ShardotDB = nil
        LoadSettings()
        preview = false
    elseif command == "scale" or command == "alpha" or command == "goal" then
        local value = tonumber(args)
        local low, high = 0.5, 3
        if command == "alpha" then low, high = 0.1, 1 end
        if command == "goal" then low, high = 1, 200 end
        if not value or value ~= value or value < low or value > high then
            Print(command .. ": " .. low .. " - " .. high)
            return
        end
        if command == "goal" then db.shardGoal = math.floor(value) else db[command] = value end
    elseif command == "icon" or command == "bar" or command == "label" or command == "background" or command == "hidezero" then
        args = args:lower()
        if args ~= "on" and args ~= "off" then Print(command .. " on | off"); return end
        db[command == "icon" and "shardIcon" or command] = args == "on"
    elseif command == "color" then
        if args:lower() == "default" then
            db.color = nil
            if not isWarlock then db.comboGradient = true end
        else
            local hex = args:match("^#?(%x%x%x%x%x%x)$")
            if not hex then Print("color RRGGBB | default"); return end
            db.color = {
                tonumber(hex:sub(1, 2), 16) / 255,
                tonumber(hex:sub(3, 4), 16) / 255,
                tonumber(hex:sub(5, 6), 16) / 255,
            }
            if not isWarlock then db.comboGradient = false end
        end
    else
        Print("/shardot unlock | lock | test | reset")
        Print("/shardot scale 0.5-3 | alpha 0.1-1 | color RRGGBB | color default")
        Print("/shardot bar on/off | label on/off | background on/off | hidezero on/off")
        Print("/shardot icon on/off")
        Print(spanish and "/shardot goal 20: objetivo visual de shards (no limita el contador)."
            or "/shardot goal 20: visual shard goal (does not cap the counter).")
        return
    end
    ApplyStyle()
    Update()
end

-- Keep configuration UI separate and allocate it only when requested.
OpenOptions = function()
    namespace.OpenOptions({
        db = function() return db end,
        warlock = isWarlock,
        apply = function() ApplyStyle(); Update() end,
        stopMoving = function() frame:StopMovingOrSizing() end,
        preview = function(value)
            if value ~= nil then preview = value end
            return preview
        end,
        sample = function(value)
            if value ~= nil then previewValue = value end
            return previewValue
        end,
        reset = function() Command("reset") end,
    })
end
events:SetScript("OnEvent", function(self, event, unit, power)
    if event == "ADDON_LOADED" then
        if unit ~= addonName then return end
        self:UnregisterEvent("ADDON_LOADED")
        LoadSettings()
        self:RegisterEvent("PLAYER_LOGIN")
    elseif event == "PLAYER_LOGIN" then
        self:UnregisterEvent("PLAYER_LOGIN")
        local localizedClass
        localizedClass, class = UnitClass("player")
        isWarlock = class == "WARLOCK"
        supported = isWarlock or class == "ROGUE" or class == "DRUID"
        CreateDisplay()
        SLASH_SHARDOT1 = "/shardot"
        SLASH_SHARDOT2 = "/sd"
        SlashCmdList.SHARDOT = Command
        if supported then
            self:RegisterEvent("PLAYER_ENTERING_WORLD")
            if isWarlock then
                self:RegisterEvent("BAG_UPDATE_DELAYED")
            else
                self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
                self:RegisterEvent("PLAYER_TARGET_CHANGED")
                self:RegisterEvent("PLAYER_REGEN_ENABLED")
                if class == "DRUID" then
                    self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
                    self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
                end
            end
        end
        Update()
    elseif event == "UNIT_POWER_UPDATE" then
        if power == "COMBO_POINTS" then Update() end
    else
        Update()
    end
end)
events:RegisterEvent("ADDON_LOADED")
