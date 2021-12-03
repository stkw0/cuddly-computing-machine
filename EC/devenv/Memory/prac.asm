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
   shr bl, 2
   shl eax, 2
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
   mov eax, [indexMat]
   cmp [carac2], ' '
   je desmarcar
   cmp [carac2], 'm'
   je marcar
   jmp  bye


marcar:
   ; no marks left to be used
   cmp [taulell + eax], 'm'
   je undo_mark

   cmp [marks], 0
   jle bye

   mov [taulell + eax], 'm'
   mov [carac], 'm'
   call printch
   jmp bye

undo_mark:
   cmp [marks], 9
   jge bye

   mov [taulell + eax], ' '
   mov [carac], ' '
   call printch
   jmp bye

desmarcar:
  
   ;mov bl, [mineField + eax]
   ;cmp bl, 0
   ;je no_minas
   ;add bl, '0'
   ;mov [carac], bl 
   ;call printch
   call countMines
   jmp bye 


no_minas:
   mov [carac], '0'
   call printch

bye:
   call updateMarks
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
; row      : Fila per a accedir a la matriu mineFieldf
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

	leave
	ret
openContinuousP1 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; Modificar el nombre de marques encara disponibles. 
; Recórrer el taullel per comptar les marques posades ('m') i restar aquest valor a les inicials (9). 
; Imprimir el nou valor a la posició indicada (rowScreen = 3, colScreen = 57), tenint 
; en compte que hi haurem de sumar el valor '0' pel format ASCII. 
; 
; Variables utilitzades:  
; taulell   : Matriu en la que anem indicant els valors de les nostres tirades  
; rowScreen : Fila de la pantalla 
; colScreen : Columna de la pantalla 
; marks     : Nombre de mines no marcades 
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
updateMarks proc 
 push ebp 
 mov  ebp, esp 
 
 xor ecx, ecx
 mov [marks], 9

bucle:
 cmp ecx, 64
 je bye

 xor eax, eax
 ;mov eax, [indexMat]
 cmp [taulell + ecx], 'm'
 lahf ; load flags into  AH ← EFLAGS(SF:ZF:0:AF:0:PF:1:CF);
 shr eax, 14
 and eax, 01b 
 ; if ZF == 1 then EAX = 1
 sub [marks], eax

 inc ecx
 jmp bucle

bye:
 mov [rowScreen], 3
 mov [colScreen], 57
 call gotoxy

    mov ebx, [marks]
   add ebx, '0' 
   mov [carac], bl
   call printch

 leave
 ret 
updateMarks endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; Comptar el nombre de mines a les cel·les veïnes (les vuit del voltant).  
; S'ha de comprovar que no accedim a posicions de fora el mineField per comptar les mines. 
; Guardar el nombre de mines de les cel·les a la variable neighbours. 
; 
; Variables utilitzades:  
; taulell    : Matriu en la que anem indicant els valors de les nostres tirades  
; mineField  : Matriu 8x8 on tenim les posicions de les mines.  
; neighbours : Caràcter introduït per l’usuari 
; col        : Fila del cursor a la matriu mineField 
; row        : Columna del cursor a la matriu mineField 
; indexMat   : Índex per a accedir a la matriu mineField 
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
countMines proc 
 push ebp 
 mov  ebp, esp 
 ;esqDalt   dalt   dretDalt 
 ;esq              dret 
 ;esqBaix   baix   dretBaix 
 
 xor edx, edx ; mines counter
 xor ecx, ecx 
 xor ebx, ebx 
 
 mov cl, [col]
 push ecx
 cmp cl, 0
 je iteration_1

 dec cl
 mov [col], cl
 call calcIndexP1
 mov eax, [indexMat]
 mov bl, [mineField + eax]
 add edx, bl

 iteration_1:
 
 pop ecx
 mov [col], cl
 call calcIndexP1
 mov eax, [indexMat]
 mov bl, [mineField + eax]
 add edx, bl

 iteration_2:

 push ecx
 cmp cl, 7
 je iteration_3

 inc ecx
 mov [col], cl
 call calcIndexP1
 mov eax, [indexMat]
 mov bl, [mineField + eax]
 add edx, bl

 iteration_3:




 dec ecx

 mov ebx, [row]
 dec ebx


next_col:
 cmp ecx, 2
 jge bye
   
next_row:
   cmp ebx, 8
   jge fi_row

   mov [row], 0
   mov [col], 0
   call calcIndexP1
   mov eax, [indexMat]

   mov bl, [mineField + eax]
   cmp bl, 1
   lahf ; load flags into  AH ← EFLAGS(SF:ZF:0:AF:0:PF:1:CF);
   shr eax, 14
   and eax, 01b 
   ; if ZF == 1 then EAX = 1
   add edx, eax

   inc ebx
   jmp next_row
fi_row:

 inc ecx
 jmp next_col   
 bye:

 leave
 ret 
countMines endp

END

COMMENT @
extern "C" char mineField[8][8] = {
{ 1,0,0,0,0,0,0,0 },
{ 0,0,0,1,0,0,1,0 },
{ 0,0,0,0,0,0,0,0 },
{ 0,1,0,0,0,1,0,0 },
{ 0,0,0,0,0,0,0,0 },
{ 0,0,0,1,0,1,0,0 },
{ 0,0,0,0,0,0,0,0 },
{ 0,1,0,0,1,0,0,0 } 
@