.equ  KBSIZE  256

	.data

ascBuf:	.skip	KBSIZE
head:	.word	0
tail:	.word	0
size:	.word	0
mem:	.word	0

	.text
	.global _start
	.extern malloc
	.extern free
        
_start:



	@then call function to loop and copy ascBuf into the data section of next node
main:
	ldr	r0, =ascBuf		@ load string bufer address
	ldr	r1, #KBSIZE		@ load string buffer size
	bl	getstring		@ call getstring

	bl	String_Length		@ find stringlength in bytes
	mov	r1, r0			@ r1 = strLen
	mov	r0, #1			@ only 1 unit to be calloc'd
	add	r1, r1, #5		@ add a word+NULL to strLen



addToList:

addFirstToList:	/* parameters: r0 = address of string buffer*/

	/* Find length of memory block to allocate */
	bl	String_Length		@ find stringlength in bytes
	mov	r1, r0			@ r1 = strLen
	mov	r0, #1			@ only 1 unit to be calloc'd
	add	r1, r1, #5		@ add a word+NULL to strLen

	/* track consumed memory */
	mov	r4, r1			@ copy memconsumed to another register
	ldr	r5, =mem		@ load mem address
	ldr	r6, [r5]		@ dereference mem
	add	r6, r6, r4		@ add current memory to new memory
	str	r6, [r5]		@ store result into mem

	bl	calloc			@ allocate a block of length strLen+word+NULL
					@r0 = addr of calloced block
	/* Link head and tail to the first node */
	ldr	r1, =head		@ load address of head pointer
	str	r0, [r1]		@ save calloc'd address into head
	ldr	r1, =tail		@ load address of tail pointer
	str	r0, [r1]		@ save calloc'd address into tail

	/* Copy string into data section of memory block */


end:
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