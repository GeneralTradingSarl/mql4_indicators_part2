//+------------------------------------------------------------------+
//|                                                     MAProfit.mq4 |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Thomas Quester 'tflores'."
#property link      "tquester@gmx.de"

// if you want speach, get gspeak from "http://www.forex-tsd.com"
// you can download also here: http://codebase.mql4.com/5036
// Remove comment in LoudAlert below

#import "speak.dll"
void gRate(int rate);
void gVolume(int rate);
void gPitch(int rate);
void gSpeak(string text);
#import

// if you do not have (or want) the speach.dll uncomment this
/*
void gSpeak(string x)
{
}
*/

int Systems[]=
  {
   PRICE_MEDIAN,MODE_SMA,50,PRICE_MEDIAN,MODE_SMA,200,
   PRICE_MEDIAN,MODE_SMA,50,PRICE_MEDIAN,MODE_SMA,100,// http://www.investopedia.com/terms/d/deathcross.asp
   PRICE_MEDIAN,MODE_SMA,10,PRICE_MEDIAN,MODE_SMA,40,
   PRICE_MEDIAN,MODE_SMA,13,PRICE_MEDIAN,MODE_SMA,26,
   PRICE_MEDIAN,MODE_SMA,5,PRICE_MEDIAN,MODE_SMA,10,
   PRICE_CLOSE, MODE_EMA,5,     PRICE_OPEN,  MODE_EMA,6,        // http://www.tradejuice.com/forex/type-moving-average-cross-mm.html
   PRICE_MEDIAN,MODE_SMA,3,     PRICE_MEDIAN,MODE_SMA,8,        // http://www.tradejuice.com/forex/type-moving-average-cross-mm.html

   0,0,0,0,0,0
  };

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Aqua
#property indicator_color2 LightGoldenrod
#property indicator_color3 Gold

int              ColorLongTrade  = MediumSpringGreen;
int              ColorShortTrade = Red;
int              ColorBadTrade   = Violet;
bool             bAlertViaAlert=true;
//---- input parameters
extern int       PeriodShort=6;
extern int       PeriodLong=40;
extern int       Method=0;
extern bool      Optimize=true;
extern bool      DrawTringles=true;
extern int       MinShortMA=5;
extern int       MaxShortMA=50;
extern int       MaxLongMA=150;
extern int       StepLongMA=5;
extern int       StepShortMA=5;
extern int       CountOptimize=150;
extern bool      OptimizeAll=false;
extern bool      OptimizeSystems=true;
extern bool      OptimizeOnNewCandle=false;
extern int       RepaintBars=500;
extern bool      Alarm=true;
datetime         lastSignalTime=0;
datetime         firstTradeCandle;                    // we trade 300 candles but at all calls it should be the same candle
                                                      // so remember the time and search each time

int Method1 = MODE_SMA;
int Method2 = MODE_SMA;
int Price1 = PRICE_MEDIAN;
int Price2 = PRICE_HIGH;
int Price3 = PRICE_LOW;

string AlertShort = "alert.wav";
string AlertLong  = "alert.wav";

//---- buffers
double ExtMapBufferFast[];                            // Fast MA curve
double ExtMapBufferSlowHigh[];                        // Upper slow curve
double ExtMapBufferSlowLow[];                         // Lower slow curve
int OldPeriod;                                        // The period, we check for changes and re-init ourself
int spread;
int cBars;                                            // Saved number of bars in order to see if new bar
string OldSymbol;                                     // If symbol canges, we re-initialize
string rsiMessage;                                    // Last Message RSI Oversold/Overbought

#define SIGNAL_NONE  0
#define SIGNAL_SHORT 1
#define SIGNAL_LONG  2

int               MaxObj=0;
int               yesterday,today;        // index of yesterday and today

double            gTradeOpen[],
gTradeMin[],
gTradeMax[];
int               gTradeCmd[],
gTradeStart[],
gTradeEnd[],
gTradeID;

int               gStartShort,gEndShort,
gStartLong,gEndLong;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LoudAlert(string s)
  {
   if(bAlertViaAlert) Alert(s);
   Print(s);
   gSpeak(s);        // uncomment this for speak
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string FormatNumber(string s)
  {
   int c;
   while(true)
     {
      c=StringGetChar(s,StringLen(s)-1);
      if(c!='.' && c!='0') break;
      s=StringSubstr(s,0,StringLen(s)-1);
     }
   return (s);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string LongName(string s)
  {
   if(s == "EUR")    s = "Euro ";
   if(s == "USD")    s = "US Dollar ";
   if(s == "JPY")    s = "Japanese Yen";
   if(s == "CAD")    s = "Canadian Dollar";
   if(s == "AUD")    s = "Australian Dollar";
   if(s == "NZD")    s = "New Zeeland Dollar";
   if(s == "GBP")    s = "Cable";
   if(s == "CHF")    s = "Swiss Francs";
   return (s);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PairName(string s)
  {
   string a,b;
   a = StringSubstr(s,0,3);
   b = StringSubstr(s,3,3);
   a = LongName(a);
   if(StringLen(a)>3) a=a+" to ";
   b=LongName(b);
   return (a+b);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SpeakTime()
  {
   int p;
   string s;
   p=Period();
   switch(p)
     {
      case 30:   s = "half hour";  break;
      case 60:   s = "One hour";   break;
      case 120:  s = "Two horus";  break;
      case 240:  s = "Four hours"; break;
      case 1440: s = "One day";    break;
      case 10080: s = "One week";  break;
      case 43200: s = "One month"; break;
      default:
         s=p+" Minutes";
     }
   return (s);
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
bool bInit;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   OldPeriod = -1;
   OldSymbol = "";

   lastSignalTime=0;
   InitSpeak();
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBufferFast);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBufferSlowLow);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBufferSlowHigh);
   IndicatorShortName("Cross Moving Average");
   SetIndexLabel(0,"Fast Moving Average");
   SetIndexLabel(1,"Slow Low");
   SetIndexLabel(2,"Slow High");
   makelabel("profit",0,20,"Profit Total",White);
   makelabel("profityesterday",300,20,"Profit Total",White);
   makelabel("signal",500,20,"Signal",White);
   cBars=0;
   ArrayResize(gTradeOpen,500);
   ArrayResize(gTradeMin,500);
   ArrayResize(gTradeMax,500);
   ArrayResize(gTradeCmd,500);
   ArrayResize(gTradeStart,500);
   ArrayResize(gTradeEnd,500);
   SendVars();
   firstTradeCandle=0;

   bInit=true;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendVars()
  {
   string sym=Symbol()+Period();
   GlobalVariableSet(sym+"PeriodShort",PeriodShort);
   GlobalVariableSet(sym+"PeriodLong",PeriodLong);
   GlobalVariableSet(sym+"Method",Method);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetVars()
  {
   string sym=Symbol()+Period();
   PeriodShort= GlobalVariableGet(sym+"PeriodShort");
   PeriodLong = GlobalVariableGet(sym+"PeriodLong");
   Method=GlobalVariableGet(sym+"Method");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DelVars()
  {
   string sym=Symbol()+Period();
   GlobalVariableDel(sym+"PeriodShort");
   GlobalVariableDel(sym+"PeriodLong");
   GlobalVariableDel(sym+"Method");
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   DeleteObjects();
   DelVars();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   spread=MarketInfo(Symbol(),MODE_SPREAD);
//----
   int         i;                      // some running integer 
   int         start;
   int         objid;                  // the number of triangles
   double      maS;                // moving average small and long value
   double      maS1,maLHigh1,maLLow1;                // moving average small and long value
   double      maLHigh,maLLow;
   double      profit = 0;             // profit of "trade" as difference between open and close
   double      open;                   // the open price
   datetime    opentime;               // the time of open trade
   int         openid;                 // the index of open trade
   int         signal,s;               // active and new singal
   double      totalProfit;            // total profit

   double      totalProfitYesterday;    // total profit yesterday
   bool        newBar;
   string      speak;
   string      alert;

   speak = "*";
   alert = "*";
//SpeakRSI();   
   signal=SIGNAL_NONE;
   if(Bars!=cBars)
      newBar=true;
   else
      newBar=false;
   cBars=Bars;

//if (Period() != OldPeriod || Symbol() != OldSymbol)
   if(bInit)
     {

      OldPeriod = Period();
      OldSymbol = Symbol();
      if(Optimize || (OptimizeOnNewCandle && newBar)) Optimize();

      Print("Symbol Changed, last Speak time set to ",TimeToStr(lastSignalTime));
     }
   objid=0;
   if(newBar) DeleteObjects();                    // delete old objects
                                                  // when starts today?
   CalcDays();
   totalProfit           = 0;
   totalProfitYesterday  = 0;

   if(lastSignalTime==0) lastSignalTime=Time[0];
   ObjectCreate("today",OBJ_VLINE,0,Time[today],0);
   ObjectCreate("yesterday",OBJ_VLINE,0,Time[yesterday],0);
   start=Bars-1;
   if(start>RepaintBars) start=RepaintBars;
   if(RepaintBars!=0) if(start>RepaintBars) start=RepaintBars;
   maLHigh  = iMA(NULL,NULL,PeriodLong,0,Method,PRICE_HIGH,start);
   maLLow   = iMA(NULL,NULL,PeriodLong,0,Method,PRICE_LOW,start);
   maLHigh1 = iMA(NULL,NULL,PeriodLong,0,Method,PRICE_HIGH,start);
   maLLow1  = iMA(NULL,NULL,PeriodLong,0,Method,PRICE_LOW,start);


// find first bar to start trading
   int tradeStart=RepaintBars;
   if(firstTradeCandle==0)
     {
      if(Bars>RepaintBars)
        {
         firstTradeCandle=Time[RepaintBars];
         tradeStart=RepaintBars;
        }
      else
        {
         firstTradeCandle=Time[Bars-1];
         tradeStart=Bars-1;
        }
     }
   else
     {
      for(i=0;i<Bars;i++)
        {
         if(Time[i]==firstTradeCandle)
           {
            tradeStart=i;
            break;
           }

        }
     }
//Print("TradeStart=",tradeStart, " Trade Start Time=",TimeToStr(firstTradeCandle));
   for(i=Bars-1;i>=0;i--)
     {
      maS=iMA(NULL,NULL,PeriodShort,0,Method1,Price1,i);
      maLHigh= iMA(NULL,NULL,PeriodLong,0,Method2,Price2,i);
      maLLow = iMA(NULL,NULL,PeriodLong,0,Method2,Price3,i);
      ExtMapBufferFast[i]=maS;
      ExtMapBufferSlowHigh[i]= maLHigh;
      ExtMapBufferSlowLow[i] = maLLow;

      if(i<tradeStart)
        {
         maS1=maS;
         maLLow1=maLLow;
         maLHigh1=maLHigh;

         s=signal;

           {
            if(maS < maLLow) s = SIGNAL_SHORT;
            if(maS> maLHigh) s = SIGNAL_LONG;
           }
         if(s!=signal)
           {

            if(s==SIGNAL_SHORT)
              {
               if(Time[i]>lastSignalTime && Alarm)
                 {
                  Print("Speak time ",TimeToStr(Time[i]));
                  lastSignalTime=Time[i];
                  alert = AlertShort;
                  speak ="New signal at "+PairName(Symbol())+ " "+SpeakTime()+". signal is short. "+OtherSignals();
                  SetText("signal","Short");
                 }
              }

            if(s==SIGNAL_LONG)
              {
               if(Time[i]>lastSignalTime && Alarm)
                 {
                  Print("Speak time ",TimeToStr(Time[i]));
                  lastSignalTime=Time[i];
                  alert = AlertLong;
                  speak = "New signal at "+PairName(Symbol()) + " " + SpeakTime()+". Signal is long. "+OtherSignals();
                  SetText("signal","Long");
                 }
              }

            profit=0;
            if(signal==SIGNAL_SHORT)
              {
               profit=open-Close[i];
               profit /= Point;
               profit -= spread;
              }
            if(signal==SIGNAL_LONG)
              {
               profit=Close[i]-open;
               profit /= Point;
               profit -= spread;
              }

            if(signal!=SIGNAL_NONE)
              {
               objid++;
               DrawTriangle(objid,signal,opentime,Open[openid],Time[i],Close[i],profit);
              }

            //ExtMapBuffer2[i] = profit;
            if(i <= today)                    totalProfit+=profit;
            if(i <= yesterday && i > today)   totalProfitYesterday+=profit;
            opentime=Time[i];
            openid = i;
            signal = s;
            open=Open[i];
           }

         profit=0;
        }
     }
// terminate open "trade"

   if(signal!=SIGNAL_NONE)
     {
      i=0;
      if(signal==SIGNAL_SHORT)
        {
         profit=open-Close[i];
         profit /= Point;
         profit -= spread;
         SetText("signal","Short");
        }

      if(signal==SIGNAL_LONG)
        {
         profit=Close[i]-open;
         profit /= Point;
         profit -= spread;
         SetText("signal","Long");
        }

      //ExtMapBuffer2[i] = profit;
      totalProfit+=profit;
      objid++;
      DrawTriangle(objid,signal,opentime,Open[openid],Time[i],Close[i],profit);
     }

   i=totalProfit;
   SetText("profit","Profit totay with MA "+PeriodShort+"/"+PeriodLong+" is "+i+" Pips");
   i=totalProfitYesterday;
   SetText("profityesterday","Profit yesterday is "+i+" Pips");

   MaxObj=objid+1;
//----
   bInit=false;
   if(alert != "*")       Alert(alert);
   if(speak != "*")       LoudAlert(speak);
   return(0);
  }
//+------------------------------------------------------------------+

int trades;
double wins,losses;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcProfit(int bars,int mode1,int price1,int periodLong,int mode2,int price2,int price3,int periodShort)
  {
   double      maS,maLLow,maLHigh;   // moving average small and long value
   double      profit=0;             // profit of "trade" as difference between open and close
   double      totalProfit;
   int         i,gOpenTime,openid;
   double      open,price,min,max;
   int         s,signal;
   signal=SIGNAL_NONE;
   totalProfit=0;
   open=0;
   gTradeID=-1;

   for(i=bars;i>=0;i--)
     {
      maS     = iMA(NULL,NULL,periodShort,0,mode1,price1,i);
      maLHigh = iMA(NULL,NULL,periodLong,0,mode2,price2,i);
      maLLow  = iMA(NULL,NULL,periodLong,0,mode2,price3,i);
      s=signal;
      if(maS < maLLow) s = SIGNAL_SHORT;
      if(maS> maLHigh) s = SIGNAL_LONG;
      // calc min/max
      price=(Open[i]+Close[i])/2;

      if(signal!=SIGNAL_NONE)
        {
         if(price< min) min = price;
         if(price> max) max = price;
        }
      if(s!=signal)
        {
         if(gTradeID>=0)
           {
            gTradeMin[gTradeID] = min;
            gTradeMax[gTradeID] = max;
            gTradeEnd[gTradeID] = i;
            gTradeCmd[gTradeID] = s;
           }
         gTradeID++;
         gTradeOpen[gTradeID]=price;
         gTradeStart[gTradeID]=i;
         gTradeEnd[gTradeID]=0;
         min = 99999;
         max = -9999;
         profit=0;
         if(signal==SIGNAL_SHORT)
           {
            profit=open-price;
            profit /= Point;
            profit -= spread;
            totalProfit+=profit;

           }

         if(signal==SIGNAL_LONG)
           {
            profit=price-open;
            profit /= Point;
            profit -= spread;
            totalProfit+=profit;
           }

         gOpenTime=Time[i];
         openid = i;
         signal = s;
         open=price;

        }
     }

   if(signal!=SIGNAL_NONE)
     {
      profit=0;
      i=0;
      if(signal==SIGNAL_SHORT)
        {
         profit=open-Open[i];
         profit /= Point;
         profit -= spread;
         totalProfit+=profit;
        }

      if(signal==SIGNAL_LONG)
        {
         profit=Open[i]-open;
         profit /= Point;
         profit -= spread;
         totalProfit+=profit;
        }



     }
   return (totalProfit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Optimize()
  {
   if(OptimizeSystems)
      OptimizeSystems();
   if(OptimizeAll)
      OptimizeAll();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OptimizeSystems()
  {
   double profit,maxProfit;
   int s,l,mode1,mode2,price1,price2;
   int bestS,bestL,bestM1,bestM2,bestPrice1,bestPrice2,bestPrice3;
   bestS = 0;
   bestL = 0;
   maxProfit=-9999;
   int i;
   i=0;
   while(true)
     {
      price1= Systems[i];
      mode1 = Systems[i+1];
      s     = Systems[i+2];
      price2= Systems[i+3];
      mode2 = Systems[i+4];
      l     = Systems[i+5];
      if(l==0 || s==0) break;
      i+=6;
      profit=CalcProfit(CountOptimize,mode1,price1,l,mode2,price2,price2,s);
      Print("Optimize ",mode1," ",price1," ",s," ",mode2," ",price2," ",l," profit=",profit);

      if(profit>maxProfit && profit!=0)
        {
         bestS = s;
         bestL = l;
         bestM1 = mode1;
         bestM2 = mode2;
         bestPrice1 = price1;
         bestPrice2 = price2;
         bestPrice3 = price2;
         maxProfit=profit;
        }
     }
   PeriodShort=bestS;
   PeriodLong   = bestL;
   Method1      = bestM1;
   Method2      = bestM2;
   Price1       = bestPrice1;
   Price2       = bestPrice2;
   Price3       = bestPrice2;
   SendVars();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OptimizeAll()
  {
   double profit,maxProfit;
   int s,l;
   int bestS,bestL;
   bestS = 0;
   bestL = 0;
   maxProfit=-9999;
   for(s=MinShortMA; s<=MaxShortMA;s+=StepShortMA)
     {
      //a = s*130;
      //a /= 100;
      for(l=s+StepShortMA;l<=MaxLongMA;l+=StepLongMA)
        {
         profit=CalcProfit(CountOptimize,Method,PRICE_MEDIAN,l,Method,PRICE_HIGH,PRICE_LOW,s);

         if(profit>maxProfit && profit!=0)
           {
            bestS = s;
            bestL = l;
            maxProfit=profit;
           }
        }
     }
   Method1      = Method;
   Method2      = Method;
   Price1       = PRICE_MEDIAN;
   Price2       = PRICE_HIGH;
   Price3       = PRICE_LOW;
   PeriodShort=bestS;
   PeriodLong=bestL;
   SendVars();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalcDays()
  {
   int day;
   int i;
   day=TimeDay(Time[0]);
   for(i=0;i<Bars;i++)
     {
      if(TimeDay(Time[i])!=day)
        {
         today=i-1;
         break;
        }
     }
// when starts yesterday 
   day=TimeDay(Time[today+1]);
   for(i=today+1;i<Bars;i++)
     {
      if(TimeDay(Time[i])!=day)
        {
         yesterday=i-1;
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTriangle(int objid,int signal,datetime opentime,double openprice,datetime timenow,double pricenow,double profit)
  {
   string name;
   int i;
   if(DrawTringles)
     {
      //Print("signal=",Sig2Str(signal)," open=",openprice," close=",pricenow," profit=",profit);
      name="profit"+objid;
      ObjectCreate(name,OBJ_TRIANGLE,0,opentime,openprice,timenow,openprice,timenow,pricenow);
      if(signal==SIGNAL_SHORT)
         ObjectSet(name,OBJPROP_COLOR,ColorShortTrade);
      else
         ObjectSet(name,OBJPROP_COLOR,ColorLongTrade);
      ObjectSet(name,OBJPROP_BACK,false);
      if(profit<0)
        {
         ObjectSet(name,OBJPROP_COLOR,ColorBadTrade);
        }

      ObjectSet(name,OBJPROP_WIDTH,2);
     }
   name="win"+objid;
   i=profit;
   ObjectCreate(name,OBJ_TEXT,0,timenow,pricenow-20*Point);
   ObjectSetText(name,i+" Pips",8,"Tahoma",White);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteObjects()
  {
   int i;
   string name;
   for(i=0;i<500;i++)
     {
      name="profit"+i;
      ObjectDelete(name);
      name="win"+i;
      ObjectDelete(name);
     }
/*
   for (i=0;i<CountOptimize;i++)
   {
       name = "mas"+Time[i];
       ObjectDelete(name);

       name = "masO"+Time[i];
       ObjectDelete(name);
       name = "masC"+Time[i];
       ObjectDelete(name);

       name = "mal"+Time[i];
       ObjectDelete(name);
   }
    */
   MaxObj=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void makelabel(string lblname,int x,int y,
               string txt,color txtcolor)
  {
   ObjectCreate(lblname,OBJ_LABEL,0,0,0);
   ObjectSet(lblname,OBJPROP_CORNER,0);
   ObjectSetText(lblname,txt,7,"Verdana",txtcolor);
   ObjectSet(lblname,OBJPROP_XDISTANCE,x);
   ObjectSet(lblname,OBJPROP_YDISTANCE,y);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetText(string name,string txt)
  {
   ObjectSetText(name,txt,7,"Verdana",White);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Rectangle(string name,datetime time,double price,int col)
  {
   string name1;
   name1=name+Time[time];
   ObjectCreate(name1,OBJ_RECTANGLE,0,Time[time],price,Time[time+1],price+Point/2);
   ObjectSet(name1,OBJPROP_COLOR,col);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Rectangle2(string name,datetime time,datetime time2,double price,int col)
  {
//Print("Rect2 ",name," ",TimeToStr(time), " ",TimeToStr(time2)," ",price);
   string name1;
   name1=name+time;
   ObjectCreate(name1,OBJ_RECTANGLE,0,time,price,time2,price+Point/2);
   ObjectSet(name1,OBJPROP_COLOR,col);
  }

bool stochKBiggerD=false;
bool stochFirst=true;
string stochLast;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitSpeak()
  {
   stochKBiggerD=false;
   stochFirst=true;
  }
// creates a speakable text about other symbols

string OtherSignals()
  {
   string s;
   double sar=iSAR(NULL,Period(),0.02,0.2,0);
   if(sar<Ask) s="SAR is long"; else s="SAR is short";
   return (s);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SpeakRSI()
  {
   string s;
   double rsi=iRSI(NULL,0,14,Ask,0);
   if(rsi > 70) s = "RSI " + PairName(Symbol())+ " is overbought";
   if(rsi < 30) s = "RSI " + PairName(Symbol())+ " is oversold";
   if(s!=rsiMessage)
     {
      rsiMessage=s;
      LoudAlert(s);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Sig2Str(int signal)
  {
   string r="undef";
   switch(signal)
     {
      case SIGNAL_NONE: r = "none"; break;
      case SIGNAL_LONG: r = "long"; break;
      case SIGNAL_SHORT: r= "short"; break;
     }
   return (r);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PreditCurve()
  {
   double a,b,c;
   double d,dd;
   datetime dt,t;
   double   ma;

   int i;

   dd= 0;
   d = 0;
   for(i=Bars-10;i>=0;i--)
     {
      a = iMA(NULL,NULL,PeriodLong,0,Method,PRICE_MEDIAN,i+2);
      b = iMA(NULL,NULL,PeriodLong,0,Method,PRICE_MEDIAN,i+1);
      c = iMA(NULL,NULL,PeriodLong,0,Method,PRICE_MEDIAN,i);
      d+= b-a;
      dd+=(b-a)-(c-b);
     }
   d/=10;
   dd/=10;
   ma = iMA(NULL,NULL,PeriodLong,0,Method,PRICE_MEDIAN,0);
   dt = Time[0]-Time[1];
   t=Time[0];
   for(i=0;i<10;i++)
     {
      Rectangle2("futur",t,t+dt,ma,Silver);
      ma+=d;
      d+=dd;
      t+= dt;
     }

  }
//+------------------------------------------------------------------+
