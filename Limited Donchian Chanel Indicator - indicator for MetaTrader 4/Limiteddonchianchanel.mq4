//+------------------------------------------------------------------+
//|                                        Limiteddonchianchanel.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 DarkKhaki
#property  indicator_width1 2
#property  indicator_width2 2
#property  indicator_width3 1
//---- indicator parameters
extern int periods=50;
extern int distance=200;
extern bool fixed=false;
//---- indicator buffers
double upper[];
double lower[];
double middle[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
   {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE,STYLE_DOT);
//---- indicator buffers mapping
   SetIndexBuffer(0,upper);
   SetIndexBuffer(1,lower);
   SetIndexBuffer(2,middle);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Limited Donchian Chanel("+periods+")");
   SetIndexLabel(0,"Upper");
   SetIndexLabel(1,"Lower");
   SetIndexLabel(2,"Middle");
//---- initialization done
   return(0);
   }
//+------------------------------------------------------------------+
//| Custom indicator start function                                  |
//+------------------------------------------------------------------+
int start()
   {
     
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int i = Bars - counted_bars;
   if(counted_bars==0) i-=1+1;
   
   while(i>=0)
      {
      double u=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,periods,i));
      double l=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,periods,i));
      if(iHigh(NULL,0,i)>upper[i+1] || iLow(NULL,0,i)<lower[i+1])
         {
         if(iHigh(NULL,0,i)>upper[i+1])
            {
            upper[i]=iHigh(NULL,0,i);
            if(upper[i]-lower[i+1]>distance*Point)
               lower[i]=upper[i]-distance*Point;
            else
               lower[i]=lower[i+1];
            }
         if(iLow(NULL,0,i)<lower[i+1])
            {
            lower[i]=iLow(NULL,0,i);
            if(upper[i]-lower[i+1]>distance*Point)
               upper[i]=lower[i]+distance*Point;
            else
               upper[i]=upper[i+1];
            }
         }
      else
         {
         upper[i]=upper[i+1];
         lower[i]=lower[i+1];
         }
      if(fixed==false)
         {
         if(upper[i]>u)
            upper[i]=u;
         if(lower[i]<l)
            lower[i]=l;
         }   
      middle[i]=(upper[i]+lower[i])/2;
      i--;
      }
   return(0);
   }
//+------------------------------------------------------------------+