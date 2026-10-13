---TODO builder
---TODO tests for builder
---telescope picker integration for indexed treetags definitions.
local ok, _ = pcall(require, 'telescope')
if not ok then
    error("treetags.pickers.telescope was required but 'telescope' plugin was not found")
end

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')

local function format_entry(entry)
    return string.format('%-15s %-50s %-30s', '[' .. entry.kind .. ']', entry.name, vim.fs.basename(entry.path))
end

return {
    treetags_all = function(opts)
        local conf = require("telescope.config").values
        opts = opts or {}
        pickers.new(opts, {
            prompt_title = "colors",
            finder = finders.new_table({
                results = require('treetags').get_all_treetags(),
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = function(tbl) return format_entry(tbl.value) end,
                        ordinal = entry.name,
                        path = entry.path,
                        lnum = entry.row,
                    }
                end,
            }),
            previewer = conf.file_previewer(opts),
            sorter = conf.generic_sorter(opts),
        }):find()
    end,

    treetags_cword = function(opts)
        local conf = require("telescope.config").values
        local current_word = vim.fn.expand('<cword>')
        print(current_word)
        opts = opts or {}
        pickers.new(opts, {
            prompt_title = current_word,
            finder = finders.new_table({
                results = require('treetags').get_treetag_by_name(current_word),
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = function(tbl) return format_entry(tbl.value) end,
                        ordinal = entry.name,
                        path = entry.path,
                        lnum = entry.row,
                    }
                end
            }),
            previewer = conf.file_previewer(opts),
            sorter = conf.generic_sorter(opts),
        }):find()
    end,

    treetags_cWORD = function(opts)
        local conf = require("telescope.config").values
        local current_word = vim.fn.expand('<cWORD>')
        opts = opts or {}
        pickers.new(opts, {
            prompt_title = current_word,
            finder = finders.new_table({
                results = require('treetags').get_treetag_by_name(current_word),
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = function(tbl) return format_entry(tbl.value) end,
                        ordinal = entry.name,
                        path = entry.path,
                        lnum = entry.row,
                    }
                end
            }),
            previewer = conf.file_previewer(opts),
            sorter = conf.generic_sorter(opts),
        }):find()
    end,

    treetags_live = function(opts)
        local conf = require("telescope.config").values
        opts = opts or {}

        local finder = finders.new_dynamic({
            fn = function(prompt)
                if not prompt or prompt == '' then
                    return {}
                end

                return require('treetags').get_treetag_by_name_glob(prompt)
            end,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = function(tbl) return format_entry(tbl.value) end,
                    ordinal = entry.name,
                    path = entry.path,
                    lnum = entry.row,
                }
            end
        })

        pickers.new(opts, {
            prompt_title = 'treetags live',
            finder = finder,
            previewer = conf.file_previewer(opts),
            sorter = conf.generic_sorter(opts),
        }):find()
    end,
}
