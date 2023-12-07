;vot macrosy
anykey macro
	push ax
	mov ah,7
	int 21h
	pop ax
endm
vivod macro x
	mov dx,offset x
	mov ah,9
	int 21h
endm
curpos macro strcol
	mov dx,strcol
	mov ah,2
	mov bh,0
	int 10h
endm
stroka macro y
local m1
	mov si,offset y
m1:	mov ah,2
	mov bh,0
	int 10h
	mov ah,0ah
	mov cx,1
        mov al,byte ptr [si]
	int 10h
	inc si
	inc dx
	cmp byte ptr [si],'$'
	jne m1
endm	
;вывод пробелов в строку сообщений
;координаты строки сообщений 1401h
probel macro
local clear
	curpos koord
	mov ah,0eh
	mov cx,70
	mov bh,0
clear:	mov al,' '
	int 10h
	loop clear
endm
.model small
.data
;koordinaty okon 
upleft dw 0103h,0204h,0504h,0804h,0120h,0130h,0a20h,0b21h
downri dw 0a17h,0316h,0616h,0916h,0727h,0737h,0f33h,0e32h
attr dw 2000h, 3 dup (3500h),5700h,1700h,3000h
curp dw 0304h,0604h,0904h,0120h,0130h,0a20h
mess1 db 'Input numbers$'
mess2 db 'Calculate$'	
mess3 db 'Exit$'
mess4 db 'Massiv+$'
mess5 db 'Massiv-$'
;ramki iz ASCII
ram1 db 201,6 dup (205),'Result',6 dup (205),187,'$'
ram2 db 186,18 dup (' '),186,'$'
ram3 db 200,18 dup (205),188,'$'
pro1 db 'Do you wish to change Result window color? Y/N$'
pro2 db 'Press any key for exit$'
pro3 db 'Press <==> to change.Enter for choice.$'
pro4 db 'Press any key to enter menu.$'
koord dw 1401h
.stack 256
.code
start:	mov ax,@data
	mov ds,ax
	mov ax,0003h
	int 10h
	xor si,si
	mov cx,6
next:	push cx
	mov ax,[upleft+si]
	push ax
	mov ax,[downri+si]
	push ax
	mov ax,[attr+si]
	push ax
	call drawin
	pop ax
	pop ax
	pop ax
	pop cx
	inc si
	inc si
	loop next
;Вывод сообщений, коорд. курсора - curp
	xor di,di
	irp a,<mess1,mess2,mess3,mess4,mess5>
	mov dx,curp+di
	stroka a
	inc di
	inc di
	endm
;Рамка, рисуем построчно ram1-3
	mov dx,curp+di
	push dx
	stroka ram1
	rept 5
	pop dx
	inc dh
	push dx
	stroka ram2
	endm
	pop dx
	stroka ram3
	curpos koord
	vivod pro1
repeat:	mov ah,0
	int 16h
	cmp al,'n'
	je col_ok
	cmp al,'y'
	jne repeat
	probel
	curpos koord
	vivod pro3
	call wincol
	jmp tobe
col_ok: probel
	curpos koord
	vivod pro4
tobe:	anykey
	call activ
	probel
	curpos koord
	vivod pro2
	anykey	
	mov ax,4c00h
	int 21h
drawin proc
	push bp
	mov bp,sp
	mov ax,0600h
	mov cx,[bp+8]
	mov dx,[bp+6]
	mov bx,[bp+4]
	int 10h
	pop bp
	ret
drawin endp
wincol proc
	mov ax,upleft+14
	push ax
	mov ax,downri+14
	push ax
	mov bx,0
pressk:	mov ah,0
	int 16h
	cmp ax,1c0dh
	je fin
	cmp ax,4d00h
	je right
	cmp ax,4b00h
	je left
	jmp pressk
right:	cmp bh,0f0h
	je pressk
	add bh,10h
	push bx
	call drawin
	pop bx
	jmp pressk
left:	cmp bh,10h
	je pressk
	sub bh,10h
	push bx
	call drawin
	pop bx
	jmp pressk
fin:	probel
	curpos koord
	vivod pro4
	pop ax
	pop ax
	ret
wincol endp
activ proc
	xor di,di
	mov si,2
	mov ax,[upleft+si]
	push ax
	mov ax,[downri+si]
	push ax
	mov ax,0b500h
	push ax
	call drawin
	pop ax
	pop ax
	pop ax
	mov dx,curp+di
	stroka mess1	
	ret
activ endp	
	
end start






