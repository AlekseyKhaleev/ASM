;#########################
;DATA SEGMENT
;#########################

d1 segment para public 'data' 
mess1 db 'Hello,world!',10,13,'$'


d1 ends

;#########################
;CODE SEGMENT
;#########################
c1 segment para public use16 'code' 

assume cs:c1, ds:d1, ss:st1
start:	mov ax,d1
	mov ds,ax

	mov dx,offset mess1
	mov ah,9
	int 21h
	
	mov ax,4c00h
   	int 21h

c1 ends

;#########################
;STACK SEGMENT 
;#########################
st1 segment para stack 'stack' 
      dw 10 dup ('$$')
st1 ends
end start
	
	