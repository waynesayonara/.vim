
" Setting up Vundle - the vim plugin bundler
let iCanHazVundle=1
"if has('win32') || has('win64')
    "let vundle_readme=expand('$VIM/bundle/vundle/README.md')
    "let bundle_folder=expand('$VIM/bundle')
    "let vundle_folder=expand('$VIM/bundle/vundle')
"else
    let vundle_readme=expand('$HOME/.vim/bundle/vundle/README.md')
    let bundle_folder=expand('$HOME/.vim/bundle')
    let vundle_folder=expand('$HOME/.vim/bundle/vundle')
"endif

if !filereadable(vundle_readme)
    echo "Installing Vundle.."
    echo ""
	echo vundle_readme
    silent !mkdir -p bundle_folder
    silent !git clone https://github.com/gmarik/vundle vundle_folder
    let iCanHazVundle=0
endif
"Vundle-specific
filetype off " requisite
"if has('win32') || has('win64')
    "set rtp+=$VIM/bundle/vundle/
    "call vundle#rc('$VIM/bundle/')
"else
    set rtp+=$HOME/.vim/bundle/vundle/
    call vundle#rc()
"endif
filetype plugin indent on " requisite
Bundle 'gmarik/vundle'

"
" PROPER PLUGINS
"
" github

"Bundle 'mileszs/ack.vim'
Bundle 'tpope/vim-fugitive'
Bundle 'scrooloose/nerdtree'
Bundle 'tpope/vim-fugitive'
Bundle 'jelera/vim-javascript-syntax'
Bundle 'scrooloose/syntastic'

" vim-scripts

Bundle 'L9'
Bundle 'FuzzyFinder'
Bundle 'rails.vim'
Bundle 'LaTeX-Suite-aka-Vim-LaTeX'
Bundle 'snipMate'
Bundle 'ack.vim'
Bundle 'Tagbar'


"
" EXPERIMENTAL SECTION
"
Bundle 'Shougo/neocomplcache'
Bundle 'scrooloose/nerdcommenter'
Bundle "michalliu/jsruntime.vim"
Bundle "michalliu/jsoncodecs.vim"
Bundle "michalliu/sourcebeautify.vim"

"after all bundles
if iCanHazVundle == 0
    echo "Installing Bundles, please ignore key map error messages"
    echo ""
    :BundleInstall
endif
