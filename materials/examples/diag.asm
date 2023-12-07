;программа вывода диагонали символов с последовательным их стиранием
;программа типа .com, трансл€ци€ tasm diag, компоновка tlink /t diag
; реакци€ на F10, жмем , если надоест смотреть

.model tiny
.code
.286	; чтобы использовать команды pusha popa
org 100h
start:
diag_line proc
	mov ax,0003  ;очистка экрана, видеорежим 25*80
	int 10h
;сообщение о F10
	mov ah,9
	mov dx,offset mess
	int 21h

	mov dx,0100h ; начать со строки 1 в столбце 0
m: 	mov ah,1
	int 16h
	cmp ax,4400h;   если  F10, то выход
	je m1

	mov ah,2 ; установить курсор
	mov bh,0
	int 10h

	mov al,'@' ;вывести символ на экран
	mov cx,1
	mov ah,10
	int 10h

	call dly_time ;вызов процедуры задержки времени

	sub al,al  ;стереть символ 
	mov ah,10
	int 10h

	inc dh ;указать на позицию в следующей строке  
	add dl,3 ; +3 к номеру столбца, так диагональ лучше
	
	cmp dh,25 ;нижн€€ строка экрана ?
	jne m
m1:	ret ;выйти из процедуры
diag_line endp
;процедура генерирующа€ паузу
dly_time proc 
	pusha
	mov ah,2ch; получить врем€:	ch-час, cl - мин, dh-сек, dl-сота€ дол€ сек
	int 21h
	add dh,1; задержка  1 сек
	cmp dh,60
	jb m2
	sub dh,60; скорректируем, если получили значение больше 60 сек
m2:	mov sec,dh; сохраним
check:	mov ah,2ch; спрашиваем врем€
	int 21h
	cmp dh,sec; сравниваем с заданным
	jne check ; если врем€ не вышло - опрос
	popa ; иначе - выход
	ret
dly_time endp
sec db ?
mess db 'You can press F10 for exit$'	
end start
