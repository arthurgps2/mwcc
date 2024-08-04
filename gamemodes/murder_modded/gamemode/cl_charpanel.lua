local characters = {}

local panel

local function updateChars()
    if !IsValid(panel) then return end

    -- Update characters
    panel.charPick:Clear()

    for _, char in ipairs(characters) do
        local btn = panel.charPick:Add("SpawnIcon")
        btn:SetModel(player_manager.TranslatePlayerModel(char.pm.model))
        btn:SetTooltip(char.name)
        btn:SetTooltipDelay(0)
        btn:Dock(TOP)
    end

    local btnAdd = panel.charPick:Add("DButton")
    btnAdd:Dock(TOP)
    btnAdd:SetSize(64, 64)
    btnAdd:SetText("NEW")
end

net.Receive("sv_send_chars", function()
    characters = util.JSONToTable(net.ReadString())
    updateChars()
end)

concommand.Add("mwcc_char_panel", function(ply)
    if IsValid(panel) then
        
    else
        -- Send character request
        net.Start("cl_get_chars")
        net.SendToServer()

        -- Main panel
        panel = vgui.Create("DFrame")
        panel:MakePopup()
        panel:SetSize(600, 400)
        panel:Center()
        panel:SetTitle("Character Config")

        panel.charIndex = 1

        -- Character selector on the left
        local charPick = panel:Add("DScrollPanel")
        charPick:Dock(LEFT)
        charPick:SetMinimumSize(charPick:GetWide() + charPick:GetVBar():GetWide(), charPick:GetTall())
        charPick:SetBackgroundColor(Color(255, 0, 0, 255))

        for i = 1, 10 do
            local btn = charPick:Add("SpawnIcon")
            btn:Dock(TOP)
        end

        -- Character model preview in the middle
        local charModel = panel:Add("DModelPanel")
        charModel:Dock(FILL)
        charModel:SetModel(player_manager.TranslatePlayerModel("male01"))
        charModel:SetAnimated(true)

        -- Character settings on the right
        local charScrollWrapper = panel:Add("DScrollPanel")
        charScrollWrapper:Dock(RIGHT)
        charScrollWrapper:SetWide(250)

        local charProperties = charScrollWrapper:Add("DForm")
        charProperties:Dock(FILL)
        charProperties:SetLabel("Character settings")

        --  Name
        local inputName = charProperties:TextEntry("Name:")
        
        -- Name color
        local inputNCLeft = vgui.Create("DLabel")
        inputNCLeft:SetText("Name color:")

        local inputNCRight = vgui.Create("DPanel")
        inputNCRight:Dock(FILL)
        inputNCRight:SetBackgroundColor(Color(0, 0, 0, 0))

        local inputNCRandom = inputNCRight:Add("DCheckBoxLabel")
        local inputNCButton = inputNCRight:Add("DButton")

        inputNCRandom:Dock(LEFT)
        inputNCRandom:SetText("Random")
        inputNCRandom.OnChange = function()
            inputNCButton:SetEnabled(!inputNCRandom:GetChecked())
        end
        
        inputNCButton:SetWide(25)
        inputNCButton:Dock(RIGHT)
        inputNCButton:SetText("")
        inputNCButton.PaintOver = function()
            local c = Color(255, 0, 0, 255)
            if !inputNCButton:IsEnabled() then c.a = 127 end
            draw.RoundedBox(0, 3, 3, inputNCButton:GetWide()-6, inputNCButton:GetTall()-6, c)
        end

        inputNCButton.DoClick = function()
            local colorWindow = vgui.Create("DPanel")
            colorWindow:SetSize(250, 200)
            colorWindow:MakePopup()

            local mx, my = input.GetCursorPos()
            mx = math.Clamp(mx, 0, ScrW() - colorWindow:GetWide())
            my = math.Clamp(my, 0, ScrH() - colorWindow:GetTall())
            colorWindow:SetPos(mx, my)
            colorWindow.OnFocusChanged = function(focus)
                -- According to the wiki, focus was supposed to be a boolean, but it's just the
                -- panel that contains this function. Most definitely a bug.
                -- The solution below is full quirk. Don't count on it too much.
                if focus:HasFocus() then
                    colorWindow:Remove()
                end
            end
            local color = colorWindow:Add("DColorMixer")
            color:Dock(FILL)
            color:SetAlphaBar(false)
            color:SetPalette(false)
        end

        charProperties:AddItem(inputNCLeft, inputNCRight)

        -- Sex
        local inputSexLeft = vgui.Create("DLabel")
        inputSexLeft:SetText("Sex:")

        local inputSexRight = vgui.Create("DPanel")
        inputSexRight:Dock(FILL)
        inputSexRight:SetBackgroundColor(Color(0, 0, 0, 0))

        local inputSexMale = inputSexRight:Add("DButton")
        local inputSexFemale = inputSexRight:Add("DButton")

        inputSexMale:Dock(LEFT)
        inputSexMale:SetWide(25)
        inputSexMale:SetText("M")
        inputSexMale:SetIsToggle(true)
        inputSexMale:SetToggle(true)
        inputSexMale.DoClick = function()
            inputSexMale:SetToggle(true)
            inputSexFemale:SetToggle(false)
        end

        inputSexFemale:Dock(RIGHT)
        inputSexFemale:SetWide(25)
        inputSexFemale:SetText("F")
        inputSexFemale:SetIsToggle(true)
        inputSexFemale.DoClick = function()
            inputSexMale:SetToggle(false)
            inputSexFemale:SetToggle(true)
        end

        charProperties:AddItem(inputSexLeft, inputSexRight)

        -- Playermodel
        local inputPMLeft = vgui.Create("DLabel")
        inputPMLeft:SetText("Playermodel")

        local inputPMRight = vgui.Create("DButton")
        inputPMRight:Dock(FILL)
        inputPMRight:SetText("male01")
        inputPMRight.DoClick = function()
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
            
            for i = 1, 60 do
                local btn = pmMenuLayout:Add("SpawnIcon")
                btn:SetSize(64, 64)
                btn.DoClick = function()
                    pmMenuWindow:Remove()
                end
            end
        end
        

        charProperties:AddItem(inputPMLeft, inputPMRight)

        -- PM Color
        local inputPMColorLeft = vgui.Create("DLabel")
        inputPMColorLeft:SetText("PM color:")

        local inputPMColorRight = vgui.Create("DPanel")
        inputPMColorRight:Dock(FILL)
        inputPMColorRight:SetBackgroundColor(Color(0, 0, 0, 0))

        local inputPMColorRandom = inputPMColorRight:Add("DCheckBoxLabel")
        local inputPMColorButton = inputPMColorRight:Add("DButton")

        inputPMColorRandom:SetText("Random")
        inputPMColorRandom:Dock(LEFT)
        inputPMColorRandom.OnChange = function()
            inputPMColorButton:SetEnabled(!inputPMColorRandom:GetChecked())
        end
        
        inputPMColorButton:SetWide(25)
        inputPMColorButton:Dock(RIGHT)
        inputPMColorButton:SetText("")
        inputPMColorButton.PaintOver = function()
            local c = Color(255, 0, 0, 255)
            if !inputPMColorButton:IsEnabled() then c.a = 127 end
            draw.RoundedBox(0, 3, 3, inputNCButton:GetWide()-6, inputNCButton:GetTall()-6, c)
        end
        inputPMColorButton.DoClick = function()
            local colorWindow = vgui.Create("DPanel")
            colorWindow:SetSize(250, 200)
            colorWindow:MakePopup()

            local mx, my = input.GetCursorPos()
            mx = math.Clamp(mx, 0, ScrW() - colorWindow:GetWide())
            my = math.Clamp(my, 0, ScrH() - colorWindow:GetTall())
            colorWindow:SetPos(mx, my)
            colorWindow.OnFocusChanged = function(focus)
                -- Quirky ass if statement
                if focus:HasFocus() then
                    colorWindow:Remove()
                end
            end
            local color = colorWindow:Add("DColorMixer")
            color:Dock(FILL)
            color:SetAlphaBar(false)
            color:SetPalette(false)
        end

        charProperties:AddItem(inputPMColorLeft, inputPMColorRight)

        -- PM bodygroups
        charProperties:Help("Bodygroups:")

        for i = 1, 10 do
            local inputBG = charProperties:NumSlider("Bodygroup "..i, nil, 0, 4, 0)
            inputBG:Dock(FILL)
            inputBG:SetValue(0)
        end
    end
end)
