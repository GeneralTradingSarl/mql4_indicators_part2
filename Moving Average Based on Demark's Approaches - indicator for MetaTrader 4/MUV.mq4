//+------------------------------------------------------------------+
//|                                                          MUV.mq4 |
//|  3 но€бр€ 2008г.                                    Yuriy Tokman |
//| ICQ#:481-971-287                           yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"

#property indicator_chart_window

#property indicator_buffers 2

#property indicator_color1 LightYellow
#property indicator_color2 Red

extern int period     = 14;
extern int ma_method  = 0;  //MODE_SMA   0   ѕростое скольз€щее среднее 
                            //MODE_EMA   1   Ёкспоненциальное скольз€щее среднее 
                            //MODE_SMMA  2   —глаженное скольз€щее среднее 
                            //MODE_LWMA  3   Ћинейно-взвешенное скольз€щее среднее 

double Buf0[];
double Buf1[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
       SetIndexBuffer(0,Buf0);
       SetIndexBuffer(1,Buf1);
       
       SetIndexStyle(0,DRAW_NONE);
       SetIndexStyle(1,DRAW_LINE);
       
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
   int limit;
   int counted_bars=IndicatorCounted();
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   for(int i=0; i<limit; i++)
    {
     double x=0.0,
            h = iHigh(NULL,0,i),
            l = iLow(NULL,0,i),
            o = iOpen(NULL,0,i),
            c = iClose(NULL,0,i);
     if     (c<o) { x=(h+l+c+l)/2;}
     else if(c>o) { x=(h+l+c+h)/2;}
     else if(c==o){ x=(h+l+c+c)/2;}
     Buf0[i]=((x-l)+(x-h))/2;
    }
     
   for(i=0; i<limit; i++)
    {
     Buf1[i]=iMAOnArray(Buf0,0,period,0,ma_method,i);
    } 
//----
   return(0);
  }
//+------------------------------------------------------------------+