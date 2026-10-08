---fzf-lua picker integration for indexed treetags definitions.

local ok, _ = pcall(require, 'fzf-lua')
if not ok then
    error("treetags.pickers.fzf was required but 'fzf-lua' plugin was not found")
end

local FzfLuaPickerBuilder = require('treetags.pickers.fzf.builder')

local function format_entry(i, entry)
    return string.format('%-15s %-50s %-30s [%s]', '[' .. entry.kind .. ']', entry.name, vim.fs.basename(entry.path), i)
end

local function parse_entry(entry, items)
    local id = nil

    -- lookup id of the item in items
    for part in string.gmatch(entry, '%[(%d+)%]') do
        id = tonumber(part)
    end

    local item = items[id]

    return item.path, item.row, item.column, item.kind, item.name
end

return {
    treetags_all = FzfLuaPickerBuilder:new()
        :with_items_provider(require('treetags').get_all_treetags)
        :with_entry_parser(parse_entry)
        :with_formatter(format_entry)
        :with_prompt('Treetags > ')
        :build(),

    treetags_cword = function()
        local current_word = vim.fn.expand('<cword>')
        local picker = FzfLuaPickerBuilder:new()
            :with_items_provider(function()
                return require('treetags').get_treetag_by_name(current_word)
            end)
            :with_entry_parser(parse_entry)
            :with_formatter(format_entry)
            :with_prompt('Treetags [' .. current_word .. '] > ')
            :build()

        picker()
    end,

    treetags_cWORD = function()
        local current_word = vim.fn.expand('<cWORD>')
        local picker = FzfLuaPickerBuilder:new()
            :with_items_provider(function()
                return require('treetags').get_treetag_by_name(current_word)
            end)
            :with_entry_parser(parse_entry)
            :with_formatter(format_entry)
            :with_prompt('Treetags [' .. current_word .. '] > ')
            :build()
        picker()
    end,

    treetags_live = FzfLuaPickerBuilder:new()
        :with_items_provider(require('treetags').get_treetag_by_name_glob)
        :with_entry_parser(parse_entry)
        :with_formatter(format_entry)
        :with_prompt('Treetags live > ')
        :build_live(),
}
