		.data
		.align 0
str_msg1: 	.asciz "\nDigite um número: \n"
str_msg2: 	.asciz "\nDigite o operando: \n"	
str_msg3: 	.asciz "\nDigite um número: \n"
str_msg4:	.asciz "Resultado: "
msg_erro:     .asciz "\nOperador inválido.\n"


#variáveis para guardar os operandos e o resultado da operação 
		.align 2 # alinha a memória a 4 bytes
numero1: 	.word 0
numero2: 	.word 0
resultado: 	.word 0

#variável para guardar o operador 
operador: 	.space 1 #reservo 1byte para guardar o operador 


		.text
		.align 2
		.globl main
		
main: 		

		####### 1º Entrada ########
		
		
		#imprimir mensagem de texto
		li a7, 4 # chamada para imprimir uma string
		la a0, str_msg1
		ecall	
		
		#solicitar ao usuário o 1º operando
		li a7, 5      # syscall para ler int
		ecall         # resultado vai para a0

 		la t0, numero1
 		sw a0, 0(t0)  # armazena o valor lido em numero1

		#imprimir mensagem de texto
		li a7, 4 # chamada para imprimir uma string
		la a0, str_msg2
		ecall	
		
		#solicitar ao usuário um operador 
		li a7, 12       # syscall para ler um caractere
		ecall           # valor lido vai para a0

		la t0, operador # obtém o endereço da variável operador			
		sb a0, 0(t0)    # armazena o valor de a0 (o char) em operador

		
		
		#imprimir mensagem de texto
		li a7, 4 # chamada para imprimir uma string
		la a0, str_msg3
		ecall	
		
		#solicitar ao usuário o 2º operando
		li a7, 5      # syscall para ler int
		ecall         # resultado vai para a0

		la t0, numero2
		sw a0, 0(t0)  # armazena o valor lido em numero1

		
		
		#######Identificação da operação########
		
		#carrego o valor da minha váriavel numero1 em t0
		la t0, numero1
		lw t0,0(t0)

		#carrego o valor da minha váriavel numero2 em t1
		la t1, numero2
		lw t1,0(t1)
		
		#carrego o valor da minha váriavel operador em t2
		la t2, operador
		lb t2,0(t2)
		
		
		#carrega o endereço da variável resultado em s4
		la s0, resultado
		
escolhe_operacao:

		## vou fazer as comparações para o valor de t2 com as minhas strings de operações para 
		# comparação do valor presente na variável operador com o valor ASCII dele

		li t3, '+'
		beq t2, t3, somar # if t2 == t3 eu vou para soma
		
		li t3, '*'
		beq t2, t3, multiplicar # if t2 == t3 eu vou para multiplicar
		
		li t3, '-'		
		beq t2, t3, subtrair # if t2 == t3 eu vou para subtrair
		
		li t3, '/'
		beq t2, t3, dividir # if t2 == t3 eu vou para dividir
		
		# Se chegou aqui, operador inválido
   		 li a7, 4
   		 la a0, msg_erro
   		 ecall

		
		
		
somar:
		mv a0,t0  # coloco o valor de t0 em a0; t0 = num1
		mv a1, t1  # coloco o valor de t1 em a0; t1 = num2
		jal funcao_somar
		
		
		sw a0,0(s0) # armazeno o valor em a0 = resultado da operação em s4
		lw a1,0(s0) # coloco o valor do resultado no parâmetro a1, para chamar a função imprimir

		jal funcao_imprimir		
		j demais_entradas
		
		
subtrair:
		mv a0,t0 # coloco o valor de t0 em a0; t0 = num1
		mv a1, t1 # coloco o valor de t1 em a0; t1 = num2
		jal funcao_subtrair
		
		
		sw a0,0(s0) # armazeno o valor em a0 = resultado da operação em s4
		lw a1,0(s0) # coloco o valor do resultado no parâmetro a1, para chamar a função imprimir
		
		jal funcao_imprimir
		j demais_entradas
		
		
		
multiplicar:
		mv a0,t0 # coloco o valor de t0 em a0; t0 = num1
		mv a1, t1 # coloco o valor de t1 em a0; t1 = num2
		jal funcao_multiplicar
		
		
		sw a0,0(s0) # armazeno o valor em a0 = resultado da operação em 
		lw a1,0(s0) # coloco o valor do resultado no parâmetro a1, para chamar a função imprimir
		
		jal funcao_imprimir
		j demais_entradas
		
		
dividir:
		mv a0,t0 # coloco o valor de t0 em a0; t0 = num1
		mv a1, t1  # coloco o valor de t1 em a0; t1 = num2
		jal funcao_dividir
		
		
		
		sw a0,0(s0) # armazeno o valor em a0 = resultado da operação em s0
		lw a1,0(s0) # coloco o valor do resultado no parâmetro a1, para chamar a função imprimir
		
		jal funcao_imprimir
		j demais_entradas

		
	
		
demais_entradas:	
		######### Demais entradas #########
		# ler um caractere e, se necessário, um opererando
		
		#imprimir mensagem de texto
		li a7, 4 # chamada para imprimir uma string
		la a0, str_msg2
		ecall	
		
		#solicitar ao usuário um operador 
		li a7, 12       # syscall para ler um caractere
		ecall           # valor lido vai para a0

		la t0, operador # obtém o endereço da variável operador			
		sb t0, 0(t0)    # armazena o valor de a0 (o char) em operador
		
		##operador == f; sai do programa
		li t3, 'f'
		beq t0, t3, fim_code
		#li t3, 'u'
		#beq t0, t3, undo
		# como posso fazer um jump aqui para mandar o meu t3 para o inicio e verificar qual operação será
		
		
		
fim_code:
		#encerrar programa
		li a7, 10
		ecall
		
		
#função soma dois valores
#parâmetros:
#a0: num1 e a1: num2	
#retorno em a0: resultado de num1+num2	
funcao_somar:
	add t0, a0, a1
	mv a0, t0
	jr ra 

#função subtrai dois valores
#parâmetros:
#a0: num1 e a1: num2	
#retorno em a0: resultado de num1-num2
funcao_subtrair:
	sub t0, a0, a1
	mv a0, t0
	jr ra


#função dividi dois valores
#parâmetros:
#a0: num1 e a1: num2	
#retorno em a0: resultado de num1/num2
funcao_dividir:
	div t0, a0,a1
	mv a0, t0
	jr ra

#função multiplica dois valores
#parâmetros:
#a0: num1 e a1: num2	
#retorno em a0: resultado de num1*num2
funcao_multiplicar:
	mul t0, a0, a1
	mv a0, t0
	jr ra
	
#função imprimir 
#parâmetro:
#a0: valor a ser impresso(resultado)

funcao_imprimir:
	
	
	#imprimir uma mensagem de texto
	li a7, 4
	la a0, str_msg4
	ecall
	
	#imprimir um inteiro
	li a7, 1
	mv a0, a1
	ecall
	jr ra
	
