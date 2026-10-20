local M = {}

M.__get_database_uri = function()
    return vim.fs.joinpath(vim.fn.stdpath('state'), M.__get_db_file_name(vim.fn.getcwd()))
end

M.__get_db_file_name = function(work_dir)
    return vim.fs.normalize(work_dir):gsub('[:/\\]', '-'):gsub('^-', '') .. '.treetags.sql'
end

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
