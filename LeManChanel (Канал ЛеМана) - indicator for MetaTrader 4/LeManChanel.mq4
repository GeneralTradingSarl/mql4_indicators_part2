//+------------------------------------------------------------------+
//|                                                  LeManChanel.mq4 |
//|                                         Copyright © 2009, LeMan. |
//|                                                 b-market@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, LeMan."
#property link      "b-market@mail.ru"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Violet
#property indicator_color2 Violet
#property indicator_width1 1
#property indicator_width2 1
#property indicator_style1 0
#property indicator_style2 0
//----
extern int N=12;
//----
double Up[];
double Down[];
double hoBuffer[];
double olBuffer[];
//+------------------------------------------------------------------+
int init() 
  {
//----
   string short_name;
   short_name="LeManChanel ("+N+")";
//----
   IndicatorDigits(Digits);
   IndicatorBuffers(4);
//----      
   SetIndexBuffer(0,Up);
   SetIndexBuffer(1,Down);
   SetIndexBuffer(2,hoBuffer);
   SetIndexBuffer(3,olBuffer);

   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
//----
   SetIndexDrawBegin(0,N);
   SetIndexDrawBegin(1,N);
   SetIndexShift(0,1);
   SetIndexShift(1,1);
//----   
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Up");
   SetIndexLabel(1,"Dn");
//----   
   return(0);
  }
//+------------------------------------------------------------------+
int start() 
  {
   int i,limit,mho,mol;
   if(Bars<=N) return(0);

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit-=2+N;

   for(i = limit-1; i >= 0; i--) hoBuffer[i] = High[i]-Close[i+1];
   for(i = limit-1; i >= 0; i--) olBuffer[i] = Close[i+1]-Low[i];

   for(i=limit-1; i>=0; i--) 
     {
      mho = ArrayMaximum(hoBuffer,N,i);
      mol = ArrayMaximum(olBuffer,N,i);
      Up[i]=Close[i]+hoBuffer[mho];
      Down[i]=Close[i]-olBuffer[mol];
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
