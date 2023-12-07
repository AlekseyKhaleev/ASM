;peresilka baitov iz in_str v out_str
;not equal 41h
d1 segment para public 'data'
mess1 db 'Input:',10,13,'$'
in_str db 22 dup (?)
d1 ends
e1 segment para public 'data'
mess2 db 10,13,'Output:',10,13,'$'
out_str db 20 dup ('$')
e1 ends
c1 segment para public 'code'
assume cs:c1,ds:d1,es:e1,ss:st1
start:		mov ax,d1
		mov ds,ax
		mov ax,e1
		mov es,ax
		mov dx,offset mess1
		mov ah,9
		int 21h	
		mov dx,offset in_str
		mov in_str,20
		mov ah,10
		int 21h
		mov si,offset in_str+2
		mov di,offset out_str
		mov cl,in_str+1
		xor ch,ch
m1:		mov al,[si]
		cmp al,41h
		je m2
		mov es:[di],al
		inc di
		inc si
m2:		loop m1
		mov ax,es
		mov ds,ax	
		mov dx,offset mess2
		mov ah,9
		int 21h
		mov dx,offset out_str
		mov ah,9
		int 21h
		mov ah,7
		int 21h
		mov ax,4c00h
		int 21h
c1 ends
st1 segment para stack 'stack'
	dw 100 dup (?)
st1 ends
end start
	