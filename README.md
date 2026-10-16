# treetags.nvim

`treetags.nvim` is a project-wide source-code index for Neovim. It extracts
definitions from Tree-sitter `locals` queries, stores them in a per-project
SQLite database, and exposes lookup APIs and
[fzf-lua](https://github.com/ibhagwan/fzf-lua) or
[Telescope](https://github.com/nvim-telescope/telescope.nvim) pickers.

The plugin is the successor to
[hopcsharp.nvim](https://github.com/leblocks/hopcsharp.nvim), generalized from
C# navigation to every language for which Neovim has a filetype, Tree-sitter
parser, and `locals` query.

## Requirements

- [fd](https://github.com/sharkdp/fd)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter), with
  parsers installed for the languages to index
- [sqlite.lua](https://github.com/kkharji/sqlite.lua)
- Optional: [fzf-lua](https://github.com/ibhagwan/fzf-lua) or
  [Telescope](https://github.com/nvim-telescope/telescope.nvim), with its
  dependencies, for picker integration

`sqlite.lua` must be able to load a native SQLite library. See its installation
instructions for platform-specific configuration.

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use({ 'leblocks/treetags.nvim', requires = { { 'kkharji/sqlite.lua' } } })
```

There is no setup function. Build the index after changing Neovim's working
directory to the project root:

```lua
require('treetags').init_database()
```

Initialization runs asynchronously. While it is running, other public
operations notify and return without querying the partially built index.
Re-running initialization replaces the index for the current working
directory.

To limit indexing by extension or exclude definition kinds:

```lua
require('treetags').init_database({
    extensions = { 'lua', 'js', 'cs' },
    kinds_filter = { 'var' },
    buffer_size = 1000,
})
```

- `extensions` is an allow-list without leading dots. An empty list scans all
  files returned by `fd`.
- `kinds_filter` is a deny-list of kinds derived from Tree-sitter
  `local.definition.*` captures. An empty list stores every kind.
- `buffer_size` controls how many definitions are accumulated before a batch
  insert. It defaults to `1000`.

## API

```lua
local treetags = require('treetags')

treetags.init_database(params)

local all = treetags.get_all_treetags()
local exact = treetags.get_treetag_by_name('MyFunction')
local matching = treetags.get_treetag_by_name_glob('Function')
```

Lookup methods return arrays of:

```lua
{
    name = 'MyFunction',
    kind = 'function',
    path = 'lua/example.lua',
    row = 10,
    column = 7,
    parser_name = 'lua',
}
```

`row` and `column` are one-based. Paths are normalized paths relative to the
working directory used to build the index.

For queries beyond the built-in exact and substring lookups, `get_db()` returns
the underlying `sqlite.lua` database object:

```lua
local db = require('treetags').get_db()
local methods = db:eval([[
    SELECT d.name, f.path, d.row, d.column
    FROM definitions d
    JOIN files f ON f.id = d.path_id
    WHERE d.kind = 'method'
    ORDER BY d.name
]])
```

The schema is an implementation detail and may change between releases.

## Pickers

### fzf-lua picker

The fzf integration provides all tags, exact lookup under the cursor, live
substring lookup, previews, split/tab navigation, multi-selection, and quickfix
export:

```lua
local pickers = require('treetags').get_pickers('fzf')

vim.keymap.set('n', '<leader>ta', pickers.treetags_all)
vim.keymap.set('n', '<leader>tw', pickers.treetags_cword)
vim.keymap.set('n', '<leader>tW', pickers.treetags_cWORD)
vim.keymap.set('n', '<leader>tl', pickers.treetags_live)
```

Inside a picker, the default action opens the selected definition. Use
`Ctrl-V`, `Ctrl-S`, or `Ctrl-T` for a vertical split, horizontal split, or tab.
Use `Alt-Q` to send selected definitions to the quickfix list.

### Telescope pickers

The Telescope integration provides the same four lookup functions, with file
previews and Telescope's configured sorting, mappings, and actions:

```lua
local pickers = require('treetags').get_pickers('telescope')

vim.keymap.set('n', '<leader>ta', pickers.treetags_all)
vim.keymap.set('n', '<leader>tw', pickers.treetags_cword)
vim.keymap.set('n', '<leader>tW', pickers.treetags_cWORD)
vim.keymap.set('n', '<leader>tl', pickers.treetags_live)
```

`treetags_all` lists every indexed definition. `treetags_cword` and
`treetags_cWORD` list exact matches for `<cword>` and `<cWORD>` under the cursor.
`treetags_live` queries the index as you type using case-sensitive SQLite GLOB
substring matching; an empty prompt shows no results.

Each Telescope picker accepts an optional options table:

```lua
vim.keymap.set('n', '<leader>ta', function()
    pickers.treetags_all({ layout_strategy = 'vertical' })
end)
```

Navigation, split/tab actions, multi-selection, and quickfix export use your
Telescope mappings rather than the fzf-specific mappings above.

## Headless indexing

Run indexing from the project directory and wait for the asynchronous job before
quitting:

```sh
nvim --headless -c "lua require('treetags').init_database()" \
  -c "lua vim.wait(600000, function() return not vim.g.treetags_processing end)" \
  -c "qall"
```

## AI usage disclosure

All documentation in this repo was prepared with assistance from AI.

## TODOs
* giff with example usage
