//+------------------------------------------------------------------+
//|                                               _i_EF_distance.mq4 |
//|                                     Copyright © 2006, Doji Starr |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Doji Starr"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Aqua
// input params
extern int Length=10;
extern double Power=2;
// vars
int i, c, startBar;
double coef, norm;
// buffers
double buf_el[], buf_co[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(2);
   SetIndexBuffer(0,buf_el);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,buf_co);
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
   if (Bars<=Length)
      return(0);
//----
   int bar;
   int counted_bars=IndicatorCounted();
   if (counted_bars < 1)
     {
      // filling initial values in buffers
      for(bar=Bars-1; bar>=Bars-Length*2; bar--)
        {
         buf_el[bar]=Close[bar];
         buf_co[bar]=0.0;
        }
      startBar=Bars-Length*2-1;
     }
   else
      startBar=Bars-counted_bars-1;
   for(bar=startBar; bar>=0; bar--)
     {
      buf_co[bar]=0.0;
      for(i=Length-1; i>=0; i--)
         buf_co[bar]+=MathAbs(MathPow(Close[bar]-Close[bar+i], Power));
//----
      norm=0.0;
      buf_el[bar]=0.0;
      for(i=Length-1; i>=0; i--)
        {
         norm+=buf_co[bar+i];
         buf_el[bar]+=buf_co[bar+i] * Close[bar+i];
        }
      if (norm!=0)
         buf_el[bar]/=norm;
      else
         buf_el[bar]=0.0;
      //Print(norm);        
     }
//----
   return(0);
  }

//+------------------------------------------------------------------+