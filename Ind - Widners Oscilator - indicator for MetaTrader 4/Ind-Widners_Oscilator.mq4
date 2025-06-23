//+------------------------------------------------------------------+
//|                                        Ind-Widners Oscilator.mq4 |
//|                    Copyright © 2004, http://www.expert-mt4.nm.ru |
//|                                      http://www.expert-mt4.nm.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, http://www.expert-mt4.nm.ru"
#property link      "http://www.expert-mt4.nm.ru"
//----
#property indicator_separate_window
#property indicator_minimum 1
#property indicator_maximum 100
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
//----
extern int nPeriod=9;
///---- int Widners Oscilator
int cnt,nCurBar;
//---- buffers
double wso[];
double wro[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,wso);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,wro);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//---- TODO: add your code here
   double r1,r2,r3,r4,r5,r6;
   double s1,s2,s3,s4,s5,s6;

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+(nPeriod-1)/2;

   for(nCurBar=limit; nCurBar>0; nCurBar--)
     {
      if(Low[nCurBar+(nPeriod-1)/2]==Low[Lowest(NULL,0,MODE_LOW,nPeriod,nCurBar)])
        {
         s6=s5; s5=s4; s4=s3; s3=s2; s2=s1; s1=Low[nCurBar+(nPeriod-1)/2];
        }
      if(High[nCurBar+(nPeriod-1)/2]==High[Highest(NULL,0,MODE_HIGH,nPeriod,nCurBar)])
        {
         r6=r5; r5=r4; r4=r3; r3=r2; r2=r1; r1=High[nCurBar+(nPeriod-1)/2];
        }
      //----
      wso[nCurBar]=100*(1-(MathFloor(s1/Close[nCurBar])+
                        MathFloor(s2/Close[nCurBar])+
                        MathFloor(s3/Close[nCurBar])+
                        MathFloor(s4/Close[nCurBar])+
                        MathFloor(s5/Close[nCurBar])+
                        MathFloor(s6/Close[nCurBar]))/6);
      if(wso[nCurBar]==0) wso[nCurBar]=wso[nCurBar]+1;
      if(wso[nCurBar]==100) wso[nCurBar]=wso[nCurBar]-1;
      wro[nCurBar]=100*(1-(MathFloor(r1/Close[nCurBar])+
                        MathFloor(r2/Close[nCurBar])+
                        MathFloor(r3/Close[nCurBar])+
                        MathFloor(r4/Close[nCurBar])+
                        MathFloor(r5/Close[nCurBar])+
                        MathFloor(r6/Close[nCurBar]))/6);
      if(wro[nCurBar]==0) wro[nCurBar]=wro[nCurBar]+1;
      if(wro[nCurBar]==100) wro[nCurBar]=wro[nCurBar]-1;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
