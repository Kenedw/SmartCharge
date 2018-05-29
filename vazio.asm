;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 16F877A                  *
;*                FEITAS POR KENED OLIVEIRA                        *
;*                    ABRIL DE 2018                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       NOME DO PROJETO                           *
;*                           CLIENTE                               *
;*         DESENVOLVIDO POR                                        *
;*   VERSÃO:	                           DATA:                   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRIÇÃO DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 16f877A                                     *
;*                                                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p16f877a.inc>		    ;ARQUIVO PADRÃO MICROCHIP PARA 16F877A
    __CONFIG _CP_OFF & _CPD_OFF & _DEBUG_OFF & _LVP_OFF & _WRT_OFF & _PWRTE_ON & _WDT_OFF & _HS_OSC & _BODEN_ON
    
				    ; CP - CODE PROTECTION (HABILITA OU DESABILITA LEITURA DA MEMÓRIA DE PROGRAMA).
				    ; DEBUG - DEPURADOR DA PLACA ICD 2 (HABILITA OU DESABILITA DEPURADOR DA PLACA ICD 2).
				    ; PWRTE - POWER UP TIMER (HABILITA OU DESABILITA TEMPORIZADOR QUE AGUARDA 72 ms PARA
				    ;ESTABILIZAR O PIC).
				    ; WDT - WATCHDOG TIMER ("CÃO DE GUARDA" TEMPORIZADOR QUE RESETA O PIC QUANDO SISTEMA
				    ;TRAVADO).
				    ; BOREN - BROWN OUT DETECT (SE A ALIMENTAÇÃO VDD FOR MENOR QUE 4V DURANTE 100 MICRO-SEG.
				    ;O PIC RESETA).
				    ; LVP - LOW VOLTAGE PROGRAM (SISTEMA DE PROGRAMAÇÃO EM BAIXA TENSÃO).
				    ; XT - OSCILADOR DO TIPO CRISTAL.
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;		DEFINIÇÃO DOS BANCOS DE MEMÓRIA RAM		  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#DEFINE BANK1 BSF STATUS, RP0	    ;SETA BANK 1 DE MEMÓRIA.
#DEFINE BANK0 BCF STATUS, RP0	    ;SETA BANK 0 DE MEMÓRIA.
    

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;				VARIÁVEIS			  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    
    CBLOCK 0X20			;ENDEREÇO LOCALIZADO NA MAMÓRIA DE DADOS DO BANK 0. FOI 
                        ;ESCOLHIDO, POIS ESTÁ LOCALIZAÇÃO É ACESSADA DE QUALQUER BANCO, FACILITANDO A OPERAÇÃO.
	TEMPO1              ; VARIAVEL DE TEMPO DO DELAY
	TEMPO0              ; VARIAVEL DE TEMPO DO DELAY
    AUX                 ;VARIAVEL AUXILIAR, 
	IDMENU              ; IDENTIFICAÇÃO DO MENU
    ADDR_C              ; ENDEREÇO DE MEMORIA DO CURSOR
    DISPLAY             ; VARIAVEL QUE ARMAZENA O VALOR A SER ENVIADO AO DISPLAY
	AUX_TEMP            ; VARIAVEL DE COMPENSAÇÃO DO OCILADOR
    TECLA               ; GUARDA O VALOR DA TECLA PRECIONADA
    ;GUARDA OS VALORES NOMINAIS DA BATERIA
    TNOMI
    INOMI               
    ;VARIAVEI DA FUNÇÃO DE AQUISIÇÕES
    PACK_L
    PACK_H
    MATH
    
    ENDC			    ; FIM DO BLOCO DE MEMÓRIA.
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;				ENTRADAS			  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;LINHAS E COLUNAS A SEREM MAPEADAS DO TECLADO
#DEFINE	CLN_1	PORTB,0		    
#DEFINE	CLN_2	PORTB,1		    
#DEFINE	CLN_3	PORTB,2		    
#DEFINE	LNH_1	PORTB,3		    
#DEFINE	LNH_2	PORTB,4		    
#DEFINE	LNH_3	PORTB,5		    
#DEFINE	LNH_4	PORTB,6		    
				    

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;				SAIDAS				  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#DEFINE RS      PORTA,2         ; INDICA AO DISPLAY O TIPO DA INFORMAÇÃO
                                ; RS ? 1 DADO : 0 COMANDO
#DEFINE ENABLE  PORTA,4		    ; SINAL ATIVA O DISPLAY NA BORDA DE DESCIDA
#DEFINE DISP_D4 PORTA,5
#DEFINE DISP_D5 PORTE,0
#DEFINE DISP_D6 PORTE,1
#DEFINE DISP_D7 PORTE,2


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;			  VETOR DE RESET			  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    ORG  0X0000                      ; ENDEREÇO DO VETOR DE RESET
    GOTO CONFIG_INIT			    ; PULA PARA AONDE EU QUISER

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;			CONFIG_INIT DA INTERUPÇÃO                             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
			    
    ORG 0X0004			    ; ENDEREÇO DO VETOR DE INTERRUPÇÃO
    RETFIE                  ; RETORNA DA INTERRUPÇÃO			    
			    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;		ROTINA DE DELAY_MILE (1 ~ 256 MILESSEGUNDOS)    		  *
;       ROTINA DE DELAY_MICRO(5*(1 ~ 256) MICROSSEGUNDOS)         *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;VALOR PASSADO EM WORK(W) DEFINE O DELAY            			  ;
    
DELAY_MILE
    MOVWF   TEMPO1		    ; CARREGA EM TEMPO_1 ATE AONDE VAI ESPERAR
VOLTA
    MOVLW   .5
    MOVWF   AUX_TEMP        ; TEMPORIZADOR AUXILIAR PARA COMPENSAÇÃO DO OCILADOR
    MOVLW   .250		    
    MOVWF   TEMPO0		    ; CARREGA EM TEMPO_0 1MS
    NOP
    DECFSZ  TEMPO0,F		; SE PASSOU 1MS?
    GOTO    $-2			    ; NÃO, VOLTA
    DECFSZ  AUX_TEMP
    GOTO    $-6
    DECFSZ  TEMPO1,F		; SE PASSOU O TEMPO DESEJADO?
    GOTO    VOLTA		    ; NÃO, ESPERA POR MAIS 1MS
    RETURN
    
DELAY_MICRO
    MOVWF   TEMPO0		    ; CARREGA EM TEMPO_1 ATE AONDE VAI ESPERAR
    MOVLW   .5
    MOVWF   AUX_TEMP        ; TEMPORIZADOR AUXILIAR PARA COMPENSAÇÃO DO OCILADOR
    DECFSZ  AUX_TEMP
    GOTO    $-1 			; NÃO, VOLTA
    DECFSZ  TEMPO0,F		; SE PASSOU O TEMPO?
    GOTO    $-5

    RETURN
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;	CONFIGURAÇÕES INICIAIS DE INICIALIZAÇÃO DO DISPLAY	  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; COMUNICAÇÃO DE 8 VIAS, DISPLAY DE 2 LINHAS, 
; CURSOR APAGADO E DESLOCAMENTO A DIREITA		  
INICIALIZA_DISPLAY
    MOVLW   .20
    CALL    DELAY_MILE
    
    BCF	    RS			    ; SELECIONA O DISPLAY COMO COMANDOS

    ; ENVIA 30H
    BCF     DISP_D7
    BCF     DISP_D6
    BSF     DISP_D5
    BSF     DISP_D4

    NOP                     ; ESPERA UM POUCO PARA ESTABILIZAR
    BSF	    ENABLE		    ; ATIVA O DISPLAY
    GOTO    $+1			    ; GASTA 2US PARA ESTABILIZAR
    BCF	    ENABLE		    ; DESATIVA O DISPLAY
    
    MOVLW   .15
    CALL    DELAY_MILE		; DELAY_MILE DE 4ms
    
    ; ENVIA 30H
    BCF     DISP_D7
    BCF     DISP_D6
    BSF     DISP_D5
    BSF     DISP_D4

    NOP                     ; ESPERA UM POUCO PARA ESTABILIZAR
    BSF	    ENABLE		    ; ATIVA O DISPLAY
    GOTO    $+1			    ; GASTA 2US PARA ESTABILIZAR
    BCF	    ENABLE		    ; DESATIVA O DISPLAY

    MOVLW   .10
    CALL    DELAY_MILE		; DELAY_MILE DE 1Ms

    ; ENVIA 30H
    BCF     DISP_D7
    BCF     DISP_D6
    BSF     DISP_D5
    BSF     DISP_D4

    NOP                     ; ESPERA UM POUCO PARA ESTABILIZAR
    BSF	    ENABLE		    ; ATIVA O DISPLAY
    GOTO    $+1			    ; GASTA 2US PARA ESTABILIZAR
    BCF	    ENABLE		    ; DESATIVA O DISPLAY

    MOVLW   .10
    CALL    DELAY_MILE		; DELAY_MILE DE 1MS

    ; ENVIA 20H
    BCF     DISP_D7
    BCF     DISP_D6
    BSF     DISP_D5
    BCF     DISP_D4

    NOP                     ; ESPERA UM POUCO PARA ESTABILIZAR
    BSF	    ENABLE		    ; ATIVA O DISPLAY
    GOTO    $+1			    ; GASTA 2US PARA ESTABILIZAR
    BCF	    ENABLE		    ; DESATIVA O DISPLAY

    MOVLW   .10
    CALL    DELAY_MILE		; DELAY_MICRO DE 1MS
    
    MOVLW   0X28
    CALL    ESCREVE         ; CONF DO DISPLAY, 4 VIAS, DISPLAY 2 LINHAS

    MOVLW   .10
    CALL    DELAY_MILE		; DELAY_MICRO DE 1MS
    
    MOVLW   0X01
    CALL    ESCREVE		    ; COMANDO LIMPA TELA
    
    MOVLW   .5
    CALL    DELAY_MILE		; DELAY_MILE DE 1ms

    MOVLW   0X0C		    
    CALL    ESCREVE		    ; LIGA SEM CURSOR
    
    MOVLW   .5
    CALL    DELAY_MILE		; DELAY_MILE DE 1ms
    
    MOVLW   0X06
    MOVWF   ESCREVE		    ; HABILITA INCREMENTO A DIREITA COM SHIFT
    
    BSF     RS
    
    ;teste de animação depois da inicialização  
;    MOVLW   0X81
;    MOVWF   ADDR_C          ;INDICA A POSIÇÃO DO CURSO NA LINHA 2
;    
;    ;ESCRITA NA SEGUNDA LINHA
;    BCF	    RS			    ;SELECIONA O DISPLAY PARA COMANDOS
;    MOVLW   .3
;    CALL    ESCREVE
;    MOVLW   .192		    ;POSICIONA O CURSOR PARA A LINHA 2
;    CALL    ESCREVE
;    MOVLW   .1
;    CALL    DELAY_MILE
;    BSF	    RS			    ;VOLTA PARA O DISPLAY RECEBER DADOS
; 

    
    RETURN
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;	    ROTINA DE ESCRITA DE UM CARACTER NO DISPLAY		  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; O CARACTER A SER ESCRITO DEVE ESTAR EM WORK(W)			  

ESCREVE
    
    MOVWF   DISPLAY		    ; ATUALIZA DISPLAY
    ;CARREGA O 8º BIT
    RLF     DISPLAY
    BTFSC   STATUS,C
    BSF     DISP_D7
    BTFSS   STATUS,C
    BCF     DISP_D7
    ;CARREGA O 7º BIT
    RLF     DISPLAY
    BTFSC   STATUS,C
    BSF     DISP_D6
    BTFSS   STATUS,C
    BCF     DISP_D6
    ;CARREGA O 6º BIT
    RLF     DISPLAY
    BTFSC   STATUS,C
    BSF     DISP_D5
    BTFSS   STATUS,C
    BCF     DISP_D5
    ;CARREGA O 5º BIT
    RLF     DISPLAY
    BTFSC   STATUS,C
    BSF     DISP_D4
    BTFSS   STATUS,C
    BCF     DISP_D4

    ;ENVIA OS 4 BITS MAIS SIGNIFICATIVOS
    NOP                     ; ESPERA UM POUCO PARA ESTABILIZAR
    BSF	    ENABLE		    ; ATIVA O DISPLAY
    GOTO    $+1			    ; GASTA 2US PARA ESTABILIZAR
    BCF	    ENABLE		    ; DESATIVA O DISPLAY
    MOVLW   .5
    CALL    DELAY_MILE		; ESPERA 1MS

    
    ;CARREGA O 4º BIT
    RLF     DISPLAY
    BTFSC   STATUS,C
    BSF     DISP_D7
    BTFSS   STATUS,C
    BCF     DISP_D7
    ;CARREGA O 3º BIT
    RLF     DISPLAY
    BTFSC   STATUS,C
    BSF     DISP_D6
    BTFSS   STATUS,C
    BCF     DISP_D6
    ;CARREGA O 2º BIT
    RLF     DISPLAY
    BTFSC   STATUS,C
    BSF     DISP_D5
    BTFSS   STATUS,C
    BCF     DISP_D5
    ;CARREGA O 1º BIT
    RLF     DISPLAY
    BTFSC   STATUS,C
    BSF     DISP_D4
    BTFSS   STATUS,C
    BCF     DISP_D4

    ;ENVIA OS 4 BITS MENOS SIGNIFICATIVOS
    NOP                     ; ESPERA UM POUCO PARA ESTABILIZAR
    BSF	    ENABLE		    ; ATIVA O DISPLAY
    GOTO    $+1			    ; GASTA 2US PARA ESTABILIZAR
    BCF	    ENABLE		    ; DESATIVA O DISPLAY
    MOVLW   .5
    CALL    DELAY_MILE	    ; ESPERA 125US

    RETURN    
    
SHIFT_DISPLAY
    BCF     RS
    MOVLW   0X18
    CALL    ESCREVE
    BSF     RS
    RETURN

;0X81 POSIÇÃO 1 DA LINHA 0
SHIFT_CURSOR
    BCF     RS
    MOVF    ADDR_C,W            ; PASSA O PONTEIRO PARA SER MOVIDO
    CALL    ESCREVE 
    BSF     RS
    INCF    ADDR_C,F            ; INCREMENTA O PONTEIRO

    RETURN


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;	     ROTINA PARA PASSAR O PROXIMO MENU			  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
PROXIMO_MENU
    INCF    IDMENU,F		    ; INCREMENTA O IDENTIFICADOR DE MENU
    MOVFW   IDMENU
    ;VERIFICA SE ULTRAPASSOU O TAMANHO DO MENU DE 5 POSIÇÕES
    SUBLW   .5			
    BTFSS   STATUS,C		    
    GOTO    $+3
    CALL    MOSTRA_SUBMENU
    RETURN
    
    MOVLW   .1
    MOVWF   IDMENU
    CALL    MOSTRA_SUBMENU
    RETURN
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;	     ROTINA PARA VOLTAR AO MENU ANTERIOR		  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
ANTERIOR_MENU
    DECF    IDMENU,F		    ; INCREMENTA O IDENTIFICADOR DE MENU
    MOVF    IDMENU,F
    BTFSC   STATUS,Z
    GOTO    $+3
    ;VERIFICA SE ULTRAPASSOU O TAMANHO DO MENU DE 5 POSIÇÕES
    CALL    MOSTRA_SUBMENU
    RETURN
    
    MOVLW   .5
    MOVWF    IDMENU
    CALL    MOSTRA_SUBMENU
    RETURN
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;	     ROTINA QUE VAI MOSTRA O SUBMENU DE OPÇÕES		  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MOSTRA_SUBMENU
    
    ;VERIFICA QUAL O ID DO MENU E MOSTRA NA TELA
    MOVLW   .1
    SUBWF   IDMENU,W
    BTFSC   STATUS,Z
    GOTO    ESC1
    
    MOVLW   .2
    SUBWF   IDMENU,W
    BTFSC   STATUS,Z
    GOTO    ESC2
    
    MOVLW   .3
    SUBWF   IDMENU,W
    BTFSC   STATUS,Z
    GOTO    ESC3
    
    MOVLW   .4
    SUBWF   IDMENU,W
    BTFSC   STATUS,Z
    GOTO    ESC4
    
    MOVLW   .5
    SUBWF   IDMENU,W
    BTFSC   STATUS,Z
    GOTO    ESC5

    
ESC1
    
    MOVLW   0XC1
    MOVWF   ADDR_C          ;INDICA A POSIÇÃO DO CURSO NA LINHA 2
    
    ;ESCRITA NA SEGUNDA LINHA
    BCF	    RS			    ;SELECIONA O DISPLAY PARA COMANDOS
    MOVLW   .3
    CALL    ESCREVE
    MOVLW   .192		    ;POSICIONA O CURSOR PARA A LINHA 2
    CALL    ESCREVE
    MOVLW   .1
    CALL    DELAY_MILE
    BSF	    RS			    ;VOLTA PARA O DISPLAY RECEBER DADOS
    
    MOVLW   'B'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'A'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'T'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   ' '
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '3'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '.'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '7'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'V'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '-'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '7'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '0'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '0'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'm'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'A'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'h'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   ' '
    CALL    ESCREVE
    CALL    SHIFT_CURSOR

    MOVLW   .200
    CALL    DELAY_MILE      ; DELAY DE 200ms

    RETURN
ESC2

    MOVLW   0XC1
    MOVWF   ADDR_C          ; INDICA A POSIÇÃO DO CURSO NA LINHA 2
    
    ;ESCRITA NA SEGUNDA LINHA
    BCF	    RS			    ; SELECIONA O DISPLAY PARA COMANDOS
    MOVLW   .3
    CALL    ESCREVE
    MOVLW   .192		    ; POSICIONA O CURSOR PARA A LINHA 2
    CALL    ESCREVE
    MOVLW   .1
    CALL    DELAY_MILE
    BSF	    RS			    ; VOLTA PARA O DISPLAY RECEBER DADOS
    
    MOVLW   'C'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'R'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '2'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '0'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '3'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '2'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   ' '
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '3'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'V'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '-'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '2'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '4'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '0'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'm'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'A'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'h'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR

    MOVLW   .200
    CALL    DELAY_MILE      ; DELAY DE 200ms

    RETURN
ESC3

    MOVLW   0XC1
    MOVWF   ADDR_C          ;INDICA A POSIÇÃO DO CURSO NA LINHA 2
    
    ;ESCRITA NA SEGUNDA LINHA
    BCF	    RS			    ;SELECIONA O DISPLAY PARA COMANDOS
    MOVLW   .3
    CALL    ESCREVE
    MOVLW   .192		    ;POSICIONA O CURSOR PARA A LINHA 2
    CALL    ESCREVE
    MOVLW   .1
    CALL    DELAY_MILE
    BSF	    RS			    ;VOLTA PARA O DISPLAY RECEBER DADOS
    
    MOVLW   'A'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'A'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'A'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   ' '
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '1'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   ','
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '5'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'V'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '-'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '1'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '1'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '0'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '0'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'm'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'A'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'h'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR

    MOVLW   .200
    CALL    DELAY_MILE      ; DELAY DE 200ms

    RETURN
ESC4
    
    MOVLW   0XC1
    MOVWF   ADDR_C          ; INDICA A POSIÇÃO DO CURSO NA LINHA 2
    
    ;ESCRITA NA SEGUNDA LINHA
    BCF	    RS			    ; SELECIONA O DISPLAY PARA COMANDOS
    MOVLW   .3
    CALL    ESCREVE         ; POSICIONA O DISPLAY NO INICIO DA LINHA    
    MOVLW   .192		    ; POSICIONA O CURSOR PARA A LINHA 2
    CALL    ESCREVE
    MOVLW   .1
    CALL    DELAY_MILE
    BSF	    RS			    ; VOLTA PARA O DISPLAY RECEBER DADOS
    
    MOVLW   'A'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'A'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   ' '
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '1'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   ','
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '5'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'V'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '-'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '2'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '5'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '0'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '0'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'm'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'A'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'h'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   ' '
    CALL    ESCREVE
    CALL    SHIFT_CURSOR

    MOVLW   .200
    CALL    DELAY_MILE      ; DELAY DE 200ms

    RETURN
ESC5

    MOVLW   0XC1
    MOVWF   ADDR_C          ;INDICA A POSIÇÃO DO CURSO NA LINHA 2
    
    ;ESCRITA NA SEGUNDA LINHA
    BCF	    RS			    ;SELECIONA O DISPLAY PARA COMANDOS
    MOVLW   .3
    CALL    ESCREVE
    MOVLW   .192		    ;POSICIONA O CURSOR PARA A LINHA 2
    CALL    ESCREVE
    MOVLW   .1
    CALL    DELAY_MILE
    BSF	    RS			    ;VOLTA PARA O DISPLAY RECEBER DADOS
    
    MOVLW   'P'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'E'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'R'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'S'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'O'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'N'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'A'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'L'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'I'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'Z'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'A'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'D'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'O'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   ' '
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   ' '
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   ' '
    CALL    ESCREVE
    CALL    SHIFT_CURSOR

    MOVLW   .200
    CALL    DELAY_MILE      ; DELAY DE 200ms


    RETURN
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;	     ROTINA DE MAPEAMENTO DOS BOTÕES DO TECLADO		  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;ACIONA AS COLUNAS DO TECLADO E LER AS COLUNAS, A FIM DE ACHAR SUA POSIÇÃO
;RETORNA A TECLA PRECIONA EM WORK
		;     j1 j2 j3
		;i1 |  1  2  3  |
		;i2 |  4  5  6  |
		;i3 |  7  8  9  |
		;i4 |  *  0  #  |
VARRE_BOTAO
    
    CLRF    PORTB           ; LIMPAS PORTAS PARA COMEÇAR A LEITURA
    ;LEITURA DA PRIMEIRA COLUNA
    BCF	    CLN_1			; HABILITA A PRIMEIRA COLUNA
    BSF	    CLN_2			; DESABILITA A SEGUNDA COLUNA
    BSF	    CLN_3			; DESABILITA A TERCEIRA COLUNA
    
    MOVLW   .1
    CALL    DELAY_MILE
    
    BTFSS   LNH_1
    RETLW   .1
    BTFSS   LNH_2
    RETLW   .4
    BTFSS   LNH_3
    RETLW   .7
    BTFSS   LNH_4
    RETLW   .10				; REPRESENTA O *

    ;LEITURA DA SEGUNDA COLUNA
    BSF	    CLN_1			; DESABILITA A PRIMEIRA COLUNA
    BCF	    CLN_2			; HABILITA A SEGUNDA COLUNA
    BSF	    CLN_3			; DESABILITA A TERCEIRA COLUNA

    MOVLW   .1
    CALL    DELAY_MILE
  
    BTFSS   LNH_1
    RETLW   .2
    BTFSS   LNH_2
    RETLW   .5
    BTFSS   LNH_3
    RETLW   .8
    BTFSS   LNH_4
    RETLW   .0				
    
    ;LEITURA DA TERCEIRA COLUNA
    BSF	    CLN_1			; DESABILITA A PRIMEIRA COLUNA
    BSF	    CLN_2			; DESABILITA A SEGUNDA COLUNA
    BCF	    CLN_3			; HABILITA A TERCEIRA COLUNA
  
    MOVLW   .1
    CALL    DELAY_MILE

    BTFSS   LNH_1
    RETLW   .3
    BTFSS   LNH_2
    RETLW   .6
    BTFSS   LNH_3
    RETLW   .9
    BTFSS   LNH_4
    RETLW   .11				; REPRESENTA O #

    RETURN


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;		ROTINA PARA DESENHAR O MENU PRINCIPAL		  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESCREVE NA PELA PRINCIPAL
; LINHA1 -> ESCOLHA Vbat E Icarga | <- 1 -> 2 * CONFIRMA |
; LINHA2 -> 3.7V - 70mA
MOSTRA_MENU
    MOVLW   0X81
    MOVWF   ADDR_C		    ;POSICIONA O CURSOR NA LINHA 0 COLUNA 16

    BCF	    RS			    ; SELECIONA O DISPLAY PARA COMANDOS
    MOVLW   .1
    CALL    ESCREVE         ; LIMPA DISPLAY
    MOVLW   .3
    CALL    ESCREVE         ; POSICIONA O CURSOR NO INICIO DA LINHA 0
    BSF	    RS			    ; SELECIONA O DISPLAY PARA DADOS
    
    ;COMANDO PARA ESCREVER "ESCOLHA Vbat E Icarga"
    MOVLW   'E'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   's'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'c'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'o'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'l'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'h'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'a'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   ' '
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'V'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   ' '
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'e'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   ' '
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'I'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   ' '
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '<'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   '-'
    CALL    ESCREVE
    CALL    SHIFT_DISPLAY
    MOVLW   '1'
    CALL    ESCREVE
    CALL    SHIFT_DISPLAY
    MOVLW   ' '
    CALL    ESCREVE
    CALL    SHIFT_DISPLAY
    MOVLW   '-'
    CALL    ESCREVE
    CALL    SHIFT_DISPLAY
    MOVLW   '>'
    CALL    ESCREVE
    CALL    SHIFT_DISPLAY
    MOVLW   '2'
    CALL    ESCREVE
    CALL    SHIFT_DISPLAY
    MOVLW   ' '
    CALL    ESCREVE
    CALL    SHIFT_DISPLAY
    MOVLW   '*'
    CALL    ESCREVE
    CALL    SHIFT_DISPLAY
    MOVLW   'O'
    CALL    ESCREVE
    CALL    SHIFT_DISPLAY
    MOVLW   'K'
    CALL    ESCREVE

    ;FIM DA ESCRITA DA PRIMEIRA LINHA
    MOVLW   .1
    MOVWF   IDMENU		     ;FLAG QUE DIRA QUAL OPÇAO FOI SELECIONADA
                             ;E QUAL É O MENU QUE ESTA SENDO MOSTRADO   
    RETURN

SELECIONA_MENU
    MOVFW   IDMENU
    XORLW   .1
    BTFSC   STATUS,Z
    GOTO    BT1

    MOVFW   IDMENU
    XORLW   .2
    BTFSC   STATUS,Z
    GOTO    BT2

    MOVFW   IDMENU
    XORLW   .3
    BTFSC   STATUS,Z
    GOTO    BT3

    MOVFW   IDMENU
    XORLW   .4
    BTFSC   STATUS,Z
    GOTO    BT4

    MOVFW   IDMENU
    XORLW   .5
    BTFSC   STATUS,Z
    GOTO    BT5
    
    RETURN
    
BT1
    MOVLW   .37
    MOVWF   TNOMI           ; MANDA O VALOR DE TENSÃO DA BATERIA 1(3.7V)
    MOVLW   .70             
    MOVWF   INOMI           ; MANDA O VALOR DE CORRENTE DA BATERIA 1(700mAh)

    RETURN
    
BT2
    MOVLW   .30
    MOVWF   TNOMI           ; MANDA O VALOR DE TENSÃO DA BATERIA 2(3.0V)
    MOVLW   .24             
    MOVWF   INOMI           ; MANDA O VALOR DE CORRENTE DA BATERIA 2(240mAh)
    
    RETURN
    
BT3
    MOVLW   .15
    MOVWF   TNOMI           ; MANDA O VALOR DE TENSÃO DA BATERIA 3(1.5V)
    MOVLW   .110             
    MOVWF   INOMI           ; MANDA O VALOR DE CORRENTE DA BATERIA 3(1100mAh)
    
    RETURN
    
BT4
    MOVLW   .15
    MOVWF   TNOMI           ; MANDA O VALOR DE TENSÃO DA BATERIA 4(1.5V)
    MOVLW   .250             
    MOVWF   INOMI           ; MANDA O VALOR DE CORRENTE DA BATERIA 1(2500mAh)
    
    RETURN
    
BT5
    ;OPÇÃO PERSONALIZADA--------------------------------------------------------
    RETURN

    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;       			AQUISIÇÃO PELO CONVERSOR A/D    			  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;A OPÇÃO DO PINO A SER CONVERTIDO É PASSADO PELO W(1-ANS0 / 2-ANS1)
;VALOR DA CONVERSÃO É RETORNADO EM WORK
FAZ_MEDIDA
    XORLW   .1
    BTFSC   STATUS,Z            ; VERIFICA SE VAMOS LER DA ANS0 OU ANS1
    GOTO    AD1
    
    CLRF    PACK_L
    CLRF    PACK_H
    MOVLW   .128
    MOVWF   TEMPO1

    ;ANS1 OPÇÃO 2
    MOVLW   B'00001001'
    MOVWF   ADCON0              ;CONFIGURA PINO ANS1
    
AD2
    BSF     ADCON0,GO           ; INICIA A CON VERSÃO
    BTFSC   ADCON0,GO
    GOTO    $-1
    
    MOVFW   ADRESH             
    ADDWF   PACK_L              ; ADICIONA O VALOR DO CONVERSOR A NOSSO ACUMULADOR
    BTFSC   STATUS,C
    INCF    PACK_H              
    
    DECFSZ  TEMPO1
    GOTO    AD2                 ; FAZ 32 AQUISIÇÕES NESTE CICLO
    
    MOVLW   .7
    MOVWF   TEMPO1
DIVIDE_128
    BCF     STATUS,C            ; LIMPA O CARRY PARA NÃO AVER ERROS
    RRF     PACK_H              ; DIVIDE PACK_H POR DOIS
    RRF     PACK_L              ; DIVIDE PACK_L POR DOIS
    DECFSZ  TEMPO1
    GOTO    DIVIDE_128
    MOVFW   PACK_H
    RETURN

AD1
    CLRF    PACK_L
    CLRF    PACK_H
    MOVLW   .128
    MOVWF   TEMPO1
    MOVLW   B'00000001'
    MOVWF   ADCON0              ;CONFIGURA PINO ANS0
    GOTO    AD2  

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;                 ROTINA DE OPERAÇÕES MATEMATICAS      			  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *	    
    
;------------------------------DIVISÃO----------------------------;
;DIVISÃO SOMENTE POR MULTIPLO DE 2, DIVIDENDO EM PACKC, DIVISOR EM WORK
;E RETORNA RESULTADO EM MATH (EX: MATH = MATH/WORK)
DIVIDE
    CLRF    AUX
DIVIDE_LOOP
    SUBWF	MATH,F		;QUANTIDADE DE PASSOS SE O ADC FOSSE DE 12V
	BTFSS	STATUS,C	;TESTO SE TERMINEI A DIVISÃO
	GOTO    DIVIDE_FIM
    INCF    AUX,F
    GOTO	DIVIDE_LOOP
DIVIDE_FIM
    MOVFW   AUX
	RETURN
    
;    MOVF X1,W		;MOVE X1 PARA O REGISTRADOR WORK
;MULTP
;	DECF    X2,F		;DECREMENTA 1 E ADICIONA NO X2(X2=X2-1)
;	BTFSC   STATUS,Z    ;VERIFICA SE X2 CHEGOU A 0
;	GOTO    FIM     	;SE FOR 0, VAI PARA O FIM
;	ADDWF   X1,F		;SOMA X1 COM O VALOR DO X2 QUE ESTA EM WORK(X1=X1+W)
;	BTFSC   STATUS,C	;VERIFICA SE A SOMA DEU MAIS DE 8BITS
;	INCF    R2,F		;SE FOR, INCREMENTA R2(R2=R2+1)
;	GOTO    MULTP		;RETORNA PARA A MULTIPLICAÇÃO
	
    
    
    
    
    
    
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;                       CONFIG DO PROGRAMA              		  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
CONFIG_INIT
    
    BANK1                       ; TRABALHAR COM BANK1

    MOVLW   B'00000011'		    ; SETANDO CONFIGURAÇÕES DE I/O PORTA
    MOVWF   TRISA 
    MOVLW   B'11111000'		    ; SETANDO CONFIGURAÇÕES DE I/O PORTB
    MOVWF   TRISB
    MOVLW   B'11111111'		    ; SETANDO CONFIGURAÇÕES DE I/O PORTC
    MOVWF   TRISC 
    MOVLW   B'11111111'		    ; SETANDO CONFIGURAÇÕES DE I/O PORTD
    MOVWF   TRISD 
    MOVLW   B'11111000'		    ; SETANDO CONFIGURAÇÕES DE I/O PORTE
    MOVWF   TRISE   
	
    CLRF    INTCON              ; DESABILITA INTERRUPÇÃO
    CLRF    OPTION_REG          ; PULLUP
    MOVLW   B'00000100'		    ; CONFIGURAÇÃO DO CONV A/D PORTAS 0,1 E 3 DO PORTA
    MOVWF   ADCON1	
 
    BANK0                       ; TRABALHAR COM BANK0
		
    MOVLW   B'00000001'		    ; LIGANDO O CONVERSOR A/D
    MOVWF   ADCON0

    CLRF    PORTA
    CLRF    PORTB
    CLRF    PORTC
    CLRF    PORTD
    CLRF    PORTE
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;                           ROTINA PRINCIPAL        			  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *			    
MAIN
    
    CALL    INICIALIZA_DISPLAY
    MOVLW   .10
    CALL    DELAY_MILE
    CALL    MOSTRA_MENU
    CALL    MOSTRA_SUBMENU
INICIO
    ; VARIFICA O BOTÃO PRECIONADO
    MOVLW   .10                             ; VARRE O BOTÃO 10 VEZES
    MOVWF   AUX
    
VARRE
    CALL    VARRE_BOTAO
    MOVWF   TECLA
    XORLW   .1
    BTFSC   STATUS,Z
    CALL    ANTERIOR_MENU

    MOVFW   TECLA
    XORLW   .2
    BTFSC   STATUS,Z
    CALL    PROXIMO_MENU

    MOVFW   TECLA
    XORLW   .11
    BTFSC   STATUS,Z
    GOTO    CARGA

    CLRF    TECLA                           ; LIMPA TECLA PARA PROXIMA LEITURA
    
    MOVLW   .50
    CALL    DELAY_MILE                      ; ESPERA 50MS
    DECFSZ  AUX                             ; VARRE 10 VEZES O TECLADO
    GOTO    VARRE
    
    CALL    SHIFT_DISPLAY                   ; DA SHIFT NO DISPLAY
    GOTO    INICIO

CARGA
    CALL    SELECIONA_MENU
    MOVLW   .1                              ; ESCOLHE MEDIDA NO ANS0
    CALL    FAZ_MEDIDA                      ; REALIZA A MEDIDA
    GOTO    INICIO
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;			FIM DO PROGRAMA			  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    END 