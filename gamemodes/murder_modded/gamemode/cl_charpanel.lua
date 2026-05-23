local CSEntMeta = FindMetaTable("CSEnt")

local inputFieldWidth = 150
local c_black = Color(0, 0, 0, 255) -- because

-- I hope nothing wrong happens with this
function CSEntMeta:GetPlayerColor()
    return self.playerColor or Vector()
end

local charFile = ""
local files = {}
local characters = {}

local panel


local function createBaseFieldContainer(name)
    local container = vgui.Create("Panel")
    container:DockPadding(0, 2, 0, 2) 
    container:Dock(TOP)

    local label = container:Add("DLabel")
    label:SetText(name)
    label:SetWide(100)
    label:SetDark(true)
    label:Dock(LEFT)

    container.label = label

    return container, label
end

local function createTextField(name)
    local container = createBaseFieldContainer(name)

    local textEntry = container:Add("DTextEntry")
    textEntry:SetWide(inputFieldWidth)
    textEntry:Dock(RIGHT)

    container.textEntry = textEntry
    return container
end

local function createColorField(name)
    local container = createBaseFieldContainer(name)

    local optionsWrapper = container:Add("DSizeToContents")
    optionsWrapper:SetWide(inputFieldWidth)
    optionsWrapper:Dock(RIGHT)

    local randomCheckbox = optionsWrapper:Add("DCheckBoxLabel")
    randomCheckbox:SetText("Random")
    randomCheckbox:SetDark(true)
    randomCheckbox:SetWide(100)
    randomCheckbox:Dock(LEFT)

    local colorButton = optionsWrapper:Add("DButton")
    colorButton:Dock(RIGHT)

    colorButton.color = Color(0, 0, 0, 255)
    colorButton.OnColorWindowFocusChanged = function(focus) end
    colorButton.OnColorWindowValueChanged = function(color) end
    colorButton.PaintOver = function()
        if !colorButton:IsEnabled() then    colorButton.color.a = 127 
        else                                colorButton.color.a = 255 end
        draw.RoundedBox(0, 3, 3, colorButton:GetWide()-6, colorButton:GetTall()-6, colorButton.color)
    end

    colorButton.DoClick = function()
        local colorWindow = vgui.Create("DPanel")
        colorWindow:SetSize(250, 200)
        colorWindow:MakePopup()

        local mx, my = input.GetCursorPos()
        mx = math.Clamp(mx, 0, ScrW() - colorWindow:GetWide())
        my = math.Clamp(my, 0, ScrH() - colorWindow:GetTall())
        colorWindow:SetPos(mx, my)

        local color = colorWindow:Add("DColorMixer")
        color:Dock(FILL)
        color:SetAlphaBar(false)
        color:SetPalette(false)
        color:SetColor(colorButton.color)

        color.ValueChanged = function(colorMixer)
            colorButton.OnColorWindowValueChanged(colorMixer:GetColor())
        end

        colorWindow.OnFocusChanged = function(f)
            local focus = f:HasFocus()
            if not focus then return end

            colorWindow:Remove()
            colorButton.OnColorWindowFocusChanged(focus)
        end
    end

    container.randomCheckbox = randomCheckbox
    container.colorButton = colorButton
    return container
end

local function createOptionToggleField(name, option1, option2)
    local container = createBaseFieldContainer(name)

    local optionsWrapper = container:Add("DSizeToContents")
    optionsWrapper:SetWide(inputFieldWidth)
    optionsWrapper:Dock(RIGHT)

    local option1Button = optionsWrapper:Add("DButton")
    local option2Button = optionsWrapper:Add("DButton")

    option1Button:SetText(option1)
    option1Button:SetWide(30)
    option1Button:Dock(LEFT)
    option1Button.OnClick = function() end
    option1Button.DoClick = function()
        option1Button:SetToggle(true)
        option2Button:SetToggle(false)
        option1Button.OnClick()
    end

    option2Button:SetText(option2)
    option2Button:SetWide(30)
    option2Button:Dock(RIGHT)
    option2Button.OnClick = function() end
    option2Button.DoClick = function()
        option1Button:SetToggle(false)
        option2Button:SetToggle(true)
        option2Button.OnClick()
    end

    container.option1Button = option1Button
    container.option2Button = option2Button
    return container
end

local function createButtonField(name)
    local container = createBaseFieldContainer(name)

    local button = container:Add("DButton")
    button:SetWide(inputFieldWidth)
    button:Dock(RIGHT)

    container.button = button
    return container
end

local function createSliderField(name, value, maxValue)
    -- local container = createBaseFieldContainer(name)
    local container = vgui.Create("Panel")
    container:Dock(TOP)

    local slider = container:Add("DNumSlider")
    slider:SetText(name)
    slider:SetDark(true)
    slider:SetValue(value)
    slider:SetMin(0)
    slider:SetMax(maxValue)
    slider:Dock(FILL)

    container.slider = slider
    return container
end



local function setCurrentChar(i)    
    panel.charIndex = i

    if i == 0 then
        panel.charModel:Hide()
        panel.charProperties:GetParent():Hide()
        return
    end

    panel.charModel:Show()
    panel.charProperties:GetParent():Show()

    -- Model
    local char = characters[i]
    if !char then
        if #characters < 1 then
            setCurrentChar(0)
        else
            setCurrentChar(1)
        end
        return
    end

    panel.charModel:SetModel(player_manager.TranslatePlayerModel(char.pm.model))
    local charModelEntity = panel.charModel:GetEntity()
    
    -- Name
    panel.charProperties.name:SetValue(char.name)

    -- Name color
    if char.nameColor == "random" then
        panel.charProperties.nameColorRandom:SetChecked(true)
        panel.charProperties.nameColor:SetEnabled(false)
        panel.charProperties.nameColor.color = Color(0, 0, 0, 255)
    else
        panel.charProperties.nameColorRandom:SetChecked(false)
        panel.charProperties.nameColor:SetEnabled(true)
        panel.charProperties.nameColor.color = 
            Color(char.nameColor.x*255, char.nameColor.y*255, char.nameColor.z*255)
    end

    -- Sex
    if char.sex == "male" then
        panel.charProperties.sexMale:SetToggle(true)
        panel.charProperties.sexFemale:SetToggle(false)
    elseif char.sex == "female" then
        panel.charProperties.sexMale:SetToggle(false)
        panel.charProperties.sexFemale:SetToggle(true)
    end

    -- Playermodel
    panel.charProperties.playermodel:SetText(char.pm.model)

    -- PM color
    if char.pm.color == "random" then
        panel.charProperties.pmColorRandom:SetChecked(true)
        panel.charProperties.pmColor:SetEnabled(false)
        panel.charProperties.pmColor.color = Color(0, 0, 0, 255)

        charModelEntity.playerColor = Vector()
    else
        panel.charProperties.pmColorRandom:SetChecked(false)
        panel.charProperties.pmColor:SetEnabled(true)
        panel.charProperties.pmColor.color = 
            Color(char.pm.color.x*255, char.pm.color.y*255, char.pm.color.z*255)

        charModelEntity.playerColor = char.pm.color
    end

    -- Skin and bodygroups
    for _, v in pairs(panel.charProperties.bodygroupContainers) do
        v:Remove()
    end
    panel.charProperties.bodygroupContainers = {}

    local skinValue = char.pm.bodygroups.Skin
    if skinValue then
        local skinField = createSliderField("Skin", skinValue, charModelEntity:SkinCount() - 1)
        skinField:SetParent(panel.charProperties.bodygroups)
        panel.charProperties.bodygroupContainers.Skin = skinField
        -- panel.charProperties.bodygroups:AddItem(skinField)

        local skinSlider = skinField.slider
        skinSlider.OnValueChanged = function(self, v)
            charModelEntity:SetSkin(v)
        end
        skinSlider.MouseReleased = function(self)
            RunConsoleCommand("mwcc_char_edit", "-byindex", panel.charIndex,
                "-pm-body", "Skin", self:GetValue(), "-noprint")
        end

        charModelEntity:SetSkin(skinValue)
    end

    for i = 0, #charModelEntity:GetBodyGroups() - 1 do
        local bgName = charModelEntity:GetBodygroupName(i)
        local bgValue = char.pm.bodygroups[bgName]
        if not bgValue then continue end

        local bgField = createSliderField(bgName, bgValue, charModelEntity:GetBodygroupCount(i) - 1)
        bgField:SetParent(panel.charProperties.bodygroups)
        panel.charProperties.bodygroupContainers[bgName] = bgField

        local bgSlider = bgField.slider
        bgSlider.OnValueChanged = function(self, v)
            charModelEntity:SetBodygroup(i, v)
        end
        bgSlider.MouseReleased = function(self)
            RunConsoleCommand("mwcc_char_edit", "-byindex", panel.charIndex,
                "-pm-body", bgName, self:GetValue(), "-noprint")
        end

        charModelEntity:SetBodygroup(i, bgValue)
    end

    -- Delete button
    panel.charProperties.delete.DoClick = function()
        RunConsoleCommand("mwcc_char_delete", "-byindex", panel.charIndex, "-noprint")
    end
end

local function updateChars()
    if !IsValid(panel) then return end

    -- Update files
    panel.file.name:SetValue(charFile)

    panel.file.nameDrop:Clear()
    for _, f in ipairs(files) do
        panel.file.nameDrop:AddChoice(string.sub(f, 1, string.len(f)-5))
    end

    -- Update characters
    panel.charPick:Clear()

    for i, char in ipairs(characters) do
        local btn = panel.charPick:Add("SpawnIcon")
        btn:SetModel(player_manager.TranslatePlayerModel(char.pm.model))
        btn:SetTooltip(char.name)
        btn:SetTooltipDelay(0)
        btn:Dock(TOP)
        btn.DoClick = function()
            setCurrentChar(i)
        end
    end

    local btnAdd = panel.charPick:Add("DButton")
    btnAdd:Dock(TOP)
    btnAdd:SetSize(64, 64)
    btnAdd:SetText("NEW")
    btnAdd.justClicked = false
    btnAdd.DoClick = function()
        panel.charPick.justAddedChar = true
        RunConsoleCommand("mwcc_char_add", "-noprint")
    end

    if panel.charPick.justAddedChar then
        panel.charPick.justAddedChar = false
        setCurrentChar(#characters)
    else
        setCurrentChar(panel.charIndex)
    end
end

net.Receive("sv_send_chars", function()
    charFile = net.ReadString()

    local filesAndChars = util.JSONToTable(net.ReadString())
    files = filesAndChars.files
    characters = filesAndChars.characters
    updateChars()
end)

local function fileMessage(txt)
    panel.file.msg:SetText(txt)
    panel.file.msg:SetColor(Color(0, 0, 0, 255))
end

local function fileError(txt)
    panel.file.msg:SetText(txt)
    panel.file.msg:SetColor(Color(255, 0, 0, 255))
end

local function fileHide()
    panel.file.msg:SetText("")
end



concommand.Add("mwcc_char_panel", function(ply)
    if IsValid(panel) then
        panel:MakePopup()
        return
    end

    -- Send character request
    net.Start("cl_get_chars")
    net.SendToServer()

    ----------------------------------
    -- MAIN PANEL
    ----------------------------------
    panel = vgui.Create("DFrame")
    panel:MakePopup()
    panel:SetSize(900, 600)
    panel:Center()
    panel:SetTitle("Character Config")

    panel.charIndex = 1

    ----------------------------------
    -- FILE SELECT PANEL
    ----------------------------------
    local filePanel = panel:Add("DPanel")
    filePanel:Dock(TOP)
    filePanel:SetBackgroundColor(Color(0, 0, 0, 0))
    filePanel:DockMargin(4, 4, 4, 4)

    local fileText = filePanel:Add("DLabel")
    fileText:Dock(LEFT)
    fileText:SetText("File:")
    fileText:SizeToContentsX()
    fileText:DockMargin(0, 0, 10, 0)

    local fileNameDrop = filePanel:Add("DComboBox")
    fileNameDrop:Dock(LEFT)
    fileNameDrop:SetWide(200)
    fileNameDrop.OnSelect = function(self, index, value)
        panel.file.name:SetValue(value)
    end

    filePanel.nameDrop = fileNameDrop

    local fileName = fileNameDrop:Add("DTextEntry")
    local w, h = fileNameDrop:GetSize()
    fileName:SetSize(w-20, h+1)
    fileName.OnGetFocus = function()
        panel.file.nameDrop:CloseMenu()
    end
    
    filePanel.name = fileName

    local fileSave = filePanel:Add("DButton")
    fileSave:Dock(LEFT)
    fileSave:SetText("Save")
    fileSave.DoClick = function()
        local name = fileName:GetText()
        if string.len(name) == 0 then 
            fileError("Can't save an unnamed file!")
            return
        end
        fileHide()
        RunConsoleCommand("mwcc_save_chars", fileName:GetText(), "-noprint")
    end

    local fileLoad = filePanel:Add("DButton")
    fileLoad:Dock(LEFT)
    fileLoad:SetText("Load")
    fileLoad.DoClick = function()
        RunConsoleCommand("mwcc_load_chars", fileName:GetText(), "-noprint")
    end

    local fileMsg = filePanel:Add("DLabel")
    fileMsg:Dock(FILL)
    fileMsg:DockMargin(10, 0, 0, 0)
    fileMsg:SetText("")

    filePanel.msg = fileMsg

    panel.file = filePanel

    ----------------------------------
    -- CHARACTER SELECT
    ----------------------------------
    local charPickWrapper = panel:Add("DPanel")
    charPickWrapper:SetWide(64)
    charPickWrapper:Dock(LEFT)

    local charPick = charPickWrapper:Add("DScrollPanel")
    charPick:SetWide(79)
    charPick:Dock(LEFT)
    charPick.justAddedChar = false

    charPick.pnlCanvas:SetWide(64)
    charPick.pnlCanvas:Dock(LEFT)
    charPick.pnlCanvas.PerformLayout = function(pnl)
        charPick:PerformLayoutInternal()

        charPick.pnlCanvas:SetWide(64)
        charPick:Rebuild()

        if charPick:GetVBar().Enabled then
            charPickWrapper:SetWide(79)
        else
            charPickWrapper:SetWide(64)
        end

        charPick:InvalidateParent()
    end

    for i = 1, 10 do
        local btn = charPick:Add("SpawnIcon")
        btn:Dock(TOP)
    end

    panel.charPick = charPick

    ----------------------------------
    -- CHARACTER MODEL PREVIEW
    ----------------------------------
    local charModel = panel:Add("DModelPanel")
    charModel:Dock(FILL)
    charModel:SetModel(player_manager.TranslatePlayerModel("male01"))
    charModel:SetAnimated(true)
    charModel.PaintOver = function()
        local x, y = charModel:GetSize()
        x = x/2
        y = y/2 + 30

        local a = panel.charProperties.nameColor.color.a
        panel.charProperties.nameColor.color.a = 255

        draw.SimpleText(panel.charProperties.name:GetText(), "MersRadial", 
            x+1, y+1, c_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(panel.charProperties.name:GetText(), "MersRadial", 
            x, y, panel.charProperties.nameColor.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        panel.charProperties.nameColor.color.a = a
    end

    charModel.pressed = false
    charModel.pressX = 0
    charModel.pressY = 0
    charModel.DragMousePress = function(self)
        self.pressX, self.pressY = input.GetCursorPos()
        self.pressed = true
    end
    charModel.DragMouseRelease = function(self)
        self.pressed = false
    end
    charModel.LayoutEntity = function(self, ent)
        if self.pressed then
            local mx, my = input.GetCursorPos()
            local angles = ent:GetAngles() - Angle(0, self.pressX - mx, 0)
            ent:SetAngles(angles)
            self.pressX, self.pressY = mx, my
        end
    end
    
    panel.charModel = charModel

    ----------------------------------
    -- CHARACTER SETTINGS
    ----------------------------------
    local charPropertiesWrapper = panel:Add("DPanel")
    charPropertiesWrapper:SetWide(280)
    charPropertiesWrapper:DockPadding(8, 8, 8, 8)
    charPropertiesWrapper:Dock(RIGHT)

    local charProperties = charPropertiesWrapper:Add("DScrollPanel")
    charProperties:Dock(FILL)
    -- charProperties:DockPadding(4, 4, 4, 4)
    panel.charProperties = charProperties

    -- NAME
    local nameField = createTextField("Name: ")
    charProperties:AddItem(nameField)

    local nameFieldTextEntry = nameField.textEntry
    local updateNameFunc = function()
        RunConsoleCommand("mwcc_char_edit", "-byindex", panel.charIndex, "-name", nameFieldTextEntry:GetText(), "-noprint")
    end

    nameFieldTextEntry.OnLoseFocus = updateNameFunc
    nameFieldTextEntry.OnEnter = updateNameFunc

    charProperties.name = nameFieldTextEntry

    -- NAME COLOR
    local nameColorField = createColorField("Name color: ")
    charProperties:AddItem(nameColorField)

    local nameColorButton = nameColorField.colorButton
    local nameColorRandom = nameColorField.randomCheckbox

    nameColorButton:SetText("")

    nameColorButton.OnColorWindowValueChanged = function(color)
        charProperties.nameColor.color = color
    end

    nameColorButton.OnColorWindowFocusChanged = function(focus)
        RunConsoleCommand("mwcc_char_edit", "-byindex", panel.charIndex, "-namecolor", 
            nameColorButton.color.r/255, nameColorButton.color.g/255, nameColorButton.color.b/255, "-noprint")
    end
    
    nameColorRandom.OnChange = function()
        nameColorButton:SetEnabled(!nameColorRandom:GetChecked())

        if nameColorRandom:GetChecked() then
            RunConsoleCommand("mwcc_char_edit", "-byindex", panel.charIndex, "-namecolor", "random", "-noprint")
        else
            RunConsoleCommand("mwcc_char_edit", "-byindex", panel.charIndex, "-namecolor", 
                nameColorButton.color.r/255, nameColorButton.color.g/255, nameColorButton.color.b/255, "-noprint")
        end
    end

    charProperties.nameColor = nameColorButton
    charProperties.nameColorRandom = nameColorRandom

    -- SEX
    local sexField = createOptionToggleField("Sex: ", "M", "F")
    charProperties:AddItem(sexField)

    local mSexButton = sexField.option1Button
    mSexButton.OnClick = function()
        RunConsoleCommand("mwcc_char_edit", "-byindex", panel.charIndex, "-sex", "male", "-noprint")
    end

    local fSexButton = sexField.option2Button
    fSexButton.OnClick = function()
        RunConsoleCommand("mwcc_char_edit", "-byindex", panel.charIndex, "-sex", "female", "-noprint")
    end

    charProperties.sexMale = mSexButton
    charProperties.sexFemale = fSexButton

    -- PLAYERMODEL
    local pmField = createButtonField("Playermodel: ")
    charProperties:AddItem(pmField)

    local pmFieldButton = pmField.button
    pmFieldButton.DoClick = function()
        local pmMenuWindow = vgui.Create("DPanel")
        pmMenuWindow:SetSize(528, 384)
        pmMenuWindow:MakePopup()

        local mx, my = input.GetCursorPos()
        mx = math.Clamp(mx, 0, ScrW() - pmMenuWindow:GetWide())
        my = math.Clamp(my, 0, ScrH() - pmMenuWindow:GetTall())
        pmMenuWindow:SetPos(mx, my)

        pmMenuWindow.OnFocusChanged = function(focus)
            -- Again don't count on this
            if focus:HasFocus() then
                pmMenuWindow:Remove()
            end
        end

        local pmMenu = pmMenuWindow:Add("DScrollPanel")
        pmMenu:Dock(FILL)

        local pmMenuLayout = pmMenu:Add("DIconLayout")
        pmMenuLayout:Dock(FILL)
        pmMenuLayout:SetSpaceX(0)
        pmMenuLayout:SetSpaceY(0)

        local pmList = player_manager.AllValidModels()
        for name, model in SortedPairs(pmList) do
            local btn = pmMenuLayout:Add("SpawnIcon")
            btn:SetSize(64, 64)
            btn:SetModel(model)
            btn.DoClick = function()
                RunConsoleCommand("mwcc_char_edit", "-byindex", panel.charIndex, "-pm", name, "-noprint")
                pmMenuWindow:Remove()
            end
        end
    end

    charProperties.playermodel = pmFieldButton

    -- PLAYERMODEL COLOR
    local pmColorField = createColorField("Playermodel color: ")
    charProperties:AddItem(pmColorField)

    local pmColorButton = pmColorField.colorButton
    local pmColorRandom = pmColorField.randomCheckbox

    pmColorButton:SetText("")

    pmColorButton.OnColorWindowValueChanged = function(c)
        charProperties.pmColor.color = c
        panel.charModel:GetEntity().playerColor = Vector(c.r/255, c.g/255, c.b/255)
    end

    pmColorButton.OnColorWindowFocusChanged = function(focus)
        RunConsoleCommand("mwcc_char_edit", "-byindex", panel.charIndex, "-pm-color", 
            pmColorButton.color.r/255, pmColorButton.color.g/255, pmColorButton.color.b/255, "-noprint")
    end

    pmColorRandom.OnChange = function()
        pmColorButton:SetEnabled(!pmColorRandom:GetChecked())

        if pmColorRandom:GetChecked() then
            RunConsoleCommand("mwcc_char_edit", "-byindex", panel.charIndex, "-pm-color", "random", "-noprint")
        else
            RunConsoleCommand("mwcc_char_edit", "-byindex", panel.charIndex, "-pm-color", 
                pmColorButton.color.r/255, pmColorButton.color.g/255, pmColorButton.color.b/255, "-noprint")
        end
    end

    charProperties.pmColor = pmColorButton
    charProperties.pmColorRandom = pmColorRandom

    -- BODYGROUPS
    local bodygroupHBarWrapper = vgui.Create("DPanel")
    bodygroupHBarWrapper:SetBackgroundColor(Color(0, 0, 0, 0))
    bodygroupHBarWrapper:SetTall(20)
    bodygroupHBarWrapper:Dock(TOP)
    bodygroupHBarWrapper:DockPadding(2, 10, 2, 9)
    charProperties:AddItem(bodygroupHBarWrapper)

    local bodygroupHBar = bodygroupHBarWrapper:Add("DPanel")
    bodygroupHBar:SetBackgroundColor(Color(209, 209, 209, 255))
    bodygroupHBar:Dock(FILL)

    local bodygroupLabel = vgui.Create("DLabel")
    bodygroupLabel:SetText("Bodygroups: ")
    bodygroupLabel:SetDark(true)
    bodygroupLabel:Dock(TOP)
    charProperties:AddItem(bodygroupLabel)

    local bodygroups = charProperties:Add("DSizeToContents")
    bodygroups:DockMargin(0, 4, 0, 4)
    bodygroups:Dock(TOP)
    
    charProperties.bodygroups = bodygroups
    charProperties.bodygroupContainers = {}

    for i = 1, 10 do
        local name = "Bodygroup "..i
        local bgField = createSliderField(name, 0, 4)
        bgField:SetParent(bodygroups)

        local bgSlider = bgField.slider
        charProperties.bodygroups[name] = bgSlider
        charProperties.bodygroupContainers[name] = bgField
    end

    -- DELETE BUTTON
    local deleteButton = charProperties:Add("DButton")
    deleteButton:SetText("Delete character")
    deleteButton:Dock(TOP)
    charProperties.delete = deleteButton
end)
