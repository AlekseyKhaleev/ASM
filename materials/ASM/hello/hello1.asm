.model small
.data
mess1 db 'Hello,world!',10,13,'$'
.code
start:	mov ax,@data
	mov ds,ax
	
	mov dx,offset mess1
	mov ah,9
	int 21h
		
	mov ax,4c00h
   	int 21h

.stack 10
end start
	
	