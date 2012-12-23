"This must be first, because it changes other options as a side effect.
set nocompatible
set nocp

source $HOME/.vim/bundleconfig.vim

if has('win32') || has('win64')
    source $VIMRUNTIME/delmenu.vim
    source $VIMRUNTIME/menu.vim
endif

set termencoding=utf-8
set fileencodings=utf8,cp1251,utf8-bom
set encoding=utf8

" xelatex
let g:Tex_CompileRule_pdf = 'xelatex -interaction=nonstopmode $*'

colorscheme waynesayonara
color waynesayonara

autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete

"configure tags - add additional tags here or comment out not-used ones
" set tags+=~/.vim/tags/cpp
" set tags+=~/.vim/tags/gl
" set tags+=~/.vim/tags/sdl
" set tags+=~/.vim/tags/qt4
" "build tags of your own project with Ctrl-F12
" map <C-F12> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>


" OmniCppComplete
let OmniCpp_NamespaceSearch = 1
let OmniCpp_GlobalScopeSearch = 1
let OmniCpp_ShowAccess = 1
let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
let OmniCpp_MayCompleteDot = 1 " autocomplete after .
let OmniCpp_MayCompleteArrow = 1 " autocomplete after ->
let OmniCpp_MayCompleteScope = 1 " autocomplete after ::
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]
"automatically open and close the popup menu / preview window
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
set completeopt=menuone,menu,longest,preview

"allow backspacing over everything in insert mode
set backspace=indent,eol,start

"store lots of :cmdline history
set history=1000

set showcmd     "show incomplete cmds down the bottom
set showmode    "show current mode down the bottom

set incsearch   "find the next match as we type the search
set hlsearch    "hilight searches by default

set number "show line numbers
set nowrap      "dont wrap lines
set linebreak   "wrap lines at convenient points

"statusline setup
set statusline=%f       "tail of the filename

"display a warning if fileformat isnt unix
set statusline+=%#warningmsg#
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*

"display a warning if file encoding isnt utf-8
set statusline+=%#warningmsg#
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
set statusline+=%*

set statusline+=%h      "help file flag
set statusline+=%y      "filetype
set statusline+=%r      "read only flag
set statusline+=%m      "modified flag

"display a warning if &et is wrong, or we have mixed-indenting
set statusline+=%#error#
set statusline+=%{StatuslineTabWarning()}
set statusline+=%*

set statusline+=%{StatuslineTrailingSpaceWarning()}

set statusline+=%{StatuslineLongLineWarning()}

set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

"display a warning if &paste is set
set statusline+=%#error#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*

set statusline+=%=      "left/right separator
set statusline+=%{StatuslineCurrentHighlight()}\ \ "current highlight
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file
set laststatus=2

"recalculate the trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

"return '[\s]' if trailing white space is detected
"return '' otherwise
function! StatuslineTrailingSpaceWarning()
    if !exists("b:statusline_trailing_space_warning")
        if search('\s\+$', 'nw') != 0
            let b:statusline_trailing_space_warning = '[\s]'
        else
            let b:statusline_trailing_space_warning = ''
        endif
    endif
    return b:statusline_trailing_space_warning
endfunction


"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

"recalculate the tab warning flag when idle and after writing
autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatuslineTabWarning()
    if !exists("b:statusline_tab_warning")
        let tabs = search('^\t', 'nw') != 0
        let spaces = search('^ ', 'nw') != 0

        if tabs && spaces
            let b:statusline_tab_warning =  '[mixed-indenting]'
        elseif (spaces && !&et) || (tabs && &et)
            let b:statusline_tab_warning = '[&et]'
        else
            let b:statusline_tab_warning = ''
        endif
    endif
    return b:statusline_tab_warning
endfunction

"recalculate the long line warning when idle and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_long_line_warning

"return a warning for "long lines" where "long" is either &textwidth or 80 (if
"no &textwidth is set)
"
"return '' if no long lines
"return '[#x,my,$z] if long lines are found, were x is the number of long
"lines, y is the median length of the long lines and z is the length of the
"longest line
function! StatuslineLongLineWarning()
    if !exists("b:statusline_long_line_warning")
        let long_line_lens = s:LongLines()

        if len(long_line_lens) > 0
            let b:statusline_long_line_warning = "[" .
                        \ '#' . len(long_line_lens) . "," .
                        \ 'm' . s:Median(long_line_lens) . "," .
                        \ '$' . max(long_line_lens) . "]"
        else
            let b:statusline_long_line_warning = ""
        endif
    endif
    return b:statusline_long_line_warning
endfunction

"return a list containing the lengths of the long lines in this buffer
function! s:LongLines()
    let threshold = (&tw ? &tw : 80)
    let spaces = repeat(" ", &ts)

    let long_line_lens = []

    let i = 1
    while i <= line("$")
        let len = strlen(substitute(getline(i), '\t', spaces, 'g'))
        if len > threshold
            call add(long_line_lens, len)
        endif
        let i += 1
    endwhile

    return long_line_lens
endfunction

"find the median of the given array of numbers
function! s:Median(nums)
    let nums = sort(a:nums)
    let l = len(nums)

    if l % 2 == 1
        let i = (l-1) / 2
        return nums[i]
    else
        return (nums[l/2] + nums[(l/2)-1]) / 2
    endif
endfunction

"indent settings
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent
set smartindent
set tabstop=4

"folding settings
set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default

set wildmode=list:longest   "make cmdline tab completion similar to bash
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing

"display tabs and trailing spaces
set list
set listchars=tab:\ \ ,extends:>,precedes:<

set formatoptions-=o "dont continue comments when pushing o/O

"vertical/horizontal scroll off settings
set scrolloff=3
set sidescrolloff=7
set sidescroll=1

"load ftplugins and indent files
filetype indent on

"turn on syntax highlighting
syntax on

"some stuff to get the mouse going in term
set mouse=a
set ttymouse=xterm2
set pastetoggle=<F4>

"hide buffers when not displayed
set hidden

if has("gui_running")
    "tell the term has 256 colors
    set t_Co=256

    if has("gui_gnome")
        "set term=gnome-256color
        colorscheme waynesayonara
    else
        colorscheme waynesayonara
        set guitablabel=%M%t
        set lines=40
        set columns=115
    endif
    if has("gui_mac") || has("gui_macvim")
        set guifont=Menlo:h15
    endif
    if has("gui_win32") || has("gui_win32s")
        set guifont=Consolas:h12
        set enc=utf-8
    endif
else
    "dont load csapprox if we no gui support - silences an annoying warning
    let g:CSApprox_loaded = 1
endif

"make <c-l> clear the highlight as well as redraw
nnoremap <C-L> :nohls<CR><C-L>
inoremap <C-L> <C-O>:nohls<CR>

"map to bufexplorer
nnoremap <C-B> :BufExplorer<cr>

"map to fuzzy finder text mate stylez
nnoremap <c-f> :FuzzyFinderTextMate<CR>

"map Q to something useful
noremap Q gq

"make Y consistent with C and D
nnoremap Y y$

"mark syntax errors with :signs
let g:syntastic_enable_signs=1

"snipmate setup
"try
"    source ~/.vim/snippets/support_functions.vim
"catch
"    source $HOMEPATH\vimfiles\snippets\support_functions.vim
"endtry
"autocmd vimenter * call s:SetupSnippets()
"function! s:SetupSnippets()
"
"    "if we're in a rails env then read in the rails snippets
"    if filereadable("./config/environment.rb")
"        call ExtractSnips("~/.vim/snippets/ruby-rails", "ruby")
"        call ExtractSnips("~/.vim/snippets/eruby-rails", "eruby")
"    endif
"
"    call ExtractSnips("~/.vim/snippets/html", "eruby")
"    call ExtractSnips("~/.vim/snippets/html", "xhtml")
"    call ExtractSnips("~/.vim/snippets/html", "php")
"endfunction

" Pmenu
hi Pmenu guibg=#2e3436 guifg=#eeeeec
hi PmenuSel guibg=#ffffff guifg=#1e2426
hi PmenuSbar guibg=#555753
hi PmenuThumb guifg=#ffffff

"visual search mappings
function! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>


"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
autocmd BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
    if &filetype !~ 'commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    end
endfunction

"define :HighlightLongLines command to highlight the offending parts of
"lines that are longer than the specified length (defaulting to 80)
command! -nargs=? HighlightLongLines call s:HighlightLongLines('<args>')
function! s:HighlightLongLines(width)
    let targetWidth = a:width != '' ? a:width : 79
    if targetWidth > 0
        exec 'match Todo /\%>' . (targetWidth) . 'v/'
    else
        echomsg "Usage: HighlightLongLines [natural number]"
    endif
endfunction

"XeLaTeX additions 29-nov-2010
let g:Tex_DefaultTargetFormat='pdf'
let g:Tex_CompileRule_pdf = 'xelatex -interaction=nonstopmode $*'
:setlocal spell spelllang=en,ru
set textwidth=150
" langmap
set langmap=ёйцукенгшщзхъфывапролджэячсмитьбюЁЙЦУКЕHГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ;`qwertyuiop[]asdfghjkl\\;'zxcvbnm\\,.~QWERTYUIOP{}ASDFGHJKL:\\"ZXCVBNM<>

set cul "highlight current line
"
"
"set keymap=russian-jcukenwin    " настраиваем переключение раскладок клавиатуры по C-^
"set iminsert=0                  " раскладка по умолчанию для ввода - английская
"set imsearch=0                  " раскладка по умолчанию для поиска - английская

"" переключение на русскую/английскую раскладку по ^f (Ctrl + F)
"cmap <silent> <S-Left> <C-^>
"imap <silent> <S-Left> <C-^>X<Esc>:call MyKeyMapHighlight()<CR>a<C-H>
"nmap <silent> <S-Left> a<C-^><Esc>:call MyKeyMapHighlight()<CR>
"vmap <silent> <S-Left> <Esc>a<C-^><Esc>:call MyKeyMapHighlight()<CR>gv

"" Переключение раскладок и индикация выбранной в данный момент раскладки -->
"" При английской раскладке статусная строка текущего окна будет синего цвета, а при русской - красного
"function MyKeyMapHighlight()
    "if &iminsert == 0
        "hi StatusLine ctermfg=White guifg=White
    "else
        "hi StatusLine ctermfg=Yellow guifg=Yellow
    "endif
"endfunction
"" Вызываем функцию, чтобы она установила цвета при запуске Vim'a
"call MyKeyMapHighlight()
"" При изменении активного окна будет выполняться обновление индикации текущей раскладки
"au WinEnter * :call MyKeyMapHighlight()
"
"
let g:NERDTreeWinPos = "right"

function RoRreadyNERDTree()
    cd ~/ror/projects/
    NERDTree
endfunction

command RN call RoRreadyNERDTree() 
"type tagname,,, to get <tagname></tagname>
imap ,,, <esc>bdwa<<esc>pa><cr></<esc>pa><esc>kA

function ConvertSpanishDiac1251TO1252()
    %s/с/n/g
    %s/б/a/g
    %s/н/i/g
    %s/у/o/g
    %s/ъ/u/g
    %s/й/e/g
    %s/С/N/g
    %s/Б/A/g
    %s/Н/I/g
    %s/У/O/g
    %s/Ъ/U/g
    %s/Й/E/g
endfunction

command CP1252 call ConvertSpanishDiac1251TO1252() 

" "Shougo/neocomplcache
 " let g:neocomplcache_enable_at_startup = 0
 " " Disable AutoComplPop. Comment out this line if AutoComplPop is not installed.
 " let g:acp_enableAtStartup = 0
 " " Launches neocomplcache automatically on vim startup.
 " let g:neocomplcache_enable_at_startup = 1
 " " Use smartcase.
 " let g:neocomplcache_enable_smart_case = 1
 " " Use camel case completion.
 " let g:neocomplcache_enable_camel_case_completion = 1
 " " Use underscore completion.
 " let g:neocomplcache_enable_underbar_completion = 1
 " " Sets minimum char length of syntax keyword.
 " let g:neocomplcache_min_syntax_length = 3
 " " buffer file name pattern that locks neocomplcache. e.g. ku.vim or fuzzyfinder 
 " let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
 
 " " Define file-type dependent dictionaries.
 " let g:neocomplcache_dictionary_filetype_lists = {
    " \ 'default' : '',
        " \ 'vimshell' : $HOME.'/.vimshell_hist',
            " \ 'scheme' : $HOME.'/.gosh_completions'
                " \ }
 
 " " Define keyword, for minor languages
 " if !exists('g:neocomplcache_keyword_patterns')
     " let g:neocomplcache_keyword_patterns = {}
  " endif

"set tags =~/.vim/tags/
nmap <F8> :TagbarToggle<CR> 

function PrognozReady()
    e D:\prognoz\Tabsheet\ComponentExampleTabSheet\build\PP.TabSheet.js  
    TagbarToggle
    TagbarToggle
    vnew D:\prognoz\temp.js
    "set ft=javascript
    "NeoComplCacheEnable
endfunction

command PZ call PrognozReady() 

function BeautifyJS()
    w D:\prognoz\temp.js
    e D:\prognoz\temp.js
    silent !jsBeautifier.net.exe "sourceFile=D:\prognoz\temp.js" "indent=4" "preserveEmptyLines=true" "detectPackers=true" "keepArrayIndent=false" "bracesInNewLine=false" 
    e!
endfunction

command JSB call BeautifyJS() 
map <F2> :JSB <CR>

" add space to comments
let g:NERDSpaceDelims = 1

" clean up comments before buttons (Prognoz js chm)
function BeatifyButtonComments()
    call NERDComment("x", "uncomment")
    call NERDComment("x", "sexy")
    g/^ \* /s/ "/ «/g
    g/^ \* /s/\(\S\)"/\1»/g
    g/^ \* /norm f*wlgUh
endfunction

command BeatifyButtonCommentsCommand call RoRreadyNERDTree() 

nmap <F6> :BeatifyButtonCommentsCommand<CR> 
