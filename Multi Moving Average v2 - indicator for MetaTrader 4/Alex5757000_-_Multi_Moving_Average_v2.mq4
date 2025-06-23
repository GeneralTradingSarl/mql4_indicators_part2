//+------------------------------------------------------------------+
//|                        Alex5757000 - Multi Moving Average v2.mq4 |
//|              Copyright © 2010, Alex5757000, Alexander S. Sovpel' |
//|                                   E-mail : Alex5757000@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Alex5757000, Alexander S. Sovpel'"
#property link      "E-mail: Alex5757000@ya.ru"

#property indicator_separate_window
#property indicator_minimum 1.0
#property indicator_maximum 4.0
#property indicator_buffers 8
#property indicator_color1 DeepSkyBlue
#property indicator_color2 Magenta
#property indicator_color3 DeepSkyBlue
#property indicator_color4 Magenta
#property indicator_color5 DeepSkyBlue
#property indicator_color6 Magenta
#property indicator_color7 DeepSkyBlue
#property indicator_color8 Magenta

extern string MA_1 = "The input parameters of the 1st moving average";

extern int MA_1_TF = 1; // Временной интервал (Time Frame). 1 = M1; 5 = M5; 15 = M15; 30 = M30; 60 = H1; 240 = H4; 1440 = D1; 
extern int MA_1_Period = 89; // Период усреднения (Averaging period). 
extern int MA_1_Mode = MODE_LWMA; // Метод вычисления скользящего среднего (Averaging method). 0 = SMA; 1 = EMA; 2 = SSMA; 3 = LWMA;
extern int MA_1_Price = PRICE_WEIGHTED; /* Используемая цена для расчёта скользящего среднего (The type of the price used for calculaton of Moving Average).
0 = CLOSE, 1 = OPEN, 2 = HIGH, 3 = LOW, 4 = MEDIAN, 5 = TYPICAL, 6 = WEIGHTED */

extern string MA_2 = "The input parameters of the 2nd moving average";

extern int MA_2_TF = 5; // Временной интервал (Time Frame). 1 = M1; 5 = M5; 15 = M15; 30 = M30; 60 = H1; 240 = H4; 1440 = D1; 
extern int MA_2_Period = 55; // Период усреднения (Averaging period). 
extern int MA_2_Mode = MODE_LWMA; // Метод вычисления скользящего среднего (Averaging method). 0 = SMA; 1 = EMA; 2 = SSMA; 3 = LWMA;
extern int MA_2_Price = PRICE_WEIGHTED; /* Используемая цена для расчёта скользящего среднего (The type of the price used for calculaton of Moving Average).
0 = CLOSE, 1 = OPEN, 2 = HIGH, 3 = LOW, 4 = MEDIAN, 5 = TYPICAL, 6 = WEIGHTED */

extern string MA_3 = "The input parameters of the 3rd moving average";

extern int MA_3_TF = 15; // Временной интервал (Time Frame). 1 = M1; 5 = M5; 15 = M15; 30 = M30; 60 = H1; 240 = H4; 1440 = D1; 
extern int MA_3_Period = 34; // Период усреднения (Averaging period). 
extern int MA_3_Mode = MODE_LWMA; // Метод вычисления скользящего среднего (Averaging method). 0 = SMA; 1 = EMA; 2 = SSMA; 3 = LWMA;
extern int MA_3_Price = PRICE_WEIGHTED; /* Используемая цена для расчёта скользящего среднего (The type of the price used for calculaton of Moving Average).
0 = CLOSE, 1 = OPEN, 2 = HIGH, 3 = LOW, 4 = MEDIAN, 5 = TYPICAL, 6 = WEIGHTED */

extern string MA_4 = "The input parameters of the 4th moving average";

extern int MA_4_TF = 60; // Временной интервал (Time Frame). 1 = M1; 5 = M5; 15 = M15; 30 = M30; 60 = H1; 240 = H4; 1440 = D1; 
extern int MA_4_Period = 21; // Период усреднения (Averaging period). 
extern int MA_4_Mode = MODE_LWMA; // Метод вычисления скользящего среднего (Averaging method). 0 = SMA; 1 = EMA; 2 = SSMA; 3 = LWMA;
extern int MA_4_Price = PRICE_WEIGHTED; /* Используемая цена для расчёта скользящего среднего (The type of the price used for calculaton of Moving Average).
0 = CLOSE, 1 = OPEN, 2 = HIGH, 3 = LOW, 4 = MEDIAN, 5 = TYPICAL, 6 = WEIGHTED */

extern bool RangeGraphic = TRUE; // Выделять область индикатора при совпадения направления движения четырех МА.

extern color RangeColorUp = DarkBlue;
extern color RangeColorDown = Maroon;

extern bool RangeAlert = TRUE; // Алерт при совпадении направления движения четырех МА.

extern string Visual = "Display parameters";

extern string Wingdings = "0 || 1 || 2";

extern int BarWingdings = 0; // Тип визуализации: 0 = квадрат, 1 = прямоугольник, 2 = точка.
extern int BarWidth = 0; // Толщина.
extern color BarColorUp = indicator_color1;
extern color BarColorDown = indicator_color2;

int P1_Position = 4;
int P2_Position = 3;
int P3_Position = 2;
int P4_Position = 1;

extern double Gap = 0.6;

extern string SetLabel = "Labels setting";

extern bool ShowLabel = TRUE;

extern string V_Label= "Vertical shift for text labels";

extern double V_Shift = 0.5; // Вертикальный сдвиг текстовой метки.

extern string H_Label = "Horizontal shift for text labels";

extern int H_Shift = 30; // Горизонтальный сдвиг текстовой метки.

extern string UP_DN = "Moving average direction relative to the price: above/below";

extern color TextColorUp = indicator_color1;
extern color TextColorDown = indicator_color2;

//+------------------------------------------------------------------+

string Label = "", ShortName;

double MA1_Up_Buffer[];
double MA2_Up_Buffer[];
double MA3_Up_Buffer[];
double MA4_Up_Buffer[];

double MA1_Down_Buffer[];
double MA2_Down_Buffer[];
double MA3_Down_Buffer[];
double MA4_Down_Buffer[];

double MA1_0 = 0.0;
double MA2_0 = 0.0;
double MA3_0 = 0.0;
double MA4_0 = 0.0;

double MA1_1 = 0.0;
double MA1_2 = 0.0;
double MA1_3 = 0.0;

double MA2_1 = 0.0;
double MA2_2 = 0.0;
double MA2_3 = 0.0;

double MA3_1 = 0.0;
double MA3_2 = 0.0;
double MA3_3 = 0.0;

double MA4_1 = 0.0;
double MA4_2 = 0.0;
double MA4_3 = 0.0;

bool HavePlayedUp = FALSE;
bool HavePlayedDown = FALSE;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
  {
   int WingdingsUp, WingdingsDown;

   switch(BarWingdings)
     {
      case 0 : WingdingsUp = 167; WingdingsDown = 167; break;
      case 1 : WingdingsUp = 250; WingdingsDown = 250; break;
      case 2 : WingdingsUp = 158; WingdingsDown = 158; break;

      default : Alert(WindowExpertName()+" ERROR : Please enter the correct value for BarWingdings !"); return(0);
     }
     
   SetIndexStyle (0, DRAW_ARROW, STYLE_SOLID, BarWidth, BarColorDown);
   SetIndexArrow (0, WingdingsUp);
   SetIndexBuffer(0, MA1_Up_Buffer);
   SetIndexEmptyValue(0, EMPTY_VALUE);

   SetIndexStyle (1, DRAW_ARROW, STYLE_SOLID, BarWidth, BarColorUp);
   SetIndexArrow (1, WingdingsDown);
   SetIndexBuffer(1, MA1_Down_Buffer);
   SetIndexEmptyValue(1, EMPTY_VALUE);

   SetIndexStyle (2, DRAW_ARROW, STYLE_SOLID, BarWidth, BarColorDown);
   SetIndexArrow (2, WingdingsUp);
   SetIndexBuffer(2, MA2_Up_Buffer);
   SetIndexEmptyValue(2, EMPTY_VALUE);

   SetIndexStyle (3, DRAW_ARROW, STYLE_SOLID, BarWidth, BarColorUp);
   SetIndexArrow (3, WingdingsDown);
   SetIndexBuffer(3, MA2_Down_Buffer);
   SetIndexEmptyValue(3, EMPTY_VALUE);

   SetIndexStyle (4, DRAW_ARROW, STYLE_SOLID, BarWidth, BarColorDown);
   SetIndexArrow (4, WingdingsUp);
   SetIndexBuffer(4, MA3_Up_Buffer);
   SetIndexEmptyValue(4, EMPTY_VALUE);

   SetIndexStyle (5, DRAW_ARROW, STYLE_SOLID, BarWidth, BarColorUp);
   SetIndexArrow (5, WingdingsDown);
   SetIndexBuffer(5, MA3_Down_Buffer);
   SetIndexEmptyValue(5, EMPTY_VALUE);

   SetIndexStyle (6, DRAW_ARROW, STYLE_SOLID, BarWidth, BarColorDown);
   SetIndexArrow (6, WingdingsUp);
   SetIndexBuffer(6, MA4_Up_Buffer);
   SetIndexEmptyValue(6, EMPTY_VALUE);

   SetIndexStyle (7, DRAW_ARROW, STYLE_SOLID, BarWidth, BarColorUp);
   SetIndexArrow (7, WingdingsDown);
   SetIndexBuffer(7, MA4_Down_Buffer);
   SetIndexEmptyValue(7, EMPTY_VALUE);

   SetIndexLabel(0, "1st Up Buffer");
   SetIndexLabel(1, "1st Down Buffer");
   SetIndexLabel(2, "2nd Up Buffer");
   SetIndexLabel(3, "2nd Down Buffer");
   SetIndexLabel(4, "3rd Up Buffer");
   SetIndexLabel(5, "3rd Down Buffer");
   SetIndexLabel(6, "4th Up Buffer");
   SetIndexLabel(7, "4th Down Buffer");

   IndicatorDigits(0);

   ShortName = "Alex5757000 - Multi Moving Average v2";
   IndicatorShortName(ShortName);

   return(0);
  }
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+

int deinit()
  {
   int i;
   string Name = WindowFind(ShortName);

   for(i=1; i<=4; i++)
     {
      if(ObjectFind("Text_1 " + Name + i)!=-1) ObjectDelete("Text_1 " + Name + i);
      if(ObjectFind("Text_2 " + Name + i)!=-1) ObjectDelete("Text_2 " + Name + i);
      if(ObjectFind("Text_3 " + Name + i)!=-1) ObjectDelete("Text_3 " + Name + i);
     }

   for(i=1; i<=10; i++)
     {
      if(ObjectFind("Intro_" + i)!=-1) ObjectDelete("Intro_" + i);
     }
     
   if(ObjectFind("RectangleUp")==WindowFind(WindowExpertName())) ObjectDelete("RectangleUp");
   if(ObjectFind("RectangleDown")==WindowFind(WindowExpertName())) ObjectDelete("RectangleDown");

   GlobalVariableDel("INTRO");

   return(0);
  }
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
  {

   datetime TimeArray_1[], TimeArray_2[], TimeArray_3[], TimeArray_4[];

   int CountedBars = IndicatorCounted(), i, y;
   // проверка на возможные ошибки.
   if(CountedBars<0) return(-1);
   // последний посчитанный бар будет пересчитан.
   if(CountedBars>0) CountedBars--;

   int Limit = Bars - CountedBars;

   color TextColor_1, TextColor_2, TextColor_3, TextColor_4;
     
//+------------------------------------------------------------------+

   if(MA_1_TF < Period()) MA_1_TF = Period();

   ArrayCopySeries(TimeArray_1,MODE_TIME,Symbol(),MA_1_TF); 

   for(i=0, y=0; y<=Limit; y++)
     {
      while(Time[y] < TimeArray_1[i]) i++; 

      MA1_1 = iMA(NULL, MA_1_TF, MA_1_Period, 0, MA_1_Mode, MA_1_Price, i);
      MA1_2 = iMA(NULL, MA_1_TF, MA_1_Period, 0, MA_1_Mode, MA_1_Price, i+1);
      MA1_3 = iMA(NULL, MA_1_TF, MA_1_Period, 0, MA_1_Mode, MA_1_Price, i+2);
      
      MA1_1 = iMA(NULL, MA_1_TF, MA_1_Period, 0, MA_1_Mode, MA_1_Price, i);
      MA1_2 = iMA(NULL, MA_1_TF, MA_1_Period, 0, MA_1_Mode, MA_1_Price, i+1);
      MA1_3 = iMA(NULL, MA_1_TF, MA_1_Period, 0, MA_1_Mode, MA_1_Price, i+2);

      MA1_0 = iMA(NULL, MA_1_TF, 1, 0, MA_1_Mode, MA_1_Price, i);

      MA1_Up_Buffer[y] = EMPTY_VALUE;
      MA1_Down_Buffer[y] = EMPTY_VALUE;

      if(MA1_1 < MA1_2) MA1_Up_Buffer[y] = Gap * P1_Position + 1.0;
      else MA1_Down_Buffer[y] = Gap * P1_Position + 1.0;

      if(MA1_1 < MA1_0) TextColor_1 = TextColorUp;
      else TextColor_1 = TextColorDown;
     }
     
//+------------------------------------------------------------------+

   if(MA_2_TF < Period()) MA_2_TF = Period();

   ArrayCopySeries(TimeArray_2,MODE_TIME,Symbol(),MA_2_TF); 

   for(i=0, y=0; y<=Limit; y++)
     {
      while(Time[y] < TimeArray_2[i]) i++; 

      MA2_1 = iMA(NULL, MA_2_TF, MA_2_Period, 0, MA_2_Mode, MA_2_Price, i);
      MA2_2 = iMA(NULL, MA_2_TF, MA_2_Period, 0, MA_2_Mode, MA_2_Price, i+1);
      MA2_3 = iMA(NULL, MA_2_TF, MA_2_Period, 0, MA_2_Mode, MA_2_Price, i+2);

      MA2_0 = iMA(NULL, MA_2_TF, 1, 0, MA_2_Mode, MA_2_Price, i);

      MA2_Up_Buffer[y] = EMPTY_VALUE;
      MA2_Down_Buffer[y] = EMPTY_VALUE;

      if(MA2_1 < MA2_2) MA2_Up_Buffer[y] = Gap * P2_Position + 1.0;
      else MA2_Down_Buffer[y] = Gap * P2_Position + 1.0;

      if(MA2_1 < MA2_0) TextColor_2 = TextColorUp;
      else TextColor_2 = TextColorDown;
     }
     
//+------------------------------------------------------------------+

   if(MA_3_TF < Period()) MA_3_TF = Period();

   ArrayCopySeries(TimeArray_3,MODE_TIME,Symbol(),MA_3_TF); 

   for(i=0, y=0; y<=Limit; y++)
     {
      while(Time[y] < TimeArray_3[i]) i++; 

      MA3_1 = iMA(NULL, MA_3_TF, MA_3_Period, 0, MA_3_Mode, MA_3_Price, i);
      MA3_2 = iMA(NULL, MA_3_TF, MA_3_Period, 0, MA_3_Mode, MA_3_Price, i+1);
      MA3_3 = iMA(NULL, MA_3_TF, MA_3_Period, 0, MA_3_Mode, MA_3_Price, i+2);

      MA3_0 = iMA(NULL, MA_3_TF, 1, 0, MA_3_Mode, MA_3_Price, i);

      MA3_Up_Buffer[y] = EMPTY_VALUE;
      MA3_Down_Buffer[y] = EMPTY_VALUE;

      if(MA3_1 < MA3_2) MA3_Up_Buffer[y] = Gap * P3_Position + 1.0;
      else MA3_Down_Buffer[y] = Gap * P3_Position + 1.0;

      if(MA3_1 < MA3_0) TextColor_3 = TextColorUp;
      else TextColor_3 = TextColorDown;
     }
     
//+------------------------------------------------------------------+

   if(MA_4_TF < Period()) MA_4_TF = Period();

   ArrayCopySeries(TimeArray_4,MODE_TIME,Symbol(),MA_4_TF); 
   
   for(i=0, y=0; y<=Limit; y++)
     {
      while(Time[y] < TimeArray_4[i]) i++; 

      MA4_1 = iMA(NULL, MA_4_TF, MA_4_Period, 0, MA_4_Mode, MA_4_Price, i);
      MA4_2 = iMA(NULL, MA_4_TF, MA_4_Period, 0, MA_4_Mode, MA_4_Price, i+1);
      MA4_3 = iMA(NULL, MA_4_TF, MA_4_Period, 0, MA_4_Mode, MA_4_Price, i+2);

      MA4_0 = iMA(NULL, MA_4_TF, 1, 0, MA_4_Mode, MA_4_Price, i);

      MA4_Up_Buffer[y] = EMPTY_VALUE;
      MA4_Down_Buffer[y] = EMPTY_VALUE;

      if(MA4_1 < MA4_2) MA4_Up_Buffer[y] = Gap * P4_Position + 1.0;
      else MA4_Down_Buffer[y] = Gap * P4_Position + 1.0;

      if(MA4_1 < MA1_0) TextColor_4 = TextColorUp;
      else TextColor_4 = TextColorDown;
     }
     
   if(MA1_Up_Buffer[0]!=EMPTY_VALUE && MA2_Up_Buffer[0]!=EMPTY_VALUE && MA3_Up_Buffer[0]!=EMPTY_VALUE && MA4_Up_Buffer[0]!=EMPTY_VALUE && RangeAlert==TRUE)
     {
      if(!HavePlayedUp) { PlaySound("wait.wav"); HavePlayedUp = TRUE; }
     }
   else HavePlayedUp = FALSE;
   
   if(MA1_Down_Buffer[0]!=EMPTY_VALUE && MA2_Down_Buffer[0]!=EMPTY_VALUE && MA3_Down_Buffer[0]!=EMPTY_VALUE && MA4_Down_Buffer[0]!=EMPTY_VALUE && RangeAlert==TRUE)
     {
      if(!HavePlayedDown) { PlaySound("wait.wav"); HavePlayedDown = TRUE; }
     }
   else HavePlayedDown = FALSE;
   
//+------------------------------------------------------------------+

   if(ShowLabel) LabelSet(TextColor_1, TextColor_2, TextColor_3, TextColor_4);
   
//+------------------------------------------------------------------+

   if(RangeGraphic)
     {
      if(MA1_Up_Buffer[0]!=EMPTY_VALUE && MA2_Up_Buffer[0]!=EMPTY_VALUE && MA3_Up_Buffer[0]!=EMPTY_VALUE && MA4_Up_Buffer[0]!=EMPTY_VALUE) RangeGraphic("RectangleUp", RangeColorDown);
      else
        {
         if(ObjectFind("RectangleUp")==WindowFind(WindowExpertName())) ObjectDelete("RectangleUp");
        }
        
      if(MA1_Down_Buffer[0]!=EMPTY_VALUE && MA2_Down_Buffer[0]!=EMPTY_VALUE && MA3_Down_Buffer[0]!=EMPTY_VALUE && MA4_Down_Buffer[0]!=EMPTY_VALUE) RangeGraphic("RectangleDown", RangeColorUp);
      else
        {
         if(ObjectFind("RectangleDown")==WindowFind(WindowExpertName())) ObjectDelete("RectangleDown");
        }
        
     }
   else
     {
      if(ObjectFind("RectangleUp")==WindowFind(WindowExpertName())) ObjectDelete("RectangleUp");
      if(ObjectFind("RectangleDown")==WindowFind(WindowExpertName())) ObjectDelete("RectangleDown");
     }
     
//+------------------------------------------------------------------+

   return(0);
  }
  
//+------------------------------------------------------------------+

int LabelSet(color TextColor_1, color TextColor_2, color TextColor_3, color TextColor_4)
  {
   int i;
   double Price, ID = Time[0] - Time[1];
   string Name, Text_1, Text_2, Text_3;
   color TextColor;

   if(ShowLabel==TRUE)
     {
      for(i=1; i<=4; i++)
        {
         switch(i)
           {
            case 1: Text_1 = TimeFrame(MA_1_TF); Text_2 = Mode(MA_1_Mode); Text_3 = MA_1_Period;
                    Price = Gap * P1_Position + 1.0 + V_Shift;
                    TextColor = TextColor_1;
                    break;
                    
            case 2: Text_1 = TimeFrame(MA_2_TF); Text_2 = Mode(MA_2_Mode); Text_3 = MA_2_Period;
                    Price = Gap * P2_Position + 1.0 + V_Shift;
                    TextColor = TextColor_2;
                    break;
                    
            case 3: Text_1 = TimeFrame(MA_3_TF); Text_2 = Mode(MA_3_Mode); Text_3 = MA_3_Period;
                    Price = Gap * P3_Position + 1.0 + V_Shift;
                    TextColor = TextColor_3;
                    break;
                    
            case 4: Text_1 = TimeFrame(MA_4_TF); Text_2 = Mode(MA_4_Mode); Text_3 = MA_4_Period;
                    Price = Gap * P4_Position + 1.0 + V_Shift;
                    TextColor = TextColor_4;
           }
           
         Name = WindowFind(ShortName);

         NewBar(Name);

         if(ObjectFind("Text_1 " + Name + i)==-1) ObjectCreate("Text_1 " + Name + i, OBJ_TEXT, WindowFind(ShortName), iTime(NULL, 0, 0) + ID * H_Shift, Price);
         ObjectSetText("Text_1 " + Name + i, Text_1, 8, "Arial Bold", TextColor);

         if(ObjectFind("Text_2 " + Name + i)==-1) ObjectCreate("Text_2 " + Name + i, OBJ_TEXT, WindowFind(ShortName), iTime(NULL, 0, 0) + 1.5 * ID * H_Shift, Price);
         ObjectSetText("Text_2 " + Name + i, Text_2, 8, "Arial Bold", TextColor);

         if(ObjectFind("Text_3 " + Name + i)==-1) ObjectCreate("Text_3 " + Name + i, OBJ_TEXT, WindowFind(ShortName), iTime(NULL, 0, 0) + 2.0 * ID * H_Shift, Price);
         ObjectSetText("Text_3 " + Name + i, Text_3, 8, "Arial Bold", TextColor);
        }
     }
   return(0);
  }
  
//+------------------------------------------------------------------+

string TimeFrame(int TF)
  {
   if(TF == 1     || (TF == 0 && Period() == PERIOD_M1 )) return ("M1" );
   if(TF == 5     || (TF == 0 && Period() == PERIOD_M5 )) return ("M5" );
   if(TF == 15    || (TF == 0 && Period() == PERIOD_M15)) return ("M15");
   if(TF == 30    || (TF == 0 && Period() == PERIOD_M30)) return ("M30");
   if(TF == 60    || (TF == 0 && Period() == PERIOD_H1 )) return ("H1" );
   if(TF == 240   || (TF == 0 && Period() == PERIOD_H4 )) return ("H4" );
   if(TF == 1440  || (TF == 0 && Period() == PERIOD_D1 )) return ("D1" );
   if(TF == 10080 || (TF == 0 && Period() == PERIOD_W1 )) return ("W1" );
   if(TF == 43200 || (TF == 0 && Period() == PERIOD_MN1)) return ("MN" );
  }
  
//+------------------------------------------------------------------+

string Mode(int MA_Mode)
  {
   switch(MA_Mode)
     {
      case 0 : return("SMA");
               break;
     
      case 1 : return("EMA");
               break;
               
      case 2 : return("SSMA");
               break;
               
      case 3 : return("LWMA");
      //----
      default : Alert(WindowExpertName()+" ERROR : Please enter the correct value for MA_Mode !"); return(0);
     }
  }
  
//+------------------------------------------------------------------+

bool NewBar(string Name)
  {
   static int PrevTime =0;
   if(PrevTime==iTime(NULL,0,0)) return(FALSE);
   PrevTime=iTime(NULL,0,0);
   for(int i=1; i<=4; i++)
     {
      ObjectDelete("Text_1 " + Name + i);
      ObjectDelete("Text_2 " + Name + i);
      ObjectDelete("Text_3 " + Name + i);
     }
   return(TRUE);
  }
  
//+------------------------------------------------------------------+

void RangeGraphic(string Name, color Color)
  {
   datetime Time_1 = iTime(Symbol(), Period(), Bars);
   datetime Time_2 = iTime(Symbol(), Period(), 0) + TimeCurrent();
   double Price_1 = 1;
   double Price_2 = 4;
   
   ObjectCreate(Name, OBJ_RECTANGLE, WindowFind(WindowExpertName()), Time_1, Price_1, Time_2, Price_2);
   
   ObjectSet(Name, OBJPROP_COLOR, Color);
  }
  
//+------------------------------------------------------------------+

0, 0) + 1.5 * ID * H_Shift, Price);
         ObjectSetText("Text_2 " + Name + i, Text_2, 8, "Arial Bold", TextColor);

         if(ObjectFind("Text_3 " + Name + i)==-1) ObjectCreate("Text_3 " + Name + i, OBJ_TEXT, WindowFind(ShortName), iTime(NULL, 0, 0) + 2.0 * ID * H_Shift, Price);
         ObjectSetText("Text_3 " + Name + i, Text_3, 8, "Arial Bold", TextColor);
        }
     }
   return(0);
  }
  
//+------------------------------------------------------------------+

string TimeFrame(int TF)
  {
   if(TF == 1     || (TF == 0 && Period() == PERIOD_M1 )) return ("M1" );
   if(TF == 5     || (TF == 0 && Period() == PERIOD_M5 )) return ("M5" );
   if(TF == 15    || (TF == 0 && Period() == PERIOD_M15)) return ("M15");
   if(TF == 30    || (TF == 0 && Period() == PERIOD_M30)) return ("M30");
   if(TF == 60    || (TF == 0 && Period() == PERIOD_H1 )) return ("H1" );
   if(TF == 240   || (TF == 0 && Period() == PERIOD_H4 )) return ("H4" );
   if(TF == 1440  || (TF == 0 && Period() == PERIOD_D1 )) return ("D1" );
   if(TF == 10080 || (TF == 0 && Period() == PERIOD_W1 )) return ("W1" );
   if(TF == 43200 || (TF == 0 && Period() == PERIOD_MN1)) return ("MN" );
  }
  
//+------------------------------------------------------------------+

string Mode(int MA_Mode)
  {
   switch(MA_Mode)
     {
      case 0 : return("SMA");
               break;
     
      case 1 : return("EMA");
               break;
               
      case 2 : return("SSMA");
               break;
               
      case 3 : return("LWMA");
      //----
      default : Alert(WindowExpertName()+" ERROR : Please enter the correct value for MA_Mode !"); return(0);
     }
  }
  
//+------------------------------------------------------------------+

void Label_Create_And_Set(string Name, string Text,int FontSize, string FontName, color TextColor, bool Back, int XD, int YD, int CR)
  {
   if(ObjectFind(Name)==-1) ObjectCreate(Name, OBJ_LABEL, 0, 0, 0, 0, 0);

   ObjectSet(Name, OBJPROP_XDISTANCE, XD);
   ObjectSet(Name, OBJPROP_YDISTANCE, YD);
   ObjectSet(Name, OBJPROP_CORNER, CR);
   ObjectSet(Name, OBJPROP_COLOR, TextColor);
   ObjectSet(Name, OBJPROP_BACK, Back);  
   ObjectSetText(Name, Text, FontSize, FontName);
  }
  
//+------------------------------------------------------------------+
     
void ShowIntro()
  {
   int i = 1;

   Label_Create_And_Set("Intro_"+i, "g", 1500, "Webdings", C'015, 015, 015', FALSE, 1, 1, 1);                                        i++;
   Label_Create_And_Set("Intro_"+i, "Внимание!", 16, "Arial", Red, FALSE, 750, 200, 1);                                              i++;
   Label_Create_And_Set("Intro_"+i, "Услуги профессионального трейдера-программиста", 16, "Arial", DeepSkyBlue, FALSE, 550, 235, 1); i++;
   Label_Create_And_Set("Intro_"+i, "по разработке индикаторов, скриптов и МТС.", 16, "Arial", DeepSkyBlue, FALSE, 580, 270, 1);     i++;
   Label_Create_And_Set("Intro_"+i, "Только серьезное сотрудничество.", 16, "Arial", DeepSkyBlue, FALSE, 625, 305, 1);               i++;
   Label_Create_And_Set("Intro_"+i, "Цены от 300 €", 16, "Arial", DeepSkyBlue, FALSE, 725, 340, 1);                                  i++;
   Label_Create_And_Set("Intro_"+i, "E-mail : Alex5757000@yandex.ru", 16, "Arial", DeepSkyBlue, FALSE, 640, 375, 1);                 i++;
   Label_Create_And_Set("Intro_"+i, "Киев UA", 16, "Arial", DeepSkyBlue, FALSE, 760, 410, 1);                                        i++;
   Label_Create_And_Set("Intro_"+i, "Установите ShowIntro = FALSE.", 12, "Arial", Lime, FALSE, 680, 445, 1);                         i++;
  }
  
//+------------------------------------------------------------------+

bool NewBar(string Name)
  {
   static int PrevTime =0;
   if(PrevTime==iTime(NULL,0,0)) return(FALSE);
   PrevTime=iTime(NULL,0,0);
   for(int i=1; i<=4; i++)
     {
      ObjectDelete("Text_1 " + Name + i);
      ObjectDelete("Text_2 " + Name + i);
      ObjectDelete("Text_3 " + Name + i);
     }
   return(TRUE);
  }
  
//+------------------------------------------------------------------+

void RangeGraphic(string Name, color Color)
  {
   datetime Time_1 = iTime(Symbol(), Period(), Bars);
   datetime Time_2 = iTime(Symbol(), Period(), 0) + TimeCurrent();
   double Price_1 = 1;
   double Price_2 = 4;
   
   ObjectCreate(Name, OBJ_RECTANGLE, WindowFind(WindowExpertName()), Time_1, Price_1, Time_2, Price_2);
   
   ObjectSet(Name, OBJPROP_COLOR, Color);
  }
  
//+------------------------------------------------------------------+

