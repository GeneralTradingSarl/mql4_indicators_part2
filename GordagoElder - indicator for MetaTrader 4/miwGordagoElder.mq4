//+------------------------------------------------------------------+
//| 5 Min RSI 12-period qual INDICATOR                               |
//+------------------------------------------------------------------+
#property copyright "Ron T"
#property link      "http://www.lightpatch.com"
//----
#property indicator_chart_window
#property indicator_buffers 5
//----
#property indicator_color1 Red
#property indicator_color2 White
#property indicator_color3 Aqua
#property indicator_color4 LightGreen
#property indicator_color5 DodgerBlue
//---- buffers
double Buffer0[];
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
  {
   // 233 up arrow
   // 234 down arrow
   // 159 big dot
   // 158 little dot
   // 168 open square
   // 120 box with X
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexBuffer(0, Buffer0);
   SetIndexArrow(0,159);
//----
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexBuffer(1, Buffer1);
   SetIndexArrow(1,159);
//----
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexBuffer(2, Buffer2);
   SetIndexArrow(2,159);
//----
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexBuffer(3, Buffer3);
   SetIndexArrow(3,159);
//----
   SetIndexStyle(4,DRAW_ARROW);
   SetIndexBuffer(4, Buffer4);
   SetIndexArrow(4,159);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   int i;
//----
   for( i=0; i<Bars; i++)Buffer0[i]=0;
   for( i=0; i<Bars; i++)Buffer1[i]=0;
   for( i=0; i<Bars; i++)Buffer2[i]=0;
   for( i=0; i<Bars; i++)Buffer3[i]=0;
   for( i=0; i<Bars; i++)Buffer4[i]=0;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int      pos=Bars-100; // leave room for moving average periods
   int      ctr=0;
   double diMACD0;
   double diMACD1;
   double diStochastic0;
   double diStochastic1;
   double diClose7;
   double diHigh8;
   double diLow17;
   double p=Point;
//----
   while(pos>=0)
     {
      diMACD0=iMACD(Symbol(),60,13,30,0,PRICE_CLOSE,MODE_MAIN,0);
      diMACD1=iMACD(Symbol(),60,13,30,0,PRICE_CLOSE,MODE_MAIN,1);
      diStochastic0=iStochastic(Symbol(),15,2,0,3,MODE_EMA,PRICE_CLOSE,MODE_MAIN,0);
      diStochastic1=iStochastic(Symbol(),15,2,0,3,MODE_EMA,PRICE_CLOSE,MODE_MAIN,1);
      diClose7=iClose(Symbol(),1,0);
      diHigh8=iHigh(Symbol(),1,1);
      diLow17=iLow(Symbol(),1,1);
      //   double diMACD0=iMACD(NULL,60,13,30,0,PRICE_CLOSE,MODE_MAIN,0);
      //   double diMACD1=iMACD(NULL,60,13,30,0,PRICE_CLOSE,MODE_MAIN,1);
      //   double diMACD2=iMACD(NULL,60,13,30,0,PRICE_CLOSE,MODE_MAIN,1);
      //   double diStochastic3=iStochastic(NULL,15,2,0,3,MODE_EMA,PRICE_CLOSE,MODE_MAIN,0);
      //   double d4=(36);
      //   double diStochastic5=iStochastic(NULL,15,2,0,3,MODE_EMA,PRICE_CLOSE,MODE_MAIN,0);
      //   double diStochastic6=iStochastic(NULL,15,2,0,3,MODE_EMA,PRICE_CLOSE,MODE_MAIN,1);
      //   double diClose7=iClose(NULL,1,0);
      //   double diHigh8=iHigh(NULL,1,1);
      //   double diMACD9=iMACD(NULL,60,14,56,0,PRICE_CLOSE,MODE_MAIN,0);
      //   double diMACD10=iMACD(NULL,60,14,56,0,PRICE_CLOSE,MODE_MAIN,1);
      //   double diMACD11=iMACD(NULL,60,14,56,0,PRICE_CLOSE,MODE_MAIN,1);
      //   double diStochastic12=iStochastic(NULL,15,1,0,3,MODE_EMA,PRICE_CLOSE,MODE_MAIN,0);
      //   double d13=(66);
      //   double diStochastic14=iStochastic(NULL,15,1,0,3,MODE_EMA,PRICE_CLOSE,MODE_MAIN,0);
      //   double diStochastic15=iStochastic(NULL,15,1,0,3,MODE_EMA,PRICE_CLOSE,MODE_MAIN,1);
      //   double diClose16=iClose(NULL,1,0);
      //   double diLow17=iLow(NULL,1,1);
      if (diMACD0>diMACD1 && diMACD1<0)
        {
         Buffer4[pos]=Low[pos]+(5*p);
        }
      if (diStochastic0<35)
        {
         Buffer3[pos]=Low[pos]+(10*p);
        }
      if (diStochastic0>diStochastic1 )
        {
         Buffer2[pos]=Low[pos]+(15*p);
        }
      if (diClose7>diHigh8 )
        {
         Buffer1[pos]=Low[pos]+(20*p);
        }
      if (diMACD0<diMACD1 && diMACD1>0)
        {
         Buffer4[pos]=High[pos]+(5*p);
        }
      if (diStochastic0>66 )
        {
         Buffer3[pos]=High[pos]+(10*p);
        }
      if (diStochastic0<diStochastic1 )
        {
         Buffer2[pos]=High[pos]+(15*p);
        }
      if (diClose7<diLow17)
        {
         Buffer1[pos]=High[pos]+(20*p);
        }
      pos--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+