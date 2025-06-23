//+------------------------------------------------------------------------+
//|                                              MTF_Alligator+T3a[sw].mq4 |
//|                                                                        |
//|                                        "http://www.forex-tsd.com"   ik |
//+------------------------------------------------------------------------+
#property copyright   "http://www.forex-tsd.com"
#property link      "http://www.forex-tsd.com"
//----
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Teal
#property indicator_color2 MediumSeaGreen
#property indicator_color3 Green
#property indicator_color4 Orchid
#property indicator_color5 MediumOrchid
#property indicator_color6 Purple
//---- input parameters
/*************************************************************************
PERIOD_M1   1
PERIOD_M5   5
PERIOD_M15  15
PERIOD_M30  30 
PERIOD_H1   60
PERIOD_H4   240
PERIOD_D1   1440
PERIOD_W1   10080
PERIOD_MN1  43200
You must use the numeric value of the timeframe that you want to use
when you set the TimeFrame' value with the indicator inputs.
---------------------------------------
PRICE_CLOSE    0 Close price. 
PRICE_OPEN     1 Open price. 
PRICE_HIGH     2 High price. 
PRICE_LOW      3 Low price. 
PRICE_MEDIAN   4 Median price, (high+low)/2. 
PRICE_TYPICAL  5 Typical price, (high+low+close)/3. 
PRICE_WEIGHTED 6 Weighted close price, (high+low+close+close)/4. 
You must use the numeric value of the Applied Price that you want to use
when you set the 'applied_price' value with the indicator inputs.
---------------------------------------
MODE_SMA    0 Simple moving average, 
MODE_EMA    1 Exponential moving average, 
MODE_SMMA   2 Smoothed moving average, 
MODE_LWMA   3 Linear weighted moving average. 
You must use the numeric value of the MA Method that you want to use
when you set the 'ma_method' value with the indicator inputs.
**************************************************************************/
extern int TimeFrame=0;
extern int JawsPeriod=13;
extern int JawsShift=2;
extern int TeethPeriod=8;
extern int TeethShift=1;
extern int LipsPeriod=5;
extern int LipsShift=0;
extern int Band1Period=26;
extern int Band1Shift=3;
extern int Band2Period=34;
extern int Band2Shift=4;
extern int Band3Period=48;
extern int Band3Shift=5;
//----
double ExtBlueBuffer[];
double ExtRedBuffer[];
double ExtLimeBuffer[];
double ExtBand1Buffer[];
double ExtBand2Buffer[];
double ExtBand3Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   
//---- indicator line
   SetIndexBuffer(0,ExtBlueBuffer);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,ExtRedBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(2,ExtLimeBuffer);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(3,ExtBand1Buffer);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(4,ExtBand2Buffer);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(5,ExtBand3Buffer);
   SetIndexStyle(5,DRAW_LINE);
   if(TimeFrame==0) TimeFrame=Period();
   SetIndexShift(0,JawsShift*TimeFrame/Period());
   SetIndexShift(1,TeethShift*TimeFrame/Period());
   SetIndexShift(2,LipsShift*TimeFrame/Period());
   SetIndexShift(3,Band1Shift*TimeFrame/Period());
   SetIndexShift(4,Band2Shift*TimeFrame/Period());
   SetIndexShift(5,Band3Shift*TimeFrame/Period());
//----
   SetIndexDrawBegin(0,JawsShift+JawsPeriod);
   SetIndexDrawBegin(1,TeethShift+TeethPeriod);
   SetIndexDrawBegin(2,LipsShift+LipsPeriod);
   SetIndexDrawBegin(3,Band1Shift+Band1Period);
   SetIndexDrawBegin(4,Band2Shift+Band2Period);
   SetIndexDrawBegin(5,Band3Shift+Band3Period);
//---- name for DataWindow and indicator subwindow label   
   switch(TimeFrame)
     {
      case 1 : string TimeFrameStr="Period_M1"; break;
      case 5 : TimeFrameStr="Period_M5"; break;
      case 15 : TimeFrameStr="Period_M15"; break;
      case 30 : TimeFrameStr="Period_M30"; break;
      case 60 : TimeFrameStr="Period_H1"; break;
      case 240 : TimeFrameStr="Period_H4"; break;
      case 1440 : TimeFrameStr="Period_D1"; break;
      case 10080 : TimeFrameStr="Period_W1"; break;
      case 43200 : TimeFrameStr="Period_MN1"; break;
      default : TimeFrameStr="Current Timeframe";
     }
   IndicatorShortName("MTF_Alligator+T3a("+(string)JawsPeriod+","+(string)TeethPeriod+","+(string)LipsPeriod+"("+TimeFrameStr+")");
//----
   SetIndexLabel(0,"MTFGatorJaws "+(string)JawsPeriod+",s"+(string)JawsPeriod+"("+TimeFrameStr+")");
   SetIndexLabel(1,"MTFGatorTeeth "+(string)TeethPeriod+",s"+(string)TeethShift+"("+TimeFrameStr+")");
   SetIndexLabel(2,"MTFGatorLips "+(string)LipsPeriod+",s"+(string)LipsShift+"("+TimeFrameStr+")");
   SetIndexLabel(3,"MTFGatorBand1 "+(string)Band1Period+",s"+(string)Band1Shift+"("+TimeFrameStr+")");
   SetIndexLabel(4,"MTFGatorBand2 "+(string)Band2Period+",s"+(string)Band2Shift+"("+TimeFrameStr+")");
   SetIndexLabel(5,"MTFGatorBand2 "+(string)Band3Period+",s"+(string)Band3Shift+"("+TimeFrameStr+")");
  return(0);
  }
//----
   
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,limit,y=0,counted_bars=IndicatorCounted();
   // Plot defined timeframe on to current timeframe   
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
//----
   limit=Bars-counted_bars;
   for(i=0,y=0;i<limit;i++)
     {
      if (Time[i]<TimeArray[y]) y++;
 /***********************************************************   
   Add your main indicator loop below.  You can reference an existing
   indicator with its iName  or iCustom.
   Rule 1:  Add extern inputs above for all neccesary values   
   Rule 2:  Use 'TimeFrame' for the indicator timeframe
   Rule 3:  Use 'y' for the indicator's shift value
 **********************************************************/
      ExtBlueBuffer [i]=iMA(NULL,TimeFrame,JawsPeriod,JawsShift, MODE_SMMA,PRICE_MEDIAN,y);
      ExtRedBuffer[i]=iMA(NULL,TimeFrame,TeethPeriod,TeethShift, MODE_SMMA,PRICE_MEDIAN,y);
      ExtLimeBuffer[i]=iMA(NULL,TimeFrame,LipsPeriod,LipsShift, MODE_SMMA,PRICE_MEDIAN,y);
      ExtBand1Buffer[i]=iMA(NULL,TimeFrame,Band1Period,Band1Shift, MODE_SMMA,PRICE_CLOSE,y);
      ExtBand2Buffer[i]=iMA(NULL,TimeFrame,Band2Period,Band2Shift, MODE_SMMA,PRICE_CLOSE,y);
      ExtBand3Buffer[i]=iMA(NULL,TimeFrame,Band3Period,Band3Shift, MODE_SMMA,PRICE_CLOSE,y);
     }
   //----     
   return(0);
  }
//+------------------------------------------------------------------+