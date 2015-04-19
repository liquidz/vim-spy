if exists('g:loaded_vim_spy')
  finish
endif
let g:loaded_vim_spy = 1

function! s:start() abort
  augroup VimSpy
    autocmd!
    autocmd VimEnter    * call spy#recordAny('vim_enter')
    autocmd VimLeave    * call spy#recordAny('vim_leave')
    autocmd BufNewFile  * call spy#recordAny('buf_newFile')
    autocmd BufRead     * call spy#recordBuffer('buf_read')
    autocmd BufWrite    * call spy#recordBuffer('buf_write')
    autocmd WinEnter    * call spy#recordBuffer('win_enter')
    autocmd WinLeave    * call spy#recordBuffer('win_leave')
    autocmd TabEnter    * call spy#recordBuffer('tab_enter')
    autocmd TabLeave    * call spy#recordBuffer('tab_leave')
    autocmd CmdwinEnter * call spy#recordAny('cmdwin_enter')
    autocmd CmdwinLeave * call spy#recordAny('cmdwin_leave')
    autocmd SwapExists  * call spy#recordAny('swap_exists')
    autocmd CursorHold  * call spy#recordAny('cursor_hold')
    autocmd CursorHoldI * call spy#recordAny('cursor_hold_i')

    " for recording diff of lines or size
    autocmd BufRead  * call spy#keepBufferData()
    autocmd BufWrite * call spy#recordBufferDataDiff()
  augroup END
endfunction

function! s:stop() abort
  augroup VimSpy
    autocmd!
  augroup END
endfunction

""
" Start to spy your vim.
"
command! StartSpy call s:start()

""
" Stop to spy your vim.
"
command! StopSpy  call s:stop()

""
" @var
" Set 1 to start spying vim automatically.
"
if exists('g:vim_spy_auto_start') && g:vim_spy_auto_start ==# 1
  call s:start()
endif
