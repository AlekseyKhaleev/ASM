;peresilka baitov iz in_str v out_str 
;> 'A', < 'Z', not equal 'Q'

d1 segment para public 'data'
in_str1 db 1,2,'A'
mess1 db 'Input:',10,13,'$'
in_str db 22 dup (?)
mess2 db 10,13,'Output:',10,13,'$'
out_str db 20 dup ('$')
d1 ends
c1 segment para public 'code'
assume cs:c1,ds:d1,ss:st1
start:		mov ax,d1
		mov ds,ax
;vivod		
		mov dx,offset mess1
		mov ah,9
		int 21h	
;vvod
		mov dx,offset in_str
		mov in_str,19
		mov ah,10
		int 21h
;lab1
		mov si,offset in_str+2
		mov di,offset out_str
		mov cl,in_str+1
		xor ch,ch
m1:		mov al,[si]
		cmp al,'A'
		jb m2
		cmp al,'Z'
		ja m2
		cmp al,'Q'
		je m2
		mov [di],al
		inc di
m2:		inc si
		loop m1

;res
			
		mov dx,offset mess2
		mov ah,9
		int 21h

		mov dx,offset out_str
		mov ah,9
		int 21h
;key
		mov ah,7
		int 21h
;fin
		mov ax,4c00h
		int 21h
c1 ends
st1 segment para stack 'stack'
	dw 100 dup (?)
st1 ends
end start
	