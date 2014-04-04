include io.asm ;подключение операций ввода-вывода

stack segment stack
	dw 128 dup (?)
stack ends

data segment
; место для переменных и констант
NOSTR db 'NO$'
YESSTR db 'YES$'
data ends

code segment 'code'
	assume ss:stack, ds:data, cs:code
; место для описания процедур

start:
	mov ax,data
	mov ds,ax
; команды программы должны располагаться здесь
	inint ax ; let a,b,c in [0..256]
	inint bx
	inint cx
	; Если deg f = 1 => Необх. и дост., что бы b|c.
	; Если deg f = 0 => Нет корней.
	; deg f = -infinity => сущ. корни.
	cmp ax,0
	jne Deg2
	cmp bx,0
	jne Deg1
	cmp cx,0
	je YES
	jne NO
Deg1:
	mov ax,cx
	cwd
	idiv bx
	cmp dx,0
	jne NO
	je YES
Deg2:
	mov di,ax
	mov si,bx
	xchg ax,bx
	imul si
	xchg ax,bx
	imul cx
	mov cx,-4
	imul cx
	add ax,bx; [dx:ax] := b^2 - 4ac
	mov ch,0
	cmp ax,0
	jl NO
	jne SEARCH
	mov cx,0
	jmp testroot
SEARCH:
	mov cx,255
	mov dx,ax
L:	mov ax,cx
	push dx
	mul cx
	pop dx
	cmp ax,dx
	je testroot
	loop L
	jmp NO
testroot:
	mov ax,si
	add ax,cx
	cwd
	mov bx,di
	add bx,bx
	idiv bx
	cmp dx,0
	je YES
	mov ax,si
	sub ax,cx
	cwd
	idiv bx
	cmp dx,0
	je YES
NO:
	lea dx, NOSTR
	jmp PRINT
YES:
	lea dx,YESSTR
PRINT:
	outstr
    finish
code ends
    end start 
