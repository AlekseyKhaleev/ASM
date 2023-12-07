s1 segment 
assume cs:s1, ds:s1, ss:s1
org 100h
start:	
	mov dx,offset mess1
	mov ah,9
	int 21h
	ret
mess1 db 'Hello,world!',10,13,'$'
s1 ends
end start