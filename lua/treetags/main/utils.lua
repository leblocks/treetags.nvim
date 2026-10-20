local M = {}

M.__block_on_processing = function(callback)
    local message = 'init_database is running, try again later. '
        .. 'If init_database failed - restart or manually set vim.g.treetags_processing to false'

    if vim.g.treetags_processing then
        vim.notify(message)
        return
    end

    return callback()
end

M.__log = function(message, prefix)
    prefix = prefix or 'treetags: '
    vim.notify(M.__escape_ansi(prefix .. message), vim.log.levels.INFO)
end

---@param entries table to iterate on
---@param callback function will be called on each entry in entries via vim.schedule
M.__scheduled_iteration = function(entries, callback)
    if not entries then
        return
    end

    local should_stop = false

    local function stop()
        should_stop = true
    end

    local function iterate(i)
        if i > #entries then
            -- finished iteration
            return
        end

        callback(i, entries[i], entries, stop)

        if not should_stop then
            vim.schedule(function()
                iterate(i + 1)
            end)
        end
    end

    iterate(1)
end

M.__escape_ansi = function(string)
    local result, _ = string
        :gsub('%^%[%[%?%d+%a', '') -- ^[[?131232h
        :gsub('%^%[%[%d+%a', '') -- ^[[123131H
        :gsub('%^%[%[%a', '') -- ^[[D
        :gsub('\27%[%?%d+%a', '') -- \27[?131232h
        :gsub('\27%[%d+%a', '') -- \27[123131H
        :gsub('\27%[%a', '') -- \27[D

    return result
end

-- TODO this should be in a db utils
M.__safe_db_call = function(callback)
    local ok, result = pcall(callback)
    if ok then
        if type(result) ~= 'table' then
            return {}
        else
            return result
        end
    else
        return {}
    end
end

return M
