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

int LabelCorner = 0;
extern int MACD_Fast = 12;
extern int MACD_Slow = 26;
extern int Signal_Period = 9;
int MACD_Price = 0;              // PRICE_CLOSE
int MACD_Shift = 0;

extern color color_Up;              // Цвет указателя направления тренда вверх
extern color color_Dn;              // Цвет указателя направления тренда вниз
extern color color_UpDn;            // Цвет указателя направления тренда вверх, с последующим разворотом вниз
extern color color_DnUp;            // Цвет указателя направления тренда вниз, с последующим разворотом вверх
extern color color_TimeFrame;       // Цвет надписи таймфрейма


double RSI_0;
double RSI_1;
int RSI_TimeFrame = 3;
int RSI_Period = 14;
int RSI_Price = 0;
int RSI_Shift = 0;


double ADX_Main;
double ADX_Plus;
double ADX_Minus;
int ADX_TimeFrame = 3;
int ADX_Period = 14;
int ADX_Price = 0;
int ADX_Shift = 0;
   

extern int FontSize = 14;           // Размер шрифта
string Font = "Times New Roman";
//string MACD_Comm1[];
//string MACD_Comm2[];
   

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   /*int i;
   for(i=1;i<=9;i++)
      {
      MACD_Comm1[i] = "Label1_"+i;
      GreatObjectLabel(MACD_Comm1[i],  10, i*FontSize+6);
      
      MACD_Comm2[i] = "Label2_"+i;
      GreatObjectLabel(MACD_Comm2[i],  50, i*FontSize+6);
      }*/
   int interval = 10;   
   GreatObjectLabel("Label1_1",  10, 1*FontSize+interval);
   GreatObjectLabel("Label1_2",  10, 2*FontSize+interval);
   GreatObjectLabel("Label1_3",  10, 3*FontSize+interval);
   GreatObjectLabel("Label1_4",  10, 4*FontSize+interval);
   GreatObjectLabel("Label1_5",  10, 5*FontSize+interval);
   GreatObjectLabel("Label1_6",  10, 6*FontSize+interval);
   GreatObjectLabel("Label1_7",  10, 7*FontSize+interval);
   GreatObjectLabel("Label1_8",  10, 8*FontSize+interval);
   GreatObjectLabel("Label1_9",  10, 9*FontSize+interval);
   
   GreatObjectLabel("Label2_1",  60, 1*FontSize+interval); 
   GreatObjectLabel("Label2_2",  60, 2*FontSize+interval);
   GreatObjectLabel("Label2_3",  60, 3*FontSize+interval);
   GreatObjectLabel("Label2_4",  60, 4*FontSize+interval);
   GreatObjectLabel("Label2_5",  60, 5*FontSize+interval);
   GreatObjectLabel("Label2_6",  60, 6*FontSize+interval);
   GreatObjectLabel("Label2_7",  60, 7*FontSize+interval);
   GreatObjectLabel("Label2_8",  60, 8*FontSize+interval);
   GreatObjectLabel("Label2_9",  60, 9*FontSize+interval);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   /*int i;
   for(i=1;i<=9;i++)
      {
      ObjectDelete(MACD_Comm1[i]);
      ObjectDelete(MACD_Comm2[i]);
      }*/
   ObjectDelete("Label1_1");
   ObjectDelete("Label1_2");
   ObjectDelete("Label1_3");
   ObjectDelete("Label1_4");
   ObjectDelete("Label1_5");
   ObjectDelete("Label1_6");
   ObjectDelete("Label1_7");
   ObjectDelete("Label1_8");
   ObjectDelete("Label1_9");
   
   ObjectDelete("Label2_1");
   ObjectDelete("Label2_2");
   ObjectDelete("Label2_3");
   ObjectDelete("Label2_4");
   ObjectDelete("Label2_5");
   ObjectDelete("Label2_6");
   ObjectDelete("Label2_7");
   ObjectDelete("Label2_8");
   ObjectDelete("Label2_9");
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

   string com1, com2, com3, com4;
   com1 = "Up";
   com2 = "Down";
   com3 = "Up->Down";
   com4 = "Down->Up";
   
   color_TimeFrame = White;
   color_Up = Lime;
   color_Dn = DeepPink;
   color_UpDn = DodgerBlue;
   color_DnUp = DodgerBlue;
          
   int limit, i;
   int counted_bars = IndicatorCounted();
//---- проверка на возможные ошибки
   if(counted_bars < 0) return(-1);
//---- последний посчитанный бар будет пересчитан
   if(counted_bars > 0) counted_bars--;
   limit = Bars - counted_bars;
//---- основной цикл
   for(i=0; i<limit; i++)
     {
     /*for(i=1;i<=9;i++)
       {
       MACD_Comm1[i] = "Label1_"+i;
       MACD_Comm2[i] = "Label2_"+i;

       if(MACD(TimeFrame(i))==1)
          {
          ObjectSetText(MACD_Comm1[i],StrTimeFrame(i),FontSize,Font,color_TimeFrame);
          ObjectSetText(MACD_Comm2[i],com1,FontSize,Font,color_Up);
          }
       if(MACD(TimeFrame(i))==2)
          {
          ObjectSetText(MACD_Comm1[i],StrTimeFrame(i),FontSize,Font,color_TimeFrame);
          ObjectSetText(MACD_Comm2[i],com2,FontSize,Font,color_Dn);
          }
       if(MACD(TimeFrame(i))==3)
          {
          ObjectSetText(MACD_Comm1[i],StrTimeFrame(i),FontSize,Font,color_TimeFrame);
          ObjectSetText(MACD_Comm2[i],com3,FontSize,Font,color_UpDn);
          }
       if(MACD(TimeFrame(i))==4)
          {
          ObjectSetText(MACD_Comm1[i],StrTimeFrame(i),FontSize,Font,color_TimeFrame);
          ObjectSetText(MACD_Comm2[i],com4,FontSize,Font,color_DnUp);
          }
       }*/
//======== MN1 =====================================================================================
     if(MACD(TimeFrame(9))==1) 
       {
       ObjectSetText("Label1_1",StrTimeFrame(9),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_1",com1,FontSize,Font,color_Up);
       }
     if(MACD(TimeFrame(9))==2) 
       {
       ObjectSetText("Label1_1",StrTimeFrame(9),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_1",com2,FontSize,Font,color_Dn);
       }
     if(MACD(TimeFrame(9))==3) 
       {
       ObjectSetText("Label1_1",StrTimeFrame(9),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_1",com3,FontSize,Font,color_UpDn);
       }
     if(MACD(TimeFrame(9))==4) 
       {
       ObjectSetText("Label1_1",StrTimeFrame(9),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_1",com4,FontSize,Font,color_DnUp);
       }
//======== W1 ======================================================================================
     if(MACD(TimeFrame(8))==1) 
       {
       ObjectSetText("Label1_2",StrTimeFrame(8),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_2",com1,FontSize,Font,color_Up);
       }
     if(MACD(TimeFrame(8))==2) 
       {
       ObjectSetText("Label1_2",StrTimeFrame(8),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_2",com2,FontSize,Font,color_Dn);
       }
     if(MACD(TimeFrame(8))==3) 
       {
       ObjectSetText("Label1_2",StrTimeFrame(8),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_2",com3,FontSize,Font,color_UpDn);
       }
     if(MACD(TimeFrame(8))==4) 
       {
       ObjectSetText("Label1_2",StrTimeFrame(7),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_2",com4,FontSize,Font,color_DnUp);
       }
//======== D1 ======================================================================================
     if(MACD(TimeFrame(7))==1) 
       {
       ObjectSetText("Label1_3",StrTimeFrame(7),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_3",com1,FontSize,Font,color_Up);
       }
     if(MACD(TimeFrame(7))==2) 
       {
       ObjectSetText("Label1_3",StrTimeFrame(7),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_3",com2,FontSize,Font,color_Dn);
       }
     if(MACD(TimeFrame(7))==3) 
       {
       ObjectSetText("Label1_3",StrTimeFrame(7),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_3",com3,FontSize,Font,color_UpDn);
       }
     if(MACD(TimeFrame(7))==4) 
       {
       ObjectSetText("Label1_3",StrTimeFrame(7),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_3",com4,FontSize,Font,color_DnUp);
       }
//======== H4 ======================================================================================
     if(MACD(TimeFrame(6))==1) 
       {
       ObjectSetText("Label1_4",StrTimeFrame(6),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_4",com1,FontSize,Font,color_Up);
       }
     if(MACD(TimeFrame(6))==2) 
       {
       ObjectSetText("Label1_4",StrTimeFrame(6),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_4",com2,FontSize,Font,color_Dn);
       }
     if(MACD(TimeFrame(6))==3) 
       {
       ObjectSetText("Label1_4",StrTimeFrame(6),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_4",com3,FontSize,Font,color_UpDn);
       }
     if(MACD(TimeFrame(6))==4) 
       {
       ObjectSetText("Label1_4",StrTimeFrame(6),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_4",com4,FontSize,Font,color_DnUp);
       }
//======== H1 ======================================================================================
     if(MACD(TimeFrame(5))==1) 
       {
       ObjectSetText("Label1_5",StrTimeFrame(5),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_5",com1,FontSize,Font,color_Up);
       }
     if(MACD(TimeFrame(5))==2) 
       {
       ObjectSetText("Label1_5",StrTimeFrame(5),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_5",com2,FontSize,Font,color_Dn);
       }
     if(MACD(TimeFrame(5))==3) 
       {
       ObjectSetText("Label1_5",StrTimeFrame(5),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_5",com3,FontSize,Font,color_UpDn);
       }
     if(MACD(TimeFrame(5))==4) 
       {
       ObjectSetText("Label1_5",StrTimeFrame(5),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_5",com4,FontSize,Font,color_DnUp);
       }
//======== M30 =====================================================================================
     if(MACD(TimeFrame(4))==1) 
       {
       ObjectSetText("Label1_6",StrTimeFrame(4),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_6",com1,FontSize,Font,color_Up);
       }
     if(MACD(TimeFrame(4))==2) 
       {
       ObjectSetText("Label1_6",StrTimeFrame(4),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_6",com2,FontSize,Font,color_Dn);
       }
     if(MACD(TimeFrame(4))==3) 
       {
       ObjectSetText("Label1_6",StrTimeFrame(4),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_6",com3,FontSize,Font,color_UpDn);
       }
     if(MACD(TimeFrame(4))==4) 
       {
       ObjectSetText("Label1_6",StrTimeFrame(4),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_6",com4,FontSize,Font,color_DnUp);
       }
//======== M15 =====================================================================================
     if(MACD(TimeFrame(3))==1) 
       {
       ObjectSetText("Label1_7",StrTimeFrame(3),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_7",com1,FontSize,Font,color_Up);
       }
     if(MACD(TimeFrame(3))==2) 
       {
       ObjectSetText("Label1_7",StrTimeFrame(3),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_7",com2,FontSize,Font,color_Dn);
       }
     if(MACD(TimeFrame(3))==3) 
       {
       ObjectSetText("Label1_7",StrTimeFrame(3),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_7",com3,FontSize,Font,color_UpDn);
       }
     if(MACD(TimeFrame(3))==4) 
       {
       ObjectSetText("Label1_7",StrTimeFrame(3),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_7",com4,FontSize,Font,color_DnUp);
       }
//======== M5 ======================================================================================
     if(MACD(TimeFrame(2))==1) 
       {
       ObjectSetText("Label1_8",StrTimeFrame(2),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_8",com1,FontSize,Font,color_Up);
       }
     if(MACD(TimeFrame(2))==2) 
       {
       ObjectSetText("Label1_8",StrTimeFrame(2),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_8",com2,FontSize,Font,color_Dn);
       }
     if(MACD(TimeFrame(2))==3) 
       {
       ObjectSetText("Label1_8",StrTimeFrame(2),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_8",com3,FontSize,Font,color_UpDn);
       }
     if(MACD(TimeFrame(2))==4) 
       {
       ObjectSetText("Label1_8",StrTimeFrame(2),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_8",com4,FontSize,Font,color_DnUp);
       }
//======== M1 ======================================================================================     
     if(MACD(TimeFrame(1))==1) 
       {
       //ObjectSetText(MACD_Comm1[1],StrTimeFrame(1),FontSize,Font,color_TimeFrame);
       //ObjectSetText(MACD_Comm2[1],com1,FontSize,Font,color_Up);
       ObjectSetText("Label1_9",StrTimeFrame(1),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_9",com1,FontSize,Font,color_Up);
       }
     if(MACD(TimeFrame(1))==2) 
       {
       ObjectSetText("Label1_9",StrTimeFrame(1),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_9",com2,FontSize,Font,color_Dn);
       }
     if(MACD(TimeFrame(1))==3) 
       {
       ObjectSetText("Label1_9",StrTimeFrame(1),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_9",com3,FontSize,Font,color_UpDn);
       }
     if(MACD(TimeFrame(1))==4) 
       {
       ObjectSetText("Label1_9",StrTimeFrame(1),FontSize,Font,color_TimeFrame);
       ObjectSetText("Label2_9",com4,FontSize,Font,color_DnUp);
       }
//==============================================================================================
      
     /*if(RSI(TimeFrame(RSI_TimeFrame))==1)
      {
      RSI_comment = StrTimeFrame(RSI_TimeFrame)+" Up";
      }
     if(RSI(TimeFrame(RSI_TimeFrame))==0)
      {
      RSI_comment = StrTimeFrame(RSI_TimeFrame)+" Down";
      }*/
//==============================================================================================     
     }
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
/*int RSI(int RSI_TimeFrame)
   {
   int RSI_Trend;
   
   RSI_0 = iRSI(Symbol(),RSI_TimeFrame,RSI_Period,RSI_Price,0);
   RSI_1 = iRSI(Symbol(),RSI_TimeFrame,RSI_Period,RSI_Price,1);
   
   if(RSI_0>RSI_1)
      {RSI_Trend = 1;}
   if(RSI_0<RSI_1)
      {RSI_Trend = 0;}
   return(RSI_Trend);
   }
//==================================================================================================
int ADX(int ADX_TimeFrame)
   {
   int ADX_Trend;
   
   ADX_Main = iADX(Symbol(),ADX_TimeFrame,ADX_Period,ADX_Price,MODE_MAIN,ADX_Shift);
   ADX_Plus = iADX(Symbol(),ADX_TimeFrame,ADX_Period,ADX_Price,MODE_PLUSDI,ADX_Shift);
   ADX_Minus = iADX(Symbol(),ADX_TimeFrame,ADX_Period,ADX_Price,MODE_MINUSDI,ADX_Shift);
   
   return (ADX_Trend);
   }
*/
//==================================================================================================



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
int GreatObjectLabel(string NameObj, int Coord_X, int Coord_Y) // Функция создания метки
  {
   ObjectCreate(NameObj, OBJ_LABEL, 0, 0, 0);
   ObjectSet(NameObj, OBJPROP_CORNER, LabelCorner);
   ObjectSet(NameObj, OBJPROP_XDISTANCE, Coord_X);
   ObjectSet(NameObj, OBJPROP_YDISTANCE, Coord_Y);
  }
//==================================================================================================



