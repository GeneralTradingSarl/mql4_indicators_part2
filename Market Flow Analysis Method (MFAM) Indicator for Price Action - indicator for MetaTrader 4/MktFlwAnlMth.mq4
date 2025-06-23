//+----------------------------------------+
//|                  BREW_MktFlwAnlMth.mq4 |
//| Market Flow Analysis Method            |
//| http://www.forexforprofits.com         |
//+----------------------------------------+
#property  copyright "Copyright © 2011, Brewmanz"
#property link      "http://www.metaquotes.net/"

//#property indicator_separate_window
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Lime
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_color2 Cyan
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_color3 Red
#property indicator_style3 STYLE_SOLID
#property indicator_width3 2
#property indicator_color4 Magenta
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

#property indicator_color5 Lime
#property indicator_style5 STYLE_SOLID
#property indicator_width5 2
#property indicator_color6 Cyan
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_color7 Red
#property indicator_style7 STYLE_SOLID
#property indicator_width7 2
#property indicator_color8 Magenta
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1

//#include <LibUtil.mqh>

//---- input parameters
extern string Comment1="Set UseSeparateChartAges to true to show how Highest High etc Bar Aging is working";
extern bool UseSeparateChartAges=false;
extern string Comment2="Set MaxAge to limit how long a Highest High etc is valid for";
extern int  MaxAge=999;

//---- display buffers
double buff_BarsSinceLastHH[];
double buff_BarsSinceHHAfterLL[];
double buff_BarsSinceLastLL[];
double buff_BarsSinceLLAfterHH[];

double buff_HH[];
double buff_HAfterL[];
double buff_LL[];
double buff_LAfterH[];

double buff_DBG[];

//---- work buffers
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   string short_name;
   IndicatorBuffers(8);
   IndicatorDigits(Digits);
//---- indicator line

   SetIndexBuffer(0,buff_BarsSinceLastHH);
   SetIndexBuffer(1,buff_BarsSinceHHAfterLL);
   SetIndexBuffer(2,buff_BarsSinceLastLL);
   SetIndexBuffer(3,buff_BarsSinceLLAfterHH);
   SetIndexBuffer(4,buff_HH);
   SetIndexBuffer(5,buff_HAfterL);
   SetIndexBuffer(6,buff_LL);
   SetIndexBuffer(7,buff_LAfterH);
   if(UseSeparateChartAges)
   {
      SetIndexStyle( 0,DRAW_LINE);
      SetIndexStyle( 1,DRAW_LINE);
      SetIndexStyle( 2,DRAW_LINE);
      SetIndexStyle( 3,DRAW_LINE);
      SetIndexStyle( 4,DRAW_NONE);
      SetIndexStyle( 5,DRAW_NONE);
      SetIndexStyle( 6,DRAW_NONE);
      SetIndexStyle( 7,DRAW_NONE);
   }
   else
   {
      SetIndexStyle( 0,DRAW_NONE);
      SetIndexStyle( 1,DRAW_NONE);
      SetIndexStyle( 2,DRAW_NONE);
      SetIndexStyle( 3,DRAW_NONE);
      SetIndexStyle( 4,DRAW_LINE);
      SetIndexStyle( 5,DRAW_LINE);
      SetIndexStyle( 6,DRAW_LINE);
      SetIndexStyle( 7,DRAW_LINE);
   }

//---- name for DataWindow and indicator subwindow label
   short_name="MFAM("
   +")";

   IndicatorShortName(""+short_name);
   SetIndexLabel(0,"AgeHH");
   SetIndexLabel(1,"HH_AfterLL");
   SetIndexLabel(2,"AgeLL");
   SetIndexLabel(3,"LL_AfterHH");
   SetIndexLabel(4,"HH");
   SetIndexLabel(5,"HAfterL");
   SetIndexLabel(6,"LL");
   SetIndexLabel(7,"LAfterH");
//----
//   SetIndexDrawBegin(0,MaPeriod);
//----
   return(0);
}
//+------------------------------------------------------------------+
int start()
{

   int ix,ixLimit,counted_bars=IndicatorCounted();
//----
   if(counted_bars>0)counted_bars--;
   ixLimit = Bars-counted_bars-1;
//----
   for(ix=ixLimit;ix>=0;ix--)
   {
      if(ix==Bars-1)
      {
         // FirstEverBar
         buff_BarsSinceLastHH   [ix] = 0;
         buff_BarsSinceHHAfterLL[ix] = 0;
         buff_BarsSinceLastLL   [ix] = 0;
         buff_BarsSinceLLAfterHH[ix] = 0;
         continue;
      }

//--- New Bar?      
      static datetime NewBarTimeCheck = 0;
      bool IsNewBar = false;
      if(NewBarTimeCheck!=Time[ix])
      {  
         IsNewBar = true;
         NewBarTimeCheck = Time[ix];
      }

      // up age of all bars
      int barsToLastHH    = 1 + buff_BarsSinceLastHH   [ix+1];
      int barsToHHSinceLL = 1 + buff_BarsSinceHHAfterLL[ix+1];
      int barsToLastLL    = 1 + buff_BarsSinceLastLL   [ix+1];
      int barsToLLSinceHH = 1 + buff_BarsSinceLLAfterHH[ix+1];

      // note any extreme price action
      if(High[ix] > High[ix+barsToLastHH])
         barsToLastHH = 0;
      if(High[ix] > High[ix+barsToHHSinceLL])
         barsToHHSinceLL = 0;
      
      if(Low[ix] < Low[ix+barsToLastLL])
         barsToLastLL = 0;
      if(Low[ix] < Low[ix+barsToLLSinceHH])
         barsToLLSinceHH = 0;
         
      // check if Max Age has been exceeded
      if(barsToLastHH    > MaxAge)
         barsToLastHH    = iHighest(NULL, Period(), MODE_HIGH, MaxAge, ix) - ix;
      if(barsToHHSinceLL > MaxAge)
         barsToHHSinceLL = iHighest(NULL, Period(), MODE_HIGH, MaxAge, ix) - ix;
      if(barsToLastLL    > MaxAge)
         barsToLastLL    = iLowest (NULL, Period(), MODE_LOW,  MaxAge, ix) - ix;
      if(barsToLLSinceHH > MaxAge)
         barsToLLSinceHH = iLowest (NULL, Period(), MODE_LOW,  MaxAge, ix) - ix;
      
      // check new HH then we have new Active Lo created
      switch(barsToLastHH)
      {
      case 0:
         barsToLastLL = barsToLLSinceHH;
         break;
      case 1:
         barsToLLSinceHH = 0;
         break;
      }

      // check new LL then we have new Active Hi created
      switch(barsToLastLL)
      {
      case 0:
         barsToLastHH = barsToHHSinceLL;
         break;
      case 1:
         barsToHHSinceLL = 0;
         break;
      }

      buff_BarsSinceLastHH   [ix] = barsToLastHH;
      buff_BarsSinceHHAfterLL[ix] = barsToHHSinceLL;
      buff_BarsSinceLastLL   [ix] = barsToLastLL;
      buff_BarsSinceLLAfterHH[ix] = barsToLLSinceHH;
         
      buff_HH     [ix] = High[ix + barsToLastHH];
      buff_HAfterL[ix] = High[ix + barsToHHSinceLL];
      buff_LL     [ix] = Low [ix + barsToLastLL];
      buff_LAfterH[ix] = Low [ix + barsToLLSinceHH];
   }
//----
   return(0);
}
//+------------------------------------------------------------------+