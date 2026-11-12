---telescope picker integration for indexed treetags definitions.
local ok, _ = pcall(require, 'telescope')
if not ok then
    error("treetags.pickers.telescope was required but 'telescope' plugin was not found")
end

local utils = require('treetags.pickers.utils')

local TelescopePickerBuilder = require('treetags.pickers.telescope.builder')

---Transform a list of indexed files into Telescope entry items.
---@param files TreetagFile[]
---@return table[]
local function files_to_entries(files)
    local entries = {}
    for _, file in ipairs(files) do
        table.insert(entries, {
            name = file.path,
            path = file.path,
            row = 1,
        })
    end
    return entries
end

return {
    treetags_all = TelescopePickerBuilder:new()
        :with_items_provider(require('treetags').get_all_treetags)
        :with_formatter(utils.__format_entry)
        :with_prompt('Treetags')
        :new_table(),

    treetags_cword = TelescopePickerBuilder:new()
        :with_items_provider(function()
            local current_word = vim.fn.expand('<cword>')
            return require('treetags').get_treetag_by_name(current_word)
        end)
        :with_formatter(utils.__format_entry)
        :with_prompt('cword')
        :new_table(),

    treetags_cWORD = TelescopePickerBuilder:new()
        :with_items_provider(function()
            local current_word = vim.fn.expand('<cWORD>')
            return require('treetags').get_treetag_by_name(current_word)
        end)
        :with_formatter(utils.__format_entry)
        :with_prompt('cWORD')
        :new_table(),

    treetags_live = TelescopePickerBuilder:new()
        :with_items_provider(require('treetags').get_treetag_by_name_glob)
        :with_formatter(utils.__format_entry)
        :with_prompt('Treetags live')
        :new_dynamic(),

    treetags_files_all = TelescopePickerBuilder:new()
        :with_items_provider(function()
            return files_to_entries(require('treetags').get_all_parsed_files())
        end)
        :with_formatter(utils.__format_path_entry)
        :with_prompt('Treefiles')
        :new_table(),

    treetags_files_live = TelescopePickerBuilder:new()
        :with_items_provider(function(args)
            return files_to_entries(require('treetags').get_treetag_by_name_glob(args))
        end)
        :with_formatter(utils.__format_path_entry)
        :with_prompt('Treefiles live')
        :new_dynamic(),
}
