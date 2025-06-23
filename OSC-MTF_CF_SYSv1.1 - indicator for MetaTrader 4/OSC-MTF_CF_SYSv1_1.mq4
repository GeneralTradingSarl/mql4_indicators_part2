//+------------------------------------------------------------------+
//|                                               OSC-MTF_CF_SYS.mq4 |
//|                                                           kuncup |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "kuncup"
#property link      "http://www.indofx-trader.net"
//----
#property indicator_separate_window
#property  indicator_buffers 6
//----
#property  indicator_color1  Yellow
#property  indicator_color2  MediumOrchid
#property  indicator_color3  SteelBlue
#property  indicator_color4  Khaki
#property  indicator_width3  2
#property  indicator_width4  2
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
extern string __Method_Note="0=SMA, 1=EMA, 2=SMMA, 3=WMA";
extern string __AppliedPrice_Note="0=Close, 1=Open, 2=High, 3=Low, 4=(H+L)/2, 5=(H+L+C)/3, 6=(H+L+C+C)/4";
//----
extern string D1_Separator="Daily MA";
extern int D1_HowManyBars=0;
extern int MA1D1_Period=8;
extern int MA1D1_Method=1;
extern int MA1D1_AppliedPrice=0;
extern int MA2D1_Period=12;
extern int MA2D1_Method=1;
extern int MA2D1_AppliedPrice=0;
extern int MA3D1_Period=24;
extern int MA3D1_Method=1;
extern int MA3D1_AppliedPrice=0;
extern int MA4D1_Period=72;
extern int MA4D1_Method=1;
extern int MA4D1_AppliedPrice=0;
//----
extern string H4_Separator="H4 MA";
extern int H4_HowManyBars=0;
extern int MA1H4_Period=8;
extern int MA1H4_Method=1;
extern int MA1H4_AppliedPrice=0;
extern int MA2H4_Period=12;
extern int MA2H4_Method=1;
extern int MA2H4_AppliedPrice=0;
extern int MA3H4_Period=24;
extern int MA3H4_Method=1;
extern int MA3H4_AppliedPrice=0;
extern int MA4H4_Period=72;
extern int MA4H4_Method=1;
extern int MA4H4_AppliedPrice=0;
//----
extern string H1_Separator="H1 MA";
extern int H1_HowManyBars=20;
extern int MA1H1_Period=8;
extern int MA1H1_Method=1;
extern int MA1H1_AppliedPrice=0;
extern int MA2H1_Period=12;
extern int MA2H1_Method=1;
extern int MA2H1_AppliedPrice=0;
extern int MA3H1_Period=24;
extern int MA3H1_Method=1;
extern int MA3H1_AppliedPrice=0;
extern int MA4H1_Period=72;
extern int MA4H1_Method=1;
extern int MA4H1_AppliedPrice=0;
//----
extern string M30_Separator="M30 MA";
extern int M30_HowManyBars=20;
extern int MA1M30_Period=8;
extern int MA1M30_Method=1;
extern int MA1M30_AppliedPrice=0;
extern int MA2M30_Period=12;
extern int MA2M30_Method=1;
extern int MA2M30_AppliedPrice=0;
extern int MA3M30_Period=24;
extern int MA3M30_Method=1;
extern int MA3M30_AppliedPrice=0;
extern int MA4M30_Period=72;
extern int MA4M30_Method=1;
extern int MA4M30_AppliedPrice=0;
//----
extern string M15_Separator="M15 MA";
extern int M15_HowManyBars=20;
extern int MA1M15_Period=8;
extern int MA1M15_Method=1;
extern int MA1M15_AppliedPrice=0;
extern int MA2M15_Period=12;
extern int MA2M15_Method=1;
extern int MA2M15_AppliedPrice=0;
extern int MA3M15_Period=24;
extern int MA3M15_Method=1;
extern int MA3M15_AppliedPrice=0;
extern int MA4M15_Period=72;
extern int MA4M15_Method=1;
extern int MA4M15_AppliedPrice=0;
//----
extern string M5_Separator="M5 MA";
extern int M5_HowManyBars=0;
extern int MA1M5_Period=8;
extern int MA1M5_Method=1;
extern int MA1M5_AppliedPrice=0;
extern int MA2M5_Period=12;
extern int MA2M5_Method=1;
extern int MA2M5_AppliedPrice=0;
extern int MA3M5_Period=24;
extern int MA3M5_Method=1;
extern int MA3M5_AppliedPrice=0;
extern int MA4M5_Period=72;
extern int MA4M5_Method=1;
extern int MA4M5_AppliedPrice=0;
//----
double Ema1[];
double Ema2[];
double Ema3[];
double Ema4[];
double HighPrice[];
double LowPrice[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexBuffer(0,Ema1);
   SetIndexBuffer(1,Ema2);
   SetIndexBuffer(2,Ema3);
   SetIndexBuffer(3,Ema4);
   SetIndexBuffer(4,HighPrice);
   SetIndexBuffer(5,LowPrice);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexStyle(5,DRAW_NONE);
   //
   SetIndexEmptyValue(0, 0.0);
   SetIndexEmptyValue(1, 0.0);
   SetIndexEmptyValue(2, 0.0);
   SetIndexEmptyValue(3, 0.0);
   IndicatorShortName("MTF MA Viewer");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
     for(int i=0;i<D1_HowManyBars;i++)
     {
      ObjectDelete("tlWickD1"+(string)i);
      ObjectDelete("tlBodyD1"+(string)i);
     }
     for(i=0;i<H4_HowManyBars;i++)
     {
      ObjectDelete("tlWickH4"+(string)i);
      ObjectDelete("tlBodyH4"+(string)i);
     }
     for(i=0;i<H1_HowManyBars;i++)
     {
      ObjectDelete("tlWickH1"+(string)i);
      ObjectDelete("tlBodyH1"+(string)i);
     }
     for(i=0;i<M30_HowManyBars;i++)
     {
      ObjectDelete("tlWickM30"+(string)i);
      ObjectDelete("tlBodyM30"+(string)i);
     }
     for(i=0;i<M15_HowManyBars;i++)
     {
      ObjectDelete("tlWickM15"+(string)i);
      ObjectDelete("tlBodyM15"+(string)i);
     }
     for(i=0;i<M5_HowManyBars;i++)
     {
      ObjectDelete("tlWickM5"+(string)i);
      ObjectDelete("tlBodyM5"+(string)i);
     }
   if (WindowFind("TF D1")!=-1)  ObjectDelete("TF D1");
   if (WindowFind("TF H4")!=-1)  ObjectDelete("TF H4");
   if (WindowFind("TF H1")!=-1)  ObjectDelete("TF H1");
   if (WindowFind("TF M30")!=-1) ObjectDelete("TF M30");
   if (WindowFind("TF M15")!=-1) ObjectDelete("TF M15");
   if (WindowFind("TF M5")!=-1)  ObjectDelete("TF M5");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   //if (Period()>PERIOD_H1) return(0);
//----
   double cp,op,hp,lp;
   int x=0;
   int BarCount=D1_HowManyBars;
   color cl;
   double maxhp=0;
     for(int i=1;i<BarCount+1;i++)
     {
      cp=iClose(NULL, PERIOD_D1, x);
      op=iOpen(NULL, PERIOD_D1, x);
      hp=iHigh(NULL, PERIOD_D1, x);
      lp=iLow(NULL, PERIOD_D1, x);
        if (cp > op)
        {
         cl=DodgerBlue;
        }
         else if(cp < op)
        {
         cl=Red;
        }
         else
        {
         cl=Green;
        }
         DrawTl("tlWickD1"+(string)x, Time[i], Time[i], lp, hp, cl, 1);
         DrawTl("tlBodyD1"+(string)x, Time[i], Time[i], op, cp, cl, 3);
         HighPrice[i]=hp;
         LowPrice[i] =lp;
         if (hp>maxhp) maxhp=hp;
//----
         Ema1[i]=iMA(NULL,PERIOD_D1,MA1D1_Period,0,MA1D1_Method,MA1D1_AppliedPrice,x);
         Ema2[i]=iMA(NULL,PERIOD_D1,MA2D1_Period,0,MA2D1_Method,MA2D1_AppliedPrice,x);
         Ema3[i]=iMA(NULL,PERIOD_D1,MA3D1_Period,0,MA3D1_Method,MA3D1_AppliedPrice,x);
         Ema4[i]=iMA(NULL,PERIOD_D1,MA4D1_Period,0,MA4D1_Method,MA4D1_AppliedPrice,x);
         x++;
     }
   if (BarCount!=0)
      drawText("TF D1", maxhp+(15*Point), Silver, Time[i-1]);
   else
      if(ObjectFind("TF D1")!=-1) ObjectDelete("TF D1");
   //return(0);
   int lasti=i+1;
   x=0;
   BarCount=H4_HowManyBars;
   maxhp=0;
     for(i=lasti;i<lasti+BarCount;i++)
     {
      cp=iClose(NULL, PERIOD_H4, x);
      op=iOpen(NULL, PERIOD_H4, x);
      hp=iHigh(NULL, PERIOD_H4, x);
      lp=iLow(NULL, PERIOD_H4, x);
        if (cp > op)
        {
         cl=DodgerBlue;
        }
         else if(cp < op)
        {
         cl=Red;
        }
         else
        {
         cl=Green;
        }
      DrawTl("tlWickH4"+(string)x, Time[i], Time[i], lp, hp, cl, 1);
      DrawTl("tlBodyH4"+(string)x, Time[i], Time[i], op, cp, cl, 3);
      HighPrice[i]=hp;
      LowPrice[i] =lp;
      if (hp>maxhp) maxhp=hp;
      Ema1[i]=iMA(NULL,PERIOD_H4,MA1H4_Period,0,MA1H4_Method,MA1H4_AppliedPrice,x);
      Ema2[i]=iMA(NULL,PERIOD_H4,MA2H4_Period,0,MA2H4_Method,MA2H4_AppliedPrice,x);
      Ema3[i]=iMA(NULL,PERIOD_H4,MA3H4_Period,0,MA3H4_Method,MA3H4_AppliedPrice,x);
      Ema4[i]=iMA(NULL,PERIOD_H4,MA4H4_Period,0,MA4H4_Method,MA4H4_AppliedPrice,x);
      x++;
     }
   if (BarCount!=0)
      drawText("TF H4", maxhp+(15*Point), Silver, Time[i-1]);
   else
      if(ObjectFind("TF H4")!=-1) ObjectDelete("TF H4");
   lasti=i+1;
   x=0;
   BarCount=H1_HowManyBars;
   maxhp=0;
     for(i=lasti;i<lasti+BarCount;i++)
     {
      cp=iClose(NULL, PERIOD_H1, x);
      op=iOpen(NULL, PERIOD_H1, x);
      hp=iHigh(NULL, PERIOD_H1, x);
      lp=iLow(NULL, PERIOD_H1, x);
        if (cp > op)
        {
         cl=DodgerBlue;
        }
         else if(cp < op)
        {
         cl=Red;
        }
         else
        {
         cl=Green;
        }
      DrawTl("tlWickH1"+(string)x, Time[i], Time[i], lp, hp, cl, 1);
      DrawTl("tlBodyH1"+(string)x, Time[i], Time[i], op, cp, cl, 3);
      HighPrice[i]=hp;
      LowPrice[i] =lp;
      if (hp>maxhp) maxhp=hp;
      Ema1[i]=iMA(NULL,PERIOD_H1,MA1H1_Period,0,MA1H1_Method,MA1H1_AppliedPrice,x);
      Ema2[i]=iMA(NULL,PERIOD_H1,MA2H1_Period,0,MA2H1_Method,MA2H1_AppliedPrice,x);
      Ema3[i]=iMA(NULL,PERIOD_H1,MA3H1_Period,0,MA3H1_Method,MA3H1_AppliedPrice,x);
      Ema4[i]=iMA(NULL,PERIOD_H1,MA4H1_Period,0,MA4H1_Method,MA4H1_AppliedPrice,x);
      x++;
     }
   if (BarCount!=0)
      drawText("TF H1", maxhp+(15*Point) , Silver, Time[i-1]);
   else
      if(ObjectFind("TF H1")!=-1) ObjectDelete("TF H1");
   lasti=i+1;
   x=0;
   BarCount=M30_HowManyBars;
   maxhp=0;
     for(i=lasti;i<lasti+BarCount;i++)
     {
      cp=iClose(NULL, PERIOD_M30, x);
      op=iOpen(NULL, PERIOD_M30, x);
      hp=iHigh(NULL, PERIOD_M30, x);
      lp=iLow(NULL, PERIOD_M30, x);
        if (cp > op)
        {
         cl=DodgerBlue;
        }
         else if(cp < op)
        {
         cl=Red;
        }
         else
        {
         cl=Green;
        }
      DrawTl("tlWickM30"+(string)x, Time[i], Time[i], lp, hp, cl, 1);
      DrawTl("tlBodyM30"+(string)x, Time[i], Time[i], op, cp, cl, 3);
      HighPrice[i]=hp;
      LowPrice[i] =lp;
      if (hp>maxhp) maxhp=hp;
      Ema1[i]=iMA(NULL,PERIOD_M30,MA1M30_Period,0,MA1M30_Method,MA1M30_AppliedPrice,x);
      Ema2[i]=iMA(NULL,PERIOD_M30,MA2M30_Period,0,MA2M30_Method,MA2M30_AppliedPrice,x);
      Ema3[i]=iMA(NULL,PERIOD_M30,MA3M30_Period,0,MA3M30_Method,MA3M30_AppliedPrice,x);
      Ema4[i]=iMA(NULL,PERIOD_M30,MA4M30_Period,0,MA4M30_Method,MA4M30_AppliedPrice,x);
      x++;
     }
   if (BarCount!=0)
      drawText("TF M30", maxhp+(15*Point)  ,Silver, Time[i-1]);
   else
      if(ObjectFind("TF M30")!=-1) ObjectDelete("TF M30");
   lasti=i+1;
   x=0;
   BarCount=M15_HowManyBars;
   maxhp=0;
     for(i=lasti;i<lasti+BarCount;i++)
     {
      cp=iClose(NULL, PERIOD_M15, x);
      op=iOpen(NULL, PERIOD_M15, x);
      hp=iHigh(NULL, PERIOD_M15, x);
      lp=iLow(NULL, PERIOD_M15, x);
        if (cp > op)
        {
         cl=Blue;
        }
         else if(cp < op)
        {
         cl=Red;
        }
         else
        {
         cl=Green;
        }
      DrawTl("tlWickM15"+(string)x, Time[i], Time[i], lp, hp, cl, 1);
      DrawTl("tlBodyM15"+(string)x, Time[i], Time[i], op, cp, cl, 3);
      HighPrice[i]=hp;
      LowPrice[i] =lp;
      if (hp>maxhp) maxhp=hp;
      Ema1[i]=iMA(NULL,PERIOD_M15,MA1M15_Period,0,MA1M15_Method,MA1M15_AppliedPrice,x);
      Ema2[i]=iMA(NULL,PERIOD_M15,MA2M15_Period,0,MA2M15_Method,MA2M15_AppliedPrice,x);
      Ema3[i]=iMA(NULL,PERIOD_M15,MA3M15_Period,0,MA3M15_Method,MA3M15_AppliedPrice,x);
      Ema4[i]=iMA(NULL,PERIOD_M15,MA4M15_Period,0,MA4M15_Method,MA4M15_AppliedPrice,x);
      x++;
     }
   if (BarCount!=0)
      drawText("TF M15",maxhp+(15*Point)  ,Silver, Time[i-1]);
   else
      if(ObjectFind("TF M15")!=-1) ObjectDelete("TF M15");
   lasti=i+1;
   x=0;
   BarCount=M5_HowManyBars;
   maxhp=0;
     for(i=lasti;i<lasti+BarCount;i++)
     {
      cp=iClose(NULL, PERIOD_M5, x);
      op=iOpen(NULL, PERIOD_M5, x);
      hp=iHigh(NULL, PERIOD_M5, x);
      lp=iLow(NULL, PERIOD_M5, x);
        if (cp > op)
        {
         cl=Blue;
        }
         else if(cp < op)
        {
         cl=Red;
        }
         else
        {
         cl=Green;
        }
      DrawTl("tlWickM5"+(string)x, Time[i], Time[i], lp, hp, cl, 1);
      DrawTl("tlBodyM5"+(string)x, Time[i], Time[i], op, cp, cl, 3);
      HighPrice[i]=hp;
      LowPrice[i] =lp;
      if (hp>maxhp) maxhp=hp;
      Ema1[i]=iMA(NULL,PERIOD_M5,MA1M5_Period,0,MA1M5_Method,MA1M5_AppliedPrice,x);
      Ema2[i]=iMA(NULL,PERIOD_M5,MA2M5_Period,0,MA2M5_Method,MA2M5_AppliedPrice,x);
      Ema3[i]=iMA(NULL,PERIOD_M5,MA3M5_Period,0,MA3M5_Method,MA3M5_AppliedPrice,x);
      Ema4[i]=iMA(NULL,PERIOD_M5,MA4M5_Period,0,MA4M5_Method,MA4M5_AppliedPrice,x);
      x++;
     }
   if (BarCount!=0)
      drawText("TF M5",maxhp+(15*Point) ,Silver, Time[i-1]);
   else
      if(ObjectFind("TF M5")!=-1) ObjectDelete("TF M5");
//----
   return(0);
  }
//+------------------------------------------------------------------+

void drawText(string name,double lvl,color Color, datetime  t)
  {
   //string text_name = StringConcatenate(name);
   if(ObjectFind(name)!=0)
     {
      ObjectCreate(name, OBJ_TEXT, WindowFind("MTF MA Viewer"), t, lvl);

     }
   ObjectSetText(name, name, 8, "Tahoma", EMPTY);
   ObjectSet(name, OBJPROP_COLOR, Color);
   ObjectMove(name, 0, t, lvl);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  void DrawTl(string n, datetime from, datetime to, double p1, double p2,color c, int w){

   //n=StringConcatenate("",n);

   if (ObjectFind(n)!=WindowFind("MTF MA Viewer"))
     {
      ObjectCreate(n, OBJ_TREND, WindowFind("MTF MA Viewer"), from, p1, to , p2);
      }else{
      ObjectMove(n, 0, from, p1);
      ObjectMove(n, 1, to, p2);
     }
   ObjectSet(n, OBJPROP_WIDTH, w);
   ObjectSet(n, OBJPROP_RAY, false);
   ObjectSet(n, OBJPROP_COLOR, c);
   ObjectSet(n, OBJPROP_BACK, true);
   WindowRedraw();
  }

//+------------------------------------------------------------------+