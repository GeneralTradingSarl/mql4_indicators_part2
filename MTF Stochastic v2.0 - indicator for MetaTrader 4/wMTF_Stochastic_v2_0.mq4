//+------------------------------------------------------------------+
//|                                               MTF Stochastic.mq4 |
//|													2007, Christof Risch (iya)	|
//| Stochastic indicator from any timeframe.									|
//+------------------------------------------------------------------+
#property link "http://www.forexfactory.com/showthread.php?t=30109"
#property indicator_separate_window
//----
#property indicator_buffers     4
#property indicator_color1      Red         // %K line
#property indicator_color2      CLR_NONE    // %D line
#property indicator_color3      LightPink   // %K line of the current candle
#property indicator_color4      CLR_NONE    // %D line of the current candle
#property indicator_maximum     100
#property indicator_minimum     0
//---- input parameters
extern string note1="Chart Time Frame";
extern string note2="0=current time frame";
extern string note3="1=M1, 5=M5, 15=M15, 30=M30";
extern string note4="60=H1, 240=H4, 1440=D1";
extern string note5="10080=W1, 43200=MN1";
extern int    TimeFrame=0;      // {1=M1, 5=M5, 15=M15, ..., 1440=D1, 10080=W1, 43200=MN1}
extern string note6="Stochastic1";
extern int    KPeriod=5,
DPeriod     =3,
Slowing     =3;
extern string note7="0=SMA, 1=EMA, 2=SMMA, 3=LWMA";
extern int    MAMethod=0;      // {0=SMA, 1=EMA, 2=SMMA, 3=LWMA}
extern string note8="0=Hi/Low, 1=Close/Close";
extern int    PriceField     =0;      // {0=Hi/Low, 1=Close/Close}
extern bool   ShowClock      =true;   // display time to candle close countdown
extern bool   ShowStochInfo  =true;
extern color  ClockColor     =Red;
extern string ClockFont      ="Arial";
extern int    ClockSize      =8;
//---- indicator buffers
double      BufferK[],
BufferD[],
BufferK_Curr[],
BufferD_Curr[];
//----
string   IndicatorName="",IndicatorName2="",StochName="",
TimeLabelName="";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- name for DataWindow and indicator subwindow label
   switch(TimeFrame)
     {
      case 1:      IndicatorName2="M1";   break;
      case 5:      IndicatorName2="M5"; break;
      case 10:      IndicatorName2="M10"; break;
      case 15:      IndicatorName2="M15"; break;
      case 30:      IndicatorName2="M30"; break;
      case 60:      IndicatorName2="H1"; break;
      case 120:   IndicatorName2="H2"; break;
      case 240:   IndicatorName2="H4"; break;
      case 480:   IndicatorName2="H8"; break;
      case 1440:   IndicatorName2="D1"; break;
      case 10080:   IndicatorName2="W1"; break;
      case 43200:   IndicatorName2="MN1"; break;
      default:     {TimeFrame=Period(); init(); return(0);}
     }
   StochName=" Stoch("+KPeriod+","+DPeriod+","+Slowing+")";
   IndicatorName=IndicatorName2+StochName;
   IndicatorShortName(IndicatorName);
   IndicatorDigits(1);
//---- indicator lines
   SetIndexBuffer(0,BufferK);
   SetIndexBuffer(1,BufferD);
   SetIndexBuffer(2,BufferK_Curr);
   SetIndexBuffer(3,BufferD_Curr);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexLabel(0,IndicatorName+" %K line");
   SetIndexLabel(1,IndicatorName+" %D Signal");
   SetIndexLabel(2,IndicatorName+" %K current candle");
   SetIndexLabel(3,IndicatorName+" %D current candle");
  }
//+------------------------------------------------------------------+
int deinit()
  {
   if(TimeLabelName!="")
      if(ObjectFind(TimeLabelName)!=-1)
         ObjectDelete(TimeLabelName);
  }
//+------------------------------------------------------------------+
//| MTF Stochastic                                                   |
//+------------------------------------------------------------------+
int start()
  {
//----
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0)
     {
      limit-=1+1;
      ArrayInitialize(BufferK_Curr,EMPTY_VALUE);
      ArrayInitialize(BufferD_Curr,EMPTY_VALUE);
      if(TimeLabelName!="")
         if(ObjectFind(TimeLabelName)!=-1) ObjectDelete(TimeLabelName);
     }

   int start1=limit;
//----
//	3... 2... 1... GO!
   for(int i=start1; i>=0; i--)
     {
      int shift1=i;
      //----
      if(TimeFrame<Period()) shift1=iBarShift(NULL,TimeFrame,Time[i]);
      //----
      int time1=iTime(NULL,TimeFrame,shift1),
      shift2=iBarShift(NULL,0,time1);
      double stochK,stochD;
      if((TimeFrame!=10) && (TimeFrame!=120) && (TimeFrame!=480))
        {
         stochK=iStochastic(NULL,TimeFrame,KPeriod,DPeriod,Slowing,MAMethod,PriceField,0,shift1);
         stochD=iStochastic(NULL,TimeFrame,KPeriod,DPeriod,Slowing,MAMethod,PriceField,1,shift1);
        }
      else
        {
         switch(TimeFrame)
           {
            case 10:
              {
               stochK=2*iStochastic(NULL,5,KPeriod,DPeriod,Slowing,MAMethod,PriceField,0,shift1);
               stochD=2*iStochastic(NULL,5,KPeriod,DPeriod,Slowing,MAMethod,PriceField,1,shift1);
               break;
              }
            case 120:
              {
               stochK=2*iStochastic(NULL,60,KPeriod,DPeriod,Slowing,MAMethod,PriceField,0,shift1);
               stochD=2*iStochastic(NULL,60,KPeriod,DPeriod,Slowing,MAMethod,PriceField,1,shift1);
               break;
              }
            case 480:
              {
               stochK=2*iStochastic(NULL,240,KPeriod,DPeriod,Slowing,MAMethod,PriceField,0,shift1);
               stochD=2*iStochastic(NULL,240,KPeriod,DPeriod,Slowing,MAMethod,PriceField,1,shift1);
               break;
              }
           }
        }
      //	old (closed) candles
      if(shift1>=1)
        {
         BufferK[shift2]=stochK;
         BufferD[shift2]=stochD;
        }
      //----
      //	current candle
      if((TimeFrame>=Period() && shift1<=1)
         || (TimeFrame<Period() && (shift1==0 || shift2==1)))
        {
         BufferK_Curr[shift2]=stochK;
         BufferD_Curr[shift2]=stochD;
        }
      //----
      //	linear interpolatior for the number of intermediate bars, between two higher timeframe candles.
      int n=1;
      if(TimeFrame>Period())
        {
         if((TimeFrame!=10) && (TimeFrame!=120) && (TimeFrame!=480))
           {
            int shift2prev=iBarShift(NULL,0,iTime(NULL,TimeFrame,shift1+1));
           }
         else
           {
            switch(TimeFrame)
              {
               case 10:
                 {
                  shift2prev=2*iBarShift(NULL,0,iTime(NULL,5,shift1+1));
                  break;
                 }
               case 120:
                 {
                  shift2prev=2*iBarShift(NULL,0,iTime(NULL,60,shift1+1));
                  break;
                 }
               case 480:
                 {
                  shift2prev=2*iBarShift(NULL,0,iTime(NULL,240,shift1+1));
                  break;
                 }
              }
           }
         if(shift2prev!=-1 && shift2prev!=shift2)
            n=shift2prev-shift2;
        }
      //	apply interpolation
      double factor=1.0/n;
      if(shift1>=1)
         if(BufferK[shift2+n]!=EMPTY_VALUE && BufferK[shift2]!=EMPTY_VALUE)
           {
            for(int k=1; k<n; k++)
              {
               BufferK[shift2+k]=k*factor*BufferK[shift2+n] + (1.0-k*factor)*BufferK[shift2];
               BufferD[shift2+k]=k*factor*BufferD[shift2+n] + (1.0-k*factor)*BufferD[shift2];
              }
           }
      //	current candle
      if(shift1==0)
         if(BufferK_Curr[shift2+n]!=EMPTY_VALUE && BufferK_Curr[shift2]!=EMPTY_VALUE)
           {
            for(k=1; k<n; k++)
              {
               BufferK_Curr[shift2+k]=k*factor*BufferK_Curr[shift2+n] + (1.0-k*factor)*BufferK_Curr[shift2];
               BufferD_Curr[shift2+k]=k*factor*BufferD_Curr[shift2+n] + (1.0-k*factor)*BufferD_Curr[shift2];
              }
            //	candle time countdown
            if(ShowClock)
              {
               int m,s;
               //----
               s=iTime(NULL,TimeFrame,0)+TimeFrame*60 - TimeCurrent();
               m=(s-s%60)/60;
               s=s%60;
               //----
               string text;
               if(s<10) text="0"+s;
               else      text=""+s;
               if(ShowStochInfo)
                  text="                "+IndicatorName2+StochName+" - "+m+":"+text;
               else
                  text="                "+IndicatorName2+" - "+m+":"+text;
               int window=WindowFind(IndicatorName);
               if(window==-1)
                  window=WindowOnDropped();
               TimeLabelName=IndicatorName+" Time Counter "+window;
               if(ObjectFind(TimeLabelName)==-1)
                  ObjectCreate(TimeLabelName,OBJ_TEXT,window,Time[shift2],BufferK_Curr[shift2]+3);
               else
                  ObjectMove(TimeLabelName,0,Time[shift2],BufferK_Curr[shift2]+3);

               ObjectSetText(TimeLabelName,text,ClockSize,ClockFont,ClockColor);
              }
            else if(ShowStochInfo)
              {
               text="                "+IndicatorName2+StochName+text;
               window=WindowFind(IndicatorName);
               if(window==-1)
                  window=WindowOnDropped();
               //----
               TimeLabelName=IndicatorName+" Time Counter "+window;
               if(ObjectFind(TimeLabelName)==-1)
                  ObjectCreate(TimeLabelName,OBJ_TEXT,window,Time[shift2],BufferK_Curr[shift2]+3);
               else
                  ObjectMove(TimeLabelName,0,Time[shift2],BufferK_Curr[shift2]+3);
               ObjectSetText(TimeLabelName,text,ClockSize,ClockFont,ClockColor);
              }
           }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
