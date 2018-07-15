
#include <program8051.h>

/*==========================================================================
			   			VARIABLES
===========================================================================*/

			/* INTERFACES */
/*keyboard*/
unsigned char xdata key_portA _at_ 0x8000;
unsigned char xdata key_portB _at_ 0x8001;
unsigned char xdata key_portC _at_ 0x8002;
unsigned char xdata key_contr _at_ 0x8003;	
/*display*/
unsigned char xdata display_portA _at_ 0x8004;
unsigned char xdata display_portB _at_ 0x8005;
unsigned char xdata display_portC _at_ 0x8006;
unsigned char xdata display_contr _at_ 0x8007;

			/* DATA */
/*database*/
unsigned char xdata product_database[16001]; /* 1 for escape*/
unsigned char* data cur_database_ptr;
/*init protocol*/
unsigned char data data_count;
unsigned char data time_count;
unsigned char data protocol_phase = 0;
unsigned char data recData;
bit bdata programming = 0;
unsigned char xdata prog_time = 0;
/* display */
unsigned char xdata display_buffer[34];
unsigned char* data cur_buffer_ptr=0;
unsigned char xdata wait_str[17] =			"   WAITING       ";
unsigned char xdata programming_str[17] =	"   PROGRAMMING   ";
unsigned char xdata sys_err_str[17] =		"ERROR NEED RESET ";
unsigned char xdata err_str[17] =			"     ERROR       ";
unsigned char xdata sys_amount_str[17] =	" AMOUNT          ";
unsigned char xdata sys_total_str[17] =		" TOTAL           ";
/* printer */
bit bdata have_paper=1;
unsigned char* data print_ptr;
unsigned int data numChar_to_print=0;
bit bdata isPrinting=0;
/* keyboard */
bit bdata isAmount=0;
bit bdata isFunction=0;
unsigned int data cur_amount=1;
unsigned int data cur_product_id=0;
unsigned char* xdata cur_product_offset;
unsigned int data cur_product_price=0;
unsigned int data cur_sum=0;
unsigned char xdata data_str[17]; 
unsigned char xdata amount_str[17];
/* sys lock	*/
bit bdata error=0;
bit bdata lock_sys=0;
bit bdata isReady=0;
/* function	*/
bit bdata serialF0=0;
/* counter */
char data counter_mode=0;
 /* printing_ptr dw 0 */
unsigned char data lad_cnt=	0x96; /*150x2mS*/
unsigned char data char_cnt=	0x0A; /*10x2mS*/
unsigned char data cr_cnt=		0x64; /*100x2mS*/
bit bdata isLad=0;
bit bdata isChar=0;
bit bdata isCr=0;
/* time	*/
unsigned char data hours=0;
unsigned char data minutes=0;
unsigned char data seconds=0;
unsigned char xdata time_str[17]="     :    :      ";
unsigned int data clkSec= 0x0FA0 ;   /*4000*/
unsigned char data clkDisplay= 0xA0; /*160*/
bit bdata show_clock=0;
/* bill */ 
unsigned char xdata current_bill[512];
unsigned char* data cur_bill_ptr;
bit bdata sending_bill=0;
unsigned char* data cur_item_to_send;
unsigned char data bill_price=0;
/* daily sales */
unsigned int data total=0;
unsigned char xdata sales_data[14000];
unsigned char* data cur_sales_ptr;
/*stack*/
unsigned char xdata stackStart;
/*utiliti*/
unsigned int data i;
unsigned int data j;
/*keyboard*/
unsigned char code keys[16]={7,8,9,'F',4,5,6,'C',1,2,3,'+','*',0,'#','='};	   /*isp*/
unsigned char code scan[4]={0x0E,0x0D,0x0B,0x07};

/*==========================================================================
			   			UTILITI FUNCTIONS
				(reentrant-not for recursion just
				 for multiple calls when function works 
				 with global data)
===========================================================================*/ 

/*--------------------------------------------------------
 		from src string to display buffer 
--------------------------------------------------------*/
 void fill_display_buf(char* src) reentrant{ 
 	unsigned char* data display_ptr;
	unsigned char data dif;
  	cur_buffer_ptr=&display_buffer[0];
 	for(i=0;i<17;i++){
		/*	number or : */
 		if(src[i]>=0x30 && src[i]<=0x3A){
			display_ptr=&display0_c;
			 dif=src[i]-'0';
			*cur_buffer_ptr=*(dif+display_ptr);
			cur_buffer_ptr++;
			*cur_buffer_ptr=*(display_ptr+dif+1);
			cur_buffer_ptr++;
			break;
		}
		/* letter */
		if(src[i]>=0x41 && src[i]<=0x5A){ 
			display_ptr=&displayA_c;
			 dif=src[i]-'A';
			*cur_buffer_ptr=*(dif+display_ptr);
			cur_buffer_ptr++;
			*cur_buffer_ptr=*(display_ptr+dif+1);
			cur_buffer_ptr++;
			break;
		}
		if(src[i]=='*'){ 
			*cur_buffer_ptr=displayMul_c;
			cur_buffer_ptr++;
			*cur_buffer_ptr=displayMul_b;
			cur_buffer_ptr++;
			break;
		}
		if(src[i]==' '){ 
			*cur_buffer_ptr=display_null;
			cur_buffer_ptr++;
			*cur_buffer_ptr=display_null;
			cur_buffer_ptr++;
			break;
		}
	}
  }

/*-----------------------------------------------------
	 refresh display to show new value
    	from display_buffer
	-in code function have protection from
	 multiple calls. 
------------------------------------------------------*/
void display_refresh() reentrant{ 
unsigned char* data seg_ptr=&select_seg0;
cur_buffer_ptr=&display_buffer[0];
 for(i=0;i<17;i++){   
  display_portA=*seg_ptr;
  display_portC=*cur_buffer_ptr;
  cur_buffer_ptr++;
  display_portB=*cur_buffer_ptr;
  seg_ptr++;
  cur_buffer_ptr++;
 }
}

/*---------------------------------------------------
				int to string
-----------------------------------------------------*/
void value_to_string(unsigned value,char* destination)reentrant{
	unsigned int data val=value;
  	char* data dst=destination;
  	for(i=0;i<5;i++){
	 	*dst=(val%10)-'0';
		val=val/10;
		dst--;
		if(val==0) break;
	}
	while(i<5){
		*dst=' ';
		i++;
		dst--;
	}
 }

/*-----------------------------------------------------
			   time to string
          "  h1h0 : m1mo : s1s0   "		       
------------------------------------------------------*/
void time_to_string(){
 	  time_str[2]=hours/10;
	  time_str[3]=hours%10;
	  time_str[7]=minutes/10;
	  time_str[8]=minutes%10;
	  time_str[12]=seconds/10;
	  time_str[13]=seconds%10;
}

/*-----------------------------------------------------
			   setup sales data	       
------------------------------------------------------*/

void setup_sales_data(){
  unsigned* data num=&product_database[14];
  cur_database_ptr=&product_database[0];
  cur_sales_ptr =&sales_data[0];
  for(i=0;i<1000;i++){
  	if(*num>0){
	for(j=0;j<12;j++){
	   *cur_sales_ptr=cur_database_ptr[j];
	   cur_sales_ptr++;
	}
	 cur_sales_ptr+=5;
	 value_to_string(*num,cur_sales_ptr);
	 cur_sales_ptr++;*cur_sales_ptr=0x0A;
	 cur_sales_ptr++;*cur_sales_ptr=0x0D;
	 *num=0;
  	}
	cur_sales_ptr++;
	num+=16;
	cur_database_ptr+=16;
			  
  }
}
 
 /*-----------------------------------------------------
			   copy string	       
------------------------------------------------------*/
void copy_string (unsigned length,char* dst,char* src)reentrant{
	for(i=0;i<length;i++)
	 *(dst+i)=*(src+i);
}


/*==========================================================================
			   			INTERRUPTS
===========================================================================*/
/*--------------------------------------------------------
 				KEYBOARD 
--------------------------------------------------------*/
void keyboard() interrupt 0 using 0{
	unsigned char data key=0;
	unsigned char data i; 
	unsigned char data temp;

		/*scan keyboard*/
 	 for(i=0;i<16;i++){
  		key_portA=scan[i%4];
		temp=key_portB&scan[i%4];
		if(!temp){
			key=keys[i];
			break;
		}
   	}
	if(!key) goto keyEnd;
	switch(key){
	/*number*/
	case 1: case 2: case 3: case 4: case 5: case 6:
	case 7: case 8: case 9:	
		if(error) goto keyEnd;
		if(!isFunction && !isAmount){
		   cur_product_id=cur_product_id*10+key;
		   cur_product_offset=(char*)&product_database[0]+cur_product_id*16;
		   show_clock=0;
		   copy_string(12,data_str,cur_product_offset);
		   cur_product_price=*(cur_product_offset+12);
		   value_to_string(cur_product_price,data_str+16);
		   fill_display_buf(data_str);
		}else if(!isFunction){
		   cur_amount=cur_amount*10+key;
		   show_clock=0;
		   value_to_string(cur_amount,amount_str+5);
		   value_to_string(cur_amount*cur_product_price,amount_str+16);
		   fill_display_buf(amount_str);
		}else if(isFunction){
		  switch(key){
		  case 0:
		  		setup_sales_data();
				numChar_to_print=16000;
				UNLOCK_SERIAL
				LOCK_KEYBOARD
				show_clock=1;
		  		break;
		  case 1:
		  		setup_sales_data();
				print_ptr=sales_data;
				numChar_to_print=16000;
				/*start counter, mask keyboard*/
				START_T0
				LOCK_KEYBOARD
				show_clock=1;
		  		break;
		  case 2:
		  		/*display total*/
		  		value_to_string(total,sys_total_str+16);
				fill_display_buf(sys_total_str);
		  		break;
		  case 3:
		  		/*open lad*/
		  		isLad=1;
				START_T0
				START_LAD
		  		break;
			}
		}
		break;
   case '+':
 		if(!error) goto keyEnd;
		copy_string(12,cur_bill_ptr,cur_product_offset);
		cur_bill_ptr+=12;
		cur_sum=cur_product_price*cur_amount;
		bill_price+=cur_sum;
	    total+=cur_sum;
		value_to_string(cur_sum,cur_bill_ptr);
		cur_bill_ptr+=5;
		*cur_bill_ptr=0x0D;
		cur_bill_ptr++;
		*cur_bill_ptr=0x0A;
		*(cur_product_offset+14)+=cur_amount;
		cur_amount=0;
		cur_product_id=0;
		cur_product_offset=0;
		cur_product_price=0;
	   	value_to_string(bill_price,sys_amount_str+16);
		fill_display_buf(sys_amount_str);
		numChar_to_print+=0x13;
		if(!isPrinting){
			print_ptr=current_bill;
			counter_mode=1;
		    STOP_T0

		}
		break;
   case '-':
 		if(!error) goto keyEnd;
		*cur_bill_ptr='-';
		cur_bill_ptr++;
		copy_string(12,cur_bill_ptr,cur_product_offset);
		cur_bill_ptr+=12;
		cur_sum=cur_product_price*cur_amount;
		bill_price-=cur_sum;
	    total-=cur_sum;
		value_to_string(cur_sum,cur_bill_ptr);
		cur_bill_ptr+=5;
		*cur_bill_ptr=0x0D;
		cur_bill_ptr++;
		*cur_bill_ptr=0x0A;
		*(cur_product_offset+14)-=cur_amount;
		cur_amount=0;
		cur_product_id=0;
		cur_product_offset=0;
		cur_product_price=0;
	   	value_to_string(bill_price,sys_amount_str+16);
		fill_display_buf(sys_amount_str);
		numChar_to_print+=0x13;
		if(!isPrinting){
			isPrinting=1;
			print_ptr=current_bill;
			counter_mode=1;
		    STOP_T0
		}
		break;
	case '=':
		if(error) goto keyEnd;
		for(i=0;i<10;i++){
		*cur_bill_ptr='=';
		cur_bill_ptr++;
		}
		*cur_bill_ptr=0x0D;
		cur_bill_ptr++;
		*cur_bill_ptr=0x0A;
		value_to_string(bill_price,cur_bill_ptr);
		*(cur_bill_ptr+5)=0x1B;
		cur_bill_ptr=0;
		bill_price=0;
		isReady=1;
		show_clock=1;
		/*open lad */
		isLad=1;
		key_portC|=0x01;
		numChar_to_print+=0x11;
		if(!isPrinting){
			isPrinting=1;
			STOP_T0
		}
		break;
	case 'F':
		if(error) goto keyEnd;
		if(!isReady) goto errorLab;
		isFunction=1;
		break;
	case 'C':
		isFunction=0;
		cur_product_id=0;
		cur_amount=1;
		isAmount=0;
		show_clock=1;
		break;
	case '*':
		if(error) goto keyEnd;
		isAmount=1;
		break;

   }
   goto keyEnd;
errorLab:
	error=1;
	fill_display_buf(err_str);
keyEnd:
	key_portA=0;		
}      

 
/*--------------------------------------------------------
 				TIME 
--------------------------------------------------------*/
void time() interrupt 1 using 1{
	/*if 1s -> setup time*/
	if(!(--clkSec)){
   		clkSec=0x0FA0;
		if(++seconds==60){
			seconds=0;
			if(++minutes==60){
				minutes=0;
				if(++hours==24){
					hours=0;
				}
			}
		}
		if(show_clock){
			time_to_string();
			fill_display_buf(time_str);
		}
  	}
	/*if 40ms -> show display*/
	if(!(--clkDisplay)){
		clkDisplay=0x0A0;
		display_refresh();
	}
}


/*--------------------------------------------------------
 				PRINT 
--------------------------------------------------------*/
void print() interrupt 2 {
 have_paper=0;
}


/*--------------------------------------------------------
 				COUNTER 
--------------------------------------------------------*/
void counter() interrupt 3 using 2{

  /*reload*/
  TH0=0x07;	
  TL0=0x0D;
  /*setup lad*/
  if(isLad){
   	if(--lad_cnt){
		lad_cnt=0x96;
		UNLOCK_KEYBOARD
		if(!isPrinting){
			STOP_T0
		} 
		STOP_LAD
	}
  }
  /*printer*/
  if(have_paper){
  switch(counter_mode){
  case 1:
  	/*start print*/
    P1=*print_ptr;
	print_ptr++;
	START_PRINT
	counter_mode=2;
	break;
  case 2:
  	/*stop print and setup
		wait interval*/
  	STOP_PRINT
	if(*print_ptr==0x0D){
	 	isCr=1;
	}else{
	 	isChar=1;
	}
	print_ptr--;
	counter_mode=3;
	break;
  case 3:
  	/*wait*/
  	if(isCr){
		if(!--cr_cnt){
	 	   cr_cnt=0x64;
		   	if(*print_ptr!=0x1B)
	 			numChar_to_print--;
			if(*print_ptr==0x1B || !numChar_to_print){
	 	 		print_ptr=current_bill;
		 		counter_mode=0;
		 		isPrinting=0;
		 		if(!isLad) STOP_T0;
			}else{
				counter_mode=1;
			}	
		}
	}
	if(isChar){
		if(!--char_cnt){
	 	   char_cnt=0x0A;
		   if(*print_ptr!=0x1B)
	 			numChar_to_print--;
			if(*print_ptr==0x1B || !numChar_to_print){
	 	 		print_ptr=current_bill;
		 		counter_mode=0;
		 		isPrinting=0;
		 		if(!isLad) STOP_T0;
			}else{
				counter_mode=1;
			}
		}
	}
	break;
  }
 }
}


/*--------------------------------------------------------
 				SERIAL 
--------------------------------------------------------*/
void serial()interrupt 4 using 3{
	
   if(serialF0){
		if(*cur_item_to_send!=0x1B){
	 		SBUF=*cur_item_to_send;
	 		cur_item_to_send++;
			RESET_STF
		}else{
			LOCK_SERIAL
			RESET_STF
			UNLOCK_KEYBOARD
		}
   }else{
	switch(protocol_phase){
	case 0:
		/*start database init protocol
  			transmit to PC SYN character*/
		SBUF=0x16;
		protocol_phase++;
		RESET_STF;
		break;
	case 1:
		START_RECEIVE
		protocol_phase++;
		RESET_STF;
		break;
	case 2:
		/*Receive SYN*/
		recData=SBUF;
		if(recData!=0x16){
		 fill_display_buf(sys_err_str);
		 display_refresh();
		 lock_sys=1;
		 break;
		}
		fill_display_buf(programming_str);
		protocol_phase++;
		RESET_SRF;
		break;
	case 3:
		/*programming*/
		recData=SBUF;
		if(prog_time){
			switch(time_count){
			case 0:
				hours=recData;
				time_count++;
				break;
			case 1:
				minutes=recData;
				time_count++;
				break;
			case 2:
				seconds=recData;
				time_count++;
				STOP_RECEIVE
				LOCK_SERIAL
				cur_database_ptr=0;
				break;
			}		
		}else if(recData==0x1B){
				if(!data_count){
			 	fill_display_buf(sys_err_str);
		 		display_refresh();
		 		lock_sys=1;
				break;
			 }
			 prog_time=1;
		}else if(data_count<=11){
		   	*cur_database_ptr=recData;
		   	cur_database_ptr++;
			data_count++;
		}else if(data_count<=13){
   			*cur_database_ptr=recData;
			if(data_count==13){
				data_count=0;
				*cur_database_ptr=0;
		   		cur_database_ptr++;
		   		*cur_database_ptr=0;
		   		cur_database_ptr++;
			}else
		   	cur_database_ptr++;
		}
		RESET_SRF;
		break;
	}
	}
}


/*==========================================================================
			   			INIT
===========================================================================*/ 
void init (){
	
	 /* init 8051 */
	 SP=0x30;
	 /*timers*/
	 TMOD=0x22; /*[g:0,c:0,M:1,0|g:0,c:0,M:0,1]*/
	 TH1=0xFA;	/*250=>250uS*/
	 TH0=0x07;	/*2000=>2mS*/
	 TL0=0x0D;
	 TCON=0x45; /* [t1:0,1|t2:0,0|0,1,0,1]*/
	 /*serial*/
	 PCON=0x00;
	 SCON=0x80;
			 		
	/* init pointers */	
 	product_database[16000]=0x1B; /*escape*/
	cur_database_ptr=&product_database[0];
	cur_buffer_ptr=&display_buffer[0];
	cur_bill_ptr=&current_bill[0];
	cur_sales_ptr=&sales_data[14000];

	 /*interrupt*/
	 IP=0x0A;  /*timer and counter has priority=1*/
	 IE=0x9F;  /*unlock all interrupts*/
}

/*==========================================================================
			   			MAIN
===========================================================================*/
void main(){
	init();
	while(1){
		if(lock_sys) IE=0x00;
	}
}


 




















