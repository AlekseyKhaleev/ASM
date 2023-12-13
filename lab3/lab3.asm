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
    MAX_POS_COUNT    equ 5h
    MAX_NEG_COUNT    equ 6h
    POS_LAST         equ 37h
    NEG_LAST         equ 38h

    MAX_NUM    db '3276' ; старшие разряды модуля максимального числа без последнего разряда

    start_mess db 'Input:5 numbers in [-32768, 32767]', 10, 'Press <Enter> after each number',10,13,'$'
    input_mess db 'Enter number: $'
    empty_mess db 'Input Error: empty string. Try again or use ctrl+x and press enter for exit.', 10, '$'
    exit_mess  db 'Program was aborted by keybord', 10, '$'
    err_mess   db 'Input error!', 10, '$'
    carret     db 10, '$'

    tmp_num    db 6 dup(0)
    in_str     db 7, ?, 6 dup (?)    ;строка символов (не более 6)
    out_str    db 6 dup (' '),'$'
    pos_array  db 0, 5 dup(5 dup(?)) ; объявление массива для пяти положительных двоично-десятичных чисел размером 6 байт
    neg_array  db 0, 5 dup(5 dup(?)) ; объявление массива для пяти отрицательных двоично-десятичных чисел размером 6 байт
    ; первый байт для размера записанных чисел

    neg_flag   db 0
    err_flag   db 0

.stack 256

.code
start:
    mov ax, @data
    mov ds, ax


;вызов функции 0 -  установка 3 текстового видеорежима, очистка экрана
    mov ax,0003  ;ah=0 (номер функции),al=3 (номер режима)
    int 10h
    print start_mess

;цикл ввода, di - номер числа в массиве
    mov cx, NUMS_SIZE ; в cx - размер массива
    mov si, offset pos_array + 1
    mov di, offset neg_array + 1

    .input:
        print input_mess  ;вывод сообщения о вводе строки
        input in_str      ;ввод числа в виде строки

        ; проверки, заполнение массивов
        ; проверка на корректность символов числа
;        call is_correct
        cmp err_flag, 0
        je .correct_input
        print err_mess
        jmp .input

    .correct_input:
        ; здесь установлен флаг отрицательного числа
        call to_decimal
        call add_value
        print carret
        loop .input
    jmp exit

exit:
    mov ah, 4ch
    mov al, 0
    int 21h

add_value proc
    ; в si адрес очередного элемента в массиве положительных чисел
    ; в di адрес очередного элемента в массиве отрицательных чисел
    ; в tmp_num значение очередного введенного числа которое нужно скопировать
    ; в массивы записываем только модули, увеличиваем количество записанных чисел
    push ax
    push bx
    push cx

    xor cx, cx
    mov cx, 5

    mov bx, offset tmp_num
    mov al, [bx]
    inc bx   ; перемещаем указатель на первый символ
    cmp al, 0
    je .pos_num
    mov al, neg_array
    inc al
    mov neg_array, al

.neg_cycle:
    mov al, [bx]
    mov [di], al
    inc bx
    inc di
    loop .neg_cycle
.pos_num:
    mov al, pos_array
    inc al
    mov pos_array, al
.pos_cycle:
    mov al, [bx]
    mov [si], al
    inc bx
    inc si
    loop .pos_cycle

    pop cx
    pop bx
    pop ax
    ret
add_value endp

to_decimal proc
    ; Процедура для перевода числа из ascii в десятичное представление. Знак минуса останется ascii
    ; также в выходном массиве первый байт для учета знака (0 неотрицательное(положительное), 1 - отрицательное)
    ; все числа будут выровнены по разрядам (дополнены незначащими нулями)
    ; В in_str содержится буфер ввода
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
    push dx ; используется для хранения количества незначащих нулей
    push si ; используется для адресации входного буфера

    ; предварительная очистка регистров
    xor ax, ax
    xor bx, bx
    xor dx, dx
    xor si, si

    mov si, offset in_str
    ; начальная инициализация
    mov al, 30h
    mov di, offset tmp_num

    ; инициализируем счетчик числом символов в строке
    inc si
    mov cx, [si]
    mov dl, [si] ; записываем количество символов
    xor ch, ch ; чистим старший(лишний) байт

    ; двигаем указатель на первый символ во входном буфере
    inc si

    ; проверка на наличие символа '-', если присутствует, записываем байт знака в выходной буфер
    ; по умолчанию байт знака инициализирован нулем, что соответствует неотрицательному числу
    ; и двигаем указатель, если нет прыгаем к основному циклу обработки
    cmp byte ptr [si], NEGATIVE
        jne .positive
        mov [di], 1
        inc si
        dec cx
        dec dl      ; если был знак минус уменьшаем количество символов в буфере на 1
    .positive:
        inc di      ; если число позитивное двигаем указатель выходного буфера на первый символ
    .null_filling:  ; заполнение незначащими нулями
        cmp dl, MAX_POS_COUNT
        jge .cycle
        mov [di], 0
        inc di
        inc dl
        jmp .null_filling

    ; основной цикл - получаем ascii код, вычитаем из него 30 (так как символы 0-9 имеют коды 30-39)
    ; записываем в выходной буфер, двигаем указатели
    .cycle:
        mov bx, [si]
        xor bh, bh
        sub bx, ax    ; в bl результат вычитания
        mov [di], bl
        inc di
        inc si
        loop .cycle

    ; восстанавливаем исходное состояние регистров
    pop si
    pop dx
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

    ; сохраняем состояние регистров
    push ax ; используется для хранения текущего символа
    push bx ; используется для хранения индекса в диапазоне
    push cx ; используется для хранения количества обработанных символов числа
    push dx ; используется для хранения последнего символа диапазона в зависимости от знака
    push si ; используется для хранения индекса числа
    push di ; используется для хранения индекса по которому записано количество введенных символов

    ; очистка
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    xor si, si
    xor di, di

    mov di, offset in_str
    inc di
    mov di, [di]    ; загружаем 2 первых байта из in_str  di
    and di, 00FFh   ; очищаем старший байт

    mov neg_flag, 0 ; флаг для хранения знака числа
    mov err_flag, 0 ; флаг для определения ошибки ввода
    mov si, 2       ; Инициализация текущего индекса числа
    mov bx, 0       ; Инициализация текущего индекса в максимальном диапазоне

    mov al, in_str[si]; Загрузка текущего элемента буфера в AL
    cmp al, NEGATIVE
    jne .is_num_cycle      ; если первый символ не '-'
    mov neg_flag, 1
    inc si
    inc cx

; проверка: является ли числом каждый введенный символ символ (не включая первый минус)
.is_num_cycle:
    cmp cx, di
    ; здесь должна быть проверка на превышение количества цифр для положительных цифр?
    je .max_digits_check ; выход из цикла
    mov al, in_str[si]
    cmp al, 30h
    jl .error
    cmp al, 39h
    jg .error
    inc cx
    inc si
    jmp .is_num_cycle

.max_digits_check:
    xor cx, cx
    xor si, si

    cmp neg_flag, 0
    je .pos_start
    cmp di, MAX_NEG_COUNT
    jl .corr_end
    jg .error
    mov si, 3
    mov cx, 2         ; значение больше на 1 чем действительное чтобы выйти из range_cycle раньше на 1 символ
    jmp .range_cycle

.pos_start:
    cmp di, MAX_POS_COUNT
    jl .corr_end
    jg .error
    mov si, 2
    inc cx

.range_cycle:
    mov al, in_str[si] ; Загрузка текущего элемента буфера в AL
    cmp al, MAX_NUM[bx]
    jg .error
    jl .corr_end
    inc si            ; Увеличение индекса числа
    inc cx            ; Увеличение счетчика обработанных цифр
    inc bx            ; Увеличение индекса в строке содержащей максимальные цифры диапазона
    cmp cx, di        ; Проверка, достигнут ли конец буфера
    je .end_range     ; Если да, прерывание цикла
    jmp .range_cycle  ; Переход на следующую итерацию цикла

.end_range:           ; проверка последнего символа если число значащих цифр равно максимальному
    cmp neg_flag, 1
    je .negative
    mov dl, POS_LAST
    jmp .continue
.negative:
    mov dl, NEG_LAST
.continue:
    mov al, in_str[si]
    cmp al, dl
    jg .error        ; если есть выход за границу диапазона переход к ошибке
    jmp .corr_end

.error:
    mov err_flag, 1

.corr_end:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

is_correct endp

end start