.equ  KBSIZE,  256

	.data

ascBuf:	.skip	KBSIZE
head:	.word	0
tail:	.word	0
llSize:	.word	0
mem:	.word	0
ascPr:	.asciz	"Enter next string: "

	.text
	.global _start
	.extern malloc
	.extern calloc
	.extern free

 
_start:/* begin basic LL program */
	/* print input prompt */
	ldr	r0, =ascPr		@ load string prompt address	
	bl	putstring		@ print

	/* get input string  */
	ldr	r0, =ascBuf		@ load string bufer address
	mov	r1, #KBSIZE		@ load string buffer size
	bl	getstring		@ call getstring

	/* save string to list */
	ldr	r0, =head		@ load head pointer
	ldr	r0, [r0]		@ dereference pointer
	cmp	r0, #0			@ if head -> NULL
	bleq	addFirstToList		@ 	then add first node
	blne	addToList		@		else add reg. node

	/* End program if size = 10, else keep adding  */
	ldr	r0, =llSize		@ load address of llSize
	ldr	r0, [r0]		@ dereference
	cmp	r0, #10			@ if llSize < 10
	bne	_start			@	then keep looping
	ldr	r4, =head		@ 		else load head into r4
	b	printList		@		and print list


addToList:	/* Add a new item to the end of the list*/
	push	{r4-r8, r10, r11}	@push to stack
	push	{sp}
	push	{lr}			@push link register
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
	push	{r4-r8, r10, r11}	@push to stack
	push	{sp}
	push	{lr}			@push link register
	
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
@	ldr	r6, [r5]		@ dereference llSize
	mov	r6, #1			@ size++
	str	r6, [r5]		@ store result into llSize

	pop	{lr}			@pop link register
	pop	{sp}			@stack pointer
	pop	{r4-r8, r10, r11}	@pop
	bx	lr			@ branch back


printList:/* Iterate through the list and print the contents of each node */
	ldr	r4, [r4]		@ then iterate to next item
	mov	r5, r4			@ copy address to r5
	add	r5, #4			@ shift address to data section
	mov	r0, r5			@ provide address of string to putstring
	bl	putstring		@ print data

	ldr	r5, [r4]		@ dereference next pointer
	cmp	r5, #0			@ if next->NULL
	beq	end			@	then we're finished
					@		else continue looping
	b	printList		@ and continue printing
	

end:/* finish program and terminate */
	mov	r0, #0			@status
	mov	r7, #1			@service code
	svc	0			@service call to linux
	
	.end

/*
Branches we need:
Load from file
	Read line from file
		addToList

Read from keyboard
	addToList

printList

deleteAtIndex

editAtIndex

	nod@index-1, save next
	node@index, save next address

   	deleteAtIndex
  	addToList

findString
	iterate through list, comparing data to input string
	print each match


*/
