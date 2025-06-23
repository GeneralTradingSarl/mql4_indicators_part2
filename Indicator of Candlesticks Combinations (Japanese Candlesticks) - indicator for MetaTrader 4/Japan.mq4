//+------------------------------------------------------------------+
//|                                                   Japan.mq4 |
//|                                                     Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"

#property indicator_chart_window
//---- input parameters
extern int       barsToProcess=1000;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   int i;
   for(i=0;i<Bars;i++)
     {
      ObjectDelete("ѕовешенный или молот "+DoubleToStr(i,0));
      ObjectDelete("бычье поглощение "+DoubleToStr(i,0));
      ObjectDelete("медвежье поглощение "+DoubleToStr(i,0));
      ObjectDelete("завеса из темных облаков "+DoubleToStr(i,0));
      ObjectDelete("просвет в облаках "+DoubleToStr(i,0));
      ObjectDelete("додж "+DoubleToStr(i,0));
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i=0;
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+1;

//if(limit>barsToProcess) limit=barsToProcess;

   while(i<limit)
     {
      //ѕовешенный или молот
      double k=(High[i]-Low[i])/3;
      if((Open[i]>(Low[i]+2*k)) && (Close[i]>(Low[i]+2*k)))
        {
         ObjectCreate("ѕовешенный или молот "+DoubleToStr(i,0),OBJ_ARROW,0,Time[i],High[i]+10*Point);
         ObjectSet("ѕовешенный или молот "+DoubleToStr(i,0),OBJPROP_ARROWCODE,108);
         ObjectSet("ѕовешенный или молот "+DoubleToStr(i,0),OBJPROP_COLOR,DimGray);
        }
      //бычье поглощение
      if((Open[i+1]>Close[i+1]) && (Close[i+1]>Open[i]) && (Close[i]>Open[i+1]))
        {
         ObjectCreate("бычье поглощение "+DoubleToStr(i,0),OBJ_ARROW,0,Time[i],Low[i]-15*Point);
         ObjectSet("бычье поглощение "+DoubleToStr(i,0),OBJPROP_ARROWCODE,110);
        }
      //медвежье поглощение
      if((Close[i+1]>Open[i+1]) && (Open[i]>Close[i+1]) && (Open[i+1]>Close[i]))
        {
         ObjectCreate("медвежье поглощение "+DoubleToStr(i,0),OBJ_ARROW,0,Time[i],High[i]+15*Point);
         ObjectSet("медвежье поглощение "+DoubleToStr(i,0),OBJPROP_ARROWCODE,110);
         ObjectSet("медвежье поглощение "+DoubleToStr(i,0),OBJPROP_COLOR,Lime);
        }
      //завеса из темных облаков
      if((Open[i+1]<Close[i+1]) && (Open[i]>High[i+1]) && (Close[i]<(Open[i+1]+(Close[i+1]-Open[i+1])/2)))
        {
         ObjectCreate("завеса из темных облаков "+DoubleToStr(i,0),OBJ_ARROW,0,Time[i],High[i]+25*Point);
         ObjectSet("завеса из темных облаков "+DoubleToStr(i,0),OBJPROP_ARROWCODE,116);
         ObjectSet("завеса из темных облаков "+DoubleToStr(i,0),OBJPROP_COLOR,Lime);
        }
      //просвет в облаках
      if((Open[i+1]>Close[i+1]) && (Low[i+1]>Open[i]) && (Close[i]>(Close[i+1]+(Open[i+1]-Close[i+1])/2)))
        {
         ObjectCreate("просвет в облаках "+DoubleToStr(i,0),OBJ_ARROW,0,Time[i],Low[i]-25*Point);
         ObjectSet("просвет в облаках "+DoubleToStr(i,0),OBJPROP_ARROWCODE,116);
        }
      //додж
      if(Open[i]==Close[i])
        {
         ObjectCreate("додж "+DoubleToStr(i,0),OBJ_ARROW,0,Time[i],High[i]+30*Point);
         ObjectSet("додж "+DoubleToStr(i,0),OBJPROP_ARROWCODE,174);
         ObjectSet("додж "+DoubleToStr(i,0),OBJPROP_COLOR,Indigo);
        }
      i++;
     }

//----
   return(0);
  }

























//+------------------------------------------------------------------+
