"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
let g:python3_host_prog="/usr/bin/python3"
let g:python_host_prog="/usr/bin/python2"
set runtimepath+=~/.dein/repos/github.com/Shougo/dein.vim

call dein#begin('~/.dein')

" Let dein manage dein
" Required:
call dein#add('~/.dein/repos/github.com/Shougo/dein.vim')

call dein#add('neovim/nvim-lspconfig')
call dein#add('williamboman/nvim-lsp-installer')
call dein#add('glepnir/lspsaga.nvim')
call dein#add('hrsh7th/nvim-cmp')
call dein#add('hrsh7th/cmp-nvim-lsp')
call dein#add('hrsh7th/cmp-buffer')
call dein#add('hrsh7th/cmp-path')
call dein#add('hrsh7th/cmp-cmdline')
call dein#add('saadparwaiz1/cmp_luasnip')
call dein#add('L3MON4D3/LuaSnip')
call dein#add('Yggdroot/indentLine')
call dein#add('editorconfig/editorconfig-vim')
call dein#add('ConradIrwin/vim-bracketed-paste')
call dein#add('scrooloose/nerdcommenter')
call dein#add('jlanzarotta/bufexplorer')
call dein#add('ctrlpvim/ctrlp.vim')
call dein#add('ms-jpq/chadtree', {'rev': 'chad', 'build': 'python3 -m chadtree deps'})
call dein#add('tpope/vim-surround')
call dein#add('EdenEast/nightfox.nvim')
call dein#add('nvim-lualine/lualine.nvim')
call dein#add('kyazdani42/nvim-web-devicons')
call dein#add('w0rp/ale')
call dein#add('jiangmiao/auto-pairs')
call dein#add('nvim-treesitter/nvim-treesitter', {'build': ':TSUpdate'})

" Required:
call dein#end()

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif
"End dein Scripts-------------------------

"indentLine
let g:indentLine_char_list = ['|', '¦', '┆', '┊']
let g:indentLine_enabled = 1
let g:indentLine_concealcursor = "nv"

" CHADtree
let g:chadtree_settings = {
  \  'ignore.name_exact': [".DS_Store", ".directory", "thumbs.db", ".git", ".idea"]
  \ }
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | CHADopen
nnoremap <leader>v <cmd>CHADopen<cr>

" theme
set termguicolors            " 24 bit color
colorscheme duskfox

" ale
let g:ale_disable_lsp = 1

function! LinterStatus() abort
    let l:counts = ale#statusline#Count(bufnr(''))

    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors

    return l:counts.total == 0 ? 'OK' : printf(
    \   '%dW %dE',
    \   all_non_errors,
    \   all_errors
    \)
endfunction

" nerdcommenter
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" lspsaga
nnoremap <silent>K :Lspsaga hover_doc<CR>

" scroll down hover doc or scroll in definition preview
nnoremap <silent> <C-f> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>
" scroll up hover doc
nnoremap <silent> <C-b> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>

