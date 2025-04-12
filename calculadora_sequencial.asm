		.data
		.align 0
str_msg1: 	.asciz "\nDigite um número: \n"
str_msg2: 	.asciz "\nDigite o operador: \n"	
str_msg3:	.asciz "\nResultado: \n"
str_erro:     	.asciz "\nOperador inválido.\n"
str_erro_div: 	.asciz "\nErro: divisao por zero.\n"
str_prog_fin:	.asciz "\nPrograma encerrado!\n"
str_lista_vazia: .asciz "\nNada para desfazer.\n"

#variáveis para guardar os operandos e o resultado da operação 
		.align 2 # alinha a memória a 4 bytes
numero1: 	.word 0
numero2: 	.word 0
resultado: 	.word 0
head: 		.word 0 # ponteiro para o inicio da lista

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
		
		#solicitar do usuário o 1º operando
		li a7, 5      # syscall para ler int
		ecall         # resultado vai para a0

 		la t3, numero1# carrego o endereço da variável numero1 em t3
 		sw a0, 0(t3)  # armazena o valor lido em numero1

		#imprimir mensagem de texto
		li a7, 4 # chamada para imprimir uma string
		la a0, str_msg2
		ecall	
		
		#solicitar ao usuário um operador 
		li a7, 12       # syscall para ler um caractere
		ecall           # valor lido vai para a0

		la t4, operador # obtém o endereço da variável operador			
		sb a0, 0(t4)    # armazena o valor de a0 (o char) em operador

		
		#imprimir mensagem de texto
		li a7, 4 # chamada para imprimir uma string
		la a0, str_msg1
		ecall	
		
		#solicitar ao usuário o 2º operando
		li a7, 5      # syscall para ler int
		ecall         # resultado vai para a0

		la t5, numero2 # carrego o endereço da variável numero2 em t1
		sw a0, 0(t5)  # armazena o valor lido em numero1

		
		
		
		#carrego o valor da minha váriavel numero1 em t0
		lw t0,0(t3)

		#carrego o valor da minha váriavel operador em t2
		lb t2,0(t4)
		

		#carrego o valor da minha váriavel numero2 em t1
		lw t1,0(t5)
		
		
		
		#carrega o endereço da variável resultado em s0
		la s0, resultado

		
		
		#######Identificação da operação########
escolhe_operacao:		

		##Verificação de qual operação será realizada##

		li t3, '+'
		beq t2, t3, somar # if t2 == t3 eu vou para soma
		
		li t3, '*'
		beq t2, t3, multiplicar # if t2 == t3 eu vou para multiplicar
		
		li t3, '-'		
		beq t2, t3, subtrair # if t2 == t3 eu vou para subtrair
		
		li t3, '/'
		beq t2, t3, dividir # if t2 == t3 eu vou para dividir
	
		# Se chegou aqui, operador inválido, pulo para o final para encerrar o programa
    		li a7, 4
    		la a0, str_erro
    		ecall

   		 
   		j main # operador inválido, reinicio o programa

		
		
		
#-----------------------------------------------------------
# somar
# Prepara parâmetros e chama função de soma
#-----------------------------------------------------------
somar:
  		mv    a0, t0        # Primeiro operando (numero1)
  	 	mv    a1, t1        # Segundo operando (numero2)
   		jal   funcao_somar  # Chamar função de soma
		
		sw a0,0(s0) # armazeno o valor de a0(resultado) em s0
		lw a1,0(s0) # coloco o valor do resultado no parâmetro a1, para chamar a função imprimir

		jal funcao_imprimir
		jal inserir_resultado		
		j demais_entradas
		

#-----------------------------------------------------------
# subtrair
# Prepara parâmetros e chama função de subtração
#-----------------------------------------------------------
subtrair:
		mv a0,t0 # coloco o valor de t0 em a0; t0 = num1
		mv a1, t1 # coloco o valor de t1 em a0; t1 = num2
		jal funcao_subtrair
		
		
		sw a0,0(s0) # armazeno o valor de a0(resultado) em s0
		lw a1,0(s0) # coloco o valor do resultado no parâmetro a1, para chamar a função imprimir
		
		jal funcao_imprimir
		jal inserir_resultado
		j demais_entradas
		
		
#-----------------------------------------------------------
# multiplicar
# Prepara parâmetros e chama função de multiplicação
#-----------------------------------------------------------
multiplicar:
		mv a0,t0 # coloco o valor de t0 em a0; t0 = num1
		mv a1, t1 # coloco o valor de t1 em a0; t1 = num2
		jal funcao_multiplicar
		
		
		sw a0,0(s0) # armazeno o valor de a0(resultado) em s0 
		lw a1,0(s0) # coloco o valor do resultado no parâmetro a1, para chamar a função imprimir
		
		jal funcao_imprimir
		jal inserir_resultado
		j demais_entradas
		

#-----------------------------------------------------------
# dividir
# Prepara parâmetros e chama função de divisão
#-----------------------------------------------------------
dividir:	
		beq t1,zero, erro_divisao #if t1=0, operação inválida, imprime erro e finaliza programa
		mv a0,t0 # coloco o valor de t0 em a0; t0 = num1
		mv a1, t1  # coloco o valor de t1 em a0; t1 = num2
		jal funcao_dividir
		
		
		
		sw a0,0(s0)# armazeno o valor de a0(resultado) em s0
		lw a1,0(s0) # coloco o valor do resultado no parâmetro a1, para chamar a função imprimir
		
		jal funcao_imprimir
		jal inserir_resultado
		j demais_entradas
  #tratamento de erro para divisão por zero 		
  erro_divisao:
  		li a7, 4
  		la a0, str_erro_div
  		ecall
  		j fim_code # encerro o programa
		
demais_entradas:	
		######### Demais entradas #########
		# ler um caractere e, se necessário, um opererando.
		
		#imprimir mensagem de texto
		li a7, 4 # chamada para imprimir uma string
		la a0, str_msg2
		ecall	
		
		#solicitar ao usuário um operador 
		li a7, 12       # syscall para ler um caractere
		ecall           # valor lido vai para a0

		la t0, operador # carrego o endereço da variável operador em t0			
		sb a0, 0(t0)    # armazena o valor de a0 (o char) em operador=t0
		lb t2, 0(t0) # carrego o conteúdo de t0 em t2, ou seja t2 recebe o operador
		
		##operador == f; sai do programa
		li t3, 'f'
		beq t2, t3, fim_code
		
		#operador =='u', desfaz a última operação
		li t3, 'u'
		beq t2, t3, undo
		#j demais_entradas # retorno para pedir ao usuário digitar novamente um operador

		
		# Verifica se é +, -, *, ou /
		li t3, '+'
		beq t2, t3, ler_numero
		
		li t3, '-'
		beq t2, t3, ler_numero
		
		li t3, '*'
		beq t2, t3, ler_numero
		
		li t3, '/'
		beq t2, t3, ler_numero
		
		
		# Caso contrário, operador inválido
		li a7, 4
		la a0, str_erro
		ecall
		j demais_entradas # retorno para pedir ao usuário digitar novamente um operador
		
ler_numero:
			
		#imprimir mensagem de texto
		li a7, 4 # chamada para imprimir uma string
		la a0, str_msg1
		ecall	
		
		#solicitar ao usuário um número
		li a7, 5      # syscall para ler int
		ecall         # resultado vai para a0
		
		
		# carregar o número 1 (resultado anterior)
 		la t3, resultado
 		lw t0, 0(t3) # coloco o conteúdo do endereço de t3 em t0

		# carregar o número 2 (novo número lido) a0
 		la t1, numero2
 		sw a0, 0(t1)  # armazena o valor lido em numero2, a0 foi retorno da syscall 5
 		lw t1,0(t1)    # t1 será o valor de número 2
 		
 		
 		la t2, operador	
 		lb t2, 0(t2) # coloco o conteúdo do endereço de t2 em t2 = operador
 		
 		#carrega o endereço da variável resultado em s0
		la s0, resultado
		
 		# Redireciona para escolher_operação, como os valores nos devidos regs que são utilizados neste label
 		j escolhe_operacao
		
		
fim_code:

		#imprimir mensagem de texto
		li a7,4 # chamada ao sistema para imprimir uma string 
		la a0, str_prog_fin
		ecall
		
		#encerrar programa
		li a7, 10
		ecall
		
		
#-----------------------------------------------------------
# funcao_somar
# Soma dois inteiros
# Parâmetros:
#   a0 - primeiro operando
#   a1 - segundo operando
# Retorno:
#   a0 - resultado da soma
#-----------------------------------------------------------
funcao_somar:
		add t0, a0, a1
		mv a0, t0
		jr ra 


#-----------------------------------------------------------
# funcao_subtrair
# Subtrai dois inteiros
# Parâmetros:
#   a0 - primeiro operando
#   a1 - segundo operando
# Retorno:
#   a0 - resultado da subtração (a0 - a1)
#-----------------------------------------------------------

funcao_subtrair:
		sub t0, a0, a1
		mv a0, t0
		jr ra


#-----------------------------------------------------------
# funcao_dividir
# Divide dois inteiros
# Parâmetros:
#   a0 - dividendo
#   a1 - divisor
# Retorno:
#   a0 - resultado da divisão inteira (a0 / a1)
# Observação:
#   A verificação de divisão por zero é feita antes da chamada
#-----------------------------------------------------------

funcao_dividir:
		beq a1, zero, erro_divisao
		div t0, a0,a1
		mv a0, t0
		jr ra
  

#-----------------------------------------------------------
# funcao_multiplicar
# Multiplica dois inteiros
# Parâmetros:
#   a0 - primeiro operando
#   a1 - segundo operando
# Retorno:
#   a0 - resultado da multiplicação
#-----------------------------------------------------------

funcao_multiplicar:

		mul t0, a0, a1
		mv a0, t0
		jr ra
	
	
#-----------------------------------------------------------
# funcao_imprimir
# Imprime um número inteiro na tela
# Parâmetros:
#   a1 - valor a ser impresso
# Retorno:
#   nenhum
#-----------------------------------------------------------

funcao_imprimir:
	
	
		#imprimir uma mensagem de texto
		li a7, 4
		la a0, str_msg3
		ecall
	
		#imprimir um inteiro
		li a7, 1
		mv a0, a1
		ecall
		jr ra


#Lista encadeada

#-----------------------------------------------------------
# inserir_resultado
# Insere o último resultado em uma lista encadeada
# Parâmetros:
#   resultado - valor a ser armazenado na lista
# Retorno:
#   nenhum
#-----------------------------------------------------------
inserir_resultado:

	    # alocar memória (8 bytes para novo nó)
	    li a7, 9      # syscall sbrk
	    li a0, 8      # 8 bytes
	    ecall
	    mv t0, a0     # t0 = endereço do novo nó
	
	    # armazenar o valor do resultado
	    sw a1, 0(t0)
	
	    # armazenar ponteiro para o antigo head
	    la t1, head
	    lw t2, 0(t1)
	    sw t2, 4(t0)
	
	    # atualizar head para apontar para novo nó
	    sw t0, 0(t1)
	
	    jr ra

#-----------------------------------------------------------
# desempilhar_resultado
# Remove o topo da pilha e retorna o valor desempilhado em a0
# Retorno:
#   a0 - valor desempilhado (último resultado)
#   Se pilha estiver vazia, a0 = 0 e a1 = 0
#-----------------------------------------------------------
desempilhar_resultado:
	    la t0, head
	    lw t1, 0(t0)       # t1 = head
	
	    beqz t1, pilha_vazia
	
	    lw t2, 4(t1)       # t2 = próximo nó
	    sw t2, 0(t0)       # atualiza head
	
	    lw a0, 0(t1)       # a0 = valor desempilhado
	    li a1, 1           # flag de sucesso
	
	 
	    jr ra

pilha_vazia:
	    li a0, 0
	    li a1, 0           # flag de falha
	    jr ra
	    
	    
undo:
 	    call desempilhar_resultado
	    beqz a1, sem_resultado_para_restaurar  # se flag == 0
	
	    # Agora o topo aponta para o valor anterior
	    la t0, head
	    lw t1, 0(t0)       # t1 = novo topo
	    beqz t1, sem_resultado_para_restaurar
	
	    lw t2, 0(t1)       # t2 = valor anterior
	    la t3, resultado
	    sw t2, 0(t3)       # atualiza resultado
	
	    mv a1, t2
	    jal funcao_imprimir
	    j demais_entradas
	
sem_resultado_para_restaurar:
	    li a7, 4
	    la a0, str_lista_vazia
	    ecall
	    j demais_entradas
	
	