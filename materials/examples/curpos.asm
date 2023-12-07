.model small 
printstr macro a
	mov dx,offset a
	mov ah,9
	int 21h
endm
anykey macro 
	mov ah,8
	int 21h
endm
.stack 0ffh
.data
mess1 db 'Window creation$'
mess2 db 'Hello!$'
mess3 db 'How are you?$'
mess4 db 'Fine!$'

.code 

start:  mov ax,@data
	mov   ds,ax
	mov ax,0003h          ;установка текстового видеорежима
	int 10h
	mov ax,0600h ;создание окна
	mov cx,0303h
	mov dx,0814h
	mov bh,5bh
	int 10h
	
	
	mov dx,0505h ;позиция курсора
	call cursor_pos
	anykey
	printstr mess1;выводсообщения в окне
	anykey
	mov ax,0600h ;создание окна
	mov cx,0920h
	mov dx,0a2ch
	mov bh,4ah
	int 10h
	mov dx,0921h
	call cursor_pos
	printstr mess2
	mov dx,0a21h
	call cursor_pos
	printstr mess3
	anykey
	mov ax,0601h ;прокрутка окна
	mov cx,0920h
	mov dx,0a2ch
	mov bh,4ah
	int 10h
	mov dx,0a21h
	call cursor_pos
	printstr mess4
	anykey
	mov ax,4c00h
	int 21h

;установка позиции курсора
cursor_pos proc 
	mov bh,0
	mov ah,2
	int 10h
	ret
cursor_pos endp
end start