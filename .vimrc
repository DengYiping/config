" File              : .vimrc
" Author            : Yiping Deng <y.deng@jacobs-university.de>
" Date              : 26.05.2018
" Last Modified Date: 26.05.2018
" Last Modified By  : Yiping Deng <y.deng@jacobs-university.de>
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
" --------------------- start of plugin list
"A tool for git
Plugin 'tpope/vim-fugitive'
" Coloring
Plugin 'altercation/vim-colors-solarized'
" Status Bar plugin
Plugin 'bling/vim-airline'
" Automatically add header
Plugin 'alpertuna/vim-header'
" deleted plug-ins ----------------
" view git tree
" Plugin 'junegunn/gv.vim'
" Typescript Support
Plugin 'leafgarland/typescript-vim'
" --------------------- end of plugin line




" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line


" personal settings

" syntax highlight
syntax enable
set background=dark
let g:solarized_termcolors=256
colorscheme solarized


" tab control
if has("autocmd")
	filetype plugin indent on
	" Use actual tab chars in Makefiles.
	autocmd FileType make set tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab
endif

" For everything else, use a tab width of 4 space chars.
set tabstop=4       " The width of a TAB is set to 4.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 4.
set shiftwidth=4    " Indents will have a width of 4.
set softtabstop=4   " Sets the number of columns for a TAB.
set expandtab       " Expand TABs to spaces.

" show property
set cursorline                  " underline the current line, for quick orientation
set showmode                    " always show what mode we're currently editing in
set nowrap
set shiftround
set number                      " always show line numbers
set showmatch                   " set show matching parenthesis
set ignorecase                  " ignore case when searching
set smartcase                   " ignore case if search pattern is all lowercase,

" search
set hlsearch                    " highlight search terms
set incsearch                   " show search matches as you type

" old shit
set backspace=2 " make backspace work like most other programs
set nobackup                    " do not keep backup files, it's 70's style cluttering
set noswapfile                  " do not write annoying intermediate swap files,

" command list
set wildmenu                    " make tab completion for files/buffers act like bash
set wildmode=list:full          " show a list when pressing tab and complete
set wildignore=*.swp,*.bak,*.pyc,*.class
set title                       " change the terminal's title
set visualbell                  " don't beep
set noerrorbells                " don't beep
set showcmd                     " show (partial) command in the last line of the screen
                                " this also shows visual selection info

" remove trailing white space by pressing F5
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

" Compile and run
map <F6> :call CompileRunGcc()<CR>
func! CompileRunGcc()
    exec "w"
    if &filetype == 'c'
        exec "!gcc % -o %<"
        exec "!time ./%<"
    elseif &filetype == 'cpp'
        exec "!g++ -o %< -std=c++11 %"
        exec "!time ./%<"
    elseif &filetype == 'sh'
        exec "!time bash %"
    elseif &filetype == 'python'
        exec "!time python %"
    elseif &filetype == 'asm'
        exec "!gcc % -o %<"
        exec "!time ./%<"
    endif
endfunc

map <F7> :call CompileRemove()<CR>
func! CompileRemove()
    if &filetype == 'c'
        exec "!rm ./%<"
    elseif &filetype == 'cpp'
        exec "!rm ./%<"
    elseif &filetype == 'asm'
        exec "!rm ./%<"
    elseif &filetype == 'tex'
        exec "!latexmk -c"
    endif
endfunc

" Vim plugin for adding C/C++ header guards.

if exists("loaded_headerguard")
    finish
endif
let loaded_headerguard = 1

if !exists('g:headerguard_use_cpp_comments')
    let g:headerguard_use_cpp_comments = 0
endif

" Save 'cpoptions' and set Vim default to enable line continuations.
let s:save_cpoptions = &cpoptions
set cpoptions&vim

" Search list of scopes for function named funcName, returning first-found.
function! s:ResolveFunc(funcName, scopes)
    for scope in a:scopes
        let scopedFuncName = scope . ':' . a:funcName
        if exists('*' . scopedFuncName)
            return function(scopedFuncName)
        endif
    endfor
    throw "Unknown function " . a:funcName
endfunction

" Return reference to Headerguard function having given suffix.
function! s:Func(funcSuffix)
    return s:ResolveFunc('Headerguard' . a:funcSuffix, ['b', 'g', 's'])
endfunction

function! s:HeaderguardName()
    return toupper(expand('%:t:gs/[^0-9a-zA-Z_]/_/g'))
endfunction

function! s:HeaderguardLine1()
    return "#ifndef " . s:Func('Name')()
endfunction

function! s:HeaderguardLine2()
    return "#define " . s:Func('Name')()
endfunction

function! s:HeaderguardLine3()
    if g:headerguard_use_cpp_comments
        return "#endif // " . s:Func('Name')()
    else
        return "#endif /* " . s:Func('Name')() . " */"
    endif
endfunction

function! g:HeaderguardAdd()
    " Test for empty filename.
    if expand('%') == ""
        echoerr "Empty filename (save file and try again)."
        return
    endif
    " Locate first, second, and last pre-processor directives.
    call cursor(1, 1)
    let poundLine1 = search('^#', "cW")
    let poundLine2 = search('^#', "W")
    call cursor(line("$"), col("$"))
    let poundLine3 = search('^#', "b")

    " Locate #ifndef, #define, #endif directives.
    call cursor(1, 1)
    let regex1  = '^#\s*ifndef\s\+\w\+\|'
    let regex1 .= '^#\s*if\s\+!\s*defined(\s*\w\+\s*)'
    let guardLine1 = search(regex1, "cW")
    let guardLine2 = search('^#\s*define', "W")
    call cursor(line("$"), col("$"))
    let guardLine3 = search('^#\s*endif', "b")

    " Locate #define of desired guardName.
    call cursor(1, 1)
    let guardDefine = search('^#\s*define\s\+' .
                \ s:Func('Name')() . '\>', "cW")

    " If the candidate guard lines were found in the proper
    " location (the outermost pre-processor directives), they
    " are deemed valid header guards.
    if guardLine1 > 0 && guardLine2 > 0 && guardLine3 > 0 &&
                \ guardLine1 == poundLine1 &&
                \ guardLine2 == poundLine2 &&
                \ guardLine3 == poundLine3
        " Replace existing header guard.
        call setline(guardLine1, s:Func('Line1')())
        call setline(guardLine2, s:Func('Line2')())
        call setline(guardLine3, s:Func('Line3')())
        " Position at new header guard start.
        call cursor(guardLine1, 1)

    elseif guardDefine > 0
        echoerr "Found '#define " . s:Func('Name')() .
                    \ "' without guard structure"
        " Position at unexpected #define.
        call cursor(guardDefine, 1)

    else
        " No header guard found.
        call append(0, [ s:Func('Line1')(), s:Func('Line2')(), "" ])
        call append(line("$"), ["", s:Func('Line3')()])
        call cursor(1, 1)
    endif
endfunction
command! -bar HeaderguardAdd call g:HeaderguardAdd()
" Automatically add header guards mapping
map <F2> :call HeaderguardAdd()<CR>

" mapping for adding author
let g:header_field_author = 'Yiping Deng'
let g:header_field_author_email = 'y.deng@jacobs-university.de'
let g:header_auto_add_header = 0
map <F4> :AddHeader<CR>
" Restore saved 'cpoptions'.
let &cpoptions = s:save_cpoptions
" vim: sts=4 sw=4 tw=80 et ai:

"use bell instead of flash
set novisualbell

set history=1000 "store a whole lot of history


" add extra file support
au BufNewFile,BufRead *.xm set filetype=objc
