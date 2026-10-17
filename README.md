# treetags.nvim

**Find definitions across your project, even without a language server.**

`treetags.nvim` builds a ctags-style definition index using Tree-sitter and
SQLite. Browse project symbols, search by name, or look up the word under your
cursor with [fzf-lua](https://github.com/ibhagwan/fzf-lua) or
[Telescope](https://github.com/nvim-telescope/telescope.nvim). No ctags executable
or tags file required.

[![treetags.nvim navigation demo](https://s15.gifyu.com/images/bQOcY.gif)](https://gifyu.com/image/bQOcY)

Use it to explore unfamiliar code, navigate projects without a configured LSP,
or search definitions across languages with one picker.

**This is name-based navigation, not semantic resolution.** A name can match
multiple definitions; treetags does not replace LSP references or rename.
Language coverage and definition kinds depend on the installed Tree-sitter
parsers and their `locals` queries.

[Requirements](#requirements) | [Installation](#-installation) |
[Quickstart](#-quickstart) | [Indexing](#-indexing) | [Pickers](#-pickers) |
[API](#api) | [Advanced usage](#advanced-usage) |
[Troubleshooting](#-troubleshooting)

## Requirements

- Neovim built with LuaJIT, with `vim.system`, `vim.fs.joinpath`, and the
  Tree-sitter APIs used by the plugin. CI tracks Neovim's stable release rather
  than testing a fixed minimum version.
- [fd](https://github.com/sharkdp/fd), available as `fd` on your `PATH`.
- A Tree-sitter parser and a `locals.scm` query for each language you want to
  index. [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
  provides parser installation and these queries, but is not a runtime
  requirement: treetags uses Neovim's built-in Tree-sitter APIs. Parsers and
  queries installed another way should also work, provided Neovim can load
  them, with queries available under `queries/<parser_name>/locals.scm` on
  `runtimepath`.
- [sqlite.lua](https://github.com/kkharji/sqlite.lua) and a loadable native
  SQLite library. Follow its
  [platform-specific installation instructions](https://github.com/kkharji/sqlite.lua#-installation).
- **Optional:** fzf-lua or Telescope, including the chosen picker's own
  dependencies. Neither is needed to use the Lua API.

## 📦 Installation

Add this plugin spec to your
[lazy.nvim](https://github.com/folke/lazy.nvim) configuration:

```lua
{
    'leblocks/treetags.nvim',
    lazy = false,
    dependencies = {
        'kkharji/sqlite.lua',
        'nvim-treesitter/nvim-treesitter', -- Omit if you provide parsers and locals.scm queries another way.
        'ibhagwan/fzf-lua', -- Optional; used in the quickstart below.
    },
}
```

There is **no `setup()` function**. Do not add `opts = {}` or `config = true`
to the treetags spec: lazy.nvim would try to call one. Installing the plugin
does not build an index.

Install parsers for the languages you want to index using nvim-treesitter or
your preferred method. Installing treetags does not install parsers for you.

If you prefer Telescope, replace the fzf-lua dependency with:

```lua
{
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
}
```

Meet the chosen picker's upstream Neovim and external-tool requirements.
In particular, fzf-lua needs an `fzf` or `skim` executable.

## 🚀 Quickstart

Start Neovim in your project root. Before the first treetags API call, use
`:pwd` to confirm the working directory or `:cd` to change it.

Build the index:

```vim
:lua require('treetags').init_database()
```

Wait for the `finished processing files` notification, then open a picker:

```vim
:lua require('treetags').get_pickers('fzf').treetags_all()
```

Add these suggested mappings to your Lua configuration after the plugins load.
Use `'telescope'` instead of `'fzf'` if you installed Telescope:

```lua
local pickers = require('treetags').get_pickers('fzf')

vim.keymap.set('n', '<leader>ta', pickers.treetags_all, { desc = 'Treetags: all definitions' })
vim.keymap.set('n', '<leader>tw', pickers.treetags_cword, { desc = 'Treetags: word under cursor' })
vim.keymap.set('n', '<leader>tW', pickers.treetags_cWORD, { desc = 'Treetags: WORD under cursor' })
vim.keymap.set('n', '<leader>tl', pickers.treetags_live, { desc = 'Treetags: live search' })
```

Run `init_database()` again when you want to refresh results after source
changes. Indexing is manual; the plugin does not watch files or update on save.

For in-editor documentation, see `:help treetags.txt`. Run
`:checkhealth treetags` to check fd, SQLite, and optional picker availability.

## ⚙️ Indexing

File discovery runs `fd --type file` in Neovim's current working directory.
The normal fd hidden-file and ignore rules apply. Files need a recognized
filetype, an installed parser, and a `locals` query to produce definitions.
The plugin does not install missing parsers.

Calling `init_database()` clears the active index and schedules parsing work.
While indexing, guarded public operations notify and return without querying;
they do not wait or queue a retry.

### Options

These are the defaults:

```lua
require('treetags').init_database({
    extensions = {},
    kinds_filter = {},
    buffer_size = 1000,
})
```

| Option | Meaning |
| --- | --- |
| `extensions` | Allow-list of file extensions, without leading dots. Empty means consider every file returned by fd. |
| `kinds_filter` | Deny-list of definition kinds. Empty means store every captured kind. |
| `buffer_size` | Number of definitions accumulated before a batch insert. |

For example, index only Lua, JavaScript, and C# files, excluding `var` captures:

```lua
require('treetags').init_database({
    extensions = { 'lua', 'js', 'cs' },
    kinds_filter = { 'var' },
})
```

Kinds come from Tree-sitter capture names: `local.definition.function` becomes
`function`, while bare `local.definition` becomes `definition`. Available kinds
vary by language and query; they are not a fixed set of LSP symbol kinds.

### Project scope and persistence

The database filename is derived from the working directory when the SQLite
connection is first opened. Databases are stored under `stdpath('state')` and
can be reused across Neovim sessions.

**Keep the same project working directory for indexing and navigation.**
The connection is cached for the session, so changing `:cd` does not switch
an already opened database. Open a new Neovim session for a different project.
Stored paths are relative to the project directory.

## 🔎 Pickers

Both integrations expose the same functions through
`require('treetags').get_pickers('fzf')` or `get_pickers('telescope')`.
Only the requested integration is loaded.

| Function | Results |
| --- | --- |
| `treetags_all()` | Every indexed definition, filtered interactively by the picker. |
| `treetags_cword()` | Exact name matches for `<cword>` under the cursor. |
| `treetags_cWORD()` | Exact name matches for `<cWORD>` under the cursor. |
| `treetags_live()` | Database lookup as the prompt changes; an empty prompt shows no results. |

Live lookup uses **case-sensitive SQLite GLOB** matching with `*` around the
prompt. GLOB metacharacters such as `*`, `?`, and bracket expressions retain
their pattern meaning. This is not a literal substring search or a fuzzy
database search.

### fzf-lua

The integration provides file previews, multi-selection, and these actions:

| Key | Action |
| --- | --- |
| `Enter` | Open the selected definition. |
| `Ctrl-V` | Open in a vertical split. |
| `Ctrl-S` | Open in a horizontal split. |
| `Ctrl-T` | Open in a new tab. |
| `Alt-Q` | Send selected definitions to the quickfix list. |

### Telescope

The integration uses Telescope's configured file previewer, generic sorter,
mappings, and actions. Split/tab navigation, multi-selection, and quickfix
export follow your Telescope configuration, not the fzf-specific bindings above.
This is a direct Lua integration; no `load_extension('treetags')` call is needed.

Each picker accepts an optional Telescope options table:

```lua
local pickers = require('treetags').get_pickers('telescope')

vim.keymap.set('n', '<leader>ta', function()
    pickers.treetags_all({ layout_strategy = 'vertical' })
end, { desc = 'Treetags: all definitions' })
```

## API

All public functions are available through `require('treetags')`:

| Function | Purpose |
| --- | --- |
| `init_database(params)` | Clear and asynchronously rebuild the index; `params` is optional. |
| `get_all_treetags()` | Return all indexed definitions. |
| `get_treetag_by_name(name)` | Return exact name matches. |
| `get_treetag_by_name_glob(name)` | Return case-sensitive GLOB matches using `*name*`. |
| `get_pickers(type)` | Return the `'fzf'` or `'telescope'` integration. |
| `get_db()` | Return the underlying sqlite.lua database object. |

After indexing finishes, lookup functions return arrays of records shaped like:

```lua
{
    name = 'MyFunction',
    kind = 'function',
    path = 'lua/example.lua',
    row = 10,
    column = 7,
}
```

`row` and `column` are one-based. Paths are normalized relative paths.
Guarded calls return `nil` instead of results while indexing is in progress.

## Advanced usage

### Custom SQL

Use `get_db()` for queries beyond the built-in lookups:

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

Run this only after indexing finishes. The database schema is an implementation
detail and may change between releases.

### Headless indexing

Run from the project directory with a Neovim configuration that loads treetags
and its dependencies. Wait for scheduled work before quitting:

```sh
nvim --headless -c "lua require('treetags').init_database()" -c "lua if not vim.wait(600000, function() return not vim.g.treetags_processing end) then vim.cmd('cquit') end" -c "qall"
```

The command exits with an error if the wait times out after ten minutes.
The processing flag indicates completion, not that every file was indexed;
inspect notifications for missing parsers or queries.

## 🩺 Troubleshooting

Start with `:checkhealth treetags` and `:messages`.

| Symptom | What to check |
| --- | --- |
| fd cannot be found | Ensure the executable is named `fd` and is on Neovim's `PATH`. Some distributions install it as `fdfind`. |
| SQLite fails to load | Install the native SQLite library and follow sqlite.lua's platform instructions. On Windows, set `vim.g.sqlite_clib_path` to the SQLite DLL before loading treetags. |
| Files or languages are missing | Check `:pwd`, fd ignore rules, `extensions`, and `kinds_filter`. Install the language parser and confirm a `locals` query exists; syntax highlighting alone does not establish this. |
| Results are stale | Save source changes and rebuild with `init_database()`. There is no incremental indexing. |
| Navigation opens the wrong path | Keep the working directory at the indexed project root. Restart Neovim when switching projects; the database connection is cached. |
| Live search has no results | Enter a nonempty prompt, check identifier casing, and remember that GLOB metacharacters are active. |
| Operations keep reporting that indexing is running | Inspect `:messages` for failures and confirm fd finds files. An empty file list can leave the processing flag set. Resolve the cause and restart Neovim before retrying. |

The health check does not verify per-language parser or `locals` query coverage.

## Project history and roadmap

`treetags.nvim` is the successor to
[hopcsharp.nvim](https://github.com/leblocks/hopcsharp.nvim), generalized from
C# navigation to languages with suitable Tree-sitter parsers and queries.

Planned, not currently implemented: incremental indexing and additional picker
integrations.

## License

See [LICENSE](LICENSE) for the GNU General Public License v3.0.

## AI usage disclosure

All documentation in this repo was prepared with assistance from AI.
