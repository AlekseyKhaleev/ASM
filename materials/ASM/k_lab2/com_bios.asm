;односегментная программа, точечные директивы
;процедуры и макросы в такой программе тоже можно использовать

.model tiny
;**********макросы пишем здесь****************************
anykey macro
	mov ah,7
	int 21h
endm
;***************
.code
org 100h
main:
		mov ax,3
		int 10h
		mov es,seg_video
		anykey
		call vivod
		call bios
		ret
;************процедуры пишем здесь****************************

vivod proc
	mov cx,N
	mov di,696
	mov ah,20h
	mov si, offset mess
m1:	mov al,[si]
	mov es:[di],ax
	add di,160
	add ah,11h
	push ax
	inc si
	anykey
	pop ax
	loop m1
	ret
vivod endp
bios proc
	mov cx,8
	mov ds,seg_bios
	mov si,5
	mov di,700
	mov ah,0Ah
m2:	mov al,[si]
	mov es:[di],ax
	inc di
	inc di
	inc si
	loop m2
	ret
bios endp
;**********здесь место данных**********************
seg_video dw 0B800h
seg_bios dw 0FFFFh
mess db 'BIOS'
N=$-mess
end main 
	

