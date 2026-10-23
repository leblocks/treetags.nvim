local os = require('os')

local M = {}

local function check_git()
    vim.health.start('git')
    local exit_code = os.execute('git --help')
    if exit_code == 0 then
        vim.health.ok('git is on PATH')
    else
        vim.health.error('git is not on PATH')
    end
end

local function check_fd()
    vim.health.start('fd')
    local exit_code = os.execute('fd --help')
    if exit_code == 0 then
        vim.health.ok('fd is on PATH')
    else
        vim.health.error('fd is not on PATH')
    end
end

local function check_sqlite_installation()
    vim.health.start('sqlite')
    local ok, _ = pcall(require, 'sqlite')
    if ok then
        vim.health.ok('sqlite plugin is installed')
    else
        vim.health.error('sqlite plugin is not found')
    end

    -- check windows specific config for sqlite
    if vim.loop.os_uname().sysname == 'Windows_NT' then
        local dll = io.open(vim.g.sqlite_clib_path, 'r')
        if dll ~= nil then
            vim.health.ok('sqlite_clib_path is set and points to a file: ' .. vim.g.sqlite_clib_path)
            io.close(dll)
        else
            vim.health.error('sqlite_clib_path is not set')
        end
    end
end

local function check_fzf_lua_optional()
    vim.health.start('fzf-lua [optional]')
    local ok, _ = pcall(require, 'fzf-lua')
    if ok then
        vim.health.ok('fzf-lua is installed')
    else
        vim.health.error('fzf-lua is not installed')
    end
end

local function check_telescope_optional()
    vim.health.start('telescope [optional]')
    local ok, _ = pcall(require, 'telescope')
    if ok then
        vim.health.ok('telescope is installed')
    else
        vim.health.error('telescope is not installed')
    end
end

M.check = function()
    check_fd()
    check_git()
    check_sqlite_installation()
    check_fzf_lua_optional()
    check_telescope_optional()
end

return M
