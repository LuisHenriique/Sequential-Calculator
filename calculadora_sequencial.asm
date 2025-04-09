		.data
		.align 0
str_msg: 	.asciz "teste"
	
		.text
		.align 2
		.globl main
		
main: 		
		#imprimir mensagem de texto
		li a7, 4 # chamada para imprimir uma string
		la a0, str_msg
		ecall