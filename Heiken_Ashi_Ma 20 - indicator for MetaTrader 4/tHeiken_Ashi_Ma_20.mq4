//+------------------------------------------------------------------+
//|                                               Heiken Ashi Ma.mq4 |
//|                                                      mod by Raff |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"
//----
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 DarkOrange
#property indicator_color2 Turquoise
#property indicator_color3 Red
#property indicator_color4 RoyalBlue
//---- parameters
extern int MaMetod =1;
extern int MaPeriod=20;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM,0,1,Red);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,1,RoyalBlue);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,3,Red);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_HISTOGRAM,0,3,RoyalBlue);
   SetIndexBuffer(3,ExtMapBuffer4);
//----
   SetIndexDrawBegin(0,5);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);
//---- initialization done
   watermark();
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double maOpen,maClose,maLow,maHigh;
   double haOpen,haHigh,haLow,haClose;
   if(Bars<=10) return(0);
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+1;
   int pos=limit;
   while(pos>=0)
     {
      maOpen=iMA(NULL,0,MaPeriod,0,MaMetod,MODE_OPEN,pos);
      maClose=iMA(NULL,0,MaPeriod,0,MaMetod,MODE_CLOSE,pos);
      maLow=iMA(NULL,0,MaPeriod,0,MaMetod,MODE_LOW,pos);
      maHigh=iMA(NULL,0,MaPeriod,0,MaMetod,MODE_HIGH,pos);
      //----
      haOpen=(ExtMapBuffer3[pos+1]+ExtMapBuffer4[pos+1])/2;
      haClose=(maOpen+maHigh+maLow+maClose)/4;
      haHigh=MathMax(maHigh,MathMax(haOpen,haClose));
      haLow=MathMin(maLow,MathMin(haOpen,haClose));
      if(haOpen<haClose)
        {
         ExtMapBuffer1[pos]=haLow;
         ExtMapBuffer2[pos]=haHigh;
        }
      else
        {
         ExtMapBuffer1[pos]=haHigh;
         ExtMapBuffer2[pos]=haLow;
        }
      ExtMapBuffer3[pos]=haOpen;
      ExtMapBuffer4[pos]=haClose;
      pos--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
void watermark()
  {
   ObjectCreate("fxcruiser",OBJ_LABEL,0,0,0);
   ObjectSetText("fxcruiser","fxcruiser",11,"Lucida Handwriting",RoyalBlue);
   ObjectSet("fxcruiser",OBJPROP_CORNER,2);
   ObjectSet("fxcruiser",OBJPROP_XDISTANCE,5);
   ObjectSet("fxcruiser",OBJPROP_YDISTANCE,10);
   return(0);
  }
//+------------------------------------------------------------------+
