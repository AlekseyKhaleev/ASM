.8086
.MODEL SMALL

include macros.asm
include data.asm

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
    call sum_mul_array
    call result_to_string
    print res_str
    print carret

.end_program:
    exit ; завершение программы

include func.asm

.stack
    db 100h dup(?)

end start