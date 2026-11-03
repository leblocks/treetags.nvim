local FzfLuaPickerBuilder = require('treetags.pickers.fzf.builder')

-- TODO can build and build_live be tested?
describe('treetags.pickers.fzf.builder', function()
    it('FzfLuaPickerBuilder - with_items_provider', function()
        local builder = FzfLuaPickerBuilder:new():with_items_provider(function()
            return { 'one' }
        end)

        assert('one' == builder.items_provider()[1])
    end)

    it('FzfLuaPickerBuilder - with_formatter', function()
        local builder = FzfLuaPickerBuilder:new():with_formatter(function()
            return { 'one' }
        end)

        assert('one' == builder.formatter()[1])
    end)

    it('FzfLuaPickerBuilder - with_entry_parser', function()
        local builder = FzfLuaPickerBuilder:new():with_entry_parser(function()
            return { 'one' }
        end)

        assert('one' == builder.parser()[1])
    end)

    it('FzfLuaPickerBuilder - with_prompt', function()
        local builder = FzfLuaPickerBuilder:new():with_prompt('prompt')
        assert('prompt' == builder.prompt)
    end)

    it('FzfLuaPickerBuilder - with_actions', function()
        local builder = FzfLuaPickerBuilder:new():with_actions({ 'one' })
        assert('one' == builder.actions[1])
    end)

    it('FzfLuaPickerBuilder - with_query', function()
        local builder = FzfLuaPickerBuilder:new():with_query('query')
        assert('query' == builder.query)
    end)
end)
