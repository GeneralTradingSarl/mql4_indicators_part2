//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Julien Loutre"
#property link      "http://www.zenhop.com"

#property  indicator_chart_window
#property  indicator_buffers 1
#property  indicator_color1  LightBlue
#property  indicator_width1 1

extern string timeframe = "H4";
extern color  BullColor = SteelBlue;
extern color  BearColor = Red;

double      extBuffer[];

double open,close,open1,close1,high,low;
int p;
int currentCandle=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(1);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexDrawBegin(0,0);
   SetIndexEmptyValue(0,0.0);
   SetIndexBuffer(0,extBuffer);
   SetIndexLabel(0,"Open Price");
   IndicatorDigits(6);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int    limit,i,j;
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0)
     {
      //ArrayInitialize(extBuffer,0);
      limit--;
     }
   p=tfstrtoint(timeframe);
   for(i=limit-1; i>=0; i--)
     {
      int rp  = MathCeil(i*Period()/p);
      int rp1 = MathCeil((i+1)*Period()/p);
      for(j=i;j<=i+p/Period();j++)
        {
         if(iOpen(NULL,p,rp)==iOpen(NULL,0,i))
           {
            open=iOpen(NULL,0,i);
            close = iClose(NULL,0,i);
            open1 = iOpen(NULL,p,rp1);
            close1= iClose(NULL,p,rp1);
           }
        }
      extBuffer[i]=open;
      if(extBuffer[i]!=extBuffer[i+1])
        {
         currentCandle++;
         createCandle(Time[i],open);
        }
      updateCandle(Time[i],close1);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void createCandle(double t,double o)
  {
   ObjectCreate("candle"+(string)currentCandle,OBJ_RECTANGLE,0,t,o,t,o);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void updateCandle(double t,double c)
  {
   ObjectSet("candle"+(string)currentCandle,OBJPROP_TIME2,t);
   ObjectSet("candle"+(string)currentCandle,OBJPROP_PRICE2,c);
   if(ObjectGet("candle"+(string)currentCandle,OBJPROP_PRICE1)>ObjectGet("candle"+(string)currentCandle,OBJPROP_PRICE2))
     {
      ObjectSet("candle"+(string)currentCandle,OBJPROP_COLOR,BearColor);
        } else {
      ObjectSet("candle"+(string)currentCandle,OBJPROP_COLOR,BullColor);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deleteCandles()
  {
   ObjectsDeleteAll(0,OBJ_RECTANGLE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   deleteCandles();
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int tfstrtoint(string str)
  {
   if(str=="M1")
     {
      return(1);
     }
   if(str=="M5")
     {
      return(5);
     }
   if(str=="M15")
     {
      return(15);
     }
   if(str=="M30")
     {
      return(30);
     }
   if(str=="H1")
     {
      return(60);
     }
   if(str=="H4")
     {
      return(240);
     }
   if(str=="D1")
     {
      return(1440);
     }
   if(str=="W1")
     {
      return(10080);
     }
   if(str=="MN")
     {
      return(43200);
     }
   if(str=="")
     {
      return(0);
     }
  }
//+------------------------------------------------------------------+
