;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 16F877A                ;*                FEITAS POR KENED OLIVEIRA                        *
;*              MODIFICA��ES PARA USO COM 16F877A                ;*                    JUNHO DE 2018                                *
;*              MODIFICA��ES PARA USO COM 16F877A                ;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 16F877A                
;*                FEITAS POR KENED OLIVEIRA                        *
;*                    JUNHO DE 2018                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*               CONTROLE DE CARGA DE 4 STAGIOS                    *
;*                   CLIENTE MARDSON AMORIM                        *
;*         DESENVOLVIDO POR KENED WANDERSON CRUZ OLIVEIRA          *
;*   VERS�O: 1.0                           DATA:12/06/2018         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRI��O DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 16f877A                                     *
;*                                                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p16f877a.inc>		    ;ARQUIVO PADR�O MICROCHIP PARA 16F877A
    __CONFIG _CP_OFF & _CPD_OFF & _DEBUG_OFF & _LVP_OFF & _WRT_OFF & _PWRTE_ON & _WDT_OFF & _HS_OSC & _BODEN_ON
    
; CP - CODE PROTECTION (HABILITA OU DESABILITA LEITURA DA MEM�RIA DE PROGRAMA).
; DEBUG - DEPURADOR DA PLACA ICD 2 (HABILITA OU DESABILITA DEPURADOR DA PLACA ICD 2).
; PWRTE - POWER UP TIMER (HABILITA OU DESABILITA TEMPORIZADOR QUE AGUARDA 72 ms PARA ESTABILIZAR O PIC).
; WDT - WATCHDOG TIMER ("C�O DE GUARDA" TEMPORIZADOR QUE RESETA O PIC QUANDO SISTEMA TRAVADO).
; BOREN - BROWN OUT DETECT (SE A ALIMENTA��O VDD FOR MENOR QUE 4V DURANTE 100 MICRO-SEG O PIC RESETA).
; LVP - LOW VOLTAGE PROGRAM (SISTEMA DE PROGRAMA��O EM BAIXA TENS�O).
; XT - OSCILADOR DO TIPO CRISTAL.
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;		DEFINI��O DOS BANCOS DE MEM�RIA RAM		  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#DEFINE BANK1 BSF STATUS, RP0	    ;SETA BANK 1 DE MEM�RIA.
#DEFINE BANK0 BCF STATUS, RP0	    ;SETA BANK 0 DE MEM�RIA.
    

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;				VARI�VEIS			  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    
    CBLOCK 0X20			;ENDERE�O LOCALIZADO NA MAM�RIA DE DADOS DO BANK 0. FOI 
                        ;ESCOLHIDO, POIS EST� LOCALIZA��O � ACESSADA DE QUALQUER BANCO, FACILITANDO A OPERA��O.
	TEMPO1              ; VARIAVEL DE TEMPO DO DELAY
	TEMPO0              ; VARIAVEL DE TEMPO DO DELAY
    AUX                 ; VARIAVEL AUXILIAR, 
	AUX_TEMP            ; VARIAVEL DE COMPENSA��O DO OCILADOR
    AUX_CHARG           ; VARIAVEL AUXILIAR DO CONTROLE DE CARGA
	IDMENU              ; IDENTIFICA��O DO MENU
    ADDR_C              ; ENDERE�O DE MEMORIA DO CURSOR
    DISPLAY             ; VARIAVEL QUE ARMAZENA O VALOR A SER ENVIADO AO DISPLAY
    TECLA               ; GUARDA O VALOR DA TECLA PRECIONADA
    FLAG                ; VARIAVEL RESPONSAVEL POR GERENCIAR AS FLAGS
    ;GUARDA OS VALORES NOMINAIS DA BATERIA
    TNOMI
    INOMI               
    ;VARIAVEIS DA FUN��O DE AQUISI��ES
    PACK_L
    PACK_H
    ;VARIAVEIS UTILIZADAS NA DIVIS�O 16BITS/16BITS
    ACCaHI
    ACCaLO              ; ACUMULADOR a DE 16BITS
    ACCbHI
    ACCbLO              ; ACUMULADOR b DE 16BITS
    ACCcHI
    ACCcLO              ; ACUMULADOR c DE 16BITS
    ACCdHI
    ACCdLO              ; ACUMULADOR d DE 16BITS
    temp
    ;VARIAVEIS UTILIZADAS NA MULTIPLICA��O 8BITS*8BITS
    mulplr
    mulcnd
    H_byte
    L_byte
    ;VARIAVEIS UTILIZADAS NA DIVIS�O DE UNIDADE,DEZENA,CENTENA
    N_U
    N_D
    N_C
    ;ACUMULADOR AQUISI��O
    AccT                ; VALOR DE TENS�O DO ADC
    AccI                ; VALOR DE CORRENTE DO ADC
    
    ENDC			    ; FIM DO BLOCO DE MEM�RIA.
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;                           FLAGS                              *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#DEFINE FLAG_MENU_CHARGE FLAG,0    
#DEFINE FLAG_MEDIDA      FLAG,1

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;                           ENTRADAS                              *
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
;                       	SAIDAS                                *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#DEFINE RS      PORTA,2         ; INDICA AO DISPLAY O TIPO DA INFORMA��O
                                ; RS ? 1 DADO : 0 COMANDO
#DEFINE ENABLE  PORTA,4		    ; SINAL ATIVA O DISPLAY NA BORDA DE DESCIDA
#DEFINE DISP_D4 PORTA,5
#DEFINE DISP_D5 PORTE,0
#DEFINE DISP_D6 PORTE,1
#DEFINE DISP_D7 PORTE,2


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;			  VETOR DE RESET			  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    ORG  0X0000                      ; ENDERE�O DO VETOR DE RESET
    GOTO CONFIG_INIT			    ; PULA PARA AONDE EU QUISER

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;			CONFIG_INIT DA INTERUP��O                             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
			    
    ORG 0X0004			    ; ENDERE�O DO VETOR DE INTERRUP��O
    RETFIE                  ; RETORNA DA INTERRUP��O			    
			    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;		ROTINA DE DELAY_MILE    (1 ~ 256)MILESSEGUNDOS)    		  *
;       ROTINA DE DELAY_MICRO   (1 ~ 256)MICROSSEGUNDOS)          *
;       ROTINA DE DELAY_1SEGUNDO(1)      SEGUNDO                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;VALOR PASSADO EM WORK(W) DEFINE O DELAY            			  ;
    
DELAY_MILE
    MOVWF   TEMPO1		    ; CARREGA EM TEMPO_1 ATE AONDE VAI ESPERAR
VOLTA
    MOVLW   .5
    MOVWF   AUX_TEMP        ; TEMPORIZADOR AUXILIAR PARA COMPENSA��O DO OCILADOR
    MOVLW   .250		    
    MOVWF   TEMPO0		    ; CARREGA EM TEMPO_0 1MS
    NOP
    DECFSZ  TEMPO0,F		; SE PASSOU 1MS?
    GOTO    $-2			    ; N�O, VOLTA
    DECFSZ  AUX_TEMP
    GOTO    $-6
    DECFSZ  TEMPO1,F		; SE PASSOU O TEMPO DESEJADO?
    GOTO    VOLTA		    ; N�O, ESPERA POR MAIS 1MS
    RETURN
    
DELAY_MICRO
    MOVWF   TEMPO0		    ; CARREGA EM TEMPO_1 ATE AONDE VAI ESPERAR
    MOVLW   .5
    MOVWF   AUX_TEMP        ; TEMPORIZADOR AUXILIAR PARA COMPENSA��O DO OCILADOR
    DECFSZ  AUX_TEMP
    GOTO    $-1 			; N�O, VOLTA
    DECFSZ  TEMPO0,F		; SE PASSOU O TEMPO?
    GOTO    $-5
    RETURN

DELAY_1SEGUNDO
    MOVLW   .240
    CALL    DELAY_MILE
    MOVLW   .240
    CALL    DELAY_MILE
    MOVLW   .240
    CALL    DELAY_MILE
    MOVLW   .240
    CALL    DELAY_MILE
    RETURN
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;       CONFIGURA��ES INICIAIS DE INICIALIZA��O DO DISPLAY        *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; COMUNICA��O DE 8 VIAS, DISPLAY DE 2 LINHAS,                     *
; CURSOR APAGADO E DESLOCAMENTO A DIREITA                         *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
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
    CALL    DELAY_MILE		; DELAY_MILE DE 1MS
    
    MOVLW   0X28
    CALL    ESCREVE         ; CONF DO DISPLAY, 4 VIAS, DISPLAY 2 LINHAS

    MOVLW   .10
    CALL    DELAY_MILE		; DELAY_MILE DE 1MS
    
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
    
    BSF     RS              ; VOLTA PARA DADOS
    
    RETURN
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;         ROTINA DE ESCRITA DE UM CARACTER NO DISPLAY             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; O CARACTER A SER ESCRITO DEVE ESTAR EM WORK(W)			  

ESCREVE
    
    MOVWF   DISPLAY		    ; ATUALIZA DISPLAY
    ;CARREGA O 8� BIT
    RLF     DISPLAY
    BTFSC   STATUS,C
    BSF     DISP_D7
    BTFSS   STATUS,C
    BCF     DISP_D7
    ;CARREGA O 7� BIT
    RLF     DISPLAY
    BTFSC   STATUS,C
    BSF     DISP_D6
    BTFSS   STATUS,C
    BCF     DISP_D6
    ;CARREGA O 6� BIT
    RLF     DISPLAY
    BTFSC   STATUS,C
    BSF     DISP_D5
    BTFSS   STATUS,C
    BCF     DISP_D5
    ;CARREGA O 5� BIT
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
    MOVLW   .2
    CALL    DELAY_MILE		; ESPERA 2MS

    
    ;CARREGA O 4� BIT
    RLF     DISPLAY
    BTFSC   STATUS,C
    BSF     DISP_D7
    BTFSS   STATUS,C
    BCF     DISP_D7
    ;CARREGA O 3� BIT
    RLF     DISPLAY
    BTFSC   STATUS,C
    BSF     DISP_D6
    BTFSS   STATUS,C
    BCF     DISP_D6
    ;CARREGA O 2� BIT
    RLF     DISPLAY
    BTFSC   STATUS,C
    BSF     DISP_D5
    BTFSS   STATUS,C
    BCF     DISP_D5
    ;CARREGA O 1� BIT
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
    MOVLW   .2
    CALL    DELAY_MILE	    ; ESPERA 2MS

    RETURN    
    
SHIFT_DISPLAY
    BCF     RS
    MOVLW   0X18
    CALL    ESCREVE
    BSF     RS
    RETURN

;0X81 POSI��O 1 DA LINHA 0
SHIFT_CURSOR
    BCF     RS
    MOVFW   ADDR_C             ; PASSA O PONTEIRO PARA SER MOVIDO
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
    ;VERIFICA SE ULTRAPASSOU O TAMANHO DO MENU DE 5 POSI��ES
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
    ;VERIFICA SE ULTRAPASSOU O TAMANHO DO MENU DE 5 POSI��ES
    CALL    MOSTRA_SUBMENU
    RETURN
    
    MOVLW   .5
    MOVWF    IDMENU
    CALL    MOSTRA_SUBMENU
    RETURN
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;	     ROTINA QUE VAI MOSTRA O SUBMENU DE OP��ES		  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MOSTRA_SUBMENU
    
    BTFSC   FLAG_MENU_CHARGE    ; VERIFICA O TIPO DE MENU A SER MOSTRADO
    GOTO    MENU_CHARGE
    
;-----CONFIGURA ESCRITA NA SEGUNDA LINHA------
    MOVLW   0XC1
    MOVWF   ADDR_C               ;INDICA A POSI��O DO CURSO NA LINHA 2
    
    BCF	    RS                   ;SELECIONA O DISPLAY PARA COMANDOS
    MOVLW   .3
    CALL    ESCREVE
    MOVLW   .192                 ;POSICIONA O CURSOR PARA A LINHA 2
    CALL    ESCREVE 
    MOVLW   .1
    CALL    DELAY_MILE
    BSF	    RS                   ;VOLTA PARA O DISPLAY RECEBER DADOS
;-------FIM CONFIGURA��O SEGUNDA LINHA----------
MOSTRA_MENU_CHARGE
    
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
    MOVLW   '.'
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
    MOVLW   '.'
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
    
MENU_CHARGE
;-------ESCRITA NA PRIMEIRA LINHA----------
    MOVLW   0X81
    MOVWF   ADDR_C		    ;POSICIONA O CURSOR NA LINHA 0 COLUNA 16

    BCF	    RS			    ; SELECIONA O DISPLAY PARA COMANDOS
    MOVLW   .1
    CALL    ESCREVE         ; LIMPA DISPLAY
    MOVLW   .3
    CALL    ESCREVE         ; POSICIONA O CURSOR NO INICIO DA LINHA 0
    BSF	    RS			    ; SELECIONA O DISPLAY PARA DADOS
;--------FIM ESCRITA PRIMEIRA LINHA
    GOTO    MOSTRA_MENU_CHARGE

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;	     ROTINA DE MAPEAMENTO DOS BOT�ES DO TECLADO		  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;ACIONA AS COLUNAS DO TECLADO E LER AS COLUNAS, A FIM DE ACHAR SUA POSI��O
;RETORNA A TECLA PRECIONA EM WORK
		;     j1 j2 j3
		;i1 |  1  2  3  |
		;i2 |  4  5  6  |
		;i3 |  7  8  9  |
		;i4 |  *  0  #  |
VARRE_BOTAO
    
    CLRF    PORTB           ; LIMPAS PORTAS PARA COME�AR A LEITURA
    ;LEITURA DA PRIMEIRA COLUNA
    BCF	    CLN_1			; HABILITA A PRIMEIRA COLUNA
    BSF	    CLN_2			; DESABILITA A SEGUNDA COLUNA
    BSF	    CLN_3			; DESABILITA A TERCEIRA COLUNA
    

    MOVLW   .1
    CALL    DELAY_MILE
    
    BTFSC   LNH_1
    GOTO    $+7
    BTFSC   LNH_1
    GOTO    $+4
    MOVLW   .10
	CALL	DELAY_MILE
	GOTO    $-4
    RETLW   .1
    
    BTFSC   LNH_2
    GOTO    $+7
    BTFSC   LNH_2
    GOTO    $+4
    MOVLW   .10
	CALL	DELAY_MILE
    GOTO    $-4
    RETLW   .4

    BTFSC   LNH_3
    GOTO    $+7
    BTFSC   LNH_3
    GOTO    $+4
    MOVLW   .10
	CALL	DELAY_MILE
    GOTO    $-4
    RETLW   .7
    
    BTFSC   LNH_4
    GOTO    $+7
    BTFSC   LNH_4
    GOTO    $+4
    MOVLW   .10
	CALL	DELAY_MILE
    GOTO    $-4
    RETLW   .10				; REPRESENTA O *

    ;LEITURA DA SEGUNDA COLUNA
    BSF	    CLN_1			; DESABILITA A PRIMEIRA COLUNA
    BCF	    CLN_2			; HABILITA A SEGUNDA COLUNA
    BSF	    CLN_3			; DESABILITA A TERCEIRA COLUNA

    MOVLW   .1
    CALL    DELAY_MILE
  
    BTFSC   LNH_1
    GOTO    $+7
    BTFSC   LNH_1
    GOTO    $+4
    MOVLW   .10
	CALL	DELAY_MILE
    GOTO    $-4
    RETLW   .2
    
    BTFSC   LNH_2
    GOTO    $+7
    BTFSC   LNH_2
    GOTO    $+4
    MOVLW   .10
	CALL	DELAY_MILE
    GOTO    $-4
    RETLW   .5
    
    BTFSC   LNH_3
    GOTO    $+7
    BTFSC   LNH_3
    GOTO    $+4
    MOVLW   .10
	CALL	DELAY_MILE
    GOTO    $-4
    RETLW   .8
    
    BTFSC   LNH_4
    GOTO    $+7
    BTFSC   LNH_4
    GOTO    $+4
    MOVLW   .10
	CALL	DELAY_MILE
    GOTO    $-4
    RETLW   .0				
    
    ;LEITURA DA TERCEIRA COLUNA
    BSF	    CLN_1			; DESABILITA A PRIMEIRA COLUNA
    BSF	    CLN_2			; DESABILITA A SEGUNDA COLUNA
    BCF	    CLN_3			; HABILITA A TERCEIRA COLUNA
  
    MOVLW   .1
    CALL    DELAY_MILE

    BTFSC   LNH_1
    GOTO    $+7
    BTFSC   LNH_1
    GOTO    $+4
    MOVLW   .10
	CALL	DELAY_MILE
    GOTO    $-4
    RETLW   .3

    BTFSC   LNH_2
    GOTO    $+7
    BTFSC   LNH_2
    GOTO    $+4
    MOVLW   .10
	CALL	DELAY_MILE
    GOTO    $-4
    RETLW   .6

    BTFSC   LNH_3
    GOTO    $+7
    BTFSC   LNH_3
    GOTO    $+4
    MOVLW   .10
	CALL	DELAY_MILE
    GOTO    $-4
    RETLW   .9
    
    BTFSC   LNH_4
    GOTO    $+7
    BTFSC   LNH_4
    GOTO    $+4
    MOVLW   .10
	CALL	DELAY_MILE
    GOTO    $-4
    RETLW   .11				; REPRESENTA O #

    RETLW   .255            ; SE NENHUMA TECLA FOR PRECIONADA, RETORNA INEXISTENCIA 


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
    MOVWF   IDMENU		     ;FLAG QUE DIRA QUAL OP�AO FOI SELECIONADA
                             ;E QUAL � O MENU QUE ESTA SENDO MOSTRADO   
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
    
;---------------------------VALORES SOMENTE COM O GANHO DE 65-------------------
BT1
    MOVLW   .189
    MOVWF   TNOMI           ; MANDA O VALOR DE TENS�O DA BATERIA 1(3.7V)
    MOVLW   .116             
    MOVWF   INOMI           ; MANDA O VALOR DE CORRENTE DA BATERIA 1(700mAh)

    RETURN
    
BT2
    MOVLW   .153
    MOVWF   TNOMI           ; MANDA O VALOR DE TENS�O DA BATERIA 2(3.0V)
    MOVLW   .40             
    MOVWF   INOMI           ; MANDA O VALOR DE CORRENTE DA BATERIA 2(240mAh)
    
    RETURN
;---------------------------VALORES SOMENTE COM O GANHO DE 20-------------------
BT3
    MOVLW   .77
    MOVWF   TNOMI           ; MANDA O VALOR DE TENS�O DA BATERIA 3(1.5V)
    MOVLW   .56             
    MOVWF   INOMI           ; MANDA O VALOR DE CORRENTE DA BATERIA 3(1100mAh)
    
    RETURN
    
BT4
    MOVLW   .77
    MOVWF   TNOMI           ; MANDA O VALOR DE TENS�O DA BATERIA 4(1.5V)
    MOVLW   .128             
    MOVWF   INOMI           ; MANDA O VALOR DE CORRENTE DA BATERIA 1(2500mAh)
    
    RETURN
    
;-----------------LEITURA DA PRIMEIRA TECLA------------------------------------
BT5
;INICIALIZA��O DAS VARIAVEIS DE SETPOINT
    MOVLW   .1
    MOVWF   TNOMI
    MOVLW   .1
    MOVWF   INOMI
    
;-----CONFIGURA ESCRITA NA SEGUNDA LINHA------
    MOVLW   0XC1
    MOVWF   ADDR_C               ;INDICA A POSI��O DO CURSO NA LINHA 2
    
    BCF	    RS                   ;SELECIONA O DISPLAY PARA COMANDOS
    MOVLW   .3
    CALL    ESCREVE
    MOVLW   .192                 ;POSICIONA O CURSOR PARA A LINHA 2
    CALL    ESCREVE 
    MOVLW   .1
    CALL    DELAY_MILE
    BSF	    RS                   ;VOLTA PARA O DISPLAY RECEBER DADOS
;-------FIM CONFIGURA��O SEGUNDA LINHA----------
;ESCRITA DO VALOR DE TENS�O
    CALL    BACKSPACE
    MOVLW   0XC3
    MOVWF   ADDR_C            ;INDICA A POSI��O DO CURSO NA LINHA 2
    CALL    SHIFT_CURSOR
    
BT5_1
    CALL    VARRE_BOTAO      ; FAZ A LEITURA DO TECLADO
         
    MOVWF   TECLA            ; JOGA TECLA LIDA EM TECLA
    SUBLW   .255             ; VERIFICA SE REALMENTE FOI LIDO ALGO
    BTFSC   STATUS,Z
    GOTO    BT5_1            ; SE N�O, FAZ OUTRA LEITURA

    ;APAGA A ENTRADA, CASO DESEJADO
    MOVFW   TECLA
    XORLW   .10
    BTFSC   STATUS,Z
    GOTO    BT5               ; VOLTA A OP��O DE MENU

    MOVFW   TECLA
    XORLW   .11
    BTFSC   STATUS,Z
    GOTO    BT5_1             ; REDUNDANCIA DO BOT�O #

;ESCREVE VALOR PRECIONADO NA TELA    
    MOVFW   TECLA            
    ADDLW   0X30
    CALL    ESCREVE          ; ESCREVE A TECLA LIDA NO DISPLAY
    CALL    SHIFT_CURSOR
;ADICIONA O PONTO
    MOVLW   '.'            
    CALL    ESCREVE          ; ESCREVE A TECLA LIDA NO DISPLAY
    CALL    SHIFT_CURSOR
    
;   CONVERTENDO O VALOR DIGITANDO, MULTIPLICA POR 51
    MOVLW   .51
    MOVWF   mulplr           
    MOVFW   TECLA
    MOVWF   mulcnd
    CALL    mpy_F
    
    MOVFW   L_byte
    ADDWF   TNOMI            ; ADICIONA O PRIMEIRO VALOR AO ACUMULADOR DE TENS�O

    MOVLW   .255
    MOVWF    TECLA            ; LIMPA TECLA PARA PROXIMA LEITURA
    
;    MOVLW   .100
;    CALL    DELAY_MILE       ; ESPERA 50MS PARA O DEBOUNCE
BT5_2
;-----------------LEITURA DA SEGUNDA TECLA------------------------------------
    CALL    VARRE_BOTAO      ; FAZ A LEITURA DO TECLADO
        
    MOVWF   TECLA            ; JOGA TECLA LIDA EM TECLA
    SUBLW   .255             ; VERIFICA SE REALMENTE FOI LIDO ALGO
    BTFSC   STATUS,Z
    GOTO    BT5_2            ; SE N�O, FAZ OUTRA LEITURA

    ;APAGA A ENTRADA, CASO DESEJADO
    MOVFW   TECLA
    XORLW   .10
    BTFSC   STATUS,Z
    GOTO    BT5               ; VOLTA A OP��O DE MENU

    MOVFW   TECLA
    XORLW   .11
    BTFSC   STATUS,Z
    GOTO    BT5_2             ; REDUNDANCIA DO BOT�O #

;ESCREVE VALOR PRECIONADO NA TELA    
    MOVFW   TECLA            
    ADDLW   0X30
    CALL    ESCREVE          ; ESCREVE A TECLA LIDA NO DISPLAY
    CALL    SHIFT_CURSOR
    
;   CONVERTENDO O VALOR DIGITANDO, MULTIPLICA POR 51 E DIVIDE POR 10
    MOVLW   .51
    MOVWF   mulplr           
    MOVFW   TECLA
    MOVWF   mulcnd
    CALL    mpy_F
    
    MOVFW   H_byte
    MOVWF   ACCbHI
    MOVFW   L_byte
    MOVWF   ACCbLO
    MOVLW   .10
    MOVWF   ACCaLO
    CLRF    ACCaHI
    CALL    D_divF
    
    MOVFW   ACCbLO
    ADDWF   TNOMI            ; ADICIONA O PRIMEIRO VALOR AO ACUMULADOR DE TENS�O
    
    MOVLW   .255
    MOVWF    TECLA            ; LIMPA TECLA PARA PROXIMA LEITURA
    
;    MOVLW   .100
;    CALL    DELAY_MILE       ; ESPERA 50MS PARA O DEBOUNCE
BT5_3
;-----------------LEITURA DA TERCEIRA TECLA------------------------------------
    CALL    VARRE_BOTAO      ; FAZ A LEITURA DO TECLADO
        
    MOVWF   TECLA            ; JOGA TECLA LIDA EM TECLA
    SUBLW   .255             ; VERIFICA SE REALMENTE FOI LIDO ALGO
    BTFSC   STATUS,Z
    GOTO    BT5_3            ; SE N�O, FAZ OUTRA LEITURA

;APAGA A ENTRADA, CASO DESEJADO
    MOVFW   TECLA
    XORLW   .10
    BTFSC   STATUS,Z
    GOTO    BT5               ; VOLTA A OP��O DE MENU

    MOVFW   TECLA
    XORLW   .11
    BTFSC   STATUS,Z
    GOTO    BT5_3             ; REDUNDANCIA DO BOT�O #

;ESCREVE VALOR PRECIONADO NA TELA    
    MOVFW   TECLA            
    ADDLW   0X30
    CALL    ESCREVE          ; ESCREVE A TECLA LIDA NO DISPLAY
    CALL    SHIFT_CURSOR
    
;   CONVERTENDO O VALOR DIGITANDO, MULTIPLICA POR 51 E DIVIDE POR 100
    MOVLW   .51
    MOVWF   mulplr           
    MOVFW   TECLA
    MOVWF   mulcnd
    CALL    mpy_F
    
    MOVFW   H_byte
    MOVWF   ACCbHI
    MOVFW   L_byte
    MOVWF   ACCbLO
    MOVLW   .100
    MOVWF   ACCaLO
    CLRF    ACCaHI
    CALL    D_divF
    
    MOVFW   ACCbLO
    ADDWF   TNOMI            ; ADICIONA O PRIMEIRO VALOR AO ACUMULADOR DE TENS�O
    
    MOVLW   .255
    MOVWF    TECLA            ; LIMPA TECLA PARA PROXIMA LEITURA
    

;ESCRITA DO VALOR DE CORRENTE
    MOVLW   0X03
    ADDWF   ADDR_C            ;INDICA A POSI��O DO CURSO NA LINHA 2 PARA CORRENTE
    CALL    SHIFT_CURSOR
;-----------------LEITURA DA PRIMEIRA TECLA------------------------------------
BT5_4
    CALL    VARRE_BOTAO      ; FAZ A LEITURA DO TECLADO
        
    MOVWF   TECLA            ; JOGA TECLA LIDA EM TECLA
    SUBLW   .255             ; VERIFICA SE REALMENTE FOI LIDO ALGO
    BTFSC   STATUS,Z
    GOTO    BT5_4            ; SE N�O, FAZ OUTRA LEITURA

;APAGA A ENTRADA, CASO DESEJADO
    MOVFW   TECLA
    XORLW   .10
    BTFSC   STATUS,Z
    GOTO    BT5               ; VOLTA A OP��O DE MENU
    
    MOVFW   TECLA
    XORLW   .11
    BTFSC   STATUS,Z
    GOTO    BT5_4             ; REDUNDANCIA DO BOT�O #

;ESCREVE VALOR PRECIONADO NA TELA    
    MOVFW   TECLA            
    ADDLW   0X30
    CALL    ESCREVE          ; ESCREVE A TECLA LIDA NO DISPLAY
    CALL    SHIFT_CURSOR
    
;CONVERTENDO O VALOR DIGITANDO, MULTIPLICA POR 83 E DIVIDE POR 5
    MOVLW   .83
    MOVWF   mulplr           
    MOVFW   TECLA
    MOVWF   mulcnd
    CALL    mpy_F
    
    MOVFW   H_byte
    MOVWF   ACCbHI
    MOVFW   L_byte
    MOVWF   ACCbLO
    MOVLW   .5
    MOVWF   ACCaLO
    CLRF    ACCaHI
    CALL    D_divF
    
    MOVFW   ACCbLO
    ADDWF   INOMI            ; ADICIONA O PRIMEIRO VALOR AO ACUMULADOR DE CORRENTE
    
    MOVLW   .255
    MOVWF    TECLA            ; LIMPA TECLA PARA PROXIMA LEITURA
    

BT5_5
;-----------------LEITURA DA SEGUNDA TECLA------------------------------------
    CALL    VARRE_BOTAO      ; FAZ A LEITURA DO TECLADO
        
    MOVWF   TECLA            ; JOGA TECLA LIDA EM TECLA
    SUBLW   .255             ; VERIFICA SE REALMENTE FOI LIDO ALGO
    BTFSC   STATUS,Z
    GOTO    BT5_5            ; SE N�O, FAZ OUTRA LEITURA

;APAGA A ENTRADA, CASO DESEJADO
    MOVFW   TECLA
    XORLW   .10
    BTFSC   STATUS,Z
    GOTO    BT5               ; VOLTA A OP��O DE MENU
    
    MOVFW   TECLA
    XORLW   .11
    BTFSC   STATUS,Z
    GOTO    BT5_5             ; REDUNDANCIA DO BOT�O #

;ESCREVE VALOR PRECIONADO NA TELA    
    MOVFW   TECLA            
    ADDLW   0X30
    CALL    ESCREVE          ; ESCREVE A TECLA LIDA NO DISPLAY
    CALL    SHIFT_CURSOR
    
;   CONVERTENDO O VALOR DIGITANDO, MULTIPLICA POR 83 E DIVIDE POR 50
    MOVLW   .83
    MOVWF   mulplr           
    MOVFW   TECLA
    MOVWF   mulcnd
    CALL    mpy_F
    
    MOVFW   H_byte
    MOVWF   ACCbHI
    MOVFW   L_byte
    MOVWF   ACCbLO
    MOVLW   .50
    MOVWF   ACCaLO
    CLRF    ACCaHI
    CALL    D_divF
    
    MOVFW   ACCbLO
    ADDWF   INOMI            ; ADICIONA O PRIMEIRO VALOR AO ACUMULADOR DE CORRENTE
    
    MOVLW   .255
    MOVWF    TECLA            ; LIMPA TECLA PARA PROXIMA LEITURA
    
;    MOVLW   .50
;    CALL    DELAY_MILE       ; ESPERA 50MS PARA O DEBOUNCE
BT5_6
;-----------------LEITURA DA TERCEIRA TECLA------------------------------------
    CALL    VARRE_BOTAO      ; FAZ A LEITURA DO TECLADO
        
    MOVWF   TECLA            ; JOGA TECLA LIDA EM TECLA
    SUBLW   .255             ; VERIFICA SE REALMENTE FOI LIDO ALGO
    BTFSC   STATUS,Z
    GOTO    BT5_6            ; SE N�O, FAZ OUTRA LEITURA

;APAGA A ENTRADA, CASO DESEJADO
    MOVFW   TECLA
    XORLW   .10
    BTFSC   STATUS,Z
    GOTO    BT5               ; VOLTA A OP��O DE MENU

    MOVFW   TECLA
    XORLW   .11
    BTFSC   STATUS,Z
    GOTO    BT5_6             ; REDUNDANCIA DO BOT�O #
;ESCREVE VALOR PRECIONADO NA TELA    
    MOVFW   TECLA            
    ADDLW   0X30
    CALL    ESCREVE          ; ESCREVE A TECLA LIDA NO DISPLAY
    CALL    SHIFT_CURSOR
    
;VERIFICA SE O USUARIO CONFIRMA O VALOR OU DIGITA NOVAMENTE
CONFIRMA
    CALL    VARRE_BOTAO      ; FAZ A LEITURA DO TECLADO
    MOVWF   TECLA
    
    MOVFW   TECLA
    XORLW   .10
    BTFSC   STATUS,Z
    GOTO    BT5               ; VOLTA A OP��O DE MENU

    MOVFW   TECLA
    XORLW   .11
    BTFSC   STATUS,Z        
    RETURN                   ; PASSA A OP��O DE MENU
    GOTO    CONFIRMA        

;DESENHA A FORMA DA TENS�O E CORRENTE DA TELA E LIMPA O LIXO
BACKSPACE
    MOVLW   'T'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    
    MOVLW   'b'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    
    MOVLW   ':'
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

    MOVLW   ' '
    CALL    ESCREVE
    CALL    SHIFT_CURSOR

    MOVLW   ' '
    CALL    ESCREVE
    CALL    SHIFT_CURSOR

    MOVLW   'I'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    
    MOVLW   'c'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    
    MOVLW   ':'
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
    
    RETURN
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;       			AQUISI��O PELO CONVERSOR A/D    			  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;A OP��O DO PINO A SER CONVERTIDO � PASSADO PELO FLAG_MEDIDA(0-ANS0-TENS�O / 1-ANS1-CORRENTE)
;VALOR DA CONVERS�O � RETORNADO EM WORK
FAZ_MEDIDA

    BTFSC   FLAG_MEDIDA            ; VERIFICA SE VAMOS LER DA ANS0 OU ANS1
    GOTO    AD1
    
    CLRF    PACK_L
    CLRF    PACK_H
    MOVLW   .128
    MOVWF   TEMPO1

    ;ANS1 OP��O 2
    MOVLW   B'00001001'
    MOVWF   ADCON0              ;CONFIGURA PINO ANS1
    
AD2
    BSF     ADCON0,GO           ; INICIA A CON VERS�O
    BTFSC   ADCON0,GO
    GOTO    $-1
    
    MOVFW   ADRESH             
    ADDWF   PACK_L              ; ADICIONA O VALOR DO CONVERSOR A NOSSO ACUMULADOR
    BTFSC   STATUS,C
    INCF    PACK_H              
    
    DECFSZ  TEMPO1
    GOTO    AD2                 ; FAZ 128 AQUISI��ES NESTE CICLO
    
    MOVLW   .7
    MOVWF   TEMPO1
DIVIDE_128
    BCF     STATUS,C            ; LIMPA O CARRY PARA N�O AVER ERROS
    RRF     PACK_H              ; DIVIDE PACK_H POR DOIS
    RRF     PACK_L              ; DIVIDE PACK_L POR DOIS
    DECFSZ  TEMPO1
    GOTO    DIVIDE_128
    MOVFW   PACK_L
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
;       			ESCRITA NO LCD DO VALOR LIDO    			  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;A OP��O DA MEDIDA A SER ESCRITA PASSADO PELO FLAG_MEDIDA(0-TENS�O / 1-CORRENTE)
;VALOR A SER ESCRITO � PASSADO PELO WORK
ESCREVE_MEDIDA    
    MOVWF   mulplr                 ; VALOR QUE VAI SER ESCRITO NO MULTIPLICADO
    BTFSS   FLAG_MEDIDA            ; VERIFICA O TIPO DA MEDIDA
    GOTO    ESCREVE_TENSAO
    
;ESCRITA CORRENTE
    MOVFW   mulplr
    MOVWF   AccI                 ;GUARDA O VALOR DA CORRENTE
;-----CONFIGURA ESCRITA NA SEGUNDA LINHA------

    MOVLW   0XC9
    MOVWF   ADDR_C               ;INDICA A POSI��O DO CURSO NA LINHA 2
    
    BCF	    RS                   ;SELECIONA O DISPLAY PARA COMANDOS
    MOVLW   .1
    CALL    DELAY_MILE
    BSF	    RS                   ;VOLTA PARA O DISPLAY RECEBER DADOS
    CALL    SHIFT_CURSOR         ;POSICIONA A ESCRITA DE CORRENTE

;-------ESCREVE SEGUNDA LINHA----------
    MOVLW   'I'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'c'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   ':'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR

;---------CONVERS�O DA MEDIDA DE CORRENTE----------
;   (MEDIDA*40*2/663)                             ;
;   CENTENA - > PRIMEIRO CARACTER                 ;
;   DEZENA  - > SEGUNDO CARACTER                  ;
;   UNIDADE - > TERCEIRO CARACTER                 ;
;--------------------------------------------------
    MOVLW   .200
    MOVWF   mulcnd
    CALL    mpy_F                 ; MULTIPLICA NOSSA MEDIDA POR 200
    
    MOVFW   H_byte
    MOVWF   ACCbHI
    MOVFW   L_byte
    MOVWF   ACCbLO                ; CARREGA O NUMERADOR DA DIVIS�O COM O 
                                  ; RESULTADO DA MULTIPLICA��O
    
    MOVLW   .2
    MOVWF   ACCaHI 
    MOVLW   .151
    MOVWF   ACCaLO                ; CARREGA O DENOMINADOR COM 663
    
    CALL    D_divF                ; REALIZA A DIVIS�O
    RLF     ACCbLO                ; MULTIPLICA POR 2

    CALL    splitCDU              ; DIVIDE ACCb EM UNIDADE,DEZENA E CENTENA
        
    MOVFW   N_C                                 
    ADDLW   0X30
    CALL    ESCREVE               ; ESCREVE O PRIMEIRO VALOR
    CALL    SHIFT_CURSOR
    
    MOVFW   N_D
    ADDLW   0X30
    CALL    ESCREVE               ; ESCREVE O SEGUNDO VALOR
    CALL    SHIFT_CURSOR
    
    MOVFW   N_U
    ADDLW   0X30
    CALL    ESCREVE               ; ESCREVE O TERCEIRO VALOR
    CALL    SHIFT_CURSOR
    
;-----FIM CONVERS�O DA MEDIDA DE CORRENTE----------
    
    MOVLW   'm'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'A'
    CALL    ESCREVE
    CALL    SHIFT_DISPLAY
    
    RETURN
    
ESCREVE_TENSAO
;CONVERS�O DA MEDIDA DE TENS�O
    MOVFW   mulplr
    MOVWF   AccT                 ;GUARDA O VALOR DA TENS�O

;-----CONFIGURA ESCRITA NA SEGUNDA LINHA------
    MOVLW   0XC1
    MOVWF   ADDR_C               ;INDICA A POSI��O DO CURSO NA LINHA 2
    
    BCF	    RS                   ;SELECIONA O DISPLAY PARA COMANDOS
    MOVLW   .3
    CALL    ESCREVE
    MOVLW   .192                 ;POSICIONA O CURSOR PARA A LINHA 2
    CALL    ESCREVE 
    MOVLW   .1
    CALL    DELAY_MILE
    BSF	    RS                   ;VOLTA PARA O DISPLAY RECEBER DADOS
;-------ESCREVE SEGUNDA LINHA----------
    MOVLW   'V'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   'c'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    MOVLW   ':'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
;---------CONVERS�O DA MEDIDA DE TENS�O------------
;   (MEDIDA*10/51)                                ;
;   DEZENA      - > PRIMEIRO CARACTER             ;
;   SIMBOLO "." - > SEGUNDO CARACTER              ;
;   UNIDADE     - > TERCEIRO CARACTER             ;
;--------------------------------------------------
    MOVLW   .100
    MOVWF   mulcnd
    CALL    mpy_F                ;MULTIPLICA POR 100

    MOVFW   H_byte
    MOVWF   ACCbHI
    MOVFW   L_byte
    MOVWF   ACCbLO               ; CARREGA O NUMERADOR DA DIVIS�O COM O 
                                 ; RESULTADO DA MULTIPLICA��O
    CLRF    ACCaHI
    MOVLW   .51
    MOVWF   ACCaLO
    CALL    D_divF               ; DIVIDE POR 51
    
    CALL    splitCDU             ; DIVIDE ACCb EM UNIDADE,DEZENA E CENTENA
    
    MOVFW   N_C
    ADDLW   0X30
    CALL    ESCREVE
    CALL    SHIFT_CURSOR

    MOVLW   '.'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    
    MOVFW   N_D
    ADDLW   0X30
    CALL    ESCREVE
    CALL    SHIFT_CURSOR

    MOVFW   N_D
    ADDLW   0X30
    CALL    ESCREVE
    CALL    SHIFT_CURSOR

;-----FIM CONVERS�O DA MEDIDA DE CORRENTE----------
    MOVLW   'V'
    CALL    ESCREVE
    CALL    SHIFT_CURSOR
    RETURN
    
splitCDU
    INCF    ACCbHI,F
    CLRF    N_C
    CLRF    N_D
    CLRF    N_U                     ;LIMPA REGISTADORES
    
    MOVF    ACCbLO,F
    BTFSC   STATUS,Z                ;VERIFICA SE A ENTRADA � 0
    
    RETURN
    
    INCF    N_U,F                   ;INCREMENTA UNIDADE
    MOVFW   N_U
    XORLW   0X0A
    BTFSS   STATUS,Z                ;VERIFICA SE UNIDADE � 10
    GOTO    $+3
    
    CLRF    N_U
    INCF    N_D,F                     ;INCREMENTA DEZENA
    MOVFW   N_D
    XORLW   0X0A
    BTFSS   STATUS,Z                ;VERIFICA SE DEZENA � 10
    GOTO    $+3
    
    CLRF    N_D
    INCF    N_C,F
    DECFSZ  ACCbLO,F                   ;ACABOU?
    GOTO    $-0X0E         
    DECFSZ  ACCbHI,F
    GOTO    $-2
    RETURN
    
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;                 ROTINA DE OPERA��ES MATEMATICAS      			  *
; ESTAS ROTINAS PODEM SER ENCONTRADAS NO DOCUMENTO                *
;http://ww1.microchip.com/downloads/en/AppNotes/00544d.pdf        *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *	    
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;                     ROTINA DE DIVIS�O                       	  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;                 DIVIS�O DE DUPLA PRECIS�O                       *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;       DIVIS�O : ACCb(16 BITS) / ACCa(16 BITIS) -> ACCb(16 BITS) *
;                                   COM RESTO EM ACCc(16BITS)     *
;   (A) CARREGUE O DENOMINADOR EM ACCaHI & ACCaLO (16BITS)        *
;   (B) CARREGUE O NUMERADOR EM ACCbHI & ACCbLO(16BITS)           *
;   (C) CHAME A SUBROTINA D_divF                                  *
;   (D) O RESULTADO DE 16 BITS FICARA EM ACCbHI & ACCbLO(16BITS)  *
;   (E) O RESTO DA DIVIS�O 16 BITS FICARA EM ACCcHI & ACCClo      *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    
D_divF
    MOVLW   .16                             ; CARREGA CONTADOR DA DIVIS�O
    MOVWF   temp
    
    MOVFW   ACCbHI
    MOVWF   ACCdHI
    MOVFW   ACCbLO
    MOVWF   ACCdLO                           ; SALVA ACCb EM ACCd
    CLRF    ACCbHI
    CLRF    ACCbLO                           ; LIMPA ACCb
    CLRF    ACCcHI
    CLRF    ACCcLO                           ; LIMPA ACCc
    
DIV_
    BCF     STATUS,C
    RLF     ACCdLO,F
    RLF     ACCdHI,F
    RLF     ACCcLO,F
    RLF     ACCcHI,F
    MOVFW   ACCaHI
    SUBWF   ACCcHI,W                          ; VERIFICA SE a>c
    BTFSS   STATUS,Z
    GOTO    NOCHK
    MOVFW   ACCaLO
    SUBWF   ACCcLO,W                          
NOCHK
    BTFSS   STATUS,C                          ; VERIFICA SE c>a
    GOTO    NOGO
    MOVFW   ACCaLO                            ;c = c - a
    SUBWF   ACCcLO,F
    BTFSS   STATUS,C
    DECF    ACCcHI,F
    MOVFW   ACCaHI
    SUBWF   ACCcHI,F
    BSF     STATUS,C
NOGO
    RLF     ACCbLO,F                           
    RLF     ACCbHI,F
    DECFSZ  temp,F                              ; VERIFICA SE CHEGOU AO FIM
    GOTO    DIV_
    
    RETURN
    
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;                      ROTINA DE MULTIPLICA��O                 	  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;                     8x8 SOFTWARE MULTIPLIER                     *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;       OS 16 BITS DE RESULTADO, S�O ARMAZENADOS EM 2 BYTES       *
;ANTES DE CHAMAR A SUB-ROTINA "mpy", DEVEMOS CARREGAR LOCALMENTE  *
;"mulplr", E O MULTIPLICADOR EM "mulcnd" . O RESULTADO EM 16 BITS,*
;SERA ARMAZENADO EM H_byte E l_byte.                              *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DA MACRO DE ADI��O E SHIFT                            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
mult    MACRO   bit                             ;INICIO DA MACRO
    
    BTFSC   mulplr,bit                          ;MAPEIA O MULTIPLICADOR
    ADDWF   H_byte,F
    RRF     H_byte,F
    RRF     L_byte,F
    
    ENDM                                        ;FIM DA MACRO
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; INICIO DA SUBROTINA DE MULTIPLICA��O                            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
mpy_F
    CLRF    H_byte
    CLRF    L_byte
    MOVFW   mulcnd                                ; MOVE O MULTIPLICA PARA W
    BCF     STATUS,C                              ; LIMPA O CARRY
    
    mult    0
    mult    1
    mult    2
    mult    3
    mult    4
    mult    5
    mult    6
    mult    7
    
    RETURN

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;                   ROTINAS DO CONTROLE PWM                		  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *	     
;                 ROTINA DO CONTROLADOR TIPO P                    *
; ANTES DE CHAMARMOS O CON_P, DEVEMOS CARREGAR O WORK COM O VALOR *
; DA MEDIDA REALIZADA E DIZER PELA FLAG_MEDIDA SE � TENS�O OU     *
;  CORRENTE                                                       *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *	     
CON_P
    MOVWF   AUX                 ; QUARDA O VALOR QUE FOI PASSADO AO CONTROLADOR
    BSF     PORTC,RC1           ; LED QUE INDICA QUE ESTAMOS EM CARGA

    BTFSS   FLAG_MEDIDA         ; VERIFICA O TIPO DA MEDIDA
    GOTO    CON_TENSAO
    
    MOVFW   AUX
    SUBWF   INOMI,W                ; PEGA O VALOR DO SETPOINT   
    
    BTFSC   STATUS,C              ; VERIFICA SE PASSAMOS DO SETPOINT
    GOTO    CON_PROX

    MOVWF   AUX
    COMF    AUX                 

    BCF     STATUS,C
    RLF     AUX

    MOVFW   AUX    
    SUBWF   CCPR1L,F              ; REGULA O PWM   

    BTFSC   STATUS,C             ; VERIFICA SE ESTAMOS MUITO ACIMA DO SETPOINT
    CLRF    CCPR1L               ; DESLIGA O PWM NO PROXIMO ESTOURO DO TIMER
    
    RETURN
    
CON_PROX  
    MOVWF   AUX
    BCF     STATUS,C
    RRF     AUX

    BCF     STATUS,C
    RRF     AUX

    BCF     STATUS,C
    RRF     AUX

    MOVFW   AUX
    ADDWF   CCPR1L,F              ; REGULA O PWM

    RETURN
    
CON_TENSAO

    MOVFW   TNOMI
    SUBWF   AUX,W                ; PEGA O VALOR DO SETPOINT   
    
    BTFSC   STATUS,C              ; VERIFICA SE PASSAMOS DO SETPOINT
    GOTO    CON_PROX

    MOVWF   AUX
    COMF    AUX                 
    BCF     STATUS,C
    RLF     AUX

    MOVFW   AUX    
    SUBWF   CCPR1L,F              ; REGULA O PWM   

    BTFSC   STATUS,C             ; VERIFICA SE ESTAMOS MUITO ACIMA DO SETPOINT
    CLRF    CCPR1L               ; DESLIGA O PWM NO PROXIMO ESTOURO DO TIMER
    
    RETURN
    
CON_PROX2  
    MOVWF   AUX
    BCF     STATUS,C
    RRF     AUX

    BCF     STATUS,C
    RRF     AUX

    BCF     STATUS,C
    RRF     AUX

    MOVFW   AUX
    ADDWF   CCPR1L,F              ; REGULA O PWM

    RETURN
    
    
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;                       CONFIG DO PROGRAMA              		  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
CONFIG_INIT
    
    BANK1                       ; TRABALHAR COM BANK1

    MOVLW   B'00000011'		    ; SETANDO CONFIGURA��ES DE I/O PORTA
    MOVWF   TRISA 
    MOVLW   B'11111000'		    ; SETANDO CONFIGURA��ES DE I/O PORTB
    MOVWF   TRISB
    MOVLW   B'11111001'		    ; SETANDO CONFIGURA��ES DE I/O PORTC
    MOVWF   TRISC 
    MOVLW   B'11111111'		    ; SETANDO CONFIGURA��ES DE I/O PORTD
    MOVWF   TRISD 
    MOVLW   B'11111000'		    ; SETANDO CONFIGURA��ES DE I/O PORTE
    MOVWF   TRISE   
	CLRF    PIE1                ; DESLIGA
    
    CLRF    INTCON              ; DESABILITA INTERRUP��O
    CLRF    OPTION_REG          ; PULLUP
    MOVLW   B'00000100'		    ; CONFIGURA��O DO CONV A/D PORTAS 0,1 E 3 DO PORTA
    MOVWF   ADCON1	
 
    BANK0                       ; TRABALHAR COM BANK0
	MOVLW   B'00000111'         ;LIGANDO O TIMER DOIS COM O MAXIMO DE PRESCALE
    MOVWF   T2CON               
    MOVLW   B'00000001'		    ; LIGANDO O CONVERSOR A/D
    MOVWF   ADCON0
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **
;                         CONFIGURA��O DO PWM                      *            
;PERIODO    = (PR2 + 1) * (4 * TOSC) * TMR2Prescale = 819,2us      *
;FREQUENCIA = 1/PERIODO = 1,22KHz                                  *
;DUTY CYCLE = (CCPR1L) * TOSC * TMR2Prescale                       *
;RESOLU��O  = LOG(FOSC/FPWM)/LOG(2) = 15 BITS, USADO SOMENTE 8 BITS*
;PORTC  RC2 COMO SAIDA DO PWM                                      *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **

    MOVLW   B'11111111'
    MOVWF   PR2
    MOVLW   B'00001100'
    MOVWF   CCP1CON             ; LIGANDO O PWM,
    
;INICIALIZA��O LIMPA
    CLRF    TMR1L               
    CLRF    CCPR1L              ; INICIANDO PWM EM 0%
    CLRF    TMR2                ; LIMPA TIMER2
    CLRF    PORTA
    CLRF    PORTB
    CLRF    PORTC
    CLRF    PORTD
    CLRF    PORTE
    CLRF    FLAG
;INICIALIZA��O LIMPA DO DISPLAY
    CALL    INICIALIZA_DISPLAY
    MOVLW   .10
    CALL    DELAY_MILE
;INICIALIZA��O LIMPA DO PWM    
PWM_RESET_SISTEMA
    CLRF    TMR1L               
    CLRF    CCPR1L              ; INICIANDO PWM EM 0%
    CLRF    TMR2                ; LIMPA TIMER2

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;                           ROTINA PRINCIPAL        			  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *			    
MAIN
    BCF     PORTC,RC1                       ; LED QUE INDICA QUE N�O ESTAMOS EM CARGA
    CALL    MOSTRA_MENU                     ; ESCREVE "ESCOLHA V E I <-1 ->2 *OK"
    CALL    MOSTRA_SUBMENU                  ; MOSTRA A PRIMEIRA OP�AO DE V E I
INICIO
    ; VARIFICA O BOT�O PRECIONADO
    MOVLW   .10                             ; VARRE O BOT�O 10 VEZES
    MOVWF   AUX
    
VARRE
    CALL    VARRE_BOTAO
    MOVWF   TECLA
    XORLW   .1
    BTFSC   STATUS,Z
    CALL    ANTERIOR_MENU                   ; VOLTA A OP��O DE MENU

    MOVFW   TECLA
    XORLW   .2
    BTFSC   STATUS,Z
    CALL    PROXIMO_MENU                    ; PASSA A OP��O DE MENU

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
    
    BSF     FLAG_MENU_CHARGE                 ; SELECIONA O MENU COMO CARGA
    CALL    MOSTRA_SUBMENU
    BCF     FLAG_MENU_CHARGE                 ; DESATIVA A FLAG

LOOP_STAGES
;    REALIZA MEDIDA E ESCRITA, DA TENS�O DA BATERIA
    BCF     FLAG_MEDIDA                      ; ESCOLHE FLAG DE MEDIDA COMO TENS�O
    CALL    FAZ_MEDIDA                       ; REALIZA A MEDIDA DA TENS�O
    CALL    ESCREVE_MEDIDA                   ; ESCREVE NO DISPLAY A TENS�O

;    REALIZA MEDIDA E ESCRITA, DA CORRENTE DA BATERIA
    BSF     FLAG_MEDIDA                      ; ESCOLHE FLAG DE MEDIDA COMO CORRENTE
    CALL    FAZ_MEDIDA                       ; REALIZA A MEDIDA DA CORRENTE
    CALL    ESCREVE_MEDIDA                   ; ESCREVE NO DISPLAY A TENS�O
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;           VERIFICA��O DO ESTAGIO INICIAL DE CARGA   			  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *			    
;TIRA 81% DA TENS�O DO SETPOINT, VERIFICANDO ASSIM SE J� ESTA EM*
;TENS�O DE DESCARGA PROFUNDA                                      *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *			    
    MOVFW   TNOMI
    MOVWF   mulplr
    MOVLW   .9
    MOVWF   mulcnd
    CALL    mpy_F
    MOVFW   H_byte
    MOVWF   ACCbHI
    MOVFW   L_byte
    MOVWF   ACCbLO
    MOVLW   .11
    MOVWF   ACCaLO
    CLRF    ACCaHI
    CALL    D_divF
    
;VERIFICA SE ESTA NA TENS�O DE DESCARGA PROFUNDA
    MOVFW   AccT
    SUBWF   ACCbLO,F                        ;ACCb - AccT
    BTFSC   STATUS,C                        ;(ACCb > AccT
    GOTO    STAGE_ONE                       ;SE SIM, VAI PARA O ESTAGIO 1
    GOTO    STAGE_TWO                       ;SE N�O. VAI PARA O ESTAGIO 2
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;                       ESTAGIO UM                  			  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *			    
;INICIA A CARGA DA BATERIA COM 1% DA CORRENTE NOMINAL DA BATERIA, *
;AO QUAL IRA RECUPERAR A BATERIA QUE SE ENCONTRA EM NIVEL DE      *
;DESCARGA PROFUNDA, PROVENDO UMA CARGA MAIS ADEQUADA E COM O      *
;MINIMO DE PREJUIZO A BATERIA.                                    *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *			    
STAGE_ONE
    MOVFW   INOMI
    MOVWF   ACCbLO
    CLRF    ACCbHI
    MOVLW   .10
    MOVWF   ACCaLO
    CLRF    ACCaHI
    CALL    D_divF                          ;DIVIDE O SET POINT POR 10

    BSF     FLAG_MEDIDA                     ;DIZ QUE ESTAMOS TRABALHANDO COM A CORRENTE
    MOVFW   INOMI
    MOVWF   AUX_CHARG
    MOVFW   ACCbLO                         ;CAPTURA O RESULTADO DA DIVIS�O
    MOVWF   INOMI                           ;GRAVA NOSSO NOVO SETPOINT

    MOVFW   AccI                            ;MANDA MEDIDA PARA O CONTROLADOR
    CALL    CON_P                           ;AJUSTA PWM COM BASE NA FLAG_MEDIDA
    INCF    CCPR1L                          ;COMPENSA��O 
    MOVFW   AUX_CHARG
    MOVWF   INOMI                           ;DEVOLVE O VALOR DO SETPOINT
    
    CALL    DELAY_1SEGUNDO                  ;ESPERA 1 SEGUNDO

;VERIFICA SE O BOT�O DE CANCELAMENTO ( * ) FOI ACIONADO
    CALL    VARRE_BOTAO
    MOVWF   TECLA
    XORLW   .10
    BTFSC   STATUS,Z
    CALL    PWM_RESET_SISTEMA                 ;SE SIM, REINICIA O SISTEMA

    GOTO    LOOP_STAGES                        ;VOLTA PARA O LOOP DE ESTAGIOS DE CARGA
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;                       ESTAGIO DOIS                			  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *			    
;INICIA A CARGA DA BATERIA COM 10% DA CORRENTE NOMINAL DA BATERIA,*
;AO QUAL � INDICADA COMO NIVEL DE CORRENTE ADEQUADO PARA CARGA.   *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *			    
STAGE_TWO
    BSF     FLAG_MEDIDA                     ;DIZ QUE ESTAMOS TRABALHANDO COM A CORRENTE
    MOVFW   AccI                            ;MANDA MEDIDA PARA O CONTROLADOR
    CALL    CON_P                           ;AJUSTA PWM COM BASE NA FLAG_MEDIDA

;TIRA 125% DA TENS�O DO SETPOINT, VERIFICANDO ASSIM SE JA ESTA EM 
;TENS�O DE EQUALIZA��O
    MOVFW   TNOMI
    MOVWF   mulplr                          ;O SETPONT COMO NUMERADOR
    MOVLW   .15
    MOVWF   mulcnd                          ;MULTIPLICADO POR 15
    CALL    mpy_F
    MOVFW   H_byte
    MOVWF   ACCbHI
    MOVFW   L_byte
    MOVWF   ACCbLO
    MOVLW   .12                     
    MOVWF   ACCaLO                         ;COM 12 DE DENOMINADOR
    CLRF    ACCaHI
    CALL    D_divF


;VERIFICA SE O BOT�O DE CANCELAMENTO ( * ) FOI ACIONADO
    CALL    VARRE_BOTAO
    MOVWF   TECLA
    XORLW   .10
    BTFSC   STATUS,Z
    CALL    PWM_RESET_SISTEMA                     ;SE SIM, REINICIA O SISTEMA

;VERIFICANDO ASSIM SE JA ESTA EM TENS�O DE EQUALIZA��O
    MOVFW   AccT
    SUBWF   ACCbLO,W                    ;ACCb - AccT    
    BTFSS   STATUS,C                    ;ACCb > AccT ? 0-AccTMENOR : 1AccTMAIOR
    GOTO    $+3
    
    CALL    DELAY_1SEGUNDO              ;ESPERA 1 SEGUNDO
    GOTO    STAGE_THREE                 
    CALL    DELAY_1SEGUNDO              ;ESPERA 1 SEGUNDO
    GOTO    STAGE_TWO                   ;VOLTA PARA O LOOP DE ESTAGIOS DE CARGA
    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;                       ESTAGIO TRES                			  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *			
;ROTINA BLOQUEANTE, EM QUE O BATERIA FICA NESTE LOOP ATE SEU      *
;PROCESSO DE CARGA SER COMPLETO OU A CONTROLADORA REINICIAR.      *
;LIBERA O NIVEL DE CORRENTE E FIXA A TENS�O ATUAL DA BATERIA COMO *
;NOVO SETPOINT, DEIXANDO A CORRENTE DIMINUIR GRADATIVAMENTE ATE   *
;ELA ATINGIR UM NIVEL DE RETEN��O, QUE EQUIVALE A CORRENTE DE     *
;CARGA DIVIDIDO POR CINCO OU A QUINTA PARTE DA CORRENTE DE EQUALIZA��O.
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *			    
STAGE_THREE
    BCF     FLAG_MEDIDA                 ; ESCOLHE FLAG DE MEDIDA COMO TENS�O
    CALL    FAZ_MEDIDA                  ; REALIZA A MEDIDA DA TENS�O
    CALL    ESCREVE_MEDIDA              ; ESCREVE NO DISPLAY A TENS�O
    MOVFW   AccT
    MOVWF   TNOMI                       ;APLICA O VALOR ATUAL COMO NOVO SETPOINT
        
LOOP_STAGE_THREE
    
;REALIZA MEDIDA E ESCRITA, DA TENS�O DA BATERIA
    BCF     FLAG_MEDIDA                 ; ESCOLHE FLAG DE MEDIDA COMO TENS�O
    CALL    FAZ_MEDIDA                  ; REALIZA A MEDIDA DA TENS�O
    CALL    ESCREVE_MEDIDA              ; ESCREVE NO DISPLAY A TENS�O
    MOVFW   AccT                        ;CAPTURA O VALOR DA MEDIDA DE TENS�O
    CALL    CON_P                       ;AJUSTA PWM COM BASE NA FLAG_MEDIDA

;REALIZA MEDIDA E ESCRITA, DA CORRENTE DA BATERIA
    BSF     FLAG_MEDIDA                 ; ESCOLHE FLAG DE MEDIDA COMO CORRENTE
    CALL    FAZ_MEDIDA                  ; REALIZA A MEDIDA DA CORRENTE
    CALL    ESCREVE_MEDIDA              ; ESCREVE NO DISPLAY A TENS�O

    CALL    DELAY_1SEGUNDO              ;AGUARDA 1 SEGUNDO PARA O PROXIMO AJUSTE DE PWM

;VERIFICA SE O BOT�O DE CANCELAMENTO ( * ) FOI ACIONADO
    CALL    VARRE_BOTAO
    MOVWF   TECLA
    XORLW   .10
    BTFSC   STATUS,Z
    CALL    PWM_RESET_SISTEMA                     ;SE SIM, REINICIA O SISTEMA
    
;VERIFICA SE A CORRENTE ESTA MENOR QUE A QUINTA PARTE DA CORRENTE DE 
;EQUALIZA��O(SETPOINT DA CORRENTE) OU 2% DA CORRENTE NOMINAL.
    MOVFW   INOMI
    MOVWF   ACCbLO                          ; CARREGA O SETPOINT PARA O NUMERADOR
    BCF     STATUS,Z
    RRF     ACCbLO
    BCF     STATUS,Z
    RRF     ACCbLO                          ; DIVIDE POR 4 O SETPOINT

    BSF     FLAG_MEDIDA                     ; ESCOLHE FLAG DE MEDIDA COMO CORRENTE
    CALL    FAZ_MEDIDA                      ; REALIZA A MEDIDA DA CORRENTE
    SUBWF   ACCbLO,F                        ; Ic - (INOMI/4)
    BTFSS   STATUS,C                        ; Ic < (INIMI/4)?
    GOTO    LOOP_STAGE_THREE                ; S - REALIZA O AJUSTE NOVAMENTE
    MOVFW   TNOMI
    SUBWF   AccT
    BTFSS   STATUS,C                        ; VERIFICA SE A TENS�O DA BATERIA � 100%
    GOTO    STAGE_FOUR                      ; N - VAI PARA O QUARTO ESTAGIO
    GOTO    LOOP_STAGE_THREE                ; S - REALIZA O AJUSTE NOVAMENTE

    
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;                       ESTAGIO QUATRO                			  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *			    
;ROTINA BLOQUEANTE, EM QUE O BATERIA FICA NESTE LOOP ATE SEU      *
;PROCESSO DE CARGA OU A CONTROLADORA REINICIAR.                   *
;NESTA ROTINA, SERA FEITA A FLUTUA��O DA BATERIA, EM QUE 1% DA    *
;CORRENTE DE CARGA VAI SER IMPOSTA, SOMENTE SE A BATERIA          *
;DESCARREGAR COM O TEMPO, JA QUE EM SE TRATANDO DE CARGA, ELA JA  *
;FOI FINALIZADA.                                                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
STAGE_FOUR
    CLRF    CCPR1L                      ;DESLIGA O PROCESSO DE CARGA
    
    MOVFW   TNOMI
    SUBWF   AccT,W                      ; (AccT - TNOMI)
    BTFSC   STATUS,C                    ; (AccT < TNOMI)
    GOTO    $+4                         ; N - CONTINUA COM A CARGA DESLIGADA
                                        ; S - LIGA O CONTROLE PARA REFOR�O DE CORRENTE
    BCF     FLAG_MEDIDA                 ; ESPECIFICA QUE ESTAMOS TRABALHANDO COM TENS�O
    MOVFW   AccT                        ; RECUPERA O VALOR DA MEDIDA
    CALL    CON_P                       ; LIGA O CONTROLADOR PARA NORMALIZAR TENS�O    
    CALL    DELAY_1SEGUNDO              ; AGUARDA 1 SEGUNDO PARA O PROXIMO AJUSTE
    BCF     PORTC,RC1                   ; LED QUE INDICA QUE N�O ESTAMOS EM CARGA

;REALIZA MEDIDA E ESCRITA, DA TENS�O DA BATERIA
    BCF     FLAG_MEDIDA                 ; ESCOLHE FLAG DE MEDIDA COMO TENS�O
    CALL    FAZ_MEDIDA                  ; REALIZA A MEDIDA DA TENS�O
    CALL    ESCREVE_MEDIDA              ; ESCREVE NO DISPLAY A TENS�O

;REALIZA MEDIDA E ESCRITA, DA CORRENTE DA BATERIA
    BSF     FLAG_MEDIDA                 ; ESCOLHE FLAG DE MEDIDA COMO CORRENTE
    CALL    FAZ_MEDIDA                  ; REALIZA A MEDIDA DA CORRENTE
    CALL    ESCREVE_MEDIDA              ; ESCREVE NO DISPLAY A TENS�O
    CALL    SHIFT_DISPLAY

;VERIFICA SE O BOT�O DE CANCELAMENTO ( * ) FOI ACIONADO
    CALL    VARRE_BOTAO
    MOVWF   TECLA
    XORLW   .10
    BTFSC   STATUS,Z
    CALL    PWM_RESET_SISTEMA             ;SE SIM, REINICIA O SISTEMA

    GOTO    STAGE_FOUR
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;                       	FIM DO PROGRAMA                 	  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    END 