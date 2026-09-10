local database = require('treetags.database')

local M = {}

M.__get_source_files = function(extensions)

    local command = { 'fd', '--type', 'file', }

    if extensions ~= nil and #extensions > 0 then
        for _, ext in ipairs(extensions) do
            table.insert(command, '--extension')
            table.insert(command, ext)
        end
    end

    local result = vim.system(command, { text = true, cwd = vim.fn.getcwd() }):wait()

    local files = {}

    for line in result.stdout:gmatch('([^\n]*)\n?') do
        if line ~= '' then
            table.insert(files, vim.fs.normalize(line))
        end
    end

    return files
end

M.__get_filetype = function(extension)
    -- TODO
end

M.__parse_tree = function(file_path, callback, writer)
    local db = database.__get_db()
    local file, err = io.open(file_path, 'r')
    local normalized_path = vim.fs.normalize(file_path)
    local extension = vim.fs.ext(normalized_path, {})

    if not file then
        print('error opening ' .. file_path .. ' error: ' .. err)
        return
    end

    local _, id = db:insert('files', { path = normalized_path, extension = extension })

    local file_content = file:read('*a')
    local filetype = M.__get_filetype(extension)
    local parser = vim.treesitter.get_string_parser(file_content, filetype, { error = false })

    if not parser then
        return
    end

    local query = vim.treesitter.query.get(filetype, 'locals')

    if not query then
        return
    end

    parser:parse(false, function(_, trees)
        if not trees then
            return
        end

        parser:for_each_tree(function(tree, _)
            callback(tree, query, id, file_content, writer)
        end)
    end)

    file:close()
end

M.__parse_file = function(file_path, writer)
    M.__parse_tree(file_path, function(tree, path_id, file_content, wr)
        local root = tree:root()
        -- TODO parse here definitions
    end, writer)
end

return M
