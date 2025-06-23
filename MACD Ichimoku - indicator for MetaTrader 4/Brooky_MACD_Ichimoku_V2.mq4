//+------------------------------------------------------------------+
//|                                      Brooky_MACD_Ichimoku_V2.mq4 |
//|                             Base Code http://www.metaquotes.net/ |
//|                     Copyright © 2010, www.Brooky-Indicators.com. |
//|                             http://www.www.Brooky-Indicators.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, www.Brooky-Indicators.com."
#property link      "http://www.www.Brooky-Indicators.com"
extern string Brooky_Modified = "Based on Metaquotes Ichimoku code";
extern string You_Are_Following_Another = "www.Brooky-Indicators.com Indicator ";

#property indicator_separate_window
#property indicator_buffers 8

#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 DodgerBlue
#property indicator_color4 Orchid
#property indicator_color5 Lime
#property indicator_color6 DodgerBlue
#property indicator_color7 Orchid
#property indicator_color8 C'82,82,82'

#property indicator_width1 3
#property indicator_width2 3
#property indicator_width5 3

#property indicator_level1 0
#property indicator_levelcolor C'82,82,82'
#property indicator_levelstyle 2
#property indicator_levelwidth 1

//--auto color
#import "user32.dll"
   int GetDC(int hwnd);
   int ReleaseDC(int hwnd,int hdc);
#import "gdi32.dll"
   color GetPixel(int hdc,int x,int y);

//---- input parameters
extern string Author_Site = "www.Brooky-Indicators.com";
extern string NOTE  = "+--DLL Must Be Allowed--+";
extern string NOTE2 = "+--For Auto Clear Backgound--+";
extern string Ichimoku_Settings =" Set Ichi Periods Below";
extern int    Tenkan=9;
extern int    Kijun=26;
extern int    Senkou=52;
extern string MACD_Periods =" Set MACD Periods Below"; 
extern int    Fast_Ema=12;
extern int    Slow_Ema=26;
extern int    Signal_Sma=9;
extern string Cloud_Style ="2 for Dots : 0 for Line";
extern int    CL_Style  =0;
//---- buffers
double Tenkan_Buffer[];
double Kijun_Buffer[];
double SpanA_Buffer[];
double SpanB_Buffer[];
double Chinkou_Buffer[];
double SpanA2_Buffer[];
double SpanB2_Buffer[];
double Fill_Buffer[];
//----
int a_begin;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//----
   IndicatorShortName("Brooky-Indicators.com MACD Ichimoku ("+Fast_Ema+","+Slow_Ema+","+Signal_Sma);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Tenkan_Buffer);
   SetIndexDrawBegin(0,Tenkan-1);
   SetIndexLabel(0,"Tenkan Sen");
//----
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Kijun_Buffer);
   SetIndexDrawBegin(1,Kijun-1);
   SetIndexLabel(1,"Kijun Sen");
//----
   a_begin=Kijun; if(a_begin<Tenkan) a_begin=Tenkan;
   SetIndexStyle(2,DRAW_HISTOGRAM,CL_Style);
   SetIndexBuffer(2,SpanA_Buffer);
   SetIndexDrawBegin(2,Kijun+a_begin-1);
   SetIndexShift(2,Kijun);
   SetIndexLabel(2,NULL);
   
   SetIndexStyle(5,DRAW_LINE,CL_Style);
   SetIndexBuffer(5,SpanA2_Buffer);
   SetIndexDrawBegin(5,Kijun+a_begin-1);
   SetIndexShift(5,Kijun);
   SetIndexLabel(5,"Senkou Span A");
//----
  SetIndexStyle(3,DRAW_HISTOGRAM,CL_Style);
   SetIndexBuffer(3,SpanB_Buffer);
   SetIndexDrawBegin(3,Kijun+Senkou-1);
   SetIndexShift(3,Kijun);
   SetIndexLabel(3,NULL);
   
   SetIndexStyle(6,DRAW_LINE,CL_Style);
   SetIndexBuffer(6,SpanB2_Buffer);
   SetIndexDrawBegin(6,Kijun+Senkou-1);
   SetIndexShift(6,Kijun);
   SetIndexLabel(6,"Senkou Span B");

//----
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,Chinkou_Buffer);
   SetIndexShift(4,-Kijun);
   SetIndexLabel(4,"Chinkou Span");
   
   //SetIndexStyle(7,DRAW_HISTOGRAM);
   SetIndexBuffer(7,Fill_Buffer);
   SetIndexDrawBegin(7,Kijun+Senkou-1);
   SetIndexShift(7,Kijun);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Ichimoku Kinko Hyo on MACD                                        |
//+------------------------------------------------------------------+
int start()
  {
   int hwnd=WindowHandle(Symbol(),Period());
   int hdc=GetDC(hwnd);
   color back_ground=GetPixel(hdc,1,2);
   ReleaseDC(hwnd,hdc);
   SetIndexStyle(7,DRAW_HISTOGRAM,0,EMPTY,back_ground);
   
   
   int    i,k;
   int    counted_bars=IndicatorCounted();
   double high,low,price;
//----
   if(Bars<=Tenkan || Bars<=Kijun || Bars<=Senkou) return(0);
//---- initial zero
   if(counted_bars<1)
     {
      for(i=1;i<=Tenkan;i++)    Tenkan_Buffer[Bars-i]=0;
      for(i=1;i<=Kijun;i++)     Kijun_Buffer[Bars-i]=0;
      for(i=1;i<=a_begin;i++) { SpanA_Buffer[Bars-i]=0; SpanA2_Buffer[Bars-i]=0; }
      for(i=1;i<=Senkou;i++)  { SpanB_Buffer[Bars-i]=0; SpanB2_Buffer[Bars-i]=0; }
     }
//---- Tenkan Sen
   i=Bars-Tenkan;
   if(counted_bars>Tenkan) i=Bars-counted_bars-1;
   while(i>=0)
     {

         high=iMACD(NULL,0,Fast_Ema,Slow_Ema,Signal_Sma,PRICE_HIGH,MODE_MAIN,i); 
         low=iMACD(NULL,0,Fast_Ema,Slow_Ema,Signal_Sma,PRICE_LOW,MODE_MAIN,i); k=i-1+Tenkan;   
      while(k>=i)
        {
         price=iMACD(NULL,0,Fast_Ema,Slow_Ema,Signal_Sma,PRICE_HIGH,MODE_MAIN,k);
         if(high<price) high=price;
         price=iMACD(NULL,0,Fast_Ema,Slow_Ema,Signal_Sma,PRICE_LOW,MODE_MAIN,k);
         if(low>price)  low=price;
         k--;
        }
      Tenkan_Buffer[i]=(high+low)/2;
      i--;
     }
//---- Kijun Sen
   i=Bars-Kijun;
   if(counted_bars>Kijun) i=Bars-counted_bars-1;
   while(i>=0)
     {
         high=iMACD(NULL,0,Fast_Ema,Slow_Ema,Signal_Sma,PRICE_HIGH,MODE_MAIN,i);
         low=iMACD(NULL,0,Fast_Ema,Slow_Ema,Signal_Sma,PRICE_LOW,MODE_MAIN,i); k=i-1+Kijun;
      while(k>=i)
        {
         price=iMACD(NULL,0,Fast_Ema,Slow_Ema,Signal_Sma,PRICE_HIGH,MODE_MAIN,k);
         if(high<price) high=price;
         price=iMACD(NULL,0,Fast_Ema,Slow_Ema,Signal_Sma,PRICE_LOW,MODE_MAIN,k);
         if(low>price)  low=price;
         k--;
        }
      Kijun_Buffer[i]=(high+low)/2;
      i--;
     }
//---- Senkou Span A
   i=Bars-a_begin+1;
   if(counted_bars>a_begin-1) i=Bars-counted_bars-1;
   while(i>=0)
     {
      price=(Kijun_Buffer[i]+Tenkan_Buffer[i])/2;
      
      SpanA2_Buffer[i]=price;
      i--;
     }
//---- Senkou Span B
   i=Bars-Senkou;
   if(counted_bars>Senkou) i=Bars-counted_bars-1;
   while(i>=0)
     {
      high=iMACD(NULL,0,Fast_Ema,Slow_Ema,Signal_Sma,PRICE_HIGH,MODE_MAIN,i);
      low=iMACD(NULL,0,Fast_Ema,Slow_Ema,Signal_Sma,PRICE_LOW,MODE_MAIN,i);k=i-1+Senkou;
      while(k>=i)
        {
         price=iMACD(NULL,0,Fast_Ema,Slow_Ema,Signal_Sma,PRICE_HIGH,MODE_MAIN,k);
         if(high<price) high=price;
         price=iMACD(NULL,0,Fast_Ema,Slow_Ema,Signal_Sma,PRICE_LOW,MODE_MAIN,k);
         if(low>price)  low=price;
         k--;
        }
      price=(high+low)/2;
      
      SpanB2_Buffer[i]=price;
      
         if(SpanA2_Buffer[i]<=SpanB2_Buffer[i]&& SpanA2_Buffer[i]>=0 && SpanB2_Buffer[i]>=0)
         {
            Fill_Buffer[i]=SpanA2_Buffer[i];SpanB_Buffer[i]=SpanB2_Buffer[i];
         }
         if(SpanA2_Buffer[i]>SpanB2_Buffer[i]&& SpanA2_Buffer[i]>=0 && SpanB2_Buffer[i]>=0)
         {
            Fill_Buffer[i]=SpanB2_Buffer[i];SpanA_Buffer[i]=SpanA2_Buffer[i];
         }
         /////
         if(SpanA2_Buffer[i]<=SpanB2_Buffer[i]&& SpanA2_Buffer[i]<=0 && SpanB2_Buffer[i]>=0)
         {
            Fill_Buffer[i]=0;SpanB_Buffer[i]=SpanA2_Buffer[i];
         }
         if(SpanA2_Buffer[i]>SpanB2_Buffer[i]&& SpanA2_Buffer[i]>=0 && SpanB2_Buffer[i]<=0)
         {
            Fill_Buffer[i]=0;SpanA_Buffer[i]=SpanA2_Buffer[i];
         }
         
         
         if(SpanA2_Buffer[i]<=SpanB2_Buffer[i]&& SpanA2_Buffer[i]<=0 && SpanB2_Buffer[i]<=0)
         {
            Fill_Buffer[i]=SpanB2_Buffer[i];SpanB_Buffer[i]=SpanA2_Buffer[i];
         }
         if(SpanA2_Buffer[i]>SpanB2_Buffer[i]&& SpanA2_Buffer[i]<=0 && SpanB2_Buffer[i]<=0)
         {
            Fill_Buffer[i]=SpanA2_Buffer[i];SpanA_Buffer[i]=SpanB2_Buffer[i];
         }      
         
      i--;
     }
//---- Chinkou Span
   i=Bars-1;
   if(counted_bars>1) i=Bars-counted_bars-1;
   while(i>=0) { Chinkou_Buffer[i]=iMACD(NULL,0,Fast_Ema,Slow_Ema,Signal_Sma,PRICE_CLOSE,MODE_MAIN,i); i--; }
//----
   return(0);
  }
//+------------------------------------------------------------------+