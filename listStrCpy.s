	.global listStrCpy
	.type listStrCpy, %function


listStrCpy:/* comply with AAPCS */
	push	{r4-r8, r10, r11}	@push to stack
	push	{sp}
	push	{lr}			@push link register

	/* Begin function proper */
        mov     r4, #0                  @ start i at 0
        mov     r5, #4                  @ start k at 4  to skip over next pointer
	mov	r6, r0			@ r6 =ascBuf
	mov	r8, r1			@ r8 =node that we're copying to
	bl	String_Length		@ get length of input string
	mov	r10, r0			@ r10 = input strLen

copyLoop:/* begin copying input string into data section of new node */
	ldrb	r2, [r6, r4]		@ load byte[i] of string into r4
	strb	r2, [r8, r5]		@ store 

	cmp	r4, r10			@compare count to string length
	beq	endCopy			@break if done

	add	r4, #1			@ i++
	add	r5, #1			@ k++

	b	copyLoop		@loop

endCopy:/* end function, pop stack, branch back */
	pop	{lr}			@pop link register
	pop	{sp}			@stack pointer
	pop	{r4-r8, r10, r11}	@pop
	
	bx	lr			@exit to program	
	
