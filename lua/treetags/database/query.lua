local M = {}

M.get_all_tags = function()
    return [[
        SELECT
            d.name,
            d.kind,
            f.path,
            d.row,
            d.column
        FROM definitions d
        JOIN files f ON f.id = d.path_id
        ORDER BY
            d.name ASC,
            f.path ASC
    ]]
end

M.get_tags_by_name = function(name)
    local query = [[
        SELECT
            d.name,
            d.kind,
            f.path,
            d.row,
            d.column
        FROM definitions d
        JOIN files f ON f.id = d.path_id
        WHERE d.name = '%s'
        ORDER BY
            d.name ASC,
            f.path ASC
    ]]

    return string.format(query, name)
end

M.get_tags_by_name_glob = function(name)
    local query = [[
        SELECT
            d.name,
            d.kind,
            f.path,
            d.row,
            d.column
        FROM definitions d
        JOIN files f ON f.id = d.path_id
        WHERE d.name GLOB '*%s*'
        ORDER BY
            d.name ASC,
            f.path ASC
    ]]

    return string.format(query, name)
end

return M
