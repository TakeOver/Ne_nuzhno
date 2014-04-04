
include io.asm ;подключение операций ввода-вывода

stack segment stack
	dw 128 dup (?)
stack ends

data segment
; место для переменных и констант
	N dw ?
	M dw ?
	Mass dw 10000 dup(?) ; array
data ends

code segment 'code'
	assume ss:stack, ds:data, cs:code
; место для описания процедур
start:
	mov ax,data
	mov ds,ax
; команды программы должны располагаться здесь
	inint N
	inint M
	mov ax,N
	mov bx,M
	mul bx
	mov cx,0;i
	mov dx,0 ;k
	mov si,0;j
	mov di,1;p
W:	cmp cx,ax
	jge F1
	jmp F2
F1: jmp near ptr F
F2:
	inc dx ;k++
	mov si,dx;j:=k-1
	dec si
	mov bx,M
	sub bx,dx
	inc bx; m-k+1
L1:	cmp si,bx ; j < m - k+1
	jge N1
	push ax
	push bx ; save
	mov ax,dx ; ax := k
	sub ax,1 ; ax := k-1
	mov bx,M ; 
	push dx 
	mov dx,0
	mul bx ; ax := (k-1)*M
	pop dx
	mov bx,ax
	add bx,si; bx := (k-1)*M + j
	add bx,bx
	mov Mass[bx],di ; Mass[k-1,j] := p
	inc di ; p++
	pop bx ; restore
	pop ax ; 
	inc si ; j++
	inc cx ; p++
	jmp L1 
N1: mov si,dx;j:=k
	mov bx,N
	sub bx,dx
	inc bx; n-k+1
L2:	cmp si,bx
	jge N2
	push ax
	push bx ; save
	mov ax,si ; ax := j
	mov bx,M
	push dx 
	mov dx,0
	mul bx ; ax := (j)*M
	pop dx
	add bx,ax; bx := (j)*M + m-k
	sub bx,dx
	add bx,bx
	mov Mass[bx],di ; Mass[j,m-k] := p
	inc di ; p++
	pop bx ; restore
	pop ax ; 
	inc si ; j++
	inc cx ; i++
	jmp L2
N2:	mov si,dx;j:=k+1
	inc si
	sub si,M
	neg si ; j := m-k-1
	mov bx,dx
	dec bx; bx := k-1
L3:	cmp si,bx ; j >= k-1
	jl N3
	push ax
	push bx ; save
	mov ax,N ; ax := n-k
	sub ax,dx
	mov bx,M ; 
	push dx 
	mov dx,0
	mul bx ; ax := (n-k)*M
	pop dx
	mov bx,ax
	add bx,si; bx := (n-k)*M + j
	add bx,bx
	mov Mass[bx],di ; Mass[n-k,j] := p
	inc di ; p++
	pop bx ; restore
	pop ax ; 
	dec si ; j--
	inc cx ; i++
	jmp L3 
N3: mov si,dx;j:=k
	mov bx,N
	sub bx,dx
	dec bx; n-k-1
	xchg bx,si; j := n-k-1 bx := k
L4:	cmp si,bx
	jl N4
	push ax
	push bx ; save
	mov ax,si ; ax := j
	mov bx,M; 
	push dx 
	mov dx,0
	mul bx ; ax := (j)*M
	pop dx
	mov bx,dx
	dec bx
	add bx,ax; bx := (j)*M + k-1
	add bx,bx
	mov Mass[bx],di ; Mass[j,k-1] := p
	inc di ; p++
	pop bx ; restore
	pop ax ; 
	dec si ; j--
	inc cx ; i++
	jmp L4
N4:
	jmp W
F:
	mov bx,0
L5:	cmp bx,ax
	jge FIN
	mov si,0
L6:	cmp si,M
	jge N5
	push bx
	push si
	add si,si
	add bx,bx
	outword Mass[bx][si],4
	pop si
	pop bx
	inc si
	jmp L6
N5:	newline
	add bx,M
	jmp L5
FIN:
	flush
    finish
code ends
    end start 
