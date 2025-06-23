//+------------------------------------------------------------------+
//|                                                    Kijun-sen.mq4 |
//|                                     Copyright © 2004, AlexSilver |
//|                                                  http://viac.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, AlexSilver"
#property link      "http://viac.ru/"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 DeepSkyBlue
//---- input parameters
extern int Kijun=26;
extern int ShiftKijun=3;
//---- buffers
double Kijun_Buffer[];
//----
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//----
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Kijun_Buffer);
   SetIndexDrawBegin(0,Kijun+ShiftKijun-1);
   SetIndexShift(0,ShiftKijun);
   SetIndexLabel(0,"Kijun Sen+");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Ichimoku Kinko Hyo Kijun-sen Only                                |
//+------------------------------------------------------------------+
int start()
  {
   int    i,k;
   int    counted_bars=IndicatorCounted();
   double high,low,price;
//----
   if(Bars<=Kijun) return(0);
//---- initial zero
   if(counted_bars<1)
     {
      for(i=1;i<=Kijun;i++)     Kijun_Buffer[Bars-i]=0;
     }
//---- Kijun Sen
   i=Bars-Kijun;
   if(counted_bars>Kijun) i=Bars-counted_bars-1;
   while(i>=0)
     {
      high=High[i]; low=Low[i]; k=i-1+Kijun;
      while(k>=i)
        {
         price=High[k];
         if(high<price) high=price;
         price=Low[k];
         if(low>price) low=price;
         k--;
        }
      Kijun_Buffer[i+ShiftKijun]=(high+low)/2;
      i--;
     } i=ShiftKijun-1;
   while(i>=0)
     {
      high=High[0]; low=Low[0]; k=Kijun-ShiftKijun+i;
      while(k>=0)
        {
         price=High[k];
         if(high<price) high=price;
         price=Low[k];
         if(low>price) low=price;
         k--;
        }
      Kijun_Buffer[i]=(high+low)/2;
      i--;
     }
   }
//+------------------------------------------------------------------+