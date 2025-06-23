//+------------------------------------------------------------------+
//|                                                 Hull_O_H_L_C.mq4 |
//|                                           Copyright © 2007, None |
//|                                      Planet.Earth.Redistribution |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2007, None"
#property link      "Planet.Earth.Redistribution"
//----
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Blue
//---- parameters
extern int MaMethod =1;
extern int MaPeriod  =60;
extern int DrawType =2;
extern int OpCl_Width= 2;
extern int ShowBars  =250;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double maOpen, maClose, maLow, maHigh;
double haOpen, haHigh, haLow, haClose;
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
  {
//---- indicators
   IndicatorBuffers(4);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexDrawBegin(0,MaPeriod);
   SetIndexStyle(0,DrawType,STYLE_SOLID,1);
   SetIndexLabel(0," Mode 0 ");
   //
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexDrawBegin(1,MaPeriod);
   SetIndexStyle(1,DrawType,STYLE_SOLID,1);
   SetIndexLabel(1," Mode 1 ");
   //
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexDrawBegin(2,MaPeriod);
   SetIndexStyle(2,DrawType,STYLE_SOLID,OpCl_Width);
   SetIndexLabel(2," Mode 2 ");
   //
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   SetIndexDrawBegin(3,MaPeriod);
   SetIndexStyle(3,DrawType,STYLE_SOLID,OpCl_Width);
   SetIndexLabel(3," Mode 3 ");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   if(Bars<=10) return(0);
   ExtCountedBars=IndicatorCounted();
//---- check for possible errors
   if (ExtCountedBars<0) return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;
   //int pos=Bars-ExtCountedBars-2;
   int pos=ShowBars;
   if (pos>=(Bars-ExtCountedBars-2)) pos=Bars-ExtCountedBars-2;
   while(pos>=0)
     {
      maOpen =iMA(Symbol(),0,MathFloor(MaPeriod/2),0,MaMethod,PRICE_OPEN ,pos)*2-iMA(Symbol(),0,MaPeriod,0,MaMethod,PRICE_OPEN ,pos);
      maClose=iMA(Symbol(),0,MathFloor(MaPeriod/2),0,MaMethod,PRICE_CLOSE,pos)*2-iMA(Symbol(),0,MaPeriod,0,MaMethod,PRICE_CLOSE,pos);
      maLow  =iMA(Symbol(),0,MathFloor(MaPeriod/2),0,MaMethod,PRICE_LOW  ,pos)*2-iMA(Symbol(),0,MaPeriod,0,MaMethod,PRICE_LOW  ,pos);
      maHigh =iMA(Symbol(),0,MathFloor(MaPeriod/2),0,MaMethod,PRICE_HIGH ,pos)*2-iMA(Symbol(),0,MaPeriod,0,MaMethod,PRICE_HIGH ,pos);
//----
      haHigh=MathMax(maHigh, MathMax(haOpen, haClose));
      haLow=MathMin(maLow, MathMin(haOpen, haClose));
      if (haOpen<haClose)
        {
         ExtMapBuffer1[pos]=haLow;
         ExtMapBuffer2[pos]=haHigh;
        }
      else
        {
         ExtMapBuffer1[pos]=haHigh;
         ExtMapBuffer2[pos]=haLow;
        }
      haOpen=(ExtMapBuffer3[pos+1]+ExtMapBuffer4[pos+1])/2;
      ExtMapBuffer3[pos]=haOpen;
      haClose=(maOpen+maHigh+maLow+maClose)/4;
      ExtMapBuffer4[pos]=haClose;
      pos--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+