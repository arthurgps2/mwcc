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
    sex = "female"
}

function SetPlayerCharacters()
    -- Shuffle so if there are not enough custom chars for everyone in the server, 
    -- at least everyone gets to play as one eventually
    local players = player:GetAll()
    table.Shuffle(players)
    
    print("n: "..#players)
    for k, ply in ipairs(players) do
        -- Keep default model for this player
        if k > #characters then break end

        local char = characters[k]

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
        for bname, bvalue in pairs(char.pm.bodygroups) do
            if bname == "Skin" then
                ply:SetSkin(bvalue)
            else
                ply:SetBodygroup(ply:FindBodygroupByName(bname), bvalue)
            end
        end

        -- Name
        ply:SetBystanderName(char.name)

        -- Sex
        ply.ModelSex = char.sex
    end
end
