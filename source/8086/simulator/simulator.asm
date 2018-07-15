ORG 100h

;save 4 registers
S4_RGS macro
	push AX
	push BX
	push CX
	push DX
endm

;restore 4 registers
RST4_RGS macro
	pop DX
	pop CX
	pop BX
	pop AX
endm

;save 6 registers
S6_RGS macro
	push AX
	push BX
	push CX
	push DX
	push SI
	push DI
endm

;restore 6 registers
RST6_RGS macro
	pop DI
	pop SI
	pop DX
	pop CX
	pop BX
	pop AX
endm

.MODEL small
; model contains 2 segments, 
; one for code, one for data,
; both are size 64kb

.DATA
	products db 1000 dup(16 dup(0))
	
	numOfProducts dw 0
	
	ammountOfProducts db 1000 dup(0)

	totalCash dw 0
	dailyCash dw 0
	currentCash dw 0
	oneProductPrice dw 0
	
	currentID dw 0
	
	;=========================
	;	TIME
	
	timerFlag db 0
	
	oldTimer dw 2 dup(0)
	
	;===========================
	
	;=======================================
	; 	MESSAGES
	
	msgWAITING db 		"  waiting        "
	msgPROGRAMMING db	"  programming    "
	msgERROR db			"  error          "
	msgFUNCTION db		" function mode   "
	msgTOTAL db			"  total          "
	msgNEW_ID db		"  new id         "
	msgNEW_AMOUNT db	"  new amount     "
	msgACCOUNT db		"  account        "
	msgAMOUNT db		" insert amount   "
	time db 			"    00:00:00     " ; time format hr:min:sec
	
	;=======================================
	
	;=======================================
	;	KEYBOARD
	
	keypad0 db 		" ___________________ "
	keypad1 db 		"|  ___ ___ ___ ___  |"
	keypad2 db 		"| | 7 | 8 | 9 | F | |"
	keypad3 db 		"| |___|___|__ |___| |"
	keypad4 db 		"| | 4 | 5 | 6 | C | |"
	keypad5 db 		"| |___|___|___|___| |"
	keypad6 db 		"| | 1 | 2 | 3 | + | |"
	keypad7 db 		"| |___|___|___|___| |"
	keypad8 db 		"| | * | 0 | # | = | |"
	keypad9 db 		"| |___|___|___|___| |"
	keypad10 db 	"|___________________|"
	
	;=======================================
	
	;==========================================
	;	PRINTER
	
	printer14 db 	"                    "
	printer13 db 	"                    "
	printer12 db 	"                    "
	printer11 db 	"                    "
	printer10 db 	"                    "
	printer9 db 	"                    "
	printer8 db 	"                    "
	printer7 db 	"                    "
	printer6 db 	"                    "
	printer5 db 	"                    "
	printer4 db 	"                    "
	printer3 db 	" __________________ "
	printer2 db 	"|                  |"
	printer1 db 	"|     PRINTER      |"
	printer0 db 	"|__________________|"
	
	
	;===========================================
	
	;============================================
	;  numbers, letters etc. for display
	
	;numbers
	display0 db     "   -   | |       | |   - "
	display1 db     "        /|         |     "
	display2 db     "   -     |   -   |     - "
	display3 db     "   -     |   -     |   - "
	display4 db     "       | |   -     |     "
	display5 db     "   -   |     -     |   - "
	display6 db     "   -   |     -   | |   - "
	display7 db     "   -   | |         |     "
	display8 db     "   -   | |   -   | |   - "
	display9 db     "   -   | |   -     |   - "
	
	;letters
	displayA db     " - - |   | - - |   |     "
	displayB db     " - -   | |   _   | | - - "
	displayC db     " - - |         |     - - "
	displayD db     " - -   | |       | | - - "
	displayE db     " - - |     - - |     - - "
	displayF db     " - - |     - - |         "
	displayG db     " - - |       - |   | - - "
	displayH db     "     |   | - - |   |     "
	displayI db     " - -   |         |   - - "
	displayJ db     "         |       | |   - "
	displayK db     "     |  /  -   |  \      "
	displayL db     "     |         |     - - "
	displayM db     "     |\ /|     |   |     "
	displayN db     "     |\  |     |  \|     "
	displayO db     " - - |   |     |   | - - "
	displayP db     " - - |   | - - |         " 
	displayQ db     " - - |   |     |  \| - - "
	displayR db     " - - |   | - - |  \      "   
	displayS db     " - - |     - -     | - - "
	displayT db     " - -   |         |       "
	displayU db     "     |   |     |   | - - "
	displayV db     "     |   |      \ /      "
	displayW db		"     |   |     |/ \|     "
	displayX db     "      \ /       / \      "
	displayY db     "      \ /        |       "
	displayZ db     " - -    /       /    - - "
	
	
	displaySpace db     "                         "
	displayStar db     	"      \|/  - -  /|\      "  
	displayMiddle db 	"       |         |       "   
	
	;==================================================
	
	numbers db "0123456789"
	others db  "*#+=FC"
	
	
	lineString db 79 dup('=')
	lineEmpty db  79 dup(' ')
	
	;===================================================
	; 	TEMP VARIABLES
	
	tempSec db 0
	productRead db 0	; flag - if someone had inputed some product
	amountRead db 0		; flag - if someone had inputed some amount
	serialSend db 0		; flag - if sending on serial is active
	tempNum db "     "
	tempERR db "     "
	tempMSG db "                 "
	printerEmpty db "                    "
	printerEnd db 	"===================="
	tempPrinter db 	"                    "
	tempPrintERR db "     "
	
	;====================================================
	
.STACK
	dw 128 (0)
	
.CODE

;==========================================
;
;	MAIN PROGRAM
;
;===========================================

main:
	; set video mode: 
	; text mode. 80x25. 16 colors. 8 pages. 
	mov     ax, 3
	int     10h

	; blinking disabled for compatibility with dos, 
	; emulator and windows prompt do not blink anyway. 
	mov     ax, 1003h
	mov     bx, 0      ; disable blinking. 
	int     10h
	
	call initSim
	
	; read from keyboard
	mov ah, 1
	int 21h	
	
	call initProgramming
	call readyState
	
	mov ax,4c00h ;Returns control to DOS
	int 21h 	;HAS TO BE HERE! Program will crash without it!
	
;================================
;
;	draw keyboard
;
;==================================
               
drawKeyboard proc near
	
	push bp
	S4_RGS
	
    mov al, 1				
    mov bh, 0
    mov bl, 10011111b		; 7..4 - background color
							; 3..0 - foreground color
    mov cx, keypad1-keypad0	; ch = cursor start line
							; cl = cursor bottom line
							; cx = num of characters to transfer
    mov dl, 30				; dl = column
    mov dh, 8				; dh = row
    push ds
    pop es
    mov bp, offset keypad0
    mov ah, 13h
    int 10h    
    
    mov al, 1
    mov bh, 0
    mov bl, 10011111b
    mov cx, keypad1-keypad0
    mov dl, 30
    mov dh, 9
    push ds
    pop es
    mov bp, offset keypad1
    mov ah, 13h
    int 10h      
    
    mov al, 1
    mov bh, 0
    mov bl, 10011111b
    mov cx, keypad1-keypad0
    mov dl, 30
    mov dh, 10
    push ds
    pop es
    mov bp, offset keypad2
    mov ah, 13h
    int 10h  
    
    mov al, 1
    mov bh, 0
    mov bl, 10011111b
    mov cx, keypad1-keypad0
    mov dl, 30
    mov dh, 11
    push ds
    pop es
    mov bp, offset keypad3
    mov ah, 13h
    int 10h      
           
    mov al, 1
    mov bh, 0
    mov bl, 10011111b
    mov cx, keypad1-keypad0
    mov dl, 30
    mov dh, 12
    push ds
    pop es
    mov bp, offset keypad4
    mov ah, 13h
    int 10h      
             
    mov al, 1
    mov bh, 0
    mov bl, 10011111b
    mov cx, keypad1-keypad0
    mov dl, 30
    mov dh, 13
    push ds
    pop es
    mov bp, offset keypad5
    mov ah, 13h
    int 10h    
    
    mov al, 1
    mov bh, 0
    mov bl, 10011111b
    mov cx, keypad1-keypad0
    mov dl, 30
    mov dh, 14
    push ds
    pop es
    mov bp, offset keypad6
    mov ah, 13h
    int 10h    
    
    mov al, 1
    mov bh, 0
    mov bl, 10011111b
    mov cx, keypad1-keypad0
    mov dl, 30
    mov dh, 15
    push ds
    pop es
    mov bp, offset keypad7
    mov ah, 13h
    int 10h      
    
    mov al, 1
    mov bh, 0
    mov bl, 10011111b
    mov cx, keypad1-keypad0
    mov dl, 30
    mov dh, 16
    push ds
    pop es
    mov bp, offset keypad8
    mov ah, 13h
    int 10h  
    
    mov al, 1
    mov bh, 0
    mov bl, 10011111b
    mov cx, keypad1-keypad0
    mov dl, 30
    mov dh, 17
    push ds                   
    pop es
    mov bp, offset keypad9
    mov ah, 13h
    int 10h      
           
    mov al, 1
    mov bh, 0
    mov bl, 10011111b
    mov cx, keypad1-keypad0
    mov dl, 30
    mov dh, 18
    push ds
    pop es
    mov bp, offset keypad10
    mov ah, 13h
    int 10h      
      
	RST4_RGS
	pop bp
    ret            
      
drawKeyboard endp

;================================
;
;	draw printer
; 	
;
;==================================

drawPrinter PROC near
	S4_RGS
	push bp
	
	
	mov al, 1				
    mov bh, 0
    mov bl, 00001111b		; 7..4 - background color
							; 3..0 - foreground color
    mov cx, printer13-printer14	; ch = cursor start line
							; cl = cursor bottom line
							; cx = num of characters to transfer
    mov dl, 0				; dl = column
    mov dh, 21				; dh = row
    push ds
    pop es
    mov bp, offset printer3
    mov ah, 13h
    int 10h
	
	mov al, 1				
    mov bh, 0
    mov bl, 00001111b		; 7..4 - background color
							; 3..0 - foreground color
    mov cx, printer13-printer14	; ch = cursor start line
							; cl = cursor bottom line
							; cx = num of characters to transfer
    mov dl, 0				; dl = column
    mov dh, 22				; dh = row
    push ds
    pop es
    mov bp, offset printer2
    mov ah, 13h
    int 10h
	
	mov al, 1				
    mov bh, 0
    mov bl, 00001111b		; 7..4 - background color
							; 3..0 - foreground color
    mov cx, printer13-printer14	; ch = cursor start line
							; cl = cursor bottom line
							; cx = num of characters to transfer
    mov dl, 0				; dl = column
    mov dh, 23				; dh = row
    push ds
    pop es
    mov bp, offset printer1
    mov ah, 13h
    int 10h
	
	mov al, 1				
    mov bh, 0
    mov bl, 00001111b		; 7..4 - background color
							; 3..0 - foreground color
    mov cx, printer13-printer14	; ch = cursor start line
							; cl = cursor bottom line
							; cx = num of characters to transfer
    mov dl, 0				; dl = column
    mov dh, 24				; dh = row
    push ds
    pop es
    mov bp, offset printer0
    mov ah, 13h
    int 10h

	pop bp
	RST4_RGS
	
	ret
drawPrinter ENDP


;================================
;
;	read from keyboard
; 	result will be in reg AL
;
;==================================

readKey proc near

	push si
	S4_RGS
	
	; AL = character read from standard input
    mov     ah, 7
    int     21h
	
	; saving the result
	xor si, si
	mov si, ax
	
	cmp al, '0'
	je num0
	cmp al, '1'
	je num1
	cmp al, '2'
	je num2
	cmp al, '3'
	je num3
	cmp al, '4'
	je num4
	cmp al, '5'
	je num5
	cmp al, '6'
	je num6
	cmp al, '7'
	je num7
	cmp al, '8'
	je num8
	cmp al, '9'
	je num9
	cmp al, '*'
	je star
	cmp al, '#'
	je hash
	cmp al, '+'
	je plus
	cmp al, '='
	je equal
	cmp al, 'f'
	je charF
	cmp al, 'c'
	je charC
	
num0:
	mov dh, 16
    mov dl, 38
	mov bx, offset numbers 
    jmp colorIt
num1:
	mov dh, 14
    mov dl, 34
	mov bx, offset numbers
	add bx, 1
    jmp colorIt
num2:
	mov dh, 14
    mov dl, 38
	mov bx, offset numbers 
	add bx, 2
    jmp colorIt
num3:
	mov dh, 14
    mov dl, 42
	mov bx, offset numbers 
	add bx, 3
    jmp colorIt
num4:
	mov dh, 12
    mov dl, 34
	mov bx, offset numbers 
	add bx, 4
    jmp colorIt
num5:
	mov dh, 12
    mov dl, 38
	mov bx, offset numbers 
	add bx, 5
    jmp colorIt
num6:
	mov dh, 12
    mov dl, 42
	mov bx, offset numbers 
	add bx, 6
    jmp colorIt
num7:
	mov dh, 10
    mov dl, 34
	mov bx, offset numbers 
	add bx, 7
    jmp colorIt
num8:
	mov dh, 10
    mov dl, 38
	mov bx, offset numbers 
	add bx, 8
    jmp colorIt
num9:
	mov dh, 10
    mov dl, 42
	mov bx, offset numbers 
	add bx, 9
    jmp colorIt
star:
	mov dh, 16
    mov dl, 34
	mov bx, offset others 
    jmp colorIt
hash:
	mov dh, 16
    mov dl, 42
	mov bx, offset others 
	add bx, 1
    jmp colorIt
plus:
	mov dh, 14
    mov dl, 46
	mov bx, offset others 
	add bx, 2
    jmp colorIt
equal:
	mov dh, 16
    mov dl, 46
	mov bx, offset others 
	add bx, 3
    jmp colorIt
charF:
	mov dh, 10
    mov dl, 46
	mov bx, offset others 
	add bx, 4
    jmp colorIt
charC:
	mov dh, 12
    mov dl, 46
	mov bx, offset others 
	add bx, 5

;this is not neccecary
;it is only used for showing
;that simulator works fine

colorIt:				;pressed key
	mov bp, bx
	mov al, 1
	mov ah, 13h
    mov bh, 0
    mov bl, 00001111b
	mov cx, 1
	push ds
    pop es
    int 10h 

	mov bl, 10011111b
	int 10h
	
	RST4_RGS
	
	; sending the result
	mov ax, si
	
	pop si
	
	ret
readKey endp


;================================
;
;	wait for C to be pressed
;
;==================================

waitC proc near
	
	push ax
	push bp
	
	mov [timerFlag], 0
	
	mov bp, offset msgERROR
	call refreshDisplay
	
wait4c:	
	call readKey
	cmp al, 'c'
	jne wait4c
	
	pop bp
	pop ax
	
	ret
waitC endp

;================================
;
;	print key
;
;==================================

printKey proc near 
    push bp
    mov bp,sp
    
    S4_RGS
    
    mov dl, [bp+6]   
    mov dh, 0   
    mov ax,dx
    add dx,ax
    add dx,ax
    add dx,ax
    add dx,ax 
    sub dx,4
    
    mov bx, [bp+4]   
    mov bp, bx
    
    mov al, 1  
    mov ah, 13h   
    mov bh, 0
    mov bl, 00001010b
    mov cx, 5
    push ds
    pop es
 
    mov dh, 1

draw:
	int 10h   
	add bp,5
    
    inc dh
    cmp dh,6
    jne draw
   
	RST4_RGS
    
    pop bp
	ret 4   
printKey endp


;==========================================
;
;	Display refresh - bp containts msg address
;
;===========================================

refreshDisplay proc near    

    S6_RGS
    push bp   
    
    mov dx,25	;length of msg
    mov cx,1
	
drawLine:    
    cmp [bp],' '
    je blankDraw   
    cmp [bp],':'
    je colonDraw
    cmp [bp],'9'
    jle numberDraw 
    cmp [bp],'a'
    jge letterDraw
             
colonDraw:
	mov ax, offset displayMiddle
           
    push cx
    push ax
    call printKey
       
    jmp incCX       
             
blankDraw:
	mov ax, offset displaySpace
           
    push cx
    push ax
    call printKey
       
    jmp incCX  
           
letterDraw:
	xor ax,ax
    mov al,[bp]
    sub al,'a'
    mul dl
    add ax, offset displayA
           
    push cx
    push ax
    call printKey
       
    jmp incCX
       
numberDraw:   
	xor ax,ax
    mov al,[bp]
    sub al,'0'
    mul dl
    add ax, offset display0
           
    push cx
    push ax
    call printKey
       
incCX: 
    inc bp
    inc cx
    cmp cx,16
    jne drawLine
    
	pop bp
    RST6_RGS
	
	ret    
refreshDisplay endp  


;=================================
;
;	init procedure
;
;=================================

initSim proc near

	push bp
	push es
	S4_RGS
	
	mov bp, offset msgWAITING
    call refreshDisplay
	
	;draw line =====================
    mov al, 1
    mov bh, 0
    mov bl, 10010000b
    mov cx, 79
    mov dl, 0
    mov dh, 6
    push ds
    pop es
    mov bp, offset lineString
    mov ah, 13h
    int 10h        
    
    ;set cursor position beneath the =========    
    mov dh, 8
    mov dl, 0
    mov bh, 0
    mov ah, 2
    int 10h    
	
	RST4_RGS
	pop es
	pop bp
	
	ret
initSim endp

;=================================
;
;	init programming procedure
;	
; 	in this proc user will type
; 	name and price of the product
;	which will be stored in
; 	memory, and at the end on
; 	display will be shown 
;	current time
;
;=================================

initProgramming proc near

	push bp
	S6_RGS
	
	mov bp, offset msgPROGRAMMING
    call refreshDisplay
	
	;set cursor position 
    mov dh, 8
    mov dl, 1
    mov bh, 0
    mov ah, 2
    int 10h 
	
	mov bx, offset products
	xor cx, cx
	
	
prog_mode:
	; esc character is signaling
	; end of progremming
	cmp al, 1Bh
	je end_prog

	; enter
	cmp al, 0Dh
	je enter_typed

	
	mov [bx], al	
	inc bx
	inc cx
	
	; read from keyboard
	mov ah, 1
	int 21h
	jmp prog_mode

		
enter_typed:
	; increment num of products
	inc [numOfProducts]

	; move cursor
	push bx
	
	; if there is more than 16
	; products in the colon 
	; clear screen and
	; position on another 
	; the top of the colon
	
	cmp dh, 23
	jne next_row
	call clearScreen
	mov dh, 7		; position on first row-1
	
next_row:
	inc dh 		
	mov dl, 0	; 0 is for left
	mov bh, 0 	; graphics mode
	mov ah, 2
	int 10h
	
	pop bx
	mov ax, 16
	sub ax, cx
	add bx, ax
	xor cx, cx
	
	
	; read from keyboard
	mov ah, 1
	int 21h
	jmp prog_mode
	
end_prog:
	; hide cursor:
    mov ch, 32
	mov ah, 1
	int 10h
	
	; end of programming 
	; show time
	lea bx, time	; BX=offset address of string TIME
					; like mov bx, offset time
	call get_time
	
	mov bp, offset time
	call refreshDisplay

	;clear screen for keyboard    
	call clearScreen

	; show keyboard
	call drawKeyboard
	
	; show printer
	call drawPrinter
	
	; set new timer
	call setNewTimer
	
	; show time
	mov [timerFlag], 1
	
	
	RST6_RGS
	pop bp
	
	ret
initProgramming endp


;=========================================
;
;	GET_TIME
;	this procedure will get the current system time 
;	input : BX=offset address of the string TIME
;	output : BX=current time
;
;	http://www.syntax-example.com/Code/get-display-current-system-time-578.aspx
;
;=========================================

GET_TIME PROC

    PUSH AX
    PUSH CX

    MOV AH, 2CH                   ; get the current system time
    INT 21H                       

    MOV AL, CH                    ; set AL=CH , CH=hours
    CALL CONVERT                  ; call the procedure CONVERT
    MOV [BX+4], AX                ; set [BX]=hr  , [BX] is pointing to hr
                                  ; in the string TIME

    MOV AL, CL                    ; set AL=CL , CL=minutes
    CALL CONVERT                  ; call the procedure CONVERT
    MOV [BX+7], AX                ; set [BX+3]=min  , [BX] is pointing to min
                                  ; in the string TIME
                                           
    MOV AL, DH                    ; set AL=DH , DH=seconds
    CALL CONVERT                  ; call the procedure CONVERT
    MOV [BX+10], AX                ; set [BX+6]=sec  , [BX] is pointing to sec
                                  ; in the string TIME
                                                      
    POP CX                        ; POP a value from STACK into CX
    POP AX                        ; POP a value from STACK into AX

    RET                           ; return control to the calling procedure
GET_TIME ENDP	                  ; end of procedure GET_TIME


;======================================
;	
;	CONVERT
;	this procedure will convert the given
;	binary code into ASCII code
;	input : AL=binary code
;	output : AX=ASCII code
;
;=======================================

CONVERT PROC 

    PUSH DX                       

    MOV AH, 0                     ; set AH=0
    MOV DL, 10                    ; set DL=10
    DIV DL                        ; set AX=AX/DL
    OR AX, 3030H                  ; convert the binary code in AX into ASCII

    POP DX                        

    RET                           
CONVERT ENDP

;=========================================
;
;	set new timer interrupt
;
;===========================================

setNewTimer proc
	cli 
	push ax
	push es
   
	mov ax,0					
	mov es, ax					
	mov ax, es:[1ch*4]				
	mov word ptr oldTimer, ax		
	mov ax, es:[1ch*4 + 2]	
	mov word ptr oldTimer+2, ax	

	mov word ptr es:[1ch*4], offset newTimer	
	mov word ptr es:[1ch*4 + 2], seg newTimer
   
	pop es
	pop ax   
	sti
	ret
setNewTimer endp            

;=========================================
;
;	return timer interrupt
;
;==========================================

returnOldTimer proc 
	cli 
	push ax
	push es
	push ds
	
	mov ax, 0	
	mov es, ax	
	
	mov ax, word ptr oldTimer
	mov es:[1ch*4], ax
	mov ax, word ptr oldTimer+2
	mov es:[1ch*4+2], ax
	
	pop ds
	pop es
	pop ax   
	sti
	ret
returnOldTimer endp  

;========================================
;
;	new timer
;
;========================================

newTimer proc
	cli
	S6_RGS
	push es
	push ds
	
	cmp [timerFlag], 0
	je timer_end
	;MOV DI, OFFSET tempSec
	
	;MOV BH,01h ;set sleeping time for 5 seconds
	;MOV AH,2Ch
	;INT 21h ;call interupt to record the current time
	;MOV [DI],DH ;record the number of seconds to memory

;label1: 
	;INT 21h ;call interupt again to record the current time
	;SUB DH,[DI] ;subtract first time form second time
	;CMP DH,BH ;compare the time passed to the time needed to pass
	;JB label1 ;jump to the top if 5 seconds didn't pass

	; wait 1 sec
	mov cx, 0Fh
	mov dx, 4240h
	mov ah, 86h
	int 15
	
	lea bx, time	; BX=offset address of string TIME
					; like mov bx, offset time
	call get_time
	
	cmp [serialSend], 1
	mov time[15], ' '
	jne only_time
	mov time[15], '*'
	
only_time:
	mov bp, offset time
	call refreshDisplay
	
	; if new day is starting 
	; reset daily cash
	; mov [dailyCash], 0
	
timer_end:
	pop ds
	pop es
	RST6_RGS
	sti
	iret
newTimer endp                 	  


;========================================
;
;	clear screen
;
;========================================

clearScreen proc near

	push bp
	S6_RGS
	
	mov di, 16
	mov dh, 8
clear_Screen:
    mov al, 1
    mov bh, 0
    mov bl, 00000000b
    mov cx, 79
    mov dl, 0
    push ds
    pop es
    mov bp, offset lineEmpty
    mov ah, 13h
    int 10h      
    
    dec di
	inc dh
	cmp di, 0
    jne clear_Screen
	
	RST6_RGS
	pop bp
	
	ret
clearScreen endp


;========================================
;
;	ready state
;
;========================================

readyState proc near
	S6_RGS
	push es
	push ds
	push bp

main_loop:	
	call readKey
	cmp al, 1Bh	; esc is for the end
	je lab_end
	cmp al, 'f'
	je lab_f
	cmp al, '0'
	jl err
	cmp al, '9'
	jg err
	jmp input_products
	
	
	; this is the input mode
	; user types number between 0-999
	; which will determine product id
input_more_products:
	call readKey
	cmp al, '+'
	je plus_presed
	cmp al, '#'
	je minus_presed
	cmp al, '*'
	je star_presed
	cmp al, '='
	je lab_equ
	cmp al, 'c'
	je c_presed
	cmp al, '0'
	jl err
	cmp al, '9'
	jg err
	
input_products:
	; disable time showing
	mov [timerFlag], 0
	
	; for determing errors
	mov [productRead], 1
	
	xor ah, ah
	xor bx, bx
	mov bl, al
	sub bl, '0'
	mov ax, [currentID]
	mov cx, 10
	mul cx
	add ax, bx
	
	; determines if there user
	; inputed id that is biger
	; than total num of products
	inc ax						; BECAUSE NUM OF PRODUCT STARTS AT 1
								; AND ID STARTS AT 0!
	cmp [numOfProducts], ax
	jb err
	
	dec ax
	mov [currentID], ax
	
	; positioning on product
	mov cx, 16		; name + price = 16
	mul cx
	mov bp, ax
	
	; refresh diplay
	add bp, offset products
	call refreshDisplay
	jmp input_more_products

plus_presed:
	; if product is not read
	; than this path is wrong
	cmp [productRead], 1
	jne err
	
	call findPrice
	call strToInt
	
	mov [oneProductPrice], ax
	add [currentCash], ax
	add [dailyCash], ax
	add [totalCash], ax
	
	; clear tempNum string
	mov si, offset tempNum
	mov cx, 5
	call clearString
	
	; convert int to string
	mov ax, [currentCash]
	call intToStr
	
	; concatenate ACCOUNT and cash
	mov si, offset msgACCOUNT
	add si, 14
	mov di, offset tempNum
	add di, 5
	mov cx, 5
	call concateString
	
	; increment ammount of current product
	mov bx, [currentID]
	add bx, offset ammountOfProducts
	inc byte ptr [bx]
	
	; clear strings
	mov si, offset tempPrinter
	mov cx, 20
	call clearString
	mov si, offset tempNum
	mov cx, 5
    call clearString
	
	; positioning on product
	mov cx, 16
	mov ax, [currentID]
	mul cx
	add ax, offset products
	mov si, ax
	mov di, offset tempPrinter
	add di, 1
	call copyProductName		; copy name 
	
	; copy price
	mov ax, [oneProductPrice]
    call intToStr
	mov si, offset tempPrinter
	add si, 17
	mov di, offset tempNum
	add di, 5
	mov cx, 5
	call concateString
	
	; print on printer
	mov bp, offset tempPrinter
	call printerPrint
	
	; clear ID
	mov [currentID], 0
	
	; clear price of one
	mov [oneProductPrice], 0
	
	; show total cash for this account
	mov bp, offset msgACCOUNT
	call refreshDisplay
	
	mov [productRead], 0
	jmp input_more_products
	
minus_presed:
	; if product is not read
	; than this path is wrong
	cmp [productRead], 1
	jne err
	
	call findPrice
	call strToInt
	
	mov [oneProductPrice], ax
	sub [currentCash], ax
	sub [dailyCash], ax
	sub [totalCash], ax
	
	; clear tempNum string
	mov si, offset tempNum
	mov cx, 5
	call clearString
	
	; convert int to string
	mov ax, [currentCash]
	call intToStr
	
	; concatenate ACCOUNT and cash
	mov si, offset msgACCOUNT
	add si, 14
	mov di, offset tempNum
	add di, 5
	mov cx, 5
	call concateString
	
	; increment ammount of current product
	mov bx, [currentID]
	add bx, offset ammountOfProducts
	dec byte ptr [bx]
	
	; clear strings
	mov si, offset tempPrinter
	mov cx, 20
	call clearString
	mov si, offset tempNum
	mov cx, 5
    call clearString
	
	; positioning on product
	mov cx, 16
	mov ax, [currentID]
	mul cx
	add ax, offset products
	mov si, ax
	mov di, offset tempPrinter
	add di, 1
	call copyProductName		; copy name 
	
	; copy price
	mov ax, [oneProductPrice]
    call intToStr
	mov si, offset tempPrinter
	add si, 17
	mov di, offset tempNum
	add di, 5
	mov cx, 5
	call concateString
	
	; minus
	mov bx, offset tempPrinter
	mov [bx + 11], '-'
	
	; print on printer
	mov bp, offset tempPrinter
	call printerPrint
	
	; clear ID
	mov [currentID], 0
	
	; clear price of one
	mov [oneProductPrice], 0
	
	; show total cash for this account
	mov bp, offset msgACCOUNT
	call refreshDisplay
	
	mov [productRead], 0
	jmp input_more_products
	
star_presed:
	; if product is not read
	; than this path is wrong
	cmp [productRead], 1
	jne err
	
	; cls
	mov bp, offset msgAMOUNT
	call refreshDisplay
	
	call findPrice		; tmp - string price
	call strToInt		; ax price
	
	xor bx, bx	; price of product
	xor cx, cx	; for total count
	mov bx, ax

star_loop:	
	call readKey
	cmp al, '+'
	je star_plus_presed
	cmp al, 'c'
	je star_c_presed
	cmp al, '0'
	jl err
	cmp al, '9'
	jg err
	
	; set flag - amount is inputed
	mov [amountRead], 1
	
	xor ah, ah
	; number of products
	sub ax, 48 	; to number
	mov si, ax
	mov ax, cx
	mov cx, 10
	mul cx
	mov cx, ax
	add cx, si
	add ax, si	; for intToString
	
	
	push cx
	;clear strings
	mov si, offset tempMSG
	mov cx, 17
	call clearString
	mov si, offset tempNum
	mov cx, 5
    call clearString	                      
		
	; concatenate 
	call intToStr 

	mov si, offset tempMSG
	add si, 6
	mov di, offset tempNum
	add di, 6
	mov cx, 6
	call concateString
    
	
	; price of all
	mul bx
	
	call intToStr
	mov si, offset tempMSG
	add si, 14
	mov di, offset tempNum
	add di, 5
	mov cx, 5
	call concateString
	
	pop cx
	
	; show number + price
	mov bp, offset tempMSG
	call refreshDisplay
	jmp star_loop
	
star_plus_presed:
	cmp [amountRead], 1
	jne err
	
	mov ax, bx
	mul cx
	add [currentCash], ax
	add [dailyCash], ax
	add [totalCash], ax
	
	push ax 	; save total price
	push cx		; save total count
	
	; clear tempNum string
	mov si, offset tempNum
	mov cx, 5
	call clearString
	
	; convert int to string
	mov ax, [currentCash]
	call intToStr
	
	; concatenate ACCOUNT and cash
	mov si, offset msgACCOUNT
	add si, 14
	mov di, offset tempNum
	add di, 5
	mov cx, 5
	call concateString
	
	; add number of sold products
	mov bx, [currentID]
	add bx, offset ammountOfProducts
	pop cx
	add [bx], cx
		
	; print on printer
	; clear strings
	mov si, offset tempPrinter
	mov cx, 20
	call clearString
	mov si, offset tempNum
	mov cx, 5
    call clearString
	
	; positioning on product
	mov cx, 16
	mov ax, [currentID]
	mul cx
	add ax, offset products
	mov si, ax
	mov di, offset tempPrinter
	add di, 1
	call copyProductName		; copy name 
	
	; copy price
	pop ax
    call intToStr
	mov si, offset tempPrinter
	add si, 17
	mov di, offset tempNum
	add di, 5
	mov cx, 5
	call concateString
	
	; print on printer
	mov bp, offset tempPrinter
	call printerPrint
	
	; show total cash for this account
	mov bp, offset msgACCOUNT
	call refreshDisplay
	
	; clear ID
	mov [currentID], 0
	
	; clear flag
	mov [amountRead], 0
	
	jmp input_more_products
	
star_c_presed:
	mov bp, offset msgNEW_AMOUNT
	call refreshDisplay
	
	xor cx, cx	; for total count
	mov [amountRead], 0
	jmp star_loop
	
c_presed:
	; if product is not read
	; than this path is wrong
	cmp [productRead], 1
	jne err
	
	; reset curr ID
	mov [currentID], 0
	
	; show message
	mov bp, offset msgNEW_ID
	call refreshDisplay
	jmp input_more_products
	
	
	
	; this is the function mode
	; user types one number between 
	; 0-3 which will determine function
lab_f:
	; disable time showing
	mov [timerFlag], 0
	
	mov bp, offset msgFUNCTION
	call refreshDisplay
	
	call readKey
	cmp al, 'c'
	je fun_c
	cmp al, '0'
	je fun_0
	cmp al, '1'
	je fun_1
	cmp al, '2'
	je fun_2
	cmp al, '3'
	je fun_3
	jmp err


fun_c:
	; get back to showing system clock
	mov [timerFlag], 1
	jmp main_loop
	
	
	; send ammount of every product
	; on serial port,
	; and reset to 0 all amounts
fun_0:
	; for displaying star
	mov [serialSend], 1
	
	; get back to showing system clock
	mov [timerFlag], 1
	
	cmp [numOfProducts], 0
	je fun0_end
	
	mov bx, offset ammountOfProducts	
	mov cx, [numOfProducts]

serial_loop:
	mov al, byte ptr [bx]
					; send id - cx
					; send ammount - ax
	mov byte ptr [bx], 0
	inc bx
	loop serial_loop
	
fun0_end:
	mov [serialSend], 0
	jmp main_loop
	
	
	; send ammount of every product
	; on printer,
	; and reset to 0 all amounts
fun_1:
	; for displaying star
	mov [serialSend], 1
	
	; get back to showing system clock
	mov [timerFlag], 1
	
	cmp [numOfProducts], 0
	je fun1_end
	
	mov bx, offset ammountOfProducts	
	mov dx, [numOfProducts]
	xor ax, ax		; for ID
	
printer_loop:
	cmp [bx], 0
	je zero_sold
	
	push ax
	push dx
	
	; clear strings
	mov si, offset tempPrinter
	mov cx, 20
	call clearString
	mov si, offset tempNum
	mov cx, 5
    call clearString
		
	; positioning on product
	mov cx, 16
	mul cx
	add ax, offset products
	mov si, ax
	mov di, offset tempPrinter
	add di, 1
	call copyProductName		; copy name 
	
	
	; copy num of sold items
	xor ax, ax
	mov al, byte ptr [bx]
    call intToStr
	mov si, offset tempPrinter
	add si, 17
	mov di, offset tempNum
	add di, 5
	mov cx, 5
	call concateString
	
	pop dx
	pop ax
	
	; print on printer
	mov bp, offset tempPrinter
	call printerPrint

zero_sold:
	inc ax
	mov [bx], 0		; restore amount to zero
	inc bx
	dec dx
	cmp dx, 0
	jne printer_loop
	
fun1_end:	
	mov [serialSend], 0
	jmp main_loop
	
	
	; displays total cash from 
	; system's first sale
fun_2:
	
	; clear tempNum string
	mov si, offset tempNum
	mov cx, 5
	call clearString
	
	; convert int to string
	mov ax, [totalCash]
	call intToStr
	
	; concatenate total and cash
	mov si, offset msgTOTAL
	add si, 14
	mov di, offset tempNum
	add di, 5
	mov cx, 5
	call concateString
	
	; rpint total to display
	mov bp, offset msgTOTAL
	call refreshDisplay
	
	jmp main_loop
	
fun_3:
	; open cash drawer
	; get back to showing system clock
	mov [timerFlag], 1
	jmp main_loop

lab_equ:
	; print account
	
	; clear tempNum string
	mov si, offset tempNum
	mov cx, 5
	call clearString
	
	; convert int to string
	mov ax, [currentCash]
	call intToStr
	
	; concatenate total and cash
	mov si, offset msgACCOUNT
	add si, 14
	mov di, offset tempNum
	add di, 5
	mov cx, 5
	call concateString
	
	; print total on printer
	mov bp, offset printerEnd
	call printerPrint
	
	mov si, offset tempPrinter
	mov cx, 20
	call clearString
	
	call intToStr
	mov si, offset tempPrinter
	add si, 17
	mov di, offset tempNum
	add di, 5
	mov cx, 5
	call concateString
	
	mov bp, offset tempPrinter
	call printerPrint
	
	; rpint total to display
	mov bp, offset msgACCOUNT
	call refreshDisplay
	
	; wait 5 sec
	mov cx, 4Ch
	mov dx, 4B40h
	mov ah, 86h
	int 15
	
	; clear 
	mov [currentCash], 0
	
	; clear ID
	mov [currentID], 0
	
	; get back to showing system clock
	mov [timerFlag], 1
	jmp main_loop

err:
	call waitC
	
	; reset ID
	mov [currentID], 0
	
	; reset flags
	mov [amountRead], 0
	mov [productRead], 0
	mov [oneProductPrice], 0
	
	mov [timerFlag], 1
	jmp main_loop
	
lab_end:
	call returnOldTimer
	
	RST6_RGS
	pop bp
	pop ds
	pop es
	ret
readyState endp	

;========================================
;
;	convert int to string
;	input: ax int
;	output: converted int in tempNum
;
;========================================

intToStr proc near
	S4_RGS
	
	mov bx, offset tempNum	;address of string
	add bx, 5				; length of string
	mov cx, 10
	
convert_num:
	xor dx, dx
	div cx
	add dl, '0'				; to ASCII
	mov [bx], dl			; save to string
	dec bx
	cmp ax, 0
	jne convert_num

	RST4_RGS
	ret
intToStr endp

;========================================
;
;	convert string to int
;	
;	output: ax int
;
;========================================

strToInt proc near
	push si
	S4_RGS
	
	mov bx, offset tempNum	;address of string 
	mov cx, 5				; length of string

	xor ax, ax
	
convert_str:
	cmp byte ptr [bx], ' '
	je space_inc
	
	xor dx, dx
	mov dl, byte ptr [bx]
	sub dl, 48	; '0'
	add ax, dx
	
	dec cx
	inc bx
	cmp byte ptr [bx], ' '
	je space_inc
	
	; if number is biger than 0-9
	mov dx, 10
	mul dx
	jmp convert_str
	
space_inc:
	inc bx
	dec cx
	cmp cx, 0
	jne convert_str

convert_str_end:
	mov si, ax
	
	RST4_RGS
	
	mov ax, si
	
	pop si
	ret
strToInt endp

	
;========================================
;
;	concatenate strings
;	input: si -  end of src adr.
;			di - end of dst adr. for con
;			cx - length for cpy 
;
;========================================

concateString proc near
	S6_RGS
	
	mov ax, cx				; save cnt 
	
clr:						; clear part of the string for
							; number
	mov [si], ' '
	dec si
	loop clr
	
	
	add si, ax				; return to start
	mov cx, ax				; rst cnt
	
	xor dx, dx
cpy:
	mov dl, [di]			; copy from tempNum
	mov [si], dl			; copy to messageString
	dec si
	dec di
	loop cpy
	
	RST6_RGS
	ret
concateString endp

;========================================
;
;	clear string
;	input: si -  src adr.
;			cx - length 
;
;========================================

clearString proc near
cls:
	mov [si], ' '
	inc si
	loop cls
	
	ret
clearString endp

;========================================
;
;	find price of current product
;	output : tempNum
;
;========================================

findPrice proc near
	S4_RGS
	push di
	
	mov ax, [currentID]
	
	; clear tempNum string
	push si
	xor cx, cx
	mov si, offset tempNum
	mov cx, 5
	call clearString
	mov bx, offset tempNum
	pop si
	
	
	; positioning on product
	mov cx, 16		; name + price = 16
	mul cx
	add ax, offset products
	mov di, ax
	
	
	xor dx, dx
finding:
	mov dl, byte ptr [di]
	cmp dl, ' '
	je find_num
	cmp dl, '0'	;30h
	jl find_num
	cmp dl, '9'	;39h
	jg find_num
	
	; number found
	mov [bx], dl
	inc bx
	
find_num:
	inc di
	dec cx
	cmp cx, 0
	jne finding

found:
	pop di
	RST4_RGS
	ret
findPrice endp

;========================================
;
;	print line by line
;	
; 	input: bp - offset of msg for print
;
;========================================

printerPrint PROC near
	
	S6_RGS
	
	xor cx, cx
	mov cx, 20
	
	mov si, offset printer14
	add si, cx
	mov di, offset printer13
	add di, cx
	call concateString

	mov si, offset printer13
	add si, cx
	mov di, offset printer12
	add di, cx
	call concateString

	mov si, offset printer12
	add si, cx
	mov di, offset printer11
	add di, cx
	call concateString

	mov si, offset printer11
	add si, cx
	mov di, offset printer10
	add di, cx
	call concateString

	mov si, offset printer10
	add si, cx
	mov di, offset printer9
	add di, cx
	call concateString

	mov si, offset printer9
	add si, cx
	mov di, offset printer8
	add di, cx
	call concateString

	mov si, offset printer8
	add si, cx
	mov di, offset printer7
	add di, cx
	call concateString
	
	mov si, offset printer7
	add si, cx
	mov di, offset printer6
	add di, cx
	call concateString
	
	mov si, offset printer6
	add si, cx
	mov di, offset printer5
	add di, cx
	call concateString

	mov si, offset printer5
	add si, cx
	mov di, offset printer4
	add di, cx
	call concateString
	
	mov si, offset printer4
	add si, cx
	mov di, bp
	add di, cx
	call concateString

	; first line
	mov bp, offset printer14
	
	mov al, 1
    mov bh, 0
    mov bl, 00001111b ;black background, white foreground
    mov dl, 0
    mov dh, 10
    push ds
    pop es
    mov ah, 13h
printing_loop:
    int 10h  
	
	; next line
	add bp, cx
	inc dh
	cmp dh, 21
	jne printing_loop
	
	RST6_RGS
	ret
printerPrint ENDP

;========================================
;
;	copy product name
;	
; 	input: si - offset of product name
;			di - offset of dst mesage
;
;========================================

copyProductName proc near
	push ax
	
	xor ax, ax
name_loop:
	mov al, [si]
	cmp al, ' '
	je name_end
	mov [di], al
	inc si
	inc di
	jmp name_loop

name_end:
	pop ax
	ret
copyProductName endp

end main      
