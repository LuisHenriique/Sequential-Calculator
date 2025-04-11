# 📟 Calculadora Sequencial em Assembly RISC-V

Este projeto é uma calculadora sequencial desenvolvida em linguagem de montagem **Assembly RISC-V**, capaz de realizar operações aritméticas básicas de forma encadeada e com funcionalidade de **desfazer (`undo`)**.  

## 🧠 Funcionalidades

- Soma (`+`)
- Subtração (`-`)
- Multiplicação (`*`)
- Divisão (`/`) com tratamento de divisão por zero
- Encadeamento de operações com uso do resultado anterior
- Desfazer a última operação (`u`)
- Finalizar o programa (`f`)
- Mensagens de erro para entradas inválidas

## 📋 Estrutura do Código

O código é dividido nas seguintes seções principais:

### 📌 Seção `.data`

Contém as **mensagens de texto** e **variáveis principais**:
- `numero1`, `numero2`: operandos
- `resultado`: armazena o resultado atual da operação
- `operador`: caractere representando a operação (`+`, `-`, `*`, `/`, `u`, `f`)
- Mensagens de entrada, erro e finalização

### ⚙️ Seção `.text`

A seção principal com a lógica do programa:
1. Leitura do primeiro número
2. Leitura do operador
3. Leitura do segundo número
4. Escolha da operação:
   - Desvia para uma das funções: `somar`, `subtrair`, `multiplicar`, `dividir`
   - Verifica por operadores especiais: `u` (undo), `f` (fim)
5. Impressão do resultado
6. Encadeamento: usa o resultado como próximo `numero1`
7. Armazena o histórico para possível operação de desfazer (por meio de lista encadeada, não incluída neste trecho)

## 💻 Execução

### ✅ Requisitos
- Um simulador RISC-V, como:
  - [RARS (RISC-V Assembler and Runtime Simulator)](https://github.com/TheThirdOne/rars)
  - [Venus (online RISC-V simulator)](https://venus.cs61c.org/)

### ▶️ Como rodar no RARS:
1. Abra o arquivo `.s` no RARS
2. Clique em "Assemble"
3. Execute com "Run" ou `F5`
4. Siga as instruções no console

## 📌 Comandos durante a execução

| Entrada | Ação |
|--------|------|
| Número inteiro | Operando para a operação |
| `+` | Soma |
| `-` | Subtração |
| `*` | Multiplicação |
| `/` | Divisão |
| `u` | Desfaz a última operação |
| `f` | Finaliza a calculadora |

## ⚠️ Tratamento de erros

- **Operador inválido:** exibe mensagem e pede nova entrada.
- **Divisão por zero:** exibe mensagem de erro e termina o programa.
- **Undo sem histórico:** exibe que não há operações a desfazer.

## 📎 Observações

- O programa reutiliza o **resultado anterior** como primeiro operando da próxima operação.
- A funcionalidade de **undo** depende de uma lista encadeada (provavelmente com funções `inserir_resultado` e `undo`), que deve ser implementada à parte para funcionar plenamente.
- Modularização: as operações matemáticas são chamadas como sub-rotinas (por exemplo, `funcao_somar`, `funcao_imprimir`).

## 🛠️ Possíveis melhorias

- Implementar a exibição de histórico completo das operações.
- Melhorar a estrutura de `undo` com controle de múltiplos níveis.
- Separar as funções auxiliares em outro arquivo `.s` para modularização.

## 👨‍💻 Autor

Calculadora desenvolvida em Assembly RISC-V como parte de estudos de arquitetura de computadores e programação de baixo nível.