-- This is how each item in this table should look like in the future

-- {
--     pm = {
--         model = "yourModelNameHere",
--         color = Vector(0, 0, 0),
--         bodygroups = {
--             Your = 0,
--             Bodygroup = 1,
--             Configs = 2,
--             Here = 4,
--         }
--     },
--     name = "Your Character Name Here",
--     nameColor = Vector(0, 0, 0),
--     sex = "male/female"
-- }

-- Stores all our custom characters' data
local characters = {}

-- Load file and store contents in the characters table
local function LoadFile(f)
    -- Check if file exists
    local filename = "mwcc/charconfigs/"..f..".json"
    if !file.Exists(filename, "DATA") then 
        print("mwcc_load_chars: Could not find file "..filename.."!")
        return 2    -- means "file not found"
    end

    -- Read file content
    local json = file.Read(filename, "DATA")
    local jsonTable = util.JSONToTable(json)

    -- Check if content structure is valid
    local invalid = false
    if !istable(jsonTable) then
        invalid = true
        print("mwcc_load_chars: Content inside file is not a table!")
    else
        for k, v in pairs(jsonTable) do
            -- This must be an array, only numerical keys
            if isstring(k) then
                invalid = true
                print("mwcc_load_chars: Table must contain only numerical indexes, found index \""..k.."\"")
                continue
            end

            -- Only tables inside this table
            if !istable(v) then
                invalid = true
                print("mwcc_load_chars: Value at index "..k.." is not a table!")
                continue
            end

            -- Name must be a string
            if !isstring(v.name) then
                invalid = true
                print("mwcc_load_chars: at index "..k..", \"name\" is not a string!")
            end

            -- Sex must be either "male" or "female"
            if v.sex != "male" and v.sex != "female" then
                invalid = true
                print("mwcc_load_chars: at index "..k..", \"sex\" must be either \"male\" or \"female\"!")
            end

            -- Name color must be a vector
            if !isvector(v.nameColor) then
                invalid = true
                print("mwcc_load_chars: at index "..k..", \"nameColor\" is not a vector!")
            end

            -- PM must be a table
            if !istable(v.pm) then
                invalid = true
                print("mwcc_load_chars: at index "..k..", \"pm\" is not a table!")
            else
                -- pm.model must be a string
                if !isstring(v.pm.model) then
                    invalid = true
                    print("mwcc_load_chars: at index "..k..", \"pm.model\" is not a string!")
                end

                -- pm.color must be either a vector or "random"
                if !isvector(v.pm.color) and v.pm.color != "random" then
                    invalid = true
                    print("mwcc_load_chars: at index "..k..", \"pm.color\" is neither a vector nor \"random\"!")
                end

                -- pm.bodygroups must be a table
                if !istable(v.pm.bodygroups) then
                    invalid = true
                    print("mwcc_load_chars: at index "..k..", \"pm.bodygroups\" is not a table!")
                else
                    -- all keys inside pm.bodygroups must be numbers
                    for k2, v2 in pairs(v.pm.bodygroups) do
                        if !isnumber(v.pm.bodygroups[k2]) then
                            invalid = true
                            print("mwcc_load_chars: at index "..k..", \"pm.bodygroups["..k2.."]\" is not a number!")
                        end
                    end
                end
            end
        end
    end

    if invalid then
        print("mwcc_load_chars: Invalid content structure inside "..filename.."!")
        return 3    -- means "invalid content structure"
    end

    -- Set characters table
    characters = jsonTable
    print("mwcc_load_chars: Loaded "..filename.." successfully!")
    return 0    -- means "success"
end

-- Command for loading character files
concommand.Add("mwcc_load_chars", function(ply, cmd, args)
    -- Check permission
    if ply != NULL and !ply:IsAdmin() then
        print("mwcc_load_chars: Only admins can run this command!")
        return 1    -- means "no permission"
    end

    return LoadFile(args[1])
end)

-- Save file
local function SaveFile(f)
    local json = util.TableToJSON(characters)
    local filename = "mwcc/charconfigs/"..f..".json"

    if string.find(filename, ":") then
        print("mwcc_save_chars: Invalid character \":\" found in filename "..filename.."!")
        return 2    -- means invalid character found
    end

    file.Write(filename, json)
    print("mwcc_save_chars: Successfully saved configs to "..filename.."!")
    return 0    -- means success
end

-- Command for saving files
concommand.Add("mwcc_save_chars", function(ply, cmd, args)
    -- Check permission
    if ply != NULL and !ply:IsAdmin() then
        print("mwcc_save_chars: Only admins can run this command!")
        return 1    -- means "no permission"
    end

    return SaveFile(args[1])
end)

-- Command for printing characters
concommand.Add("mwcc_print_chars", function(ply, cmd, args)
    -- Check permission
    if ply != NULL and !ply:IsAdmin() then
        print("mwcc_print_chars: Only admins can run this command!")
        return 1    -- means "no permission"
    end

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
    for i, c in ipairs(characters) do
        local name      = c.name
        local nameColor = string.sub(c.nameColor.x, 1, 4).." "..string.sub(c.nameColor.y, 1, 4).." "..string.sub(c.nameColor.z, 1, 4)
        local pm        = c.pm.model
        local pmColor   = string.sub(c.pm.color.x, 1, 4).." "..string.sub(c.pm.color.y, 1, 4).." "..string.sub(c.pm.color.z, 1, 4)
        local sex       = c.sex
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

-- Command for printing specific character info
concommand.Add("mwcc_char_info", function(ply, cmd, args)
    -- Check permission
    if ply != NULL and !ply:IsAdmin() then
        print("mwcc_char_info: Only admins can run this command!")
        return 1    -- means "no permission"
    end

    local index
    local char

    if !args[2] or (args[1] != "-byname" and args[1] != "-byindex") then
        print("mwcc_char_info: Must include an identifier, either with \"-byname [name]\" or \"-byindex [index]\"!") 
        return 2    -- means "no identifier"
    end

    if args[1] == "-byname" then
        for i,v in pairs(characters) do
            if string.lower(v.name) == string.lower(args[2]) then
                index = i
                char = v
                break
            end
        end
    elseif args[1] == "-byindex" then
        index = tonumber(args[2])
        char = characters[index]
    end

    if char == nil then
        print("mwcc_char_info: Could not find specified character!")
        return 3    -- means "not found"
    end

    print("INDEX: "..index)
    print("NAME: "..char.name)
    print("NAME COLOR: "..string.sub(char.nameColor.x, 1, 4).." "..string.sub(char.nameColor.y, 1, 4).." "..string.sub(char.nameColor.z, 1, 4))
    print("PLAYERMODEL: "..char.pm.model)
    print("PM COLOR: "..string.sub(char.pm.color.x, 1, 4).." "..string.sub(char.pm.color.y, 1, 4).." "..string.sub(char.pm.color.z, 1, 4))
    print("SEX: "..char.sex)

    print("BODYGROUPS ("..#char.pm.bodygroups.."):")
    for k,v in pairs(char.pm.bodygroups) do
        print("- "..k..": "..v)
    end
end)

-- Load default file on start
-- TODO idk if it's just me, but it seems as if sometimes the file isn't loaded when the gamemode is initialized.
hook.Add("Initialize", "InitializeChars", function()
    LoadFile("default")
end)

function SetPlayerCharacters()
    -- Shuffle so if there are not enough custom chars for everyone in the server, 
    -- at least everyone gets to play as one eventually
    local players = player:GetAll()
    local chars = table.Copy(characters)
    table.Shuffle(players)
    table.Shuffle(chars)
    
    for k, ply in ipairs(players) do
        -- Keep default model for this player
        if k > #characters then break end

        local char = chars[k]

        -- Model
        local modelPath = player_manager.TranslatePlayerModel(char.pm.model)
        util.PrecacheModel(modelPath)
        ply:SetModel(modelPath)

        -- Model color
        local modelColor = char.pm.color
        if modelColor == "random" then 
            modelColor = Vector(math.Rand(0,1), math.Rand(0,1), math.Rand(0,1)) 
        end
        ply:SetPlayerColor(modelColor)

        -- Model bodygroups
        local skin = char.pm.bodygroups.Skin
        if skin == nil then skin = 0 end
        ply:SetSkin(skin)

        for i = 0, ply:GetNumBodyGroups()-1 do
            ply:SetBodygroup(i, 0)
        end

        for bname, bvalue in pairs(char.pm.bodygroups) do
            if bname == "Skin" then continue end
            ply:SetBodygroup(ply:FindBodygroupByName(bname), bvalue)
        end

        -- Model hands
        ply:SetupHands()

        -- Name
        ply:SetBystanderName(char.name)

        -- Name color
        ply:SetNameColor(char.nameColor)

        -- Sex
        ply.ModelSex = char.sex
    end
end
