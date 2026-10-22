local M = {}

M.__has_extension = function(file, extensions)
    if not extensions or #extensions == 0 then
        return true
    end

    local extension = vim.fs.ext(file)

    for _, ext in ipairs(extensions) do
        if extension == ext then
            return true
        end
    end

    return false
end

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
---@param extensions string[]
M.__get_changed_files = function(start_commit, end_commit, diff_filter, extensions)
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
        if (line ~= '') and M.__has_extension(line, extensions) then
            table.insert(files, line)
        end
    end

    return files
end

return M
