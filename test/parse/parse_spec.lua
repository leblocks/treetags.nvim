local parse = require('treetags.parse')

describe('treetags.parse', function()
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
