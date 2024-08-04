local panel

concommand.Add("mwcc_char_panel", function(ply)
    if panel then
        
    else
        -- Main panel
        panel = vgui.Create("DFrame")
        panel:MakePopup()
        panel:SetSize(600, 400)
        panel:Center()
        panel:SetTitle("Character Config")

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
        inputNCButton.PaintOver = function(w, h)
            draw.RoundedBox(0, 3, 3, inputNCButton:GetWide()-6, inputNCButton:GetTall()-6, Color(255, 0, 0, 255))
        end

        inputNCButton.DoClick = function()
            local colorWindow = vgui.Create("DPanel")
            colorWindow:SetSize(250, 200)
            colorWindow:SetPos(gui.MousePos())
            colorWindow:MakePopup()
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

        charProperties:AddItem(inputPMLeft, inputPMRight)

        -- PM Color
        local inputPMColorLeft = vgui.Create("DLabel")
        inputPMColorLeft:SetText("PM color:")

        local inputPMColorRight = vgui.Create("DPanel")
        inputPMColorRight:Dock(FILL)
        inputPMColorRight:SetBackgroundColor(Color(0, 0, 0, 0))
        local inputPMColorRandom = inputPMColorRight:Add("DCheckBoxLabel")
        inputPMColorRandom:SetText("Random")
        inputPMColorRandom:Dock(LEFT)
        local inputPMColorButton = inputPMColorRight:Add("DButton")
        inputPMColorButton:SetWide(25)
        inputPMColorButton:Dock(RIGHT)

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
