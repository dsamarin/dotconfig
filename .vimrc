set nocompatible

" Get rid of working directory clutter
set backupdir=~/.vim/.backup//
set directory=~/.vim/.backup//

filetype plugin indent on

syntax on
let g:c_syntax_for_h = 1

" Unicode
if has("multi_byte")
	if &termencoding == ""
		let &termencoding = &encoding
	endif
	set encoding=utf-8
	setglobal fileencoding=utf-8
	set fileencodings=ucs-bom,utf-8,latin1
endif

set statusline=%#Special#%f%#Normal#\ %M%R%H%W%=%#Special#%P
set laststatus=2

set virtualedit=onemore
set formatoptions=

" Allow colors
set t_Co=256
set t_ut=

" If the Vim binary has no GUI support, shut up CSApprox
if !has("gui_running")
	let g:CSApprox_verbose_level = 0
endif

syntax enable
colorscheme lucius
LuciusLight

set fillchars+=vert:\ 

set number
set ignorecase
set smartcase
set incsearch
set autoindent
set mouse=a
set ttymouse=xterm2
set tabstop=2
set shiftwidth=2
set expandtab
set cursorline
set cursorcolumn
set colorcolumn=80
set completeopt=menu,menuone
set pastetoggle=<F12>
set autochdir

set list
set listchars=tab:→\ ,trail:·

mapclear
mapclear!

set tags=tags;
let g:ycm_collect_identifiers_from_tags_files = 1

set nocp
filetype plugin on
filetype indent off

" Taglist
autocmd BufWritePost *.c,*.h :TlistUpdate
nnoremap <silent> <F8> :TlistToggle<CR>


" Vala shit
autocmd BufRead *.vala set efm=%f:%l.%c-%[%^:]%#:\ %t%[%^:]%#:\ %m
autocmd BufRead *.vapi set efm=%f:%l.%c-%[%^:]%#:\ %t%[%^:]%#:\ %m
au BufRead,BufNewFile *.vala            setfiletype vala
au BufRead,BufNewFile *.vapi            setfiletype vala

" JavaScript shit
hi link javaScriptGlobal NONE
hi link javaScriptMember NONE
hi link javaScriptMessage NONE

" Markdown shit
au BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn}   setfiletype mkd
