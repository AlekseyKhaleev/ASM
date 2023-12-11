.MODEL SMALL

print macro text;вывод сообщений на экран
	push ax
	push dx
	mov dx,offset text
	mov ah,9
	int 21h
	pop dx
	pop ax
endm

input macro text;ввод строки символов
	push ax
	push dx
	mov dx,offset text
	mov ah,0ah
	int 21h
	pop dx
	pop ax
endm

.data
start_mess db 'Input:5 numbers in [-29999,29999]',10,13, 'Press <Enter> after each number',10,13,'$'
input_mess db 'Enter number: $'
in_str label byte ;строка символов (не более 6)
STRING_SIZE db 7
NUMS_SIZE dw 5         ;количество чисел
kol db (?)
string db 7 dup (?)   ; знак числа (для отрицательных), 5 цифр, enter
numbers dw 5 dup (0)   ;массив чисел
maxnum dw (?)          ;наибольшее
PosSum dw 0        ;сумма положительных
NegSum dw 0,0         ;сумма отрицательных
average dw (?)	;среднее
carret db 10,13,'$'
err_mess db 'Input error!','$'
overflow_mess db 13,10,7,'Overflow!','$'
average_mess db 13,10,'Average:','$'
max_mess db 13,10,'Max:','$'
out_str db 6 dup (' '),'$'
flag_err equ 1

.stack 256

.code
start:
    mov ax,@data
    mov ds,ax

;вызов функции 0 -  установка 3 текстового видеорежима, очистка экрана
    mov ax,0003  ;ah=0 (номер функции),al=3 (номер режима)
    int 10h
    print start_mess

;цикл ввода, di - номер числа в массиве
    xor di,di
    mov cx, NUMS_SIZE ; в cx - размер массива

vvod:
    push cx
m1:
    print input_mess     ;вывод сообщения о вводе строки
;ввод числа в виде строки
    input in_str
    print carret
;проверка диапазона вводимых чисел (-29999,+29999)
    call diapazon
    cmp bh,flag_err  ;сравним bh и flag_err
    je err1          ;если равен -сообщение об ошибке ввода
;проверка допустимости вводимых символов
    call dopust
    cmp bh,flag_err
    je err1
;;преобразование строки в число
;    call AscToBin
;    inc di
;    inc di
;    pop cx
    print carret
    print in_str+2
    loop vvod
    jmp exit
err1:
    print err_mess
    jmp exit

;здесь место для арифметической обработки
;*******************************************************************************
;например, получения суммы положительных, отрицательных, среднего, максимального
;TRY!!!
;********************************************************************************************

	
DIAPAZON PROC
;;проверка диапазона вводимых чисел -29999,+29999
;;буфер ввода - string
;;через bh возвращается флаг ошибки ввода
;    xor bh,bh;
;    xor si,si;      номер символа в вводимом числе
;
;; проверим является ли первый символ минусом
;	cmp [in_string + 2],2dh
;	jne plus ;   если 1 символ не минус,проверим число символов
;
;;если первый - минус и символов меньше 6 проверим допустимость символов
;	cmp [in_str + 1], 6
;	jb dop
;	inc si;         иначе проверим первую цифру
;	jmp first
;
;plus:
;    cmp kol,6;      введено 6 символов и первый - не минус
;	je error1;       ошибка
;first:
;    cmp string[si],32h;сравним первый символ с 2
;	jna dop;если первый <=2 -проверим допустимость символов
;error1:
;    mov bh,flag_err;иначе bh=flag_err
;dop:
    ret
DIAPAZON ENDP

DOPUST PROC
;;проверка допустимости вводимых символов
;;буфер ввода - stroka
;;si - номер символа в строке
;;через bh возвращается флаг ошибки ввода
;	xor bh,bh
;    xor si,si
;	xor ah,ah
;	xor ch,ch
;	mov cl,kol;в ch количество введенных символов
;m11:
;	mov al,[string+si]; в al - первый символ
;	cmp al,2dh;является ли символ минусом
;	jne testdop;если не минус - проверка допустимости
;	cmp si,0;если минус  - является ли он первым символом
;	jne error2;если минус не первый -ошибка
;	jmp m13
;;является ли введенный символ цифрой
;testdop:
;    cmp al,30h
;	jb error2
;	cmp al,39h
;	ja error2
;m13:
; 	inc si
;	loop m11
;	jmp m14
;error2:
;	mov bh, flag_err;при недопустимости символа bh=flag_err
;m14:
	ret
DOPUST ENDP

AscToBin PROC
;в cx количество введенных символов
;в bx - номер символа начиная с последнего 
;буфер чисел - number, в di - номер числа в массиве
	xor ch,ch
	mov cl,kol
	xor bh,bh
	mov bl,cl
	dec bl
	mov si,1  ;в si вес разряда
n1:
    mov al,[string+bx]
	xor ah,ah
	cmp al,2dh;проверим знак числа
	je otr    ; если число отрицательное
	sub al,30h
	mul si
	add [numbers+di],ax
	mov ax,si
	mov si,10
	mul si
	mov si,ax
	dec bx
	loop n1
	jmp n2
otr:
	neg [numbers+di];представим отрицательное число в дополнительном коде
n2:
	ret
AscToBin ENDP

BinToAsc PROC
;преобразование числа в строку
;число передается через ax
	xor si,si
	add si,5
	mov bx,10
	push ax
	cmp ax,0
	jnl mm1
	neg ax
mm1:
	cwd
	idiv bx
	add dl,30h
	mov [out_str+si],dl
	dec si
	cmp ax,0
	jne mm1
	pop ax
	cmp ax,0
	jge mm2
	mov [out_str+si],2dh
mm2:
	ret
BinToAsc ENDP
exit:

end start