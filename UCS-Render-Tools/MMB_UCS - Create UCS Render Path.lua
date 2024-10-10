-- Function to prompt user to select a destination folder
function choose_destination_folder()
    local retval, folder_path = reaper.JS_Dialog_BrowseForFolder("Choose Render Output Folder", "")
    if retval == 1 then
        return folder_path
    else
        return nil
    end
end

-- Function to save the user-chosen folder path to a config file
function save_chosen_folder(folder_path)
    local config_file_path = reaper.GetResourcePath() .. "/Scripts/MMB-Reaper-Scripts/UCS-Render-Tools/ucs_config.txt"
    local config_file = io.open(config_file_path, "w")
    if config_file then
        config_file:write(folder_path)
        config_file:close()
        reaper.ShowMessageBox("Render folder path saved successfully!", "Success", 0)
    else
        reaper.ShowMessageBox("Failed to save the folder path. Check permissions or path.", "Error", 0)
    end
end

-- Main function to prompt user for folder and save it
function main()
    local selected_folder = choose_destination_folder()
    if selected_folder then
        save_chosen_folder(selected_folder)
    else
        reaper.ShowMessageBox("No folder selected!", "Error", 0)
    end
end

-- Run the script
main()
