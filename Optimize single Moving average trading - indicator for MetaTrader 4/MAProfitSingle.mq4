//+------------------------------------------------------------------+
//|                                                     MAProfit.mq4 |
//|                      Copyright © 2010, Thomas Quester.           |
//|                                        tquester@gmx.de           |
//+------------------------------------------------------------------+

/*
   I do custom mql4/mql5 programming at low prices.
   
   
   If you wish to thank the autor, you might do the following
     
     - Send money to PayPal:        tquester@gmx.de
     - Send money to Moneybrokers:  tquester@gmx.de
     - Open an account at avafx and drop me a line with your user name (both will receive a rebate)
     - Open an account at instaforex and refer to my account number: 3003318
     
     
     
*/

#property copyright "Copyright © 2010, Thomas Quester 'tflores'."
#property link      "tquester@gmx.de"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Aqua
#property indicator_color2 Yellow

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

/* You may change this if you want different audio files for long/short signals. */

string AlertShort = "alert.wav";
string AlertLong  = "alert.wav";



extern bool      bOptimize=true;                    // True: Find the best single MA by optimizing (switch time frame to re-optimize)
extern bool      bOptimizeIntersect=true;           // True: optimize for minimum intersections, otherwise optimize for max profit
extern int       PeriodMA=400;                     // If you do not want to optimize, you can define a period
extern int       Method=0;                         // Method for MA 0 = Simple, 1 = Expotential, 2 = Smoothed, 3 = Linear weighted
extern bool      DrawTringles=true;                // Draws triangles for the simulated trading
extern int       MinMA=5;                          // Minimum test for optimizing
extern int       MaxMA=500;                        // Maximum test for optimizing
extern int       StepMA=1;                         // Step during optimizion, 1 tests every MA, 10 tests every 10th etc.
extern int       CountOptimize=300;                // Number of candles for optimizing
extern int       RepaintBars=3000;                 // Number of candles on which we draw triangles and calculate the win/loss
extern bool      Alarm=true;                       // Make a visible alert on new signal
extern bool      bSpeak=true;                       // Speak the alert with gspeak 
bool             bNeedOptimize;
int              ColorLongTrade  = MediumSpringGreen;
int              ColorShortTrade = Red;
int              ColorBadTrade   = Violet;
bool             bAlertViaAlert = true;
datetime         lastSignalTime=0;
datetime         firstTradeCandle;                    // we trade 300 candles but at all calls it should be the same candle
int Method1 = MODE_SMA;
int Method2 = MODE_SMA;
int Price1 = PRICE_MEDIAN;
int Price2 = PRICE_HIGH;
int Price3 = PRICE_LOW;                                                      

//---- buffers
double ExtMapBuffer[];                            // Fast MA curve
double ExtMapBuffer2[];                            // Fast MA curve
int OldPeriod;                                        // The period, we check for changes and re-init ourself
int spread;                            
int cBars;                                            // Saved number of bars in order to see if new bar
string OldSymbol;                                     // If symbol canges, we re-initialize
string rsiMessage;                                    // Last Message RSI Oversold/Overbought

#define SIGNAL_NONE  0
#define SIGNAL_SHORT 1
#define SIGNAL_LONG  2

int               MaxObj = 0;
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
                  

void LoudAlert(string s)
{
   if (bAlertViaAlert) Alert(s);
   Print(s);
   if (bSpeak) gSpeak(s);        // uncomment this for speak
}

string FormatNumber(string s)
{
    int c;
    while (true)
    {
       c = StringGetChar(s,StringLen(s)-1);
       if (c != '.' && c != '0') break;
       s = StringSubstr(s,0,StringLen(s)-1);
    }
    return (s);
}

string LongName(string s)
{
   if (s == "EUR")    s = "Euro ";
   if (s == "USD")    s = "US Dollar ";
   if (s == "JPY")    s = "Japanese Yen";
   if (s == "CAD")    s = "Canadian Dollar";
   if (s == "AUD")    s = "Australian Dollar";
   if (s == "NZD")    s = "New Zeeland Dollar";
   if (s == "CHF")    s = "Swiss Francs";
   return (s);
}

string PairName(string s)
{
   string a,b;
   a = StringSubstr(s,0,3);
   b = StringSubstr(s,3,3);
   a = LongName(a);
   if (StringLen(a) > 3) a = a + " to ";
   b = LongName(b);
   return (a+b);
}

string SpeakTime()
{ 
   int p;
   string s;
   p = Period();
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
          s = p+" Minutes";
   }
   return (s);
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
bool bInit;
int init()
  {
//---- indicators
   OldPeriod = -1;
   OldSymbol = "";
   bNeedOptimize = true;
   lastSignalTime = 0  ;
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexBuffer(1,ExtMapBuffer2);
   
   IndicatorShortName("Cross Moving Average");
   SetIndexLabel(0,"Fast Moving Average");
   makelabel("profit",              0,20,"Profit Total",White);   
   makelabel("profityesterday",     300,20,"Profit Total",White);   
   makelabel("signal",              500,20,"Signal",White); 
   makelabel("message",             600,20,"Message",White);  
   makelabel("message2",            600,40,"Message",White);  
   makelabel("hint",                400,0,"MAProfit (C) Thomas Quester",White);
   makelabel("hint2",               600,0,"look at source code for description",White);
   cBars = 0;
   ArrayResize(gTradeOpen,500);
   ArrayResize(gTradeMin,500);
   ArrayResize(gTradeMax,500);
   ArrayResize(gTradeCmd,500);
   ArrayResize(gTradeStart,500);
   ArrayResize(gTradeEnd,500);
   SendVars();
   firstTradeCandle = 0;

   bInit = true;
//----
   return(0);
  }
  
  
void SendVars()
{
   string sym = Symbol()+Period();
   GlobalVariableSet(sym+"PeriodMA",PeriodMA);
   GlobalVariableSet(sym+"Method",Method);
}   

void GetVars()
{
   string sym = Symbol()+Period();
   PeriodMA = GlobalVariableGet(sym+"PeriodMA");
   
   Method = GlobalVariableGet(sym+"Method");
}   

void DelVars()
{
   string sym = Symbol()+Period();
   GlobalVariableDel(sym+"PeriodMA");
   
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
   spread = MarketInfo(Symbol(),MODE_SPREAD);
//----
//----
   int         i;                      // some running integer 
   int         start;
   int         objid;                  // the number of triangles
   string      name;                   // name of triangle
   double      d;                      // some double 
   double      maPeriod;               // moving average Period
   double      profit = 0;             // profit of "trade" as difference between open and close
   double      open;                   // the open price
   int         day;                    // the day
   datetime    opentime;               // the time of open trade
   int         openid;                 // the index of open trade
   int         signal,s;               // active and new singal
   double      totalProfit;            // total profit
   
   double      totalProfitYesterday;    // total profit yesterday
   bool        newBar;
   string      speak;
   string      alert;
   double      ma,price,maHigh;
   if (bNeedOptimize)
       Optimize();
   bNeedOptimize=false;

   speak = "*";
   alert = "*";
   //SpeakRSI();   
   signal = SIGNAL_NONE;
   if (Bars != cBars)
       newBar = true;
   else  
       newBar = false;
   cBars = Bars;

   //if (Period() != OldPeriod || Symbol() != OldSymbol)
   if (bInit)
   {
      
      OldPeriod = Period();
      OldSymbol = Symbol();
      
      Print("Symbol Changed, last Speak time set to ",TimeToStr(lastSignalTime));
   }
   objid = 0;
   if (newBar) DeleteObjects();                    // delete old objects
   
   // when starts today?
   CalcDays();
   totalProfit           = 0;
   totalProfitYesterday  = 0;
   
   
   if (lastSignalTime == 0)
       lastSignalTime = Time[0];
   ObjectCreate("today",OBJ_VLINE,0,Time[today],0);
   ObjectCreate("yesterday",OBJ_VLINE,0,Time[yesterday],0);
   start = Bars;
   if (start > RepaintBars) start = RepaintBars;
   if (RepaintBars != 0) if (start > RepaintBars) start = RepaintBars;
   ma       = iMA(NULL,NULL,PeriodMA,0,Method,PRICE_MEDIAN,start);
   
   
   // find first bar to start trading
   
   int tradeStart=RepaintBars;
   if (firstTradeCandle == 0)
   {  if (Bars > RepaintBars)
      {
         firstTradeCandle = Time[RepaintBars];
         tradeStart = RepaintBars;
      }
      else 
      {
         firstTradeCandle = Time[Bars];
         tradeStart = Bars;
      }
   }
   else
   {
      for (i=0;i<Bars;i++)
      {
         if (Time[i] == firstTradeCandle)
         {
             tradeStart = i;
             break;
         }
         
      }
   }
   //Print("TradeStart=",tradeStart, " Trade Start Time=",TimeToStr(firstTradeCandle));
   int good=0;
   int fails=0;
   int totalWin=0;
   for (i=Bars;i>=0;i--)
   {
      
      ma       = iMA(NULL,NULL,PeriodMA,0,Method,PRICE_LOW,i);
      maHigh   = iMA(NULL,NULL,PeriodMA,0,Method,PRICE_HIGH,i);
      ExtMapBuffer[i] = ma;
      ExtMapBuffer2[i] = maHigh;
      
      if (i < tradeStart)
      {
         price = (High[i]+Low[i])/2;
         s = signal;       
         {
            if (Low[i] < ma) s = SIGNAL_SHORT; 
            if (High[i] > maHigh) s = SIGNAL_LONG;
         }
         if (s != signal)
         {
          
             if (s == SIGNAL_SHORT)
             {
             
                 if (Time[i] > lastSignalTime && bSpeak)
                  {
                      Print("Speak time ",TimeToStr(Time[i]));
                      lastSignalTime = Time[i];
                      alert = AlertShort;
                      speak ="New signal at "+PairName(Symbol())+ " "+SpeakTime()+". signal is short. ";
                      SetText("signal","Short");
                  }
             }
          
             if (s == SIGNAL_LONG)
             {
                  if (Time[i] > lastSignalTime && bSpeak)
                  {
                     Print("Speak time ",TimeToStr(Time[i]));
                     lastSignalTime = Time[i];
                     alert = AlertLong;
                     speak = "New signal at "+PairName(Symbol()) + " " + SpeakTime()+". Signal is long. ";
                     SetText("signal","Long");
                  }
             }
          
             profit = 0;
             if (signal == SIGNAL_SHORT) 
             {
                  profit = open-Close[i];
                  profit /= Point;
                  profit -= spread;
             }
             if (signal == SIGNAL_LONG)  
             {
                  profit = Close[i]-open;
                  profit /= Point;
                  profit -= spread;
             }
             totalWin+=profit;
             if (profit < 0) fails++;
             if (profit > 0) good++;
          
             if (signal != SIGNAL_NONE)
             {
                 objid++;
                 DrawTriangle(objid,signal,opentime,Open[openid],Time[i],Close[i],profit);              
             }
          
             //ExtMapBuffer2[i] = profit;
             if (i <= today)                    totalProfit+=profit;
             if (i <= yesterday && i > today)   totalProfitYesterday+=profit;
             opentime = Time[i];
             openid = i;
             signal = s;
             open = Open[i];
         }
          
         profit = 0;
      }
   }
   // terminate open "trade"
      
   if (signal != SIGNAL_NONE)
   {
        i = 0;
        if (signal == SIGNAL_SHORT) 
        {
            profit = open-Close[i];
            profit /= Point;
            profit -= spread;
            SetText("signal","Short");
          }
            
        if (signal == SIGNAL_LONG)  
        {
               profit = Close[i]-open;
               profit /= Point;
               profit -= spread;
               SetText("signal","Long");
        }
        
        //ExtMapBuffer2[i] = profit;
        totalProfit+=profit;
        totalWin+=profit;
       if (profit < 0) fails++;
       if (profit > 0) good++;
        
        objid++;
        DrawTriangle(objid,signal,opentime,Open[openid],Time[i],Close[i],profit);
        
    }
    
    i = totalProfit;
    SetText("profit","Profit totay with MA "+PeriodMA+" is "+i+" Pips");
    SetText("message2","Total Profit="+totalWin+" Fails="+fails+" Wins="+good);
    if (totalWin < 0)
       ObjectSet("message2",OBJPROP_COLOR,Red);
    else
       ObjectSet("message2",OBJPROP_COLOR,GreenYellow);
    i = totalProfitYesterday;
    SetText("profityesterday","Profit yesterday is "+i+" Pips");
   
   MaxObj=objid+1;
//----
   bInit = false;

   if (alert != "*")       Alert(alert);
   if (speak != "*")       LoudAlert(speak);
   return(0);
  }
//+------------------------------------------------------------------+


int trades;
double wins, losses;

double CalcProfit(int bars, int mode1, int price1, int mode2, int price2, int price3, int periodMA)
{
   double      ma;                // moving average small and long value
   double      profit = 0;             // profit of "trade" as difference between open and close
   double      totalProfit;
   int         i,gOpenTime,openid;
   double      d,open,price,min,max;
   int         s,signal;
   signal = SIGNAL_NONE;
   totalProfit           = 0;
   open = 0;
   gTradeID=-1;
   
   for (i=bars;i>=0;i--)
   {
      ma     = iMA(NULL,NULL,periodMA,0,mode1,price1,i);
      s = signal;
      price = (High[i]+Low[i])/2;
      if (ma < price) s = SIGNAL_SHORT; 
      if (ma > price) s = SIGNAL_LONG;
      // calc min/max
   
      if (signal != SIGNAL_NONE)
      {
          if (price< min) min = price;
          if (price > max) max = price;
      } 
      if (s != signal)
      {
          if (gTradeID >= 0)
          {
              gTradeMin[gTradeID] = min;
              gTradeMax[gTradeID] = max;
              gTradeEnd[gTradeID] = i;
              gTradeCmd[gTradeID] = s;
          }
          gTradeID++;
          gTradeOpen[gTradeID] = price;
          gTradeStart[gTradeID] = i;
          gTradeEnd[gTradeID] = 0;
          min = 99999;
          max = -9999;
          profit = 0;
          if (signal == SIGNAL_SHORT) 
          {
            profit = open-price;
            profit /= Point;
            profit -= spread;
            totalProfit += profit;
            
          }
            
          if (signal == SIGNAL_LONG)  
          {
            profit = price-open;
            profit /= Point;
            profit -= spread;
            totalProfit += profit;
          }
            
          gOpenTime = Time[i];
          openid = i;
          signal = s;
          open = price;
          
      }
   }
   
      
   if (signal != SIGNAL_NONE)
   {
      profit = 0;
      i = 0;
      if (signal == SIGNAL_SHORT) 
      {
         profit = open-Open[i];
         profit /= Point;
         profit -= spread;
         totalProfit += profit;
      }
         
      if (signal == SIGNAL_LONG)  
      {
         profit = Open[i]-open;
         profit /= Point;
         profit -= spread;
         totalProfit += profit;
      }
         
      
      
        
    }
    return (totalProfit);
}

void Optimize()
{
   if (bOptimize) 
   {
      if (bOptimizeIntersect)
          OptimizeIntersects();
      else
          OptimizeAll();
   }
   else  
      SetText("message","Optimizing is disabled");
    
}    


void OptimizeIntersects()
{
   int i,s,intersects,minInterSects;
   double ma;
   minInterSects = 9999;
   for (s = MinMA; s<=MaxMA;s+=StepMA)
   {
      intersects=0;
      for (i=CountOptimize;i>=0;i--)
      {
         ma     = iMA(NULL,NULL,s,0,Method,PRICE_MEDIAN,i);
         if (ma >= Low[i] && ma <= High[i]) intersects++;
      }
      if (intersects < minInterSects)
      {
          minInterSects = intersects;
          PeriodMA = s;
      }
   }
   SetText("message","BestMA="+PeriodMA+" Intersects="+minInterSects);
   
 }                 
                 
void OptimizeAll()
{
    double profit, maxProfit;
    int s,l,a;
    int bestMA;
    bestMA = 0;
    
    maxProfit=-9999;
    for (s = MinMA; s<=MaxMA;s+=StepMA)
    {
        //a = s*130;
        //a /= 100;
           profit = CalcProfit(CountOptimize,Method,PRICE_MEDIAN,Method,PRICE_HIGH,PRICE_LOW,s);

           if (profit > maxProfit && profit != 0)
           {
              bestMA = s;
              
              maxProfit = profit;
           }
    }
    Method1      = Method;
    Method2      = Method;
    Price1       = PRICE_MEDIAN;
    Price2       = PRICE_HIGH;
    Price3       = PRICE_LOW;
    PeriodMA = bestMA;
    SetText("message","BestMA="+PeriodMA+" Profit="+maxProfit);

    SendVars();
}

void CalcDays()
{
   int day;
   int i;
   day = TimeDay(Time[0]);
   for (i=0;i<Bars;i++)
   {
      if (TimeDay(Time[i]) != day)
      {
          today = i-1;
          break;
      }
   }
   // when starts yesterday 
   day = TimeDay(Time[today+1]);
   for (i=today+1;i<Bars;i++)
   {
      if (TimeDay(Time[i]) != day)
      {
          yesterday = i-1;
          break;
      }
   }
}

void DrawTriangle(int objid,int signal, datetime opentime,double openprice,datetime timenow,double pricenow,double profit)
{
  string name;
  int i;
  if (DrawTringles)
  {
      //Print("signal=",Sig2Str(signal)," open=",openprice," close=",pricenow," profit=",profit);
      name = "profit"+objid;
      ObjectCreate(name,OBJ_TRIANGLE,0,opentime,openprice,timenow,openprice,timenow,pricenow);
      if (signal == SIGNAL_SHORT)
          ObjectSet(name,OBJPROP_COLOR,ColorShortTrade);
      else
          ObjectSet(name,OBJPROP_COLOR,ColorLongTrade);
      ObjectSet(name,OBJPROP_BACK,false);
      if (profit < 0)
      {
            ObjectSet(name,OBJPROP_WIDTH,1);
      }
      else
         ObjectSet(name,OBJPROP_WIDTH,3);
  }
  name = "win"+objid;
  i = profit;
  ObjectCreate(name, OBJ_TEXT, 0, timenow, pricenow-20*Point);
  ObjectSetText(name, i+" Pips", 8, "Tahoma", White);
  
}

void DeleteObjects()
{
   int i;
   string name;
   for (i=0;i<500;i++)
   {
      name = "profit"+i;
      ObjectDelete(name);
      name = "win"+i;
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
   MaxObj = 0;
 }

void makelabel(string lblname,int x,int y,
   string txt,color txtcolor){
   ObjectCreate(lblname, OBJ_LABEL,0, 0, 0);
   ObjectSet(lblname, OBJPROP_CORNER, 0);
   ObjectSetText(lblname,txt,8,"Verdana", txtcolor);
   ObjectSet(lblname, OBJPROP_XDISTANCE, x);
   ObjectSet(lblname, OBJPROP_YDISTANCE, y);
}

void SetText(string name, string txt)
{
   ObjectSetText(name,txt,7,"Verdana", White);
}

void Rectangle(string name, datetime time, double price, int col)
{
    string name1;
    name1 = name + Time[time];
    ObjectCreate(name1, OBJ_RECTANGLE, 0, Time[time],price,Time[time+1],price+Point/2);
    ObjectSet(name1,OBJPROP_COLOR,col);
}

void Rectangle2(string name, datetime time, datetime time2,double price, int col)
{
    string name1;
    name1 = name + time;
    ObjectCreate(name1, OBJ_RECTANGLE, 0, time,price,time2,price+Point/2);
    ObjectSet(name1,OBJPROP_COLOR,col);
}


// creates a speakable text about other symbols

    
string Sig2Str(int signal)
{
   string r = "undef";
   switch(signal)
   {
      case SIGNAL_NONE: r = "none"; break;
      case SIGNAL_LONG: r = "long"; break;
      case SIGNAL_SHORT: r = "short"; break;
   }
   return (r);
 }



