local _, namespace = ...
local panel
local SUPPORT_URL = "https://www.paypal.com/paypalme/sebiten"
local spanish = GetLocale() == "esES" or GetLocale() == "esMX"
local function L(es, en) return spanish and es or en end
local function RGB(hex)
    return tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255,
        tonumber(hex:sub(5, 6), 16) / 255
end

-- Created on demand. No timers, animation loops, or additional combat events.
function namespace.OpenOptions(api)
    if panel then panel:Show(); panel:Refresh(); return end
    panel = CreateFrame("Frame", "ShardotOptions", UIParent)
    panel:SetSize(640, 590)
    panel:SetPoint("CENTER", 180, 30)
    panel:SetScale(math.min(1, (UIParent:GetHeight() - 40) / 590))
    panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    panel:EnableMouse(true)
    panel:SetMovable(true)
    table.insert(UISpecialFrames, "ShardotOptions")
    local controls, inputs, pages, tabs = {}, {}, {}, {}
    local syncing, selected = false, 1
    local function Rect(parent, r, g, b, a)
        local texture = parent:CreateTexture(nil, "BACKGROUND")
        texture:SetAllPoints()
        texture:SetColorTexture(r, g, b, a or 1)
        return texture
    end
    Rect(panel, 0.045, 0.055, 0.085, 0.98)
    local accent = panel:CreateTexture(nil, "OVERLAY")
    accent:SetColorTexture(0.62, 0.43, 1, 1)
    accent:SetPoint("TOPLEFT")
    accent:SetPoint("TOPRIGHT")
    accent:SetHeight(2)
    local function Text(parent, text, x, y, size, muted)
        local font = parent:CreateFontString(nil, "OVERLAY")
        font:SetFont(STANDARD_TEXT_FONT, size or 12, "")
        font:SetPoint("TOPLEFT", x, y)
        font:SetTextColor(muted and 0.58 or 0.91, muted and 0.64 or 0.93, muted and 0.69 or 0.95)
        font:SetText(text)
        return font
    end
    local function Button(parent, caption, x, y, width, callback)
        local button = CreateFrame("Button", nil, parent)
        button:SetPoint("TOPLEFT", x, y)
        button:SetSize(width, 30)
        button.bg = Rect(button, 0.13, 0.16, 0.18)
        button.text = Text(button, caption, 0, 0, 12)
        button.text:ClearAllPoints()
        button.text:SetPoint("CENTER")
        button:SetScript("OnEnter", function(self) self.bg:SetColorTexture(0.24, 0.20, 0.36, 1) end)
        button:SetScript("OnLeave", function(self)
            if self.selected then self.bg:SetColorTexture(0.20, 0.14, 0.32, 1)
            else self.bg:SetColorTexture(0.13, 0.16, 0.18, 1) end
        end)
        button:SetScript("OnClick", callback)
        return button
    end
    local header = CreateFrame("Frame", nil, panel)
    header:SetPoint("TOPLEFT", 0, -2)
    header:SetPoint("TOPRIGHT", 0, -2)
    header:SetHeight(70)
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() panel:StartMoving() end)
    header:SetScript("OnDragStop", function() panel:StopMovingOrSizing() end)
    local brand = Text(header, "Shardot", 24, -18, 20)
    brand:SetTextColor(0.77, 0.65, 1)
    Text(header, L("Cambios en vivo · Guardado por personaje", "Live changes · Saved per character"), 24, -44, 11, true)
    local closeButton = CreateFrame("Button", nil, panel)
    closeButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -18, -18)
    closeButton:SetSize(30, 30)
    closeButton:SetFrameLevel(header:GetFrameLevel() + 10)
    closeButton:EnableMouse(true)
    closeButton:RegisterForClicks("LeftButtonUp")
    closeButton.bg = Rect(closeButton, 0.13, 0.16, 0.18, 1)
    closeButton.text = Text(closeButton, "×", 0, 0, 16)
    closeButton.text:ClearAllPoints()
    closeButton.text:SetPoint("CENTER", 0, 1)
    closeButton:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(0.42, 0.16, 0.20, 1)
        self.text:SetTextColor(1, 0.86, 0.88)
    end)
    closeButton:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(0.13, 0.16, 0.18, 1)
        self.text:SetTextColor(0.91, 0.93, 0.95)
    end)
    closeButton:SetScript("OnClick", function()
        panel:Hide()
    end)
    local function Commit()
        api.apply()
        panel:Refresh()
    end
    local function Check(parent, key, caption, x, y)
        local button = CreateFrame("CheckButton", nil, parent)
        button:SetPoint("TOPLEFT", x, y)
        button:SetSize(270, 30)
        local row = Rect(button, 0.10, 0.12, 0.14)
        local border = button:CreateTexture(nil, "ARTWORK")
        border:SetSize(20, 20)
        border:SetPoint("LEFT", 8, 0)
        border:SetColorTexture(0.42, 0.48, 0.53, 1)
        local inside = button:CreateTexture(nil, "ARTWORK", nil, 1)
        inside:SetSize(16, 16)
        inside:SetPoint("CENTER", border, "CENTER")
        inside:SetColorTexture(0.055, 0.065, 0.075, 1)
        local checked = button:CreateTexture(nil, "OVERLAY")
        checked:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
        checked:SetSize(22, 22)
        checked:SetPoint("CENTER", border, "CENTER")
        button:SetCheckedTexture(checked)
        local captionText = Text(button, caption, 38, -8, 12)
        captionText:SetWidth(224)
        captionText:SetJustifyH("LEFT")
        button:SetScript("OnEnter", function() row:SetColorTexture(0.17, 0.20, 0.23, 1) end)
        button:SetScript("OnLeave", function() row:SetColorTexture(0.10, 0.12, 0.14, 1) end)
        button:SetScript("OnClick", function(self)
            local enabled = self:GetChecked() and true or false
            if key == "preview" then api.preview(enabled)
            else
                local db = api.db()
                db[key] = enabled
                if key == "locked" then api.stopMoving() end
            end
            Commit()
        end)
        controls[#controls + 1] = function()
            local value
            if key == "preview" then value = api.preview() else value = api.db()[key] end
            button:SetChecked(value)
            if value then border:SetColorTexture(1, 0.70, 0.28, 1)
            else border:SetColorTexture(0.42, 0.48, 0.53, 1) end
        end
    end
    local function Slider(parent, key, caption, low, high, step, x, y)
        local title = Text(parent, caption, x, y)
        local slider = CreateFrame("Slider", nil, parent)
        slider:SetPoint("TOPLEFT", x, y - 25)
        slider:SetSize(270, 18)
        slider:SetOrientation("HORIZONTAL")
        slider:SetMinMaxValues(low, high)
        slider:SetValueStep(step)
        slider:SetObeyStepOnDrag(true)
        local track = slider:CreateTexture(nil, "BACKGROUND")
        track:SetPoint("LEFT")
        track:SetPoint("RIGHT")
        track:SetHeight(3)
        track:SetColorTexture(0.25, 0.29, 0.32, 1)
        local thumb = slider:CreateTexture(nil, "OVERLAY")
        thumb:SetSize(10, 18)
        thumb:SetColorTexture(1, 0.70, 0.28, 1)
        slider:SetThumbTexture(thumb)
        slider:SetScript("OnValueChanged", function(_, value)
            if syncing then return end
            value = math.floor(value / step + 0.5) * step
            if key == "previewValue" then api.preview(true); api.sample(value)
            else api.db()[key] = value end
            Commit()
        end)
        controls[#controls + 1] = function()
            local value = key == "previewValue" and api.sample() or api.db()[key]
            slider:SetValue(value)
            title:SetFormattedText(step < 1 and "%s   %.2f" or "%s   %d", caption, value)
        end
    end
    local function Choice(parent, key, caption, choices, x, y)
        Text(parent, caption, x, y)
        local button = Button(parent, "", x, y - 24, 270, function()
            local db, index = api.db(), 1
            for i, choice in ipairs(choices) do if choice[1] == db[key] then index = i; break end end
            db[key] = choices[index % #choices + 1][1]
            Commit()
        end)
        controls[#controls + 1] = function()
            for _, choice in ipairs(choices) do
                if choice[1] == api.db()[key] then button.text:SetText(choice[2] .. "  ›"); break end
            end
        end
    end
    local function Color(parent, key, caption, x, y)
        Text(parent, caption, x, y)
        local swatch = CreateFrame("Frame", nil, parent)
        swatch:SetSize(26, 26)
        swatch:SetPoint("TOPLEFT", x, y - 25)
        local fill = Rect(swatch, 1, 1, 1)
        local input = CreateFrame("EditBox", nil, parent)
        input:SetPoint("TOPLEFT", x + 38, y - 24)
        input:SetSize(125, 30)
        input:SetFont(STANDARD_TEXT_FONT, 13, "")
        input:SetTextInsets(10, 4, 0, 0)
        input:SetAutoFocus(false)
        input:SetMaxLetters(6)
        Rect(input, 0.10, 0.12, 0.14)
        inputs[#inputs + 1] = input
        input:SetScript("OnEscapePressed", function(self) self:ClearFocus(); panel:Refresh() end)
        local function Apply()
            local hex = input:GetText():upper()
            if not hex:match("^%x%x%x%x%x%x$") then
                input:SetTextColor(1, 0.3, 0.2)
                return
            end
            local db = api.db()
            if key == "color" then
                db.color = {RGB(hex)}
                if not api.warlock then db.comboGradient = false end
            else db[key] = hex end
            input:ClearFocus()
            Commit()
        end
        input:SetScript("OnEnterPressed", Apply)
        Button(parent, L("Aplicar", "Apply"), x + 178, y - 24, 92, Apply)
        controls[#controls + 1] = function()
            local hex = api.db()[key]
            if key == "color" then
                local c = hex or (api.warlock and {0.68, 0.42, 1} or {1, 0.72, 0.2})
                hex = string.format("%02X%02X%02X", math.floor(c[1] * 255 + 0.5),
                    math.floor(c[2] * 255 + 0.5), math.floor(c[3] * 255 + 0.5))
            end
            if not input:HasFocus() then input:SetText(hex); input:SetTextColor(0.9, 0.93, 0.95) end
            local r, g, b = RGB(hex)
            fill:SetColorTexture(r, g, b, 1)
        end
    end
    local tabNames = {L("General", "General"), L("Diseño", "Design"), L("Colores", "Colors")}
    if not api.warlock then tabNames[#tabNames + 1] = L("Nameplate", "Nameplate") end
    local tabGap = 8
    local tabWidth = (592 - (#tabNames - 1) * tabGap) / #tabNames
    for i, name in ipairs(tabNames) do
        local index = i
        local page = CreateFrame("Frame", nil, panel)
        page:SetPoint("TOPLEFT", 24, -140)
        page:SetSize(592, 380)
        pages[index] = page
        tabs[index] = Button(panel, name, 24 + (i - 1) * (tabWidth + tabGap), -88, tabWidth, function()
            selected = index
            panel:Refresh()
        end)
    end
    local general, design, colors, nameplate = pages[1], pages[2], pages[3], pages[4]
    Text(general, L("Visibilidad y posición", "Visibility and position"), 0, 0, 16)
    Check(general, "locked", L("Bloquear posición", "Lock position"), 0, -38)
    Check(general, "hidezero", L("Ocultar en cero", "Hide at zero"), 310, -38)
    Check(general, "background", L("Mostrar fondo", "Show background"), 0, -80)
    Check(general, "label", L("Mostrar etiqueta", "Show label"), 310, -80)
    Slider(general, "scale", L("Escala", "Scale"), 0.5, 3, 0.05, 0, -143)
    Slider(general, "alpha", L("Opacidad", "Opacity"), 0.1, 1, 0.05, 310, -143)
    Check(general, "preview", L("Vista previa", "Preview"), 0, -218)
    if not api.warlock then Slider(general, "previewValue", L("Combos de prueba", "Preview points"), 0, 5, 1, 310, -218) end
    Text(general, L("Desbloqueá para mover el indicador. Al cerrar, termina la vista previa.",
        "Unlock to move the indicator. Closing the panel ends the preview."), 0, -287, 12, true)
    Text(design, L("Forma y dimensiones", "Shape and dimensions"), 0, 0, 16)
    if api.warlock then
        Check(design, "shardIcon", L("Icono con contador", "Icon with count"), 0, -38)
        Check(design, "bar", L("Barra de shards", "Shard bar"), 310, -38)
        Slider(design, "shardGoal", L("Objetivo de shards", "Shard goal"), 1, 200, 1, 0, -100)
        Choice(design, "shardFont", L("Fuente del contador", "Counter font"), {
            {1, L("Predeterminada", "Default")}, {2, "Arial"}, {3, "Morpheus"}, {4, "Skurri"},
        }, 310, -100)
    else
        Choice(design, "comboShape", L("Estilo (clic para cambiar)", "Style (click to switch)"), {
            {"squares", L("Segmentos cuadrados", "Square segments")}, {"circles", L("Círculos", "Circles")},
        }, 0, -38)
        Check(design, "comboNumber", L("Mostrar número", "Show number"), 310, -62)
        Slider(design, "dotWidth", L("Ancho · solo segmentos", "Width · segments only"), 10, 60, 1, 0, -120)
        Slider(design, "dotSize", L("Alto / diámetro", "Height / diameter"), 10, 40, 1, 310, -120)
        Slider(design, "dotGap", L("Separación · 0 = unidos", "Spacing · 0 = joined"), 0, 20, 1, 0, -194)
        Slider(design, "borderSize", L("Grosor del borde", "Border width"), 0, 3, 1, 310, -194)
        Check(design, "metal", L("Mostrar borde", "Show border"), 0, -270)
        Check(design, "shine", L("Reflejo sutil", "Subtle highlight"), 310, -270)
    end
    Text(colors, L("Paleta del recurso", "Resource palette"), 0, 0, 16)
    Color(colors, "color", api.warlock and L("Barra", "Bar") or L("Relleno · color fijo", "Fill · fixed color"), 0, -40)
    if api.warlock then
        Color(colors, "shardTextColor", L("Número de shards", "Shard count"), 310, -40)
    else
        Color(colors, "emptyColor", L("Segmentos vacíos", "Empty segments"), 310, -40)
        Color(colors, "borderColor", L("Borde", "Border"), 0, -132)
        Check(colors, "comboGradient", L("Dorado → rojo por combos", "Gold → red with combos"), 310, -156)
        Text(colors, L("Aplicar un color de relleno desactiva la progresión a rojo.", "Applying a fill color disables the red progression."), 0, -232, 12, true)
    end
    Text(colors, L("Usá seis dígitos hexadecimales; por ejemplo FFB733.", "Use six hex digits; for example FFB733."), 0, -278, 12, true)
    Button(colors, L("Colores originales", "Default colors"), 0, -317, 270, function()
        local db = api.db()
        db.color, db.emptyColor, db.borderColor, db.shardTextColor = nil, "252B2B", "111617", "FFFFFF"
        db.comboGradient = true
        Commit()
    end)
    if nameplate then
        Text(nameplate, L("Combo points en la nameplate", "Combo points on the nameplate"), 0, 0, 16)
        Check(nameplate, "nameplateEnabled", L("Mostrar en el objetivo", "Show on target"), 0, -38)
        Check(nameplate, "nameplateHideZero", L("Ocultar sin combo points", "Hide with no combo points"), 310, -38)
        Choice(nameplate, "nameplatePosition", L("Posición respecto a la nameplate", "Position relative to nameplate"), {
            {"TOP", L("Arriba", "Above")}, {"BOTTOM", L("Abajo", "Below")},
        }, 0, -100)
        Slider(nameplate, "nameplateScale", L("Escala", "Scale"), 0.5, 2, 0.05, 310, -100)
        Slider(nameplate, "nameplateX", L("Movimiento X", "X offset"), -200, 200, 1, 0, -185)
        Slider(nameplate, "nameplateY", L("Movimiento Y", "Y offset"), -100, 100, 1, 310, -185)
        Text(nameplate, L("Usa el mismo estilo y colores configurados en Diseño y Colores.",
            "Uses the same style and colors configured under Design and Colors."), 0, -270, 12, true)
        Text(nameplate, L("Necesitás tener las nameplates activadas y un objetivo visible para verlo.",
            "Nameplates must be enabled and the target must be visible."), 0, -296, 12, true)
    end
    local support = CreateFrame("Frame", nil, general)
    support:SetPoint("TOPLEFT", 0, -320)
    support:SetSize(592, 60)
    Rect(support, 0.09, 0.085, 0.13, 0.72)
    local supportAccent = support:CreateTexture(nil, "ARTWORK")
    supportAccent:SetPoint("TOPLEFT")
    supportAccent:SetPoint("TOPRIGHT")
    supportAccent:SetHeight(1)
    supportAccent:SetColorTexture(0.40, 0.31, 0.56, 0.8)
    local supportTitle = Text(support, L("Apoyar el desarrollo", "Support development"), 12, -12, 13)
    supportTitle:SetTextColor(0.80, 0.72, 0.94)
    local supportCopy = Text(support, L("Donación opcional. Gracias por apoyar Shardot.",
        "Optional donation. Thanks for supporting Shardot."), 12, -35, 11, true)
    supportCopy:SetTextColor(0.69, 0.72, 0.78)
    local supportLink = CreateFrame("EditBox", nil, support)
    supportLink:SetPoint("TOPLEFT", 12, -8)
    supportLink:SetSize(430, 30)
    supportLink:SetFont(STANDARD_TEXT_FONT, 12, "")
    supportLink:SetTextInsets(12, 12, 0, 0)
    supportLink:SetAutoFocus(false)
    supportLink:SetText(SUPPORT_URL)
    supportLink:Hide()
    Rect(supportLink, 0.10, 0.12, 0.14)
    inputs[#inputs + 1] = supportLink
    supportLink:SetScript("OnTextChanged", function(self)
        if self:GetText() ~= SUPPORT_URL then self:SetText(SUPPORT_URL) end
    end)
    supportLink:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    supportLink:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    supportLink:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    local copyHint = Text(support, L("Ctrl+C / Cmd+C para copiar y abrir en tu navegador.",
        "Ctrl+C / Cmd+C to copy and open in your browser."), 12, -43, 11, true)
    copyHint:Hide()
    local function CollapseSupport()
        supportLink:Hide()
        copyHint:Hide()
        supportTitle:Show()
        supportCopy:Show()
    end
    supportLink:SetScript("OnEditFocusLost", CollapseSupport)
    support:SetScript("OnHide", function() supportLink:ClearFocus(); CollapseSupport() end)
    local donateButton = Button(support, "PayPal", 460, -12, 120, function()
        supportTitle:Hide()
        supportCopy:Hide()
        supportLink:Show()
        copyHint:Show()
        supportLink:SetFocus()
        supportLink:HighlightText()
    end)
    donateButton.text:SetTextColor(0.90, 0.84, 1)
    donateButton.bg:SetColorTexture(0.24, 0.17, 0.35, 1)
    donateButton:SetScript("OnEnter", function(self) self.bg:SetColorTexture(0.33, 0.23, 0.47, 1) end)
    donateButton:SetScript("OnLeave", function(self) self.bg:SetColorTexture(0.24, 0.17, 0.35, 1) end)
    local resetArmed = false
    local reset
    reset = Button(panel, L("Restablecer todo", "Reset all"), 24, -536, 190, function()
        if not resetArmed then
            resetArmed = true
            reset.text:SetText(L("Confirmar restablecer", "Confirm reset"))
            return
        end
        api.reset()
        resetArmed = false
        reset.text:SetText(L("Restablecer todo", "Reset all"))
        panel:Refresh()
    end)
    Button(panel, L("Listo", "Done"), 446, -536, 170, function() panel:Hide() end)
    function panel:Refresh()
        syncing = true
        for _, refresh in ipairs(controls) do refresh() end
        for i, page in ipairs(pages) do
            page:SetShown(i == selected)
            tabs[i].selected = i == selected
            if i == selected then tabs[i].bg:SetColorTexture(0.20, 0.14, 0.32, 1)
            else tabs[i].bg:SetColorTexture(0.13, 0.16, 0.18, 1) end
            tabs[i].text:SetTextColor(i == selected and 1 or 0.65, i == selected and 0.73 or 0.69, i == selected and 0.35 or 0.73)
        end
        syncing = false
    end
    panel:SetScript("OnHide", function()
        for _, input in ipairs(inputs) do input:ClearFocus() end
        api.preview(false)
        api.apply()
        resetArmed = false
        reset.text:SetText(L("Restablecer todo", "Reset all"))
    end)
    panel:Refresh()
end
