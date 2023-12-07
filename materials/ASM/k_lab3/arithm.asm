;font "Terminal"!!!
.model small
p1 macro a
	mov ah,9
	mov dx,offset a
	int 21h
endm
_clear macro
local m
	mov si,offset string
	mov cx,6
m:	mov byte ptr [si],' '
	inc si
	loop m
endm	
vivod macro y1,y2
local m
	p1 y1
	mov ax,y2
	cmp ax,0
	jge m
	neg ax
	mov string,'-'
m:	call _ascii
	p1 string
	_clear
endm
		
.data 
;Числа должны быть в диапазоне -32768 +32767 
massiv dw 10,20,-10,3,-5
N=($-massiv)/2
error1 db 10,13,'Addition overflow!',10,13,'$'
error2 db 10,13,'Multiplication overflow!',10,13,'$'
res1 db 10,13,'Sum of negative:$'
res2 db 10,13,'Sum of positive:$'
res3 db 10,13,'Summa:$'
res4 db 10,13,'Middle negative:$'
res5 db 10,13,'Middle positive:$'
res6 db 10,13,'Min number:$'
res7 db 10,13,'Max number:$'
res8 db 10,13,'Middle:$'
res9 db 10,13,'Multiplication:$'
errflag db 0
sum_neg dw 0
sum_pos dw 0
sum dw ?	
_min dw 0
_max dw 0	
n_neg dw 0
n_pos dw 0
sred_neg dw ?
sred_pos dw ?
sred dw ?
pr dw ?
string db 6 dup (' '),'$'
.stack 256
.code
start:	mov ax,@data
		mov ds,ax
		mov ax,0003h
		int 10h
		call summa
		cmp errflag,1
		jne add_all
		jmp _err1
add_all:	mov ax,sum_neg	
		add ax,sum_pos	
		mov sum,ax
		call srednee
     		vivod res1,sum_neg
		vivod res2,sum_pos
		vivod res3,sum
		vivod res4,sred_neg
		vivod res5,sred_pos
		vivod res6,_min
		vivod res7,_max	
		vivod res8,sred
		jmp m3
_err1:	p1 error1
m3:		mov errflag,0
		call proizv
		cmp errflag,1
		je _err2
		vivod res9,pr
		jmp _end
_err2:	p1 error2
_end:		mov ah,8
		int 21h
		mov ax,4c00h
		int 21h

summa proc
		mov cx,N
		mov si,offset massiv
next:		mov ax,[si]
		cmp ax,0
		jg m1
		add sum_neg,ax	;сумма отрицательных
		jo f_err
		inc n_neg		;число отрицательных
		cmp ax,_min
 		jge m2
		mov _min,ax
		jmp m2
m1:		add sum_pos,ax	;сумма положительных
		jno no_err
f_err:	mov errflag,1
		jmp _exit
no_err:	inc n_pos		;число положительных
		cmp ax,_max
		jle m2
		mov _max,ax
m2:		inc si
		inc si
		loop next
_exit:	ret
summa endp
srednee proc
		cwd
		mov bx,n_neg
		add bx,n_pos
		idiv bx
		mov sred,ax		;среднее
irp z,<neg,pos>
		mov ax,sum_&z
		cwd
		mov bx,n_&z
		idiv bx
		mov sred_&z,ax	;среднее положительных, среднее отрицательных
endm
		ret
srednee endp
proizv proc
		mov cx,N-1
		mov si,offset massiv
		mov ax,[si]
_mul:		mov bx,[si+2]
		imul bx
		jo ovf
		inc si
		inc si
		loop _mul
		mov pr,ax
		jmp mm
ovf:		mov errflag,1
mm:		ret
proizv endp
	

;преобразование слова из ax в ASCII строку string
_ascii proc
		mov si,offset string+5
		mov bx,10
m4:		cwd
		div bx
		add dl,30h
		mov [si],dl
		dec si
		cmp ax,0
		jne m4
		ret
_ascii endp
end start	
	