//+------------------------------------------------------------------+
//|                                               Ind-Fractals-1.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//----
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Blue
#property indicator_color5 Lime
#property indicator_color6 Lime
#property indicator_color7 Sienna
#property indicator_color8 Sienna
//---- input parameters
extern bool      Comm=true;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,217);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,218);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(1,0.0);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,217);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexEmptyValue(2,0.0);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,218);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexEmptyValue(3,0.0);
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,217);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexEmptyValue(4,0.0);
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,218);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexEmptyValue(5,0.0);
   SetIndexStyle(6,DRAW_ARROW);
   SetIndexArrow(6,217);
   SetIndexBuffer(6,ExtMapBuffer7);
   SetIndexEmptyValue(6,0.0);
   SetIndexStyle(7,DRAW_ARROW);
   SetIndexArrow(7,218);
   SetIndexBuffer(7,ExtMapBuffer8);
   SetIndexEmptyValue(7,0.0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//------------------------------------------------------------------  
bool Fractal(string F,int Per,int shift)
  {
   if(Period()>Per) return(-1);
   Per=Per/Period()*2+MathCeil(Per/Period()/2);
   if(shift<Per)return(-1);
   if(shift>Bars-Per)return(-1);
   for(int i=1;i<=Per;i++)
     {
      if(shift+i>=Bars || shift-i<0)
         return(-1);
      if(F=="U")
        {
         if(High[shift+i]>High[shift])return(-1);
         if(High[shift-i]>=High[shift])return(-1);
        }
      if(F=="L")
        {
         if(Low[shift+i]<Low[shift])return(-1);
         if(Low[shift-i]<=Low[shift])return(-1);
        }
     }
   return(1);
  }
//------------------------------------------------------------------
int start()
  {
   int D1=1440,H4=240,H1=60,M15=15,B;
   double P;
   int    counted_bars=IndicatorCounted();
   B=Bars-counted_bars;
   if(counted_bars==0) B--;
   if(Period()==D1)P=15*Point;
   if(Period()==H4)P=7*Point;
   if(Period()==H1)P=4*Point;
   if(Period()==30)P=3*Point;
   if(Period()==M15)P=2*Point;
   if(Period()==5)P=1*Point;
   if(Period()==1)P=0.5*Point;
   for(int shift=B;shift>0;shift--)
     {
      if(Fractal("U",M15,shift)==1) ExtMapBuffer1[shift]=High[shift]+P;
      else ExtMapBuffer1[shift]=0;
      if(Fractal("L",M15,shift)==1) ExtMapBuffer2[shift]=Low[shift]-P;
      else ExtMapBuffer2[shift]=0;
      if(Fractal("U",H1,shift)==1) ExtMapBuffer3[shift]=High[shift]+P;
      else ExtMapBuffer3[shift]=0;
      if(Fractal("L",H1,shift)==1) ExtMapBuffer4[shift]=Low[shift]-P;
      else ExtMapBuffer4[shift]=0;
      if(Fractal("U",H4,shift)==1) ExtMapBuffer5[shift]=High[shift]+P;
      else ExtMapBuffer5[shift]=0;
      if(Fractal("L",H4,shift)==1) ExtMapBuffer6[shift]=Low[shift]-P;
      else ExtMapBuffer6[shift]=0;
      if(Fractal("U",D1,shift)==1) ExtMapBuffer7[shift]=High[shift]+P;
      else ExtMapBuffer7[shift]=0;
      if(Fractal("L",D1,shift)==1) ExtMapBuffer8[shift]=Low[shift]-P;
      else ExtMapBuffer8[shift]=0;
     }
   if(Comm) Comment(" D1 - коричневый\n H4 - зелёный\n H1 - синий\nM15 - красный ");
//  ObjectCreate("T_D1",OBJ_TEXT,0,Time[30],Close[0]+10*P);
//  ObjectSetText("T_D1","D1",10,"Times New Roman",indicator_color8);
//  ObjectCreate("T_H4",OBJ_TEXT,0,Time[20],Close[0]+10*P);
//  ObjectSetText("T_H4","H4",10,"Times New Roman",indicator_color6);
//  ObjectCreate("T_H1",OBJ_TEXT,0,Time[10],Close[0]+10*P);
//  ObjectSetText("T_H1","H1",10,"Times New Roman",indicator_color4);
//  ObjectCreate("T_M15",OBJ_TEXT,0,Time[0],Close[0]+10*P);
//  ObjectSetText("T_M15","M15",10,"Times New Roman",indicator_color2);
   return(0);
  }
//+------------------------------------------------------------------+
