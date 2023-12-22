

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
	jmp .end_program
.not_exit:
	; возврат состояния из стека
    pop bx
	pop dx
	pop ax
endm

exit macro
    ; завершение программы
    mov ah, 4ch
    mov al, 0
    int 21h
    ret
endm