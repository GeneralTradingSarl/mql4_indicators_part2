//+------------------------------------------------------------------+
//|                                        Brooky_Strength_Rev_1.mq4 |
//|                                          Copyright © 2010,Brooky |
//|                               http://forex-indicators.weebly.com |
//|                     Modified by Pat1 forexfactory.pat1@gmail.com |    
//+------------------------------------------------------------------+

#property copyright "Copyright © 2010,Brooky"
#property link      "http://forex-indicators.weebly.com"

#define Major 1
#define Minor -1
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 C'47,47,47'
#property indicator_color2 DodgerBlue
#property indicator_width1 1
#property indicator_width2 2
#property indicator_level1 8
#property indicator_level2 0
#property indicator_level3 -8

#property indicator_levelcolor Yellow
#property indicator_levelstyle STYLE_DOT
#property indicator_maximum 10.5
#property indicator_minimum -10.5

extern string Author_Site = "Forex-Indicators.weebly.com";
extern string Pair1 = "USDCHF";
extern string Pair2 = "USDJPY";
extern string Pair3 = "USDCAD";
extern string Pair4 = "AUDUSD";
extern string Pair5 = "EURUSD";
extern string Pair6 = "GBPUSD";
extern string Pair7 = "NZDUSD";


extern string Checking_MAs = "Fast v Slow Checks";
extern int slow_check_ma = 55;
extern int fast_check_ma = 34;
extern string Data_Smoothie = "Smoothing Line";
extern int sig_smooth = 15;
extern string Checking_TF = "Timeframe 0 is current";
extern int check_tf = 0;
string Pairs[7];
int PairType[7];
//---- buffers
double data_buffer[];
double sig_buffer[];
int i;
double multiplier = -1.4285714285714285714285714285714;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   Pairs[0]=Pair1;
   Pairs[1]=Pair2;
   Pairs[2]=Pair3;
   Pairs[3]=Pair4;
   Pairs[4]=Pair5;
   Pairs[5]=Pair6;
   Pairs[6]=Pair7;


   string a =StringSubstr(Pairs[0],0,3);
   string b =StringSubstr(Pairs[0],3,3);
   string a1=StringSubstr(Pairs[1],0,3);
   string b1=StringSubstr(Pairs[1],3,3);
   
   if(a==a1 || a==b1)string MainCurrency=a; else MainCurrency=b;
   for(int j=0;j<7;j++)
   {
         if(StringSubstr(Pairs[j],0,3)==MainCurrency){PairType[j]=Major;Print(Pairs[j],"  1");}
    else if(StringSubstr(Pairs[j],3,3)==MainCurrency){PairType[j]=Minor;Print(Pairs[j]," -1");}
    else 
    {string com=StringConcatenate("This Currency ",Pairs[j]," is not a part of the Main Currency ",MainCurrency," group - Indicator aborted");
    Print(com);
    Comment(com);
    return(0);}
   }
   

   SetIndexBuffer(0,data_buffer);SetIndexStyle(0,DRAW_LINE);
   
   SetIndexStyle(1,DRAW_LINE);SetIndexBuffer(1,sig_buffer);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("forex-indicators.weebly.com "
                       +"("+MainCurrency+" Strength Effect)"
                        );   

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
   int start()
   {
      int limit;
      int counted_bars=IndicatorCounted();
      //---- check for possible errors
      if(counted_bars<0) return(-1);
      //---- the last counted bar will be recounted
      if(counted_bars>0) counted_bars--;
      limit=Bars-counted_bars;
      //---- main loop
      for( i=0; i<limit; i++)
      {
         
         int c=0; 
         for(int j=0;j<7;j++)c+=get_c(j);
         data_buffer[i]=c*multiplier;
      }
      for(i=0; i<limit; i++)
      {
      sig_buffer[i]=iMAOnArray(data_buffer,0,sig_smooth,0,MODE_LWMA,i);
      Comment("Level ("+DoubleToStr(sig_buffer[i],1)+")");
      }
      //---- done
      return(0);
   }
//+------------------------------------------------------------------+

double get_c(int j)
{
      double maf1=iMA(Pairs[j],check_tf,fast_check_ma,0,MODE_LWMA,PRICE_CLOSE,i+1);
      double maf0=iMA(Pairs[j],check_tf,fast_check_ma,0,MODE_LWMA,PRICE_CLOSE,i);
      double mas0=iMA(Pairs[j],check_tf,slow_check_ma,0,MODE_LWMA,PRICE_CLOSE,i);
      int c=0;
      if(maf0 > mas0 && maf0 > maf1)c= 1.0 ;
      if(maf0 > mas0 && maf0 < maf1)c= 0.5 ;                
      if(maf0 < mas0 && maf0 < maf1)c=-1.0 ;
      if(maf0 < mas0 && maf0 > maf1)c=-0.5 ;
      c=c*PairType[j];
      return(c);

}

