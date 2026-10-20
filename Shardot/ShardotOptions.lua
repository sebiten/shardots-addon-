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
    panel:SetSize(640, 690)
    panel:SetPoint("CENTER", 180, 30)
    panel:SetScale(math.min(1, (UIParent:GetHeight() - 40) / 690))
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
    Button(panel, "×", 588, -18, 28, function() panel:Hide() end)
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
    for i, name in ipairs({L("General", "General"), L("Diseño", "Design"), L("Colores", "Colors")}) do
        local index = i
        local page = CreateFrame("Frame", nil, panel)
        page:SetPoint("TOPLEFT", 24, -140)
        page:SetSize(592, 480)
        pages[index] = page
        tabs[index] = Button(panel, name, 24 + (i - 1) * 200, -88, 192, function()
            selected = index
            panel:Refresh()
        end)
    end
    local general, design, colors = pages[1], pages[2], pages[3]
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
    local support = CreateFrame("Frame", nil, general)
    support:SetPoint("TOPLEFT", 0, -320)
    support:SetSize(592, 160)
    Rect(support, 0.08, 0.12, 0.18)
    local supportAccent = support:CreateTexture(nil, "ARTWORK")
    supportAccent:SetPoint("TOPLEFT")
    supportAccent:SetPoint("BOTTOMLEFT")
    supportAccent:SetWidth(3)
    supportAccent:SetColorTexture(0.24, 0.71, 0.91, 1)
    local supportTitle = Text(support, L("Apoyar el desarrollo", "Support development"), 16, -12, 16)
    supportTitle:SetTextColor(0.45, 0.82, 1)
    local supportCopy = Text(support, L(
        "¿Te gusta Shardot? Podés apoyar su desarrollo con una donación voluntaria.",
        "Enjoying Shardot? Support its development with a voluntary donation."), 16, -39, 12)
    supportCopy:SetWidth(560)
    supportCopy:SetJustifyH("LEFT")
    supportCopy:SetSpacing(4)
    local supportLink = CreateFrame("EditBox", nil, support)
    supportLink:SetPoint("TOPLEFT", 16, -71)
    supportLink:SetSize(360, 32)
    supportLink:SetFont(STANDARD_TEXT_FONT, 12, "")
    supportLink:SetTextInsets(12, 12, 0, 0)
    supportLink:SetAutoFocus(false)
    supportLink:SetText(SUPPORT_URL)
    Rect(supportLink, 0.10, 0.12, 0.14)
    inputs[#inputs + 1] = supportLink
    supportLink:SetScript("OnTextChanged", function(self)
        if self:GetText() ~= SUPPORT_URL then self:SetText(SUPPORT_URL) end
    end)
    supportLink:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    supportLink:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    supportLink:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    local donateButton = Button(support, L("Seleccionar PayPal", "Select PayPal link"), 392, -72, 184, function()
        supportLink:SetFocus()
        supportLink:HighlightText()
    end)
    donateButton.text:SetTextColor(0.45, 0.82, 1)
    Text(support, L("Copiá con Ctrl+C (Cmd+C en Mac) y abrilo en tu navegador.",
        "Copy with Ctrl+C (Cmd+C on Mac), then open it in your browser."), 16, -115, 11, true)
    Text(support, L("Donar es opcional. Todas las funciones siguen disponibles.",
        "Donations are optional. All features remain available."), 16, -136, 11, true)
    local resetArmed = false
    local reset
    reset = Button(panel, L("Restablecer todo", "Reset all"), 24, -636, 190, function()
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
    Button(panel, L("Listo", "Done"), 446, -636, 170, function() panel:Hide() end)
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
