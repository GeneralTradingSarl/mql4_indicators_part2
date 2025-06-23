//+------------------------------------------------------------------+
//|                                    MVV_LinearRegression+STOP.mq4 |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window

extern string _FixedDateTime="2014.02.06 00:00";
extern color STOP_Color=clrRed;
extern color _TrendLineColor=clrDodgerBlue;
extern int LR_WIDTH=1;
datetime _N_Time;
double a,b,c;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//----
   IndicatorShortName("MVV_LinearRegression+STOP ("+_FixedDateTime+")");
//----------------------LR------------------------------
   ObjectCreate("LR("+_FixedDateTime+")",4,0,Time[0],0,Time[0],0);
   ObjectSet("LR("+_FixedDateTime+")",OBJPROP_COLOR,_TrendLineColor);
   ObjectSet("LR("+_FixedDateTime+")",OBJPROP_RAY,1);
   ObjectSet("LR("+_FixedDateTime+")",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet("LR("+_FixedDateTime+")",OBJPROP_WIDTH,LR_WIDTH);
   _N_Time=0;
   ObjectCreate("STOP("+_FixedDateTime+")",OBJ_ARROW,0,iTime(NULL,0,0),0,0,0,0,0);
   ObjectSet("STOP("+_FixedDateTime+")",OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
   ObjectSet("STOP("+_FixedDateTime+")",OBJPROP_COLOR,STOP_Color);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("LR("+_FixedDateTime+")");
   ObjectDelete("STOP("+_FixedDateTime+")");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(_N_Time==Time[0]) return(0);

   int Start,stop=0,i_max,i_min;

   datetime _time=StrToTime(_FixedDateTime);
   Start=iBarShift(NULL,Period(),_time,false);

   i_min= iLowest(NULL,0,MODE_LOW,Start,1);
   i_max= iHighest(NULL,0,MODE_HIGH,Start,1);
   if(iClose(NULL,0,Start) < iMA(NULL,0,21,0,MODE_SMMA,PRICE_CLOSE,Start))  stop=i_max;
   if(iClose(NULL,0,Start) > iMA(NULL,0,21,0,MODE_SMMA,PRICE_CLOSE,Start))  stop=i_min;

   _N_Time=Time[0];

   if(stop>5)
     {
      int n=Start+1;
      //---- calculate price values
      double value=iClose(Symbol(),0,0);
      double sumy=value;
      double sumx=0.0;
      double sumxy=0.0;
      double sumx2=0.0;
      for(int i=1; i<n; i++)
        {
         value=iClose(Symbol(),0,i);
         sumy+=value;
         sumxy+=value*i;
         sumx+=i;
         sumx2+=i*i;
        }
      c=sumx2*n-sumx*sumx;
      if(c==0.0) return(0);
      b=(sumxy*n-sumx*sumy)/c;
      a=(sumy-sumx*b)/n;
     }
   ObjectMove("LR("+_FixedDateTime+")",0,Time[Start],0);
   ObjectMove("LR("+_FixedDateTime+")",1,Time[stop],0);
   ObjectMove("STOP("+_FixedDateTime+")",0,iTime(NULL,0,0),a);
//Alert(LR.price.2);

   return(0);
  }
//+------------------------------------------------------------------+
