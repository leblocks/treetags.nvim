-- AGENT TODO document module and all pickers modules

local M = {}

-- AGENT TODO documentation
M.fzf = function()
    local pickers = require('treetags.pickers.fzf')
    return {
        get_all_treetags = pickers.get_all_treetags,
        get_treetag_by_word_under_cursor = pickers.get_treetag_by_word_under_cursor,
    }
end

-- AGENT TODO documentation
M.telescope = function()
    -- TODO
end

return M
