-- TODO refactor
local ok, _ = pcall(require, 'fzf-lua')
if not ok then
    error("treetags.pickers.fzf was required but 'fzf-lua' plugin was not found")
end

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

    return item.path, item.row, item.column, item.kind, item.parser_name
end

local get_picker = function(items_provider, formatter)
    local fzf = require('fzf-lua')
    local builtin_previewer = require('fzf-lua.previewer.builtin')
    local actions = require('fzf-lua.actions')

    -- store items in a closure
    -- so after db call and render
    -- we can retrieve info from here
    local items = {}

    -- see example here https://github.com/ibhagwan/fzf-lua/wiki/Advanced#preview-nvim-builtin
    local custom_previewer = builtin_previewer.buffer_or_file:extend()

    function custom_previewer:new(o, opts, fzf_win)
        custom_previewer.super.new(self, o, opts, fzf_win)
        setmetatable(self, custom_previewer)
        return self
    end

    function custom_previewer:parse_entry(entry_str)
        local path, line, col = parse_entry(entry_str, items)
        return { path = path, line = line, col = col }
    end

    local picker = function()
        fzf.fzf_exec(function(fzf_cb)
            coroutine.wrap(function()
                local co = coroutine.running()
                items = items_provider()

                if type(items) ~= 'table' then
                    items = {}
                end

                for i, entry in ipairs(items) do
                    fzf_cb(formatter(i, entry), function()
                        coroutine.resume(co)
                    end)
                    coroutine.yield()
                end
                fzf_cb()
            end)()
        end, {
            actions = {
                ['default'] = function(selected)
                    local path, row, column = parse_entry(selected[1], items)
                    actions.file_switch_or_edit({ path .. ':' .. row .. ':' .. column }, {})
                end,

                ['ctrl-v'] = function(selected)
                    local path, row, column = parse_entry(selected[1], items)
                    actions.file_vsplit({ path .. ':' .. row .. ':' .. column }, {})
                end,

                ['ctrl-s'] = function(selected)
                    local path, row, column = parse_entry(selected[1], items)
                    actions.file_split({ path .. ':' .. row .. ':' .. column }, {})
                end,

                ['ctrl-t'] = function(selected)
                    local path, row, column = parse_entry(selected[1], items)
                    actions.file_tabedit({ path .. ':' .. row .. ':' .. column }, {})
                end,

                ['alt-q'] = function(selected)
                    local qf = {}

                    for _, s in ipairs(selected) do
                        local path, row, column = parse_entry(s, items)
                        table.insert(qf, path .. ':' .. row .. ':' .. column)
                    end
                    -- TODO terrible hack is here
                    actions.file_sel_to_qf(qf, { __resume_key = 't' })
                end,
            },

            previewer = custom_previewer,
            fzf_opts = {
                ['--wrap'] = false,
                ['--multi'] = true,
            },
        })
    end

    return picker
end

return {
    treetags_all = get_picker(require('treetags').get_all_treetags, format_entry),
    treetags_cword = function()
        local current_word = vim.fn.expand('<cword>')
        local picker = get_picker(function() return require('treetags').get_treetag_by_name(current_word) end,
            format_entry)
        picker()
    end,
    treetags_cWORD = function()
        local current_word = vim.fn.expand('<cWORD>')
        local picker = get_picker(function() return require('treetags').get_treetag_by_name(current_word) end,
            format_entry)
        picker()
    end,
    treetags_live = function() end,
}
