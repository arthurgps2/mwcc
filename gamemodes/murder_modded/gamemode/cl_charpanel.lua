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

        --  Name
        charProperties:TextEntry("Name:")
        
        -- Name color
        local inputNCLeft = vgui.Create("DLabel")
        inputNCLeft:SetText("Name color:")

        local inputNCRight = vgui.Create("DPanel")
        inputNCRight:Dock(FILL)
        inputNCRight:SetBackgroundColor(Color(0, 0, 0, 0))
        local inputNCRandom = inputNCRight:Add("DCheckBoxLabel")
        inputNCRandom:Dock(LEFT)
        inputNCRandom:SetText("Random")
        local inputNCButton = inputNCRight:Add("DButton")
        inputNCButton:SetWide(25)
        inputNCButton:Dock(RIGHT)

        charProperties:AddItem(inputNCLeft, inputNCRight)

        -- Sex
        local inputSexLeft = vgui.Create("DLabel")
        inputSexLeft:SetText("Sex:")

        local inputSexRight = vgui.Create("DPanel")
        inputSexRight:Dock(FILL)
        inputSexRight:SetBackgroundColor(Color(0, 0, 0, 0))
        local inputSexMale = inputSexRight:Add("DButton")
        inputSexMale:Dock(LEFT)
        inputSexMale:SetWide(25)
        inputSexMale:SetText("M")
        local inputSexFemale = inputSexRight:Add("DButton")
        inputSexFemale:Dock(RIGHT)
        inputSexFemale:SetWide(25)
        inputSexFemale:SetText("F")
        
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
            charProperties:NumSlider("Bodygroup "..i, nil, 0, 4, 0)
        end
    end
end)
