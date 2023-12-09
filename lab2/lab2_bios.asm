.model tiny
.code
org 100h
START:
    ; Установить видеорежим 3
    mov ah, 0
    mov al, 3
    int 10h

    ; Получить дату BIOS
    mov ah, 4
    int 1Ah

    ; ES:DI указывает на начало видеопамяти
    mov ax, 0B800h
    mov es, ax
    xor di, di

    ; Выводим строку 'BIOS date: '
    mov si, offset BIOS_date_string
print_string:
    lodsb
    or al, al
    jz print_date
    mov [es:di], al
    mov [es:di+1], 07h
    add di, 2
    jmp print_string

print_date:
    mov ax, cx ; Год
    call number_to_string
    mov [es:di], '/'
    add di, 2
    mov ax, dh ; Месяц
    call number_to_string
    mov [es:di], '/'
    add di, 2
    mov ax, dl ; День
    call number_to_string

    ; Завершить программу
    mov ax, 4C00h
    int 21h
BIOS_date_string db 'BIOS date: ', 0
number_to_string:
    ; число в AX, указатель на буфер в DI
    push ax
    push bx
    push cx
    mov cx, 10
convert_loop:
    xor dx, dx
    div cx
    add dx, '0'
    push dx
    or ax, ax
    jnz convert_loop
write_loop:
    pop dx
    cmp dx, '0'
    je end_convert
    mov [es:di], dl
    inc di
    jmp write_loop
end_convert:
    pop cx
    pop bx
    pop ax
    ret
END START