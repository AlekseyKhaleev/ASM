.model small
.data
x_l db 40
x_r db 41
mess1 db 'Move window  <= =>.Choice - enter.$'
in_str dw 5 dup (?)
.stack 0ffh
.code
start:	mov ax,@data
	mov ds,ax
;video mode #3 "text 80*25"
	mov ax,0003
	int 10h
	mov ax,0600h
	mov bh,20h
	mov cx,0
	mov dx,184Fh
	int 10h
;vivod mess1
	mov dx,0
	call vivod
	
;risuem okno startovoe okno
	mov cl,x_l
	mov dl,x_r
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
right:	mov bh,0
	call drawin
	inc x_l
	inc x_r
	mov cl,x_l
	mov dl,x_r
	mov bh,30h
	call drawin
	jmp presskey
left:	mov bh,0
	call drawin
	dec x_l
	dec x_r
	mov cl,x_l
	mov dl,x_r
	mov bh,30h
	call drawin
	jmp presskey
fin:	mov ah,02
	int 21h
;the end
	
	mov ax,4c00h
	int 21h

drawin proc
	mov ax,0600h
	mov ch,11
	mov dh,12
	int 10h
	ret
drawin endp
vivod proc
	
	mov ah,2	
	int 10h
	mov ah,9
	mov dx,offset mess1
	int 21h
	ret
vivod endp

end start	
		
		