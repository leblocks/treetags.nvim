--- TODO tests
---Builder for fzf-lua pickers backed by treetags query functions.
---@class FzfLuaPickerBuilder
---@field items Treetag[]
---@field items_provider function
---@field formatter function
---@field parser function
---@field prompt string
---@field exec_empty_query boolean
---@field fzf_opts table
---@field actions table
---@field query string

local FzfLuaPickerBuilder = {}

---Create an empty picker builder.
---@return FzfLuaPickerBuilder
function FzfLuaPickerBuilder:new()
    local obj = {
        items = {},
        items_provider = nil,
        formatter = nil,
        parser = nil,
        prompt = '',
        exec_empty_query = false,
        fzf_opts = {
            ['--wrap'] = false,
            ['--multi'] = true,
        },
        actions = nil,
        query = nil,
    }

    self.__index = self
    setmetatable(obj, self)

    return obj
end

---Set the function that supplies picker items.
---@param provider function
---@return FzfLuaPickerBuilder
function FzfLuaPickerBuilder:with_items_provider(provider)
    self.items_provider = provider
    return self
end

---Set the function that formats an indexed item for display.
---@param formatter function
---@return FzfLuaPickerBuilder
function FzfLuaPickerBuilder:with_formatter(formatter)
    self.formatter = formatter
    return self
end

---Set the function that maps a displayed entry back to its source location.
---@param parser function
---@return FzfLuaPickerBuilder
function FzfLuaPickerBuilder:with_entry_parser(parser)
    self.parser = parser
    return self
end

---Set the fzf prompt.
---@param prompt string
---@return FzfLuaPickerBuilder
function FzfLuaPickerBuilder:with_prompt(prompt)
    self.prompt = prompt
    return self
end

---Set the fzf actions.
---@param actions table
---@return FzfLuaPickerBuilder
function FzfLuaPickerBuilder:with_actions(actions)
    self.actions = actions
    return self
end

---Set the fzf query.
---@param query string
---@return FzfLuaPickerBuilder
function FzfLuaPickerBuilder:with_query(query)
    self.query = query
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
        ['default'] = function(selected, opts)
            if #selected == 0 then
                return
            end
            local path, row, column = self.parser(selected[1], self.items)
            actions.file_switch_or_edit({ path .. ':' .. row .. ':' .. column }, opts)
        end,

        ['ctrl-v'] = function(selected, opts)
            if #selected == 0 then
                return
            end
            local path, row, column = self.parser(selected[1], self.items)
            actions.file_vsplit({ path .. ':' .. row .. ':' .. column }, opts)
        end,

        ['ctrl-s'] = function(selected, opts)
            if #selected == 0 then
                return
            end
            local path, row, column = self.parser(selected[1], self.items)
            actions.file_split({ path .. ':' .. row .. ':' .. column }, opts)
        end,

        ['ctrl-t'] = function(selected, opts)
            if #selected == 0 then
                return
            end
            local path, row, column = self.parser(selected[1], self.items)
            actions.file_tabedit({ path .. ':' .. row .. ':' .. column }, opts)
        end,

        ['alt-q'] = function(selected, opts)
            local qf = {}

            for _, s in ipairs(selected) do
                local path, row, column, kind, name = self.parser(s, self.items)

                -- TODO no way for consumer to define qf formatting
                table.insert(
                    qf,
                    path .. ':' .. row .. ':' .. column .. ':' .. string.format('%-15s', kind) .. ' ' .. name
                )
            end
            if #selected == 0 then
                return
            end
            actions.file_sel_to_qf(qf, opts)
        end,
    }
end

---Build a picker that loads its items once when opened.
---@return fun()
function FzfLuaPickerBuilder:build()
    local fzf = require('fzf-lua')
    return function()
        fzf.fzf_exec(function(fzf_cb)
            coroutine.wrap(function()
                local co = coroutine.running()
                self.items = self.items_provider()

                if self.items == nil or type(self.items) ~= 'table' then
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
            actions = self.actions or self:get_actions(),
            previewer = self:get_previewer(),
            fzf_opts = self.fzf_opts,
            prompt = self.prompt,
        })
    end
end

function FzfLuaPickerBuilder:build_live()
    local fzf = require('fzf-lua')
    return function()
        fzf.fzf_live(function(args)
            return coroutine.wrap(function(fzf_cb)
                local co = coroutine.running()

                if not args[1] or args[1] == '' then
                    self.items = {}
                else
                    self.items = self.items_provider(args[1])
                end

                if self.items == nil or type(self.items) ~= 'table' then
                    self.items = {}
                end

                for i, entry in ipairs(self.items) do
                    fzf_cb(self.formatter(i, entry), function()
                        coroutine.resume(co)
                    end)
                    coroutine.yield()
                end
                fzf_cb()
            end)
        end, {
            actions = self.actions,
            previewer = self:get_previewer(),
            fzf_opts = self.fzf_opts,
            prompt = self.prompt,
            query = self.query,
            exec_empty_query = self.exec_empty_query,
        })
    end
end

-- TODO refactor \ cleanup
--- AGENT TODO documentation
function FzfLuaPickerBuilder:build_toggleable_live()
    return function()
        local live_search

        local fuzzy_actions = self:get_actions()

        local fuzzy_search = function(frozen_query)
            frozen_query = frozen_query or ''
            fuzzy_actions['ctrl-g'] = function(_, opts)
                live_search(frozen_query)
            end
            local picker = FzfLuaPickerBuilder:new()
                :with_items_provider(function()
                    -- since this one is nested builder we
                    -- have to update outer items as well for
                    -- actions to continue work
                    self.items = self.items_provider(frozen_query)
                    return self.items
                end)
                :with_entry_parser(self.parser)
                :with_formatter(self.formatter)
                :with_actions(fuzzy_actions)
                :with_prompt(self.prompt .. ' (' .. frozen_query .. ') ')
                :build()

            picker()
        end

        local live_actions = self:get_actions()

        live_search = function(initial_query)
            live_actions['ctrl-g'] = function(_, opts)
                fuzzy_search(opts.last_query)
            end
            local picker = FzfLuaPickerBuilder:new()
                :with_items_provider(function(arg)
                    -- since this one is nested builder we
                    -- have to update outer items as well for
                    -- actions to continue work
                    self.items = self.items_provider(arg)
                    return self.items
                end)
                :with_entry_parser(self.parser)
                :with_formatter(self.formatter)
                :with_actions(live_actions)
                :with_prompt(self.prompt)
                :with_query(initial_query)
                :build_live()

            picker()
        end

        live_search('')
    end
end

return FzfLuaPickerBuilder
