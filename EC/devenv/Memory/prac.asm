.586
.MODEL FLAT, C


; Funcions definides en C
printChar_C PROTO C, value:SDWORD
printInt_C PROTO C, value:SDWORD
clearscreen_C PROTO C
clearArea_C PROTO C, value:SDWORD, value1: SDWORD
printMenu_C PROTO C
gotoxy_C PROTO C, value:SDWORD, value1: SDWORD
getch_C PROTO C
printBoard_C PROTO C
initialPosition_C PROTO C
rand PROTO C, value:SDWORD

.code   
   
public C posCurScreenP1, getMoveP1, moveCursorP1, movContinuoP1, openP1, openContinuousP1, setupBoard
                         

extern C opc: SDWORD, row:SDWORD, col: BYTE, carac: BYTE, carac2: BYTE, gameCards: BYTE, tauler: BYTE, indexMat: SDWORD
extern C rowScreen: SDWORD, colScreen: SDWORD, RowScreenIni: SDWORD, ColScreenIni: SDWORD
extern C rowIni: SDWORD, colIni: BYTE
extern C gameCards: BYTE, firstVal: SDWORD, firstCol: BYTE, firstRow: SDWORD, cardTurn: SDWORD, totalPairs: SDWORD, totalTries: SDWORD
extern C cards: BYTE

;****************************************************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Situar el cursor en una fila i una columna de la pantalla
; en funci? de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funci? gotoxy_C.
;
; Variables utilitzades: 
; Cap
; 
; Par?metres d'entrada : 
; Cap
;    
; Par?metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxy proc
   enter 0,0
   pusha

   ; Quan cridem la funci? gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els par?metres s'han de passar per la pila
      
   mov eax, [colScreen]
   push eax
   mov eax, [rowScreen]
   push eax
   call gotoxy_C
   pop eax
   pop eax 

   popa   

   leave
   ret
gotoxy endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar un car?cter, guardat a la variable carac
; en la pantalla en la posici? on est? el cursor,  
; cridant a la funci? printChar_C.
; 
; Variables utilitzades: 
; carac : variable on est? emmagatzemat el caracter a treure per pantalla
; 
; Par?metres d'entrada : 
; Cap
;    
; Par?metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printch proc
   enter 0,0
   ;guardem l'estat dels registres del processador perqu?
   ;les funcions de C no mantenen l'estat dels registres.
   
   pusha

   ; Quan cridem la funci?  printch_C(char c) des d'assemblador, 
   ; el par?metre (carac) s'ha de passar per la pila.
 
   xor eax,eax
   mov  al, [carac]
   push eax 
   call printChar_C
 
   pop eax
   popa

   leave
   ret
printch endp
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un car?cter de teclat   
; cridant a la funci? getch_C
; i deixar-lo a la variable carac2.
;
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caracter llegit
;
; Par?metres d'entrada : 
; Cap
;    
; Par?metres de sortida: 
; El caracter llegit s'emmagatzema a la variable carac
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getch proc
   enter 0,0
   pusha

   call getch_C
   
   mov [carac2],al
   
   popa

   leave
   ret
getch endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la pantalla, dins el tauler, en funci? de
; les variables (row) fila (int) i (col) columna (char), a partir dels
; valors de les constants RowScreenIni i ColScreenIni.
; Primer cal restar 1 a row (fila) per a que quedi entre 0 i 3 
; i convertir el char de la columna (A..D) a un n?mero entre 0 i 3.
; Per calcular la posici? del cursor a pantalla (rowScreen) i 
; (colScreen) utilitzar aquestes f?rmules:
; rowScreen=rowScreenIni+(row*2)
; colScreen=colScreenIni+(col*4)
; Per a posicionar el cursor cridar a la subrutina gotoxy.
;
; Variables utilitzades:    
; row       : fila per a accedir a la matriu gameCards/tauler
; col       : columna per a accedir a la matriu gameCards/tauler
; rowScreen : fila on volem posicionar el cursor a la pantalla.
; colScreen : columna on volem posicionar el cursor a la pantalla.
;
; Par?metres d'entrada : 
; Cap
;
; Par?metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
posCurScreenP1 proc
    enter 0,0

    pusha
    mov eax, [row]
    xor ebx,ebx
    mov bl, [col]
    sub ebx, 65
    sub eax, 1
    shl eax, 1
    shl ebx, 2

    add eax, [rowScreenIni]
    add ebx, [colScreenIni]

    mov [rowScreen], eax
    mov [colScreen], ebx

    call gotoxy

    popa

    leave
    ret
posCurScreenP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un car?cter de teclat   
; cridant a la subrutina getch
; Verificar que solament es pot introduir valors entre 'i' i 'l', 
; o les tecles espai ' ', o 's' i deixar-lo a la variable carac2.
; 
; Variables utilitzades: 
; carac2 : variable on s'emmagatzema el car?cter llegit
; 
; Par?metres d'entrada : 
; Cap
;    
; Par?metres de sortida: 
; El car?cter llegit s'emmagatzema a la variable carac2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getMoveP1 proc
   enter 0,0

loop1:
   call getch
   mov al, [carac2]
   cmp al, 'i'
   je fin
   cmp al, 'j'
   je fin
   cmp al, 'k'
   je fin
   cmp al, 'l'
   je fin
   cmp al, ' '
   je fin
   cmp al, 's'
   je fin
   jmp loop1

fin:
    mov [carac2], al

   leave
   ret
getMoveP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Actualitzar les variables (row) i (col) en funci? de 
; la tecla premuda que tenim a la variable (carac2)
; (i: amunt, j:esquerra, k:avall, l:dreta).
; Comprovar que no sortim del tauler, (row) i (col) nom?s poden 
; prendre els valors [1..4] i [A..D]. Si al fer el moviment es surt 
; del tauler, no fer el moviment.
; No posicionar el cursor a la pantalla, es fa a posCurScreenP1.
; 
; Variables utilitzades: 
; carac2 : car?cter llegit de teclat
;          'i': amunt, 'j':esquerra, 'k':avall, 'l':dreta
; row : fila del cursor a la matriu gameCards.
; col : columna del cursor a la matriu gameCards.
;
; Par?metres d'entrada : 
; Cap
;
; Par?metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursorP1 proc
   enter 0,0

   mov al, [carac2]
   cmp al, 'i'
   je handle_i
   cmp al, 'j'
   je handle_j
   cmp al, 'k'
   je handle_k
   cmp al, 'l'
   je handle_l
   cmp al, ' '
   je fin
   cmp al, 's'
   je fin

   check_row:
      pop ebx

      cmp eax, 4
      jg fin
      cmp eax, 1
      jl fin

      push ebx
      ret

   check_col:
      pop ebx

      cmp eax, 'D'
      jg fin
      cmp eax, 'A'
      jl fin

      push ebx
      ret

   handle_i:
      mov eax, [row]
      dec eax
      call check_row
      mov [row], eax
      jmp fin

   handle_k:
      mov eax, [row]
      inc eax
      call check_row
      mov [row], eax
      jmp fin

   handle_j:
      mov al, [col]
      dec eax
      call check_col
      mov [col], al
      jmp fin

   handle_l:
      mov al, [col]
      inc eax
      call check_col
      mov [col], al
      jmp fin

   fin:
      leave
      ret
moveCursorP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continuo. 
;
; Variables utilitzades:
;       carac2   : variable on s?emmagatzema el car?cter llegit
;       row      : fila per a accedir a la matriu gameCards
;       col      : columna per a accedir a la matriu gameCards
; 
; Par?metres d'entrada : 
; Cap
;
; Par?metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
movContinuoP1 proc
    enter 0,0

   bucle:
      call getMoveP1
      mov al, [carac2]
      cmp al, 's'
      je fin
      cmp al, ' '
      je fin
      call moveCursorP1
      call posCurScreenP1
      jmp bucle

fin:

   leave
   ret
movContinuoP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calcular l'?ndex per a accedir a les matrius en assemblador.
; gameCards[row][col] en C, ?s [gameCards+indexMat] en assemblador.
; on indexMat = row*8 + col (col convertir a n?mero).
;
; Variables utilitzades:    
; row       : fila per a accedir a la matriu gameCards
; col       : columna per a accedir a la matriu gameCards
; indexMat  : ?ndex per a accedir a la matriu gameCards
;
; Par?metres d'entrada : 
; Cap
;
; Par?metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calcIndexP1 proc
   enter 0,0
   
   mov eax, [rowScreen]
   mov ebx, [colScreen]

   sub eax, [rowScreenIni]
   sub ebx, [colScreenIni]

   sal eax, 1
   sar ebx, 2
   add ebx, eax

   mov cl,[gameCards+ebx]
   
   leave
   ret
calcIndexP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; En primer lloc calcular la posici? de la matriu corresponent a la
; posici? que ocupa el cursor a la pantalla, cridant a la subrutina 
; calcIndexP1. Mostrar el contingut de la casella a la posici? de 
; pantalla corresponent.
;
; Canvis per a OpenContinuous:
; En cas de que la carta no estigui girada mostrar el valor
; En cas de que sigui la primera carta girada:
;   - Guardar el valor i la posici? de la carta en el registres 
;     firstVal i firstPos
;   - Actualitzar la matriu tauler y printar el valor per pantalla 
;     a la seva posici?
; En cas de que sigui la segona carta girada:
;   - Comprovar si el valor es el mateix que la primera carta
;       - Si el valor es el mateix actualitzar la matriu tauler, la 
;         variable totalPairs, i el valor de parelles restants 
;         mostrat per pantalla (updateScore)
;       - Si el valor no es el mateix, esperar a que el usuari premi 
;         qualsevol tecla (getMoveP1), esborrar els valors de pantalla 
;         i la matriu tauler, i actualitzar els intents restants.
; Mostrarem el contingut de la carta criant a la subrutina printch. L'?ndex per
; a accedir a la matriu gameCards, el calcularem cridant a la subrutina calcIndexP1.
; No es pot obrir una casella que ja tenim oberta o marcada.
;
; Canvis per al nivell avan?at:
; Cada vegada que fem una parella o fallem, actualitzar el total de parelles 
; i intents restants.
;
; Variables utilitzades:    
; row       : fila per a accedir a la matriu gameCards
; col       : columna per a accedir a la matriu gameCards
; indexMat  : ?ndex per a accedir a la matriu gameCards
; gameCards : matriu 8x8 on tenim les posicions de les mines. 
; carac     : car?cter per a escriure a pantalla.
; tauler   : matriu en la que guardem els valors de les tirades 
; firstVal  : valor de la primera carta destapada
; firstPos  : posici? de la primera carta destapada
; cardTurn  : flag per controlar si el jugador esta obrint la 
;             primera o la segona carta
; totalPairs: nombre de parelles restants
; totalTries: nombre de intents restants
;
; Par?metres d'entrada : 
; Cap
;
; Par?metres de sortida: 
; endGame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openP1 proc
   enter 0,0

	mov al, [carac2]
	cmp al, ' '
	jne fin

	call calcIndexP1
	mov [carac], cl
	mov dl, [tauler+ebx]	;
	cmp dl,' '				; if lletra ja descoberta
	jne fin					;
	call printch

	cmp [cardTurn],1
	je first
	cmp [cardTurn],2
	je second
	jmp fin

first:
	mov byte ptr [tauler+ebx],cl	;tauler[x][y] = 'lletra descoberta'
	mov [firstCol],cl				;firstVal=firstCol
	mov [firstRow],ebx				;firstPos=firstRow
	inc cardTurn
	jmp fin
second:
	cmp cl,[firstCol]				;if firstVal = currentVal
	je equal

	;if not equal
	call getMoveP1
	mov edx,[firstRow]
	mov byte ptr [tauler+edx],' '	;valor de la primera carta girada torna a l'original
	dec cardTurn
	dec totalTries
	jmp fin

equal:
	mov byte ptr [tauler+ebx],cl	;tauler[x][y] = 'segona lletra descoberta'
	dec cardTurn
	dec totalPairs

fin:
   leave
   ret
openP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa l?obertura continua de cartes. S?ha 
; d?utilitzar la tecla espai per girar/obrir una carta i la 's' per 
; sortir. 
;
; Canvis per al nivell avan?at: 
; Per a cada moviment introdu?t comprovar si hem guanyat o perdut el 
; joc compovant les variables totalPairs i totalTries.
;
; Variables utilitzades: 
; carac2     : car?cter introdu?t per l?usuari
; row        : fila per a accedir a la matriu gameCards
; col        : columna per a accedir a la matriu gameCards
; totalPairs : nombre de variables restants que ens queden en joc
; totalTries : nombre de intents restants que ens queden en joc
;
; Par?metres d'entrada : 
; Cap
;
; Par?metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openContinuousP1 proc
    enter 0,0
	mov [cardTurn], 1
bucle:
	cmp [totalPairs],0
	je fin
	cmp [totalTries],0
	je fin
	call movContinuoP1
	cmp al,'s'
	je fin
	call openP1
	call updateScore
	jmp bucle
fin:
	mov [cardTurn],0
    leave
    ret
openContinuousP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que mostra el n?mero de parelles restants. Moure el 
; cursor a la posici? (row=-1, col=5) i (row=-1, col=3), per printar 
; el n?mero de parelles i intents restants, al finalitzar, retornar
; el cursor a la posici? original.
;
; Variables utilitzades: 
; totalPairs : nombre de parelles restants
; totalTries : nombre d'intentns restants
; row        : fila per a accedir a la matriu gameCards
; col        : columna per a accedir a la matriu gameCards
;
; Par?metres d'entrada : 
; Cap
;
; Par?metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
updateScore proc
	enter 0,0

	call printBoard_C
	call PosCurScreenP1

    leave
    ret
updateScore endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que inicialitza el tauler aleat?riament.
;
; Pistes:
; - La crida a la funci? rand guarda el valor aleatori al
;   registre eax
; - La crida a la funci? div guarda el modul de la divisi? al
;   registre edx
;
; Variables utilitzades: 
; row      : fila per a accedir a la matriu gameCards
; col      : columna per a accedir a la matriu gameCards
; cards    : llistat ordenat de cartes en joc
; gameCards: matriu de cartes ordenades aleat?riament.
;
;
; Par?metres d'entrada : 
; Cap
;
; Par?metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setupBoard proc
	enter 0,0

	mov esi,0
	mov edi,0
bucle:
	cmp esi,15
	jg bucle1
	mov byte ptr [gameCards+esi],' '
	inc esi
	jmp bucle
bucle1:
	cmp edi,15
	jg fin
	mov bl, [cards+edi]
	push ebx
random:	
	
	call rand
	mov edx,0
	mov ecx,16
	div ecx
	mov bl,' '
	cmp bl,[gameCards + edx]
	jne random
	pop ebx
	mov byte ptr [gameCards+edx],bl
	inc edi
	jmp bucle1
fin:
    leave
    ret
setupBoard endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que mostra nombres de 2 xifres per pantalla
;
; rowscreen : fila del cursor a la pantalla
; colscreen : columna del cursor a la pantalla
; carac     : car?cter a visulatizar per la pantalla
;
; Par?metres d'entrada : 
; AL: nombre a mostrar
;
; Par?metres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
showNumbers proc
    enter 0,0



    leave
    ret
showNumbers endp

;****************************************************************************************


END
