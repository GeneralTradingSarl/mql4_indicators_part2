//+------------------------------------------------------------------+
//|                                                      NtMidMA.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot Label1
#property indicator_label1  "Label1"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrWhiteSmoke
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Label2
#property indicator_label2  "signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Label3
#property indicator_label3  "price"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBeige
#property indicator_style3  STYLE_DOT
#property indicator_width3  1
//--- plot Label3
#property indicator_label4 "priceShift"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

//--- input parameters

input int      MA1=12;
input int      MA2=26;
input int      sig=9;
input int      shift=2;

//--- indicator buffers
double         cdma[];
double         signal[];
double         price[];
double         priceShift[];
//double         signal[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexShift(3,shift);
   SetIndexBuffer(0,cdma);
   SetIndexBuffer(1,signal);
   SetIndexBuffer(2,price);
   SetIndexBuffer(3,priceShift);
   
   //SetIndexBuffer(1,signal);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int limit=rates_total-prev_calculated;
   double m,imas=0;
   if(limit==0)
     {
      imas=iMA(NULL,NULL,MA2,0,MODE_EMA,PRICE_CLOSE,0);
      cdma[0]=(iMA(NULL,NULL,MA1,0,MODE_EMA,PRICE_CLOSE,0)-imas);
      price[0]=((close[0]>imas?high[0]:close[0]<imas?low[0]:close[0])-imas);        
     }
   for(int i=0; i<(limit>1?limit-1:limit); i++)
     {
      m=iCustom(NULL,Period(),"NtVLDTY",0,i+1);
      imas=iMA(NULL,NULL,MA2,0,MODE_EMA,PRICE_CLOSE,i);
      cdma[i]=(iMA(NULL,NULL,MA1,0,MODE_EMA,PRICE_CLOSE,i)-imas);
      
      price[i]=((close[i]>imas?high[i]:close[i]<imas?low[i]:close[i])-imas);  
      priceShift[i]=price[i];
     }
   for(int i=0; i<(limit>1?limit-1:limit); i++)
     {
      signal[i]= iMAOnArray(cdma,0,sig,0,MODE_SMA,i);
     }  
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
