/*-------------------------------------------------------------------+
 |                                                    MaEnv_02B.mq4  |
 |                                                 Copyright © 2010  |
 |                                             basisforex@gmail.com  |
 +-------------------------------------------------------------------*/
#property copyright "Copyright © 2010, basisforex@gmail.com"
#property link      "basisforex@gmail.com"
//-----
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Yellow
#property indicator_color2 Yellow
#property indicator_color3 Aqua
#property indicator_color4 Aqua
#property indicator_color5 Blue
#property indicator_color6 Blue
#property indicator_color7 Red
#property indicator_color8 Red
//----------------------------
double aquaUp1[];
double aquaDn1[];
double aquaUp2[];
double aquaDn2[];
double aquaUp3[];
double aquaDn3[];
double aquaUp4[];
double aquaDn4[];
double yMA[];
//--------------
int init()
 {
   IndicatorBuffers(8);
   //-----
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, aquaUp1);
   SetIndexDrawBegin(0, 0);
   //-----
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, aquaDn1);
   SetIndexDrawBegin(1, 0);
   //-------------------------
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, aquaUp2);
   SetIndexDrawBegin(2, 0);
   //-----
   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, aquaDn2);
   SetIndexDrawBegin(3, 0);
   //-------------------------
   SetIndexStyle(4, DRAW_LINE);
   SetIndexBuffer(4, aquaUp3);
   SetIndexDrawBegin(4, 0);
   //-----
   SetIndexStyle(5, DRAW_LINE);
   SetIndexBuffer(5, aquaDn3);
   SetIndexDrawBegin(5, 0);
   //-------------------------
   SetIndexStyle(6, DRAW_LINE);
   SetIndexBuffer(6, aquaUp4);
   SetIndexDrawBegin(6, 0);
   //-----
   SetIndexStyle(7, DRAW_LINE);
   SetIndexBuffer(7, aquaDn4);
   SetIndexDrawBegin(7, 0);
   //------------------------
   return(0);
 }
//+------------------------------------------------------------------+
int start()
 {
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit--;   
   //-----
   ArrayResize(yMA, MathMax(ArraySize(yMA),limit+1));
   ArrayInitialize(yMA, 0.0);
   //-----
   for(int i = limit; i >= 0; i--)
    {
      yMA[i]=(iMA(NULL, 0, 30, 0, MODE_LWMA, PRICE_WEIGHTED, i) +
              iMA(NULL, 0, 50, 0, MODE_LWMA, PRICE_WEIGHTED, i) +
              iMA(NULL, 0, 100, 0, MODE_LWMA, PRICE_WEIGHTED, i)) / 3;
      //------------------------------------------------------------       
      aquaUp1[i] = yMA[i] + 6.18 * Point;
      aquaDn1[i] = yMA[i] - 6.18 * Point;
      aquaUp2[i] = yMA[i] + 16.18 * Point;
      aquaDn2[i] = yMA[i] - 16.18 * Point;
      aquaUp3[i] = yMA[i] + 26.18 * Point;
      aquaDn3[i] = yMA[i] - 26.18 * Point;
      aquaUp4[i] = yMA[i] + 36.18 * Point;
      aquaDn4[i] = yMA[i] - 36.18 * Point;
    }
   return(0);
  }
//+------------------------------------------------------------------+