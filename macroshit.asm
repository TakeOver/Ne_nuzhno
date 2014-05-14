
include io.asm ;подключение операций ввода-вывода

stack segment stack
	dw 128 dup (?)
stack ends

data segment
; место для переменных и констант
B1 db 1
BB1 db 0
B2 db 2
BB2 db 0
B3 db 3
BB3 db 0
W1 dw 4

W2 dw 5

W3 dw 6

D1 dd 7

D2 dd 8

D3 dd 9
data ends

code segment 'code'
	assume ss:stack, ds:data, cs:code
; место для описания процедур

CONST EQU 0
VARIABLE EQU 1
REGISTER  EQU 2
Ident macro X
	IF TYPE X NE ABS 
		Res&X = VARIABLE
	ELSE
		Res&X = CONST
		IRP R,<DL,aX,bX,cX,dX,dI,sI,bP,sP,sS,cS,dS,eS,aH,aL,bH,bL,cL,cH,dH,dL>
			IFIDN <R>,<X>
				Res&X = REGISTER
			ENDIF
		ENDM
		IRP R,<Dl,ax,bx,cx,dx,di,si,bp,sp,ss,cs,ds,es,ah,al,bh,bl,cl,ch,dh,dl>
			IFIDN <R>,<X>
				Res&X = REGISTER
			ENDIF
		ENDM
		IRP R,<AX,BX,CX,DX,DI,SI,BP,SP,SS,CS,DS,ES,AH,AL,BH,BL,CL,CH,DH>
			IFIDN <R>,<X>
				Res&X = REGISTER
			ENDIF
		ENDM
		IRP R,<Ax,Bx,Cx,Dx,Di,Si,Bp,Sp,Ss,Cs,Ds,Es,Ah,Al,Bh,Bl,Cl,Ch,Dh>
			IFIDN <R>,<X>
				Res&X = REGISTER
			ENDIF
		ENDM
	ENDIF
ENDM
Type_ macro X
	Ident X
	IF Res&X EQ CONST
		IF X LT 256
			Type_&X=8
		ELSE
			IF X LT (1 SHL 16)
				Type_&X = 16
			ELSE
				Type_&X=32
			ENDIF
		ENDIF
	ELSE
		IF Res&X EQ REGISTER
			Type_&X=8
			IRP R,<AX,BX,CX,DX,DI,SI,BP,SP,SS,CS,DS,ES,aX,bX,cX,dX,dI,sI>
				IFIDN <R>,<X>
					Type_&X = 16
				ENDIF
			ENDM
			IRP R,<bP,sP,sS,cS,dS,eS,Ax,Bx,Cx,Dx,Di,Si,Bp,Sp,Ss,Cs,Ds,Es>
				IFIDN <R>,<X>
					Type_&X = 16
				ENDIF
			ENDM
			IRP R,<ax,bx,cx,dx,di,si,bp,sp,ss,cs,ds,es>
				IFIDN <R>,<X>
					Type_&X = 16
				ENDIF
			ENDM
		ELSE
			IF TYPE X EQ BYTE
				Type_&X = 8
			ELSE
				IF TYPE X EQ WORD
					Type_&X = 16
				ELSE
					Type_&X=32
				ENDIF
			ENDIF
		ENDIF
	ENDIF
ENDM
exB2W macro X,R
	IFDIF <R>,<AX>
		push ax
		mov al,x
		mov ah,0
		mov R,ax
		pop ax
	ELSE
		mov AL,X
		mov AH,0
	ENDIF
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
	Type_ X
	IF Type_&X EQ 16
		mov R, X
	ELSE
		exB2W <X>,<R>
	ENDIF
ENDM
expand2D macro X,RH,RL
	Type_ X
	IF Type_&X EQ 32
		mov RL, word ptr X
		mov RH, word ptr X+2
	ELSE
		IF Type_&X EQ 8
			exB2D <X>,<RH>,<RL>
		ELSE
			exW2D <X>,<RH>,<RL>
		ENDIF
	ENDIF
ENDM
Check macro R,N,a,b,c,d
	Check&N&_&R = 0
	IRP Rs,<a,b,c,d>
		IFIDN <Rs>,<R>
			Check&N&_&R = -1
		ENDIF
	ENDM
ENDM
AddThreeSub macro Dest,First,Second
	Type_ Dest
	Type_ First
	Type_ Second
	IF (Type_&Dest LT Type_&First) OR (Type_&Dest LT Type_&Second)
		.ERR <Destination(!first non constant operand - &Dest) size arent maximal>
	ENDIF
	IF Type_&Dest EQ 8
		Check Dest, AL, AL,Al,aL,al
		Check Dest, AH, AH,Ah,aH,ah
		IFE CheckAL_&Dest 
			IF CheckAH_&Dest 
				add AH,First
				add AH,Second
			ELSE
				Check First, AL,AL,al,Al,aL
				IF CheckAL_&First
					add AL,Second
					add Dest, AL
				ELSE
					Check Second, AL,AL,al,Al,aL
					IF CheckAL_&Second
						add AL,First
						add Dest,AL
					ELSE
						push AX
						mov AL,First
						add AL,Second
						add Dest,AL
					ENDIF
				ENDIF
			ENDIF
		ELSE
			add AL,First
			add AL, Second
		ENDIF
	ELSE
	IF Type_&Dest EQ 16
		IFDIF <DI>,<Dest> 
			push DI
		ENDIF
		push AX
		push BX
		mov DI,Dest
		IFDIF <Second>,<AX>
			expand2W First,AX
			expand2W Second,BX
		ELSE
			expand2W First,BX
		ENDIF
		add AX,BX
		add DI,AX
		pop BX
		pop AX
		IFDIF <DI>,<Dest>
			mov Dest,DI
			pop DI
		ENDIF
		
	ELSE
		IRP R,<AX,BX,CX,DX>
			push R
		ENDM
		expand2D First,AX,BX
		expand2D Second,CX,DX
		add BX,DX
		adc AX,CX
		add word ptr Dest,BX
		adc word ptr Dest+2,AX
		IRP R,<AX,BX,CX,DX>
			pop R
		ENDM
	ENDIF
	ENDIF
endm
addThree macro A,B,C
	Ident A
	Ident B
	Ident C
	IF Res&A NE CONST
		AddThreeSub A,B,C
	ELSE
		IF Res&B NE CONST
			AddThreeSub B,A,C
		ELSE
			IF Res&C NE CONST
				AddThreeSub C,B,A
			ELSE
				.ERR <All operands have constant type>
			ENDIF
		ENDIF
	ENDIF
endm
start:
	mov ax,data
	mov ds,ax
	mov AX,12
	mov BX,43
	mov DX, 74
	mov CX, 65
	mov SI, 11
; команды программы должны располагаться здесь
	finish
code ends
    end start 
