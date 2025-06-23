//+------------------------------------------------------------------+
//|                                                          111.mq4 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Yellow
#property indicator_color3 Red
#property indicator_color4 Blue

//extern int MAMetod = 0;
extern int MAPeriod = 14;
extern int KPeriod = 14;
extern bool ShowDif = true;
extern bool ShowMUV = true;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//double ExtMapBuffer1[];
//double ExtMapBuffer2[];
//double K[];
double K0[];
double K1[];
double K2[];
double K3[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
IndicatorBuffers(8); 
   if (ShowDif) {SetIndexStyle(0,DRAW_LINE); SetIndexStyle(1,DRAW_LINE);} 
   else {SetIndexStyle(0,DRAW_NONE); SetIndexStyle(1,DRAW_NONE);}
   if (ShowMUV) {SetIndexStyle(2,DRAW_LINE); SetIndexStyle(3,DRAW_LINE);} 
   else {SetIndexStyle(2,DRAW_NONE); SetIndexStyle(3,DRAW_NONE);}   
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);   
   SetIndexBuffer(4,K0);   
   SetIndexBuffer(5,K1); 
   SetIndexBuffer(6,K2);   
   SetIndexBuffer(7,K3);      
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+1;
//----

  for (int i = limit;i >=0; i--)
  {

  K0[i] = iCustom(NULL,0,"MUV",MAPeriod,0,1,i)-iCustom(NULL,0,"MUV",MAPeriod,0,1,i+1);
  K1[i] = iCustom(NULL,0,"MUV",MAPeriod,1,1,i)-iCustom(NULL,0,"MUV",MAPeriod,1,1,i+1);
  K2[i] = iCustom(NULL,0,"MUV",MAPeriod,0,1,i);
  K3[i] = iCustom(NULL,0,"MUV",MAPeriod,1,1,i);
  
  double K0mx = K0[ArrayMaximum(K0,KPeriod,i)];
  double K0mm = K0[ArrayMinimum(K0,KPeriod,i)]; 
    
  double K1mx = K1[ArrayMaximum(K1,KPeriod,i)];
  double K1mm = K1[ArrayMinimum(K1,KPeriod,i)];
    
  double K2mx = K2[ArrayMaximum(K2,MAPeriod,i)];
  double K2mm = K2[ArrayMinimum(K2,MAPeriod,i)];
    
  double K3mx = K3[ArrayMaximum(K3,MAPeriod,i)];
  double K3mm = K3[ArrayMinimum(K3,MAPeriod,i)]; 
  
  if ((K0mx - K0mm)>0) double k0 = 1-((K0mx-K0[i])/(K0mx-K0mm)); else k0 = 1;        
  if ((K1mx - K1mm)>0) double k1 = 1-((K1mx-K1[i])/(K1mx-K1mm)); else k1 = 1;
  if ((K2mx - K2mm)>0) double k2 = 1-((K2mx-K2[i])/(K2mx-K2mm)); else k2 = 0;
  if ((K3mx - K3mm)>0) double k3 = 1-((K3mx-K3[i])/(K3mx-K3mm)); else k3 = 0;

  ExtMapBuffer1[i] = k0;
  ExtMapBuffer2[i] = k1;
  ExtMapBuffer3[i] = k2;
  ExtMapBuffer4[i] = k3;
  }
//----
   return(0);
  }
//+------------------------------------------------------------------+