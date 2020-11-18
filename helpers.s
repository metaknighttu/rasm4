	.global listStrCpy
	.type listStrCpy, %function
/*
Parameters:
r0 = address to string to add to list
r1 = dereferenced pointer to node the string goes into

no register is altered or returned. Changes are
instead made to the node provided in r1 in memory.
*/
///////////////////////////////////////////////////////////////////////////////
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
	ldrb	r11, [r6, r4]		@ load byte[i] of string into r4
	strb	r11, [r8, r5]		@ store 

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
///////////////////////////////////////////////////////////////////////////////


	.global getNode
	.type getNode, %function
///////////////////////////////////////////////////////////////////////////////
getNode:/* r0 = index. returns node address in r0.*/
	push	{r4-r8, r10, r11}	@ push AAPCS
	push	{sp}                    @ push stack pointer
	push	{lr}			@ push link register

        /* Find the string and get its length */
        mov     r4, r0                  @ store dest index
        mov     r5, #1                  @ i = 1
        ldr     r6, =head               @ load head pointer

	cmp	r4, #1			@ if index = first item
	moveq	r0, r6			@ 	move head into r0 and end function
	beq	endGetNode		@		else continute to iteration loop

getNodeLoop:/* Loop to iterate through list */

        ldr     r6, [r6]                @ dereference (move 1 node down the list)
        add     r5, #1                  @ i++
        cmp     r4, r5                  @ if i != index
        bne     getNodeLoop             @       then keep iterating down the list
        mov     r0, r6                  @               else we have the item and we 
                                        @               return it in r0
endGetNode:/* Restore registers and branch back to function call */
	pop	{lr}			@ pop link register
	pop	{sp}			@ pop stack pointer
	pop	{r4-r8, r10, r11}	@ pop AAPCS
	bx	lr	                @ branch back to function call
///////////////////////////////////////////////////////////////////////////////



	.global addToList
	.type addToList, %function
///////////////////////////////////////////////////////////////////////////////
addToList:/* Add a node */
	push	{r4-r8, r10, r11}	@push to stack
	push	{sp}
	push	{lr}			@push link register

	ldr	r0, =head		@ load head pointer
	ldr	r0, [r0]		@ dereference pointer
	cmp	r0, #0			@ if head -> NULL
	bleq	addFirstToList		@ 	then add first node
	blne	addToList		@		else add reg. node

addNextToList:	/* Add a new item to the end of the list*/
	/* Find length of memory block to allocate */
	ldr	r0, =ascBuf		@ load new string
	bl	String_Length		@ find stringlength in bytes
	mov	r1, r0			@ r1 = strLen
	mov	r0, #1			@ only 1 unit to be calloc'd
	add	r1, r1, #5		@ add a word+NULL to strLen

	/* accumulate consumed memory */
	mov	r4, r1			@ copy memconsumed to another register
	ldr	r5, =mem		@ load mem address
	ldr	r6, [r5]		@ dereference mem
	add	r6, r6, r4		@ add current memory to new memory
	str	r6, [r5]		@ store result into mem

	push	{r4-r8, r10, r11}	@push to stack
	push	{sp}
	push	{lr}			@push link register
	bl	calloc			@ allocate a block of length strLen+word+NULL
					@r0 = addr of calloced block
	pop	{lr}			@pop link register
	pop	{sp}			@stack pointer
	pop	{r4-r8, r10, r11}	@pop

	/* dereference tail->next, then save newnode into tail->next & tail */
	ldr	r1, =tail		@ load address of tail pointer
	ldr	r1, [r1]		@ dereference for next
	str	r0, [r1]		@ save calloc'd address into tail->next

	ldr	r1, =tail		@ load address of tail pointer
	str	r0, [r1]		@ save calloc'd address into tail

	/* Copy string into data section of memory block */
	ldr	r0, =ascBuf		@ load address of last element
	ldr	r1, =tail		@ load address of new string
	ldr	r1, [r1]		@ dereference
	bl	listStrCpy		@ call helper function to copy the data

	/* Increment size of list */
	ldr	r5, =llSize		@ load llSize address
	ldr	r6, [r5]		@ dereference llSize
	add	r6, #1			@ size++
	str	r6, [r5]		@ store result into llSize

	pop	{lr}			@pop link register
	pop	{sp}			@stack pointer
	pop	{r4-r8, r10, r11}	@pop
	bx	lr			@ branch back

addFirstToList:	/* Add the first item to the list*/
	/* Find length of memory block to allocate */

	ldr	r0, =ascBuf		@ load new string
	bl	String_Length		@ find stringlength in bytes
	mov	r1, r0			@ r1 = strLen
	mov	r0, #1			@ only 1 unit to be calloc'd
	add	r1, r1, #5		@ add a word+NULL to strLen

	/* accumulate consumed memory */
	mov	r4, r1			@ copy memconsumed to another register
	ldr	r5, =mem		@ load mem address
	ldr	r6, [r5]		@ dereference mem
	add	r6, r6, r4		@ add current memory to new memory
	str	r6, [r5]		@ store result into mem


	push	{r4-r8, r10, r11}	@push to stack
	push	{sp}
	push	{lr}			@push link register
	bl	calloc			@ allocate a block of length strLen+word+NULL
					@r0 = addr of calloced block
	pop	{lr}			@pop link register
	pop	{sp}			@stack pointer
	pop	{r4-r8, r10, r11}	@pop


	/* Link head and tail to the first node */
	ldr	r1, =head		@ load address of head pointer
	str	r0, [r1]		@ save calloc'd address into head
	ldr	r1, =tail		@ load address of tail pointer
	str	r0, [r1]		@ save calloc'd address into tail

	/* Copy string into data section of memory block */
	ldr	r0, =ascBuf		@ load address of last element
	ldr	r1, =tail		@ load address of new string
	ldr	r1, [r1]		@ dereference
	bl	listStrCpy		@ call helper function to copy the data

	/* Increment size of list */
	ldr	r5, =llSize		@ load llSize address
	mov	r6, #1			@ size++
	str	r6, [r5]		@ store result into llSize

	pop	{lr}			@pop link register
	pop	{sp}			@stack pointer
	pop	{r4-r8, r10, r11}	@pop
	bx	lr			@ branch back
//////////////////////////////////////////////////////////////////////////////////
