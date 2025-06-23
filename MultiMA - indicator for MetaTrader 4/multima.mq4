//--------------------------------------------------------------------
// multima.mq4 
//|                                  Copyright © 2008, Viennatrader |
//|                                                                  |
//+------------------------------------------------------------------+
#property indicator_chart_window 
#property indicator_buffers 3     
#property indicator_color1 Red   
#property indicator_color2 Blue
#property indicator_color3 Yellow

extern string c0="Use for Methode:";

extern string c1="MODE_SMA: 0"; 
extern string c2="MODE_EMA: 1"; 
extern string c3="MODE_SMMA: 2"; 
extern string c4="MODE_LWMA: 3"; 

extern int ma1=5;
extern int ma1_periode=1;
extern int ma1_methode=1;

extern int ma2=5;
extern int ma2_periode=5;
extern int ma2_methode=1;

extern int ma3=5;
extern int ma3_periode=15;
extern int ma3_methode=1;

double Buf_0[];
double Buf_1[];
double Buf_2[];

                     
//--------------------------------------------------------------------
int init()                         
  {
   IndicatorBuffers(3);
   SetIndexBuffer(0,Buf_0);         
   SetIndexStyle (0,DRAW_LINE,STYLE_SOLID,1);
   SetIndexBuffer(1,Buf_1);         
   SetIndexStyle (1,DRAW_LINE,STYLE_SOLID,1);
   SetIndexBuffer(2,Buf_2);         
   SetIndexStyle (2,DRAW_LINE,STYLE_SOLID,1);
   return;                          
  }
//--------------------------------------------------------------------
int start()                        
  {
   int i,                          
   n,                              
   Counted_bars;                   
   double
   Sum_H,                           
   Sum_L;                          
//--------------------------------------------------------------------
   Counted_bars=IndicatorCounted(); 
   i=Bars-Counted_bars-1;           
               
   while(i>=0)                      
     {
     Buf_0[i]=iMA(Symbol(),ma1_periode,ma1,0,ma2_methode,0,i);
      Buf_1[i]=iMA(Symbol(),ma2_periode,ma2,0,ma2_methode,0,i);
      Buf_2[i]=iMA(Symbol(),ma3_periode,ma3,0,ma2_methode,0,i);
      i--;                          
     }
//--------------------------------------------------------------------
   return;                          
  }
//--------------------------------------------------------------------