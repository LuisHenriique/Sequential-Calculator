##################################################################################
# Descrição do código:
# Este programa implementa uma calculadora simples em assembly para RISC-V, que permite ao usuário 
# realizar operações aritméticas como soma, subtração, multiplicação e divisão. 
# Além disso, oferece funcionalidades como desfazer a última operação e encerrar o programa.
# O programa faz uso de syscalls para entrada e saída de dados, e a execução das operações
# é baseada na escolha do usuário, sendo verificado o tipo de operação selecionada.
#
# Funcionalidades:
# - Solicitar dois números e um operador do usuário
# - Realizar operações aritméticas: soma, subtração, multiplicação e divisão
# - Exibir o resultado da operação
# - Permitir desfazer a última operação realizada
# - Tratar erros como divisão por zero e operador inválido
# - Exibir mensagens de erro e encerramento do programa
#
# Autores:
# - Luis Henrique Ponciano dos Santos 	(N-USP: 15577760)
# - Gabriel de Araujo Lima	  	(N-USP: 14571376)
#
##################################################################################
		
		.data
		.align 0
str_msg1: 	.asciz "\nDigite um número: \n"
str_msg2: 	.asciz "\nDigite o operador: \n"	
str_msg3:	.asciz "\nResultado: \n"
str_erro:     	.asciz "\nOperador inválido.\n"
str_erro_div: 	.asciz "\nErro: divisao por zero.\n"
str_prog_fin:	.asciz "\nPrograma encerrado!\n"
str_lista_vazia: .asciz "\nNada para desfazer.\n"

# Variáveis para guardar os operandos e o resultado da operação 
		.align 2 # Alinha a memória a 4 bytes
numero1: 	.word 0  # numero1 guarda o primeiro operando	
numero2: 	.word 0  # numero2 guarda o segundo operando
resultado: 	.word 0  # resultado guarda o valor atual das operações aritméticas
head: 		.word 0  # ponteiro para o inicio (primeiro nó) da lista

# Variável para guardar o operador 
operador: 	.space 1 #reservo 1 byte (pois é representado por um char) para guardar o operador 

		.text
		.align 2
		.globl main

#-----------------------------------------------------------------
# A main coordena as entradas e saídas do usuário, organizando as chamadas
# das funções somar, subtrair, multiplicar e dividir com base nos valores
# lidos do usuário
#-----------------------------------------------------------------
main: 		
		# --- FUNÇÃO MAIN: COORDENA ENTRADAS E SAÍDAS ---
		# A função main coordena todas as interações com o usuário, controlando a entrada de dados,
		# a escolha dos operadores e a execução da operação solicitada.
		# 
		# Registradores usados:
		# a0  registrador que recebe o endereço das strings ou valores para syscalls
		# a7  código da syscall (comando do sistema) para realizar operações, como imprimir ou ler dados
		# t0, t1, t2, t3, t4, t5  registradores temporários usados para armazenar dados e endereços durante a execução
		# s0  registrador para armazenar o endereço da variável de resultado
		# --------------------------------------------------------
		
		# Imprimir mensagem pedindo um número
		li a7, 4 	# Syscall para imprimir uma string
		la a0, str_msg1	# Passa o endereço de str_msg1 que tem a mensagem "\nDigite um número: \n"
		ecall		# Chamada ao sistema
		
		# Lê um inteiro do usuário
		li a7, 5      # Syscall código 5, para ler int
		ecall         # Chamada ao sistema, cujo valor lido vai para a0

 		la t3, numero1 # Carrega o endereço da variável numero1 em t3
 		sw a0, 0(t3)   # Armazena o valor lido em numero1

		# Imprime na tela pedindo um operador ao usuário
		li a7, 4 	# Chamada para imprimir uma string
		la a0, str_msg2 # Imprime a mensagem "\nDigite o operador: \n"
		ecall		# Chamada ao sistema para imprimir na tela
		
		# Leitura de um caractere que representa o operador ('+', '-', '*' e '/')
		li a7, 12       # Syscall para ler um caractere
		ecall           # Chama o sistema, com o valor lido sendo armazenado em a0

		# Armazena o caractere lido do operador na variável 'operador'
		la t4, operador # Obtém o endereço da variável 'operador' e armazena em t4
		sb a0, 0(t4)    # Armazena o valor de a0 (onde está o caractere do operador)
				# na variavel 'operador'

		# Imprimir na tela pedindo mais um número ao usuário (2º operando)
		li a7, 4 	# Syscall para imprimir uma string (syscall código 4)
		la a0, str_msg1	# Armazena o endereço da mensagem "\nDigite um número: \n"
		ecall		# Chamada ao sistema, imprimindo a mensagem na tela
		
		# Leitura do 2º operando
		li a7, 5      # Syscall para ler 'int' (syscall código 5)
		ecall         # Chamada ao sistema, cujo valor lido é armazenado em a0

		# Passagem do valor do 2º operando para a variável 'numero2'
		la t5, numero2	# Carrega o endereço da variável numero2 em t5
		sw a0, 0(t5) 	# Armazena o valor lido (que está em a0) em numero1

		# Carrega o valor da váriavel 'numero1' para t0
		lw t0,0(t3)	# Passa o conteúdo do endereço em t3 (variável 'numero1') para t0

		# Carrega o valor da váriavel 'operador' para t2
		lb t2,0(t4)	# Passa o conteúdo do endereço em t4 (variável 'operador') parat2
		

		# Carrega o valor da váriavel numero2 para t1
		lw t1,0(t5)	# Passa o conteúdo do endereço em t5 (variável 'numero2') para t1
		
		# Carrega o endereço da variável 'resultado' em s0
		la s0, resultado	# Passa o endereço de 'resultado' para s0

#-----------------------------------------------------------------
# O seguinte trecho de código (escolhe_operacao) é responsável por analisar o caractere
# armazenado na variavel 'operador' e coordenar as chamadas de funções respectivas
# para executar essa operação. 
# Ex.: se for '+', será responsável por identificar que é uma soma e irá chamar as funções de soma
#-----------------------------------------------------------------
escolhe_operacao:		
		# --- FUNÇÃO ESCOLHE_OPERACAO: SELEÇÃO DA OPERAÇÃO ---
		# Esta função é responsável por verificar o operador informado pelo usuário ('+', '-', '*' ou '/')
		# e direcionar o fluxo de execução para a operação correspondente. Caso o operador seja inválido,
		# exibe uma mensagem de erro e reinicia o programa.
		# 
		# Registradores usados:
		# t2  guarda o valor do operador lido do usuário
		# t3  guarda o valor do operador esperado para comparação (um dos operadores '+', '-', '*' ou '/')
		# --------------------------------------------------------

		# Verifica se o usuário solicitou soma
		li t3, '+'	  # Armazena o valor imediato do símbolo '+' em t3
		beq t2, t3, somar # Se t2 == t3 vai para 'somar'
		
		# Verifica se o usuário solicitou multiplicação
		li t3, '*'		# Armazena o valor imediato do símbolo '*' em t3
		beq t2, t3, multiplicar # Se t2 == t3 vai para 'multiplicar'
		
		# Verifica se o usuário solicitou subtração
		li t3, '-'		# Armazena o valor imediato do símbolo '-' em t3
		beq t2, t3, subtrair 	# Se t2 == t3 vai para 'subtrair'
		
		# Verifica se o usuário solicitou divisão
		li t3, '/'		# Armazena o valor imediato do símbolo '/' em t3
		beq t2, t3, dividir 	# Se t2 == t3 vai para 'dividir'
	
		# Trata o erro em que o usuário digita um operador inválido
		# Caso isso aconteça, reinicia o programa
    		li a7, 4	# Syscall para imprimir string (código 4)
    		la a0, str_erro	# Passa o endereço da mensagem "\nOperador inválido.\n" para a0
    		ecall		# Chamada ao sistema para imprimir a mensagem

   		j main # Caso seja um operador inválido, reinicia o programa
   		
#-------------------------------------------------------------
# O label 'somar' é responsável por preparar os parâmetros
# e chamar a função de somar com os operandos armazenados
#-------------------------------------------------------------
somar:
		# --- SOMA DE DOIS NÚMEROS ---------------
		# Este bloco realiza a chamada da função que soma de dois 
		# valores armazenados nos registradores t0 e t1.
		#
		# Registradores usados:
		# t0  Contém o primeiro operando (numero1)
		# t1  Contém o segundo operando (numero2)
		# a0  Usado para passar o primeiro operando para a função funcao_somar e também para receber o resultado
		# a1  Usado para passar o segundo operando para a função funcao_somar e depois para passar o resultado à funcao_imprimir
		# s0  Registrador base para armazenar o resultado da operação
		#
		# A função funcao_somar recebe a0 e a1 como argumentos e retorna o resultado em a0.
		# Depois, o valor é salvo em s0 e carregado de volta em a1 para ser impresso por funcao_imprimir.
		# ----------------------------------------
		
  		# Passa os operandos como argumentos e chama a função 'funcao_somar'
  		mv    a0, t0        # Passa o numero1 (operando 1) como argumento
  	 	mv    a1, t1        # Passa o numero2 (operando 2) como argumento
   		jal   funcao_somar  # Chamar função de soma
   		
   		# Observação: o resultado de funcao_somar será
   		# retornado no registrador a0
		
		# Armazena o resultado em s0 e passa esse valor para a1 
		sw a0,0(s0) # Armazena o valor de a0 (resultado) em s0
		lw a1,0(s0) # Armazena o resultado (s0) em a1 para chamar a função imprimir

		jal funcao_imprimir	# Imprime o resultado com a1 como argumento
		jal lista_adicionar_elemento	# Insere o valor na estrutura que armazena os resultados
		
		j demais_entradas	# Vai para demais_entradas para pedir
					# ao usuário 1 novo operador e 1 novo operando
		

#-------------------------------------------------------------
# O label 'subtrair' é responsável por preparar os parâmetros
# e chamar a função de subtrair com os operandos armazenados
#-------------------------------------------------------------
subtrair:
		# --- SUBTRAÇÃO DE DOIS NÚMEROS ---
		# Este bloco realiza a chamada da função que subtrai
		# dois valores armazenados nos registradores t0 e t1.
		#
		# Registradores usados:
		# t0  Contém o primeiro operando (numero1)
		# t1  Contém o segundo operando (numero2)
		# a0  Usado para passar o primeiro operando para a função funcao_subtrair e também para receber o resultado
		# a1  Usado para passar o segundo operando para a função funcao_subtrair e depois para passar o resultado à funcao_imprimir
		# s0  Registrador base para armazenar temporariamente o resultado da operação
		#
		# A função funcao_subtrair recebe a0 e a1 como argumentos e retorna o resultado em a0.
		# Depois, o valor é salvo em s0 e carregado de volta em a1 para ser impresso por funcao_imprimir.
		# ----------------------------------------
		
  		# Passa os operandos como argumentos e chama a função 'funcao_subtrair'
		mv a0,t0		# Passa o numero1 (operando 1) como argumento em a0
		mv a1, t1	 	# Passa o numero2 (operando 2) como argumento em a1
		jal funcao_subtrair	# Chama a função 'funcao_subtrair'
		
		# Armazena o resultado em s0 e passa esse valor para a1 
		sw a0,0(s0) # Armazena o valor de a0 (resultado) em s0
		lw a1,0(s0) # Armazena o resultado (s0) em a1 para chamar a função imprimir
		
		jal funcao_imprimir	# Imprime o resultado com a1 como argumento
		jal lista_adicionar_elemento	# Insere o valor na estrutura que armazena os resultados
		
		j demais_entradas	# Vai para demais_entradas para pedir
					# ao usuário 1 novo operador e 1 novo operando
		
#-------------------------------------------------------------
# O label 'multiplicar' é responsável por preparar os parâmetros
# e chamar a função de multiplicar com os operandos armazenados
#-------------------------------------------------------------
multiplicar:
		# --- MULTIPLICAÇÃO DE DOIS NÚMEROS ---
		# Este bloco chama a função de multiplicar
		# dois valores armazenados nos registradores t0 e t1.
		#
		# Registradores usados:
		# t0  Contém o primeiro operando (numero1)
		# t1  Contém o segundo operando (numero2)
		# a0  Usado para passar o primeiro operando para a função funcao_multiplicar e também para receber o resultado
		# a1  Usado para passar o segundo operando para a função funcao_multiplicar e depois para passar o resultado à funcao_imprimir
		# s0  Registrador base para armazenar temporariamente o resultado da operação
		#
		# A função funcao_multiplicar recebe a0 e a1 como argumentos e retorna o resultado em a0.
		# Depois, o valor é salvo em s0 e carregado de volta em a1 para ser impresso por funcao_imprimir.
		# ----------------------------------------
		
		# Passa os operandos como argumentos e chama a função 'funcao_multiplicar'
		mv a0,t0 		# Passa o numero1 (operando 1) como argumento em a0
		mv a1, t1 		# Passa o numero2 (operando 2) como argumento em a1
		jal funcao_multiplicar	# Chama a função 'funcao_multiplicar'
		
		# Armazena o resultado em s0 e passa esse valor para a1 
		sw a0,0(s0) # Armazena o valor de a0 (resultado) em s0 
		lw a1,0(s0) # Armazena o resultado (s0) em a1 para chamar a função imprimir
		
		jal funcao_imprimir		# Imprime o resultado com a1 como argumento
		jal lista_adicionar_elemento	# Insere o valor na estrutura que armazena os resultados
		
		j demais_entradas	# Vai para demais_entradas para pedir
					# ao usuário 1 novo operador e 1 novo operando

#-------------------------------------------------------------
# O label 'dividir' é responsável por preparar os parâmetros
# e chamar a função de dividir com os operandos armazenados
#-------------------------------------------------------------
dividir:	
		# --- DIVISÃO ENTRE DOIS NÚMEROS ---
		# Este bloco chama a função de dividir um valor pelo outro
		# armazenados nos registradores t0 e t1.
		# Antes de realizar a operação, verifica se o segundo operando (t1) é zero.
		# Se for, a divisão é inválida e o programa salta para erro_divisao.
		#
		# Registradores usados:
		# t0  Contém o dividendo (numero1)
		# t1  Contém o divisor (numero2)
		# a0  Usado para passar o dividendo para a função funcao_dividir e também para receber o resultado
		# a1  Usado para passar o divisor para a função funcao_dividir e depois para passar o resultado à funcao_imprimir
		# s0  Registrador base para armazenar temporariamente o resultado da operação
		#
		# A função funcao_dividir recebe a0 e a1 como argumentos e retorna o resultado da divisão em a0.
		# Depois, o valor é salvo em s0 e carregado de volta em a1 para ser impresso por funcao_imprimir.
		# ----------------------------------------
		
		# Verifica se o divisor é 0
		beq t1,zero, erro_divisao # Se t1=0, operação inválida, imprime erro e finaliza programa
		mv a0,t0 		  # Passa o numero1 (operando 1) como argumento em a0
		mv a1, t1  		  # Passa o numero2 (operando 2) como argumento em a1
		jal funcao_dividir	  # Chama a função 'funcao_dividir'

		# Armazena o resultado em s0 e passa esse valor para a1 
		sw a0,0(s0)	# Armazena o valor de a0 (resultado) em s0
		lw a1,0(s0) 	# Armazena o resultado (s0) em a1 para chamar a função imprimir
		
		jal funcao_imprimir		# Imprime o resultado com a1 como argumento
		jal lista_adicionar_elemento	# Insere o valor na estrutura que armazena os resultados
		
		j demais_entradas	# Vai para demais_entradas para pedir
					# ao usuário 1 novo operador e 1 novo operando
		
  # Tratamento de erro para divisão por zero 		
  erro_divisao:
 		# --- MENSAGEM DE ERRO DE DIVISÃO POR ZERO ---
		# Este bloco é executado quando se tenta dividir um número por zero (t1 == 0).
		# Ele imprime uma mensagem de erro na tela e encerra o programa.
		#
		# Registradores usados:
		# a0  Usado para passar o endereço da string de erro para o sistema
		# a7  Usado para especificar o tipo de chamada de sistema (ecall)
		# -----------------------------------------------
		
  		li a7, 4		# a7 = 4. Chamada de sistema para imprimir string (print_string)
  		la a0, str_erro_div	# a0 = endereço da string "\nErro: divisao por zero.\n"
  		ecall			# Chamada de sistema que imprime a string apontada por a0
  		
  		j fim_code 		# Salta para o final do código (encerra o programa)
		
#-------------------------------------------------------------
# O label 'demais_entradas' é responsável por fazer as próximas
# leituras do usuário, ou seja, 1 operador e 1 operando
#-------------------------------------------------------------
demais_entradas:
		# --- LER NOVO OPERADOR E IDENTIFICAR AÇÃO ---
		# Este bloco solicita ao usuário um novo operador e decide o próximo passo.
		# Pode iniciar nova operação, desfazer a última ou encerrar o programa.
		#
		# Registradores usados:
		# a0  Parâmetro de entrada e saída de ecall
		# a7  Especifica o tipo da chamada de sistema
		# t0  Endereço da variável 'operador'
		# t2  Valor do operador lido
		# t3  Caractere de comparação para decisões
		# --------------------------------------------
		
		# Imprimir mensagem pedindo um novo operador
		li a7, 4 	# a7 = 4, chamada de sistema para imprimir string
		la a0, str_msg2 # a0 = endereço da mensagem "\nDigite o operador: \n"
		ecall		# Chamada ao sistema para imprimir na tela 
		
		# Ler um caractere do usuário (operador)		
		li a7, 12       # a7 = 12, chamada para ler um caractere do teclado
		ecall           # Valor lido é armazenado em a0

		# Armazenar operador lido na variável 'operador'
		la t0, operador # Carrega em t0 o endereço da variável 'operador'		
		sb a0, 0(t0)    # Armazena o valor de a0 (operador) no endereço de t0 (variavel 'operador')
		lb t2, 0(t0) 	# Carrega o valor do operador em t2 para análise
		
		# Verificar se o operador é 'u' ou 'f'
		
		# Verificar se operador é 'f' (finalizar programa)
		li t3, 'f'		# t3 recebe o caractere 'f'
		beq t2, t3, fim_code	# se t2 == 'f', salta para fim_code
		
		# Verificar se operador é 'u' (undo)
		li t3, 'u'		# t3 recebe o caractere 'u'
		beq t2, t3, undo	# se t2 == 'u', salta para undo

		# Verificar se operador é válido para nova operação

		# Verifica se é soma
		li t3, '+'		# t3 recebe '+'
		beq t2, t3, ler_numero	# Se t2 (operador lido) == t3 ('+') salta para ler_numero
		
		# Verifica se é subtração
		li t3, '-'		# t3 recebe '-'
		beq t2, t3, ler_numero	# Se t2 (operador lido) == t3 ('-') salta para ler_numero
		
		# Verifica se é multiplicação
		li t3, '*'		# t3 recebe '*'
		beq t2, t3, ler_numero	# Se t2 (operador lido) == t3 ('*') salta para ler_numero
		
		# Verifica se é divisão
		li t3, '/'		# t3 recebe '/'
		beq t2, t3, ler_numero	# Se t2 (operador lido) == t3 ('/') salta para ler_numero
		
		# Caso contrário, operador inválido, imprimindo mensagem de erro
		li a7, 4	# a7 = 4, chamada para imprimir string
		la a0, str_erro	# a0 = endereço da mensagem "\nOperador inválido.\n"
		ecall		# imprime a mensagem de erro
		
		j demais_entradas # Retorno para pedir ao usuário digitar novamente um operador
		
#-------------------------------------------------------------
# O label 'ler_numero' é responsável por ler um operando (número) do usuário
# Ele é chamado após a identificação de que foi digitado um operador
#-------------------------------------------------------------
ler_numero:
		# --- LEITURA DO NOVO OPERANDO E PREPARAÇÃO PARA OPERAÇÃO ---
		# Este bloco exibe uma mensagem, lê um número do usuário e prepara os registradores
		# para a operação aritmética com o valor anterior (resultado) e o novo valor lido.
		#
		# Registradores usados:
		# a0  Parâmetro de entrada e saída de ecall
		# a7  Especifica o tipo da chamada de sistema
		# t0  valor anterior (resultado)
		# t1  novo número lido
		# t2  operador selecionado
		# t3  endereço temporário
		# s0  endereço de armazenamento do resultado
		# ------------------------------------------------------------
			
		# Imprimir mensagem pedindo novo número
		li a7, 4	# a7 = 4, chamada para imprimir string 
		la a0, str_msg1	# a0 = endereço da string str_msg1, que é "\nDigite um número: \n"
		ecall		# Imprime a mensagem solicitando novo número
		
		# Ler número inteiro digitado pelo usuário
		li a7, 5      # Syscall para ler inteiro
		ecall         # Valor lido será armazenado em a0
		
		# Recupera o resultado anterior e guarda em t0
 		la t3, resultado	# Carrega o endereço de resultado em t3
 		lw t0, 0(t3) 		# t0 recebe o valor armazenado como resultado anterior

		# Carrega o número lido em t1
 		la t1, numero2	# t1 = endereço da variável numero2
 		sw a0, 0(t1)  	# Armazena o valor lido (a0) em numero2
 		lw t1,0(t1)    	# t1 = novo número carregado da memória
 		
 		# Com isso, tem-se
 		# t0: resultado anterior
  		# t1: valor lido do usuário
 		
 		# Passa o operador para t2
 		la t2, operador	# t2 = endereço da variável operador
 		lb t2, 0(t2) 	# t2 = operador (char) carregado da memória
 		
 		# Carrega o endereço da variável resultado em s0
		la s0, resultado	# s0 = endereço da variável resultado
		
		# Salta para identificar a operação
 		j escolhe_operacao	# Salta para o label escolhe_operacao
	
#-------------------------------------------------------------
# O label 'fim_code' é responsável por encerrar o programa
#-------------------------------------------------------------	
fim_code:
		# --- ENCERRAMENTO DO PROGRAMA ---
		# Este bloco imprime uma mensagem final e encerra a execução do programa.
		#
		# Registradores usados:
		# a0  Parâmetro de entrada da ecall
		# a7  Código da chamada de sistema (syscall)
		# -------------------------------------------

		# Imprimir mensagem final de encerramento
		li a7,4 		# a7 = 4, chamada ao sistema para imprimir string 
		la a0, str_prog_fin	# a0 = endereço da string str_prog_fin que é "\nPrograma encerrado!\n"
		ecall			# Chamada ao sistema para imprimir a mensagem
		
		# Encerrar programa
		li a7, 10	# Syscall 10 para encerrar 
		ecall		# Chamada ao sistema para finalizar
		
# Função que recebe 2 parâmetros e retorna a soma deles
funcao_somar:
		# --- FUNÇÃO DE SOMA ---
		# Esta função realiza a soma de dois operandos inteiros recebidos em a0 e a1.
		# O resultado da soma é retornado em a0.
		#
		# Parâmetros:
		# 	a0  Primeiro operando e também registrador de retorno
		# 	a1  Segundo operando
		# 
		# Registrador t0  Registrador temporário para armazenar o resultado da operação
		# 
		# Retorno: 
		#	a0 - resultado da soma
		# -------------------------------------------
		
		# Realiza a soma dos operandos e retorna o resultado
		add t0, a0, a1	# t0 = a0 + a1, armazena a soma dos dois operandos
		mv a0, t0	# Move o resultado (t0) de volta para a0
		jr ra 		# Salta para o endereço armazenado em ra

# Função que recebe 2 parâmetros e retorna a subtração entre eles
funcao_subtrair:
		# --- FUNÇÃO DE SUBTRAÇÃO ---
		# Esta função realiza a subtração entre dois operandos inteiros recebidos em a0 e a1.
		# O resultado da subtração (a0 - a1) é retornado em a0.
		#
		# Parâmetros:
		# 	a0  Primeiro operando (minuendo) e também registrador de retorno
		# 	a1  Segundo operando (subtraendo)
		#
		# t0  Registrador temporário para armazenar o resultado da operação
		# 
		# Retorno:
		# 	a0 - resultado da subtração
		# -------------------------------------------
		
		sub t0, a0, a1	# t0 = a0 - a1, calcula a diferença entre os dois operandos
		mv a0, t0	# Move o resultado (t0) de volta para a0
		jr ra		# Retorna, saltando para o endereço armazenado em ra

# Função que recebe 2 parâmetros e retorna a divisão entre eles
funcao_dividir:
		# --- FUNÇÃO DE DIVISÃO ---
		# Esta função realiza a divisão inteira entre dois operandos inteiros recebidos em a0 e a1.
		# O resultado da divisão (a0 / a1) é retornado em a0.
		# Observação: Caso o divisor (a1) seja zero, a execução é redirecionada
		# para erro_divisao.
		#
		# Parâmetros:
		# 	a0  Primeiro operando (dividendo) e também registrador de retorno
		# 	a1  Segundo operando (divisor)
		# 
		# Registrador t0  Registrador temporário para armazenar o resultado da operação
		# 
		# Retorno:
		#	a0 - resultado da divisão
		# -------------------------------------------
		
		# Verifica se o divisor é zero
		beq a1, zero, erro_divisao	# se a1 == 0, pula para erro_divisao (evita divisão por zero)
		
		div t0, a0,a1	# Realiza a divisão inteira dos operandos
		mv a0, t0	# Move o resultado (t0) de volta para a0
		jr ra		# Retorna, saltando para o endereço armazenado em ra
  
# Função que recebe 2 parâmetros e retorna a multiplicação entre eles
funcao_multiplicar:
		# --- FUNÇÃO DE MULTIPLICAÇÃO ---
		# Esta função realiza a multiplicação entre dois operandos inteiros recebidos em a0 e a1.
		# O resultado da multiplicação (a0 * a1) é retornado em a0.
		#
		# Parâmetros:
		# 	a0  Primeiro operando (multiplicando) e também registrador de retorno
		# 	a1  Segundo operando (multiplicador)
		# 
		# Registrador t0  Registrador temporário para armazenar o resultado da operação
		# 
		# Retorno: 
		# 	a0 - resultado da multiplicação
		# -------------------------------------------
		
		# Multiplica os parâmetros e retorna o resultado em a0
		mul t0, a0, a1	# Multiplica a0 e a1 e guarda em t0
		mv a0, t0	# Passa o resultado de t0 para a0
		
		jr ra		# Retorna o valor em a0

# A função a seguir imprime o resultado na tela
funcao_imprimir:
		#---- FUNÇÃO DE IMPRIMIR -----------------------------------
		# Esta função imprime um número inteiro na tela
		# 
		# Parâmetros:
		#   a1 - valor a ser impresso
		# Retorno:
		#   nenhum
		#-----------------------------------------------------------
		
		# Imprimir a mensagem que apresenta o resultado
		li a7, 4	# Syscall de código 4, para imprimir string na tela
		la a0, str_msg3 # Passa o endereço da mensagem "\nResultado: \n" para a0
		ecall		# Chamada da função, imprimindo na tela
	
		#imprimir o resultado
		li a7, 1	# Código 1 da syscall, para imprimir inteiro
		mv a0, a1	# Move o valor de a1 (inteiro a ser impresso) para a0
		ecall		# chamada de sistema para imprimir o inteiro
		
		jr ra		# Retorna para a função chamadora


# Implementação da lista encadeada

# A seguinte função implementa adicionar um elemento na lista encadeada
# Para isso, um novo nó é formado e um valor é passado para esse nó
# Esta função é utilizada pelo código principal para inserir os resultados
# que vão sendo obtidos e poder recuperar caso necessário
lista_adicionar_elemento:
		# --- INSERE RESULTADO NA LISTA LIGADA ---
		# Esta função aloca um novo nó de 8 bytes na memória (4 bytes para valor, 4 bytes para ponteiro)
		# e insere o valor do resultado no início da lista encadeada ligada à variável 'head'.
		#
		# Parâmetros:
		# 	a0  argumento da syscall sbrk e valor de retorno (endereço alocado)
		# 	a1  contém o valor do resultado a ser armazenado no novo nó
		# Registradores:
		# 	a7  código da syscall (9 para alocação)
		# 	t0  endereço do novo nó
		# 	t1  endereço da variável head
		# 	t2  valor anterior de head (ponteiro para o próximo nó)
		# 	ra  endereço de retorno para o chamador
		# Retorno:
		# 	nenhum
		# --------------------------------------------------------

	    	# Aloca a memória para o novo nó (8 bytes)
	    	li a7, 9     	# Syscall código 9 para alocar memória
	    	li a0, 8	# Requisita 8 bytes (4 para valor, 4 para ponteiro)
	    	ecall	     	# Chamada de sistema: aloca memória
		mv t0, a0	# salva o endereço retornado em t0 (novo nó)
	
	    	# Armazena o valor inteiro nos primeiros 4 bytres do nó
		sw a1, 0(t0)	# armazena o valor de a1 (valor inteiro) no início do novo nó
	
	    	# Armazenar ponteiro para o nó anterior (antigo head)
		la t1, head	# Carrega o endereço da variável head
		lw t2, 0(t1)	# t2 recebe o valor atual de head (ponteiro para nó antigo)
		sw t2, 4(t0)	# Armazena o antigo head na segunda palavra do novo nó
				# São pulados 4 bytes pois os primeiros 4 guardam o valor inteiro
	    
	    	# Fazer o head apontar para novo nó
		sw t0, 0(t1)	# Atualiza a variável head para apontar para o novo nó
	
		# Retorna
		jr ra		# Retorna à função chamadora

#-----------------------------------------------------------
# desempilhar_resultado
# Remove o topo da pilha e retorna o valor desempilhado em a0
# Retorno:
#   a0 - valor desempilhado (último resultado)
#   Se pilha estiver vazia, a0 = 0 e a1 = 0
#-----------------------------------------------------------
lista_remover_elemento:
		# --- Remove o último nó da lista encadeada ---
		# Esta função retira o valor no 'topo' da lista encadeada (apontada por 'head'),
		# atualiza o ponteiro para o próximo nó e retorna o valor removido.
		#
		# Se a lista estiver vazia (head == NULL), salta para lista_vazia.
		#
		# Parâmetros:
		#	a0 - valor removido (retorno da função)
		#	a1 - flag de sucesso (1)
		#
		# Registradores usados:
		# 	t0  endereço da variável head
		# 	t1  endereço do nó atual (nó a ser removido)
		# 	t2  endereço do nó anterior ao removido
		# 	ra  endereço de retorno para o chamador
		#
		# Retorno:
		#   a0 - valor desempilhado (último resultado)
		#   Se pilha estiver vazia, a0 = 0 e a1 = 0
		# --------------------------------------------------------
		
		# Para remover um nó, são realizadas duas ações principais:
		# 1 - Fazer o conteúdo do head apontar para o endereço do nó anterior ao removido 
		# 2 - Guardar o valor do nó removido em a0 e retornar
		
		# Exemplo: se a lista está como head -> nó 3 -> nó 2 -> nó 1 -> 0
		# Então remover o nó 3 faria o head apontar para nó 2:
		# head -> nó 2 -> nó 1 -> 0
		# Observação: a lista cresce para "trás" (esquerda) e diminui para "frente" (direita)
		
		# Fazer o head apontar para o nó anterior ao removido
		
		# Guarda o endereço do nó cabeça em t1
		la t0, head	# Carrega o endereço da variável head em t0
		lw t1, 0(t0)    # Carrega o conteúdo de head (que é o endereço do nó cabeça) em t1
				# Assim, t1 = endereço do último nó adicionado
	
		# Verifica se a lista está vazia
	    	beqz t1, lista_vazia	# se o t1 (endereço do nó cabeça) == 0, 
	    				# então a lista está vazia, saltando para lista_vazia
		
		# Representação exemplo da lista:
		# head -> nó 3 -> nó 2 -> nó 1 -> 0
		# Nesse caso, nó 3 é o nó a ser removido
		# nó anterior ao removido = nó 2
		
		# Passa o endereço do nó anterior ao removido para t2
	    	lw t2, 4(t1)       # Passa para t2 o valor de 4 bytes após o endereço t1, 
	    			   # que é o endereço do nó antes do head	
	    	
	    	# Faz o conteúdo do head ser o endereço do nó anterior ao removido
	    	# Transformando o nó anterior ao removido a nova cabeça da lista
	    	sw t2, 0(t0)	# Armazena t2 (endereço do nó anterior ao removido)
	    			# em mem[0 + t0], que é o conteúdo da variável 'head'   
				# Assim, 'head' aponta para o nó anterior ao removido
	    	
	    	# Passar o valor do nó removido para a0
	    	lw a0, 0(t1)       # t1 é o endereço do nó a ser removido, então mem[0+t1] é o valor inteiro do nó
	    			   # sendo passado para a0
	    	li a1, 1           # Deixa a flag a1 como 1, indicando sucesso
	
	 	# Retorna
	    	jr ra		# Retorna para a função chamadora

lista_vazia:
		# --- CASO DE PILHA VAZIA ---
		# Esta função é chamada quando a lista encadeada está vazia (head == NULL).
		# Define os registradores de retorno indicando falha na operação de desempilhar.
		#
		# Registradores usados:
		# a0  valor nulo (0), pois não há valor para retornar
		# a1  flag de falha (0), indicando que a pilha estava vazia
		# ra  endereço de retorno para o chamador
		# --------------------------------------------------------
		
	    	li a0, 0	# a0 recebe 0, pois não há valor para remover
	    	li a1, 0	# a1 recebe 0, indicando falha (lista vazia)
	    	jr ra		# retorna à função chamadora 
	    
	    
undo:
		# --- OPERACAO DE DESFAZER (UN-DO) ---
		# Esta função é chamada para desfazer a última operação realizada.
		# Ela remove o resultado anterior e o restaura para que a operação anterior seja revertida.
		#
		# Registradores usados:
		# a0  valor da remoção (não utilizado diretamente nesta função)
		# a1  flag de sucesso ou falha no desempilhamento
		# t0, t1, t2, t3  registradores temporários usados para manipulação dos ponteiros e dados
		# ra  endereço de retorno para o chamador
		# --------------------------------------------------------
		
		# Chamando a função lista_remover_elemento para obter o valor anterior
 	    	call lista_remover_elemento
 	    	
 	    	# Verifica se a flag a1 é igual a 0, o que indica que a lista estava vazia
	    	beqz a1, sem_resultado_para_restaurar  # se flag == 0
	
	    	# Carrega o ponteiro para o head da lista em t0
	    	la t0, head
	    	lw t1, 0(t0)       			# t1 = novo head da lista (novo nó após a remoção)
	    	beqz t1, sem_resultado_para_restaurar	# Verifica se o head é nulo (lista vazia)
	
		# Carrega o valor armazenado no novo head da pilha em t2 (valor anterior)
	    	lw t2, 0(t1)      
	    	
	    	# Atualiza o valor armazenado em resultado com o valor anterior
	    	la t3, resultado
	    	sw t2, 0(t3)       # armazena o valor anterior em 'resultado'
	
		# Atualiza o registrador a1 com o valor anterior (para ser impresso)
	    	mv a1, t2
	    	
	    	# Chama a função funcao_imprimir para exibir o valor restaurado
	    	jal funcao_imprimir
	    	
	    	# Retorna para a função onde a operação foi chamada
		j demais_entradas
	
sem_resultado_para_restaurar:
		# --- MENSAGEM DE ERRO: LISTA VAZIA ---
		# Este bloco é responsável por exibir uma mensagem de erro informando que não há resultado
		# disponível para restaurar, ou seja, a pilha está vazia.
		#
		# Registradores usados:
		# a0  registrador que recebe o endereço da string de erro para exibição
		# a7  código da syscall para exibir uma string na tela
		# ra  endereço de retorno para o chamador
		# --------------------------------------------------------
		
		# Chama a syscall para imprimir a mensagem de erro "Lista vazia"
		li a7, 4		# Syscall de código 4 para imprimir string na tela
		la a0, str_lista_vazia	# Carrega o endereço da string de erro "Lista vazia" em a0
		ecall			# Chama a syscall, exibindo a string na tela
		j demais_entradas	# Retorna para o ponto de entrada das demais entradas (demais_entradas)
