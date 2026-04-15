# Projeto e Implementação de um Acelerador de Redes Neurais Convolucionais em FPGA baseado em SoC

Este repositório contém o desenvolvimento de um acelerador de hardware dedicado à rede neural **LeNet-5**, implementado em ambiente **SoC (System-on-Chip) Zynq-7000**. O projeto é parte integrante do Trabalho de Conclusão de Curso (PG1/PG2) de Engenharia da Computação na **UFES - Campus São Mateus**.

## Resumo do Projeto

A crescente complexidade das Redes Neurais Convolucionais (CNNs) impõe desafios significativos em sistemas embarcados devido ao alto custo computacional das operações de Multiplicação e Acumulação (MAC). Este projeto foca na implementação de uma arquitetura paralela em FPGA (PL) integrada a um sistema de processamento ARM (PS), visando otimizar a eficiência energética e o throughput em comparação com execuções puramente em software.

## Arquitetura do Sistema

O acelerador utiliza uma abordagem de **Co-design Hardware/Software**:

* **Processing System (PS):** Processador ARM Cortex-A9 operando com o framework **PYNQ**. Responsável pelo gerenciamento de dados, pré-processamento de imagens e controle da execução.
* **Programmable Logic (PL):** Implementação em VHDL de módulos especializados:
    * **Unidades de Processamento (PEs):** Núcleos aritméticos para convolução e pooling.
    * **Hierarquia de Memória:** Uso de BRAMs e controladores AXI para reduzir o impacto do gargalo de Von Neumann e otimizar o fluxo de dados.
    * **Controlador de Fluxo:** Máquina de estados (FSM) para sincronização das camadas da LeNet-5.

## Estrutura do Repositório

* `/Lenet5_FPGA.srcs`: Código-fonte RTL (VHDL) e definições do Block Design.
* `/notebooks`: Interface em Python (Jupyter) para interação com o hardware via PYNQ.
* `Lenet5_FPGA.xpr`: Arquivo de projeto do Vivado.
* `rebuild_bd.tcl`: Script para reconstrução do design de blocos.

## Metodologia de Desenvolvimento

O trabalho segue o fluxo de projeto para sistemas embarcados baseados em SoC:
1.  **Modelagem e Simulação:** Validação da lógica aritmética em VHDL (Vivado Simulator).
2.  **Síntese e Implementação:** Mapeamento dos recursos na FPGA XC7Z010.
3.  **Integração PYNQ:** Geração do overlay (`.bit` e `.hwh`) e desenvolvimento drivers em Python.
4.  **Avaliação de Desempenho:** Comparação de latência e consumo entre CPU e Acelerador.

## Tecnologias Utilizadas

* **Linguagem de Descrição de Hardware:** VHDL.
* **Ferramentas de EDA:** Xilinx Vivado Design Suite.
* **Plataforma de Hardware:** Zynq-7000 SoC (Zybo/ZedBoard).
* **Ambiente de Software:** PYNQ (Python on Zynq).

## Autor
* **Autor:** Norian Silva Aredes Hermsdorf
* **Instituição:** Universidade Federal do Espírito Santo (UFES) - Centro Universitário Norte do Espírito Santo (CEUNES).

---
*Este projeto está em desenvolvimento como parte dos requisitos para obtenção do título de Engenheiro de Computação (2026).*
