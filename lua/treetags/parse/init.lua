local utils = require('treetags.main.utils')
local database = require('treetags.database')
local history = require('treetags.parse.history')
local parse_utils = require('treetags.parse.utils')

local M = {}

---Return changed source paths since the latest indexed commit, or all source paths if no history exists.
---@param diff_filter? string Git diff status letters to include.
---@param extensions? string[] Allowed file extensions without leading dots.
---@return string[]
M.__get_changed_source_files = function(diff_filter, extensions)
    local last_commit = history.__get_last_parsed_commit()

    -- no history, get all files
    if last_commit == '' then
        return M.__get_source_files(extensions)
    end

    -- get only changed ones
    return parse_utils.__get_changed_files(last_commit, '.', diff_filter, extensions)
end

M.__get_source_files = function(extensions)
    local command = { 'fd', '--type', 'file' }

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

    local filetype = vim.filetype.match({ filename = filename })

    if not filetype then
        return nil
    end

    return vim.treesitter.language.get_lang(filetype) or filetype
end

M.__parse_tree = function(file_path, callback, buffered_writer)
    local db = database.__get_db()
    local file, err = io.open(file_path, 'r')
    local normalized_path = vim.fs.normalize(file_path)

    if not file then
        utils.__log('error opening ' .. file_path .. ' error: ' .. err, nil, vim.log.levels.DEBUG)
        return
    end

    local _, id = db:insert('files', { path = normalized_path })

    local file_content = file:read('*a')
    local parser_name = M.__get_parser_name(file_path)

    if not parser_name then
        utils.__log('error finding parser name for file: ' .. file_path, nil, vim.log.levels.DEBUG)
        file:close()
        return
    end

    if not vim.treesitter.language.add(parser_name) then
        utils.__log('error loading parser for parser_name: ' .. parser_name .. ' file: ' .. file_path, nil, vim.log.levels.DEBUG)
        file:close()
        return
    end

    local parser = vim.treesitter.get_string_parser(file_content, parser_name, { error = false })

    if not parser then
        utils.__log('error finding parser for file: ' .. file_path .. ' parser_name: ' .. parser_name, nil, vim.log.levels.DEBUG)
        file:close()
        return
    end

    local query = vim.treesitter.query.get(parser_name, 'locals')

    if not query then
        utils.__log('error finding query for file: ' .. file_path .. ' parser_name: ' .. parser_name, nil, vim.log.levels.DEBUG)
        file:close()
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

M.__parse_file = function(file_path, filtered_kinds, buffered_writer)
    local should_skip_kinds_check = filtered_kinds == nil or #filtered_kinds == 0

    M.__parse_tree(file_path, function(tree, query, _, path_id, file_content, b_wr)
        local root = tree:root()
        local visited = {}
        for id, node, _, _ in query:iter_captures(root, file_content, 0, -1) do
            local capture_name = query.captures[id]
            if capture_name:match('^local.definition') then
                local kind = string.gsub(capture_name, 'local.definition.', '')

                if kind == 'local.definition' then
                    kind = 'definition'
                end

                if not should_skip_kinds_check then
                    for _, filtered in ipairs(filtered_kinds) do
                        if kind == filtered then
                            goto continue
                        end
                    end
                end

                local row, col = node:range()
                local name = vim.trim(vim.treesitter.get_node_text(node, file_content, nil))

                -- dedupe matches
                if visited[id .. name] then
                    goto continue
                else
                    visited[id .. name] = true
                end

                b_wr:add_to_buffer('definitions', {
                    path_id = path_id,
                    kind = kind,
                    name = name,
                    row = row + 1,
                    column = col + 1,
                })
            end
            ::continue::
        end
    end, buffered_writer)
end

return M
