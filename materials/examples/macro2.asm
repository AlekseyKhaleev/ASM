.model small
anykey macro
	mov ah,7
	int 21h
endm
vivod macro a
local m1
IFB <a>
	mov bx,0
	mov ah,3
	int 10h	;read cursor position to dx (dh-string, dl-column)
	mov si,offset mess2
	mov cx,n
m1:	push cx
	mov al,[si]
	mov bx,0024h ;bh-number of videopage,bl-symbols attribute
	mov cx,1
	mov ah,9
	int 10h	;print symbol in cursor position (al-ASCII)
	inc si
	inc dl
	mov ah,2	;set cursor to next column
	int 10h
	pop cx
	loop m1
ELSE
	mov dx,offset a
	mov ah,9
	int 21h
ENDIF
endm
.data
mess1 db 'Use macros',10,13,'$'
mess2 db 'No parameter in macrocall!'
n=$-mess2
x1 db 201,9 dup (205),187,10,13,'$'
x2 db 186,'macrodef ',186,10,13,'$'
x3 db 186,'macrocall',186,10,13,'$'
x4 db 186,'macroext ',186,10,13,'$'
x5 db 200,9 dup (205),188,10,13,'$'
x6 db 'vivod macro a',10,13,'mov dx,offset a',10,13,'mov ah,9',10,13,'int 21h',10,13,'endm',10,13,'$'
x7 db 'vivod mess',10,13,'$'
x8 db 'mov dx,offset mess',10,13,'mov ah,9',10,13,'int 21h',10,13,'$'
.stack  256
.code
start:mov ax,@data
	mov ds,ax
	mov ax,0003h 
	int 10h	;cls
	vivod mess1
	irp number,<1,2,5,6>
	vivod x&number
	endm
	anykey
	irp number,<1,3,5,7>
	vivod x&number
	endm
	anykey
	irp number,<1,4,5,8>
	vivod x&number
	endm
	anykey
	vivod
	anykey
	mov ax,4c00h
	int 21h
end start            