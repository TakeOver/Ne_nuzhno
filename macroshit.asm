
include io.asm ;подключение операций ввода-вывода

stack segment stack
	dw 128 dup (?)
stack ends

data segment
; место для переменных и констант

data ends

code segment 'code'
	assume ss:stack, ds:data, cs:code
; место для описания процедур
exB2W macro X,R
	push ax
	mov al,x
	mov ah,0
	mov R,ax
	pop ax
endm
exW2D macro X,RH,RL
	mov RL,X
	mov	RH,0
endm
exB2D macro X,RH,RL
	exB2W X,RL
	mov RH,0
endm
expand2W macro X,R
	IF TYPE X EQ WORD
		mov R,X
	ELSE
		exB2W <X>,<R>
	ENDIF
ENDM
expand2D macro X,RH,RL
	IF TYPE X EQ DWORD
		mov RL,X
		mov RH,X+2
	ELSE
	IF TYPE X EQ BYTE
		exB2D <X>,<RH>,<RL>
	ELSE
		exW2D <X>,<RH>,<RL>
	ENDIF
	ENDIF
ENDM
Check macro R
	Check&R = 0
	IRP Rs,<AX,BX,CX,DX,DS,SI,DI,SS,CS,ES,SP,BP>
		IFIDN <&R>,<&&Rs>
			Check&R = 16
			EXITM
		ENDIF
	ENDM

	IRP Rs,<AH,AL,BH,BL,CL,CH,DL,DH>
		IFIDN <&R>,<&&Rs>
			Check&R = 8
			EXITM
		ENDIF
	ENDM
ENDM 
TYPE_ macro R
	Check R
	IF Check&R
		TYPE_&R = Check&R
	ELSE
		IF (.TYPE R) EQ ABS
			IF R LT 256 
				TYPE_&R = 8
			ELSE
				IF R LT (1 SHL 16)
					TYPE_&R = 16
				ELSE
					TYPE_&R = 32
				ENDIF
			ENDIF
		ELSE
			TYPE_&R = (TYPE R)
		ENDIF
	ENDIF	
endm
AddThreeSub macro Dest,First,Second
	TYPE_ Dest
	TYPE_ First
	TYPE_ Second
	IF (TYPE_&Dest GT TYPE_&First) OR (TYPE_&Dest GT TYPE_&Second)
	;;	echo <'Destination(first non constant operand) size aren\'t maximal'>
		mov AH,AX
		EXITM
	ENDIF
	IF TYPE_&Dest EQ BYTE
		push AX
		mov AL,First
		add AL,Second
		mov Dest,AL
		pop AX
	ELSE
	IF TYPE_&Dest EQ WORD
		push AX
		push BX
		expand2W First,AX
		expand2W Second,BX
		add AX,BX
		mov Dest,AX
		pop AX
		pop BX
	ELSE
		IRP R,<AX,BX,CX,DX>
			push R
		ENDM
		expand2D First,AX,BX
		expand2D Second,CX,DX
		add BX,DX
		adc AX,CX
		mov word ptr Dest,BX
		mov word ptr Dest+2,AX
		IRP R,<AX,BX,CX,DX>
			pop R
		ENDM
	ENDIF
	ENDIF
endm
addThree macro A,B,C
	Check A
	Check B
	Check C
	IF ((.TYPE A)  NE ABS) OR (Check&A GT 0)
		AddThreeSub A,B,C
	ELSE
	IF ((.TYPE B) NE ABS) OR (Check&B GT 0)
		AddThreeSub B,A,C
	ELSE
	IF ((.TYPE C) NE ABS) OR (Check&C GT 0)
		AddThreeSub C,B,A
	ELSE
	;;	echo <All operands have constant type>
		mov AX,AH
	ENDIF
	ENDIF
	ENDIF
endm
start:
	mov ax,data
	mov ds,ax
; команды программы должны располагаться здесь
	AddThree 322,AX,333
    finish
code ends
    end start 
