
include io.asm ;подключение операций ввода-вывода
stack segment stack
	dw 128 dup (?)
stack ends

data segment
; место для переменных и констант
strs db 100 dup (?)
count db 256 dup(?)
data ends

code segment 'code'
	assume ss:stack, ds:data, cs:code
; место для описания процедур

start:
	mov ax,data
	mov ds,ax

	mov ax,0B800h ; indirect write into video mem
	push ax
    pop es	
	mov di,0 ; for colored output,ofc

    mov ax,3 ; clrscr
    int 10h ; clrscr
	
	mov dx,0 ; temporary register 
; команды программы должны располагаться здесь
	mov bx,0
L:
	;mov al,1 ; ignore 'enter' key
	;call procinch ; readkey
	mov ah,06h ; direct input
	mov dl,0ffh
	int 21h 
	jz L ; if ZF = 1 then no char at input. Otherwise al = char code
	
	
	cmp al,8 ; 8 - backspace code
	jne proccess ; if backspace <> al then goto proccess
	;mov dl,8 ; backspace code
	;mov ah,2 
	;int 21h ; delete last char; syscall
	cmp bx,0
	je L
	sub di,2
	mov ah,0h
	mov al,' '
	stosw
	sub di,2
	dec bx
	jmp L ; continue
proccess:
	mov ah,01Dh
	stosw
	cmp al,'.' ; if dot then goto apply
	je apply
	mov ah,0 ; ax := al.
	mov si,ax
	inc count[si]; count[al] ++
	mov strs[bx],al ; strs[i] := al
	inc bx ; inc length
	cmp bx,100
	je apply
	jmp L ; continue
apply: 
	cmp bx,0 ; if length == 0 then goto Fin
	je Fin
	mov dl,strs[bx-1] ; last char
	mov si,dx ; si := strs[bx-1]
	cmp count[si],1 ; check last char freq.
	mov cx,bx ; cx := bx, bx := 0
	mov bx,0
	
	
    mov ax,3 ; clrscr
    int 10h ; clrscr
	mov di,0
	
	je First; if last char freq. == 1 then goto First else goto Second
	jne Second
First:
	cmp strs[bx],'A' ; check if strs[bx] in ['A'..'Z']
	jl NextF
	cmp strs[bx],'Z'
	jg NextF
	sub strs[bx],'A'-'a' ; strs[bx] := strs[bx] - 'A' + 'a'
NextF:
	;outch <[strs+bx]> ; and print mov di,0
    
	mov al,[strs+bx]
    mov ah,0Fh
    stosw ; writes al to es:di
	
	inc bx ; bx++
	loop First 
	jmp Fin ; skip second
Second:
	mov dl,strs[bx]
	mov si,dx ; si := strs[bx]
	cmp count[si],1 ; if strs[bx] freq. == 1 then print
	jne NextS
	
	mov al,[strs+bx]
    mov ah,0Eh
    stosw
NextS:
	inc bx
	loop Second
Fin:
	newline
	mov ah,4ch
	int 21h
code ends
    end start 
