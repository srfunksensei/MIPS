.8086
.model medium

;====================================================================================================
;************************************    CONSTANTS     **********************************************
;====================================================================================================

;----------------------------------------------------------------
;	INTERFACES 
;----------------------------------------------------------------
  
  ;interrupt controller 8259A
  icw1_adr EQU 0018h
  icw2_adr EQU 001Ah
  icw3_adr EQU 001Ah
  icw4_adr EQU 001Ah
  ocw1_adr EQU 001Ah
  ocw2_adr EQU 0018h
  ocw3_adr EQU 0018h
  icw1 EQU 00010111b
  icw2 EQU 00100000b
  icw4 EQU 00000101b
  ocw1 EQU 11100000b
  lockKeyboard EQU 11100100b
  unlockKeyboard EQU 11100000b
  eoi0_command EQU 00110000b
  eoi1_command EQU 00110001b
  eoi2_command EQU 00110010b
  eoi3_command EQU 00110011b
  eoi4_command EQU 00110100b
     
  ;timer 8254
  cnt0_adr EQU 0020h 
  cnt1_adr EQU 0022h 
  cnt2_adr EQU 0024h 
  control_adr EQU 0026h 
  cnt2_con EQU 10010110b 
  cnt2_val EQU 1Eh       ;serial (30*pclk)
  cnt1_con EQU 01110100b
  cnt1_val_low EQU  40h  ;display,time (40000*pclk=10mS)
  cnt1_val_high EQU 9Ch  ;display=x4 time=x100
  cnt0_con EQU 00110100b ;printer,lad(8000*pclk=2ms)
  cnt0_val_low EQU 40h   ;wr=x1,char=x10,cr=x100,lad=x300
  cnt0_val_high EQU 1Fh
  
  ;serial 8251a 
  serial_cnt_adr EQU 0000h ;control and status
  serial_data_adr EQU 0002h ;data
  serial_mode EQU 01001110b
  serial_com_T1R1 EQU 00110111b ;T-transmit
  serial_com_T0R1 EQU 00100110b ;R-receive
  serial_com_T0R0 EQU 00100010b
  serial_com_T1R0 EQU 00100011b
  
  ;paralel 8255
  ;keyboard port
  key_portA EQU 0008h 
  key_portB EQU 000Ah 
  key_portC EQU 000Ch 
  key_con_adr EQU 000Eh 
  key_control EQU 10000010b
  init_key_val EQU 00000000b
  scan1 EQU 00001110b
  scan2 EQU 00001101b
  scan3 EQU 00001011b
  scan4 EQU 00000111b
  mask1 EQU 00001000b
  mask2 EQU 00000100b
  mask3 EQU 00000010b
  mask4 EQU 00000001b
  ;display port 
  dis_portA EQU 0010h
  dis_portB EQU 0012h
  dis_portC EQU 0014h
  dis_cnt_adr EQU 0016h
  dis_control EQU 10000000b
  ;printer port
  print_portA EQU 0028h
  print_portB EQU 002Ah
  print_portC EQU 002Ch
  print_cnt_adr EQU 002Eh
  print_control EQU 10000000b
  start_counter EQU 10000000b
  stop_counter EQU 00000000b
  lad0wr0 EQU 00000000h
  lad0wr1 EQU 00000001h
  lad1wr0 EQU 00000010h
  lad1wr1 EQU 00000011h
  
;---------------------------------------------------------------
;	PAL16L8
;---------------------------------------------------------------
;PAL16L8 need to be programmed with shown equations
;RAM(pin 12)=/pin11*/pin9*/pin8*/pin7*/pin14
;ROM(pin 13)=pin11*pin9*pin8*pin7*pin6*pin5*/pin14*pin15
;interfaces(pin 19)=/pin11*/pin9*/pin8*/pin7*/pin6*/pin5*
; 	    */pin4*/pin3*/pin2*/pin1*pin16*pin17*
; 	    *pin18*pin14

;---------------------------------------------------------------
;	SEGMENT ADDRESSES
;---------------------------------------------------------------
  prog_seg EQU 0FC00h    	;pocetak rom-a
  interrupt_seg EQU 0000h	;pocetak ram-a
		
		
;----------------------------------------------------------------
;	MACROS
;----------------------------------------------------------------
 ;save reg
 saveReg MACRO
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
 ENDM
 
 ;restore reg
 resReg MACRO
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax	
 ENDM
 
;----------------------------------------------------------------
; 	DISPLAY CONSTANTS
;----------------------------------------------------------------
  select_seg0 EQU 00000000b
  select_seg1 EQU 00000001b
  select_seg2 EQU 00000010b
  select_seg3 EQU 00000011b
  select_seg4 EQU 00000100b
  select_seg5 EQU 00000101b
  select_seg6 EQU 00000110b
  select_seg7 EQU 00000111b
  select_seg8 EQU 00001111b
  select_seg9 EQU 00010111b
  select_seg10 EQU 00011111b
  select_seg11 EQU 00100111b
  select_seg12 EQU 00101111b
  select_seg13 EQU 00110111b
  select_seg14 EQU 00111111b
  select_seg15 EQU 01111111b
  select_seg16 EQU 10111111b
  ;null
  unselect_seg EQU 11111111b
  display_null EQU 11111111b
  ;numbers
  display0_c EQU 00011001b	;0
  display0_b EQU 10011000b
  display1_c EQU 11110111b	;1
  display1_b EQU 11101111b
  display2_c EQU 00111100b	;2
  display2_b EQU 00111100b
  display3_c EQU 00111100b	;3
  display3_b EQU 01111000b
  display4_c EQU 11011100b	;4
  display4_b EQU 01111011b
  display5_c EQU 00011110b	;5
  display5_b EQU 01111000b
  display6_c EQU 00011110b	;6
  display6_b EQU 00111000b
  display7_c EQU 00111101b	;7
  display7_b EQU 11111011b
  display8_c EQU 00011100b	;8
  display8_b EQU 00111000b
  display9_c EQU 00011100b	;9
  display9_b EQU 01111000b
  ;letters
  displayA_c EQU 00011100b	;A
  displayA_b EQU 00111011b
  displayB_c EQU 00110101b	;B
  displayB_b EQU 01101000b
  displayC_c EQU 00011111b	;C
  displayC_b EQU 10111100b
  displayD_c EQU 00110101b	;D
  displayD_b EQU 11101100b
  displayE_c EQU 00011101b	;E
  displayE_b EQU 10111100b
  displayF_c EQU 00011101b	;F
  displayF_b EQU 10111111b
  displayG_c EQU 00011111b	;G
  displayG_b EQU 00111000b
  displayH_c EQU 11011100b	;H
  displayH_b EQU 00111011b
  displayI_c EQU 00101111b	;I
  displayI_b EQU 11101100b
  displayJ_c EQU 00111101b	;J
  displayJ_b EQU 10111000b
  displayK_c EQU 11011010b	;K
  displayK_b EQU 10101111b
  displayL_c EQU 11011111b	;L
  displayL_b EQU 10101111b
  displayM_c EQU 11001001b	;M
  displayM_b EQU 10111011b
  displayN_c EQU 11001101b	;N
  displayN_b EQU 10110011b
  displayO_c EQU 00011101b	;O
  displayO_b EQU 10111000b
  displayP_c EQU 00011100b	;P
  displayP_b EQU 00111111b
  displayQ_c EQU 00011101b	;Q
  displayQ_b EQU 10110000b
  displayR_c EQU 01010110b	;R
  displayR_b EQU 10110111b
  displayS_c EQU 00011110b	;S
  displayS_b EQU 01111000b
  displayT_c EQU 00110111b	;T
  displayT_b EQU 11101111b
  displayU_c EQU 11011101b	;U
  displayU_b EQU 10111000b
  displayV_c EQU 11011011b	;V
  displayV_b EQU 10010011b
  displayW_c EQU 11011101b	;W
  displayW_b EQU 10010011b
  displayX_c EQU 11101011b	;X
  displayX_b EQU 10110111b
  displayY_c EQU 11101011b	;Y
  displayY_b EQU 11101111b	
  displayZ_c EQU 00111011b	;Z
  displayZ_b EQU 11011100b
  displayMul_c EQU 11100010b	;*
  displayMul_b EQU 01000111b
  displayDD_c EQU 11110111b	;:
  displayDD_b EQU 11101111b
  
;====================================================================================================
;************************************    RESET SEGMENT    *******************************************
;====================================================================================================
reset SEGMENT AT 0FFFF0h
  jmp FAR PTR startADR     ;program starts at 00000h
reset ENDS

	
;====================================================================================================
;**********************************    INTERRUPT SEGMENT    *****************************************
;====================================================================================================
interrupt SEGMENT AT 00000h
  ASSUME es:interrupt
  
  ; dedicaded interrupts
  divz dd ?		;0000h ul0
  trap dd ?		;0004h ul1
  nmi dd ?		;0008h ul2
  brake dd ?		;000ch ul3
  overflow dd ?	;0010h ul4
  
  ; reserved interrupts
  reserved dd 27 dup(?)	;0014h-007ch ul5-ul31
  
  ; available interrupts
  time dd ?		;0080h ul32
  counter dd ?		;0104h ul33
  keyboard dd ?	;0108h ul34
  serial dd ?		;010ah ul35
  printer dd ?		;010ch ul36
  notUsed dd 2 dup(?)	;0110h-0114h ul37,ul38
  falseInt dd ?	;0118h ul39
  
  ;other interrupts
  others dd 216 dup(?) 	;0110h-03fch ul37-ul255
interrupt ENDS
;====================================================================================================
;************************************    STACK SEGMENT    *******************************************
;====================================================================================================
stack SEGMENT word STACK 
  ASSUME ss:stack
topStack LABEL word
  db 2048 dup(?)
stack ENDS
;====================================================================================================
; ************************************    DATA SEGMENT    *******************************************
;====================================================================================================
data SEGMENT word public  	
  ASSUME ds:data
  
  ;database
  product_database db 16000 dup(?)
  end_database db 1Bh
  cur_product_offset dw 0
  
  ;inti protocol
  cur_database_ptr dw offset product_database
  data_count db 0
  time_count db 0
  protocol_phase db 0
  programming db 0
  progTime db 0
  
  ;display
  display_buffer db 34 dup(0)
  cur_buffer_ptr dw 0
  wait_str db		"   WAITING       "
  programming_str db  	"   PROGRAMMING   "
  sys_err_str db  	"ERROR NEED RESET "
  err_str db		"     ERROR       "
  sys_amount_str db	" AMOUNT          "
  sys_total_str db	" TOTAL           "
  
  ;printer
  have_paper db 1
  print_ptr dw offset current_bill
  numChar_to_print dw 0
  isPrinting db 0
  
  ;keyboard
  isAmount db 0
  isFunction db 0
  cur_amount dw 1
  cur_product_id dw 0
  cur_product_price dw 0
  data_str db "                 "  
  amount_str db "                 "
  
  ;sys lock
  error db 0
  lock_sys db 0
  isReady db 0
  ;function
  serialF0 db 0
  
  ;counter
  counter_mode db 0
  lad_cnt db 96h	;150x2mS
  char_cnt db 0Ah	;10x2mS
  cr_cnt db 64h	;100x2mS
  isLad db 0
  isChar db 0
  isCr db 0
  
  ;time
  hours db 0
  minutes db 0
  seconds db 0
  pclkSec dw 64h       ;1s
  pclkDisplay dw 04h   ;40mS
  show_clock db 0
  time_str db "                 "
  
  ;bill 
  current_bill db 512 dup(0) ;max 32 items(16B)
  cur_bill_ptr dw offset current_bill
  sending_bill db 0
  cur_item_to_send dw 0
  bill_price dw 0
  
  ;daily sales
  total dw 0
  sales_data db 14000 dup(0)
  cur_sales_ptr dw offset sales_data

data ENDS
;====================================================================================================
; ***********************************    PROGRAM SEGMENT    *****************************************
;====================================================================================================
program SEGMENT AT 0FC000h
ASSUME cs:program 
      
;#############################################################
;----------------------    INIT    ---------------------------
;#############################################################
init proc near

;-----------------------------------------------------
; 	SET SEGMENT REGISTERS
;-----------------------------------------------------
  mov ax,prog_seg
  mov cs,ax
  mov ax,interrupt_seg
  mov es,ax
  mov ax, stack 
  mov ss,ax
  mov sp, offset topStack
  mov ax, data
  mov ds,ax
  mov lock_sys,0

;-----------------------------------------------------
; 	SET INTERRUPT ROUTINES
;-----------------------------------------------------
  ; zero div
  mov ax, offset div0Interrupt 
  mov WORD PTR divz,ax
  mov ax, seg div0Interrupt
  mov WORD PTR [divz+02h],ax
  ; trap
  mov ax, offset trapInterrupt 
  mov WORD PTR trap,ax
  mov ax, seg trapInterrupt
  mov WORD PTR [trap+02h],ax
  ; nmi
  mov ax, offset nmiInterrupt 
  mov WORD PTR nmi,ax
  mov ax, seg nmiInterrupt
  mov WORD PTR [nmi+02h],ax
  ; brake point 
  mov ax, offset brakeInterrupt 
  mov WORD PTR brake,ax
  mov ax, seg brakeInterrupt
  mov WORD PTR [brake+02h],ax
  ; overflow
  mov ax, offset overflowInterrupt 
  mov WORD PTR overflow,ax
  mov ax, seg overflowInterrupt
  mov WORD PTR [overflow+02h],ax
  ; falseInterrupt
  mov ax, offset falseInterrupt 
  mov WORD PTR falseInt,ax
  mov ax, seg falseInterrupt
  mov WORD PTR [falseInt+02h],ax
  ; time
  mov ax, offset timeInterrupt 
  mov WORD PTR time,ax
  mov ax, seg timeInterrupt
  mov WORD PTR [time+02h],ax
  ; counter
  mov ax, offset counterInterrupt 
  mov WORD PTR counter,ax
  mov ax, seg counterInterrupt
  mov WORD PTR [counter+02h],ax
  ; keyboard
  mov ax, offset keyboardInterrupt 
  mov WORD PTR keyboard,ax
  mov ax, seg keyboardInterrupt
  mov WORD PTR [keyboard+02h],ax
  ; serial
  mov ax, offset serialInterrupt 
  mov WORD PTR serial,ax
  mov ax, seg serialInterrupt
  mov WORD PTR [serial+02h],ax
  ; printer
  mov ax, offset printerInterrupt 
  mov WORD PTR printer,ax
  mov ax, seg printerInterrupt
  mov WORD PTR [printer+02h],ax

;-----------------------------------------------------
;	INTERRUPT CONTROLLER 8259A
;-----------------------------------------------------
  mov al,icw1
  out icw1_adr,al
  mov al,icw2
  out icw2_adr,al
  mov al,icw4
  out icw4_adr,al
  mov al,ocw1
  out ocw1_adr,al
  
;------------------------------------------------------
;	TIMER 8254
;----------------------------------------------------- 
 mov al,cnt2_con
 out cnt2_adr,al
 mov al,cnt2_val
 out cnt2_adr,al
 mov al,cnt1_con
 out cnt1_adr,al
 mov al,cnt1_val_high
 out cnt1_adr,al
 mov al,cnt1_val_low
 out cnt1_adr,al
 mov al,cnt0_con
 out cnt0_adr,al
 mov al,cnt0_val_high
 out cnt0_adr,al
 mov al,cnt0_val_low
 out cnt0_adr,al
 
;----------------------------------------------------- 
;	PARALLEL 8255
;----------------------------------------------------- 
 ;keyboard
 mov al,key_control
 out key_con_adr,al
 mov al,init_key_val
 out key_portA,al
 ;display
 mov al,dis_control
 out dis_cnt_adr,al
 mov al,unselect_seg
 out dis_portA,al
 ;print 
 mov al,print_control
 out print_cnt_adr,al
 mov al,0h
 out print_portA,al
 out print_portB,al
 out print_portC,al
 
;----------------------------------------------------- 
;	SERIAL 8251a
;-----------------------------------------------------  
 mov al,serial_mode
 out serial_cnt_adr,al
 mov al,serial_com_T1R1
 out serial_cnt_adr,al
 
;----------------------------------------------------- 
;	DISPLAY WAIT
;----------------------------------------------------- 
  mov ax, offset wait_str
  push ax
  call fill_disply_buf
  
init endp


	
;#############################################################
;---------------   INTERRUPT ROUTINES   ----------------------
;#############################################################

;div by zero
div0Interrupt:
  iret
;trap
trapInterrupt:
  iret
;nmi
nmiInterrupt:
  iret
;brake
brakeInterrupt:
  iret
;overflow
overflowInterrupt:
  iret
;flase interrupt
falseInterrupt:
  iret
  
;*********************************************************** 
;	TIME INTERRUPT
;***********************************************************
timeInterrupt:
  saveReg

  mov ax,pclkSec
  dec ax
  mov pclkSec,ax
  cmp ax,0
  jne timeEnd
  
  
  mov pclkSec,64h
  inc seconds
  cmp seconds,60
  jne setStrLab
  
  mov BYTE PTR seconds,0
  inc minutes
  cmp minutes,60
  jne setStrLab
  
  mov BYTE PTR minutes,0
  inc hours
  cmp hours,24
  jne setStrLab
  mov BYTE PTR hours,0
  
setStrLab:
 cmp show_clock,0
 je timeEnd
 call time_to_string
 mov ax,offset time_str
 push ax
 call fill_disply_buf
    
timeEnd:
 mov ax,pclkDisplay
 dec ax
 cmp ax,0
 jne skipDisRefLab
 mov pclkDisplay,04h
 call display_refresh
 jmp tiEnd
skipDisRefLab:
  mov pclkDisplay,ax
  
tiEnd: 
 mov al,eoi0_command
 out ocw2_adr,al
 resReg
 iret
  
;***********************************************************
;	COUNTER INTERRUPT
;***********************************************************
counterInterrupt:
  saveReg
  sti
  
;lad operations
  cmp isLad,1
  jne cntModeLab
  dec lad_cnt
  cmp lad_cnt,0
  jne cntModeLab
  mov lad_cnt,96h
  ;unlock keyboard
  mov al,unlockKeyboard
  out ocw1_adr,al
  cmp isPrinting,1
  je ladSkipLab
  mov al,lad0wr0
  out print_portB, al
  mov al,stop_counter
  out cnt0_adr,al
  jmp cntModeLab
ladSkipLab:
  mov al,lad0wr1
  out print_portB, al

  
cntModeLab:
  cmp have_paper,0
  je printErrLab
  cmp counter_mode,1
  je mode1Lab
  cmp counter_mode,2
  je mode2Lab
  cmp counter_mode,3 
  je mode3Lab
  jmp ciEnd
  
printErrLab:
    ;no paper error
  mov isPrinting,0
  cmp isLad,1
  je pesLab
  mov al,lad0wr0
  out print_portB,al
  mov al,stop_counter
  out cnt0_adr,al
  mov counter_mode,1
  mov print_ptr,0
  jmp ciEnd
pesLab:
  mov al,lad1wr0
  out print_portB,al
  mov counter_mode,1
  mov print_ptr,0
  jmp ciEnd
  
mode1Lab:
  ;move char and start print
  mov bx,print_ptr
  mov al,[bx]
  inc bx
  mov print_ptr,bx
  out print_portA,al
  ;start print
  cmp isLad,1
  je wrStartLab
  mov al,lad0wr1
  out print_portB,al
  mov counter_mode,2
  jmp ciEnd
wrStartLab:
  mov al,lad1wr1
  out print_portB,al
  mov counter_mode,2
  jmp ciEnd
  
mode2Lab:
  ;stop print and set wait
  cmp isLad,1
  je wrStopLab
  mov al,lad0wr0
  out print_portB,al
  jmp wrSkipLab
wrStopLab:
  mov al,lad1wr0
  out print_portB,al
wrSkipLab:
  mov bx,print_ptr
  dec bx
  cmp BYTE PTR [bx],0Dh
  je crLab
  mov isChar,1
  jmp skipCrLab
crLab:
  mov isCr,1
skipCrLab:
  mov counter_mode,3
  jmp ciEnd
  
mode3Lab:
  ;set counters and waiting
  cmp isCr,1
  jne charLab
  dec cr_cnt
  cmp cr_cnt,0
  jne ciEnd
  mov cr_cnt,64h
  jmp chModeLab  
charLab:
  dec char_cnt
  cmp char_cnt,0
  jne ciEnd
  mov char_cnt,0Ah
  jmp chModeLab
  
chModeLab:
  mov bx,print_ptr
  dec bx
  cmp bx,1Bh
  je endPrintLab
  dec numChar_to_print
  cmp numChar_to_print,0
  jne gotoM1Lab
endPrintLab:
  mov counter_mode,0
  mov print_ptr,offset current_bill
  mov isPrinting,0
  mov al,ocw1
  out ocw1_adr,al
  cmp isLad,1
  je ciEnd
  mov al,stop_counter
  out print_portC,al
  jmp ciEnd
gotoM1Lab:
  mov counter_mode,1
  
ciEnd:
  mov al,eoi1_command
  out ocw2_adr,al
  resReg
  iret  
  
;*********************************************************** 
;	KEYBOARD INTERRUPT
;***********************************************************
keyboardInterrupt:
  saveReg
  xor bx,bx
  xor dx,dx
  sti
;---------------------
; find pressed key 
;--------------------
  ; ROW 1
  mov al, scan1
  out key_portA,al
  in al,key_portB
  test al,mask1
  jnz skip1
  mov bl,00000111b
  jmp numLab
skip1:
  test al,mask2
  jnz skip2
  mov bl,00001000b
  jmp numLab
skip2:
  test al,mask3
  jnz skip3
  mov bl,00001001b
  jmp numLab
skip3:
  test al,mask4
  jnz skip4
  mov bl,'F'
  jmp FLab
skip4:
  ;ROW 2
  mov al, scan2
  out key_portA,al
  in al,key_portB
  test al,mask1
  jnz skip5
  mov bl,00000100b
  jmp numLab
skip5:
  test al,mask2
  jnz skip6
  mov bl,00000101b
  jmp numLab
skip6:
  test al,mask3
  jnz skip7
  mov bl,00000110b
  jmp numLab
skip7:
  test al,mask4
  jnz skip8
  mov bl,'C'
  jmp CLab
skip8:
  ;ROW 3
  mov al, scan3
  out key_portA,al
  in al,key_portB
  test al,mask1
  jnz skip9
  mov bl,00000001b
  jmp numLab
skip9:
  test al,mask2
  jnz skip10
  mov bl,00000010b
  jmp numLab
skip10:
  test al,mask3
  jnz skip11
  mov bl,00000011b
  jmp numLab
skip11:
  test al,mask4
  jnz skip12
  mov bl,'+'
  jmp plusLab
skip12:
  ;ROW 4
  mov al, scan4
  out key_portA,al
  in al,key_portB
  test al,mask1
  jnz skip13
  mov bl,'#'
  jmp minusLab
skip13:
  test al,mask2
  jnz skip14
  mov bl,00000000b
  jmp numLab
skip14:
  test al,mask3
  jnz skip15
  mov bl,'*'
  jmp mulLab
skip15:
  test al,mask4
  jnz skip16
  mov bl,'='
  jmp equLab
skip16:
  ;noise
  mov al,eoi2_command
  out ocw2_adr,al
  iret
  
;------------------------
;   logic
;------------------------

numLab:
      cmp error,1
      je keyEnd
      cmp isFunction,1
      je funcLab
      cmp isAmount,1
      je amountLab
      
      mov ax,cur_product_id
      mov dl,0Ah
      mul dl
      add ax,bx
      mov cur_product_id,ax
      mov dx,10h
      mul dx
      mov bx,ax
      mov cur_product_offset,bx
      
      ;display product
        ;move name to data_str
      mov show_clock,0
      mov ax,ds
      push ax	;segment
      mov ax,0Ch
      push ax	;length 12
      mov ax,offset data_str
      push ax	;dst offset
      mov ax,offset product_database
      add bx,ax
      push bx ;src offset
      call copy_string 
        ;price is moved to data_str
      add bx,0Ch
      mov ax,[bx]
      mov cur_product_price,ax
      mov dx,ds
      push dx ;segment
      mov dx,offset data_str
      add dx,10h ;last location
      push dx ;offset
      push ax ;price
      call value_to_string
        ;prepare buffer
      mov ax,offset data_str
      push ax
      call fill_disply_buf
      jmp keyEnd
      
amountLab:
      mov ax,cur_amount
      mov dl,0Ah
      mul dl
      add bx,ax 
      mov cur_amount,bx
      
      ;display amount
        ;cur_amount to amount_str
      mov show_clock,0
      mov si, offset amount_str
      add si,05h ;last location
      mov ax,ds
      push ax ;segment
      push si ;offset
      push bx ;value
      call value_to_string
        ;cur_price to amount_str
      add si,0Bh ;last location
      push ax ;segment
      push si ;offset
      mov ax,cur_product_price
      mul bx
      push ax ;val
      call value_to_string
      mov ax,offset amount_str
      push ax
      call fill_disply_buf
      jmp keyEnd

funcLab:
      cmp bl,0
      je func0
      cmp bl,1
      je func1
      cmp bl,2
      je func2
      cmp bl,3
      je func3
      jmp keyEnd
      
func0:
     call setup_sales_data
     mov ax,offset sales_data
     mov cur_item_to_send,ax
     mov numChar_to_print,16000
      ;start transfer
     mov al,serial_com_T1R0
     out serial_cnt_adr,al
      ;lock keyboard interrupt
     mov al,lockKeyboard
     out ocw1_adr,al
      ;set flags
     mov show_clock,1
     jmp keyEnd
      
func1:
     call setup_sales_data
     mov ax,offset sales_data
     mov print_ptr,ax
     mov numChar_to_print,16000
     mov al,start_counter
     out print_portC,al
     ;lock keyboard interrupt
     mov al,lockKeyboard
     out ocw1_adr,al
     ;set flags
     mov show_clock,1
     jmp keyEnd
func2:
      ;display total
      mov bx, offset sys_total_str
      add bx,0Fh ;last location
      mov ax,ds
      push ax ;segment
      push bx ;offset
      mov ax,total
      push ax ;value
      call value_to_string
      mov ax, offset sys_total_str
      push ax
      call fill_disply_buf
      jmp keyEnd
func3:
      ;open lad and start counter
      mov isLad,1
      mov al,start_counter
      out print_portC,al
      cmp isPrinting,1
      je ladSkip3Lab
      mov al,lad1wr0
      out print_portB, al
      jmp keyEnd
ladSkip3Lab:
      mov al,lad1wr1
      out print_portB, al
      jmp keyEnd
      
plusLab:
      cmp error,1
      je keyEnd
      mov bx,offset product_database
      mov si,cur_product_offset
      add bx,si
       ;move name to bill_buf
      mov ax,ds
      push ax	;segment
      mov ax,0Ch
      push ax	;length 12
      mov ax, cur_bill_ptr
      push ax	;dst offset
      add ax,0Ch
      mov cur_bill_ptr,ax
      push bx ;src offset
      call copy_string
        ;modify bill_price
      mov ax,cur_product_price
      mov dx,cur_amount
      mul dx
      mov dx,bill_price
      add dx,ax
      mov bill_price,dx
       ;inc total
      mov dx,total
      add dx,ax
      mov total,dx
       ;move product price to bill_buf
      mov dx,ds
      push dx ;segment
      mov si,cur_bill_ptr
      add si,05h
      push si ;offset
      push ax ;price
      call value_to_string 
       ;new line
      mov BYTE PTR [si],0Dh
      inc si
      mov BYTE PTR [si],0Ah
      inc si
      mov cur_bill_ptr,si
       ;inc sold number
      add bx,0Eh
      mov ax,[bx]
      mov dx,cur_amount
      add ax,dx
      mov [bx],ax
       ;reset values
      mov cur_amount,0
      mov cur_product_id,0
      mov cur_product_offset,0
      mov cur_product_price, 0
       ;set display
      mov bx, offset sys_amount_str
      add bx,0Fh ;last location
      mov ax,ds
      push ax ;segment
      push bx ;offset
      mov ax,bill_price
      push ax ;value
      call value_to_string
      mov ax, offset sys_amount_str
      push ax
      call fill_disply_buf
       ;printing
      mov ax,numChar_to_print
      add ax,13h
      mov numChar_to_print,ax
      cmp isPrinting,1
      je keyEnd
      mov isPrinting,1
      mov print_ptr,offset current_bill
      mov counter_mode,1 ;mode 1-put data and wr=1
      mov al,start_counter ;start counter
      out print_portC,al
      jmp keyEnd

minusLab:
      cmp error,1
      je keyEnd
       ;put '-' to bill
      mov bx,cur_bill_ptr
      mov BYTE PTR [bx],'-'
      inc bx
      mov cur_bill_ptr,bx
      mov bx,offset product_database
      mov si,cur_product_offset
      add bx,si
      mov ax,ds
       ;move name to bill_buf
      push ax	;segment
      mov ax,0Ch
      push ax	;length 12
      mov ax, cur_bill_ptr
      push ax	;dst offset
      add ax,0Ch
      mov cur_bill_ptr,ax
      push bx ;src offset
      call copy_string
       ;modify bill_price
      mov ax,cur_product_price
      mov dx,cur_amount
      mul dx
      mov dx,bill_price
      add dx,ax
      mov bill_price,dx
       ;dec total
      mov dx,total
      sub dx,ax
      mov total,dx
       ;move product price to bill_buf 
      mov dx,ds
      push dx ;segment
      mov si,cur_bill_ptr
      add si,05h
      push si ;offset
      push ax ;price
      call value_to_string 
       ;new line
      mov BYTE PTR [si],0Dh
      inc si
      mov BYTE PTR [si],0Ah
      inc si
      mov cur_bill_ptr,si
       ;dec sold number
      add bx,0Eh
      mov ax,[bx]
      mov dx,cur_amount
      sub ax,dx
      mov [bx],ax
       ;reset values
      mov cur_amount,0
      mov cur_product_id,0
      mov cur_product_offset,0
      mov cur_product_price, 0
       ;set display
      mov bx, offset sys_amount_str
      add bx,0Fh ;last location
      mov ax,ds
      push ax ;segment
      push bx ;offset
      mov ax,bill_price
      push ax ;value
      call value_to_string
      mov ax, offset sys_amount_str
      push ax
      call fill_disply_buf
      jmp keyEnd
       ;printing
      mov ax,numChar_to_print
      add ax,14h
      mov numChar_to_print,ax
      cmp isPrinting,1
      je keyEnd
      mov print_ptr,offset current_bill
      mov isPrinting,1
      mov counter_mode,1 
      mov al,start_counter ;start counter
      out print_portC,al
      jmp keyEnd
      
equLab:
      cmp error,1
      je keyEnd
       ;prepare for print
      mov al,'='
      mov si,cur_bill_ptr
      mov cx,0Ah
equLoop:
      mov BYTE PTR [si],al
      inc si
      loop equLoop
      mov BYTE PTR [si],0Dh
      inc si
      mov BYTE PTR [si],0Ah
      inc si
       ;put total price 
      mov ax,ds
      push ds ;seg
      push si ;off
      mov ax,bill_price
      push ax ;val
      call value_to_string
      mov BYTE PTR [si],1Bh ;escape
       ;reset values
      mov cur_bill_ptr,0
      mov bill_price,0
      mov isReady,1
      ;display clock
      mov show_clock,1
       ;open lad and start counter
      mov isLad,1
      mov al,start_counter
      out print_portC,al
      cmp isPrinting,1
      je ladSkip1Lab
      mov al,lad1wr0
      out print_portB, al
      jmp ladSkip2Lab
ladSkip1Lab:
      mov al,lad1wr1
      out print_portB, al
ladSkip2Lab:      
       ;printing
      mov ax,numChar_to_print
      add ax,11h
      mov numChar_to_print,ax
      cmp isPrinting,1
      je keyEnd
      mov isPrinting,1
      mov counter_mode,1 
      mov al,start_counter ;start counter
      out print_portC,al
      jmp keyEnd
      
FLab:
    cmp error,1
    je keyEnd
    cmp isReady,1
    jne errorLab
    mov isFunction,1
    jmp keyEnd

CLab:
    mov isFunction,0
    mov cur_product_id,0
    mov cur_amount,1
    mov isAmount,0
    mov show_clock,1
    jmp keyEnd
  
mulLab:
    cmp error,1
    je keyEnd
    mov isAmount,1
    jmp keyEnd
    
errorLab:
    mov error,1
    mov ax,offset err_str
    push ax
    call fill_disply_buf
    
    
keyEnd:
  mov al, 0h
  out key_portA,al
  mov al,eoi2_command
  out ocw2_adr,al 
 iret
  

;*********************************************************
;	SERIAL INTERRUPT
;*********************************************************
serialInterrupt:
  saveReg
  sti
  
  cmp serialF0,1
  je F0Lab
  
  mov bx,offset product_database
  mov si,offset cur_database_ptr
  
  cmp protocol_phase,3
  je phase3
  cmp protocol_phase,2
  je phase2
  cmp protocol_phase,1
  je phase1
  cmp protocol_phase,0
  je phase0
  je siEnd
  
phase0:
  ;start database init protocol
  ;transmit to PC SYN character 
  mov al,16h
  out serial_data_adr,al
  mov al,protocol_phase
  inc al
  mov protocol_phase,al
  jmp siEnd
phase1:
  ;turn off transmit
  mov al,serial_com_T0R1
  out serial_cnt_adr,al
  mov al,protocol_phase
  inc al
  mov protocol_phase,al
  jmp siEnd
phase2:
  ;receive SYN
  in al,serial_data_adr
  cmp al,16h
  jne siErr
  mov al,protocol_phase
  inc al
  mov protocol_phase,al
  push si
  mov ax,offset programming_str
  push ax
  call fill_disply_buf
  jmp siEnd
phase3:
  ;programming
  in al,serial_data_adr
  cmp progTime,1
  je timeLab
  cmp al,1bh
  je startTimeLab
  cmp data_count,11
  jle nameLab
  cmp data_count,13
  jle priceLab
   
nameLab:
  mov [bx+si],al
  inc si
  mov cur_database_ptr,si
  inc data_count
  jmp siEnd  
priceLab:
  mov [bx+si],al
  inc si
  mov cur_database_ptr,si
  cmp data_count,13
  je priceClearLab
  inc data_count
  jmp siEnd
  
priceClearLab:
  mov data_count,0
  mov BYTE PTR [bx+si],0
  inc si
  mov BYTE PTR [bx+si],0
  inc si
  mov cur_database_ptr,si
  jmp siEnd
  
startTimeLab:
  cmp data_count,0
  jne siErr
  mov progTime,1
  jmp siEnd
  
timeLab:
  mov bl,time_count
  cmp bl,0
  je hoursLab
  cmp bl,1
  je minutesLab
  cmp bl,2
  je secondsLab
  
hoursLab:
  mov hours,al
  inc bl
  mov time_count,bl
  jmp siEnd
minutesLab:
  mov minutes,al
  inc bl
  mov time_count,bl
  jmp siEnd
secondsLab:
  mov seconds,al
  inc bl
  mov time_count,bl
  mov al,serial_com_T0R0
  out serial_cnt_adr,al
  mov cur_database_ptr,0
  jmp siEnd
 
F0Lab: 
  mov bx,cur_item_to_send
  mov al,ds:[bx]
  inc bx
  mov cur_item_to_send,bx
  cmp al,1bh; escape like end 
  jne send
  mov al,serial_com_T0R0
  out serial_cnt_adr,al
  ;unmask keyboard interrupt
  mov al,ocw1
  out ocw1_adr,al
  ;reset flags
  mov cur_bill_ptr,0
  mov sending_bill,0
  jmp siEnd
send:
  out serial_data_adr,al
  jmp siEnd
  
siErr:
  mov ax, offset sys_err_str
  push ax
  call fill_disply_buf
  mov lock_sys,1
      
siEnd:
  mov al,eoi3_command
  out ocw2_adr,al
  resReg
  iret

;*********************************************************
;	PRINTER INTERRUPT
;*********************************************************
printerInterrupt:
 mov have_paper,0
 mov al,eoi4_command
 out ocw2_adr,al
 iret

;====================================================================================================
;***********************************    UTILITY FUNCTIONS    ****************************************
;====================================================================================================

;#############################################################
;   arg0: offset of src string (word) 
;   arg1: offset of dst string (word)
;   arg2: length (word)
;   arg3: segment (word)
;#############################################################
copy_string proc near
 push bp
 mov bp,sp
 saveReg
 
 mov si,WORD PTR [bp+04h]
 mov ds,WORD PTR [bp+1Ah]
 mov di,WORD PTR [bp+06h]
 mov es,WORD PTR [bp+1Ah] 
 mov cx,WORD PTR [bp+08h]
 
 cld
 rep movsb
 
 resReg
 pop bp
 ret 08h
copy_string endp
;############################################################# 


;#############################################################
;	arg0: offset of string 
;	-string must have 17 bytes
;############################################################# 
fill_disply_buf proc near
  push bp
  mov bp,sp
  
  push si
  push di
  push cx
  
  mov si,[bp+04h];
  mov di, offset display_buffer
  mov cx,17
petlja:
  cmp BYTE PTR ds:[si],'0'
  je LAB_0
  cmp BYTE PTR ds:[si],'1'
  je LAB_1
  cmp BYTE PTR ds:[si],'2'
  je LAB_2
  cmp BYTE PTR ds:[si],'3'
  je LAB_3
  cmp BYTE PTR ds:[si],'4'
  je LAB_4
  cmp BYTE PTR ds:[si],'5'
  je LAB_5
  cmp BYTE PTR ds:[si],'6'
  je LAB_6
  cmp BYTE PTR ds:[si],'7'
  je LAB_7
  cmp BYTE PTR ds:[si],'8'
  je LAB_8
  cmp BYTE PTR ds:[si],'9'
  je LAB_9
  cmp BYTE PTR ds:[si],'A'
  je LAB_A
  cmp BYTE PTR ds:[si],'B'
  je LAB_B  
  cmp BYTE PTR ds:[si],'C'
  je LAB_C 
  cmp BYTE PTR ds:[si],'D'
  je LAB_D  
  cmp BYTE PTR ds:[si],'E'
  je LAB_E
  cmp BYTE PTR ds:[si],'F'
  je LAB_F
  cmp BYTE PTR ds:[si],'G'
  je LAB_G
  cmp BYTE PTR ds:[si],'H'
  je LAB_H
  cmp BYTE PTR ds:[si],'I'
  je LAB_I
  cmp BYTE PTR ds:[si],'J'
  je LAB_J
  cmp BYTE PTR ds:[si],'K'
  je LAB_K
  cmp BYTE PTR ds:[si],'L'
  je LAB_L
  cmp BYTE PTR ds:[si],'M'
  je LAB_M
  cmp BYTE PTR ds:[si],'N'
  je LAB_N
  cmp BYTE PTR ds:[si],'O'
  je LAB_O
  cmp BYTE PTR ds:[si],'P'
  je LAB_P
  cmp BYTE PTR ds:[si],'Q'
  je LAB_Q
  cmp BYTE PTR ds:[si],'R'
  je LAB_R
  cmp BYTE PTR ds:[si],'S'
  je LAB_S
  cmp BYTE PTR ds:[si],'T'
  je LAB_T
  cmp BYTE PTR ds:[si],'U'
  je LAB_U
  cmp BYTE PTR ds:[si],'V'
  je LAB_V
  cmp BYTE PTR ds:[si],'W'
  je LAB_W
  cmp BYTE PTR ds:[si],'X'
  je LAB_X
  cmp BYTE PTR ds:[si],'Y'
  je LAB_Y
  cmp BYTE PTR ds:[si],'Z'
  je LAB_Z
  cmp BYTE PTR ds:[si],' '
  je LAB_SPACE
  cmp BYTE PTR ds:[si],'*'
  je LAB_MUL 
  cmp BYTE PTR ds:[si],':'
  je LAB_DD 
  
LAB_0:
      mov BYTE PTR ds:[di],display0_b
      inc di
      mov BYTE PTR ds:[di],display0_c
      inc di
LAB_1:
      mov BYTE PTR ds:[di],display1_b
      inc di
      mov BYTE PTR ds:[di],display1_c
      inc di
LAB_2:
      mov BYTE PTR ds:[di],display2_b
      inc di
      mov BYTE PTR ds:[di],display2_c
      inc di
LAB_3:
      mov BYTE PTR ds:[di],display3_b
      inc di
      mov BYTE PTR ds:[di],display3_c
      inc di
LAB_4:
      mov BYTE PTR ds:[di],display4_b
      inc di
      mov BYTE PTR ds:[di],display4_c
      inc di
LAB_5:
      mov BYTE PTR ds:[di],display5_b
      inc di
      mov BYTE PTR ds:[di],display5_c
      inc di
LAB_6:
      mov BYTE PTR ds:[di],display6_b
      inc di
      mov BYTE PTR ds:[di],display6_c
      inc di
LAB_7:
      mov BYTE PTR ds:[di],display7_b
      inc di
      mov BYTE PTR ds:[di],display7_c
      inc di
LAB_8:
      mov BYTE PTR ds:[di],display8_b
      inc di
      mov BYTE PTR ds:[di],display8_c
      inc di
LAB_9:
      mov BYTE PTR ds:[di],display9_b
      inc di
      mov BYTE PTR ds:[di],display9_c
      inc di
LAB_A:
      mov BYTE PTR ds:[di],displayA_b
      inc di
      mov BYTE PTR ds:[di],displayA_c
      inc di
LAB_B:
      mov BYTE PTR ds:[di],displayB_b
      inc di
      mov BYTE PTR ds:[di],displayB_c
      inc di
LAB_C:
      mov BYTE PTR ds:[di],displayC_b
      inc di
      mov BYTE PTR ds:[di],displayC_c
      inc di
LAB_D:
      mov BYTE PTR ds:[di],displayD_b
      inc di
      mov BYTE PTR ds:[di],displayD_c
      inc di
LAB_E:
      mov BYTE PTR ds:[di],displayE_b
      inc di
      mov BYTE PTR ds:[di],displayE_c
      inc di
LAB_F:
      mov BYTE PTR ds:[di],displayF_b
      inc di
      mov BYTE PTR ds:[di],displayF_c
      inc di
LAB_G:
      mov BYTE PTR ds:[di],displayG_b
      inc di
      mov BYTE PTR ds:[di],displayG_c
      inc di
LAB_H:
      mov BYTE PTR ds:[di],displayH_b
      inc di
      mov BYTE PTR ds:[di],displayH_c
      inc di
LAB_I:
      mov BYTE PTR ds:[di],displayI_b
      inc di
      mov BYTE PTR ds:[di],displayI_c
      inc di
LAB_J:
      mov BYTE PTR ds:[di],displayJ_b
      inc di
      mov BYTE PTR ds:[di],displayJ_c
      inc di
LAB_K:
      mov BYTE PTR ds:[di],displayK_b
      inc di
      mov BYTE PTR ds:[di],displayK_c
      inc di
LAB_L:
      mov BYTE PTR ds:[di],displayL_b
      inc di
      mov BYTE PTR ds:[di],displayL_c
      inc di
LAB_M:
      mov BYTE PTR ds:[di],displayM_b
      inc di
      mov BYTE PTR ds:[di],displayM_c
      inc di
LAB_N:
      mov BYTE PTR ds:[di],displayN_b
      inc di
      mov BYTE PTR ds:[di],displayN_c
      inc di
LAB_O:
      mov BYTE PTR ds:[di],displayO_b
      inc di
      mov BYTE PTR ds:[di],displayO_c
      inc di
LAB_P:
      mov BYTE PTR ds:[di],displayP_b
      inc di
      mov BYTE PTR ds:[di],displayP_c
      inc di
LAB_Q:
      mov BYTE PTR ds:[di],displayQ_b
      inc di
      mov BYTE PTR ds:[di],displayQ_c
      inc di
LAB_R:
      mov BYTE PTR ds:[di],displayR_b
      inc di
      mov BYTE PTR ds:[di],displayR_c
      inc di
LAB_S:
      mov BYTE PTR ds:[di],displayS_b
      inc di
      mov BYTE PTR ds:[di],displayS_c
      inc di
LAB_T:
      mov BYTE PTR ds:[di],displayT_b
      inc di
      mov BYTE PTR ds:[di],displayT_c
      inc di
LAB_U:
      mov BYTE PTR ds:[di],displayU_b
      inc di
      mov BYTE PTR ds:[di],displayU_c
      inc di
LAB_V:
      mov BYTE PTR ds:[di],displayV_b
      inc di
      mov BYTE PTR ds:[di],displayV_c
      inc di
LAB_W:
      mov BYTE PTR ds:[di],displayW_b
      inc di
      mov BYTE PTR ds:[di],displayW_c
      inc di
LAB_X:
      mov BYTE PTR ds:[di],displayX_b
      inc di
      mov BYTE PTR ds:[di],displayX_c
      inc di
LAB_Y:
      mov BYTE PTR ds:[di],displayY_b
      inc di
      mov BYTE PTR ds:[di],displayY_c
      inc di
LAB_Z:
      mov BYTE PTR ds:[di],displayZ_b
      inc di
      mov BYTE PTR ds:[di],displayZ_c
      inc di
LAB_SPACE:
      mov BYTE PTR ds:[di],display_null
      inc di
      mov BYTE PTR ds:[di],display_null
      inc di
LAB_MUL:
      mov BYTE PTR ds:[di],displayMul_b
      inc di
      mov BYTE PTR ds:[di],displayMul_c
      inc di
LAB_DD:
      mov BYTE PTR ds:[di],displayDD_b
      inc di
      mov BYTE PTR ds:[di],displayDD_c
      inc di
      
      inc si
      dec cx
      jnz petlja
      
      pop cx
      pop di
      pop si
      pop bp
      retn 02h
fill_disply_buf endp
;#############################################################


;############################################################# 
;   	refresh display to show new value
;               from display_buffer
;############################################################# 
display_refresh proc near 
  push ax
  push bx
  push cx
  push si
    
  ;display buffer 
  mov bx,offset display_buffer
  xor si,si
  ;seg 0
  mov al,[bx+si]
  out dis_portB,al
  inc si
  mov al,[bx+si]
  out dis_portC,al
  inc si
  mov al,select_seg0
  out dis_portA,al
  ;seg 1
  mov al,[bx+si]
  out dis_portB,al
  inc si
  mov al,[bx+si]
  out dis_portC,al
  inc si
  mov al,select_seg1
  out dis_portA,al
  ;seg 2
  mov al,[bx+si]
  out dis_portB,al
  inc si
  mov al,[bx+si]
  out dis_portC,al
  inc si
  mov al,select_seg2
  out dis_portA,al
  ;seg 3
  mov al,[bx+si]
  out dis_portB,al
  inc si
  mov al,[bx+si]
  out dis_portC,al
  inc si
  mov al,select_seg3
  out dis_portA,al
  ;seg 4
  mov al,[bx+si]
  out dis_portB,al
  inc si
  mov al,[bx+si]
  out dis_portC,al
  inc si
  mov al,select_seg4
  out dis_portA,al
  ;seg 5
  mov al,[bx+si]
  out dis_portB,al
  inc si
  mov al,[bx+si]
  out dis_portC,al
  inc si
  mov al,select_seg5
  out dis_portA,al
  ;seg 6
  mov al,[bx+si]
  out dis_portB,al
  inc si
  mov al,[bx+si]
  out dis_portC,al
  inc si
  mov al,select_seg6
  out dis_portA,al
  ;seg 7
  mov al,[bx+si]
  out dis_portB,al
  inc si
  mov al,[bx+si]
  out dis_portC,al
  inc si
  mov al,select_seg7
  out dis_portA,al
  ;seg 8
  mov al,[bx+si]
  out dis_portB,al
  inc si
  mov al,[bx+si]
  out dis_portC,al
  inc si
  mov al,select_seg8
  out dis_portA,al
  ;seg 9
  mov al,[bx+si]
  out dis_portB,al
  inc si
  mov al,[bx+si]
  out dis_portC,al
  inc si
  mov al,select_seg9
  out dis_portA,al
  ;seg 10
  mov al,[bx+si]
  out dis_portB,al
  inc si
  mov al,[bx+si]
  out dis_portC,al
  inc si
  mov al,select_seg10
  out dis_portA,al
  ;seg 11
  mov al,[bx+si]
  out dis_portB,al
  inc si
  mov al,[bx+si]
  out dis_portC,al
  inc si
  mov al,select_seg11
  out dis_portA,al
  ;seg 12
  mov al,[bx+si]
  out dis_portB,al
  inc si
  mov al,[bx+si]
  out dis_portC,al
  inc si
  mov al,select_seg12
  out dis_portA,al
  ;seg 13
  mov al,[bx+si]
  out dis_portB,al
  inc si
  mov al,[bx+si]
  out dis_portC,al
  inc si
  mov al,select_seg13
  out dis_portA,al
  ;seg 14
  mov al,[bx+si]
  out dis_portB,al
  inc si
  mov al,[bx+si]
  out dis_portC,al
  inc si
  mov al,select_seg14
  out dis_portA,al
  ;seg 15
  mov al,[bx+si]
  out dis_portB,al
  inc si
  mov al,[bx+si]
  out dis_portC,al
  inc si
  mov al,select_seg15
  out dis_portA,al
  ;seg 16
  mov al,[bx+si]
  out dis_portB,al
  inc si
  mov al,[bx+si]
  out dis_portC,al
  inc si
  mov al,select_seg16
  out dis_portA,al
  
  ;switch off
  mov al,unselect_seg
  out dis_portA,al

  pop si
  pop cx
  pop bx
  pop ax
  retn
display_refresh endp
;############################################################# 


;############################################################# 
;	time to string
;         "  h1h0 : m1mo : s1s0   "
;############################################################# 
time_to_string proc near
  push ax
  push bx
  push cx
  push si
  
  xor si,si
  xor ax,ax
  
  mov BYTE PTR [time_str+si],' '
  inc si
  mov BYTE PTR [time_str+si],' '
  inc si
  ;hours
  mov al,hours
  mov cl,0Ah
  div cl
  mov bl,al
  sub bl,'0'
  mov BYTE PTR [time_str+si],bl
  inc si
  mov bl,ah
  sub bl,'0'
  mov BYTE PTR [time_str+si],bl
  inc si
  mov BYTE PTR [time_str+si],' '
  inc si
  mov BYTE PTR [time_str+si],':'
  inc si
  mov BYTE PTR [time_str+si],' '
  inc si
  ;minutes
  mov al,minutes
  mov cl,0Ah
  div cl
  mov bl,al
  sub bl,'0'
  mov BYTE PTR [time_str+si],bl
  inc si
  mov bl,ah
  sub bl,'0'
  mov BYTE PTR [time_str+si],bl
  inc si
  mov BYTE PTR [time_str+si],' '
  inc si
  mov BYTE PTR [time_str+si],':'
  inc si
  mov BYTE PTR [time_str+si],' '
  inc si
  ;seconds
  mov al,minutes
  mov cl,0Ah
  div cl
  mov bl,al
  sub bl,'0'
  mov BYTE PTR [time_str+si],bl
  inc si
  mov bl,ah
  sub bl,'0'
  mov BYTE PTR [time_str+si],bl
  inc si
  mov BYTE PTR [time_str+si],' '
  inc si
  mov BYTE PTR [time_str+si],' '
  inc si
  cmp sending_bill,1
  je starLab
  mov BYTE PTR [time_str+si],' '
  jmp notStarLab
starLab:
  mov BYTE PTR [time_str+si],'*'
notStarLab:

  pop si
  pop cx
  pop bx
  pop ax
  retn
time_to_string endp
;############################################################# 


;############################################################# 
;	       int to string
;	arg0: value (word)
;	arg1: destination offset (last location)
;	arg2: destination segment
;############################################################# 
value_to_string proc near
  push bp
  mov bp,sp
  saveReg
  
  mov ax,[bp+02h]
  mov di,[bp+04h]
  mov bx,[bp+06h]
  mov ds,bx
  mov cx,0Ah
  mov si,05h
  
convert:
  xor dx,dx
  div cx
  add dl,'0'
  mov ds:[di],dl
  dec di
  dec si
  cmp ax,0
  jne convert
  
le5Lab:
  cmp si,0
  je conEnd
  mov BYTE PTR ds:[di],' '
  dec di
  dec si
  jmp le5Lab
  
conEnd:
  resReg
  pop bp
  retn 06h
value_to_string endp
;############################################################# 


;############################################################# 
; 	setup sales data
;############################################################# 
setup_sales_data proc near
  saveReg
  
  mov bx,offset product_database
  xor si,si
  mov di,14
  mov cx,1000
  xor dx,dx
setupLoop:
  mov ax,[bx+di]
  cmp ax,0
  je skipSetupLab
  mov WORD PTR [bx+di],0
  mov dx,ds
  push dx ;seg for next func
  push dx ;seg 
  mov dx,0Ch
  push dx ;length
  mov dx,cur_sales_ptr
  push dx ;dst
  push si ;src
  call copy_string ;copy name 
  add dx,0Ch
  push dx
  push ax
  call value_to_string ;copy num of sales
  add dx,05h
  mov cur_sales_ptr,dx
skipSetupLab:
  add si,10h
  add di,10h
  loop setupLoop
  mov bx,dx
  mov BYTE PTR [bx],1Bh
  
  mov cur_sales_ptr,offset sales_data
  resReg
setup_sales_data endp
;############################################################# 


;====================================================================================================
;**************************************    MAIN    **************************************************
;====================================================================================================
startADR:
  cli
  ; inti system
  call init
  sti
  
labStart:
  nop
  cmp lock_sys,0
  je labStart
  cli
labLock:
  nop ;system error detected 
  jmp labLock
	
program ENDS

END startADR

