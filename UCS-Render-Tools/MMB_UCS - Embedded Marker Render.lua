-- Function to read base folder path from a config file
function read_base_folder()
     local config_path = reaper.GetResourcePath() .. "/Scripts/MAB UCS Render Tools/UCS Tools/ucs_config.txt"
    local file = io.open(config_path, "r")
    if file then
        local base_folder = file:read("*l")
        file:close()
        return base_folder
    else
        reaper.ShowMessageBox("Configuration file not found!", "Error", 0)
        return nil
    end
end

-- Function to extract the category from the UCS marker near the media item
function get_category_from_marker(media_item)
    -- Get the start position of the media item
    local item_position = reaper.GetMediaItemInfo_Value(media_item, "D_POSITION")

    -- Count all project markers
    local marker_count = reaper.CountProjectMarkers(0)

    -- Look for a marker at or near the item's start position
    for i = 0, marker_count - 1 do
        local retval, isrgn, marker_pos, rgnend, name, marker_idx = reaper.EnumProjectMarkers(i)
        
        -- Check if the marker is near the item position and contains "Category="
        if math.abs(marker_pos - item_position) < 0.01 and name:find("Category=") then  -- Look for "Category=" in marker name
            -- Try to extract the "Category" from the marker's name
            local category = name:match("Category=([^;]+)")
            if category then
                return category
            end
        end
    end

    return nil  -- Return nil if no valid UCS marker found
end

-- Function to check if all selected items have the same category from their corresponding UCS markers
function check_all_items_same_category()
    local item_count = reaper.CountSelectedMediaItems(0)  -- Count only selected media items
    if item_count == 0 then
        reaper.ShowMessageBox("No media items selected!", "Error", 0)
        return nil
    end

    -- Get the category from the first selected item's UCS marker
    local first_category = get_category_from_marker(reaper.GetSelectedMediaItem(0, 0))  -- Check only selected items
    if not first_category then
        reaper.ShowMessageBox("No UCS category marker found for the first selected item!", "Error", 0)
        return nil
    end

    -- Check the rest of the selected items for the same UCS category
    for i = 1, item_count - 1 do
        local media_item = reaper.GetSelectedMediaItem(0, i)
        local category = get_category_from_marker(media_item)
        if category ~= first_category then
            reaper.ShowMessageBox("Multiple UCS category types found! Ensure all selected items have the same category.", "Warning", 0)
            return nil
        end
    end

    return first_category
end

-- Function to update Reaper's render output directory and filename using UCS category and "$item" wildcard
function update_render_output_directory_and_filename()
    local base_folder = read_base_folder()
    if not base_folder then
        return
    end

    -- Check that all selected items have the same UCS category
    local category = check_all_items_same_category()
    if not category then
        return
    end

    -- Set the render folder based on the UCS category
    local folder_path = base_folder .. "/" .. category
    reaper.RecursiveCreateDirectory(folder_path, 0) -- Ensure the folder exists

    -- Set the render path (directory) in Reaper's "Render to File" window
    reaper.GetSetProjectInfo_String(0, "RENDER_FILE", folder_path .. "/", true)

    -- Set the filename wildcard ($item) in the "Render to File" window
    --reaper.GetSetProjectInfo_String(0, "RENDER_PATTERN", "$item", true)

    -- Open the "Render to File" window
    reaper.Main_OnCommand(40015, 0)  -- Opens the "Render to File" dialog
end

-- Main function to run the script
function main()
    update_render_output_directory_and_filename()
end

-- Run the script
main()
