---@class FzfLuaPickerBuilder AGENT TODO finish description
---@field with_items_provider function
---@field with_formatter function
---@field with_entry_parser function
---@field build function
---@field new function


local FzfLuaPickerBuilder = {}

-- AGENT TODO finish description
---@return FzfLuaPickerBuilder
function FzfLuaPickerBuilder:new()
    local obj = {
        items = {},
        items_provider = nil,
        formatter = nil,
        parser = nil,
    }

    self.__index = self
    setmetatable(obj, self)

    return obj
end

-- AGENT TODO finish description
---@return FzfLuaPickerBuilder
function FzfLuaPickerBuilder:with_items_provider(provider)
    self.items_provider = provider
    return self
end

-- AGENT TODO finish description
---@return FzfLuaPickerBuilder
function FzfLuaPickerBuilder:with_formatter(formatter)
    self.formatter = formatter
    return self
end

-- AGENT TODO finish description
---@return FzfLuaPickerBuilder
function FzfLuaPickerBuilder:with_entry_parser(parser)
    self.parser = parser
    return self
end

function FzfLuaPickerBuilder:get_previewer()
    local builtin_previewer = require('fzf-lua.previewer.builtin')
    local this = self

    -- see example here https://github.com/ibhagwan/fzf-lua/wiki/Advanced#preview-nvim-builtin
    local custom_previewer = builtin_previewer.buffer_or_file:extend()

    function custom_previewer:new(o, opts, fzf_win)
        custom_previewer.super.new(self, o, opts, fzf_win)
        setmetatable(self, custom_previewer)
        return self
    end

    function custom_previewer:parse_entry(entry_str)
        local path, line, col = this.parser(entry_str, this.items)
        return { path = path, line = line, col = col }
    end

    return custom_previewer
end

function FzfLuaPickerBuilder:get_actions()
    local actions = require('fzf-lua.actions')
    return {
        ['default'] = function(selected)
            local path, row, column = self.parser(selected[1], self.items)
            actions.file_switch_or_edit({ path .. ':' .. row .. ':' .. column }, {})
        end,

        ['ctrl-v'] = function(selected)
            local path, row, column = self.parser(selected[1], self.items)
            actions.file_vsplit({ path .. ':' .. row .. ':' .. column }, {})
        end,

        ['ctrl-s'] = function(selected)
            local path, row, column = self.parser(selected[1], self.items)
            actions.file_split({ path .. ':' .. row .. ':' .. column }, {})
        end,

        ['ctrl-t'] = function(selected)
            local path, row, column = self.parser(selected[1], self.items)
            actions.file_tabedit({ path .. ':' .. row .. ':' .. column }, {})
        end,

        ['alt-q'] = function(selected)
            local qf = {}

            for _, s in ipairs(selected) do
                local path, row, column = self.parser(s, self.items)
                table.insert(qf, path .. ':' .. row .. ':' .. column)
            end
            -- TODO terrible hack is here
            actions.file_sel_to_qf(qf, { __resume_key = 't' })
        end,
    }
end

-- AGENT TODO finish description
function FzfLuaPickerBuilder:build()
    local fzf = require('fzf-lua')
    return function()
        fzf.fzf_exec(function(fzf_cb)
            coroutine.wrap(function()
                local co = coroutine.running()
                self.items = self.items_provider()

                if type(self.items) ~= 'table' then
                    self.items = {}
                end

                for i, entry in ipairs(self.items) do
                    fzf_cb(self.formatter(i, entry), function()
                        coroutine.resume(co)
                    end)
                    coroutine.yield()
                end
                fzf_cb()
            end)()
        end, {
            actions = self:get_actions(),
            previewer = self:get_previewer(),
            fzf_opts = {
                ['--wrap'] = false,
                ['--multi'] = true,
            },
        })
    end
end

return FzfLuaPickerBuilder
