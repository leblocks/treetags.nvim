local TelescopePickerBuilder = require('treetags.pickers.telescope.builder')

describe('treetags.pickers.telescope.builder', function()
    it('TelescopePickerBuilder - with_items_provider', function()
        local builder = TelescopePickerBuilder:new():with_items_provider(function()
            return { 'one' }
        end)
        assert('one' == builder.items_provider()[1])
    end)

    it('TelescopePickerBuilder - with_formatter', function()
        local builder = TelescopePickerBuilder:new():with_formatter(function()
            return { 'one' }
        end)
        assert('one' == builder.formatter()[1])
    end)

    it('TelescopePickerBuilder - with_prompt', function()
        local builder = TelescopePickerBuilder:new():with_prompt('prompt')
        assert('prompt' == builder.prompt)
    end)
end)
