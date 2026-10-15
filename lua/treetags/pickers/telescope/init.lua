---telescope picker integration for indexed treetags definitions.
local ok, _ = pcall(require, 'telescope')
if not ok then
    error("treetags.pickers.telescope was required but 'telescope' plugin was not found")
end

local utils = require('treetags.pickers.utils')

local TelescopePickerBuilder = require('treetags.pickers.telescope.builder')

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
}
