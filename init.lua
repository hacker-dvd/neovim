vim.g.mapleader = " "

vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
vim.o.cursorline = true
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.hlsearch = false
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.clipboard = "unnamedplus"
vim.o.scrolloff = 4
-- vim.o.sidescrolloff = 4
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.showmode = true


-- keymap
vim.keymap.set("i", "jk", "<ESC>")

local map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_extend('force', { noremap = true, silent = true }, opts or {})
  vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

-- map('n', 'J', ':m .+1<CR>==')
-- map('n', 'K', ':m .-2<CR>==')
-- map('x', 'J', ":move '>+1<CR>gv-gv")
-- map('x', 'K', ":move '<-2<CR>gv-gv")

map('n', '<C-w>v', ':vsplit<CR>')
map('n', '<C-w>s', ':split<CR>')
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')
map('n', '<C-Left>', ':vertical resize -5<CR>')
map('n', '<C-Right>', ':vertical resize +5<CR>')
map('n', '<C-Up>', ':resize +5<CR>')
map('n', '<C-Down>', ':resize -5<CR>')


-- plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "folke/tokyonight.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- load the colorscheme here
      vim.cmd([[colorscheme tokyonight-moon]])
    end,
  },

  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {}
  },


  {
    'numToStr/Comment.nvim',
    opts = {},
    lazy = false,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function()
      map('n', '<C-b>', ':Neotree toggle<CR>')
      map('i', '<C-b>', '<Esc>:Neotree toggle<CR>')
    end
  },

  {
    'nvim-telescope/telescope.nvim', tag = '0.1.5',
    -- or                              , branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
      vim.keymap.set('n', '<leader>fo', builtin.oldfiles, {})
      vim.keymap.set('n', '<leader>/', function()
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })
    end
  },

  {
    "nvim-treesitter/nvim-treesitter",
    main = "nvim-treesitter.configs",
    build = ":TSUpdate",
    opts = {
      -- ensure_installed = "all",
      ensure_installed = {
        "c", "cpp", "python", "java", "json", "lua", "bash", "cmake", "css",
        "go", "html", "javascript", "rust", "sql", 
      },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    },
  },

  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},
  
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    lazy = true,
    config = false,
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {'hrsh7th/cmp-nvim-lsp'},
    }
  },

  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      {'L3MON4D3/LuaSnip'}
    },
  },
})

vim.api.nvim_set_hl(0, "Normal", {bg = "none"})
vim.api.nvim_set_hl(0, "NormalFloat", {bg = "none"})


vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"*.cppm"},
  callback = function()
    vim.bo.filetype = "cpp"
  end,
})


local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)


require('mason').setup({})
require('mason-lspconfig').setup({
  -- ensure_installed = {
  --   "lua_ls", "clangd"
  -- },
  handlers = {
    lsp_zero.default_setup,
    lua_ls = function()
      -- (Optional) configure lua language server
      local lua_opts = lsp_zero.nvim_lua_ls()
      require('lspconfig').lua_ls.setup(lua_opts)
    end,
  }
})

---
-- Autocompletion config
---
local cmp = require('cmp')
local cmp_action = lsp_zero.cmp_action()

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    -- `Enter` key to confirm completion
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- Ctrl+Space to trigger completion menu
    ['<C-Space>'] = cmp.mapping.complete(),

    -- Navigate between snippet placeholder
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),

    -- Scroll up and down in the completion documentation
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  })
})
