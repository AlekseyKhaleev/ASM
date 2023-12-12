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
	mov dx,offset text
	mov ah,0ah
	int 21h

	; проверка на ввод ctrl+x (= выход)
	add dx, 2
	mov bx, dx
	mov bx, [bx]
	cmp bl, 18h
	je exit

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
    NUMS_SIZE dw 5
    start_mess db 'Input:5 numbers in [-32768, 32767]',10,13, 'Press <Enter> after each number',10,13,'$'
    input_mess db 'Enter number: $'
    carret db 10, '$'
    tmp_num db 7 dup(0)
    in_str db 9, 8 dup (0)    ;строка символов (не более 9)
    out_str db 6 dup (' '),'$'


    err_mess db 'Input error!','$'
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
    mov cx, NUMS_SIZE ; в cx - размер массива

vvod:
    push cx
    print input_mess  ;вывод сообщения о вводе строки
    input in_str      ;ввод числа в виде строки
    ; проверки, заполнение массивов
    xor dx, dx
    mov dx, offset in_str
    call to_decimal

    print carret
    loop vvod
    jmp exit

exit:
    print carret
    mov ah, 4ch
    mov al, 0
    int 21h

to_decimal proc
    ; dx - string address
    push cx
    push bx
    push ax

    xor ax, ax
    xor bx, bx

    mov al, 30h
    inc dx
    mov cx, [offset dx]
    xor ch, ch
    inc dx
    .cycle:
        cmp byte ptr [dx], 2dh
        jne .positive
        inc dx
    .positive:
        mov bx, [offset dx]
        xor bh, bh
        sub bx, ax
        mov [offset dx], bl
        dec cl
        loop .cycle
    pop cx
    pop bx

to_decimal endp

end start