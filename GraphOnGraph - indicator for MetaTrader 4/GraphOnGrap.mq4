//+------------------------------------------------------------------+
//|                                                  GraphOnGrap.mq4 |
//|                          Gryb Alexander alexandergrib@rambler.ru |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Gryb Alexander alexandergrib@rambler.ru"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 1
extern string comment1 = "Валютная пара";
extern string symbol = "EURUSD";
extern string comment2 = "Таймфрейм. 0 - тф текущего графика";
extern int timeFrame = 0;
extern string comment3 = "Цена, по которой строется график пары(Open, Close, Medium)";
extern string price = "Open";
extern color indicatorColor=Red;
double cot1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
    SetIndexBuffer(0,cot1);
    SetIndexStyle(0,DRAW_LINE,NULL,NULL,indicatorColor);
    IndicatorShortName("График "+symbol);
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
   int    counted_bars=IndicatorCounted();
//----
    for(int k = 0;k<1000;k++)
    {
     if(price == "Open") cot1[k]=iOpen(symbol,0,k);
     if(price == "Close") cot1[k]=iClose(symbol,0,k);
     if(price == "Medium") cot1[k]=((iOpen(symbol,0,k)+iClose(symbol,0,k))/2);
    }
//----
   return(0);
  }
//+------------------------------------------------------------------+