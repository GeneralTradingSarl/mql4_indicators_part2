//+------------------------------------------------------------------+
//|                                           OscillatorsOnChart.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 10

#property indicator_color1  clrAqua
#property indicator_color2  clrMagenta
#property indicator_color3  clrAqua
#property indicator_color4  clrMagenta
#property indicator_color5  clrMagenta
#property indicator_color6  clrAqua
#property indicator_color7  clrMagenta
#property indicator_color8  clrFireBrick
#property indicator_color9  clrYellow
#property indicator_color10 clrRoyalBlue

#property indicator_style1  STYLE_SOLID
#property indicator_style2  STYLE_DOT
#property indicator_style3  STYLE_DOT
#property indicator_style4  STYLE_DOT
#property indicator_style5  STYLE_DOT
#property indicator_style6  STYLE_DOT
#property indicator_style7  STYLE_DOT
#property indicator_style8  STYLE_SOLID
#property indicator_style9  STYLE_SOLID
#property indicator_style10 STYLE_SOLID

#property indicator_width1  2
#property indicator_width8  2
#property indicator_width9  2
#property indicator_width10 2

#define        LEVELS           7

#define        sRSI             "RSI " 
#define        sCCI             "CCI " 
#define        sPRI             "PRI " 

#define        ALRT_BUY         " up"
#define        ALRT_SELL        " down"

#define        OP_NONE          -1

#define        HIGH_LOW         0
#define        CLOSE_CLOSE      1
#define        HIGH_LOW_CLOSE   2

#define        MODE_MEDIAN      1
#define        MODE_RANGE       2
//---- input parameters
input bool     ShowRSI        = true;
input int      iRSIPeriod     = 14;
input string   _              = "0=Close 4=Median 5=Typical 6=Weighted";
input int      iRSIPrice      = PRICE_CLOSE;

input bool     ShowCCI        = true;
input int      iCCIPeriod     = 14;
input string   __             = "0=Close 4=Median 5=Typical 6=Weighted";
input int      iCCIPrice      = PRICE_CLOSE;

input bool     ShowPRI        = true;
input int      iPRIPeriod     = 14;
input string   ___            = "0=Close 4=Median 5=Typical 6=Weighted";
input int      iPRIPrice      = PRICE_CLOSE;
input int      TimeFrame      = 0;

input int      iRangePeriod   = 50;
input string   ____           = "0=High/Low 1=Close/Close 2=High/Low/Close";
input int      RangeMode      = HIGH_LOW;

input bool     AverageMedian  = false;
input string   _____          = "0=SMA 1=EMA 2=SMMA 3=LWMA";
input int      MAMode         = MODE_SMA;
input string   ______         = "0=Close 4=Median 5=Typical 6=Weighted";
input int      MAPrice        = PRICE_MEDIAN;

input bool     AlertsOn       = true,
               AlertsMessage  = true,
               AlertsEmail    = false,
               AlertsSound    = false;
//---- buffers
double         Level_0[],
               Level_1[],
               Level_2[],
               Level_3[],
               Level_4[],
               Level_5[],
               Level_6[];

double         RSI_Buffer[];
double         CCI_Buffer[];
double         PRI_Buffer[];
//---- levels
double         Level[LEVELS] = {-0.50,-0.26,-0.12, 0.0, 0.12, 0.26, 0.50};

int            p_digits;
//double         p_point;

int            BarsWindow;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set points & digits
   if(Digits==2 || Digits==3) p_digits = 2;
   else                       p_digits = 4;
   if(Symbol() == "XAUUSD")   p_digits = 1;
   if(Symbol() == "XAGUSD")   p_digits = 3;
   //if(Digits==2 || Digits==4)       p_point=Point;
   //else                             p_point=Point*10;
   IndicatorDigits(p_digits);
   BarsWindow=WindowBarsPerChart()+iRangePeriod;
//---- indicator buffer mapping
   SetIndexBuffer(0,Level_0);
   SetIndexBuffer(1,Level_1);
   SetIndexBuffer(2,Level_2);
   SetIndexBuffer(3,Level_3);
   SetIndexBuffer(4,Level_4);
   SetIndexBuffer(5,Level_5);
   SetIndexBuffer(6,Level_6);
//---- indicator properties
   SetIndexStyle(0,DRAW_LINE,indicator_style1,indicator_width1);
   SetIndexStyle(1,DRAW_LINE,indicator_style2);
   SetIndexStyle(2,DRAW_LINE,indicator_style3);
   SetIndexStyle(3,DRAW_LINE,indicator_style4);
   SetIndexStyle(4,DRAW_LINE,indicator_style5);
   SetIndexStyle(5,DRAW_LINE,indicator_style6);
   SetIndexStyle(6,DRAW_LINE,indicator_style7);
//---- name for DataWindow and indicator subwindow label
   string ShortName;
   ShortName="OscillatorsOnChart("+IntegerToString(iRangePeriod)+")";
   IndicatorShortName(ShortName);
   SetIndexLabel(0," "+(string)(Level[3]*100+50)+"% ");
   SetIndexLabel(1," "+(string)(Level[4]*100+50)+"% ");
   SetIndexLabel(2," "+(string)(Level[5]*100+50)+"% ");
   SetIndexLabel(3," "+(string)(Level[6]*100+50)+"% ");
   SetIndexLabel(4," "+(string)(Level[2]*100+50)+"% ");
   SetIndexLabel(5," "+(string)(Level[1]*100+50)+"% ");
   SetIndexLabel(6," "+(string)(Level[0]*100+50)+"% ");
//---- first values aren't drawn
   SetIndexDrawBegin(0,Bars-BarsWindow);
   SetIndexDrawBegin(1,Bars-BarsWindow);
   SetIndexDrawBegin(2,Bars-BarsWindow);
   SetIndexDrawBegin(3,Bars-BarsWindow);
   SetIndexDrawBegin(4,Bars-BarsWindow);
   SetIndexDrawBegin(5,Bars-BarsWindow);
   SetIndexDrawBegin(6,Bars-BarsWindow);

   int xStart=6;
   int yStart=70;
   int yIncrement=14;

   if(ShowRSI)
     {
      SetIndexBuffer(7,RSI_Buffer);
      SetIndexStyle(7,DRAW_LINE,indicator_style8,indicator_width8);
      SetIndexLabel(7,sRSI);
      SetIndexDrawBegin(7,Bars-BarsWindow);
      CreateLabel(sRSI+"("+IntegerToString(iRSIPeriod)+")",0,xStart,yStart,indicator_color8);
      yStart += yIncrement;
     }
   if(ShowCCI)
     {
      SetIndexBuffer(8,CCI_Buffer);
      SetIndexStyle(8,DRAW_LINE,indicator_style9,indicator_width9);
      SetIndexLabel(8,sCCI);
      SetIndexDrawBegin(8,Bars-BarsWindow);
      CreateLabel(sCCI+"("+IntegerToString(iCCIPeriod)+")",0,xStart,yStart,indicator_color9);
      yStart += yIncrement;
     }
   if(ShowPRI)
     {
      SetIndexBuffer(9,PRI_Buffer);
      SetIndexStyle(9,DRAW_LINE,indicator_style10,indicator_width10);
      SetIndexLabel(9,sPRI);
      SetIndexDrawBegin(9,Bars-BarsWindow);
      CreateLabel(sPRI+"("+IntegerToString(iPRIPeriod)+")",0,xStart,yStart,indicator_color10);
     }
//----
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---- check & delete labels
   if(ObjectFind(0,sRSI+"("+IntegerToString(iRSIPeriod)+")")!=-1) 
      ObjectDelete(0,sRSI+"("+IntegerToString(iRSIPeriod)+")");
   if(ObjectFind(0,sCCI+"("+IntegerToString(iCCIPeriod)+")")!=-1) 
      ObjectDelete(0,sCCI+"("+IntegerToString(iCCIPeriod)+")");
   if(ObjectFind(0,sPRI+"("+IntegerToString(iPRIPeriod)+")")!=-1) 
      ObjectDelete(0,sPRI+"("+IntegerToString(iPRIPeriod)+")");
   return;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   int tick=TickIn(close[0]);
   if(Bars<BarsWindow)   return(rates_total);
   if(prev_calculated>0 && tick==OP_NONE)   return(rates_total); //---skip useless ticks
   bool newbar = NewBar(time[0]);
   int i,limit;
   static double dMedian,
                 dRange;
//----
   limit = (rates_total-prev_calculated);
   if(prev_calculated==0) limit = BarsWindow;
   if(prev_calculated>0 && newbar) limit = 1;
//----
   for(i=limit;i>=0;i--)
     {
      int shift=iBarShift(NULL,TimeFrame,time[i]);
      if(prev_calculated==0 || newbar)
        {
         if(!AverageMedian)
            dMedian=Range(MODE_MEDIAN,TimeFrame,iRangePeriod,shift);
         else
            dMedian=iMA(NULL,TimeFrame,iRangePeriod,0,MAMode,MAPrice,shift+1);
         dRange=Range(MODE_RANGE,TimeFrame,iRangePeriod,shift);

         Level_0[i] = dMedian;
         Level_1[i] = dMedian + (dRange * Level[4]);
         Level_2[i] = dMedian + (dRange * Level[5]);
         Level_3[i] = dMedian + (dRange * Level[6]);
         Level_4[i] = dMedian + (dRange * Level[2]);
         Level_5[i] = dMedian + (dRange * Level[1]);
         Level_6[i] = dMedian + (dRange * Level[0]);
        }
      if(ShowRSI)
        {
         RSI_Buffer[i] = RSI(TimeFrame,iRSIPeriod,iRSIPrice,shift);
         RSI_Buffer[i] *= dRange;
         RSI_Buffer[i] += dMedian;
         if(AlertsOn && prev_calculated>0)
           {
            if(tick==OP_BUY)
              {
               if(RSI_Buffer[0] > Level_0[0] && 
                  RSI_Buffer[1] <=Level_0[1])    
                     AlertsHandle(sRSI,Level[3],ALRT_BUY,close[0]);
               if(RSI_Buffer[0] > Level_1[0] && 
                  RSI_Buffer[1] <=Level_1[1])    
                     AlertsHandle(sRSI,Level[4],ALRT_BUY,close[0]);
               if(RSI_Buffer[0] > Level_2[0] && 
                  RSI_Buffer[1] <=Level_2[1])    
                     AlertsHandle(sRSI,Level[5],ALRT_BUY,close[0]);
               if(RSI_Buffer[0] > Level_4[0] && 
                  RSI_Buffer[1] <=Level_4[1])    
                     AlertsHandle(sRSI,Level[2],ALRT_BUY,close[0]);
               if(RSI_Buffer[0] > Level_5[0] && 
                  RSI_Buffer[1] <=Level_5[1])
                     AlertsHandle(sRSI,Level[3],ALRT_BUY,close[0]);
              }
            if(tick==OP_SELL)
              {
               if(RSI_Buffer[0] < Level_0[0] && 
                  RSI_Buffer[1] >=Level_0[1])
                     AlertsHandle(sRSI,Level[3],ALRT_SELL,close[0]);
               if(RSI_Buffer[0] < Level_1[0] && 
                  RSI_Buffer[1] >=Level_1[1])
                     AlertsHandle(sRSI,Level[4],ALRT_SELL,close[0]);
               if(RSI_Buffer[0] < Level_2[0] && 
                  RSI_Buffer[1] >=Level_2[1])
                     AlertsHandle(sRSI,Level[5],ALRT_SELL,close[0]);
               if(RSI_Buffer[0] < Level_4[0] && 
                  RSI_Buffer[1] >=Level_4[1])
                     AlertsHandle(sRSI,Level[2],ALRT_SELL,close[0]);
               if(RSI_Buffer[0] < Level_5[0] && 
                  RSI_Buffer[1] >=Level_5[1])
                     AlertsHandle(sRSI,Level[3],ALRT_SELL,close[0]);
              }
           }
        }
      if(ShowCCI)
        {
         CCI_Buffer[i] = CCI(TimeFrame,iCCIPeriod,iCCIPrice,shift);
         CCI_Buffer[i] *= dRange;
         CCI_Buffer[i] += dMedian;
         if(AlertsOn && prev_calculated>0)
           {
            if(tick==OP_BUY)
              {
               if(CCI_Buffer[0] > Level_0[0] && 
                  CCI_Buffer[1] <=Level_0[1])
                     AlertsHandle(sCCI,Level[3],ALRT_BUY,close[0]);
               if(CCI_Buffer[0] > Level_1[0] && 
                  CCI_Buffer[1] <=Level_1[1])
                     AlertsHandle(sCCI,Level[4],ALRT_BUY,close[0]);
               if(CCI_Buffer[0] > Level_2[0] && 
                  CCI_Buffer[1] <=Level_2[1])
                     AlertsHandle(sCCI,Level[5],ALRT_BUY,close[0]);
               if(CCI_Buffer[0] > Level_4[0] && 
                  CCI_Buffer[1] <=Level_4[1])
                     AlertsHandle(sCCI,Level[2],ALRT_BUY,close[0]);
               if(CCI_Buffer[0] > Level_5[0] && 
                  CCI_Buffer[1] <=Level_5[1])
                     AlertsHandle(sCCI,Level[3],ALRT_BUY,close[0]);
              }
            if(tick==OP_SELL)
              {
               if(CCI_Buffer[0] < Level_0[0] && 
                  CCI_Buffer[1] >=Level_0[1])
                     AlertsHandle(sCCI,Level[3],ALRT_SELL,close[0]);
               if(CCI_Buffer[0] < Level_1[0] && 
                  CCI_Buffer[1] >=Level_1[1])
                     AlertsHandle(sCCI,Level[4],ALRT_SELL,close[0]);
               if(CCI_Buffer[0] < Level_2[0] && 
                  CCI_Buffer[1] >=Level_2[1])
                     AlertsHandle(sCCI,Level[5],ALRT_SELL,close[0]);
               if(CCI_Buffer[0] < Level_4[0] && 
                  CCI_Buffer[1] >=Level_4[1])
                     AlertsHandle(sCCI,Level[2],ALRT_SELL,close[0]);
               if(CCI_Buffer[0] < Level_5[0] && 
                  CCI_Buffer[1] >=Level_5[1])
                     AlertsHandle(sCCI,Level[3],ALRT_SELL,close[0]);
              }
           }
        }
      if(ShowPRI)
        {
         PRI_Buffer[i] = PRI(TimeFrame,iPRIPeriod,iPRIPrice,shift);
         PRI_Buffer[i] *= dRange;
         PRI_Buffer[i] += dMedian;
         if(AlertsOn && prev_calculated>0)
           {
            if(tick==OP_BUY)
              {
               if(PRI_Buffer[0] > Level_0[0] && 
                  PRI_Buffer[1] <=Level_0[1])
                     AlertsHandle(sPRI,Level[3],ALRT_BUY,close[0]);
               if(PRI_Buffer[0] > Level_1[0] && 
                  PRI_Buffer[1] <=Level_1[1])
                     AlertsHandle(sPRI,Level[4],ALRT_BUY,close[0]);
               if(PRI_Buffer[0] > Level_2[0] && 
                  PRI_Buffer[1] <=Level_2[1])
                     AlertsHandle(sPRI,Level[5],ALRT_BUY,close[0]);
               if(PRI_Buffer[0] > Level_4[0] && 
                  PRI_Buffer[1] <=Level_4[1])
                     AlertsHandle(sPRI,Level[2],ALRT_BUY,close[0]);
               if(PRI_Buffer[0] > Level_5[0] && 
                  PRI_Buffer[1] <=Level_5[1])
                     AlertsHandle(sPRI,Level[3],ALRT_BUY,close[0]);
              }
            if(tick==OP_SELL)
              {
               if(PRI_Buffer[0] < Level_0[0] && 
                  PRI_Buffer[1] >=Level_0[1])
                     AlertsHandle(sPRI,Level[3],ALRT_SELL,close[0]);
               if(PRI_Buffer[0] < Level_1[0] && 
                  PRI_Buffer[1] >=Level_1[1])
                     AlertsHandle(sPRI,Level[4],ALRT_SELL,close[0]);
               if(PRI_Buffer[0] < Level_2[0] && 
                  PRI_Buffer[1] >=Level_2[1])
                     AlertsHandle(sPRI,Level[5],ALRT_SELL,close[0]);
               if(PRI_Buffer[0] < Level_4[0] && 
                  PRI_Buffer[1] >=Level_4[1])
                     AlertsHandle(sPRI,Level[2],ALRT_SELL,close[0]);
               if(PRI_Buffer[0] < Level_5[0] && 
                  PRI_Buffer[1] >=Level_5[1])
                     AlertsHandle(sPRI,Level[3],ALRT_SELL,close[0]);
              }
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateLabel(string oscillator,int window,int x,int y,int clr)
  {
   int label=ObjectCreate(oscillator,OBJ_LABEL,window,0,0);
   ObjectSetText(oscillator,oscillator,10,"Arial Bold");
   ObjectSet(oscillator,OBJPROP_COLOR,clr);
   ObjectSet(oscillator,OBJPROP_XDISTANCE,x);
   ObjectSet(oscillator,OBJPROP_YDISTANCE,y);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar(datetime time)
  {
   static datetime   time_prev=0;
   if(time_prev!=time)
     {
      time_prev=time;
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TickIn(double price)
  {
   int tick_in=OP_NONE;
   static double tick_price[3];
   tick_price[2] = tick_price[1];
   tick_price[1] = tick_price[0];
   tick_price[0] = NormalizeDouble(price,p_digits);

   if(tick_price[0] > tick_price[2]) tick_in = OP_BUY;
   if(tick_price[0] < tick_price[2]) tick_in = OP_SELL;

   return(tick_in);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RSI(int timeframe,int period,int price,int idx)
  {
   double RSI;
   RSI = iRSI(NULL,timeframe,period,price,idx);
   RSI -= 50;
   RSI /= 100;
   return(RSI);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CCI(int timeframe,int period,int price,int idx)
  {
   double CCI;
   double Mul=0.015/period;
   CCI = iCCI(NULL,timeframe,period,price,idx);
   CCI *= Mul;
   return(CCI);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PRI(int timeframe,int period,int price,int idx)
  {
   double PRI;
   double Price;
   double MaxHigh;
   double MinLow;
   double PRIRange;

   MaxHigh = iHigh(NULL,timeframe,
             iHighest(NULL,timeframe,MODE_HIGH,period,idx));
   MinLow = iLow(NULL,timeframe,
            iLowest(NULL,timeframe,MODE_LOW,period,idx));

   PRIRange = MaxHigh-MinLow;

   switch(price)
     {
      case PRICE_CLOSE:    Price =  iClose(NULL,timeframe,idx); break;
      case PRICE_HIGH:     Price =  iHigh(NULL,timeframe,idx); break;
      case PRICE_LOW:      Price =  iLow(NULL,timeframe,idx); break;
      case PRICE_MEDIAN:   Price = (iHigh(NULL,timeframe,idx)+
                                    iLow(NULL,timeframe,idx))/2; break;
      case PRICE_TYPICAL:  Price = (iHigh(NULL,timeframe,idx)+
                                    iLow(NULL,timeframe,idx)+
                                    iClose(NULL,timeframe,idx))/3; break;
      case PRICE_WEIGHTED: Price = (iHigh(NULL,timeframe,idx)+
                                    iLow(NULL,timeframe,idx)+
                                    iClose(NULL,timeframe,idx)+
                                    iClose(NULL,timeframe,idx))/4; break;
      default:             Price =  iClose(NULL,timeframe,idx); break;
     }
   
   if(NormalizeDouble(PRIRange,Digits)!=0.0)
     {
      PRI = (Price-MinLow) / PRIRange;
      PRI -= 0.50;
     }
   else PRI = 0.0;
   //if(PRI >  0.50)   PRI =  0.50;
   //if(PRI < -0.50)   PRI = -0.50;
   return(PRI);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Range(int mode,int timeframe,int period,int idx)
  {
   double   MaxHigh=0,
            MinLow=0,
            Range;
   double   HighHigh,
            HighClose,
            HighLow;
   double   LowHigh,
            LowClose,
            LowLow;

   switch(RangeMode)
     {
      case HIGH_LOW:
        {
         MaxHigh = iHigh(NULL,timeframe,
                   iHighest(NULL,timeframe,MODE_HIGH,period-1,idx+1));
         MinLow = iLow(NULL,timeframe,
                  iLowest(NULL,timeframe,MODE_LOW,period-1,idx+1));
         break;
        }
      case CLOSE_CLOSE:
        {
         MaxHigh = iClose(NULL,timeframe,
                   iHighest(NULL,timeframe,MODE_CLOSE,period-1,idx+1));
         MinLow = iClose(NULL,timeframe,
                  iLowest(NULL,timeframe,MODE_CLOSE,period-1,idx+1));
         break;
        }
      case HIGH_LOW_CLOSE:
        {
         HighHigh = iHigh(NULL,timeframe,
                    iHighest(NULL,timeframe,MODE_HIGH,period-1,idx+1));
         HighLow = iLow(NULL,timeframe,
                   iHighest(NULL,timeframe,MODE_LOW,period-1,idx+1));
         HighClose = iClose(NULL,timeframe,
                     iHighest(NULL,timeframe,MODE_CLOSE,period-1,idx+1));
         LowHigh = iHigh(NULL,timeframe,
                   iLowest(NULL,timeframe,MODE_HIGH,period-1,idx+1));
         LowLow = iLow(NULL,timeframe,
                  iLowest(NULL,timeframe,MODE_LOW,period-1,idx+1));
         LowClose = iClose(NULL,timeframe,
                    iLowest(NULL,timeframe,MODE_CLOSE,period-1,idx+1));
         MaxHigh = (HighHigh+HighLow+HighClose)/3;
         MinLow = (LowHigh+LowLow+LowClose)/3;
         break;
        }
     }

   if(mode==MODE_MEDIAN) Range = (MaxHigh+MinLow)/2;
   else                  Range = (MaxHigh-MinLow);
   return(Range);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AlertsHandle(string oscillator,double level,string alert_type,double price)
  {
   static datetime time_prev;
   static string type_prev;
   string alert_Message;

   if(time_prev != iTime(NULL,TimeFrame,0) /*|| osc_prev != oscillator*/ || type_prev != alert_type)
     {
      time_prev = iTime(NULL,TimeFrame,0);
      //osc_prev = oscillator;
      type_prev = alert_type;
      alert_Message = StringConcatenate(Symbol()," @ ",TimeToStr(TimeLocal(),TIME_SECONDS),
                                          " ",oscillator,"crossed ",level*100+50,"% level",
                                          alert_type," @ ",NormalizeDouble(price,p_digits));
      if(AlertsMessage) Alert(alert_Message);
      if(AlertsEmail)   SendMail(StringConcatenate(Symbol(),"OscOnChart Alert "),alert_Message);
      if(AlertsSound)   PlaySound("alert2.wav");
     }
  }
//+------------------------------------------------------------------+
