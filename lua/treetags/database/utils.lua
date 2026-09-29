local M = {}

M.__get_database_uri = function()
    return vim.fs.joinpath(vim.fn.stdpath('state'), M.__get_db_file_name(vim.fn.getcwd()))
end

M.__get_db_file_name = function(work_dir)
    return vim.fs.normalize(work_dir):gsub('[:/\\]', '-'):gsub('^-', '') .. '.treetags.sql'
end

return M
