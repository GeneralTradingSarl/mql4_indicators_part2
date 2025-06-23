//+------------------------------------------------------------------+
//|                                                         RSL1.mq4 |
//|                      Copyright © 2006, Харитонов А.В             |
//|                                        HaritonovAB@rambler.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "HaritonovAB@rambler.ru"

#property indicator_chart_window
#property indicator_buffers 1

//---- input parameters
extern int       MA_period=20;                              // Период опорной скользящей средней (MA)
extern double    LHistoCor=5;                               // Множитель корректировки видимой длины гистограммы 
extern color     Hcolor=Red;                                // Цвет гистограммы
double MA[];
int RS[];
int FS,n;
double maxHigh,minLow;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(1);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,MA);
   int Asize;
   maxHigh=High[Highest(NULL,0,MODE_HIGH,WHOLE_ARRAY,0)];
   minLow =Low[Lowest(NULL,0,MODE_LOW,WHOLE_ARRAY,0)];
   Asize=(maxHigh-minLow)/Point;
   ArrayResize(RS,Asize);
   ArrayInitialize(RS,0);
   n=0;
   Print(Asize,"   ",maxHigh,"   ",minLow);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectsDeleteAll(0,OBJ_RECTANGLE);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  if(Period()>=PERIOD_H1)
    {
     Print("Reduce the timeframe");
     return(0);
    }
   int i,j,k,t,counted_bars=IndicatorCounted(),size;
   double mH,mL;
   mH=minLow;mL=maxHigh;
   string LineName;
//----
   if(Bars<=MA_period) return(0);
//---- initial zero
   if(counted_bars<MA_period)
      ArrayInitialize(MA,0.0);
//---
   size=ArraySize(RS);

//----
   i=Bars-MA_period;
   if(counted_bars>=MA_period) i=Bars-counted_bars-1;

   while(i>=1)
     {
      MA[i]=iMA(NULL,0,13,0,MODE_EMA,PRICE_MEDIAN,i);
      if(High[i]>mH)mH=High[i];
      if((MA[i]>MA[i+1]) && (MA[i+1]<MA[i+2]))
        {
         k=(mL-minLow)/Point;
         if(k>=Bars) break;
         if(k<size)RS[k]++;
         else
           {
            RS[size-1]++;
           // PrintFormat("k=%d  ArraySize=%d",k,ArraySize(RS));
           }
         mH=mL;
        }
      if(Low[i]<mL)mL=Low[i];
      if((MA[i]<MA[i+1]) && (MA[i+1]>MA[i+2]))
        {
         if(k>=Bars) break;
         k=(mH-minLow)/Point;
         if(k<size)RS[k]++;
         else
           {
            RS[size-1]++;
           // PrintFormat("k=%d  ArraySize=%d",k,ArraySize(RS));
           }
         mL=mH;
        }

      i--;
     }
   ObjectsDeleteAll(0,OBJ_RECTANGLE);
   t=Period()*60*LHistoCor;
   j=(maxHigh-minLow)/Point-1;//Print(j);
   while(j>=0)
     {
      LineName="P_line"+j;
      ObjectCreate(LineName,OBJ_RECTANGLE,0,Time[FirstVisibleBar()],minLow+j*Point,Time[FirstVisibleBar()]+t*RS[j],minLow+(j+0.4)*Point);
      ObjectSet(LineName,OBJPROP_COLOR,Hcolor);// зададим цвет линии 
      ObjectSet(LineName,OBJPROP_STYLE,STYLE_DOT);
      j--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
