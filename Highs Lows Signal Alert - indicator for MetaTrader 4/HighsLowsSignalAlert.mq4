//+------------------------------------------------------------------+
//|                                         HighsLowsSignalAlert.mq4 |
//|         Copyright © 2006, Robert Hill                            |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Allows you to enter a number and it will then show you at        |
//| which point that many higher highs/higher lows or                |
//| lower highs/lower lows candles occur.                            |
//| It also give an alert if the current bar has the                 |
//| required number of candles before it.                            |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Robert Hill"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrLawnGreen
#property indicator_color2 clrRed
#property indicator_width1 3
#property indicator_width2 3
//----
extern bool SoundON=true;
extern int HowManyCandles=3;
//----
double TrendUp[];
double TrendDown[];
double alertTag;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_ARROW,EMPTY,3);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,TrendUp);
   SetIndexStyle(1,DRAW_ARROW,EMPTY,3);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,TrendDown);
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
   double Range,AvgRange;
   int HigherHighs,HigherLows;
   int LowerHighs,LowerLows;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
//----
   limit=Bars-counted_bars;
   if(counted_bars==0) limit-=10;
//----
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
      HigherHighs=0;
      HigherLows=0;
      LowerHighs=0;
      LowerLows=0;
      for(counter=i;counter<i+HowManyCandles;counter++)
        {
         if(High[counter]>High[counter+1]) HigherHighs++;
         if(Low[counter]>Low[counter+1]) HigherLows++;
         if(High[counter]<High[counter+1]) LowerHighs++;
         if(Low[counter]<Low[counter+1]) LowerLows++;
        }
      if(HigherHighs==HowManyCandles && HigherLows==HowManyCandles)
        {
         TrendUp[i]=Low[i]-Range*0.75;
         if(alertTag!=Time[0])
           {
            PlaySound("news.wav");// buy wav
            Alert(Symbol(),"  M",Period(),HowManyCandles," HigherHighs/HigherLows");
           }
         alertTag=Time[0];
        }
      else if(LowerHighs==HowManyCandles && LowerLows==HowManyCandles)
        {
         TrendDown[i]=High[i] + Range*0.75;
         if(alertTag!=Time[0])
           {
            PlaySound("news.wav"); //sell wav
            Alert(Symbol(),"  M",Period(),HowManyCandles," LowerHighs/LowerLows");
           }
         alertTag=Time[0];
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
