-- Define the UCS categories based on v8.2.1
local ucs_categories = {
    "AIR", "AIRCRAFT", "ALARMS", "AMBIENCE", "ANIMALS", "ARCHIVED", "BEEPS", "BELLS", "BIRDS", 
    "BOATS", "BULLETS", "CARTOON", "CERAMICS", "CHAINS", "CHEMICALS", "CLOCKS", "CLOTH", 
    "COMMUNICATIONS", "COMPUTERS", "CREATURES", "CROWDS", "DESIGNED", "DESTRUCTION", 
    "DIRT & SAND", "DOORS", "DRAWERS", "ELECTRICITY", "EQUIPMENT", "EXPLOSIONS", "FARTS", 
    "FIGHT", "FIRE", "FIREWORKS", "FOLEY", "FOOD & DRINK", "FOOTSTEPS", "GAMES", "GEOTHERMAL", 
    "GLASS", "GORE", "GUNS", "HORNS", "HUMAN", "ICE", "LASERS", "LEATHER", "LIQUID & MUD", 
    "MACHINES", "MAGIC", "MECHANICAL", "METAL", "MOTORS", "MOVEMENT", "MUSICAL", "NATURAL DISASTER", 
    "OBJECTS", "PAPER", "PLASTIC", "RAIN", "ROBOTS", "ROCKS", "ROPE", "RUBBER", "SCIFI", 
    "SNOW", "SPORTS", "SWOOSHES", "TOOLS", "TOYS", "TRAINS", "USER INTERFACE", "VEGETATION", 
    "VEHICLES", "VOICES", "WATER", "WEAPONS", "WEATHER", "WHISTLES", "WIND", "WINDOWS", 
    "WINGS", "WOOD"
}

-- Function to prompt user to select a destination folder
function choose_destination_folder()
    local retval, folder_path = reaper.JS_Dialog_BrowseForFolder("Choose Destination Folder", "")
    if retval == 1 then
        return folder_path
    else
        return nil
    end
end

-- Create folders for each UCS category
function create_ucs_folders(destination_folder)
    if destination_folder then
        for _, category in ipairs(ucs_categories) do
            local folder_path = destination_folder .. "/" .. category
            reaper.RecursiveCreateDirectory(folder_path, 0)
        end
        
        -- Save the destination folder path to a configuration file inside the MAB folder
        local config_file_path = reaper.GetResourcePath() .. "/Scripts/MMB-Reaper-Scripts/UCS-Render-Tools/ucs_config.txt"
        local config_file = io.open(config_file_path, "w")
        if config_file then
            config_file:write(destination_folder)
            config_file:close()
            -- Message without path details
            reaper.ShowMessageBox("UCS folders created successfully! Path has been saved in the UCS-Render-Tools folder.", "Success", 0)
        else
            reaper.ShowMessageBox("Failed to save the folder path. Check permissions or path.", "Error", 0)
        end
    else
        reaper.ShowMessageBox("No destination folder selected.", "Error", 0)
    end
end

-- Main function to run the script
function main()
    -- Ensure the SWS Extension (needed for folder browsing) is installed
    if not reaper.APIExists("JS_Dialog_BrowseForFolder") then
        reaper.ShowMessageBox("Please install the SWS Extension to use this script.", "Error", 0)
        return
    end

    -- Prompt user to select destination folder
    local destination_folder = choose_destination_folder()

    -- Create folders if a destination is selected
    create_ucs_folders(destination_folder)
end

-- Run the script
main()

