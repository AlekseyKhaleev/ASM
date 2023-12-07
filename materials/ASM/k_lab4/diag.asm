;��������� ������ ��������� �������� � ���������������� �� ���������
;��������� ���� .com, ���������� tasm diag, ���������� tlink /t diag
; ������� �� F10, ���� , ���� ������� ��������

.model tiny
.code
.286	; ����� ������������ ������� pusha popa
org 100h
start:
diag_line proc
	mov ax,0003  ;������� ������, ���������� 25*80
	int 10h
;��������� � F10
	mov ah,9
	mov dx,offset mess
	int 21h

	mov dx,0100h ; ������ �� ������ 1 � ������� 0
m: 	mov ah,1
	int 16h
	cmp ax,4400h;   ����  F10, �� �����
	je m1

	mov ah,2 ; ���������� ������
	mov bh,0
	int 10h

	mov al,'@' ;������� ������ �� �����
	mov cx,1
	mov ah,10
	int 10h

	call dly_time ;����� ��������� �������� �������

	sub al,al  ;������� ������ 
	mov ah,10
	int 10h

	inc dh ;������� �� ������� � ��������� ������  
	add dl,3 ; +3 � ������ �������, ��� ��������� �����
	
	cmp dh,25 ;������ ������ ������ ?
	jne m
m1:	ret ;����� �� ���������
diag_line endp
;��������� ������������ �����
dly_time proc 
	pusha
	mov ah,2ch; �������� �����:	ch-���, cl - ���, dh-���, dl-����� ���� ���
	int 21h
	add dh,1; ��������  1 ���
	cmp dh,60
	jb m2
	sub dh,60; �������������, ���� �������� �������� ������ 60 ���
m2:	mov sec,dh; ��������
check:	mov ah,2ch; ���������� �����
	int 21h
	cmp dh,sec; ���������� � ��������
	jne check ; ���� ����� �� ����� - �����
	popa ; ����� - �����
	ret
dly_time endp
sec db ?
mess db 'You can press F10 for exit$'	
end start
