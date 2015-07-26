set nocompatible

filetype off
filetype plugin indent on

syntax on

" Unicode
if has("multi_byte")
	if &termencoding == ""
		let &termencoding = &encoding
	endif
	set encoding=utf-8
	setglobal fileencoding=utf-8
	set fileencodings=ucs-bom,utf-8,latin1
endif

set statusline=%#Special#%f%#Normal#\ %M%R%H%W%=%-15(%#Identifier#ch%#Normal#=%b,0x%B%)%-15(L%l\ C%c%V%)%#Special#%P
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
colorscheme mustang
"LuciusLight

set fillchars+=vert:\ 

set number
set ignorecase
set smartcase
set incsearch
set autoindent
set mouse=a
set tabstop=4
set shiftwidth=4

set list
set listchars=tab:→\ ,trail:·

mapclear
mapclear!

" set tags+=/home/eboyjr/.vim/systags
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
