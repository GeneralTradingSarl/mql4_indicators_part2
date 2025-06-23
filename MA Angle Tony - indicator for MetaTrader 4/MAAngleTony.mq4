//+------------------------------------------------------------------+
//|                                                                  |
//|                 Copyright © 1999-2008, MetaQuotes Software Corp. |
//|                                         http://www.metaquotes.ru |
//+------------------------------------------------------------------+
#property  copyright "jpkfox"
#property  link      "http://www.strategybuilderfx.com/forums/showthread.php?t=15274&page=1&pp=8"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 3
//----
#property  indicator_color1  LimeGreen
#property  indicator_color2  FireBrick
#property  indicator_color3 Yellow
//---- indicator parameters
extern int MAMode=1;
extern int MAPeriod=34;
extern int Price=0;
extern double AngleMin=0.0020;
//---- indicator buffers
double UpBuffer[];
double DownBuffer[];
double ZeroBuffer[];
double Angle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(3);
//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,4);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,4);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,4);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);
//---- 3 indicator buffers mapping
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DownBuffer);
   SetIndexBuffer(2,ZeroBuffer);
//---- name for DataWindow and indicator subwindow label
   //IndicatorShortName("MAAngle("+MAPeriod+","+AngleTreshold+","+StartMAShift+","+EndMAShift+")");
   IndicatorShortName("MAAngle");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| The angle for EMA                                                |
//+------------------------------------------------------------------+
int start()
  {
   double mFactor, dFactor;
   int i;
   string Sym;
   if (MAMode>=4) MAMode=0; 
   
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit--;
      
   dFactor=2*3.14159/180.0;
   mFactor=10000.0;
   Sym=StringSubstr(Symbol(),3,3);
//---- main loop
   for(i=0; i<limit; i++)
     {
      DownBuffer[i]=0.0;
      UpBuffer[i]=0.0;
      ZeroBuffer[i]=0.0;
//----
      Angle=iMA(NULL,0,MAPeriod,0,MAMode,Price,i)-iMA(NULL,0,MAPeriod,0,MAMode,Price,i+1);
      if(Angle>AngleMin)
         UpBuffer[i]=1;
      else if (Angle<-AngleMin)
            DownBuffer[i]=-1;
         else ZeroBuffer[i]=0.5;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+

