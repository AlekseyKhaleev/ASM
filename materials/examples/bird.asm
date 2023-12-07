CURSOR MACRO
       MOV AH,2
       MOV BH,0
       INT 10h
ENDM

ATTR MACRO
     MOV AH,9
     MOV BH,0
     INT 10h
ENDM

curspos macro a,b
    mov dh,a
    mov dl,b
    mov tmp_ax, ax 
    mov ah,02
    mov bh,0
    int 10h
    mov ax, tmp_ax
endm 

printstr macro c
    mov dx,offset c
    mov ah,9
    int 21h
endm

p1 macro f1     ; output
    push ax
    push dx
    mov dx, offset f1
    mov ah, 09h
    int 21h
    pop dx
    pop ax
endm

p2 macro f2     ; input
    push ax
    push dx
    mov dx, offset f2
    mov ah, 0Ah
    int 21h
    pop dx
    pop ax
endm

DATA SEGMENT
;-------------------------------------------------
wup_col db 0,16,14,9,7,52,50,1,0,1,21,42,63
wup_str db 0,3,2,9,8,16,15,18,17,24,24,24,24
wdn_col db 79,66,64,43,41,78,76,45,43,19,40,61,78
wdn_str db 23,6,5,15,14,21,20,21,20,24,24,24,24
attr_ db 30h,1,24h,1,1eh,1,4ah,1,1eh,0ech,0ech,0ech,0ech
curs_str db 3,9,16,24,24,24
curs_col db 17,15,56,3,26,46,66
text1 db 'Programma: Input 2 pos nums and 2 neg nums$'
text2 db 'vvod massiva 3x3$'
text3 db 'Result$'
text4 db 'Enter$'

info_mess db 'Move bird  <= =>.Press - enter.$'
x_l db 40
x_r db 41
;------------------------------------------------------
mess1 db 'Input number: $'
    
in_str label byte   ; input
razmer db 7
kol db (?)
stroka db 7 dup (?)

tmp db (?)
count_col db 0
count_row db 0

tmp_ax dw (?)

;если нет результата, то возведи флаг
not_error db 0 

tmp_si dw (?)
number dw 4 dup (0)   

siz dw 4              

negNum dw 4 dup (0)
posNum dw 4 dup (0)
sum dw 4 dup(0)

perevod db 10,13,'$'
text_err1 db 'Input Error!', 10,10,'$'
div_zero db 'Divition by zero!', 10,10,'$'
messovf db 13,10,7,'Overflow!','$'
MulNeg db 13,10,'Mul of negatives: ','$'
notify db 'error input', 10,13,'$'
star db '*$'
equal db '=$'

out_str db 6 dup (' '),'$'

flag_err equ 1
;------------------------------------------------------
BUF  DB  32 DUP(0)
DATA ENDS

CODE SEGMENT
     ASSUME CS:CODE, DS:DATA
start:
    call _START

_START PROC
    PUSH  DS
    SUB   AX,AX
    PUSH  AX
    MOV   AX,DATA
    MOV   DS,AX

    call hero_fly
    
    CALL MAIN

    RET
_START ENDP

MAIN PROC
    mov cx,13
round_1:
    push cx
    mov ax,0600h
    mov bh,attr_+si
    mov ch,wup_str+si
    mov cl,wup_col+si
    mov dh,wdn_str+si
    mov dl,wdn_col+si
    int 10h
    inc si
    pop cx
    loop round_1
    ;********************
    xor si,si
    curspos curs_str+si,curs_col+si
    printstr text1
    inc si

    curspos curs_str+si, curs_col+si
    call MATH


    xor si,si
    inc si
    inc si

    curspos curs_str+si,curs_col+si
    printstr text3
    inc si
    
    curspos curs_str+si, curs_col+si
    printstr text4
    inc si

    mov ax, 4c00h
    int 21h 
    
    ret
MAIN ENDP

;--------------------------------------------------------------
hero_fly PROC
    ;video mode #3 "text 80*25"
    mov ax,0003
    int 10h

        
;risuem okno startovoe okno
    mov cl,x_l
    mov dl,x_r
    mov bh,30h
    call drawin
    CALL TILO

;vivod mess1
    mov dx,0
    call vivod

    ;vvod
    presskey:mov ah,0
        int 16h
    ;if enter
        cmp ax,1c0dh
        je fin
    ;if =><=
        cmp ax,4d00h
        je right
        cmp ax,4b00h
        je left
        jmp presskey
    right:  mov bh,0
        call drawin
        inc x_l
        inc x_r
        mov cl,x_l
        mov dl,x_r
        mov bh,30h
        call drawin
        jmp presskey
    left:   mov bh,0
        call drawin
        dec x_l
        dec x_r
        mov cl,x_l
        mov dl,x_r
        mov bh,30h
        call drawin
        jmp presskey
    fin:    mov ah,02
        int 21h
    ;the end

    ret
hero_fly ENDP
;--------------------------------------------------------------
vivod proc
    
    mov ah,2    
    int 10h
    mov ah,9
    mov dx,offset info_mess
    int 21h
    ret
vivod endp
;---------------------------------------------------------------
drawin proc
    mov ax,0600h
    mov ch,7
    mov dh,8
    int 10h
    ret
drawin endp

;--------------------------------------------------------------
MATH PROC
    ;----------------
    mov ax, 03h

    xor di,di
    mov cx, siz

    mov tmp, bl 
    ;-----------------
    mov bl, curs_str+si
    mov count_row, bl

    mov bl, curs_col+si
    mov count_col, bl
    ;----------------
    mov bl, tmp

    inc si
    mov tmp_si, si

vvod:   
    push cx
 
    p1 mess1    
    p2 in_str   
    
    inc count_row
    curspos count_row, count_col
    
    call diapazon   ; (-29999,+29999)
    
    cmp bh, flag_err    ; flag_err
    je err1                 

    call dopust
    
    cmp bh, flag_err
    je err1
    
    call AscToBin
    inc di
    inc di
    pop cx
    loop vvod
    jmp mmm2
    
err1:   
    p1 text_err1    
    jmp endprog
    
; ----------------0 positive-----------------------------
mmm2: 
    mov cx, siz 
    mov si, offset number
    mov di, offset negNum
    xor bx, bx
negFind:    
    mov ax, [si]
    cmp ax, 0
    jge endNegFind
    mov [di], ax
    inc di
    inc di
    inc bl
    
endNegFind:
    inc si
    inc si
    loop negFind
    
    mov cx, siz
    mov si, offset number
    mov di, offset posNum
    
posFind:    
    mov ax, [si]
    cmp ax, 0
    jl endPosFind
    mov [di], ax
    inc di
    inc di
    inc bh
    
endPosFind:
    inc si
    inc si
    loop posFind
    
    ;-----------анализ--------------
    ;--числа только положительные---
    ;--числа только отрицательные---
    cmp bl, 0
    jne c1
    inc not_error
c1: cmp bh, 0
    jne c2
    inc not_error
    ;------------------------------
c2:
    xor cx, cx
    
    cmp bl, bh
    jge bhLess
    mov cl, bl
    jmp blLess
bhLess:
    mov cl, bh
    
blLess:
    cmp cx, 00h
    jne _clearDI
    jmp endprog
    
_clearDI:
    xor di, di
    

;восстановление si для вывода
    mov si, tmp_si

    mov tmp, bl 
    ;-----------------
    mov bl, curs_str+si
    mov count_row, bl

    mov bl, curs_col+si
    mov count_col, bl
    ;----------------
    mov bl, tmp

    inc count_row
    curspos count_row, count_col
    ;---------------
mainLoop:
    mov ax, posNum[di]
    call BinToAsc
    p1 out_str
    call clearOutputStr
    
    p1 star
    
    mov ax, negNum[di]
    call BinToAsc
    p1 out_str
    call clearOutputStr

    p1 equal

    mov ax, posNum[di]
    mov bx, negNum[di]
    imul bx
    jo overflow

    add sum, ax
    jo overflow

    call BinToAsc
    p1 out_str
    call clearOutputStr
    
    inc di
    inc di
    ;-------перевод курсора---
    call translation_cursor
    ;-----------------------
    loop mainLoop

sumOut:
    mov ax, sum
    call BinToAsc
    p1 out_str
    call clearOutputStr
    jmp endprog
        
overflow:
    p1 messovf
endprog:
    cmp not_error, 0
    je press
    p1 notify
press:
    ret
MATH ENDP
;----------------------------------------------------------
translation_cursor PROC
    inc count_row
    curspos count_row, count_col
    ret
translation_cursor ENDP

;-------------------------------------------------------------
TILO PROC   
     MOV AH, 0
     MOV AL, 2
     INT 10h
     MOV DH, 14
     MOV DL, 25
M2:  CURSOR
     MOV CX, 14
     MOV AL, 219
     MOV BL, 059h
     ATTR
     INC DH
     CMP DH, 15
     JNE M2

     MOV AH, 1
     MOV AL, 2
     INT 10h
     MOV DH, 15
     MOV DL, 23
M3:  CURSOR
     MOV CX, 18
     MOV AL, 219
     MOV BL, 059h
     ATTR
     INC DH
     CMP DH, 16
     JNE M3  

     MOV AH, 2
     MOV AL, 2
     INT 10h
     MOV DH, 12
     MOV DL, 35
M1:  CURSOR
     MOV CX, 2
     MOV AL, 219
     MOV BL, 054h
     ATTR
     INC DH
     CMP DH, 16
     JNE M1      

     MOV AH, 2
     MOV AL, 2
     INT 10h
     MOV DH, 16
     MOV DL, 21
M4:  CURSOR
     MOV CX, 22
     MOV AL, 219
     MOV BL, 059h
     ATTR
     INC DH
     CMP DH, 17
     JNE M4 
     
     MOV AH, 3
     MOV AL, 2
     INT 10h
     MOV DH, 17
     MOV DL, 19
M5:  CURSOR
     MOV CX, 26
     MOV AL, 219
     MOV BL, 059h
     ATTR
     INC DH
     CMP DH, 18
     JNE M5

     MOV AH, 4
     MOV AL, 2
     INT 10h
     MOV DH, 24
     MOV DL, 0
M13: CURSOR
     MOV CX, 100
     MOV AL, 219
     MOV BL, 078h
     ATTR
     INC DH
     CMP DH, 25
     JNE M13

     MOV AH, 4
     MOV AL, 2
     INT 10h
     MOV DH, 18
     MOV DL, 21
M6:  CURSOR
     MOV CX, 22
     MOV AL, 219
     MOV BL, 025h
     ATTR
     INC DH
     CMP DH, 26
     JNE M6 

     MOV AH, 4
     MOV AL, 2
     INT 10h
     MOV DH, 19
     MOV DL, 25
M7:  CURSOR
     MOV CX, 5
     MOV AL, 219
     MOV BL, 016h
     ATTR
     INC DH
     CMP DH, 24
     JNE M7

     MOV AH, 4
     MOV AL, 2
     INT 10h
     MOV DH, 20
     MOV DL, 25
M9:  CURSOR
     MOV CX, 5
     MOV AL, 219
     MOV BL, 043h
     ATTR
     INC DH
     CMP DH, 21
     JNE M9

     MOV AH, 4
     MOV AL, 2
     INT 10h
     MOV DH, 19
     MOV DL, 27
M10: CURSOR
     MOV CX, 1
     MOV AL, 219
     MOV BL, 043h
     ATTR
     INC DH
     CMP DH, 24
     JNE M10

     MOV AH, 4
     MOV AL, 2
     INT 10h
     MOV DH, 19
     MOV DL, 34
M8:  CURSOR
     MOV CX, 5
     MOV AL, 219
     MOV BL, 016h
     ATTR
     INC DH
     CMP DH, 24
     JNE M8

     MOV AH, 4
     MOV AL, 2
     INT 10h
     MOV DH, 20
     MOV DL, 34
M11: CURSOR
     MOV CX, 5
     MOV AL, 219
     MOV BL, 043h
     ATTR
     INC DH
     CMP DH, 21
     JNE M11

     MOV AH, 4
     MOV AL, 2
     INT 10h
     MOV DH, 19
     MOV DL, 36
M12: CURSOR
     MOV CX, 1
     MOV AL, 219
     MOV BL, 033h
     ATTR
     INC DH
     CMP DH, 24
     JNE M12
     CURSOR     
     RET
TILO ENDP

S SEGMENT para stack 'STACK'
    dw 100 dup (?)
S ENDS

;*******************Proc**********************
DIAPAZON PROC
    xor bh, bh
    xor si, si
    
    cmp kol, 05h    
    jb dop
        
    cmp stroka, 2dh     
    jne plus    
    
    cmp kol, 06h    
    jb dop        
    
    inc si      
    jmp first

plus:   
    cmp kol,6    
    je error1   
    
first:  
    cmp stroka[si], 32h ; '2'
    jna dop 
    
error1:
    mov bh, flag_err    ; bh = flag_err
    
dop:    
    ret
DIAPAZON ENDP


;****************************************************
DOPUST PROC

    xor bh, bh
    xor si, si
    xor ah, ah
    xor ch, ch
    
    mov cl, kol 
    
mmm11:    
    mov al, [stroka + si]
    cmp al, 2dh 
    jne testdop 
    cmp si, 00h 
    jne error2  
    jmp mmm13
    
testdop:
    cmp al, 30h 
    jb error2
    cmp al, 39h
    ja error2
    
mmm13:    
    inc si
    loop mmm11
    jmp m14
    
error2: 
    mov bh, flag_err    ; bh = flag_err
    
m14:    
    ret
DOPUST ENDP

;****************************************************
;* ASCII to number                                  *
;*      cx
;*      bx
;*      number
;*      di 
;****************************************************
AscToBin PROC
    xor ch, ch
    mov cl, kol
    xor bh, bh
    mov bl, cl
    dec bl
    mov si, 01h
    
n1: 
    mov al, [stroka + bx]
    xor ah, ah
    cmp al, 2dh 
    je otr  
    sub al, 30h
    mul si 
    add [number + di], ax
    mov ax, si
    mov si, 10
    mul si
    mov si, ax
    dec bx
    loop n1
    jmp n2
otr:    
    neg [number + di]
    
n2: 
    ret
AscToBin ENDP

;****************************************************
;* Number to ASCII                                  
;*      ax                  
;*      out_str             
;****************************************************
BinToAsc PROC
    xor si, si
    add si, 05h
    mov bx, 0Ah
    push ax
    cmp ax, 00h
    jnl mm1
    neg ax
    
mm1:    
    cwd
    idiv bx
    add dl,30h
    mov [out_str + si], dl
    dec si
    cmp ax, 00h
    jne mm1
    pop ax
    cmp ax, 00h
    jge mm2
    mov [out_str + si], 2dh
    
mm2:    
    ret
BinToAsc ENDP

clearOutputStr PROC
    xor si, si
    mov si, offset out_str
    push cx
    mov cl, 06h
_clearCycle:
    mov [si], byte ptr ' '
    inc si
    loop _clearCycle
    pop cx
    ret
ENDP
CODE ENDS  
END START

     

