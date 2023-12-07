.model small
;vivod soob 
vivod macro a
	mov ah,9
	mov dx,offset a
	int 21h
endm

.data
mess1 db 'Press F1 to draw window',10,13,'$'
mess2 db 'Press F2 to exit',10,13,'$'

.stack  256
.code
start:	mov ax,@data
	mov ds,ax
	mov ax,3
	int 10h

	vivod mess1
	vivod mess2

	mov bh,34h

m1:	mov ah,0
	int 16h
	cmp ax,3b00h  ;cod F1
	je m2
	cmp ax,3c00h  ;cod F2
	je m3
	jmp m1
m2:	call drawin	
	add bh,10h
	jmp m1

m3:	mov ax,4c00h
	int 21h

drawin proc
	mov ax,0600h
	mov cx,0707h
	mov dx,1020h	
	int 10h
	ret
drawin endp
end start            