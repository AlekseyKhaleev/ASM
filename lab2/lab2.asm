;пересылка слов(W) из in_str в out_str 21-ВМз-4 07/12/2023
;слова, не равные 'A', 'H', 'X'

d1 segment para public 'data'
in_str1 db 1,2,'A'
mess1 db '21_vmz_4|A_Khaleev Input:',10,13,'$'
in_str db 22 dup (?)
mess2 db 10,13,'Output:',10,13,'$'
out_str db 20 dup ('$')
d1 ends

c1 segment para public 'code'
assume cs:c1,ds:d1,ss:st1
start:
        mov ax,d1
		mov ds,ax
;приглашение ввода
		mov dx,offset mess1
		mov ah,9
		int 21h	
;ввод
		mov dx,offset in_str
		mov in_str,16
		mov ah,10
		int 21h

;основная часть (код из ЛР1):
		mov si,offset in_str+2
		mov di,offset out_str
		xor ah, ah  ; Очистка старшего байта ax
		mov al,in_str+1
		xor dx, dx ; Очистите dx перед div, так как div использует dx:ax
        mov bl, 2  ; Делитель
        div bl     ; ax/bl -> результат в al, остаток в ah
        mov cl, al
        test ah, ah ; Проверьте, есть ли остаток
        jz noRemainder ; Если остатка нет, перейдите к метке noRemainder
        inc cl      ; Если был остаток, увеличьте cl на 1
noRemainder:
        ; Здесь cl содержит количество слов, учитывая нечетное количество байт
		xor ch,ch
m1:		mov ax,[si]
;        xchg ah, al ; обменять местами старший и младший байты
;		cmp ah,'3'
;		je m2
;		cmp ax,'4'
;		je m2
;		cmp ax,'5'
;		je m2
		mov [di], ax
		add di, 2
m2:		add si, 2
		loop m1

;вывод результата:
		mov dx,offset mess2
		mov ah,9
		int 21h

		mov dx,offset out_str
		mov ah,9
		int 21h
;задержка (ожидание нажатия клавиши):
		mov ah,7
		int 21h
;завершение:
		mov ax,4c00h
		int 21h
c1 ends

st1 segment para stack 'stack'
	dw 100 dup (?)
st1 ends

end start
	