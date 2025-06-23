//+------------------------------------------------------------------+
//|                                                   TrackTrend.mq4 |
//|                                                     Duke3DAtomic |
//|                                             duke3datomic@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window

// Периоды таймфреймов:
// 0 - период текущего графика
// 1 - M1
// 2 - M5
// 3 - M15
// 4 - M30
// 5 - H1
// 6 - H4
// 7 - D1
// 8 - W1
// 9 - MN1


int MACD_Fast = 12;
int MACD_Slow = 26;
int Signal_Period = 9;
int MACD_Price = 0;              // PRICE_CLOSE
int MACD_Shift = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
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
   string MACD_comment1,
          MACD_comment2,
          MACD_comment3,
          MACD_comment4,
          MACD_comment5,
          MACD_comment6,
          MACD_comment7,
          MACD_comment8,
          MACD_comment9;
          
   string MACDComment[];
   int limit;
   int counted_bars = IndicatorCounted();
//---- проверка на возможные ошибки
   if(counted_bars < 0) return(-1);
//---- последний посчитанный бар будет пересчитан
   if(counted_bars > 0) counted_bars--;
   limit = Bars - counted_bars;
//---- основной цикл
   for(int i=0; i<limit; i++)
     {
//==============================================================================================     
   string com1, com2, com3, com4;
   com1 = " Up";
   com2 = " Down";
   com3 = " Up->Down";
   com4 = " Down->Up";
//======== M1 ======================================================================================     
     if(MACD(TimeFrame(1))==1) {MACD_comment1 = StrTimeFrame(1)+com1;}
     if(MACD(TimeFrame(1))==2) {MACD_comment1 = StrTimeFrame(1)+com2;}
     if(MACD(TimeFrame(1))==3) {MACD_comment1 = StrTimeFrame(1)+com3;}
     if(MACD(TimeFrame(1))==4) {MACD_comment1 = StrTimeFrame(1)+com4;}
//======== M5 ======================================================================================
     if(MACD(TimeFrame(2))==1) {MACD_comment2 = StrTimeFrame(2)+com1;}
     if(MACD(TimeFrame(2))==2) {MACD_comment2 = StrTimeFrame(2)+com2;}
     if(MACD(TimeFrame(2))==3) {MACD_comment2 = StrTimeFrame(2)+com3;}
     if(MACD(TimeFrame(2))==4) {MACD_comment2 = StrTimeFrame(2)+com4;}
//======== M15 =====================================================================================
     if(MACD(TimeFrame(3))==1) {MACD_comment3 = StrTimeFrame(3)+com1;}
     if(MACD(TimeFrame(3))==2) {MACD_comment3 = StrTimeFrame(3)+com2;}
     if(MACD(TimeFrame(3))==3) {MACD_comment3 = StrTimeFrame(3)+com3;}
     if(MACD(TimeFrame(3))==4) {MACD_comment3 = StrTimeFrame(3)+com4;}
//======== M30 =====================================================================================
     if(MACD(TimeFrame(4))==1) {MACD_comment4 = StrTimeFrame(4)+com1;}
     if(MACD(TimeFrame(4))==2) {MACD_comment4 = StrTimeFrame(4)+com2;}
     if(MACD(TimeFrame(4))==3) {MACD_comment4 = StrTimeFrame(4)+com3;}
     if(MACD(TimeFrame(4))==4) {MACD_comment4 = StrTimeFrame(4)+com4;}
//======== H1 ======================================================================================
     if(MACD(TimeFrame(5))==1) {MACD_comment5 = StrTimeFrame(5)+com1;}
     if(MACD(TimeFrame(5))==2) {MACD_comment5 = StrTimeFrame(5)+com2;}
     if(MACD(TimeFrame(5))==3) {MACD_comment5 = StrTimeFrame(5)+com3;}
     if(MACD(TimeFrame(5))==4) {MACD_comment5 = StrTimeFrame(5)+com4;}
//======== H4 ======================================================================================
     if(MACD(TimeFrame(6))==1) {MACD_comment6 = StrTimeFrame(6)+com1;}
     if(MACD(TimeFrame(6))==2) {MACD_comment6 = StrTimeFrame(6)+com2;}
     if(MACD(TimeFrame(6))==3) {MACD_comment6 = StrTimeFrame(6)+com3;}
     if(MACD(TimeFrame(6))==4) {MACD_comment6 = StrTimeFrame(6)+com4;}
//======== D1 ======================================================================================
     if(MACD(TimeFrame(7))==1) {MACD_comment7 = StrTimeFrame(7)+com1;}
     if(MACD(TimeFrame(7))==2) {MACD_comment7 = StrTimeFrame(7)+com2;}
     if(MACD(TimeFrame(7))==3) {MACD_comment7 = StrTimeFrame(7)+com3;}
     if(MACD(TimeFrame(7))==4) {MACD_comment7 = StrTimeFrame(7)+com4;}
//======== W1 ======================================================================================
     if(MACD(TimeFrame(8))==1) {MACD_comment8 = StrTimeFrame(8)+com1;}
     if(MACD(TimeFrame(8))==2) {MACD_comment8 = StrTimeFrame(8)+com2;}
     if(MACD(TimeFrame(8))==3) {MACD_comment8 = StrTimeFrame(8)+com3;}
     if(MACD(TimeFrame(8))==4) {MACD_comment8 = StrTimeFrame(8)+com4;}
//======== MN1 =====================================================================================
     if(MACD(TimeFrame(9))==1) {MACD_comment9 = StrTimeFrame(9)+com1;}
     if(MACD(TimeFrame(9))==2) {MACD_comment9 = StrTimeFrame(9)+com2;}
     if(MACD(TimeFrame(9))==3) {MACD_comment9 = StrTimeFrame(9)+com3;}
     if(MACD(TimeFrame(9))==4) {MACD_comment9 = StrTimeFrame(9)+com4;}
//==============================================================================================
     }
   Comment("MACD (",MACD_Fast,",",MACD_Slow,",",Signal_Period,")\n",MACD_comment9,"\n",MACD_comment8,"\n",MACD_comment7,"\n",MACD_comment6,"\n",MACD_comment5,"\n",MACD_comment4,"\n",MACD_comment3,"\n",MACD_comment2,"\n",MACD_comment1);  
//----
   return(0);
  }
//==================================================================================================
int MACD(int MACDTimeFrame)
   {
   int MACD_Trend;
   
   double MACD_Main_0;
   double MACD_Main_1;
   double MACD_Signal_0;
   double MACD_Signal_1;

   MACD_Main_0 = iMACD(Symbol(),MACDTimeFrame,MACD_Fast,MACD_Slow,Signal_Period,MACD_Price,MODE_MAIN,0);
   MACD_Main_1 = iMACD(Symbol(),MACDTimeFrame,MACD_Fast,MACD_Slow,Signal_Period,MACD_Price,MODE_MAIN,1);
   MACD_Signal_0 = iMACD(Symbol(),MACDTimeFrame,MACD_Fast,MACD_Slow,Signal_Period,MACD_Price,MODE_SIGNAL,0);
   MACD_Signal_1 = iMACD(Symbol(),MACDTimeFrame,MACD_Fast,MACD_Slow,Signal_Period,MACD_Price,MODE_SIGNAL,1);
   
   if(MACD_Main_0>MACD_Main_1 && MACD_Signal_0>MACD_Signal_1 && MACD_Main_0>MACD_Signal_0) {MACD_Trend = 1;}    // Тренд вверх
   if(MACD_Main_0<MACD_Main_1 && MACD_Signal_0<MACD_Signal_1 && MACD_Main_0<MACD_Signal_0) {MACD_Trend = 2;}    // Тренд вниз
   if(MACD_Main_0<MACD_Main_1 && MACD_Signal_0>MACD_Signal_1 && MACD_Main_0>MACD_Signal_0) {MACD_Trend = 3;}    // Тренд вверх, с переходом вниз
   if(MACD_Main_0>MACD_Main_1 && MACD_Signal_0<MACD_Signal_1 && MACD_Main_0<MACD_Signal_0) {MACD_Trend = 4;}    // Тренд вниз, с переходом вверх
   return(MACD_Trend);
   }
//==================================================================================================
int TimeFrame(int Time_Period)   // функция возвращает числовое значение периода графика
  {
   switch(Time_Period) 
     {
      case 0: return(0);           // период текущего графика
      case 1: return(1);           // M1
      case 2: return(5);           // M5
      case 3: return(15);          // M15
      case 4: return(30);          // M30
      case 5: return(60);          // H1
      case 6: return(240);         // H4
      case 7: return(1440);        // D1
      case 8: return(10080);       // W1
      case 9: return(43200);       // MN1
     }
  }
//==================================================================================================
string StrTimeFrame(int T_Frame)   // функция возвращает строковое значение периода графика
  {
   switch(T_Frame) 
     {
      case 0: return("Cur:");       // период текущего графика
      case 1: return("M1:");        // M1
      case 2: return("M5:");        // M5
      case 3: return("M15:");       // M15
      case 4: return("M30:");       // M30
      case 5: return("H1:");        // H1
      case 6: return("H4:");        // H4
      case 7: return("D1:");        // D1
      case 8: return("W1:");        // W1
      case 9: return("MN1:");       // MN1
     }
  }
//==================================================================================================

