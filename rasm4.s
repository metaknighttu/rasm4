  .equ  KBSIZE  512
  
  
  .data
  

	.text
	.global _start
	.extern malloc
	.extern free
        
_start:


end:
	mov	r0, #0			@status
	mov	r7, #1			@service code
	svc	0			      @service call to linux
.end
