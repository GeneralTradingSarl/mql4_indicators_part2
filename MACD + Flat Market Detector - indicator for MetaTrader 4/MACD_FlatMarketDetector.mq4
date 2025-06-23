//+------------------------------------------------------------------+
//| MACD_FlatMarketDetector.mq4
//| Copyright http://www.pointzero-indicator.com
//+------------------------------------------------------------------+
#property copyright "Copyright © Pointzero-indicator.com"
#property link      "http://www.pointzero-indicator.com"

//---- Properties
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 DodgerBlue
#property indicator_color2 Red
#property indicator_color3 DarkSlateGray
#property indicator_color4 DarkSlateGray
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 1
#property indicator_width4 1
#property indicator_style3 STYLE_DOT
#property indicator_style4 STYLE_DOT

//---- External variables
extern bool   CalculateOnBarClose = true;
extern int    FastEMA             = 9;
extern int    SlowEMA             = 26;
extern int    AvPeriod            = 400;
extern double Gamma               = 0.75;

//---- Buffers
double FextMapBuffer1[];
double FextMapBuffer2[];
double FextMapBuffer3[];
double FextMapBuffer4[];
double FextMapBuffer5[];
double FextMapBuffer6[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
{
   // Total buffers
   IndicatorBuffers(6);
   
   // Visible buffers
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0, FextMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1, FextMapBuffer2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,FextMapBuffer3);    
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,FextMapBuffer4); 
   
   // Internal  
   SetIndexBuffer(4,FextMapBuffer5);  
   SetIndexBuffer(5,FextMapBuffer6);       
   
   // My name
   IndicatorShortName("MACD + Flat Market Detector ("+ FastEMA +","+ SlowEMA +")");
   Comment("Copyright © http://www.pointzero-indicator.com");
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   // Start, limit1, etc..
   int start = 0;
   int limit;
   int counted_bars = IndicatorCounted();
   
   // nothing else to do?
   if(counted_bars < 0) 
       return(-1);

   // do not check repeated bars
   limit = Bars - 1 - counted_bars;
   if(counted_bars==0) limit-=1+1;
   // Check if ignore bar 0
   if(CalculateOnBarClose == true) { start = 1; }
   
   // Iteration from past to present
   for(int pos = limit; pos >= start; pos--)
   {  
      // Median
      double median  = iMACD(NULL,0, FastEMA, SlowEMA, 4, PRICE_MEDIAN, MODE_MAIN, pos);
      double median1 = iMACD(NULL,0, SlowEMA, SlowEMA, 4, PRICE_MEDIAN, MODE_MAIN, pos+1);
     
      // Difference
      FextMapBuffer6[pos] = median - median1;
      
      // Save current absolute value
      FextMapBuffer5[pos] = MathAbs(FextMapBuffer6[pos]);
   }
      
   for(pos = limit; pos >= start; pos--)
   {  
      // Flat lines
      double flat = iMAOnArray(FextMapBuffer5, Bars, AvPeriod, 0, MODE_EMA, pos);
      FextMapBuffer3[pos] = (flat * Gamma);
      FextMapBuffer4[pos] = 0 - (flat * Gamma);
      
      //---- Deceleration
      if(FextMapBuffer6[pos] < FextMapBuffer6[pos+1])
      {
         // This is a red line
         FextMapBuffer2[pos] = FextMapBuffer6[pos];
         FextMapBuffer1[pos] = 0;
         
      //---- Acceleration
      } else if(FextMapBuffer6[pos] > FextMapBuffer6[pos+1]){
         
         // This is a blue line
         FextMapBuffer1[pos] = FextMapBuffer6[pos];
         FextMapBuffer2[pos] = 0;
      }
   }
   return(0);
}

