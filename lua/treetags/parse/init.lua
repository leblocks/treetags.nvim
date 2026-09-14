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

M.__get_parser_name = function(filename)
    if not filename then
        return nil
    end

    local map = {
        cs = 'c_sharp',
    }

    local filetype = vim.filetype.match({ filename = filename })

    if map[filetype] then
        return map[filetype]
    end

    return filetype
end

M.__parse_tree = function(file_path, callback, buffered_writer)
    local db = database.__get_db()
    local file, err = io.open(file_path, 'r')
    local normalized_path = vim.fs.normalize(file_path)
    local extension = vim.fs.ext(normalized_path, {})

    if not file then
        print('error opening ' .. file_path .. ' error: ' .. err)
        return
    end

    local _, id = db:insert('files', { path = normalized_path })

    local file_content = file:read('*a')
    local parser_name = M.__get_parser_name(file_path)

    if not parser_name then
        print('error finding parser name for ' .. file_path)
        return
    end

    local parser = vim.treesitter.get_string_parser(file_content, parser_name, { error = false })

    if not parser then
        print('error finding parser for ' .. file_path .. ' name ' .. parser_name)
        return
    end

    local query = vim.treesitter.query.get(parser_name, 'locals')

    if not query then
        return
    end

    parser:parse(false, function(_, trees)
        if not trees then
            return
        end

        parser:for_each_tree(function(tree, _)
            callback(tree, query, parser_name, id, file_content, buffered_writer)
        end)
    end)

    file:close()
end

M.__parse_file = function(file_path, buffered_writer)
    M.__parse_tree(file_path, function(tree, query, parser_name, path_id, file_content, b_wr)
        local root = tree:root()
        for id, node in query:iter_captures(root, file_content, 0, -1) do
            local capture_name = query.captures[id]
            if capture_name:match("^local.definition") then
                -- TODO get kind!
                local row, col = node:range()
                local name = vim.trim(vim.treesitter.get_node_text(node, file_content, nil))
                b_wr:add_to_buffer('definitions', {
                    path_id = path_id,
                    kind = capture_name, -- TODO use numeric instead? to preserve space?
                    name = name,
                    parser_name = parser_name,
                    row = row + 1,
                    column = col + 1,
                    line_content = 'TODO',
                })
            end
        end
    end, buffered_writer)
end

return M
