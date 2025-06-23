//+------------------------------------------------------------------+
//|                                                  i4_pivot_v1.mq4 |
//|                                               goldenlion@ukr.net |
//|                                      http://GlobeInvestFund.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright c 2005, goldenlion@ukr.net"
#property link      "http://GlobeInvestFund.com/"
//----
#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Yellow
#property indicator_color2 Blue
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_color6 White
#property indicator_color7 White
//---- input parameters
//---- buffers
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double Buffer5[];
double Buffer6[];
double Buffer7[];
//---------
// ‘Œ–Ã”À€:
//
//P = (yesterday_high + yesterday_low + yesterday_close + yesterday_close) / 4;
//
//R1 = P + P - yesterday_low;	
//S1 = P + P - yesterday_high;
//
//R2 = P + yesterday_high - yesterday_low;
//S2 = P - yesterday_high + yesterday_low;
//
//R3 = P + P - yesterday_low - yesterday_low + yesterday_high;
//S3 = P + P - yesterday_high - yesterday_high + yesterday_low;//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexStyle(6,DRAW_LINE);
//
   SetIndexBuffer(0,Buffer1);
   SetIndexBuffer(1,Buffer2);
   SetIndexBuffer(2,Buffer3);
   SetIndexBuffer(3,Buffer4);
   SetIndexBuffer(4,Buffer5);
   SetIndexBuffer(5,Buffer6);
   SetIndexBuffer(6,Buffer7);
//---- name for DataWindow and indicator subwindow label
   short_name="i_pivot";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,short_name);
   SetIndexLabel(2,short_name);
   SetIndexLabel(3,short_name);
   SetIndexLabel(4,short_name);
   SetIndexLabel(5,short_name);
   SetIndexLabel(6,short_name);
//----
   SetIndexDrawBegin(0,0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|    
//+------------------------------------------------------------------+
int start()
  {
   double P,R1,R2,R3,S1,S2,S3;
   double yesterday_high1,yesterday_low1;
   double yesterday_high,yesterday_low,yesterday_close;

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int i=Bars-counted_bars;
   if(counted_bars==0) i-=1+1;
//----
   while(i>=0)
     {
      yesterday_high1=MathMax(yesterday_high1,High[i]);
      yesterday_low1=MathMin(yesterday_low1,Low[i]);
      if(TimeDay(Time[i])!=TimeDay(Time[i+1]))
        {
         yesterday_high=yesterday_high1;
         yesterday_low=yesterday_low1;
         yesterday_close=Close[i+1];
         yesterday_high1=Open[i];
         yesterday_low1=Open[i];
         P=(yesterday_high+yesterday_low+yesterday_close+yesterday_close)/4;
         R1=P + P - yesterday_low;
         S1=P + P - yesterday_high;
         R2=P + yesterday_high - yesterday_low;
         S2=P - yesterday_high + yesterday_low;
         R3=P + P - yesterday_low - yesterday_low + yesterday_high;
         S3=P + P - yesterday_high - yesterday_high + yesterday_low;
        }
      Buffer1[i]=P;
      Buffer2[i]=R1;
      Buffer3[i]=S1;
      Buffer4[i]=R2;
      Buffer5[i]=S2;
      Buffer6[i]=R3;
      Buffer7[i]=S3;
      i--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
