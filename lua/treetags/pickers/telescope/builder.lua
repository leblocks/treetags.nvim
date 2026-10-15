---Builder for telescope pickers backed by treetags query functions.
---@class TelescopePickerBuilder
---@field items_provider function
---@field formatter function
---@field prompt string

local TelescopePickerBuilder = {}

function TelescopePickerBuilder:new()
    local obj = {
        prompt = '',
        formatter = nil,
        items_provider = nil,
    }

    self.__index = self
    setmetatable(obj, self)
    return obj
end

---@param provider function
---@return TelescopePickerBuilder
function TelescopePickerBuilder:with_items_provider(provider)
    self.items_provider = provider
    return self
end

---@param formatter function
---@return TelescopePickerBuilder
function TelescopePickerBuilder:with_formatter(formatter)
    self.formatter = formatter
    return self
end

---@param prompt string
---@return TelescopePickerBuilder
function TelescopePickerBuilder:with_prompt(prompt)
    self.prompt = prompt
    return self
end

function TelescopePickerBuilder:new_table()
    return function(opts)
        local pickers = require('telescope.pickers')
        local finders = require('telescope.finders')
        local conf = require('telescope.config').values
        opts = opts or {}
        pickers
            .new(opts, {
                prompt_title = self.prompt,
                finder = finders.new_table({
                    results = self.items_provider(),
                    entry_maker = function(entry)
                        return {
                            value = entry,
                            display = function(tbl)
                                return self.formatter(tbl.value)
                            end,
                            ordinal = entry.name,
                            path = entry.path,
                            lnum = entry.row,
                        }
                    end,
                }),
                previewer = conf.file_previewer(opts),
                sorter = conf.generic_sorter(opts),
            })
            :find()
    end
end

function TelescopePickerBuilder:new_dynamic()
    return function(opts)
        local pickers = require('telescope.pickers')
        local finders = require('telescope.finders')
        local conf = require('telescope.config').values
        opts = opts or {}
        pickers
            .new(opts, {
                prompt_title = self.prompt,
                finder = finders.new_dynamic({
                    fn = function(prompt)
                        if not prompt or prompt == '' then
                            return {}
                        end
                        return self.items_provider(prompt)
                    end,
                    entry_maker = function(entry)
                        return {
                            value = entry,
                            display = function(tbl)
                                return self.formatter(tbl.value)
                            end,
                            ordinal = entry.name,
                            path = entry.path,
                            lnum = entry.row,
                        }
                    end,
                }),
                previewer = conf.file_previewer(opts),
                sorter = conf.generic_sorter(opts),
            })
            :find()
    end
end

return TelescopePickerBuilder
