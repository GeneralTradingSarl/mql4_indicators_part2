//+------------------------------------------------------------------+
//|                                           MTF Stochastic_SmL.mq4 |
//|			                 smooz line	2007, Christof Risch (iya)	|
//|                          Stochastic indicator from any timeframe |
//+------------------------------------------------------------------+
#property link "http://www.forexfactory.com/showthread.php?t=30109"
#property indicator_separate_window
//----
#property indicator_buffers   2
#property indicator_color1    LightSeaGreen
#property indicator_color2    Red
#property indicator_level1    80
#property indicator_level2    20
#property indicator_maximum   100
#property indicator_minimum   0
//---- input parameters
extern int  TimeFrame   =0,
            KPeriod     =5,
            DPeriod     =3,
            Slowing     =3,
            MAMethod    =0,
            PriceField  =0;
//---- indicator buffers
double      Buffer1[],
            Buffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator lines
   SetIndexBuffer(0,Buffer1);
   SetIndexBuffer(1,Buffer2);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
//---- name for DataWindow and indicator subwindow label
   string TimeFrameStr;
   switch(TimeFrame)
     {
      case 1:      TimeFrameStr="Period M1";  break;
      case 5:      TimeFrameStr="Period M5";  break;
      case 15:     TimeFrameStr="Period M15"; break;
      case 30:     TimeFrameStr="Period M30"; break;
      case 60:     TimeFrameStr="Period H1";  break;
      case 240:    TimeFrameStr="Period H4";  break;
      case 1440:   TimeFrameStr="Period D1";  break;
      case 10080:  TimeFrameStr="Period W1";  break;
      case 43200:  TimeFrameStr="Period MN1"; break;
      default:     TimeFrameStr="Current Timeframe";
     }
   IndicatorShortName(TimeFrameStr+" Stoch("+KPeriod+","+DPeriod+","+Slowing+")");
  }
//+------------------------------------------------------------------+
//| MTF Stochastic                                                   |
//+------------------------------------------------------------------+
int start()
  {
   for(int i=Bars-1-IndicatorCounted(); i>=0; i--)
     {
      int shift1=iBarShift(NULL,TimeFrame,Time[i]),
      time1 =iTime    (NULL,TimeFrame,shift1),
      shift2=iBarShift(NULL,0,time1);
//----
      Buffer1[shift2]=iStochastic(NULL,TimeFrame,KPeriod,DPeriod,Slowing,MAMethod,PriceField,0,shift1);
      Buffer2[shift2]=iStochastic(NULL,TimeFrame,KPeriod,DPeriod,Slowing,MAMethod,PriceField,1,shift1);
      //----
      //	linear interpolation for indicators from a higher timeframe
      if(TimeFrame<=Period())
         continue;
      //----
      //	current candle
      if(shift1==0)
         for(int n=1; shift2-n>=0; n++)
           {
            Buffer1[shift2-n]=Buffer1[shift2];
            Buffer2[shift2-n]=Buffer2[shift2];
           }
      //	count number of intermediate bars
      for(n=1; shift2+n < Bars && Time[shift2+n] > iTime(NULL,TimeFrame,iBarShift(NULL,TimeFrame,Time[shift2+n],true)); n++)
         continue;
      //----
      //	apply interpolation
      double factor=1.0/n;
      for(int k=1; k < n; k++)
        {
         Buffer1[shift2+k]=k*factor*Buffer1[shift2+n] + (1.0-k*factor)*Buffer1[shift2];
         Buffer2[shift2+k]=k*factor*Buffer2[shift2+n] + (1.0-k*factor)*Buffer2[shift2];
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+