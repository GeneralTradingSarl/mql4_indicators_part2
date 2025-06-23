//+------------------------------------------------------------------+
//|                                                   machXalert.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow
#property indicator_color2 Red
//----
#property indicator_width1 2
#property indicator_width2 2
//----
double CrossUp[];
double CrossDown[];
//----
extern int FasterSMA       =12;
extern int FASTER_SMA_SHIFT=3;
extern int SlowerSMA       =25;
extern int SLOWER_SMA_SHIFT=5;
extern bool Alerts=true;
//----
int upalert=true,downalert=true;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW,EMPTY);
   SetIndexArrow(0,74);
   SetIndexBuffer(0,CrossUp);
   SetIndexStyle(1,DRAW_ARROW,EMPTY);
   SetIndexArrow(1,74);
   SetIndexBuffer(1,CrossDown);
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
   int limit,i,counter;
   double fasterSMAnow,slowerSMAnow,fasterSMAprevious,slowerSMAprevious,fasterSMAafter,slowerSMAafter;
   double Range,AvgRange;

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+MathMax(9,MathMax(FasterSMA,SlowerSMA));

   for(i=0; i<=limit; i++)
     {
      counter=i;
      Range=0;
      AvgRange=0;
      for(counter=i;counter<=i+9;counter++)
        {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
        }
      Range=AvgRange/10;
      //----
      fasterSMAnow=iMA(NULL,0,FasterSMA,FASTER_SMA_SHIFT,MODE_SMA,PRICE_CLOSE,i);
      fasterSMAprevious=iMA(NULL,0,FasterSMA,FASTER_SMA_SHIFT,MODE_SMA,PRICE_CLOSE,i+1);
      fasterSMAafter=iMA(NULL,0,FasterSMA,FASTER_SMA_SHIFT,MODE_SMA,PRICE_CLOSE,i-1);
      slowerSMAnow=iMA(NULL,0,SlowerSMA,SLOWER_SMA_SHIFT,MODE_SMA,PRICE_CLOSE,i);
      slowerSMAprevious=iMA(NULL,0,SlowerSMA,SLOWER_SMA_SHIFT,MODE_SMA,PRICE_CLOSE,i+1);
      slowerSMAafter=iMA(NULL,0,SlowerSMA,SLOWER_SMA_SHIFT,MODE_SMA,PRICE_CLOSE,i-1);
      //----
      if((fasterSMAnow>slowerSMAnow) && (fasterSMAprevious<slowerSMAprevious) && (fasterSMAafter>slowerSMAafter))
        {
         CrossUp[i]=Low[i]-Range*0.5;
         if(i<=2 && Alerts && !upalert)
           {
            Alert(Symbol()," ",Period(),"M  SMACross UP ");
            //SendMail("SMA Cross Up on "+Symbol(),"");
            upalert=true;
            downalert=false;
           }
        }
      else if((fasterSMAnow<slowerSMAnow) && (fasterSMAprevious>slowerSMAprevious) && (fasterSMAafter<slowerSMAafter))
        {
         CrossDown[i]=High[i]+Range*0.5;
         if(i<=2 && Alerts && !downalert)
           {
            Alert(Symbol()," ",Period(),"M  SMACross DOWN ");
            //SendMail("SMA Cross Down on "+Symbol(),"");
            downalert=true;
            upalert=false;
           }
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
