//+------------------------------------------------------------------+
//|                                                          MoR.mq4 |
//|                 Copyright © 1999-2007, MetaQuotes Software Corp. |
//|                                         http://www.metaquotes.ru |
//+------------------------------------------------------------------+
#property copyright "Wolfe"
#property link "xxxxwolfe@gmail.com"
//----
#property indicator_separate_window
#property indicator_level1  100
#property indicator_level2  80
#property indicator_level3  50
#property indicator_level4  20
#property indicator_buffers 4
#property indicator_color1 Black    //RSI
#property indicator_color2 Blue     //MA1
#property indicator_color3 Red      //MA2
#property indicator_color4 Green    //Ratio
//----
int  RSI_Timeframe=0;//0=current chart,1=m1,5=m5,15=m15,30=m30,60=h1,240=h4,etc...
int  RSI_Period=10;
int  RSI_Applied_Price=0;//0=close, 1=open, 2=high, 3=low, 4=(high+low)/2, 5=(high+low+close)/3, 6=(high+low+close+close)/4
int  MA1_Period=10;
int  MA1_Method=1;// 0=SMA, 1=EMA, 2=SMMA, 3=LWMA
int  MA2_Period=30;
int  MA2_Method=1;// 0=SMA, 1=EMA, 2=SMMA, 3=LWMA
double RSI[],MA1_Array[],MA2_Array[],MR_Ratio[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators setting
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1); //RSI
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1); //EMA10
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1); //EMA30
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,2); //Ratio
//----
   SetIndexBuffer(0,RSI);
   SetIndexLabel(0,"RSI");
   SetIndexBuffer(1,MA1_Array);
   SetIndexLabel(1,"MA1");
   SetIndexBuffer(2,MA2_Array);
   SetIndexLabel(2,"MA2");
   SetIndexBuffer(3,MR_Ratio);
   SetIndexLabel(3,"Ratio");
//----
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   IndicatorShortName("MoR");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i,limit;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit--;
//+------------------------------------------------------------------+
//| RSI                                                              |
//+------------------------------------------------------------------+
   for(i=limit; i>=0; i--)
     {
      RSI[i]=iRSI(NULL,RSI_Timeframe,RSI_Period,RSI_Applied_Price,i);
     }
//+------------------------------------------------------------------+
//| EMA 10 & 30                                                      |
//+------------------------------------------------------------------+
   for(i=limit; i>=0; i--)
     {
      MA1_Array[i]=iMAOnArray(RSI,0,MA1_Period,0,MA1_Method,i);
      MA2_Array[i]=iMAOnArray(RSI,0,MA2_Period,0,MA2_Method,i);
     }
//+------------------------------------------------------------------+
//| Ratio of EMA 10 & 30                                             |
//+------------------------------------------------------------------+
   for(i=0; i<=limit; i++)
     {
      if(MA2_Array[i]!=0) MR_Ratio[i]=MA1_Array[i]/MA2_Array[i] *100;
      else MR_Ratio[i]=0;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
