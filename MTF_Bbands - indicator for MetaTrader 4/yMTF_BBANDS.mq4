//+------------------------------------------------------------------+
//|                                              #MTF_HULL_TREND.mq4 |
//|------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 6
//----
#property indicator_color1 LightSkyBlue
#property indicator_color2 MistyRose
#property indicator_color3 LightSkyBlue
#property indicator_color4 MistyRose
#property indicator_color5 LightSkyBlue
#property indicator_color6 MistyRose
//----
#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 4
#property indicator_width5 4
#property indicator_width6 4
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
---------------------------------------*/
extern int    TimeFrame=60;
//---- input parameters
extern int    Length=20;      // Bollinger Bands Period
extern int    Deviation=1;    // Deviation was 2
extern double MoneyRisk=1.00; // Offset Factor
extern int    Signal=1;       // Display signals mode: 1-Signals & Stops; 0-only Stops; 2-only Signals;
extern int    Line=1;         // Display line mode: 0-no,1-yes  
extern int    Nbars=1000;
//---- indicator buffers
double UpTrendBuffer[];
double DownTrendBuffer[];
double UpTrendSignal[];
double DownTrendSignal[];
double UpTrendLine[];
double DownTrendLine[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
  {
//---- indicator buffers
//---- indicator line
   SetIndexBuffer(0,UpTrendBuffer);
   SetIndexBuffer(1,DownTrendBuffer);
   SetIndexBuffer(2,UpTrendSignal);
   SetIndexBuffer(3,DownTrendSignal);
   SetIndexBuffer(4,UpTrendLine);
   SetIndexBuffer(5,DownTrendLine);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexArrow(0,159);
   SetIndexArrow(1,159);
   SetIndexArrow(2,108);
   SetIndexArrow(3,108);
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
   IndicatorShortName("#MTF_BBANDS~1("+TimeFrameStr+")");
   return(0);
  }
//----
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,y=0;

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit--;

// Plot defined time frame on to current time frame
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
   for(i=0,y=0;i<limit;i++)
     {
      if(y<ArraySize(TimeArray)){ if(Time[i]<TimeArray[y]) y++;}
/***********************************************************   
   Add your main indicator loop below.  You can reference an existing
   indicator with its iName  or iCustom.
   Rule 1:  Add extern inputs above for all neccesary values   
   Rule 2:  Use 'TimeFrame' for the indicator time frame
   Rule 3:  Use 'y' for your indicator's shift value
**********************************************************/
      UpTrendBuffer[i]=iCustom(Symbol(),TimeFrame,"BBANDS",0,y);
      DownTrendBuffer[i]=iCustom(Symbol(),TimeFrame,"BBANDS",1,y);
      UpTrendSignal[i]=iCustom(Symbol(),TimeFrame,"BBANDS",2,y);
      DownTrendSignal[i]=iCustom(Symbol(),TimeFrame,"BBANDS",3,y);
      UpTrendLine[i]=iCustom(Symbol(),TimeFrame,"BBANDS",4,y);
      DownTrendLine[i]=iCustom(Symbol(),TimeFrame,"BBANDS",5,y);
     }
   return(0);
  }
//+------------------------------------------------------------------+
