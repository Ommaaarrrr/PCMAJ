DUTY_CYCLE_HI DATA 2
DUTY_CYCLE_LO DATA 3
PWM_PERIOD_HI EQU 000h
PWM_PERIOD_LO EQU 000h
MOT1_FW BIT P2.0
MOT1_BW BIT P2.1
MOT2_FW BIT P2.2
MOT2_BW BIT P2.3
ISX_AXIS BIT 0
IS_FW BIT 1
DONE BIT 2

ORG 0
LJMP MAIN
ORG 000BH
PWM_PERIOD_END:
	CPL ISX_AXIS	;change axis
	CLR TR0
	SETB DONE
	RETI


ORG 001BH
DUTY_CYCLE_END:
	LJMP CLEAR_PWM	;Duty cycle ended, we will wait till to the new period

ORG 00ABH
MAIN:
	MOV IE, #10001010b
	MOV DUTY_CYCLE_HI, #008h
	MOV DUTY_CYCLE_LO, #00Dh
	MOV TMOD, #00010001b

	SETB ISX_AXIS

	ANL P2, #0F0h			;Clear pins so that first cycle will be empty
	ACALL LOOP
	MOV DUTY_CYCLE_HI, #00Ch
	MOV DUTY_CYCLE_LO, #067h
	ACALL LOOP
	MOV DUTY_CYCLE_HI, #00Bh
	MOV DUTY_CYCLE_LO, #0AFh
	ACALL LOOP
	MOV DUTY_CYCLE_HI, #009h
	MOV DUTY_CYCLE_LO, #086h
	ACALL LOOP
	SJMP $
	
BWX:	JNB ISX_AXIS, BWY		;Check if we will send x axis
	JB IS_FW, FWX			;Check if we will turn forward or backwards
	SETB MOT1_BW
	CLR MOT1_FW
	RET
FWX:
	SETB MOT1_FW
	CLR MOT1_BW
	RET

BWY: 	JB IS_FW, FWY
	SETB MOT2_BW
	CLR MOT2_FW
	RET
FWY:
	SETB MOT2_FW
	CLR MOT2_BW

	RET

CLEAR_PWM:
	JNB ISX_AXIS, CLEAR_FWY
	CLR MOT1_BW
	CLR MOT1_FW
	SJMP NEXT_CYCLE

CLEAR_FWY:
	CLR MOT2_FW
	CLR MOT2_BW
	SJMP NEXT_CYCLE

NEXT_CYCLE:
	CLR TR1
	MOV TH1, DUTY_CYCLE_HI
	MOV TL1, DUTY_CYCLE_LO
	RETI
	
LOOP:
	CLR DONE
	MOV TH0, #PWM_PERIOD_HI
	MOV TL0, #PWM_PERIOD_LO
	MOV TH1, DUTY_CYCLE_HI
	MOV TL1, DUTY_CYCLE_LO
	ACALL BWX
	SETB TR0
	SETB TR1
	JNB DONE, $
	RET

END
