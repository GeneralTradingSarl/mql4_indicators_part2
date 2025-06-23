//+------------------------------------------------------------------+
//|                                                       sample.mq4 |
//|                                                        yzacarias |
//|                                                        yzacarias |
//+------------------------------------------------------------------+
#property copyright "yzacarias"
#property link      "yzacarias"
#property version   "1.70"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

double BufferSell[];
int Symbol_3_Kod=234;

double BufferBuy[];
int Symbol_4_Kod=233;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexStyle(0,DRAW_ARROW,0,1); 
   SetIndexArrow(0,Symbol_3_Kod);
   SetIndexBuffer(0,BufferSell);
   
   SetIndexStyle(1,DRAW_ARROW,0,1); 
   SetIndexArrow(1,Symbol_4_Kod);
   SetIndexBuffer(1,BufferBuy);
   
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
   int limit=rates_total-prev_calculated;
//---
   for(int i=0; i<limit - 4; i++)
     {
      if(open[i+1]-close[i+1] >= 0 &&  //Bajada
         open[i+2]-close[i+2] <= 0 &&  //Subida
         open[i+3]-close[i+3] <= 0 &&  //Subida
         open[i+4]-close[i+4] <= 0 &&  //Subida
         MathAbs(open[i+1]-close[i+1]) >= MathAbs(close[i+2]-open[i+4]))  //La Bajada engloba las tres subidas anteriores 
         BufferSell[i+1]=high[i+1]; 
         
         
      if(open[i+1]-close[i+1] <= 0 &&  //Subida
         open[i+2]-close[i+2] >= 0 &&  //Bajada
         open[i+3]-close[i+3] >= 0 &&  //Bajada
         open[i+4]-close[i+4] >= 0 &&  //Bajada
         MathAbs(open[i+1]-close[i+1]) >= MathAbs(close[i+2]-open[i+4]))  //La subida engloba las tres bajadas anteriores 
         BufferBuy[i+1]=low[i+1];    
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
