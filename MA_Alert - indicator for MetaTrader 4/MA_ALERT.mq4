//+------------------------------------------------------------------+
//|                                                     MA_ALERT.mq4 |
//|                                                          Kalenzo |
//|                                                  simone@konto.pl |
//+------------------------------------------------------------------+
#property copyright "Kalenzo"
#property link      "simone@konto.pl"
//----
extern bool makeItPlay=true;
extern int maMethod=0;
extern int maPeriod=14;
extern int maShift=0;
extern int appiledPrice=0;
//----
int PrevAlertTime=0;
#property indicator_chart_window
#property indicator_color1 Red
#property indicator_buffers 1
double maBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE,0,1);
   SetIndexBuffer(0,maBuffer);
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
//---- 
   int limit;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) counted_bars=0;
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- 
   for(int i=0 ;i < limit ;i++)
     {
      maBuffer[i]=iMA(Symbol(),0,maPeriod,maShift,maMethod,appiledPrice,i);
     }
   double ppMA=NormalizeDouble(iMA(Symbol(),0,maPeriod,maShift,maMethod,appiledPrice,3),4);
   double pMA=NormalizeDouble(iMA(Symbol(),0,maPeriod,maShift,maMethod,appiledPrice,2),4);
   double cMA=NormalizeDouble(iMA(Symbol(),0,maPeriod,maShift,maMethod,appiledPrice,1),4);
//----
   if (CurTime() - PrevAlertTime > Period()*60)
     {
      if(ppMA < pMA && pMA > cMA)
        {
         Alert("MA incerasing");
         PrevAlertTime=CurTime();
        }
      else if(ppMA > pMA && pMA < cMA)
           {
            Alert("MA decerasing");
            PrevAlertTime=CurTime();
           }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+