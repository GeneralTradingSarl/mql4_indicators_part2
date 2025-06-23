//+------------------------------------------------------------------+
//|                                       Ma_Distance_From_Price.mq4 |
//|                              transport_david , David W Honeywell |
//|                                        transport.david@gmail.com |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Coral
#property indicator_color2 White
//---- input parameters
extern int MaPeriod       =9;  // default = 9,0,3,0,15 on H1 charts
extern int MaShift        =0;
extern int MaMethod_0to3  =3; // 0 = SMA, 1 = EMA, 2 = SMMA, 3 = LWMA
extern int AppliedPrice_0to6=  0; // 0 = Close, 1 = Open, 2 = High, 3 = Low, 4 = Median, 5 = Typical, 6 = Weighted Close
extern int PipBuffer       =15; // If Ma > Price+PipBuffer then arrow , If Ma < Price-PipBuffer then arrow
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,234);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,233);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(1,0.0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
   int    i;
//---- 
   for(i=Bars-50; i>=0; i--)
     {
      double MaCurrent=iMA(Symbol(),0,MaPeriod,MaShift,MaMethod_0to3,AppliedPrice_0to6,i);
//----
      if(MaCurrent >(High[i] + PipBuffer*Point))
         ExtMapBuffer1[i]=High[i]+2*Point;
      if(MaCurrent <(Low[i] - PipBuffer*Point))
         ExtMapBuffer2[i]=Low[i]-2*Point;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+