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
    ; константы
    NEGATIVE         equ 2Dh ; шестнадцатеричный ascii код знака '-'
    NUMS_SIZE        equ 8h  ; количество вводимых чисел
    MAX_POS_LEN      equ 5h  ; максимальная длина положительного числа
    MAX_NEG_LEN      equ 6h  ; максимальная длина отрицательного числа с учетом знака
    POS_MAX_LAST     equ 37h ; младший разряд верхнего ограничения (ascii, hex)
    NEG_MAX_LAST     equ 38h ; младший разряд нижнего ограничения (ascii, hex)

    MAX_NUM    db '3276' ; старшие разряды модуля максимального числа без последнего разряда

    ; текстовые переменные для вывода
    start_mess db 'Input: 6 numbers in [-32768, 32767]', 10, 'Press <Enter> after each number',10,13,'$'
    input_mess db 'Enter number: $'
    empty_mess db 'Input Error: empty string. Try again or use ctrl+x and press enter for exit.', 10, '$'
    exit_mess  db 'Program was aborted by keybord', 10, '$'
    err_mess   db 'Input error!', 10, '$'
    carret     db 10, '$'

    ; буферные переменные
    tmp_res    db 10 dup(?)          ; переменная для промежуточного сохранения результата сложения/умножения
                                     ; двух десяти-разрядных беззнаковых двоично-десятичных чисел
    tmp_num    db 0, 10 dup(?)       ; переменная для промежуточного сохранения двоично-десятичного представления числа
                                     ; первый байт tmp_num - знаковый,
                                     ; все операции над 10 разрядными двоично-десятичными числами (с незначащими нулями)
    in_str     db 7, ?, 6 dup (?)    ; буфер ввода 1 байт размер буфера, второй -количество введенных символов
    out_str    db 6 dup (' '),'$'    ; буфер вывода

    ; массивы, первый байт в массиве для учета количества записанных чисел
    pos_array  db 0, 4 dup(10 dup(?)) ; массив для пяти модулей положительных двоично-десятичных чисел размером 5 байт
    neg_array  db 0, 4 dup(10 dup(?)) ; массив для пяти модулей отрицательных двоично-десятичных чисел размером 5 байт
    mul_array  db 0, 4 dup(10 dup(?)) ; массив модулей поэлементных произведений массивов

    ; флаги
    neg_flag   db 0     ; флаг наличия знака '-' для is_correct proc
    err_flag   db 0     ; флаг ошибки во вводе для is_correct proc/цикла ввода

    ; проверка сложения
    num1 db 0, 0, 0, 0, 0, 0, 0, 1, 2, 3
    num2 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 3

.stack 256

.code
start:
    ; инициализация памяти
    mov ax, @data
    mov ds, ax

    ;вызов функции 0 -  установка 3 текстового видеорежима, очистка экрана
    mov ax, 0003  ; ah=0 (номер функции), al=3 (номер режима)
    int 10h

    print start_mess  ; вывод стартового сообщения
    xor cx, cx
    mov cx, NUMS_SIZE ; в cx количество чисел для ввода пользователем

    ; инициализация указателей на первые элементы массивов без учета размерного байта (используется в add_value proc)
    mov si, offset pos_array + 1
    mov di, offset neg_array + 1

    ; цикл ввода/проверки/распределения по массивам
    .input:
        print input_mess  ;вывод сообщения о вводе строки
        input in_str      ;ввод числа в виде строки

        ; проверки, заполнение массивов
        call is_correct   ; проверка на корректность символов числа, установка err_flag
        cmp err_flag, 0
        je .correct_input

        ; если была ошибка вывод сообщения и циклический ввод
        print err_mess
        jmp .input

    .correct_input:
        call to_bin_decimal  ; преобразование in_str к двоично-десятичному виду в tmp_num (с незначащими нулями и байтом знака)
        call add_value       ; копирование модуля из tmp_num в соответствующий массив
        print carret         ; печать переноса строки
        loop .input          ; цикл ввода

    ; здесь массивы pos_array и neg_array заполнены модулями соответствующих по знаку введенных чисел
    call fill_mul_array
    mov bx, offset mul_array

    jmp exit

exit:
    ; завершение программы
    mov ah, 4ch
    mov al, 0
    int 21h

clear_tmp_res proc
    push si
    push cx
    mov cx, 10
    mov si, offset tmp_res
    .clear_cycle:
        mov byte ptr [si], 0
        inc si
        loop .clear_cycle
    pop cx
    pop si

    ret
clear_tmp_res endp

fill_mul_array proc
    ; процедура для заполнения массива mul_array попарными произведениями модулей положительных и отрицательных чисел
    ; ожидается что произведен ввод с клавиатуры чисел, числа приведены к двоично-десятичному виду
    ; массивы pos_array и neg_array заполнены модулями положительных и отрицательных чисел соответственно

    ; сохраняем состояние
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; чистим регистры
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    xor si, si
    xor di, di

    ; инициализация счетчика размером меньшего из массивов введенных чисел
    mov bx, offset pos_array
    mov bl, [bx]
    mov al, bl
    mov bx, offset neg_array
    mov bl, [bx]
    cmp al, bl
    jg .pos_bigger
    mov cl, bl
    jmp .counter_initialized
.pos_bigger:
    mov cl, al

.counter_initialized:
    ; инициализация указателей на массивы с модулями чисел
    mov si, offset pos_array + 1
    mov di, offset neg_array + 1

    ; заполнение массива mul_array
    mov bx, offset mul_array
    mov [bx], byte ptr cx   ; запись в массив mul_array количества элементов
    inc bx                  ; двигаем указатель на первый результат
    .prod_loop:
        call mul_values ; в tmp_res результат умножения модулей

        ; копируем результат в массив mul_array
        push cx
        push si
        mov cx, 10
        mov si, offset tmp_res

        .copy_loop:
            mov dl, [si]
            mov [bx], dl
            inc si
            inc bx
            loop .copy_loop
        pop si
        pop cx
        ; здесь копирование завершено

        ; перемещаем указатели к следующим элементам:
        add si, 10
        add di, 10
        loop .prod_loop

    ; восстанавливаем состояние
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    ret     ; возврат
fill_mul_array endp

add_value proc
    ; Процедура для копирования числа из временной переменной в соответствующий массив
    ; число представлено в двоично-десятичном виде с незначащими нулями (размер на выходе 5 байт)
    ; в массивы записываем только модули, увеличиваем количество записанных чисел
    ; в si адрес очередного элемента в массиве положительных чисел
    ; в di адрес очередного элемента в массиве отрицательных чисел
    ; в tmp_num значение очередного введенного и преобразованного числа которое нужно скопировать

    push ax ; используется для увеличения счетчика записанных чисел в массиве и копирования очередной цифры(байта) числа
    push bx ; используется как указатель на tmp_num
    push cx ; счетчик элементов числа для цикла, инициализируется числом 5 (количеством байт в каждом числе)

    ; инициализация счетчика
    xor cx, cx
    mov cx, 10

    mov bx, offset tmp_num ; инициализируем указатель на временную переменную
    mov al, [bx]           ; в al байт знака
    inc bx                 ; перемещаем указатель на первый символ
    cmp al, 0              ; проверка на отрицательное/положительное число
    je .pos_num

    ; увеличиваем счетчик записанных чисел в массиве отрицательных чисел
    mov al, neg_array
    inc al
    mov neg_array, al

    ; по-байтовая запись модуля очередного числа в массив отрицательных чисел
    .neg_cycle:
        mov al, [bx]
        mov [di], al
        inc bx
        inc di
        loop .neg_cycle

    jmp .add_value_exit

    .pos_num:
        ; увеличиваем счетчик записанных чисел в массиве положительных (неотрицательных) чисел
        mov al, pos_array
        inc al
        mov pos_array, al

    ; по-байтовая запись модуля очередного числа в массив положительных (неотрицательных) чисел
    .pos_cycle:
        mov al, [bx]
        mov [si], al
        inc bx
        inc si
        loop .pos_cycle

    ; возврат состояния
    .add_value_exit:
        pop cx
        pop bx
        pop ax
        ret

add_value endp

to_bin_decimal proc
    ; Процедура для перевода числа из ascii в десятичное представление
    ; В выходном массиве первый байт для учета знака (0 неотрицательное(положительное), 1 - отрицательное)
    ; все числа будут выровнены по разрядам (дополнены незначащими нулями)
    ; В in_str содержится буфер ввода
    ;   1й байт: размер буфера
    ;   2й байт: количество введенных символов (включая знак минус)
    ;   с третьего по предпоследний: ascii символы введенного числа
    ;   последний символ завершения ввода - 0Dh
    ; Результат:
    ; в буфере tmp_num записано десятичное представление введенного числа,
    ; первый байт - знаковый
    ; так как при переводе все разряды заполняются новым байтом знака, цифрами разряда или незначащими нулями,
    ; то предварительная очистка буфера перед новой записью не требуется

    ; сохранение состояния
    push ax ; используется для хранения числа 30h и использовании в команде sub
    push bx ; используется для получения ascii-кода очередного символа
    push cx ; используется в роли счетчика обработанных символов
    push dx ; используется для хранения количества незначащих нулей
    push di ; используется для адресации выходного буфера
    push si ; используется для адресации входного буфера

    ; предварительная очистка регистров
    xor ax, ax
    xor bx, bx
    xor dx, dx
    xor si, si
    xor di, di

    mov si, offset in_str
    ; начальная инициализация
    mov al, 30h
    mov di, offset tmp_num

    ; инициализируем счетчик числом символов в строке
    inc si
    mov cx, [si]
    mov dl, [si] ; записываем количество символов
    xor ch, ch   ; чистим старший(лишний) байт

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
        inc di
        jmp .null_filling
    .positive:
        mov [di], 0
        inc di      ; если число позитивное двигаем указатель выходного буфера на первый символ
    .null_filling:  ; заполнение незначащими нулями
        cmp dl, 10  ; все числа десяти разрядные с незначащими нулями
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
    pop di
    pop dx
    pop cx
    pop bx
    pop ax

    ret

to_bin_decimal endp

is_correct proc
    ; Процедура для проверки корректности введенного числа
    ; число должно быть записано в буфер in_str
    ; корректный диапазон - [-32768, 32767]

    ; сохраняем состояние регистров
    push ax ; используется для хранения текущего символа
    push bx ; используется для хранения индекса в диапазоне (проход по константе MAX_NUM)
    push cx ; используется для хранения количества обработанных символов числа
    push dx ; используется для хранения последнего символа диапазона в зависимости от знака
    push si ; используется для хранения индекса в буфере ввода
    push di ; используется для хранения количества введенных символов во входном буфере

    ; очистка используемых регистров
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    xor si, si
    xor di, di

    ; инициализация di количеством символов во входном буфере
    mov di, offset in_str ; помещаем в di адрес буфера ввода
    inc di          ; перемещаем на количество символов записанных в буфер
    mov di, [di]    ; загружаем 2 первых байта из in_str в di
    and di, 00FFh   ; очищаем старший байт

    ; начальная инициализация
    mov neg_flag, 0 ; очистка флага для хранения знака числа
    mov err_flag, 0 ; очистка флага для определения ошибки ввода
    mov si, 2       ; Инициализация индекса числа (пропуск служебных байтов буфера)
    mov bx, 0       ; Инициализация индекса для максимального диапазона

    mov al, in_str[si]; Загрузка текущего элемента буфера в AL
    cmp al, NEGATIVE  ; Является ли первый символ знаком '-'
    jne .is_num_cycle
    mov neg_flag, 1   ; установка флага отрицательного числа
    inc si            ; перемещаем указатель в буфере на следующий байт (символ)
    inc cx            ; увеличиваем счетчик обработанных чисел

    ; проверка: является ли числом каждый введенный символ символ (исключая первый минус)
    .is_num_cycle:
        cmp cx, di           ; если все символы обработаны
        je .max_digits_check ; выход из цикла
        mov al, in_str[si]   ; в al очередной ascii код ввода
        cmp al, 30h          ; 30h - ascii код для числа 0, если меньше - ошибка ввода
        jl .error
        cmp al, 39h          ; 39h - ascii код для числа 9, если меньше - ошибка ввода
        jg .error
        inc cx               ; увеличиваем счетчик
        inc si               ; двигаем указатель
        jmp .is_num_cycle    ; повторяем цикл


    .max_digits_check:
        ; очистка регистров
        xor cx, cx
        xor si, si

        cmp neg_flag, 0     ; проверка знака числа
        je .pos_start

        ; для отрицательных:
        .neg_start:
            cmp di, MAX_NEG_LEN ; сравнение количества введенных символов и максимального количества разрядов
            jl .corr_end        ; если меньше, завершаем без ошибки
            jg .error           ; если больше завершаем с ошибкой
            ; если равно, инициализация и переход к поразрядной проверке
            mov si, 3
            mov cx, 2            ; значение больше на 1 чем действительное чтобы выйти из range_cycle раньше на 1 символ
            jmp .range_cycle

        ; для положительных
        .pos_start:
            cmp di, MAX_POS_LEN ; сравнение количества введенных символов и максимального количества разрядов
            jl .corr_end        ; если меньше, завершаем без ошибки
            jg .error
            ; если равно, инициализация и переход к поразрядной проверке
            mov si, 2
            mov cx, 1

        ; поразрядная проверка диапазона если количество символов модуля равно 5
        .range_cycle:
            mov al, in_str[si] ; Загрузка текущего элемента буфера в AL
            cmp al, MAX_NUM[bx]
            jg .error
            jl .corr_end
            ; если символ равен ограничению:
            inc si            ; Увеличение индекса числа
            inc cx            ; Увеличение счетчика обработанных цифр
            inc bx            ; Увеличение индекса в строке содержащей максимальные цифры диапазона
            cmp cx, di        ; Проверка, достигнут ли конец буфера
            je .end_range     ; Если да, прерывание цикла
            jmp .range_cycle  ; Переход на следующую итерацию цикла

        ; проверка последнего символа если число значащих цифр равно максимальному
        .end_range:
            cmp neg_flag, 1
            je .negative
            mov dl, POS_MAX_LAST
            jmp .continue
        .negative:
            mov dl, NEG_MAX_LAST
        .continue:
            mov al, in_str[si] ; загружаем последний символ
            cmp al, dl
            jg .error          ; если есть выход за границу диапазона переход к ошибке
            jmp .corr_end

    ; завершение с ошибкой
    .error:
        mov err_flag, 1      ; установка флага ошибки

    ; завершение без ошибки
    .corr_end:
        ; восстанавливаем состояние из стека
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret

is_correct endp

sum proc
    ; Процедура для сложения двух неотрицательных десяти разрядных двоично-десятичных чисел
    ; задано ограничение для числа: |-36768| * |36767| = 1 073 709 056, десять разрядов защищают от переполнения
    ; вход:
    ;     si - адрес первого числа
    ;     di - адрес второго числа
    ; результат в tmp_res

    ; сохраняем состояние стека
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; очистка регистров
    xor ax, ax
    xor cx, cx

    mov cx, 10 ; инициализируем счетчик - 10 байт числа = 10 итераций

    ; двигаем указатели на последние разряды (байты) чисел
    add si, 9
    add di, 9

    .sum_cycle:
        ; очистка регистров
        xor bx, bx
        xor dx, dx

        add al, byte ptr [si] ; добавляем очередной разряд первого числа в al, в ax очередной разряд + переполнение
        mov bl, byte ptr [di] ; перемещаем очередной разряд второго числа в bl
        add ax, bx            ; складываем, результат в ax
        mov bx, 10            ; в bx делитель - 10
        div bx                ; в ax результат, в dx остаток от деления на 10 суммы разрядов сложенной с переполнением

        ; инициализируем bx индексом разряда в результирующем буфере (состояние декрементного счетчика - 1)
        mov bx, cx
        dec bx
        mov tmp_res[bx], dl   ; записываем остаток в разряд результата

        ; двигаем указатели в слагаемых
        dec si
        dec di

        loop .sum_cycle       ; уменьшаем cx, переходим к следующей итерации

    ; восстанавливаем состояние стека
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    ret
sum endp

mul_values proc
    ; процедура для умножения двух неотрицательных десяти разрядных двоично-десятичных чисел
    ; в si - адрес первого числа
    ; в di - адрес второго числа
    ; результат - в tmp_res

    push ax
    push bx
    push cx
    push si
    push di

    xor ax, ax
    xor bx, bx
    xor cx, cx

    call to_hex_decimal ; преобразование второго числа к десятичному виду, результат в cx
    dec cx
    mov di, si          ; умножение реализуем как сложение num1 с самим собой num2 - 1 раз
    .add_cycle:
        call sum        ; результат сложения дв/дес чисел из si и di в tmp_res
        mov si, offset tmp_res
        loop .add_cycle

    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret
mul_values endp

to_hex_decimal proc
    ; Процедура для перевода числа из двоично-десятичного в десятичное представление в шестнадцатеричной записи
    ; В регистре di ожидается адрес двоично-десятичного числа
    ; Результат:
    ; в cx записано шестнадцатеричное представление  десятичного числа
    ; данная процедура необходима для инициализации счетчика для процедуры умножения чисел
    ; так как в данной программе задано ограничение по модулю для вводимого числа равное 32768,
    ; то переполнения регистра cx не случится в процессе перевода числа в нужный вид


    ; сохранение состояния
    push ax ;
    push bx ; множитель 10
    push si ; для умножения на разряд
    push di ; адрес числа которое нужно преобразовать

    ; предварительная очистка регистров
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor si, si

    ; Преобразование в десятичное число (в шестнадцатеричном представлении)
    mov cx, 0       ; счетчик для суммирования числа
    mov bx, 10      ; множитель для умножения предыдущей суммы на 10
    mov si, 10      ; в si количество разрядов числа (возможны незначащие нули слева)

.convert_loop:
    cmp si, 0
    je .conv_end
    xor ax, ax
    mov al, [di]    ; загружаем символ из строки
    cmp al, 0
    je .zero_rank
    push si         ; сохраняем текущее значение обрабатываемого разряда

; умножаем очередной разряд на 10 соответствующее количество раз
.rank_mul:
    dec si
    cmp si, 0
    je .conv_cont
    mul BX          ; умножаем предыдущую сумму на 10
    jmp .rank_mul

.conv_cont:
    pop si
    add CX, AX      ; добавляем текущее значение к сумме
.zero_rank:
    inc di          ; переходим к следующему символу
    dec si
    jmp .convert_loop


.conv_end:
    pop di
    pop si
    pop bx
    pop ax

    ret
to_hex_decimal endp

end start