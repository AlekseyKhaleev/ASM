d1 segment para public 'data'
mess1 db 'BIOS date:'
n=$-mess1
d1 ends
c1 segment para public 'code'
assume cs:c1, ds:d1, ss:st1
start:	mov ax,d1
	mov ds,ax

	mov ax,0b800h
	mov es,ax
	mov di,80*2*11+30
	mov cx,n
	mov ah,20h
	mov si, offset mess1
m1:	mov al,[si]
	mov es:[di],ax
	inc si
	inc di
	inc di
	loop m1

	mov di,80*2*12+30
	mov cx,8
	mov ax,0ffffh
	mov ds,ax
	mov si,5
	mov ah,30h
m2:	mov al,[si]
	mov es:[di],ax
	inc si
	inc di
	inc di
	loop m2
		
	mov ax,4c00h
   	int 21h
c1 ends
st1 segment para stack 'stack'
      dw 10 dup ('$$')
st1 ends
end start
	
	