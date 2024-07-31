-- Helper function for checking if player is admin
local function checkAdmin(ply)
    if ply != NULL and !ply:IsAdmin() then
        print("mwcc_save_chars: Only admins can run this command!")
        return false
    end
    return true
end

-- Command for saving files
concommand.Add("mwcc_save_chars", function(ply, cmd, args)
    -- Check permission
    if !checkAdmin(ply) then return 1 end   -- 1 means "no permission"

    return SaveCharsFile(args[1])
end)

-- Command for loading character files
concommand.Add("mwcc_load_chars", function(ply, cmd, args)
    -- Check permission
    if !checkAdmin(ply) then return 1 end   -- 1 means "no permission"

    if !args[1] then
        print("mwcc_load_chars: No file passed!")
        return 3    -- means "failed to load file"
    end

    return LoadCharsFile(args[1])
end)

-- Command for printing characters
concommand.Add("mwcc_print_chars", function(ply, cmd, args)
    -- Check permission
    if !checkAdmin(ply) then return 1 end   -- 1 means "no permission"

    -- Set tables
    local printTable = {{"INDEX", "NAME", "NAME COLOR", "PLAYERMODEL", "PM COLOR", "SEX"}}
    local columnWidths = {0, 0, 0, 0, 0, 0}
    local function upd()
        for i,v in ipairs(columnWidths) do
            columnWidths[i] = math.max(v, string.len(printTable[#printTable][i]))
        end
    end
    upd()

    -- Add content to print table and update column widths
    local characters = GetCustomChars()
    for i, c in ipairs(characters) do
        local name      = c.name
        local pm        = c.pm.model
        local sex       = c.sex

        local nameColor
        if isvector(c.nameColor) then nameColor = string.sub(c.nameColor.x, 1, 4).." "..string.sub(c.nameColor.y, 1, 4).." "..string.sub(c.nameColor.z, 1, 4)
        else nameColor = c.nameColor end
        
        local pmColor
        if isvector(c.pm.color) then pmColor = string.sub(c.pm.color.x, 1, 4).." "..string.sub(c.pm.color.y, 1, 4).." "..string.sub(c.pm.color.z, 1, 4)
        else pmColor = c.pm.color end

        table.insert(printTable, {i, name, nameColor, pm, pmColor, sex})
        upd()
    end

    -- Print content from table
    for i,v in ipairs(printTable) do
        local output = ""
        for j,w in ipairs(v) do
            output = output..w..string.rep(" ", columnWidths[j] - string.len(w))
            if j != #v then output = output.." | " end
        end
        print(output)
    end

    return 0    -- means success
end)

-- Some helper functions for the mwcc_char_- commands
local function findCharacterByName(n)
    local characters = GetCustomChars()
    for i,v in pairs(characters) do
        if string.lower(v.name) == string.lower(n) then
            return i, v
        end
    end
end

local function findCharacterByIndex(i)
    local characters = GetCustomChars()
    i = tonumber(i)
    return i, characters[i]
end

local function findCharacterFromArgs(args)
    local index, char

    if args[1] then
        if args[1] == "-byname" then
            index, char = findCharacterByName(args[2])
        elseif args[1] == "-byindex" then
            index, char = findCharacterByIndex(args[2])

        -- None of these tags found. If arg is a number, assume it's the index
        elseif tonumber(args[1]) then
            index, char = findCharacterByIndex(args[1])
        
        -- Not a number either, so it must be the name
        else
            index, char = findCharacterByName(args[1])
        end
    else
        return 2    -- means "could not find identifier"
    end

    -- Char not found
    if char == nil then
        return 3    -- means "not found"
    end

    return 0, index, char
end

-- Command for printing specific character info
concommand.Add("mwcc_char_info", function(ply, cmd, args)
    -- Check permission
    if !checkAdmin(ply) then return 1 end   -- 1 means "no permission"

    -- Get char from identifier
    local r, index, char = findCharacterFromArgs(args)
    if r == 2 then 
        print("mwcc_char_info: Must include either the name or the index of the character!")
        return r
    elseif r == 3 then
        print("mwcc_char_info: Could not find specified character!")
        return r
    end

    -- Print info
    print("INDEX: "..index)
    print("NAME: "..char.name)

    if isvector(char.nameColor) then
        print("NAME COLOR: "..string.sub(char.nameColor.x, 1, 4).." "..string.sub(char.nameColor.y, 1, 4).." "..string.sub(char.nameColor.z, 1, 4))
    else
        print("NAME COLOR: "..char.nameColor)
    end

    print("PLAYERMODEL: "..char.pm.model)

    if isvector(char.pm.color) then
       print("PM COLOR: "..string.sub(char.pm.color.x, 1, 4).." "..string.sub(char.pm.color.y, 1, 4).." "..string.sub(char.pm.color.z, 1, 4))
    else
        print("PM COLOR: "..char.pm.color)
    end

    print("SEX: "..char.sex)

    print("BODYGROUPS ("..#char.pm.bodygroups.."):")
    for k,v in pairs(char.pm.bodygroups) do
        print("- "..k..": "..v)
    end

    return 0    -- means "success"
end)

-- Command for editing character info
concommand.Add("mwcc_char_edit", function(ply, cmd, args)
    -- Check permission
    if !checkAdmin(ply) then return 1 end   -- 1 means "no permission"

    -- Get char from identifier
    local r, index, char = findCharacterFromArgs(args)
    if r == 2 then 
        print("mwcc_char_edit: Must include either the name or the index of the character!")
        return r
    elseif r == 3 then
        print("mwcc_char_edit: Could not find specified character!")
        return r
    end

    -- Set loop start position
    local start
    if args[1] == "-byname" or args[1] == "-byindex" then
        start = 3
    else
        start = 2
    end

    -- Make a copy of the character to overwrite the original with
    char = table.Copy(char)

    -- Quick func for throwing an error for invalid command
    local function throwInvalid()
        print("mwcc_char_edit: Invalid command format!")
        return 4    -- means "invalid format"
    end

    -- Check if there's actually anything after the identifier
    if !args[start] then
        return throwInvalid()
    end

    -- Loop through the rest of command looking for varnames and its values to change to
    local i = start
    while i <= #args do
        local varname = args[i]
        if varname == "-name" then
            char.name = args[i+1]
            i = i+1
        elseif varname == "-namecolor" then
            local r = args[i+1]
            if r == "random" then
                char.nameColor = r
                i = i+1
            else
                r = tonumber(r)
                local g = tonumber(args[i+2])
                local b = tonumber(args[i+3])

                if !r or !g or !b then
                    return throwInvalid()
                end

                r = math.Clamp(r, 0, 1)
                g = math.Clamp(g, 0, 1)
                b = math.Clamp(b, 0, 1)

                char.nameColor = Vector(r, g, b)
                i = i+3
            end
        elseif varname == "-sex" then
            char.sex = args[i+1]
            i = i+1
        elseif varname == "-pm" then
            char.pm.model = args[i+1]
            i = i+1
        elseif varname == "-pm-color" then
            local r = args[i+1]
            if r == "random" then
                char.pm.color = r
                i = i+1
            else
                r = tonumber(r)
                local g = tonumber(args[i+2])
                local b = tonumber(args[i+3])

                if !r or !g or !b then
                    return throwInvalid()
                end

                r = math.Clamp(r, 0, 1)
                g = math.Clamp(g, 0, 1)
                b = math.Clamp(b, 0, 1)

                char.pm.color = Vector(r, g, b)
                i = i+3
            end
        elseif varname == "-pm-body" then
            for j = i+1, #args, 2 do
                local bgName = string.lower(args[j])
                local bgValue = tonumber(args[j+1])

                local bgNameFirstChar = string.sub(bgName, 1, 1)

                if bgNameFirstChar == "-" then
                    i = j-1
                    break
                elseif tonumber(bgNameFirstChar) or !bgValue then
                    return throwInvalid()
                end

                -- Look for the correct-cased bgName in case there's any difference in letter case
                for bgk, bgv in pairs(char.pm.bodygroups) do
                    if string.lower(bgk) == bgName then
                        bgName = bgk
                        break
                    end
                end

                -- Set bodygroup
                char.pm.bodygroups[bgName] = bgValue

                -- Finished reading whole command
                if j+1 == #args  then
                    i = j+1
                    break
                end
            end
        else
            -- Expected any of these varnames, got none of them. Invalid format
            return throwInvalid()
        end

        i = i+1
    end

    SetCustomChar(index, char)
    print("mwcc_char_edit: Changed character info for "..char.name.." successfully!")
end)
