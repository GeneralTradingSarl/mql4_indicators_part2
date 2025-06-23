//+------------------------------------------------------------------+
//|                                            Linear Regression.mq4 |
//|                Copyright © 2006, tageiger, aka fxid10t@yahoo.com |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, tageiger, aka fxid10t@yahoo.com"
#property link      "http://www.metaquotes.net"
#property indicator_chart_window
//----
extern int period=0;
/*default 0 means the channel will use the open time from "x" bars back on which ever time period 
the indicator is attached to.  one can change to 1,5,15,30,60...etc to "lock" the start time to a specific 
period, and then view the "locked" channels on a different time period...*/
extern int line_width=2;
extern int LR_length=34;   // bars back regression begins
extern color  LR_c=Orange;
extern double std_channel_1=0.618;        // 1st channel
extern color  c_1=Gray;
extern double std_channel_2=1.618;        // 2nd channel
extern color  c_2=Gray;
extern double std_channel_3=2.618;        // 3nd channel
extern color  c_3=Gray;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init(){return(0);}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int deinit()
  { ObjectDelete((string)period+"m "+(string)LR_length+" TL");
   ObjectDelete((string)period+"m "+(string)LR_length+" +"+(string)std_channel_1+"d"); ObjectDelete((string)period+"m "+(string)LR_length+" -"+(string)std_channel_1+"d");
   ObjectDelete((string)period+"m "+(string)LR_length+" +"+(string)std_channel_2+"d"); ObjectDelete((string)period+"m "+(string)LR_length+" -"+(string)std_channel_2+"d");
   ObjectDelete((string)period+"m "+(string)LR_length+" +"+(string)std_channel_3+"d"); ObjectDelete((string)period+"m "+(string)LR_length+" -"+(string)std_channel_3+"d");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int start(){//refresh chart
   ObjectDelete((string)period+"m "+(string)LR_length+" TL");
   ObjectDelete((string)period+"m "+(string)LR_length+" +"+(string)std_channel_1+"d"); ObjectDelete((string)period+"m "+(string)LR_length+" -"+(string)std_channel_1+"d");
   ObjectDelete((string)period+"m "+(string)LR_length+" +"+(string)std_channel_2+"d"); ObjectDelete((string)period+"m "+(string)LR_length+" -"+(string)std_channel_2+"d");
   ObjectDelete((string)period+"m "+(string)LR_length+" +"+(string)std_channel_3+"d"); ObjectDelete((string)period+"m "+(string)LR_length+" -"+(string)std_channel_3+"d");
   //linear regression calculation
   int start_bar=LR_length, end_bar=0;
   int n=start_bar-end_bar+1;
//---- calculate price values
   double value=iClose(Symbol(),period,end_bar);
   double a,b,c;
   double sumy=value;
   double sumx=0.0;
   double sumxy=0.0;
   double sumx2=0.0;
   for(int i=1; i<n; i++)
     {
      value=iClose(Symbol(),period,end_bar+i);
      sumy+=value;
      sumxy+=value*i;
      sumx+=i;
      sumx2+=i*i;
     }
   c=sumx2*n-sumx*sumx;
   if(c==0.0) return(-1);
   b=(sumxy*n-sumx*sumy)/c;
   a=(sumy-sumx*b)/n;
   double LR_price_2=a;
   double LR_price_1=a+b*n;
//---- maximal deviation calculation (not used)
   double max_dev=0;
   double deviation=0;
   double dvalue=a;
   for(i=0; i<n; i++)
     {
      value=iClose(Symbol(),period,end_bar+i);
      dvalue+=b;
      deviation=MathAbs(value-dvalue);
      if(max_dev<=deviation) max_dev=deviation;
     }
   //Linear regression trendline
   ObjectCreate((string)period+"m "+(string)LR_length+" TL",OBJ_TREND,0,iTime(Symbol(),period,start_bar),LR_price_1,Time[end_bar],LR_price_2);
   ObjectSet((string)period+"m "+(string)LR_length+" TL",OBJPROP_COLOR,LR_c);
   ObjectSet((string)period+"m "+(string)LR_length+" TL",OBJPROP_WIDTH,line_width);
   ObjectSet((string)period+"m "+(string)LR_length+" TL",OBJPROP_RAY,false);
   //...standard deviation...
   double x=0,x_sum=0,x_avg=0,x_sum_squared=0,std_dev=0;
   for(i=0; i<start_bar; i++)
     {
      x=MathAbs(iClose(Symbol(),period,i)-ObjectGetValueByShift((string)period+"m "+(string)LR_length+" TL",i));
      x_sum+=x;
      if(i>0)
        {
         x_avg=(x_avg+x)/i;
         x_sum_squared+=(x-x_avg)*(x-x_avg);
         std_dev=MathSqrt(x_sum_squared/(start_bar-1));
        }
     }
   //Print("LR_price_1 ",LR_price_1,"  LR_Price_2 ",LR_price_2," std_dev ",std_dev);
   //_..standard deviation channels...
   ObjectCreate((string)period+"m "+(string)LR_length+" +"+(string)std_channel_1+"d",OBJ_TREND,0,iTime(Symbol(),period,start_bar),LR_price_1+std_dev*std_channel_1,                                Time[end_bar],LR_price_2+std_dev*std_channel_1);
   ObjectSet((string)period+"m "+(string)LR_length+" +"+(string)std_channel_1+"d",OBJPROP_COLOR,c_1);
   ObjectSet((string)period+"m "+(string)LR_length+" +"+(string)std_channel_1+"d",OBJPROP_WIDTH,line_width);
   ObjectSet((string)period+"m "+(string)LR_length+" +"+(string)std_channel_1+"d",OBJPROP_RAY,false);
   ObjectCreate((string)period+"m "+(string)LR_length+" -"+(string)std_channel_1+"d",OBJ_TREND,0,iTime(Symbol(),period,start_bar),LR_price_1-std_dev*std_channel_1,
                                             Time[end_bar],LR_price_2-std_dev*std_channel_1);
   ObjectSet((string)period+"m "+(string)LR_length+" -"+(string)std_channel_1+"d",OBJPROP_COLOR,c_1);
   ObjectSet((string)period+"m "+(string)LR_length+" -"+(string)std_channel_1+"d",OBJPROP_WIDTH,line_width);
   ObjectSet((string)period+"m "+(string)LR_length+" -"+(string)std_channel_1+"d",OBJPROP_RAY,false);
   ObjectCreate((string)period+"m "+(string)LR_length+" +"+(string)std_channel_2+"d",OBJ_TREND,0,iTime(Symbol(),period,start_bar),LR_price_1+std_dev*std_channel_2,
                                             Time[end_bar],LR_price_2+std_dev*std_channel_2);
   ObjectSet((string)period+"m "+(string)LR_length+" +"+(string)std_channel_2+"d",OBJPROP_COLOR,c_2);
   ObjectSet((string)period+"m "+(string)LR_length+" +"+(string)std_channel_2+"d",OBJPROP_WIDTH,line_width);
   ObjectSet((string)period+"m "+(string)LR_length+" +"+(string)std_channel_2+"d",OBJPROP_RAY,false);
   ObjectCreate((string)period+"m "+(string)LR_length+" -"+(string)std_channel_2+"d",OBJ_TREND,0,iTime(Symbol(),period,start_bar),LR_price_1-std_dev*std_channel_2,
                                             Time[end_bar],LR_price_2-std_dev*std_channel_2);
   ObjectSet((string)period+"m "+(string)LR_length+" -"+(string)std_channel_2+"d",OBJPROP_COLOR,c_2);
   ObjectSet((string)period+"m "+(string)LR_length+" -"+(string)std_channel_2+"d",OBJPROP_WIDTH,line_width);
   ObjectSet((string)period+"m "+(string)LR_length+" -"+(string)std_channel_2+"d",OBJPROP_RAY,false);
   ObjectCreate((string)period+"m "+(string)LR_length+" +"+(string)std_channel_3+"d",OBJ_TREND,0,iTime(Symbol(),period,start_bar),LR_price_1+std_dev*std_channel_3,
                                             Time[end_bar],LR_price_2+std_dev*std_channel_3);
   ObjectSet((string)period+"m "+(string)LR_length+" +"+(string)std_channel_3+"d",OBJPROP_COLOR,c_3);
   ObjectSet((string)period+"m "+(string)LR_length+" +"+(string)std_channel_3+"d",OBJPROP_WIDTH,line_width);
   ObjectSet((string)period+"m "+(string)LR_length+" +"+(string)std_channel_3+"d",OBJPROP_RAY,false);
   ObjectCreate((string)period+"m "+(string)LR_length+" -"+(string)std_channel_3+"d",OBJ_TREND,0,iTime(Symbol(),period,start_bar),LR_price_1-std_dev*std_channel_3,
                                             Time[end_bar],LR_price_2-std_dev*std_channel_3);
   ObjectSet((string)period+"m "+(string)LR_length+" -"+(string)std_channel_3+"d",OBJPROP_COLOR,c_3);
   ObjectSet((string)period+"m "+(string)LR_length+" -"+(string)std_channel_3+"d",OBJPROP_WIDTH,line_width);
   ObjectSet((string)period+"m "+(string)LR_length+" -"+(string)std_channel_3+"d",OBJPROP_RAY,false);
  return(0);
  }
//+------------------------------------------------------------------+