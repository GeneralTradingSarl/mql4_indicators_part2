//+------------------------------------------------------------------+
//|                                     past regression deviated.mq4 |
//|                Copyright © 2006, tageiger, aka fxid10t@yahoo.com |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, tageiger, aka fxid10t@yahoo.com"
#property link      "http://www.metaquotes.net"
//----
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Yellow
#property indicator_color2 Olive
#property indicator_color3 Olive
#property indicator_color4 Orange
#property indicator_color5 Orange
#property indicator_color6 Gray
#property indicator_color7 Gray
//---- input parameters
int period=0;
/*default 0 means the channel will use the open time from "x" bars back on which ever time period 
the indicator is attached to.  one can change to 1,5,15,30,60...etc to "lock" the start time to a specific 
period, and then view the "locked" channels on a different time period...*/
extern int LR_length=55;   // bars back regression begins
extern double std_channel_1=1;        // 1st channel
extern double std_channel_2=2;        // 2nd channel
extern double std_channel_3=3;        // 3nd channel
//---- indicator buffers
double mean_Buffer[];
double high_1_Buffer[];
double low_1_Buffer[];
double high_2_Buffer[];
double low_2_Buffer[];
double high_3_Buffer[];
double low_3_Buffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
/*---- line shifts when drawing
   SetIndexShift(0,JawsShift);
   SetIndexShift(1,TeethShift);
   SetIndexShift(2,LipsShift);
//---- first positions skipped when drawing*/
   SetIndexDrawBegin(0,LR_length);
   SetIndexDrawBegin(1,LR_length);
   SetIndexDrawBegin(2,LR_length);
   SetIndexDrawBegin(3,LR_length);
   SetIndexDrawBegin(4,LR_length);
   SetIndexDrawBegin(5,LR_length);
   SetIndexDrawBegin(6,LR_length);
//---- 3 indicator buffers mapping
   SetIndexBuffer(0,mean_Buffer);
   SetIndexBuffer(1,high_1_Buffer);
   SetIndexBuffer(2,low_1_Buffer);
   SetIndexBuffer(3,high_2_Buffer);
   SetIndexBuffer(4,low_2_Buffer);
   SetIndexBuffer(5,high_3_Buffer);
   SetIndexBuffer(6,low_3_Buffer);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE,0); SetIndexArrow(0,158);
   SetIndexStyle(1,DRAW_LINE,0); SetIndexArrow(1,158);
   SetIndexStyle(2,DRAW_LINE,0); SetIndexArrow(2,158);
   SetIndexStyle(3,DRAW_LINE,0); SetIndexArrow(3,158);
   SetIndexStyle(4,DRAW_LINE,0); SetIndexArrow(4,158);
   SetIndexStyle(5,DRAW_LINE,0); SetIndexArrow(5,158);
   SetIndexStyle(6,DRAW_LINE,0); SetIndexArrow(6,158);
//---- index labels
   SetIndexLabel(0,"mean");
   SetIndexLabel(1,"1st Std up");
   SetIndexLabel(2,"1st Std down");
   SetIndexLabel(3,"2nd Std up");
   SetIndexLabel(4,"2nd Std down");
   SetIndexLabel(5,"3rd Std up");
   SetIndexLabel(6,"3rd Std down");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(0,OBJ_ARROW);ObjectDelete(period+"m "+LR_length+" TL");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   ObjectDelete(period+"m "+LR_length+" TL");

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+LR_length;

//---- main loop
   for(int i=0; i<limit; i++)
     {
      //linear regression calculation
      int start_bar=i+LR_length,end_bar=i;
      int n=start_bar-end_bar+1;
      //---- calculate price values.. Linear regression calculation
      double value=Close[end_bar];
      double a,b,c;
      double sumy=value;
      double sumx=0.0;
      double sumxy=0.0;
      double sumx2=0.0;
      for(int ii=1; ii<n; ii++)
        {
         value=Close[end_bar+ii];
         sumy+=value;
         sumxy+=value*ii;
         sumx+=ii;
         sumx2+=ii*ii;
        }
      c=sumx2*n-sumx*sumx;
      if(c==0.0) return(0);
      b=(sumxy*n-sumx*sumy)/c;
      a=(sumy-sumx*b)/n;
      double LR_price_2=a;
      double LR_price_1=a+b*n;
      mean_Buffer[i]=NormalizeDouble(LR_price_2,Digits);
/*---- maximal deviation calculation (3rd deviation line)
      double max.dev=0;
      double deviation=0;
      double dvalue=a;
      for(int i.1=0; i.1<n; i.1++)   {
         value=Close[end.bar+i.1];
         dvalue+=b;
         deviation=MathAbs(value-dvalue);
         if(max.dev<=deviation) max.dev=deviation; } */
      //Linear regression trendline
      ObjectDelete(period+"m "+LR_length+" TL");
      ObjectCreate(period+"m "+LR_length+" TL",OBJ_TREND,0,Time[start_bar],LR_price_1,Time[end_bar],LR_price_2);
      ObjectSet(period+"m "+LR_length+" TL",OBJPROP_COLOR,Orange);
      ObjectSet(period+"m "+LR_length+" TL",OBJPROP_WIDTH,2);
      ObjectSet(period+"m "+LR_length+" TL",OBJPROP_RAY,false);
      //...standard deviation...
      double x=0,x_sum=0,x_avg=0,x_sum_squared=0,std_dev=0;
      for(int iii=i; iii<start_bar; iii++)
        {
         x=MathAbs(Close[iii]-ObjectGetValueByShift(period+"m "+LR_length+" TL",iii));
         x_sum_squared+=(x*x);
        }
      std_dev=MathSqrt(x_sum_squared/((start_bar-end_bar)-1));
      //Print("LR.price.1 ",LR.price.1,"  LR.Price.2 ",LR.price.2," std.dev ",std.dev);
      //...standard deviation channels...
      high_1_Buffer[i]=mean_Buffer[i]+(std_channel_1*std_dev);
      low_1_Buffer[i]=mean_Buffer[i]-(std_channel_1*std_dev);
      high_2_Buffer[i]=mean_Buffer[i]+(std_channel_2*std_dev);
      low_2_Buffer[i]=mean_Buffer[i]-(std_channel_2*std_dev);
      high_3_Buffer[i]=mean_Buffer[i]+(std_channel_3*std_dev);//max.dev;
      low_3_Buffer[i]=mean_Buffer[i]-(std_channel_3*std_dev);//max.dev;
     }
   return(0);
  }
//+------------------------------------------------------------------+
