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
colorscheme modus

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

" lspsaga
nnoremap <silent>K :Lspsaga hover_doc<CR>

" scroll down hover doc or scroll in definition preview
nnoremap <silent> <C-f> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>
" scroll up hover doc
nnoremap <silent> <C-b> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>

