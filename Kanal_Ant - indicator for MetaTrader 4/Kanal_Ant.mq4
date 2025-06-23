//+------------------------------------------------------------------+
//|                                                    Kanal_Ant.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|                       red. Stajer59, http://www.stajer59.ucoz.ru |
//|                                      (orig.: Envelopes.mq4)      |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_color5 Blue
#property indicator_color6 Red
#property indicator_color7 Teal
//---- indicator parameters
extern int     BarsCount = 500;
extern int MA_Period=55;
extern int MA_Shift=0;
extern int MA_Method=0;
extern int Applied_Price=0;
extern int     fontsize=7;
extern double Deviation=1;
//---- indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   int    draw_begin;
   string short_name;
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE,OBJPROP_WIDTH,2);
   SetIndexStyle(5,DRAW_LINE,OBJPROP_WIDTH,2);
   SetIndexStyle(6,DRAW_LINE,OBJPROP_WIDTH,2);
   SetIndexShift(0,MA_Shift);
   SetIndexShift(1,MA_Shift);
   SetIndexShift(2,MA_Shift);
   SetIndexShift(3,MA_Shift);
   SetIndexShift(4,MA_Shift);
   SetIndexShift(5,MA_Shift);
   SetIndexShift(6,MA_Shift);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   if(MA_Period<2) MA_Period=14;
   draw_begin=MA_Period-1;
//---- indicator short name
   IndicatorShortName("Env("+MA_Period+")");
   SetIndexLabel(0,"Env("+MA_Period+")U1");
   SetIndexLabel(1,"Env("+MA_Period+")D1");
   SetIndexLabel(2,"Env("+MA_Period+")U2");
   SetIndexLabel(3,"Env("+MA_Period+")D2");
   SetIndexLabel(4,"Env("+MA_Period+")U3");
   SetIndexLabel(5,"Env("+MA_Period+")D3");
   SetIndexLabel(6,"MA("+MA_Period+")");
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   SetIndexDrawBegin(3,draw_begin);
   SetIndexDrawBegin(4,draw_begin);
   SetIndexDrawBegin(5,draw_begin);
   SetIndexDrawBegin(6,draw_begin);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexBuffer(6,ExtMapBuffer7);
   
   ObjectCreate("l1", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("l1", "U1",fontsize,"Arial",Blue);
   ObjectCreate("l2", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("l2", "D1",fontsize,"Arial",Red);
   ObjectCreate("l3", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("l3", "U2",fontsize,"Arial",Blue);
   ObjectCreate("l4", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("l4", "D2",fontsize,"Arial",Red);
   ObjectCreate("l5", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("l5", "U3",fontsize,"Arial",Blue);
   ObjectCreate("l6", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("l6", "D3",fontsize,"Arial",Red);
   ObjectCreate("l7", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("l7", "LB",fontsize,"Arial",Teal);
   
   if(Deviation<0.1) Deviation=0.1;
   if(Deviation>100.0) Deviation=100.0;
//---- initialization done
   return(0);
  }
  
  //+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("l1");
   ObjectDelete("l2");
   ObjectDelete("l3");
   ObjectDelete("l4");
   ObjectDelete("l5");
   ObjectDelete("l6");
   ObjectDelete("l7");
   
   return(0);
  }
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   if(Bars<=MA_Period) return(0);
   ExtCountedBars=IndicatorCounted();
//---- check for possible errors
   if (ExtCountedBars<0) return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;
   limit=Bars-ExtCountedBars;
//---- EnvelopesM counted in the buffers
   for(int i=0; i<limit; i++)
     { 
      ExtMapBuffer1[i] = (1+Deviation*0.382/100)*iMA(NULL,0,MA_Period,0,MA_Method,Applied_Price,i);
      ExtMapBuffer2[i] = (1-Deviation*0.382/100)*iMA(NULL,0,MA_Period,0,MA_Method,Applied_Price,i);
      ExtMapBuffer3[i] = (1+Deviation*0.618/100)*iMA(NULL,0,MA_Period,0,MA_Method,Applied_Price,i);
      ExtMapBuffer4[i] = (1-Deviation*0.618/100)*iMA(NULL,0,MA_Period,0,MA_Method,Applied_Price,i);
      ExtMapBuffer5[i] = (1+Deviation/100)*iMA(NULL,0,MA_Period,0,MA_Method,Applied_Price,i);
      ExtMapBuffer6[i] = (1-Deviation/100)*iMA(NULL,0,MA_Period,0,MA_Method,Applied_Price,i);
      ExtMapBuffer7[i] = iMA(NULL,0,MA_Period,0,MA_Method,Applied_Price,i);
     }
     
   ObjectMove("l1", 0, Time[0],ExtMapBuffer1[0]);
   ObjectMove("l2", 0, Time[0],ExtMapBuffer2[0]);
   ObjectMove("l3", 0, Time[0],ExtMapBuffer3[0]);
   ObjectMove("l4", 0, Time[0],ExtMapBuffer4[0]);
   ObjectMove("l5", 0, Time[0],ExtMapBuffer5[0]);
   ObjectMove("l6", 0, Time[0],ExtMapBuffer6[0]);
   ObjectMove("l7", 0, Time[0],ExtMapBuffer7[0]);
     
//---- done
   return(0);
  }
//+------------------------------------------------------------------+