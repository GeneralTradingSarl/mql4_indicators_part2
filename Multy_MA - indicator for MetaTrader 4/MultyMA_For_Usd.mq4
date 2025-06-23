//+------------------------------------------------------------------+
//|                                               MyMultyMA Spr2.mq4 |
//|                                                   AndrFx@mail.ru |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property copyright "Andr"
#property link      " AndrFx@mail.ru"
//---- indicator parameters
#property indicator_buffers 8
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Aqua
#property indicator_color4 Chocolate
#property indicator_color5 White
#property indicator_color6 Lime
#property indicator_color7 MediumOrchid
//#property indicator_color8 Plum
extern int MA_Period      =5;
extern int MA_Basis       =233;
extern int MA_Shift       =0;
extern int MA_Method      =1;
//----
extern string symbol_1   ="EURUSD";
extern string symbol_2   ="GBPUSD";
extern string symbol_3   ="USDCHF";
extern string symbol_4   ="USDJPY";
extern string symbol_5   ="AUDUSD";
extern string symbol_6   ="USDCAD";
extern string symbol_7   ="medium";
//----
double k_1;
double k_2;
double k_3;
double k_4;
double k_5;
double k_6;
//----
extern bool revers=false;
//----
bool revers_1     =false;
bool revers_2     =false;
bool revers_3     =true;
bool revers_4     =false;
bool revers_5     =false;
bool revers_6     =true;
//---- indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];
//----
double val;
double val_med;
double basis;
double basis_symbol;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   if(revers)
     {
      revers_1     =true;
      revers_2     =true;
      revers_3     =false;
      revers_4     =false;
      revers_5     =true;
      revers_6     =false;
      //revers_7      = false;
      //revers_8      = false;
     }
//---- indicators
   int    draw_begin;
   string short_name;
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE,0);
   SetIndexStyle(1,DRAW_LINE,0);
   SetIndexStyle(2,DRAW_LINE,0);
   SetIndexStyle(3,DRAW_LINE,0);
   SetIndexStyle(4,DRAW_LINE,0);
   SetIndexStyle(5,DRAW_LINE,0);
   SetIndexStyle(6,DRAW_LINE,1);
   SetIndexStyle(7,DRAW_LINE,EMPTY,2,Red);
//  SetIndexStyle(8,DRAW_LINE,0);
   if(MA_Period<2) MA_Period=2;
   draw_begin=MA_Period-1;
   SetIndexDrawBegin(0,draw_begin);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexBuffer(6,ExtMapBuffer7);
   SetIndexBuffer(7,ExtMapBuffer8);
//----
   k_1=Ask/MarketInfo(symbol_1,MODE_ASK);
   k_2=Ask/MarketInfo(symbol_2,MODE_ASK);
   k_3=Ask/MarketInfo(symbol_3,MODE_ASK);
   k_4=Ask/MarketInfo(symbol_4,MODE_ASK);
   k_5=Ask/MarketInfo(symbol_5,MODE_ASK);
   k_6=Ask/MarketInfo(symbol_6,MODE_ASK);
//k_7 = Ask / MarketInfo(symbol_7,MODE_ASK);
//k_8 = Ask / MarketInfo(symbol_8,MODE_ASK);
   SetIndexLabel(0,"0 "+symbol_1+" k "+k_1);
   SetIndexLabel(1,"1 "+symbol_2+" k "+k_2);
   SetIndexLabel(2,"2 "+symbol_3+" k "+k_3);
   SetIndexLabel(3,"3 "+symbol_4+" k "+k_4);
   SetIndexLabel(4,"4 "+symbol_5+" k "+k_5);
   SetIndexLabel(5,"5 "+symbol_6+" k "+k_6);
   SetIndexLabel(6,"6 "+"medium");
   SetIndexLabel(7,"7 "+"baza");
//Alert(" k1 ",k_1," k2 ",k_2," k3 ",k_3," k4 ",k_4," \nk5 ",k_5," k6 ",k_6," k7 ",k_7," k8 ",k_8);
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
//----  
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int iMax=Bars-counted_bars;
   if(counted_bars==0) iMax--;

//----
   val=0.0;
   datetime tm;
//----
   for(int ii=iMax; ii>=0; ii--)
     {
      tm=Time[ii];
      val_med=0.0;
      int cnt=0;
      //----
      if(tm==iTime(symbol_1,0,ii))
        {
         val=(iMA(symbol_1,0,MA_Period,MA_Shift,MODE_EMA,PRICE_WEIGHTED,ii)-
              iMA(symbol_1,0,MA_Basis,MA_Shift,MODE_EMA,PRICE_WEIGHTED,ii));
         basis=iMA(NULL,0,MA_Basis,MA_Shift,MODE_EMA,PRICE_WEIGHTED,ii);
         //----
         if(revers_1)
            val=-val;
         //----
         val*=k_1;
         ExtMapBuffer1[ii]=val;
         //----
         val_med=val_med+val;
         cnt++;
        }
      //      else
      //      ExtMapBuffer1[ii]= 0.0;
      //----
      if(tm==iTime(symbol_2,0,ii))
        {
         val=(iMA(symbol_2,0,MA_Period,MA_Shift,MODE_EMA,PRICE_WEIGHTED,ii)-
              iMA(symbol_2,0,MA_Basis,MA_Shift,MODE_EMA,PRICE_WEIGHTED,ii));
         basis=iMA(NULL,0,MA_Basis,MA_Shift,MODE_EMA,PRICE_WEIGHTED,ii);
         //----
         if(revers_2)
            val=-val;
         //----
         val*=k_2;
         //val_med = val_med+basis + val;      
         ExtMapBuffer2[ii]=val;
         //----
         val_med=val_med+val;
         cnt++;
        }
      //   else
      //   ExtMapBuffer2[ii]= 0.0;
      //---- 
      if(tm==iTime(symbol_3,0,ii))
        {
         val=(iMA(symbol_3,0,MA_Period,MA_Shift,MODE_EMA,PRICE_WEIGHTED,ii)-
              iMA(symbol_3,0,MA_Basis,MA_Shift,MODE_EMA,PRICE_WEIGHTED,ii));
         basis=iMA(NULL,0,MA_Basis,MA_Shift,MODE_EMA,PRICE_WEIGHTED,ii);
         //----
         if(revers_3)
            val=-val;
         //----
         val*=k_3;
         //val_med = val_med+basis + val;      
         ExtMapBuffer3[ii]=val;
         //----
         val_med=val_med+val;
         cnt++;
        }
      //   else
      //   ExtMapBuffer3[ii]= 0.0;
      //---- 
      if(tm==iTime(symbol_4,0,ii))
        {
         val=(iMA(symbol_4,0,MA_Period,MA_Shift,MODE_EMA,PRICE_WEIGHTED,ii)-
              iMA(symbol_4,0,MA_Basis,MA_Shift,MODE_EMA,PRICE_WEIGHTED,ii));
         basis=iMA(NULL,0,MA_Basis,MA_Shift,MODE_EMA,PRICE_WEIGHTED,ii);
         //----
         if(revers_4)
            val=-val;
         //----
         val*=k_4;
         //val_med = val_med+basis + val;      
         ExtMapBuffer4[ii]=val;
         val_med=val_med+val;
         cnt++;
        }
      //   else
      //   ExtMapBuffer4[ii]= 0.0;
      //---- 
      if(tm==iTime(symbol_5,0,ii))
        {
         val=(iMA(symbol_5,0,MA_Period,MA_Shift,MODE_EMA,PRICE_WEIGHTED,ii)-
              iMA(symbol_5,0,MA_Basis,MA_Shift,MODE_EMA,PRICE_WEIGHTED,ii));
         basis=iMA(NULL,0,MA_Basis,MA_Shift,MODE_EMA,PRICE_WEIGHTED,ii);
         //----
         if(revers_5)
            val=-val;
         //----
         val*=k_5;
         //val_med = val_med+basis + val;      
         ExtMapBuffer5[ii]=val;
         val_med=val_med+val;
         cnt++;
        }
      //   else
      //   ExtMapBuffer5[ii]= 0.0;
      //---- 
      if(tm==iTime(symbol_6,0,ii))
        {
         val=(iMA(symbol_6,0,MA_Period,MA_Shift,MODE_EMA,PRICE_WEIGHTED,ii)-
              iMA(symbol_6,0,MA_Basis,MA_Shift,MODE_EMA,PRICE_WEIGHTED,ii));
         basis=iMA(NULL,0,MA_Basis,MA_Shift,MODE_EMA,PRICE_WEIGHTED,ii);
         //----
         if(revers_6)
            val=-val;
         //----
         val*=k_6;
         // val_med += (basis + val);//!!!!!      
         ExtMapBuffer6[ii]=val;
         val_med=val_med+val;
         cnt++;
        }
      //   else
      //   ExtMapBuffer6[ii]= 0.0;
      //---- 
/*   int cnt = 6;
   if(ExtMapBuffer1[ii] == 0.0) cnt--;
   if(ExtMapBuffer2[ii] == 0.0) cnt--;
   if(ExtMapBuffer3[ii] == 0.0) cnt--;
   if(ExtMapBuffer4[ii] == 0.0) cnt--;
   if(ExtMapBuffer5[ii] == 0.0) cnt--;
   if(ExtMapBuffer6[ii] == 0.0) cnt--;
  */
      if(cnt==0)
         return(0);
      //----
      ExtMapBuffer7[ii]=val_med/cnt;
/*          (ExtMapBuffer1[ii]
                     +ExtMapBuffer2[ii]
                     +ExtMapBuffer3[ii]
                     +ExtMapBuffer4[ii]
                     +ExtMapBuffer5[ii]
                     +ExtMapBuffer6[ii])/cnt;  */

     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
