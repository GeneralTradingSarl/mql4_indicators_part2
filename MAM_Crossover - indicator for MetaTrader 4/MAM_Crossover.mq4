//+------------------------------------------------------------------+
//|                                                MAM_CrossOver.mq4 |
//|                         Copyright © 2010, Andy Tjatur Pramono    |
//|                                         andy.tjatur@gmail.com    |
//+------------------------------------------------------------------+


#property copyright "Copyright © 2010, Andy Tjatur Pramono"
#property link      "andy.tjatur@gmail.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 1
#property indicator_width2 1

double CrossUp[];
double CrossDown[];
extern bool Use_Sound = true;

bool alert;
datetime timestamp;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW, EMPTY);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, CrossUp);
   SetIndexStyle(1, DRAW_ARROW, EMPTY);
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
   int limit, i, counter;
   double x1,y1,x2,y2,x3,y3,A,B,C,D,E,F;
   double Range, AvgRange;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;

   limit=Bars-counted_bars;
   
   for(i = 0; i <= limit; i++) {
   
      counter=i;
      Range=0;
      AvgRange=0;
      for (counter=i ;counter<=i+9;counter++)
      {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
       
      A=iMA(NULL,0,20,0,MODE_SMA,PRICE_CLOSE,i);
      B=iMA(NULL,0,20,0,MODE_SMA,PRICE_OPEN,i);
      C=iMA(NULL,0,20,0,MODE_SMA,PRICE_CLOSE,i+1);
      D=iMA(NULL,0,20,0,MODE_SMA,PRICE_OPEN,i+1);
      E=iMA(NULL,0,20,0,MODE_SMA,PRICE_CLOSE,i-1);
      F=iMA(NULL,0,20,0,MODE_SMA,PRICE_OPEN,i-1);
      
      x1 = (A-B);
      y1 = (B-A);
      x2 = (C-D);
      y2 = (D-C);
      x3 = (E-F);
      y3 = (F-E);
      
      if ((x1>y1)&& (x2<y2)&&(x3>y3)) {
         CrossUp[i] = Low[i] - Range*0.7;if (Use_Sound && !alert) {PlaySound ("alert.wav"); alert=true;}}
      {
      }
      
      if ((x1<y1)&& (x2>y2)&&(x3<y3)) {
         CrossDown[i] = High[i] + Range*0.7;if (Use_Sound && !alert) {PlaySound ("alert.wav"); alert=true;} }
      
      }
     
      
   return(0);
}

