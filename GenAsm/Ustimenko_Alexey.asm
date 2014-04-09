.386p
	EXTRN	SYSTEM_RANDOM$$EXTENDED: NEAR
	EXTRN	SYSTEM_RANDOM$LONGINT$$LONGINT: NEAR
.model compact
.stack
.code	
public	mutation
mutation proc
		push	ebp ; save realworld context
		mov	ebp,esp ; pointer-arg - located at ebp-4, real-prob - located at ebp+8
		sub	esp,12 ; reserve some mem for locals
		mov	dword ptr [ebp-12],ebx ; save old ebx
		mov	dword ptr [ebp-4],eax ; getting ptr
		mov	word ptr [ebp-8],0 ; let i := 0
Iter: ;let's name [ebp-8] as i.
		inc	word ptr [ebp-8] ; i++
		call	SYSTEM_RANDOM$$EXTENDED
		fld	qword ptr [ebp+8] ; ST(0) <- p; where p - is probability of mutation
		fcompp ; if random < p then mutate
		fnstsw	ax
		sahf ; load FPU flags to CPU's one.
		jb	MutateThis
		jmp	SkipMutation
MutateThis:
		mov	eax,2
		call	SYSTEM_RANDOM$LONGINT$$LONGINT ; random(2)
		mov	ebx,dword ptr [ebp-4]
		movzx	ecx,word ptr [ebp-8]
		add 	ecx,ecx
		add 	ecx,ecx
		add 	ecx,ecx
		add 	ebx,ecx
		mov	dword ptr [ebx-8],eax  
		mov	dword ptr [ebx-4],0
SkipMutation:
		cmp	word ptr [ebp-8],16 ; if i < 16 then goto Iter
		jl	Iter
		mov	ebx,dword ptr [ebp-12] ; restore old ebx
		leave ; restore esp and ebp
		ret	8
mutation endp
end
