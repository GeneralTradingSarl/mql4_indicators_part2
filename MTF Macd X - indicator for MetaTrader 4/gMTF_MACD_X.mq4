//+------------------------------------------------------------------+
//|                                                  #MTF MACD X.mq4 |
//|                                      Copyright © 2006, Eli Hayun |
//|                                          http://www.elihayun.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Eli Hayun"
#property link      "http://www.elihayun.com"
//----
#property indicator_separate_window
#property indicator_minimum -1
#property indicator_maximum 6
#property indicator_buffers 8
//----
#property indicator_color1 clrBlue
#property indicator_color2 clrBlue
#property indicator_color3 clrBlue
#property indicator_color4 clrBlue
#property indicator_color5 clrRed
#property indicator_color6 clrRed
#property indicator_color7 clrRed
#property indicator_color8 clrRed
//---- input parameters
extern int       FastEMA=5;
extern int       SlowEMA=45;
//---- buffers
double UpBuffer_M15[];
double UpBuffer_M30[];
double UpBuffer_H1[];
double UpBuffer_H4[];
double DownBuffer_M15[];
double DownBuffer_M30[];
double DownBuffer_H1[];
double DownBuffer_H4[];
datetime dt15[200],dt30[200],dth1[200],dth4[200];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,254);
   SetIndexBuffer(0,UpBuffer_M15);
   SetIndexEmptyValue(0,-40.0);
//---
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,254);
   SetIndexBuffer(1,UpBuffer_M30);
   SetIndexEmptyValue(1,-40.0);
//---
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,254);
   SetIndexBuffer(2,UpBuffer_H1);
   SetIndexEmptyValue(2,-40.0);
//---
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,254);
   SetIndexBuffer(3,UpBuffer_H4);
   SetIndexEmptyValue(3,-40.0);
//---
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,253);
   SetIndexBuffer(4,DownBuffer_M15);
   SetIndexEmptyValue(4,-40.0);
//---
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,253);
   SetIndexBuffer(5,DownBuffer_M30);
   SetIndexEmptyValue(5,-40.0);
//---
   SetIndexStyle(6,DRAW_ARROW);
   SetIndexArrow(6,253);
   SetIndexBuffer(6,DownBuffer_H1);
   SetIndexEmptyValue(6,-40.0);
//---
   SetIndexStyle(7,DRAW_ARROW);
   SetIndexArrow(7,253);
   SetIndexBuffer(7,DownBuffer_H4);
   SetIndexEmptyValue(7,-40.0);
//---
   IndicatorShortName("#MACDx("+(string)FastEMA+","+(string)SlowEMA+")");
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
   int    counted_bars=IndicatorCounted();
   int limit;
   if(counted_bars<0) return(-1);
   if(counted_bars==0) limit=Bars-1;  // limit = Bars-MinBars-1;
//---- last counted bar will be recounted
   if(counted_bars>0) limit=Bars-counted_bars;
   limit-=SlowEMA;
//----
   int i15=0,i30=0,ih1=0,ih4=0;
   static bool fft=true;
//if (NewBar()) // Update array every 15 minutes
     {
      ArrayCopySeries(dt15,MODE_TIME,Symbol(),PERIOD_M15);
      if(_LastError!=0)
        {
         Print("Error ",GetLastError());
         ResetLastError();
         return(0);
        }
      ArrayCopySeries(dt30,MODE_TIME,Symbol(),PERIOD_M30);
      if(_LastError!=0)
        {
         Print("Error ",GetLastError());
         ResetLastError();
         return(0);
        }
      ArrayCopySeries(dth1,MODE_TIME,Symbol(),PERIOD_H1);
      if(_LastError!=0)
        {
         Print("Error ",GetLastError());
         ResetLastError();
         return(0);
        }
      ArrayCopySeries(dth4,MODE_TIME,Symbol(),PERIOD_H4);
      if(_LastError!=0)
        {
         Print("Error ",GetLastError());
         ResetLastError();
         return(0);
        }
     }
   if((fft) && (Symbol()=="EURUSD"))
     {
      fft=false;
      datetime d=iTime(NULL,PERIOD_D1,0);
      for(int j=0; j<80; j++)
        {
         //Print(j,") ",dt15[j]-d," ",dt30[j]-d," ",dth1[j]-d," ",dth4[j]-d);
        }
     }
   for(int i=0; i<limit; i++)
     {
      datetime ddt=iTime(NULL,0,i);
      if(ddt<dt15[i15]) i15++;
      if(ddt<dt30[i30]) i30++;
      if(ddt<dth1[ih1]) ih1++;
      if(ddt<dth4[ih4]) ih4++;
      //----
      double macd_m15=iMACD(NULL,PERIOD_M15, FastEMA,SlowEMA,1,PRICE_CLOSE, MODE_MAIN,i15);
      double macd_m30=iMACD(NULL,PERIOD_M30, FastEMA,SlowEMA,1,PRICE_CLOSE, MODE_MAIN,i30);
      double macd_h1=iMACD(NULL,PERIOD_H1, FastEMA,SlowEMA,1,PRICE_CLOSE, MODE_MAIN,ih1);
      double macd_h4=iMACD(NULL,PERIOD_H4, FastEMA,SlowEMA,1,PRICE_CLOSE, MODE_MAIN,ih4);
      //----
      UpBuffer_M15[i]=-40;    DownBuffer_M15[i]=-40;
      UpBuffer_M30[i]=-40;    DownBuffer_M30[i]=-40;
      UpBuffer_H1[i] =-40;    DownBuffer_H1[i] =-40;
      UpBuffer_H4[i] =-40;    DownBuffer_H4[i] =-40;
      //----
      if(macd_m15 > 0) UpBuffer_M15[i]=1; if(macd_m15 < 0) DownBuffer_M15[i]=1;
      if(macd_m30 > 0) UpBuffer_M30[i]=2; if(macd_m30 < 0) DownBuffer_M30[i]=2;
      if(macd_h1 > 0) UpBuffer_H1[i]  =3; if(macd_h1  < 0) DownBuffer_H1[i] =3;
      if(macd_h4 > 0) UpBuffer_H4[i]  =4; if(macd_h4  < 0) DownBuffer_H4[i] =4;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
/*
bool NewBar()
{
   static datetime dt = 0;
   if (dt != iTime(NULL, PERIOD_M15, 0))
   {
      dt = iTime(NULL, PERIOD_M15, 0);
   }
   return(false);
}
*/
//+------------------------------------------------------------------+
