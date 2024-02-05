section .text

    global _start                       

;main;
    _start:
        ;Inicia o código

        push ebp                        ; ebp na base da pilha
        mov ebp, esp                    ; ebp recebe o ponteiro para o topo da pilha (esp)


    pedir_numero:
        ; saída
        mov edx, len_menu                    ; recebe o len_menu da mensagem
        mov ecx, menu                    ; recebe a mensagem
        
        mov ebx, 1                       ; entrada padrão 
        mov eax, 4                       ; output
        int 0x80                        ; Interrupção

        ; entrada
        mov edx, 5                      ; len_menu da entrada 
        mov ecx, discos                 ; armazenamento em 'discos'
        
        mov ebx, 0                      ; entrada padrão
        mov eax, 3                      ; input           
        int 0x80                        ; Interrupção
        
        mov edx, discos                  ; menu de discos eax
        call    stringparaint

        cmp eax, 1                      ; compara se o número digitado é maior ou igual a 1
        jl  numero_errado               ; se for menor que 1 exibe mensagem de erro
        cmp eax, 9                      ; compara se o número digitado é menor ou igual a 9
        jg  numero_errado               ; se for maior que 9, exibe mensagem de erro


        ; 3 torres em ordem
        push dword 0x2                  ; meio
        push dword 0x3                  ; destino
        push dword 0x1                  ; origem
        push eax                        ; eax na pilha

        call torrehanoi                 ; chama a função ranoi

        jmp fim_programa                ; pula para o fim do programa

        ; finaliza
        mov eax, 1                      ; Saida do sistema
        mov ebx, 0                      ; saida padrão  
        int 0x80                        ; Interrupção Kernel


;funcao para checar se o numero digitado esta ok;
numero_errado:
        ; Mensagem de erro
        mov edx, len_numero_errado      ; Tamanho da mensagem de erro
        mov ecx, msg_numero_errado      ; Mensagem de erro

        mov ebx, 1                       ; Saída padrão
        mov eax, 4                       ; input
        int 0x80                         ; Interrupção Kernel
        jmp pedir_numero                 ; Volta para o início do loop para pedir novamente o número


;funcao par finalizar o programa;
fim_programa:
        ; Mensagem de conclusão
        mov edx, len_concluido           ; Tamanho da mensagem "Concluido! Você finalizou a torre de Hanoi"
        mov ecx, msg_concluido           ; Mensagem "Concluido! Você finalizou a torre de Hanoi"

        mov ebx, 1                        ; saída padrão
        mov eax, 4                        ; input
        int 0x80                          ; Interrupção Kernel

        ; fim
        mov eax, 1                        ; saída do sistema
        mov ebx, 0                        ; saída padrão  
        int 0x80                          ; Interrupção Kernel


;função para mudar de ascii para int;
stringparaint:
    xor     eax, eax                    ; limpa o registrador
    mov     ebx, 10                     ; auxiliar de multiplicação.
    
    .loop:
        movzx   ecx, byte [edx]         ; um byte de edx p/ ecx (1 numero)
        inc     edx                     ; +1
        cmp     ecx, '0'                ; compara ecx com '0'
        jb      .done                   ; se for menor pula pra linha .done
        cmp     ecx, '9'                ; compara ecx com '9'
        ja      .done                   ; se for maior pula pra linha .done
        
        sub     ecx, '0'                ; duminui a string de zero (transformar em int)
        imul    eax, ebx                ; multiplica por ebx
        add     eax, ecx                ; adiciona ecx que foi para eax
        jmp     .loop                   ; loop até .done
    
    .done:
        ret                             ; sair 


;torre hanoi;

    torrehanoi: 

        push ebp                        ; ebp na base pilha
        mov ebp, esp                     ; ebp recebe o ponteiro do topo da pilha (esp)

        mov eax,[ebp+8]                 ; primeiro elemento da pilha (numero digitado)
        cmp eax,0x0                     ; compara eax com 0x0=0 em hexadecimal 
        jle fim                         ; se for menor ou igual a 0 desempilha
        
        ;recursao
        dec eax                         ; -1
        push dword [ebp+16]             ; coloca na pilha o pino de trabalho
        push dword [ebp+20]             ; coloca na pilha o pino de destino
        push dword [ebp+12]             ; coloca na pilha o pino de origem
        push dword eax                  ; poe eax na pilha com -1 para a recursividade

        call torrehanoi                ; recursao

        ;2- move o pino e imprime
        add esp,12                      ; libera 12bits de espaço (ultimo-primeiro)
        push dword [ebp+16]             ; pega o pino de origem referenciado pelo parâmetro ebp+16
        push dword [ebp+12]             ; coloca na pilha o pino de origem
        push dword [ebp+8]              ; coloca na pilha o pino de o numero de disco inicial
        call imprime                    ; Chama a função 'imprime'
        
        ;3- recursao
        add esp,12                      ; libera 12bits de espaço (ultimo-primeiro)
        push dword [ebp+12]             ; coloca na pilha o pino de origem
        push dword [ebp+16]             ; coloca na pilha o pino de trabalho
        push dword [ebp+20]             ; coloca na pilha o pino de destino
        mov eax,[ebp+8]                 ; número de discos atuais
        dec eax                         ; -1

    push dword eax                      ; poe eax na pilha
        call torrehanoi                ; recursao


    fim: 

        mov esp,ebp                     ; ebp para esp (guarda em outro registrador)
        pop ebp                         ; tira da pilha o ebp (desempilha)
        ret                             


    imprime:

        push ebp                        ; empilha
        mov ebp, esp                    ; recebe o ponteiro do topo da pilha (esp)

        mov eax, [ebp + 8]            ; coloca no registrador ax o disco a ser movido
        add al, 48                    ; conversao na tabela ASCII
        mov [disco], al               ; coloca o valor no [disco] para o print

        mov eax, [ebp + 12]             ; pino de trabalho
        add al, 64                    ; conversao para ASCII
        mov [torre_origem], al           ; al para [torre_origem]

        mov eax, [ebp + 16]             ; pino de destino
        add al, 64                     ; conversao para ASCII
        mov [torre_destino], al          ; al para [torre_destino]

        mov edx, len_msg_pino                 ; tamanho da mensagem 
        mov ecx, msg_pino                    ; mensagem em si

        mov ebx, 1                      ; permissão para a saida
        mov eax, 4                      ; output
        int 0x80                        ; Interrupção kernel

        mov     esp, ebp                ; ebp para esp
        pop     ebp                     ; topo da pilha para o ebp
        ret                         


;variáveis inicializadas;
section .data
   
    menu db 'Seja bem vindo a jogo Torre de Hanoi! Digite a quantidade de discos: ' ,0xa      ; mensagem do começo para pedir a quantidade
    len_menu equ $-menu                                      ;tamanho da mensagem, em len_menu

    msg_concluido db 'A Torre de Hanoi foi finalizada com sucesso!', 0xa ; mensagem do final
    len_concluido equ $-msg_concluido           ;tamanho da mensagem

    msg_numero_errado db 'Número errado! Digite um número entre 1 e 9.', 0xa            ; mensagem de erro
    len_numero_errado equ $-msg_numero_errado           ;tamanho da mensagem

    ; saida
    msg_pino:
                   db        "Mova o disco "   
    disco:            db        " "
                      db        " da torre "                     
    torre_origem:      db        " "  
                      db        " para torre "     
    torre_destino:     db        " ", 0xa  ; para quebrar linha
    
len_msg_pino            equ       $-msg_pino


;variáveis não inicializadas;
section .bss

    discos resb 5                 ; Armazenamento de dados não inicializado