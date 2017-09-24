#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0000h#
#SP=FFFEh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#

jmp st1; 3 bytes 
nop; 1 bytes 
dw 2 dup(0) ; 4 bytes
dw nmi_
dw 0000h
db 500 dup(0)

dw 0000h
dw 0000h
db 508 dup(0)


st1: cli
; intialize ds, es,ss to start of RAM
mov       ax,0200h
mov       ds,ax
mov       es,ax
mov       ss,ax
mov       sp,0FFFEH

; 8255_1 with 7447 and has buttdls on port c. porta minutes and portb second; max value is 59:59
; greater than equal to thing..
; 8255_1 starting address 60h

porta1 equ 60h
portb1 equ 62h
portc1 equ 64h ; verified.
creg11 equ 66h 

mov al, 89h ; 1000 1001 porta and portb are both output and portc is input  for first 8255.
out creg11, al



mov al, 00
out porta1, al
out portb1, al

;8255_1 init done.

;8255_2 with output things like led-pc0, buzzer-pc1, motor-pc3 and all. Only portc will be used.
;8255_2 has starting address 70h.
creg12 equ 76h

mov al, 92h ; 1001 0010
out creg12, al   


mov al,09h ; 0000 1001; high on pc4 initially since active low buzzer
out creg12,al



;8255_2 init done.

;8253_1 starts here.
;int-interrupt and 1 second generator and 1/10 also generated from out2.
int_cnt0 equ 40h
int_cnt1 equ 42h
int_cnt2 equ 44h
int_creg equ 46h

mov al, 00110110b         ;mode 3
out int_creg, al

mov al, 01110110b
out int_creg, al

mov al, 10110110b
out int_creg, al

;moving count into int_cnt0 -- 25000 hex val 6108h
mov al, 0a8h
out int_cnt0, al

mov al, 061h
out int_cnt0, al

;moving count into int_cnt1 -- 100 hex val 0064h
mov al, 64h ;lsb
out int_cnt1, al

mov al, 00h ;msb
out int_cnt1, al

;moving count into int_cnt2 -- 10 hex val 000ah
mov al, 0ah ; lsb
out int_cnt2, al

mov al, 00h ; msb
out int_cnt2, al

;8253_1 ends here

;8253_2 starts here
;int-interrupt and 1 second generator and 1/10 also generated from out2.
duty_cnt0 equ 50h
duty_creg equ 56h

mov al, 00110010b ; binary hai.  ;mode 1
out duty_creg, al

mov al, 0ah ; lsb
out duty_cnt0, al 

mov al, 00h ; msb
out duty_cnt0, al 

;8253_2 ends here.

;8259 stars here.
; 8259 starts at 80h and ends at 82h &&&& vector number is 80h. same here special case.
add1_8259 equ 80h
add2_8259 equ 82h

mov al, 00010011b ; icw1
out add1_8259, al

mov al, 1000000b; 80 written in first 5 bits. && icw2
out add2_8259, al

mov al, 00000011b         ; icw4  AEOI is given high.
out add2_8259, al

mov al, 11111110b         ; ocw1
out add2_8259, al

; ocw2 not sure whethere to write or not. But if write then write in anywhere. *********************************

;8259 ends here.

on db 0; main working bool.
quick db 0;quickstart working bool.
tmin db 0; has the value to be displayed. time remaining.
tsec db 0; has the value to be displayed. time remaining.
buzz db 0; bool for buzzer
tset db 0; bool value to indicate if time has been set
tpow db 0; bool var to indicate if power has been set
qstop db 0; checks if stop is pressed atleast once.
pow db 0ah;pow db -1;
stops db 00h

mov on  ,00h; main working bool.
mov quick  ,0;quickstart working bool.
mov tmin  ,00h; has the value to be displayed. time remaining.
mov tsec  ,00h; has the value to be displayed. time remaining.
mov buzz  ,0; bool for buzzer
mov tset  ,0; bool value to indicate if time has been set
mov tpow  ,0; bool var to indicate if power has been set
mov qstop  ,0; checks if stop is pressed atleast once.mov 
mov pow ,0ah;pow db -1;
mov stops ,00h ; to check if pressed once after start 1
mov bl,00   ;for duty time for 10 sec

;add al,40h


mov al,tmin

out porta1, al  

mov al,tsec
out portb1, al

 

X12: in al,portc1
	and al,3fh; 0001 1111
	cmp al,3fh
	jnz X12 ; no i/p detected.
	
	call delay
	
X13: in al,portc1
	and al,3fh ; 0001 1111
	cmp al,3fh ; active logic.
	jz X13
	
	call delay 
	
	in al,portc1
	and al,3fh
	cmp al,3fh
	jz X13
        
    ;mov cx, 6842h
    ;int 3
    
	cmp al, 01fh;0011 1111 -> 0001 1111
	je stop_

	cmp al,02Fh    ;0010 1111
	je start_

	cmp al,37h
	je tenm			;0011 0111

	cmp al,03Bh		;0011 1011
	je onem

	cmp al,03Dh			;0011 1101
	je tens

	cmp al,3Eh		; 0011 1110
	je power

    jmp X13
    
stop_: call stop
		jmp X12
start_:call start
		jmp X12
tenm:   call add_10m
		jmp X12
onem:		call add_1m
		jmp X12
tens:	   
        ;mov cx,2222h
        ;int 3
        call add_10s
		jmp X12
power:	call pow_mod
		jmp X12

nmi_:     
           
    
	mov cl, dl;
	;int 3
    cmp dl,00;
	je re_ad
    
    
    ;int 3
    cmp bl,10
    jne z3:
   ; int 3
    mov bl,00
    
   z3:   
   ;int 3
    add bl,1
    cmp bl,pow
    
    ;int 3
    
    jg z1
    mov al,00000101b
    
    ;int 3
      
    out creg12,al  
    jmp z2
    
    
    z1:mov al,00000100b
    ;int 3
       out creg12,al
    
    z2:
    
    
	cmp buzz,01
	je re_ad

	cmp tsec,00;
	je min_

		mov al,tsec
		sub al,01
		das
		mov tsec,al
		call update_disp
		jmp buzz_chk

	min_:
		mov al,tmin
		sub al,01
		das
		;add al, ff
		
		mov tmin,al
		mov tsec,59h
		call update_disp
		jmp re_ad
	
	buzz_chk:
		cmp tsec,00
		jne re_ad
		cmp tmin,00
		jne re_ad
		mov buzz,01
		mov al, 08h  ;low active for buzzer portc4b
		out creg12, al; 0000 0011 ; turn dl buzzer through bsr 
		mov dl,00   ;turn off on variable  
		
		
		
		mov al,00h  ; turn off LED at pc0 B
		out creg12,al

re_ad: 

	iret

;helper functidl to update display dl bcd
update_disp:
	
	mov al,tmin
	cmp al,60h
	jl  nt
	mov al,60h
	mov tmin,al

	mov al,00h
	mov tsec,al 
	nt:
	mov al,tsec 	
	out portb1,al 
	
	mov al,tmin 	
	out porta1,al
	
ret
;end of helper functidl update_disp


add_10m: ;awwwwwww

	cmp dl,01h
	je tm_ret
    
    cmp stops,01h
	je tm_ret
    
	mov tset,01h

	mov al,tmin
	add al,10
	daa
	
	cmp al,60h
	jl lt_10m
	mov tsec,00
	mov al,60h

	lt_10m: ; around 59 max
		mov tmin,al  
		
		call update_disp

tm_ret:
	ret

add_1m: 
  ;  mov cx, 5555h
  ;  
  
	cmp dl,01
	je m_ret
    
    cmp stops,01h
	je m_ret
    
	mov tset,01h

	mov al,tmin
	add al,01h
	daa  
	
	cmp al,60h
	jl lt_1m
	mov tsec,00
	mov al,60h

	lt_1m:
		mov tmin,al
        call update_disp
	m_ret:
	call update_disp
		ret

add_10s:
   cmp dl,01		; check if microwave is cooking
	je xyz		; if yes return wothout updating
    
    cmp stops,01h
	je xyz    
	mov tset,01h	
	mov al,tsec		; move seconds in al
	add al,10
	daa
    
   ; mov cx,8888h
   ; int 3
    
    
	cmp al,60h		; check if after adding  10s time exceeds 60s
	jl lt_10s	; if time remains less than 60s jump to label less_than_10s

	sub al,60h
	
	mov tsec,al             ; if tsec is greater than 60s then subtract 60 from tsec and call subroutine to add 1m to time
	call add_1m
	jmp xyz


	lt_10s:   
	   ; mov bx, 4444h MISTAKKE AS FUCK.
	    ;mov cl, tsec
	    ;int 3
		mov tsec,al    ; if tsec is less than 60s mov time back from al to tsec    
		call update_disp
		jmp xyz

	xyz:
		call update_disp
		ret

pow_mod:
    ;int 3  
    
    
	cmp dl,01h
	je pow_ret
    
    cmp stops,01
    je pow_ret
    
	cmp tset,01h
	je pow_ret

	; here onwards dl and tset are b0th 0S

	cmp tpow,00h
	je pow_init

	; not virgin from here.

	mov al,pow
	sub al,02
	cmp al,00h
	jne nzero_pow
	add al,10

	nzero_pow:
		mov pow,al

	pow_init:
		mov tpow,01

	pow_ret:
	    ;mov cl,pow   
	    ;int 3
	    
		mov al,pow
		;int 3           ; initial pow handled here
		out duty_cnt0,al      
		mov al,00
		out duty_cnt0,al;msb

		;;;;;;;;;;;;;;;;;
		mov al,pow
		add al,00h
		daa
		out portb1,al
		
		mov al,0FFh
		out porta1,al
		;;;;;;;;;;;;;;;;;
		
		ret



start:
    ;mov cl,tset
   ; int 3
	; checking time variable. 
	mov stops,00
	
	cmp tset, 00h
	je quicks
	; tset =1 means either default power or given power .normal cooking and again pressing start wdl't do anything.
	; assuming at-0 power is 100
	cmp tpow, 01h
	je pw_give
	; here power is default.
	mov tpow, 01h
	mov pow, 0Ah
	mov dl, 01h
	
	jmp down ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	pw_give: ;;;;;;;;;;;;;;;;;;;;;; if pressing it normal then recursive here here here here.
		; normal cooking.
		mov dl, 01h
		
		; in normal cooking pressing start again wdl't do anything.
		jmp down ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	quicks:
    ;    mov cx,1111h
     ;   int 3
		cmp qstop, 01 ; If its "start" after pressing stop in quickstart mode then run it
		jne x1
		mov qstop, 00h ; here qstop =1;
		je pw_give

		x1:	
			mov qstop, 00 ; as it is until next start of quickstart is pressed.
			mov pow, 0Ah;;;;;;;;;;;;;;;;;;;;;;;;;;
			mov tpow, 01h;;;;;;;;;;;;;;;;;;;;;;;;;;
			cmp dl, 01h
			je qck_add

			
			mov tsec, 30h ; first time with quickstart
			mov tmin, 00h
			mov dl, 01h
			;
			;int 3

			call update_disp
			
			jmp down;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			qck_add:
				mov al, tsec
				add al, 30h
				daa
				mov tsec, al
				
				cmp tsec, 60h
				jge qadd_1m

				; less than 60
				jmp down;;;;;;;;;;;;;;;;;;;;;;;;;;; to be written.

				qadd_1m:
					mov al, tsec
					sub al, 60h
					das
					mov tsec, al

					; now adding 1 min to 

					mov al, tmin
					add al, 1
					daa
					mov tmin, al

					cmp tmin, 60h
					jge qmax

					jmp down

					qmax: 	mov tsec, 00h
							mov tmin, 60h
							jmp down ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	down:
	    
	    
		mov al,00000001b ; pc0 lock led. 
		mov cx,4444h
		
		;int 3
		out creg12,al  
	    
	    mov cx,1112h  
	   ; int 3
		mov al,00000101b ; pc2 duty cycle ka bool since duty is always shown.
		
		out creg12,al
        
        
		ret



stop:

	;call update_disp

    mov stops,01h
	mov buzz, 00h ; everytime stop is pressed buzzer will turned off.

	cmp dl, 00
	je rst 
	
	

	; ndl-reset code here.
	; here dl=1
	cli
	mov dl, 00h
	mov al,00000100b ; when stopped duty cycle must also be masked made zero.
	out creg12,al

	;once the cooking begins the door gets locked and should open only when cooking process is "terminated". 
	;User can "terminate" cooking anytime by pressing the STOP button. 
	mov al,00000000b ; pc0 lock led. lock is open 
	out creg12,al

	cmp tset, 00 ; (tset=0 iff quickstart mode is off, apply cdltrapositive also.)
	jne not_qstop
	mov qstop, 01h ; if tset is zero.
	
	not_qstop: jmp down1
	
	rst:
	jmp st1 


	down1:
		ret


delay:
    mov              cx,3040 
	xn:        loop          xn
ret 
