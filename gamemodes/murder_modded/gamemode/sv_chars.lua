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

-- TODO for testing, remove later and some code for importing data from files
characters[1] = {
    pm = {
        model = "Mimi (Mini-Sentry Girl)",
        color = Vector(0, 0, 0),
        bodygroups = {
            Skin = 8,
            Team = 1
        }
    },
    name = "Mimi",
    nameColor = Vector(.4, .4, 1),
    sex = "female"
}
characters[2] = {
    pm = {
        model = "Niko (Sasamin)",
        color = "random",
        bodygroups = {
            ["MLG Glasses"] = 1
        }
    },
    name = "Niko",
    nameColor = Vector(.5, .2, 1),
    sex = "male"
}
characters[3] = {
    pm = {
        model = "Red Shygal",
        color = "random",
        bodygroups = {
            Hair = 1
        }
    },
    name = "Shygal",
    nameColor = Vector(1, 0, 0),
    sex = "female"
}
characters[1] = {
    pm = {
        model = "Sonic the Hedgehog - Lanolin the Sheep",
        color = "random",
        bodygroups = {
            Gloves = 1
        }
    },
    name = "Lanolin",
    nameColor = Vector(.9, .9, .9),
    sex = "female"
}

concommand.Add("mwcc_load_chars", function(ply, cmd, args)
    -- Check permission
    if ply != NULL and !ply:IsAdmin() then
        print("mwcc_load_chars: Only admins can run this command!")
        return 1    -- means "no permission"
    end

    -- Check if file exists
    local filename = "mwcc/charconfigs/"..args[1]..".chars"
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
    print("mwcc_load_chars: Loaded character configs successfully!")
    return 0    -- means "success"
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
