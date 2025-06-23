//+------------------------------------------------------------------+
//|                                               SlopeDirection.mq4 |
//|                               Copyright 2016, Claude G. Beaudoin |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Claude G. Beaudoin"
#property link      "https://www.mql5.com/en/users/claudegbeaudoin"
#property version   "1.00"
#property strict
#property indicator_chart_window

//--- input parameters
extern int              BarCount = 9;
extern ENUM_MA_METHOD   Method   = MODE_SMA;

// Define trend directions
#define     UPTREND           1
#define     DOWNTREND         -1
#define     FLATTREND         0

// Define Objectcs
#define     TrendPanel        "TrendPanel"
#define     InfoLine1         "InfoLine1"
#define     InfoLine2         "InfoLine2"
#define     TrendLabel        "Trend:  M1  M5  M15  M30  H1  H4  D1  W1  MN"
#define     TrendUp           "\233"
#define     TrendDown         "\234"
#define     TrendFlat         "\232"
#define     TrendUnknown      "\251"
#define     StatObjectError   "%s(%d) Failed to create '%s'.  Error = %d"

// Define global variables
int      TrendPosition[]= { 44,64,88,114,136,156,174,194,216 };
int      TrendPeriods[] = { PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1 };
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int   OnInit()
  {
// Go create objects for indicator panel
   if(Create_Panel() && BarCount>=3)
      return(INIT_SUCCEEDED);
   else
      return(INIT_FAILED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// Delete indicator's objects
   if(ObjectFind(TrendPanel)>= 0) ObjectDelete(TrendPanel);
   if(ObjectFind(InfoLine1) >= 0) ObjectDelete(InfoLine1);
   if(ObjectFind(InfoLine2) >= 0) ObjectDelete(InfoLine2);
   for(int i=1; i<10; i++)
      if(ObjectFind("Trend"+DoubleToStr(i,0))>=0) ObjectDelete("Trend"+DoubleToStr(i,0));
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int   start()
  {
// Display current trend for all timeframes
   DisplayTrend();

   return(0);
  }
//+------------------------------------------------------------------+ 
//| Return the moving average                                               | 
//+------------------------------------------------------------------+ 
double WMA(int TimeFrame,int x,int p)
  {
   return(NormalizeDouble(iMA(NULL, TimeFrame, p, 0, MODE_LWMA, PRICE_CLOSE, x), Digits));
  }
//+------------------------------------------------------------------+
//| Get the current trend for TimeFrame
//+------------------------------------------------------------------+
double   GetTrend(int TimeFrame,int TrendPeriod,int Mode=MODE_SMA,bool Value=false,int Offset=0)
  {
   int x = 0;
   int p = (int)MathSqrt(TrendPeriod);
   int e = TrendPeriod * 3;
   double vect[],trend[],Buffer[];

   ArrayResize(vect,e);
   ArraySetAsSeries(vect,true);
   ArrayResize(trend,e);
   ArraySetAsSeries(trend,true);
   ArrayResize(Buffer,e);
   ArraySetAsSeries(Buffer,true);

   for(x=0; x<e; x++)
      vect[x]=NormalizeDouble(2*WMA(TimeFrame,x,TrendPeriod/2)-WMA(TimeFrame,x,TrendPeriod),Digits);

   for(x=0; x<e-TrendPeriod; x++)
      Buffer[x]=NormalizeDouble(iMAOnArray(vect,0,p,0,Mode,x),Digits);

   for(x=e-TrendPeriod; x>=0; x--)
     {
      trend[x]=trend[x+1];
      if(Buffer[x] > Buffer[x+1]) trend[x] = UPTREND;
      if(Buffer[x] < Buffer[x+1]) trend[x] = DOWNTREND;
      if(Buffer[x]==Buffer[x+1]) trend[x]=FLATTREND;
     }

// Return trend or value
   return((Value ? Buffer[x+1+Offset] : trend[x+1+Offset]));
  }
//+------------------------------------------------------------------+
//| Display the current trend for all timeframes
//+------------------------------------------------------------------+
void  DisplayTrend(void)
  {
   int      i,cntr,Trend,LastTrend;
   string   str;

   for(i=1; i<10; i++)
     {
      str="Trend"+DoubleToStr(i,0);
      Trend=(int)GetTrend(TrendPeriods[i-1],BarCount,Method);
      if(Trend==FLATTREND)
        {
         // I'm flat, find the last trend direction
         cntr=1;
         do
           {
            LastTrend=(int)GetTrend(TrendPeriods[i-1],BarCount,Method,false,cntr++);
           }
         while(LastTrend==Trend);
         ObjectSetText(str,TrendFlat,8,"WingDings",(LastTrend==UPTREND ? Green : Red));
         ObjectSetInteger(0,str,OBJPROP_YDISTANCE,6);
        }
      else
        {
         ObjectSetText(str,(Trend==UPTREND ? TrendUp : TrendDown),8,"WingDings",(Trend==UPTREND ? Green : Red));
         ObjectSetInteger(0,str,OBJPROP_YDISTANCE,5+(Trend==UPTREND ? 1 : -1));
        }
     }
  }
//+------------------------------------------------------------------+
//| Create the trend panel in the bottom left of the screen
//+------------------------------------------------------------------+
bool  Create_Panel(void)
  {

   int      i;
   string   str;

// Create the trend indicator window
   if(ObjectCreate(TrendPanel,OBJ_RECTANGLE_LABEL,0,0,0))
     {
      ObjectSetInteger(0,TrendPanel,OBJPROP_XDISTANCE,1);
      ObjectSetInteger(0,TrendPanel,OBJPROP_YDISTANCE,29);
      ObjectSetInteger(0,TrendPanel,OBJPROP_XSIZE,240);
      ObjectSetInteger(0,TrendPanel,OBJPROP_YSIZE,26);
      ObjectSetInteger(0,TrendPanel,OBJPROP_BGCOLOR,White);
      ObjectSetInteger(0,TrendPanel,OBJPROP_BORDER_TYPE,0);
      ObjectSetInteger(0,TrendPanel,OBJPROP_CORNER,CORNER_LEFT_LOWER);
      ObjectSetInteger(0,TrendPanel,OBJPROP_COLOR,Red);
      ObjectSetInteger(0,TrendPanel,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(0,TrendPanel,OBJPROP_WIDTH,2);
      ObjectSetInteger(0,TrendPanel,OBJPROP_BACK,false);
      ObjectSetInteger(0,TrendPanel,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,TrendPanel,OBJPROP_SELECTED,false);
      ObjectSetInteger(0,TrendPanel,OBJPROP_HIDDEN,true);
      ObjectSetString(0,TrendPanel,OBJPROP_TOOLTIP,"\n");
     }
   else
     { PrintFormat(StatObjectError,__FUNCTION__,__LINE__,TrendPanel,GetLastError()); return(false); }

   if(ObjectCreate(InfoLine1,OBJ_LABEL,0,0,0))
     {
      ObjectSet(InfoLine1,OBJPROP_CORNER,CORNER_LEFT_LOWER);
      ObjectSet(InfoLine1,OBJPROP_XDISTANCE,6);
      ObjectSet(InfoLine1,OBJPROP_YDISTANCE,15);
      ObjectSetInteger(0,InfoLine1,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,InfoLine1,OBJPROP_HIDDEN,true);
      ObjectSetString(0,InfoLine1,OBJPROP_TOOLTIP,"\n");
      ObjectSetText(InfoLine1,TrendLabel,8,"Arial",Black);
     }
   else
     { PrintFormat(StatObjectError,__FUNCTION__,__LINE__,InfoLine1,GetLastError()); return(false); }

   if(ObjectCreate(InfoLine2,OBJ_LABEL,0,0,0))
     {
      ObjectSet(InfoLine2,OBJPROP_CORNER,CORNER_LEFT_LOWER);
      ObjectSet(InfoLine2,OBJPROP_XDISTANCE,6);
      ObjectSet(InfoLine2,OBJPROP_YDISTANCE,5);
      ObjectSetInteger(0,InfoLine2,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,InfoLine2,OBJPROP_HIDDEN,true);
      ObjectSetString(0,InfoLine2,OBJPROP_TOOLTIP,"\n");
      ObjectSetText(InfoLine2," "+DoubleToStr(BarCount,0)+" / "+DoubleToStr(Method,0),8,"Arial",Black);
     }
   else
     { PrintFormat(StatObjectError,__FUNCTION__,__LINE__,InfoLine2,GetLastError()); return(false); }

// Create trend object and display current trend    
   for(i=1; i<10; i++)
     {
      str="Trend"+DoubleToStr(i,0);
      if(ObjectCreate(str,OBJ_LABEL,0,0,0))
        {
         ObjectSet(str,OBJPROP_CORNER,CORNER_LEFT_LOWER);
         ObjectSet(str,OBJPROP_XDISTANCE,TrendPosition[i-1]);
         ObjectSet(str,OBJPROP_YDISTANCE,5);
         ObjectSetInteger(0,str,OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,str,OBJPROP_HIDDEN,true);
         ObjectSetString(0,str,OBJPROP_TOOLTIP,"\n");
        }
      else
        { PrintFormat(StatObjectError,__FUNCTION__,__LINE__,str,GetLastError()); return(false); }
     }

// Go display current trend
   DisplayTrend();

// All good
   return(true);
  }
//+------------------------------------------------------------------+
