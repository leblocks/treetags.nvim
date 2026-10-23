local parse = require('treetags.parse')
local utils = require('treetags.parse.utils')
local database = require('treetags.database')

local some_commit_hash = '49139a0'

describe('treetags.parse', function()
    it('__get_changed_source_files - no history ', function()
        local files = parse.__get_changed_source_files('', {})
        local all_files = parse.__get_source_files({})

        assert(#files > 0)
        assert(#files == #all_files)
        for i = 1, #files, 1 do
            assert(files[i] == all_files[i])
        end
    end)

    it('__get_changed_source_files - (no history) extensions propagated', function()
        local files = parse.__get_changed_source_files('', { 'md' })
        local all_files = parse.__get_source_files({ 'md' })

        assert(#files == 1)
        assert(#files == #all_files)
        assert(files[1] == 'README.md')
    end)

    it('__get_changed_source_files - (with history) diff_filter propagated', function()
        -- prepare history, ho ho ho
        database.__drop_db()
        local db = database.__get_db()
        db:insert('parse_history', { id = 1, commit_hash = some_commit_hash })

        local files = parse.__get_changed_source_files('a', {})
        local baseline = utils.__get_changed_files(some_commit_hash, '.', 'a', {})
        assert(#files == 2)
        assert(#files == #baseline)
        assert(files[1] == 'Makefile')
        assert(files[2] == 'scripts/minimal_init.lua')
    end)

    it('__get_changed_source_files - (with history) extensions propagated', function()
        -- prepare history, ho ho ho
        database.__drop_db()
        local db = database.__get_db()
        db:insert('parse_history', { id = 1, commit_hash = some_commit_hash })

        local files = parse.__get_changed_source_files('a', { 'lua' })
        local baseline = utils.__get_changed_files(some_commit_hash, '.', 'a', { 'lua' })
        assert(#files == 1)
        assert(#files == #baseline)
        assert(files[1] == 'scripts/minimal_init.lua')
    end)

    it('__get_source_files no arguments', function()
        local files = parse.__get_source_files()
        assert(#files > 0)
    end)

    it('__get_source_files nil', function()
        local files = parse.__get_source_files(nil)
        assert(#files > 0)
    end)

    it('__get_source_files empty', function()
        local files = parse.__get_source_files({})
        assert(#files > 0)
    end)

    it('__get_source_files lua', function()
        local files = parse.__get_source_files({ 'lua' })
        local lua_files_count = 0

        for _, file in ipairs(files) do
            if file:match('lua$') then
                lua_files_count = lua_files_count + 1
            end
        end

        assert(#files == lua_files_count)
    end)

    it('__get_source_files lua and md', function()
        local files = parse.__get_source_files({ 'lua', 'md' })
        local lua_files_count = 0

        for _, file in ipairs(files) do
            if file:match('lua$') or file:match('md$') then
                lua_files_count = lua_files_count + 1
            end
        end

        assert(#files == lua_files_count)
    end)

    it('__get_parser_name nil', function()
        local parser_name = parse.__get_parser_name(nil)
        assert(parser_name == nil)
    end)

    it('__get_parser_name empty', function()
        local parser_name = parse.__get_parser_name('')
        assert(parser_name == nil)
    end)

    it('__get_parser_name non existing extension', function()
        local parser_name = parse.__get_parser_name('someclass.kawabanga')
        assert(parser_name == nil)
    end)

    it('__get_parser_name parser name is different from filetype', function()
        assert(parse.__get_parser_name('someclass.cs') == 'c_sharp')
        assert(parse.__get_parser_name('someclass.ps1') == 'powershell')
    end)

    it('__get_parser_name parser name matches filetype', function()
        assert(parse.__get_parser_name('script.js') == 'javascript')
        assert(parse.__get_parser_name('script.ts') == 'typescript')
        assert(parse.__get_parser_name('script.py') == 'python')
    end)
end)
