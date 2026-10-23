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

---Return Git-diff paths between two revisions, optionally filtered by status and extension.
---@param start_commit string Start revision accepted by `git diff`.
---@param end_commit string End revision accepted by `git diff`.
---@param diff_filter? string Git diff status letters to include, such as `D` for deleted files.
---@param extensions? string[] Allowed file extensions without leading dots; nil or empty allows all.
---@return string[] Changed paths relative to the current working directory.
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
