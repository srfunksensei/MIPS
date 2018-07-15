

#ifndef __PROGRAM8051_H__
#define __PROGRAM8051_H__

/*===========================================================================================
								SFR REGISTERS									  
===========================================================================================*/

sfr P0    = 0x80;	/* port 0 - adr and data */
sfr P1    = 0x90;	/* port 1 - printer */ 
sfr P2    = 0xA0;	/* port 2 - adr */
sfr P3    = 0xB0;	/* port 3 - control 0..7 [RxD,TxD,\INT0,\INT1,\T0,\T1,WR,RD]*/
sfr PSW   = 0xD0;	/* [CY,AC,F0,RS1,RS0, ,OV,P]*/
sfr ACC   = 0xE0;	/* akomulator */
sfr B     = 0xF0;	/* pomocni */
sfr SP    = 0x81;  	/* zadnji uneti , rasete ka visim lokacijama*/
sfr DPL   = 0x82;  	/* pokazivac na eksternu memoriju - nizi bajt */
sfr DPH   = 0x83;  	/* pokazivac na eksternu memoriju - visi bajt */
sfr PCON  = 0x87;	/* kontrolni: [SMOD,-,-,-,GF1,GF0,PD,IDL]*/
sfr TCON  = 0x88;	/* kontroni : [TF1,TR1,TF0,TR0]*/
sfr TMOD  = 0x89;	/* mod tajmera : [t1-gate,t1-C/T,t1-M1,t1-M0,t0-gate,t0-C/T,t0-M1,t0-M0,IE1,IT1,IE0,IT0]*/
sfr TL0   = 0x8A;	/* T0 low data */
sfr TL1   = 0x8B;	/* T0 high data */
sfr TH0   = 0x8C;	/* T1 low data */
sfr TH1   = 0x8D;	/* T1 high data */
sfr IE    = 0xA8;	/* enable interrupt: [EA,-,-,mser,mt1,me1,mt0,me0] */
sfr IP    = 0xB8;	/* interrupt priority: [-,-,-,ser,t1,e1,t0,e0] */ 
sfr SCON  = 0x98;	/* kontrolni: [SM0,SM1,SM2,REN,TB8,RB8,TI,RI] */ 
sfr SBUF  = 0x99;	/* data to transmit or received data */
/*  PSW  */
sbit CY    = PSW^7;
sbit AC    = PSW^6;
sbit F0    = PSW^5;
sbit RS1   = PSW^4;
sbit RS0   = PSW^3;
sbit OV    = PSW^2;
sbit P     = PSW^0; 
/*  TCON  */
sbit TF1   = TCON^7;
sbit TR1   = TCON^6;
sbit TF0   = TCON^5;
sbit TR0   = TCON^4;
sbit IE1   = TCON^3;
sbit IT1   = TCON^2;
sbit IE0   = TCON^1;
sbit IT0   = TCON^0;
/*  IE  */
sbit EA    = IE^7;
sbit ES    = IE^4;
sbit ET1   = IE^3;
sbit EX1   = IE^2;
sbit ET0   = IE^1;
sbit EX0   = IE^0;
/*  IP  */
sbit PS    = IP^4;
sbit PT1   = IP^3;
sbit PX1   = IP^2;
sbit PT0   = IP^1;
sbit PX0   = IP^0;
/*  P3  */
sbit RD    = P3^7;
sbit WR    = P3^6;
sbit T1    = P3^5;
sbit T0    = P3^4;
sbit INT1  = P3^3;
sbit INT0  = P3^2;
sbit TXD   = P3^1;
sbit RXD   = P3^0;
/*  SCON  */
sbit SM0   = SCON^7;
sbit SM1   = SCON^6;
sbit SM2   = SCON^5;
sbit REN   = SCON^4;
sbit TB8   = SCON^3;
sbit RB8   = SCON^2;
sbit TI    = SCON^1;
sbit RI    = SCON^0;

/*===========================================================================================
								CONSTANTS									  
===========================================================================================*/

/*----------------------------------------------------------
					PAL16L8
------------------------------------------------------------
keyCS(pin12)=\pin16*pin15*pin14*pin13*\pin1*
			  *\pin2*\pin3*\pin4*\pin5*\pin6*
			  *\pin7*\pin8*\pin9*\pin11
displayCS(pin19)=\pin16*pin15*pin14*pin13*\pin1*
			  	 *pin2*\pin3*\pin4*\pin5*\pin6*
			     *\pin7*\pin8*\pin9*\pin11	*/


#define START_T0 TCON|=0x10;
#define STOP_T0 TCON&=0xEF;
#define START_LAD  key_portC|=0x01;
#define STOP_LAD	key_portC&=0xFE;
#define START_PRINT	key_portC|=0x02;
#define STOP_PRINT	key_portC&=0xFD;
#define LOCK_KEYBOARD  IE&=0xFE;
#define UNLOCK_KEYBOARD	IE|=0x01;
#define RESET_STF SCON&=0xFD; 
#define RESET_SRF SCON&=0xFE;
#define LOCK_SERIAL	 IE&=0xEF;
#define UNLOCK_SERIAL IE|=0x10;
#define START_RECEIVE SCON|=0x10;
#define STOP_RECEIVE  SCON&=0xEF;

/*----------------------------------------------------------
				DISPLAY CONSTANTS
----------------------------------------------------------*/

unsigned char code select_seg0 =	0x00; 
unsigned char code select_seg1 =	0x01;
unsigned char code select_seg2 =	0x02;
unsigned char code select_seg3 =	0x03;
unsigned char code select_seg4 =	0x04;
unsigned char code select_seg5 =	0x05;
unsigned char code select_seg6 =	0x06;
unsigned char code select_seg7 =	0x07;
unsigned char code select_seg8 =	0x0F;
unsigned char code select_seg9 =	0x17;
unsigned char code select_seg10 =	0x1F;
unsigned char code select_seg11 =	0x27;
unsigned char code select_seg12 =	0x2F;
unsigned char code select_seg13 =	0x37;
unsigned char code select_seg14 =	0x3F;
unsigned char code select_seg15 =	0x7F;
unsigned char code select_seg16 =	0xBF;

/* null */
unsigned char code unselected_seg =	0xFF;
unsigned char code display_null =	0xFF;
/* numbers */
unsigned char code display0_c =		0x19;
unsigned char code display0_b =		0x98;
unsigned char code display1_c =		0xF7;
unsigned char code display1_b =		0xEF;	
unsigned char code display2_c =		0x3C;		
unsigned char code display2_b =		0x3C;
unsigned char code display3_c =		0x3C;
unsigned char code display3_b =		0x78;
unsigned char code display4_c =		0XDC;
unsigned char code display4_b =		0x7B;
unsigned char code display5_c =		0x1E;
unsigned char code display5_b =		0x78;
unsigned char code display6_c =		0x1E;	
unsigned char code display6_b =		0x38;		
unsigned char code display7_c =		0x3D;		
unsigned char code display7_b =		0xFB;		
unsigned char code display8_c =		0x1C;		
unsigned char code display8_b =		0x38;
unsigned char code display9_c =		0x1C;
unsigned char code display9_b =		0x78;
unsigned char code displayDD_c =	0xF7;	
unsigned char code displayDD_b =	0xEF;
/* letters */
unsigned char code displayA_c =		0x1C;
unsigned char code displayA_b =		0x3B;
unsigned char code displayB_c =		0x35;
unsigned char code displayB_b =		0x68;
unsigned char code displayC_c =		0x1F;
unsigned char code displayC_b =		0xBC;
unsigned char code displayD_c =		0x35;
unsigned char code displayD_b =		0xEC;
unsigned char code displayE_c =		0xCD;
unsigned char code displayE_b =		0xBC;
unsigned char code displayF_c =		0x1D;
unsigned char code displayF_b =		0xBF;
unsigned char code displayG_c =		0x1F;
unsigned char code displayG_b =		0x38;
unsigned char code displayH_c =		0xDC;
unsigned char code displayH_b =		0x3B;
unsigned char code displayI_c =		0x2F;
unsigned char code displayI_b =		0xEC;
unsigned char code displayJ_c =		0x3D;
unsigned char code displayJ_b =		0xB8;
unsigned char code displayK_c =		0xDA;
unsigned char code displayK_b =		0xB8;
unsigned char code displayL_c =		0xDF;
unsigned char code displayL_b =		0xBC;
unsigned char code displayM_c =		0xC9;
unsigned char code displayM_b =		0xBB;
unsigned char code displayN_c =		0xCD;
unsigned char code displayN_b =		0xB3;
unsigned char code displayO_c =		0x1D;
unsigned char code displayO_b =		0xB8;
unsigned char code displayP_c =		0x1C;
unsigned char code displayP_b =		0x3F;
unsigned char code displayQ_c =		0x1D;
unsigned char code displayQ_b =		0xB0;
unsigned char code displayR_c =		0x56;
unsigned char code displayR_b =		0xB7;
unsigned char code displayS_c =		0x1E;
unsigned char code displayS_b =		0x78;
unsigned char code displayT_c =		0x37;
unsigned char code displayT_b =		0xEF;
unsigned char code displayU_c =		0xDD;
unsigned char code displayU_b =		0xB8;
unsigned char code displayV_c =		0xDB;
unsigned char code displayV_b =		0x9F;
unsigned char code displayW_c =		0xDD;
unsigned char code displayW_b =		0x93;
unsigned char code displayX_c =		0xEB;
unsigned char code displayX_b =		0xB7;
unsigned char code displayY_c =		0xEB;
unsigned char code displayY_b =		0xEF;
unsigned char code displayZ_c =		0x3B;
unsigned char code displayZ_b =		0xDC;
unsigned char code displayMul_c =	0xE2;	
unsigned char code displayMul_b =	0x47;

#endif
