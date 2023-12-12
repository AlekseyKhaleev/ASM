.MODEL SMALL

print macro text ;вывод сообщений на экран
	push ax
	push dx
	mov dx,offset text
	mov ah,9
	int 21h
	pop dx
	pop ax
endm

input macro text ;ввод строки символов
    ; сохранение состояния в стеке
	push ax
	push dx
	push bx

    ; запись ввода в буфер text
.retry:
	mov dx,offset text
	mov ah,0ah
	int 21h

	inc dx
	mov bx, dx
	mov bl, [bx] ; количество введенных символов
	cmp bl, 0h   ; проверка на пустую строку
	jne .not_empty
	print empty_mess
    print input_mess
    jmp .retry

.not_empty:
    mov bx, dx
	inc bx
	mov bl, [bx] ; первый введенный символ
	cmp bl, 18h  ; проверка на ввод ctrl+x (= выход)
	jne .not_exit
	print exit_mess
	jmp exit
.not_exit:
	; возврат состояния из стека
    pop bx
	pop dx
	pop ax


endm

in_to_out macro
    push bx
    push si
    push dx

    xor bx, bx
    xor si, si
    xor dx, dx

    mov bx, offset in_str
    add bx, 2
    mov si, offset out_str
    mov dx, [bx]
;    xor dh, dh
    mov [si], dx

    pop dx
    pop si
    pop bx
endm

.data
    NUMS_SIZE        equ 5h
    NEGATIVE         equ 2Dh
    MAX_DIGITS_COUNT equ 5h
    POS_LAST         equ 37h
    NEG_LAST         equ 38h

    MAX_NUM db '3276' ; старшие разряды модуля максимального числа без последнего разряда

    start_mess db 'Input:5 numbers in [-32768, 32767]',10,13, 'Press <Enter> after each number',10,13,'$'
    input_mess db 'Enter number: $'
    empty_mess db 'Input Error: empty string. Try again or use ctrl+x and press enter for exit.', 10, '$'
    exit_mess  db 'Program was aborted by keybord', 10 ,'$'
    err_mess db 'Input error!','$'
    carret     db 10, '$'

    tmp_num db 7 dup(0)
    in_str db 7, ?, 7 dup (?)    ;строка символов (не более 6)
    out_str db 6 dup (' '),'$'

    neg_flag db 0
    flag_err db 0

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
    mov cx, NUMS_SIZE ; в cx - размер массива

    vvod:
        push cx
        print input_mess  ;вывод сообщения о вводе строки
        input in_str      ;ввод числа в виде строки

        ; проверки, заполнение массивов
        xor si, si
        mov si, offset in_str
        call to_decimal

        print carret
        loop vvod
    jmp exit

exit:
    mov ah, 4ch
    mov al, 0
    int 21h

to_decimal proc
    ; Процедура для перевода числа из ascii в десятичное представление. Знак минуса останется ascii
    ; В регистре si ожидается адрес буфера ввода
    ;   1й байт: размер буфера
    ;   2й байт: количество действительных символов (включая знак минус)
    ;   с первого по предпоследний: ascii символы введенного числа
    ; Результат:
    ; в буфере tmp_num записано десятичное представление введенного числа,
    ; первый байт - размер, включая знак минус (при наличии)

    ; сохранение состояния
    push ax ; используется для хранения числа 30h
    push bx ; используется для получения ascii-кода очередного символа
    push cx ; используется в роли счетчика обработанных символов
    push di ; используется для адресных операций записи в буфер tmp_num

    ; предварительная очистка регистров
    xor ax, ax
    xor bx, bx

    ; начальная инициализация
    mov al, 30h
    mov di, offset tmp_num

    ; инициализируем счетчик числом символов в строке
    inc si
    mov cx, [si]
    xor ch, ch ; чистим старший(лишний) байт
    mov [di], cl ; запись в выходной буфер количества символов числа

    ; двигаем указатель на первый символ во входном и выходном буфере
    inc di
    inc si

    ; проверка на наличие символа "минус", если есть то записываем в выходной буфер без изменений
    ; и двигаем указатель, если нет прыгаем к основному циклу обработки
    cmp byte ptr [si], NEGATIVE
        jne .cycle
        mov bx, [si]
        xor bh, bh
        mov [di], bl
        inc si
        inc di
        dec cx
    ; основной цикл - получаем ascii код, вычитаем из него 30 (так как символы 0-9 имеют коды 30-39)
    ; записываем в выходной буфер, двигаем указатели
    .cycle:
        mov bx, [si]
        xor bh, bh
        sub bx, ax
        mov [di], bl
        inc si
        inc di
        loop .cycle

    ; восстанавливаем исходное состояние регистров
    pop di
    pop cx
    pop bx
    pop ax

    ret

to_decimal endp

is_correct proc
    ; Процедура для проверки корректности введенного числа
    ; число должно быть записано в буфер in_str
    ; корректный диапазон - [-32768, 32767]

    push ax ; используется для хранения текущего символа
    push bx ; используется для хранения индекса в диапазоне
    push cx ; используется для хранения индекса в числе
    push dx ; используется для хранения последнего символа диапазона в зависимости от знака

    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx

    mov neg_flag, 0 ; флаг для хранения знака числа
    mov cl, 2      ; Инициализация текущего индекса
    mov bl, 0

    mov al, in_str[cl]; Загрузка текущего элемента буфера в AL
    cmp al, NEGATIVE
    jne .iterate
    mov neg_flag, 1
    inc cl
.is_num_cycle:

; здесь должна быть проверка количества символов если оно максимальное то идем в .range_cycle

.range_cycle:
    mov al, in_str[cl] ; Загрузка текущего элемента буфера в AL
    cmp al, MAX_NUM[bx]
    jne .error
    inc cl            ; Увеличение индекса числа
    inc bl            ; Увеличение индекса диапазона
    cmp cl, in_str[1] ; Проверка, достигнут ли конец буфера
    je .end_range     ; Если да, прерывание цикла
    jmp .range_cycle  ; Переход на следующую итерацию цикла

.end_range:           ; проверка последнего символа если число значащих цифр равно максимальному
    cmp neg_flag, 1
    je .negative
    mov dx, POS_LAST
    jmp .continue
.negative:
    mov dx, NEG_LAST
.continue:
    cmp dx, al
    jne .error        ; если есть выход за границу диапазона переход к ошибке
    jmp .corr_end

.error:
    print overflow_mess
    mov err_flag, 1

.corr_end:
    ret
is_correct endp

end start