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
printBoard_C PROTO C, value: DWORD
initialPosition_C PROTO C

.code   
   
public C posCurScreenP1, getMoveP1, moveCursorP1, movContinuoP1, openP1, openContinuousP1
                         

extern C opc: SDWORD, row:SDWORD, col: BYTE, carac: BYTE, carac2: BYTE, mineField: BYTE, taulell: BYTE, indexMat: SDWORD
extern C rowCur: SDWORD, colCur: BYTE, rowScreen: SDWORD, colScreen: SDWORD, RowScreenIni: SDWORD, ColScreenIni: SDWORD
extern C rowIni: SDWORD, colIni: BYTE, indexMatIni: SDWORD
extern C neighbours: SDWORD, marks: SDWORD, endGame: SDWORD

;****************************************************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Situar el cursor en una fila i una columna de la pantalla
; en funció de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funció gotoxy_C.
;
; Variables utilitzades: 
; Cap
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;gotoxy:
gotoxy proc
   push ebp
   mov  ebp, esp
   pushad

   ; Quan cridem la funció gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els paràmetres s'han de passar per la pila
      
   mov eax, [colScreen]
   push eax
   mov eax, [rowScreen]
   push eax
   call gotoxy_C
   pop eax
   pop eax 
   
   popad

   leave
   ret
gotoxy endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar un caràcter, guardat a la variable carac
; en la pantalla en la posició on està  el cursor,  
; cridant a la funció printChar_C.
; 
; Variables utilitzades: 
; carac : variable on està emmagatzemat el caracter a treure per pantalla
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;printch:
printch proc
   push ebp
   mov  ebp, esp
   ;guardem l'estat dels registres del processador perqué
   ;les funcions de C no mantenen l'estat dels registres.
   
   
   pushad
   

   ; Quan cridem la funció  printch_C(char c) des d'assemblador, 
   ; el paràmetre (carac) s'ha de passar per la pila.
 
   xor eax,eax
   mov  al, [carac]
   push eax 
   call printChar_C
 
   pop eax
   popad

   leave
   ret
printch endp
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat   
; cridant a la funció getch_C
; i deixar-lo a la variable carac2.
;
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caracter llegit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;getch:
getch proc
   push ebp
   mov  ebp, esp
    
   ;push eax
   pushad

   call getch_C
   
   mov [carac2],al
   
   ;pop eax
   popad

   leave
   ret
getch endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la pantalla, dins el tauler, en funció de
; les variables (row) fila (int) i (col) columna (char), a partir dels
; valors de les constants RowScreenIni i ColScreenIni.
; Primer cal restar 1 a row (fila) per a que quedi entre 0 i 7 
; i convertir el char de la columna (A..H) a un número entre 0 i 7.
; Per calcular la posició del cursor a pantalla (rowScreen) i 
; (colScreen) utilitzar aquestes fórmules:
; rowScreen=rowScreenIni+(row*2)
; colScreen=colScreenIni+(col*4)
; Per a posicionar el cursor cridar a la subrutina gotoxy.
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu mineField/taulell
; col       : columna per a accedir a la matriu mineField/taulell
; rowScreen : fila on volem posicionar el cursor a la pantalla.
; colScreen : columna on volem posicionar el cursor a la pantalla.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;posCurScreenP1:
posCurScreenP1 proc
   push ebp
	mov  ebp, esp

   dec [row]
   sub [col], 'A'
   
   shl [row], 1
   shl [col], 2

   mov ebx, [rowScreenIni]
   add ebx, [row]
   mov [rowScreen], ebx

   mov ebx, [colScreenIni]
   add bl, [col]
   mov [colScreen], ebx

   call gotoxy

   leave
	ret
posCurScreenP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat   
; cridant a la subrutina getch
; Verificar que solament es pot introduir valors entre 'i' i 'l', 
; o les tecles espai ' ', 'm' o 's' i deixar-lo a la variable carac2.
; 
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caràcter llegit
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;getMoveP1:
getMoveP1 proc
   push ebp
   mov  ebp, esp

read_again:

   call getch

   mov al, [carac2]
   
   cmp al, ' '
   je ok
   
   cmp al, 'm'
   je ok
   
   cmp al, 's'
   je ok
   
   cmp al, 'i'
   jl read_again

   cmp al, 'l'
   jg read_again

ok:
   leave
   ret
getMoveP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Actualitzar les variables (rowCur) i (colCur) en funció de 
; la tecla premuda que tenim a la variable (carac2)
; (i: amunt, j:esquerra, k:avall, l:dreta).
; Comprovar que no sortim del taulell, (rowCur) i (colCur) només poden 
; prendre els valors [1..8] i [0..7]. Si al fer el moviment es surt 
; del tauler, no fer el moviment.
; No posicionar el cursor a la pantalla, es fa a posCurScreenP1.
; 
; Variables utilitzades: 
; carac2 : caràcter llegit de teclat
;          'i': amunt, 'j':esquerra, 'k':avall, 'l':dreta
; rowCur : fila del cursor a la matriu mineField.
; colCur : columna del cursor a la matriu mineField.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;moveCursorP1: proc endp
moveCursorP1 proc
   push ebp
   mov  ebp, esp 

   mov al, [carac2]
   cmp al, 'i'
   je move_up
   cmp al, 'k'
   je move_down
   cmp al, 'j'
   je move_left
   cmp al, 'l'
   je move_right
   jmp bye

move_up:
   cmp [rowCur], 1
   jle bye
   dec [rowCur]
   jmp bye

move_down:
   cmp [rowCur], 8
   jge bye 
   inc [rowCur]
   jmp bye

move_left:
   cmp [colCur], 0+'A'
   jle bye
   dec [colCur]
   jmp bye 

move_right:
   cmp [colCur], 7+'A'
   jge bye 
   inc [colCur]
   jmp bye 

bye:
   leave
   ret
moveCursorP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continuo. 
;
; Variables utilitzades: 
;		carac2   : variable on s’emmagatzema el caràcter llegit
;		rowCur   : Fila del cursor a la matriu mineField
;		colCur   : Columna del cursor a la matriu mineField
;		row      : Fila per a accedir a la matriu mineField
;		col      : Columna per a accedir a la matriu mineField
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;movContinuoP1: proc endp
movContinuoP1 proc
	push ebp
	mov  ebp, esp

next_move:
   call getMoveP1
   cmp [carac2], 's'
   je bye

   cmp [carac2], ' '
   je bye

   cmp [carac2], 'm'
   je bye

   call moveCursorP1

   mov ebx, [rowCur]
   mov al, [colCur]
   mov [row], ebx
   mov [col], al
   call posCurScreenP1
   jmp next_move

bye:
	leave
	ret
movContinuoP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calcular l'índex per a accedir a les matrius en assemblador.
; mineField[row][col] en C, és [mineField+indexMat] en assemblador.
; on indexMat = row*8 + col (col convertir a número).
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu mineField
; col       : columna per a accedir a la matriu mineField
; indexMat  : índex per a accedir a la matriu mineField
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;calcIndexP1: proc endp
calcIndexP1 proc
	push ebp
	mov  ebp, esp

   xor ebx, ebx

   mov eax, [row]
   mov bl, [col]
	sub bl, 'A'
   shl eax, 3
   add eax, ebx
   mov [indexMat], eax

	leave
	ret
calcIndexP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Obrim una casella de la matriu mineField
; En primer lloc calcular la posició de la matriu corresponent a la
; posició que ocupa el cursor a la pantalla, cridant a la 
; subrutina calcIndexP1.
; En cas de que la casella no estigui oberta ni marcada mostrar:
;	- 'X' si hi ha una mina
;	- 'm' si volem marcar la casella
;	- el numero de veïns si obrim una casella sense mina 
; En cas de que la casella estigui marcada mostrar:
;	- ' ' si volem desmarcar la casella
; Mostrarem el contingut de la casella criant a la subrutina printch. L'índex per
; a accedir a la matriu mineField, el calcularem cridant a la subrutina calcIndexP1.
; No es pot obrir una casella que ja tenim oberta o marcada.
; Cada vegada que marquem/desmarquem una casella, actualitzar el número de marques restants 
; cridant a la subrutina updateMarks.
; Si obrim una casella amb mina actualitzar el valor endGame a -1.
; Finalment, per al nivell avançat, si obrim una casella sense mina y amb 
; 0 mines al voltant, cridarem a la subrutina openBorders del nivell avançat.
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu mineField
; rowCur    : fila actual del cursor a la matriu
; col       : columna per a accedir a la matriu mineField
; colCur    : columna actual del cursor a la matriu 
; indexMat  : Índex per a accedir a la matriu mineField
; mineField : Matriu 8x8 on tenim les posicions de les mines. 
; carac	    : caràcter per a escriure a pantalla.
; taulell   : Matriu en la que anem indicant els valors de les nostres tirades 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;openP1: proc endp
openP1 proc
	push ebp
	mov  ebp, esp


   call calcIndexP1
   cmp [carac2], ' '
   je desmarcar
   cmp [carac2], 'm'
   je marcar
   jmp  bye


marcar:
   mov [carac], 'm'
   call printch
   jmp bye

desmarcar:
   mov eax, [indexMat]
   cmp [mineField + eax], 0
   jge no_minas
   mov [carac], '1'
   call printch
   jmp bye 


no_minas:
   mov [carac], '0'
   call printch

bye:
	leave
	ret
openP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa l’obertura continua de caselles. S’ha d’utilitzar
; la tecla espai per a obrir una casella i la 's' per a sortir. 
; Per a cada moviment introduït comprovar si hem guanyat el joc cridant a 
; la subrutina checkWin, o bé si hem perdut el joc (endGame!=0).
;
; Variables utilitzades: 
; carac2   : Caràcter introduït per l’usuari
; rowCur   : Fila del cursor a la matriu mineField
; colCur   : Columna del cursor a la matriu mineField
; row      : Fila per a accedir a la matriu mineField
; col      : Columna per a accedir a la matriu mineField
; endGame  : flag per indicar si hem perdut (0=no hem perdut, 1=hem perdut)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;openContinuousP1:proc endp
openContinuousP1 proc
	push ebp
	mov  ebp, esp


repetir:
   call movContinuoP1
   call openP1
   cmp [carac2], 's'
   je bye
   jmp repetir


   bye:

	

	mov esp, ebp
	pop ebp
	ret
openContinuousP1 endp
END
