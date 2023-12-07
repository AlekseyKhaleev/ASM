.model small
.data
ramka db 201,7 dup (186),200
mess1 db 'Change window color <= =>.Choice - enter.$'
mess2 db 'Hello$'
in_str dw 5 dup (?)
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
;risuem okno startovoe okno
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
	add bh,10h
	call drawin
	jmp presskey
left:	cmp bh,10h
	je presskey
	sub bh,10h
	call drawin
	jmp presskey
fin:	mov ah,02
	int 21h
;primer risovaniya ramki
	mov cx,9
	mov si, offset ramka
;nachalnye coordinaty cursora 0202
	mov dx,0202h
;cikl: ustanovit' cursor+vivesti simvol
next:	mov bh,0
	mov ah,2	
	int 10h
	
;vivod simvolov po verticali
	mov ah,9
	mov bl,20h
	mov al,[si]
	push cx
	mov cx,1
	int 10h
	pop cx
;+1 k #stroki
	inc dh
	inc si
	loop next
;vivod simvolov po gorizontali
	dec dh
	inc dl
	mov ah,2	
	int 10h
	mov ah,9
	mov bl,20h
	mov al,0CDh
	mov cx,7
	int 10h
	call vivod
	call vvod
;the end
	
	mov ax,4c00h
	int 21h

drawin proc
	mov ax,0600h
	mov cx,0303h
	mov dx,0909h
	int 10h
	ret
drawin endp
vivod proc
	mov dx,0303h
	mov ah,2	
	int 10h
	mov ah,9
	mov dx,offset mess2
	int 21h
	ret
vivod endp
vvod proc
	mov dx,0403h
	mov cx,5
	mov si,offset in_str
q1:	push cx
	mov ah,2	
	int 10h	
	mov ah,0
	int 16h
	mov [si],ax
	inc si
	 inc si
	mov ah,9
	mov bh,0
	mov cx,1
	int 10h
	inc dl
	pop cx
	loop q1
	ret
vvod endp

end start	
		
		