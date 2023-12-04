.model tiny
.code

org 100h
start:	mov dx,offset mess1
	mov ah,9
	int 21h
	ret
mess1 db 'Hello,world!',10,13,'$'
end start
	
	