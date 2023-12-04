;.com program
;!!! tlink /t
s1 segment
assume cs:s1, ds:s1, es:s1, ss:s1
org 100h; ÿ PSP

start:	mov ah,9
	mov dx,offset mess1
	int 21h
	mov dx,offset in_str
	mov ah,0ah
	int 21h
	mov si,offset in_str+2
	mov di,offset out_str
	xor ch,ch
	mov cl,[in_str+1]
m1:	mov al,[si]
	cmp al,'A'
	jb m2
	cmp al,'z'
	ja m2
	mov [di],al
	inc di
m2:	inc si
	loop m1
	mov dx,offset mess2
	mov ah,9
	int 21h
	mov dx, offset out_str
	mov ah,9
	int 21h
	ret
mess1 db 'Input digits and letters:',10,13,'$'
in_str db 10,11 dup (?)
mess2 db 10,13,'Result (only letters):',10,13,'$'
out_str db 10 dup ('$')
s1 ends
end start
	
	