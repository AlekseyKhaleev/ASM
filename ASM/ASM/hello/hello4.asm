.model tiny
.code
.386
org 100h
start:	mov dx,offset mess1
	mov ah,9
	int 21h
	push eax
	mov eax,ebx

	ret
mess1 db 'Hello,world!',10,13,'$'
end start
	
	