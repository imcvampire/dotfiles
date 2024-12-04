local cmp = require'cmp'

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

local saga = require 'lspsaga'

saga.setup({})

require('lualine').setup {
  options = {
    theme = 'auto'
  },
  extensions = {'chadtree', 'fzf'},
  sections = {
    lualine_b = {
      'branch',
      'diff',
      {
        'diagnostics',

        sources = { 'nvim_diagnostic', 'nvim_lsp', 'ale' },
      }
    }
  }
}

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

require("bufferline").setup{}

local navic = require("nvim-navic")
navic.setup {
    lsp = {
        auto_attach = true,
    },
}

