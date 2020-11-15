.equ  KBSIZE,  256

	.data

ascBuf:	.skip	KBSIZE
head:	.word	0
tail:	.word	0
llSize:	.word	0
mem:	.word	0
ascPr:	.asciz	"Enter next string: "


cZero:	.byte	48						@ 0
iCount:	.word	0						@ count for loops
szCls:	.asciz	"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"	@ clear screen

/* Input */
szIn1:	.asciz	"1"						@ check input
szIn2a:	.asciz	"2a"					@ check input
szIn2b:	.asciz	"2b"					@ check input
szIn3:	.asciz	"3"						@ check input
szIn4:	.asciz	"4"						@ check input
szIn5:	.asciz	"5"						@ check input
szIn6:	.asciz	"6"						@ check input
szIn7:	.asciz	"7"						@ check input

/* MENU */
ascM1:	.asciz	"                MASM4 TEXT EDITOR\n"
ascM2:	.asciz	"        Data Structure Heap Memory Consumption: "		@ Num Bytes after ascM2
ascM3:	.asciz	" bytes\n"
ascM4:	.asciz	"        Number of Nodes: "								@ Num Nodes after ascM4
ascM5:	.asciz	"\n<1> View all strings\n\n"
ascM6:	.asciz	"<2> Add string\n"
ascM7:	.asciz	"    <a> from Keyboard\n"
ascM8:	.asciz	"    <b> from File. Static file named input.txt\n\n"
ascM9:	.asciz	"<3> Delete string. Given an index #, delete the entire string and de-allocate memory (including the node).\n\n"
ascM10:	.asciz	"<4> Edit string. Given an index #, replace old string w/ new string. Allocate/De-allocate as needed.\n\n"
ascM11:	.asciz	"<5> String search. Regardless of case, return all strings that match the substring given.\n\n"
ascM12:	.asciz	"<6> Save File (output.txt)\n\n"
ascM13:	.asciz	"<7> Quit\n\n"

	.text
	.global _start
	.extern malloc
	.extern calloc
	.extern free

 
_start:	

Menu:
@	push	{lr}		@ push link register

	ldr	r0, =szCls		@ load clear screen
	bl	putstring		@ print

	/* Print Title */
	ldr	r0, =ascM1		@ load menu part 1
	bl	putstring		@ print

	ldr	r0, =ascM2		@ load menu part 2
	bl	putstring		@ print

	/* convert mem to string and print with leading zeros */
	ldr	r0, =mem		@ load mem
	ldr	r1, =ascBuf		@ load buffer
	bl	intasc32		@ convert

	ldr	r0, =ascBuf		@ load buffer to r0
	bl	String_Length	@ get string length

	mov	r1, r0			@ move to r2
	cmp	r1, #8			@ check length
	bllt	leadingZeros	@ jump to leading 0s

	ldr	r0, =ascBuf		@ Re-load string
	bl 	putstring		@ print
	
	ldr	r0, =ascM3		@ print bytes
	bl	putstring		@ print

	/* Number of nodes */
	ldr	r0, =ascM4		@ load ascM4
	bl	putstring		@ print

	ldr	r0, =llSize		@ load llSize
	ldr	r1, =ascBuf		@ load buffer
	bl	intasc32		@ convert to asci

	ldr	r0, =ascBuf		@ move buffer to r0
	bl	putstring		@ print

	/* print menu options */
	ldr	r0, =ascM5		@ load ascM5
	bl	putstring		@ print

	ldr	r0, =ascM6		@ load ascM6
	bl	putstring		@ print

	ldr	r0, =ascM7		@ load ascM7
	bl	putstring		@ print
	
	ldr	r0, =ascM8		@ load ascM8
	bl	putstring		@ print
	
	ldr	r0, =ascM9		@ load ascM9
	bl	putstring		@ print
	
	ldr	r0, =ascM10		@ load ascM10
	bl	putstring		@ print
	
	ldr	r0, =ascM11		@ load ascM11
	bl	putstring		@ print
	
	ldr	r0, =ascM12		@ load ascM12
	bl	putstring		@ print
	
	ldr	r0, =ascM13		@ load ascM13
	bl	putstring		@ print
	
	/* END OF PRINT MENU */

getInput:
	/* get input and break */
	ldr	r0, =ascBuf		@ load buffer
	mov	r1, #KBSIZE		@ load kbsize
	bl	getstring		@ getstring
	
	/* option 1 */
	ldr	r0, =ascBuf		@ load buffer
	ldr	r1, =szIn1		@ load string 1
	bl	string_equalsIgnoreCase		@ compare strings

	cmp	r0, #1			@ check if true
	beq	printList		@ break to print list

	/* option 2a */
	ldr	r0, =ascBuf		@ load buffer
	ldr	r1, =szIn2a		@ load string 2a
	bl	string_equalsIgnoreCase		@ compare strings

	cmp	r0, #1			@ check if true
@	beq	option2A		@ break option 2a
	
	/* option 2b */
	ldr	r0, =ascBuf		@ load buffer
	ldr	r1, =szIn2b		@ load string 2b
	bl	string_equalsIgnoreCase		@ compare strings

	cmp	r0, #1			@ check if true
@	beq	option2B		@ break option 2b

	/* option 3 */
	ldr	r0, =ascBuf		@ load buffer
	ldr	r1, =szIn3		@ load string 3
	bl	string_equalsIgnoreCase		@ compare strings

	cmp	r0, #1			@ check if true
@	beq	option3			@ break option 3

	/* option 4 */
	ldr	r0, =ascBuf		@ load buffer
	ldr	r1, =szIn4		@ load string 4
	bl	string_equalsIgnoreCase		@ compare strings

	cmp	r0, #1			@ check if true
@	beq	option4			@ option4

	/* option 5 */
	ldr	r0, =ascBuf		@ load buffer
	ldr	r1, =szIn5		@ load string 5
	bl	string_equalsIgnoreCase		@ compare strings

	cmp	r0, #1			@ check if true
@	beq	option5			@ option 5

	/* option 6 */
	ldr	r0, =ascBuf		@ load buffer
	ldr	r1, =szIn6		@ load string 6
	bl	string_equalsIgnoreCase		@ compare strings

	cmp	r0, #1			@ check if true
@	beq	option6			@ option 6

	/* option 7 */
	ldr	r0, =ascBuf		@ load buffer
	ldr	r1, =szIn7		@ load string 7
	bl	string_equalsIgnoreCase		@ compare strings

	cmp	r0, #1			@ check if true
	beq	end			@ break to option7

	b	getInput		@ if no options were met

@	pop		{lr}		@ pop link register
@	bx	lr				@ break out


	/* begin basic LL program */
	
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

	
leadingZeros:/* loop for leading zeroes */

	push	{lr}		@ push link register

	ldr r0, =cZero		@ character '0'
	bl	putch			@ print char '0'

	add	r1, #1			@ increment
	cmp	r1, #8			@ check leading zeros
	bllt	leadingZeros	@ loop
	
	pop 	{lr}		@ pop link register
	bx	lr				@ break out


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
