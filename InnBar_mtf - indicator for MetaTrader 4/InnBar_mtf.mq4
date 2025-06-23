//+------------------------------------------------------------------+
//|                                                    DOSR_Dots.mq4 |
//|                                                          Kalenzo |
//|                                          http://www.fxservice.eu |
//+------------------------------------------------------------------+
//mod InnBar mtf
#property copyright "Kalenzo"
#property link      "http://www.fxservice.eu"
#property indicator_buffers 2
#property indicator_color1 Magenta
#property indicator_color2 MediumVioletRed
#property indicator_width1 2
#property indicator_width2 2
//----
double val1[];
double val2[];
//----
extern int tf=60;
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexBuffer(0,val1);
   SetIndexBuffer(1,val2);
//
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexStyle(1,DRAW_ARROW);
//
   SetIndexArrow(0,158);
   SetIndexArrow(1,158);
//
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexEmptyValue(1,EMPTY_VALUE);
//
   SetIndexLabel(0,"insideBar Hi");
   SetIndexLabel(1,"insideBar Lo");
   if(tf<Period())tf=Period();
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
   int i,bs,limit;

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+1+tf/Period();

//----
   for(i=0; i<limit; i++)
     {
      bs=iBarShift(Symbol(),tf,Time[i]);
      //----
      double H1=iHigh(Symbol(),tf,bs+1);
      double L1=iLow(Symbol(),tf,bs+1);
      //
      double H=iHigh(Symbol(),tf,bs);
      double L=iLow(Symbol(),tf,bs);
      //----
      if((H1>H) && (L1<L))
        {
         val1[i]=H; val2[i]=L;
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
