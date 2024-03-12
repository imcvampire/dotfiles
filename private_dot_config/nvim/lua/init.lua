local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
    vim.fn.system({ "git", "-C", lazypath, "checkout", "tags/stable" }) -- last stable release
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "neovim/nvim-lspconfig",
  { "Abstract-IDE/Abstract-cs", priority = 1000 },
  {
    'VonHeikemen/lsp-zero.nvim',
    dependencies = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},

      -- Snippets
      {'L3MON4D3/LuaSnip'},
      {'rafamadriz/friendly-snippets'},
    },
  },
  "glepnir/lspsaga.nvim",
  "ray-x/cmp-treesitter",
  "Yggdroot/indentLine",
  "editorconfig/editorconfig-vim",
  "ConradIrwin/vim-bracketed-paste",
  { "numToStr/Comment.nvim", config = function() require('Comment').setup() end },
  "ctrlpvim/ctrlp.vim",
  { "ms-jpq/chadtree", build = "python3 -m chadtree deps" },
  "tpope/vim-surround",
  "nvim-lualine/lualine.nvim",
  "w0rp/ale",
  "jiangmiao/auto-pairs",
  { "akinsho/bufferline.nvim", version = "v3.*", dependencies = {'nvim-tree/nvim-web-devicons'} },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  "svermeulen/vim-cutlass",
  { 'SmiteshP/nvim-navic', dependencies = {'neovim/nvim-lspconfig'} },
})

