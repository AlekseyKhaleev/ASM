.model small
.data
mess1 db 'Change window color <= =>.Choice - enter.$'
.stack 0ffh
.code
start:	mov ax,@data
	mov ds,ax
;video mode #3 text 80*25
	mov ax,0003
	int 10h
;vivod mess1
	mov dx,offset mess1
	mov ah,9
	int 21h
;risuem startovoe okno
	mov bh,30h
	call drawin
;vvod
presskey:mov ah,0
	int 16h
;if enter
	cmp ax,1c0dh
	je fin
;if =><=
	cmp ax,4d00h
	je right
	cmp ax,4b00h
	je left
	jmp presskey
right:	cmp bh,0f0h
	je presskey
;izmenim zvet fona na 1
	add bh,10h
	call drawin
	jmp presskey
left:	cmp bh,10h
	je presskey
;izmenim zvet fona na 1
	sub bh,10h
	call drawin
	jmp presskey
fin:	mov ah,02
	int 21h
	mov ax,4c00h
	int 21h

drawin proc
	mov ax,0600h
	mov cx,0303h
	mov dx,0909h
	int 10h
	ret
drawin endp
end start	
		
		