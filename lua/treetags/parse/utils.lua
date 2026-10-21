
local M = {}

--- TODO test
M.__get_commit_hash = function()
    local output = vim.system({ 'git', 'rev-parse', 'HEAD' }, { text = true, cwd = vim.fn.getcwd() }):wait()

    if output.code == 0 then
        -- remove newlines from stdout
        return output.stdout:gsub('\r?\n$', '')
    end

    return nil
end

--- TODO test
--- TODO refactor?
--- AGENT TODO complete documentation
---@param start_commit string
---@param end_commit string
---@param diff_filter string
M.__get_changed_files = function(start_commit, end_commit, diff_filter)
    local arguments = {
        'git',
        '--no-pager',
        'diff',
        '--name-only',
    }

    if diff_filter then
        table.insert(arguments, '--diff-filter=' .. diff_filter)
    end

    table.insert(arguments, start_commit)
    table.insert(arguments, end_commit)

    local result = vim.system(arguments, { text = true, cwd = vim.fn.getcwd() }):wait()

    local files = {}

    for line in result.stdout:gmatch('([^\n]*)\n?') do
        if (line ~= '') and (line:match('cs$')) then
            table.insert(files, line)
        end
    end

    return files
end

return M
