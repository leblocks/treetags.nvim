-- AGENT TODO document module and all pickers modules

local M = {}

-- AGENT TODO documentation
M.fzf = function()
    local pickers = require('treetags.pickers.fzf')
    return {
        get_all_treetags = pickers.get_all_treetags,
        get_treetag_by_name = pickers.get_treetags_by_name,
    }
end

-- AGENT TODO documentation
M.telescope = function()
    -- TODO
end

return M
