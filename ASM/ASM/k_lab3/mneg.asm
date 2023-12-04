;Программа вычисления среднего отрицательных чисел массива x и произведения положительных
vivod macro a
		mov dx,offset a
		mov ah,9
		int 21h
endm
anykey macro
		mov ah,7
		int 21h
endm
win macro xy1,xy2
		mov ax,0600h
		mov cx,xy1
		mov dx,xy2
		mov bh,35h
		int 10h
endm
vivod1 macro pos,stroka,k
local m
		mov dx,pos
		mov si,offset stroka
		mov cx,k
		mov bh,0
m:		push cx
		mov ah,2
		int 10h
		mov al,[si]
		mov cx,1
		mov ah,10
		int 10h
		inc dl
		inc si
		pop cx
		loop m 
endm

d1 SEGMENT PARA PUBLIC 'DATA'
x DW 5,-100,-200,-500,2,-500,100
N = ($-x)/2
pr_pos dw 1
mess_err1 db 10,13,'Add overflow!$'
mess_err2 db 10,13,'Mul overflow!$'

mess_rez1   db 'Middle neg:'
k1=$-mess_rez1
mess_rez2   db 'Mul pos:'
k2=$-mess_rez2

rez1 dw ?
str_symb db  6 dup (' '),'$'
flag db 0
d1 ENDS
st1 SEGMENT PARA STACK 'STACK'
	DW 50 DUP (?)
st1 ENDS
s1 SEGMENT para public 'CODE'
ASSUME CS:s1, DS:d1, SS:St1
start: 	mov ax, d1
       	mov ds, ax 
		mov ax,0003h
		int 10h
		call sred 
		mov str_symb,'-'
		mov ax,rez1
		neg ax
		call symb
		cmp flag,0
		je co
		jmp fin
co:		win 0200h,0515h               
           	vivod1 0302h,mess_rez1,k1
		vivod1 0402h,str_symb,6
		call clear
		call proiz
		cmp flag,0
		je  co1
		jmp fin
co1:		mov ax,pr_pos
		call symb
		win 0226h,0539h
		vivod1 0328h,mess_rez2,k2
		vivod1 0428h,str_symb,6
fin:   		anykey
    		mov ax, 4c00h
       		int 21h
sred proc 
	      	xor ax,ax
      		xor bx,bx	
	      	mov cx,N
      		mov si,offset x
next:  		cmp word ptr [si],0
	      	jg  m1
      		add ax,[si];накопление суммы
	      	jo ovf
      		inc bl	;количество отрицательных
m1:	    	inc si
      		inc si
     		loop next
       		cwd
       		idiv bx
		mov rez1, ax ; среднее 
		jmp no_err
ovf: 		vivod mess_err1
		mov flag,1
no_err:		ret
sred endp
proiz proc 
		mov si,offset x
		mov cx,N
mm1:		cmp word ptr [si],0
		jl next1
		mov ax,pr_pos
		mul word ptr[si]
		jc ovf1
		mov pr_pos,	ax
next1:		inc si
		inc si
		loop mm1
		jmp no_err1
ovf1:		vivod mess_err2
		mov flag,1
no_err1:	ret
proiz endp
		
symb proc
		mov si, offset str_symb+5
		mov bx,10
m5:		cwd
		div bx
		add dl,30h
		mov [si],dl
		dec si
		cmp ax,0
		jne m5
		ret
symb endp
		
clear proc
		mov si,offset str_symb
		mov cx,6
next2:	mov byte ptr[si],' '
		inc si
		loop next2
		ret
clear endp
s1 ENDS

end start