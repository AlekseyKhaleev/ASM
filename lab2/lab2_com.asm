;пересылка слов(W) из in_str в out_str 21-ВМз-4 07/12/2023
;слова, не равные '01' ~ 3031h, '23' ~ 3233h, '45' ~ 3435h
.model tiny
.data
mess1 db '21_vmz_4|A_Khaleev Input:',10,13,'$'
mess2 db 10,13,'Output:',10,13,'$'
in_str db 22 dup (?)
out_str db 22 dup ('$')

.code
ORG 100h ; COM-программы начинаются с этой точки
start:
;приглашение ввода:
		mov dx,offset mess1
		mov ah,9
		int 21h	
;ввод:
		mov dx,offset in_str
		mov in_str, 16 ; ограничиваем ввод 16ю байтами
		mov ah,10
		int 21h

;основная часть (модифицированный код из ЛР1):
		mov si,offset in_str+2 ; первые 2 байта служебные
		mov di,offset out_str
		xor ah, ah  ; Очистка старшего байта ax
		mov al,in_str+1 ; помещаем в al количество введенных байт символов
		xor dx, dx  ; Очистка dx перед div, так как div использует dx:ax
        mov bl, 2   ; Делитель
        div bl      ; ax/bl -> результат в al, остаток в ah
        mov cl, al  ; так как оперируем словами данных в регистр счетчика записываем значение деленное на 2
        test ah, ah ; Проверка, есть ли остаток
        jz noRemainder ; Если остатка нет, переход к метке noRemainder
        inc cl      ; Если был остаток, увеличиваем cl на 1
noRemainder:
        ; Здесь cl содержит количество слов, учитывая нечетное количество байт
		xor ch,ch    ; очистка старшего байта счетчика
cmp_cycle:
        mov ax,[si]  ; помещаем первое считанное слово в ax (байты переставлены)
        xchg ah, al  ; обменять местами старший и младший байты
		cmp ax,3031h ; 3031h ~ '01'
		je cmp_true  ; если равно - пропуск
		cmp ax,3233h ; 3233h ~ '23'
		je cmp_true  ; если равно - пропуск
		cmp ax,3435h ; 3435h ~ '45'
		je cmp_true  ; если равно - пропуск
        xchg ah, al  ; обменять местами старший и младший байты
		mov [di], ax ; запись в выходной массив
		add di, 2    ; увеличиваем выходной указатель на 2 (работаем со словами)
cmp_true:
        add si, 2    ; увеличиваем входной указатель на 2 (работаем со словами)
		loop cmp_cycle ; пока регистр счетчика не равен 0 выполняем цикл cmp_cycle

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

end start
	