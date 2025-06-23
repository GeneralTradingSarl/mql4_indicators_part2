//+------------------------------------------------------------------+
//|                                                  MVA  Signal.mq4 |
//|                                      Copyright © 2005,mazennafee |
//|                                           mazen.nafee@yahoo.com  |
//+------------------------------------------------------------------+


#property copyright "Copyright © 2005, mazennafee "
#property link      "mazen.nafee@yahoo.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

double CrossUp[];
double CrossDown[];
extern int FasterEMA = 60;
extern int SlowerEMA = 100;
extern bool SoundON=true;
double alertTag;

 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW, EMPTY,3);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, CrossUp);
   SetIndexStyle(1, DRAW_ARROW, EMPTY,3);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, CrossDown);
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
int start() {
   int limit, i;
   double fasterEMAnow, slowerEMAnow, closepre , closeprePre;
   
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;

   limit=Bars-counted_bars;
   
   for(i = 0; i <= limit; i++) {
   
      
     
       
      fasterEMAnow = iMA(NULL, 0, FasterEMA, 0, MODE_EMA, PRICE_CLOSE, i+1);
      slowerEMAnow = iMA(NULL, 0, SlowerEMA, 0, MODE_EMA, PRICE_CLOSE, i+1);
      closepre     = iClose(NULL,0,i+1);
      closeprePre  = iClose(NULL,0,i+2);
      
      if ((closepre > fasterEMAnow) && closepre > slowerEMAnow && closeprePre < fasterEMAnow && closeprePre < slowerEMAnow ) {
         CrossUp[i+1] = Low[i+1] - Point*10;
      }
      else if ((closepre < fasterEMAnow) && closepre < slowerEMAnow && closeprePre  > fasterEMAnow && closeprePre > slowerEMAnow) {
          CrossDown[i+1] = High[i+1] + Point*10;
      }
        if (SoundON==true && i==1 && CrossUp[i] > CrossDown[i] && alertTag!=Time[0]){
         Alert("EMA CLOse Trend going Down on ",Symbol()," ",Period());
        alertTag = Time[0];
      }
        if (SoundON==true && i==1 && CrossUp[i] < CrossDown[i] && alertTag!=Time[0]){
       Alert("EMA CLOse Trend going Up on ",Symbol()," ",Period());
        alertTag = Time[0];
        } 
  }
   return(0);
}

