curspos macro a,b
	mov dh,a
	mov dl,b 
	mov ah,02
	mov bh,0
	int 10h
endm 
printstr macro c
	mov dx,offset c
	mov ah,9
	int 21h
endm
.MODEL SMALL
.STACK 256
.DATA
wup_col db 0,16,14,9,7,52,50,16,14,1,21,42,63
wup_str db 0,3,2,9,8,10,9,18,17,24,24,24,24
wdn_col db 79,66,64,43,41,73,71,66,64,19,40,61,78
wdn_str db 23,6,5,15,14,14,13,21,20,24,24,24,24
attr db 30h,1,24h,1,1eh,1,4ah,1,1eh,0ech,0ech,0ech,0ech
curs_str db 3,9,10,24,24,24
curs_col db 17,15,56,3,26,46,66
text1 db 'Programma...$'
text2 db 'vvod massiva 3x3$'
text3 db 'Result$'
text4 db 'F1-clear window$'
text5 db 'F2-calcul$'
text6 db 'F10-exit $'
.CODE
start:	mov ax,@data
	mov ds,ax
;создание интерфейса (окон)
;v cikle
;*****************
	mov cx,13; количество окон
round_1:push cx
	mov ax,0600h
	mov bh,attr+si
	mov ch,wup_str+si
	mov cl,wup_col+si
	mov dh,wdn_str+si
	mov dl,wdn_col+si
	int 10h
	inc si
	pop cx
	loop round_1
;********************
	xor si,si
	curspos curs_str+si,curs_col+si
	printstr text1
	inc si 
	curspos curs_str+si, curs_col+si
	printstr text2
	inc si
	curspos curs_str+si,curs_col+si
	printstr text3
	inc si
	curspos curs_str+si, curs_col+si
	printstr text4
	inc si
	curspos curs_str+si,curs_col+si
	printstr text5
	inc si
	curspos curs_str+si,curs_col+si
	printstr text6
	mov ah,07
	int 21h
	mov ax,4c00h
	int 21h
end start