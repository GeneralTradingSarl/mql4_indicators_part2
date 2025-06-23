//+------------------------------------------------------------------+
//|                                                   ind_tracer.mq4 |
//|                                   Copyright 2014, Enrico Lambino |
//|                                          enricolambino@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Enrico Lambino"
#property link      "enricolambino@yahoo.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property description "Traces the output of indicators by buffer"
#property description "Output can be changed on the chart by moving the VL left or right"

#define OBJNAME   "IND_TRACER"
#define OPEN      DoubleToStr(iOpen(NULL,0,shift),Digits)
#define CLOSE     DoubleToStr(iClose(NULL,0,shift),Digits)
#define HIGH      DoubleToStr(iHigh(NULL,0,shift),Digits)
#define LOW       DoubleToStr(iLow(NULL,0,shift),Digits)

input string indicator_name="Bands"; //Custom Indicator Name
input int buffers=3; //Number of Indicator Buffers
int startpos=1; //Bar Starting Position

double arr[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(OBJNAME);
   Comment("");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   ArrayResize(arr,buffers);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---

//--- return value of prev_calculated for next call
   if(ObjectFind(0,OBJNAME)<0)
      if(ObjectCreate(0,OBJNAME,OBJ_VLINE,0,iTime(NULL,0,startpos),0))
         trace();
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_OBJECT_DRAG && sparam==OBJNAME)
      trace();
  }
//+------------------------------------------------------------------+
void trace()
  {
   string str="";
   datetime time1=(datetime) ObjectGet(OBJNAME,OBJPROP_TIME1);
   int shift=iBarShift(NULL,0,time1);
   str += indicator_name+"\n";
   str += "TIME "+TimeToStr(time1)+"\n";
   str += "SHIFT "+shift+"\n";
   str += "OHLC "+OPEN+" "+HIGH+" "+LOW+" "+CLOSE+"\n";
   for(int i=0;i<buffers;i++)
     {
      double val=iCustom(NULL,0,indicator_name,i,shift);
      str+="BUFFER "+i+": "+DoubleToStr(val,Digits)+"\n";
     }
   Comment(str);
   Sleep(500);
  }
//+------------------------------------------------------------------+
