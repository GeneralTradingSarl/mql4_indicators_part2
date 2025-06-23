//+------------------------------------------------------------------+
//|                 This has been coded by MT-Coder                  |
//|                                                                  |
//|                     Email: mt-coder@hotmail.com                  |
//|                      Website: mt-coder.110mb.com                 |
//|                                                                  |
//| For a price I can code for you any strategy you have in mind     |
//|            into EA, I can code any indicator you have in mind    |
//|                                                                  |
//|          Don't hesitate to contact me at mt-coder@hotmail.com    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|      This indicator trys to indentify the dominanting power in   |
//|            the market.                                           |
//+------------------------------------------------------------------+


#property copyright "Copyright © 2009, MT-Coder."
#property link      "http://mt-coder.110mb.com/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 White

//---- input parameters
extern int HBBPeriod=500;
extern int PeriodOne=2;
extern int PeriodTwo=7;

//---- buffers
double MainBuffer[];
double TempBuffer[];
double TempBufferTwo[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
   //---- 1 additional buffer used for counting.
   IndicatorBuffers(3);
   IndicatorDigits(Digits);
//---- indicator line
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,MainBuffer);
   SetIndexBuffer(1,TempBuffer);
   SetIndexBuffer(2,TempBufferTwo);
  
   
//---- name for DataWindow and indicator subwindow label
   short_name="H Bulls n Bears by MT-Coder("+PeriodOne+","+PeriodTwo+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"PeriodOne");
   SetIndexLabel(1,"PeriodTwo");
  
//----
   SetIndexDrawBegin(0,HBBPeriod);
  

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| H Bulls n Bears                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int i,counted_bars=IndicatorCounted();
//----
   if(Bars<=HBBPeriod) return(0);

//----
   int limit=Bars-counted_bars;
   if(counted_bars>0) limit++;
   for(i=0; i<limit; i++)
      TempBuffer[i]=iMA(NULL,0,PeriodOne,0,MODE_SMA,PRICE_WEIGHTED,i);
//----
//----
   int limito=Bars-counted_bars;
   if(counted_bars>0) limito++;
   for(i=0; i<limito; i++)
      TempBufferTwo[i]=iMA(NULL,0,PeriodTwo,0,MODE_SMA,PRICE_WEIGHTED,i);
//----
   i=Bars-HBBPeriod-1;
   if(counted_bars>=HBBPeriod) i=Bars-counted_bars-1;
   while(i>=0)
     {

      MainBuffer[i]=(TempBuffer[i] / TempBufferTwo[i])-1;
      
      //another version
      //MainBuffer[i]=MathPow(TempBuffer[i+PeriodOne],5)/MathPow(TempBuffer[i+PeriodTwo],5); 
      
      i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+