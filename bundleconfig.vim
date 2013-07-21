
" Setting up Vundle - the vim plugin bundler
let iCanHazVundle=1

let vundle_readme=expand('$HOME/.vim/bundle/vundle/README.md')

if !filereadable(vundle_readme )
    echo "Installing Vundle.."
    echo ""
    silent !mkdir -p /home/wayne/.vim/bundle
    silent !git clone https://github.com/gmarik/vundle /home/wayne/.vim/bundle/vundle
    "$H/.vim/bundle/vundle
    let iCanHazVundle=0
endif
"Vundle-specific
filetype off " requisite
set rtp+=$HOME/.vim/bundle/vundle/
call vundle#rc()
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
Bundle 'rails.vim'


"
" EXPERIMENTAL SECTION
"
Bundle 'Shougo/neocomplcache'
Bundle 'scrooloose/nerdcommenter'
Bundle "michalliu/jsruntime.vim"
Bundle "michalliu/jsoncodecs.vim"
Bundle "michalliu/sourcebeautify.vim"
Bundle "bling/vim-airline"

"after all bundles
if iCanHazVundle == 0
    echo "Installing Bundles, please ignore key map error messages"
    echo ""
    :BundleInstall
endif
