-- Stores all our custom characters' data
local characters = {}

-- Getter, setter, adder, remover, urmommer etc.
function GetCustomChars()
    return characters
end

function SetCustomChar(index, char)
    characters[index] = char
end

function AddCustomChar(char)
    table.insert(characters, char)
end

function DeleteCustomChar(index)
    table.remove(characters, index)
end

-- Save file
function SaveCharsFile(f)
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

-- Load file
function LoadCharsFile(f)
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
        print("mwcc_load_chars: Failed to load file "..filename.."!")
        return 3    -- means "failed to load file"
    end

    -- Set characters table
    characters = jsonTable
    print("mwcc_load_chars: Loaded "..filename.." successfully!")
    return 0    -- means "success"
end

-- Load default file on start
hook.Add("Initialize", "InitializeChars", function()
    LoadCharsFile("default")
end)

-- Set all players' characters from the table
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
