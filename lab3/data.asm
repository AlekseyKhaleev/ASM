.data
    NEGATIVE         equ 2Dh ; шестнадцатеричный ascii код знака '-'
    NUMS_SIZE        equ 8h  ; количество вводимых чисел
    MAX_POS_LEN      equ 5h  ; максимальная длина положительного числа
    MAX_NEG_LEN      equ 6h  ; максимальная длина отрицательного числа с учетом знака
    POS_MAX_LAST     equ 37h ; младший разряд верхнего ограничения (ascii, hex)
    NEG_MAX_LAST     equ 38h ; младший разряд нижнего ограничения (ascii, hex)
    MAX_NUM    db '3276' ; старшие разряды модуля максимального числа без последнего разряда

    ; текстовые переменные для вывода
    start_mess db 'Input: 8 numbers in [-32768, 32767]', 10, 'Press <Enter> after each number',10,13,'$'
    input_mess db 'Enter number: $'
    output_mess db 'output (sum of pairwise products of numbers of different signs):', 10, 13, '$'
    empty_mess db 'Input Error: empty string. Try again or use ctrl+x and press enter for exit.', 10, '$'
    exit_mess  db 'Program was aborted by keybord', 10, '$'
    err_mess   db 'Input error!', 10, '$'
    no_pairs_mess db 'An error occurred: all numbers have the same sign', 10, '$'
    carret     db 10, '$'

    ; буферные переменные
    tmp_res    db 10 dup(0)          ; переменная для промежуточного сохранения результата сложения/умножения
                                     ; двух десяти-разрядных беззнаковых двоично-десятичных чисел
    tmp_num    db 0, 10 dup(?)       ; переменная для промежуточного сохранения двоично-десятичного представления числа
                                     ; первый байт tmp_num - знаковый,
                                     ; все операции над 10 разрядными двоично-десятичными числами (с незначащими нулями)
    in_str     db 7, ?, 6 dup (?)      ; буфер ввода 1 байт размер буфера, второй -количество введенных символов
    res_str    db 12 dup ('$')       ; буфер для преобразования результата в строку
                                     ; (произведения разных знаков, а также их последующие суммы всегда отрицательны)

    ; массивы, первый байт в массиве для учета количества записанных чисел
    pos_array  db 0, 4 dup(10 dup(?)) ; массив для пяти модулей положительных двоично-десятичных чисел размером 5 байт
    neg_array  db 0, 4 dup(10 dup(?)) ; массив для пяти модулей отрицательных двоично-десятичных чисел размером 5 байт
    mul_array  db 0, 4 dup(10 dup(?)) ; массив модулей поэлементных произведений массивов

    ; флаги
    neg_flag   db 0     ; флаг наличия знака '-' для is_correct proc
    err_flag   db 0     ; флаг ошибки во вводе для is_correct proc/цикла ввода
    no_pairs_flag db 0  ; флаг ошибки, сигнал о том. что ввдены числа одного знака

