""
" All your vim are belong to us.
"
" Requirements:
"   vim-elastic
"     https://github.com/liquidz/vim-elastic
"   vim-yacd (OPTIONAL)
"     https://github.com/liquidz/vim-yacd
"     This is used for getting git repository name.
"

let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('vimspy')
let s:P = s:V.import('Prelude')
let s:Date = s:V.import('DateTime')
let s:Filepath = s:V.import('System.Filepath')
let s:Str = s:V.import('Data.String')
let s:_ = s:V.import('Underscore').import()

function! s:now() abort
  return s:Date.now().strftime('%Y-%m-%dT%H:%M:%S%z')
endfunction

function! s:addToDict(dict, kv) abort
  let a:dict[a:kv[0]] = a:kv[1]
  return a:dict
endfunction

" Escape string for Kibana.
function! s:escape(x) abort
  return s:P.is_string(a:x) ? s:Str.replace(a:x, '-', '_') : a:x
endfunction

function! s:out(data, ...) abort
  let index = 'vim'
  let type = (len(a:000) ==# 0 ? 'spy' : a:000[0])
  " escape values
  let data = s:_.chain(values(a:data))
      \.map(function('s:escape'))
      \.zip(keys(a:data))
      \.map(s:_.reverse)
      \.reduce({}, function('s:addToDict'))
      \.value()
  let data = extend(data, {'time': s:now()})
  call elastic#post(index, type, data)
endfunction

function! s:getBufferData(opt) abort
  let root = {}
  if exists('b:yacd_buf_root_dir')
    let root = {
        \ 'root_dir' : b:yacd_buf_root_dir,
        \ 'root_name': s:_.last(s:Filepath.split(b:yacd_buf_root_dir))
        \ }
  endif

  let opt = extend(a:opt, root)
  return extend(opt, {
      \ 'type'    : &filetype,
      \ 'format'  : &fileformat,
      \ 'encoding': &fileencoding,
      \ 'filename': expand('%:t'),
      \ 'path'    : expand('%:p')
      \ })
endfunction

function! s:isRecordable() abort
  return filereadable(expand('%:p'))
endfunction

""
" Record buffer information.
"
function! spy#recordBuffer(action) abort
  if s:isRecordable()
    let d = s:getBufferData({'action': a:action})
    call s:out(d)
  endif
endfunction

""
" Record any information.
"
function! spy#recordAny(action, ...) abort
  let data = (len(a:000) ==# 0 ? {} : a:000[0])
  call s:out(extend(data, {'action': a:action}))
endfunction

""
" Keep following buffer data in buffer variable.
"  - line count
"  - file size
"
function! spy#keepBufferData() abort
  if s:isRecordable()
    let b:spy_line_count = line('$')
    let b:spy_file_size = getfsize(expand('%'))
  endif
endfunction

""
" Record difference of buffer data that is kept in buffer variable.
"
function! spy#recordBufferDataDiff() abort
  if s:isRecordable()
    if exists('b:spy_line_count') && exists('b:spy_file_size')
      let line_diff = abs(line('$') - b:spy_line_count)
      let size_diff = abs(getfsize(expand('%')) - b:spy_file_size)
      if line_diff > 0 || size_diff > 0
        let data = s:getBufferData({
            \ 'line_diff': line_diff,
            \ 'size_diff': size_diff
            \ })
        call s:out(data, 'work')
      endif
    endif

    call spy#keepBufferData()
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
