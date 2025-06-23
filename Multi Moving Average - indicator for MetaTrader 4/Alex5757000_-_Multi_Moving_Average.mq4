//+------------------------------------------------------------------+
//|                           Alex5757000 - Multi Moving Average.mq4 |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net" // http://www.mql4.com/ru/users/Alex5757000
//----
#property indicator_separate_window
#property indicator_minimum 1.0
#property indicator_maximum 4.0
#property indicator_buffers 8
#property indicator_color1  Blue
#property indicator_color2  Red
#property indicator_color3  Blue
#property indicator_color4  Red
#property indicator_color5  Blue
#property indicator_color6  Red
#property indicator_color7  Blue
#property indicator_color8  Red
//----
extern string MA1            = "The input parameters of the 1st Moving Average";
//----
extern int    MA1_Period     = 13;                // Averaging period.
extern int    MA1_Mode       = MODE_EMA;          // Averaging method.
extern int    MA1_Price      = PRICE_MEDIAN;      // The type of the price used for calculaton of Moving Average.
//----
extern string MA2            = "The input parameters of the 2nd Moving Average";
//----
extern int    MA2_Period     = 34;
extern int    MA2_Mode       = MODE_EMA;
extern int    MA2_Price      = PRICE_MEDIAN;
//----
extern string MA3            = "The input parameters of the 3rd Moving Average";
//----
extern int    MA3_Period     = 55;
extern int    MA3_Mode       = MODE_EMA;
extern int    MA3_Price      = PRICE_MEDIAN;
//----
extern string MA4            = "The input parameters of the 4th Moving Average";
//----
extern int    MA4_Period     = 89;
extern int    MA4_Mode       = MODE_EMA;
extern int    MA4_Price      = PRICE_MEDIAN;
//----
extern string Visual         = "Display parameters";
//----
extern string Wingdings      = "0 -rectangles, 1 - arrows";
//----
extern int    Bar_Wingdings  = 0;
extern int    Bar_Width      = 0;
extern color  Bar_Color_Up   = DeepSkyBlue;
extern color  Bar_Color_Down = Red;
//----
extern int    P1_Position    = 4;
extern int    P2_Position    = 3;
extern int    P3_Position    = 2;
extern int    P4_Position    = 1;
//----
extern double Gap            = 0.6;
//----
extern string Set_Label      = "Labels setting";
//----
extern bool   Show_Label     = true;
//----
extern string V_Label        = "Vertical shift for text labels";
//----
extern double V_Shift        = 0.5;
//----
extern string H_Label        = "Horizontal shift for text labels";
//----
extern int    H_Shift        = 20;
//----
extern string UP_DN          = "Moving average direction relative to the price: above/below";
extern color  Text_Color_UP    = DeepSkyBlue;
extern color  Text_Color_Down  = Red;
//+------------------------------------------------------------------+
string Label ="", Short_Name;
//----
double MA1_UP_Buffer[];
double MA1_DN_Buffer[];
double MA2_UP_Buffer[];
double MA2_DN_Buffer[];
double MA3_UP_Buffer[];
double MA3_DN_Buffer[];
double MA4_UP_Buffer[];
double MA4_DN_Buffer[];
//----
double MA0_Buffer_0;
//----
double MA1_Buffer_1;
double MA1_Buffer_0;
double MA2_Buffer_1;
double MA2_Buffer_0;
double MA3_Buffer_1;
double MA3_Buffer_0;
double MA4_Buffer_1;
double MA4_Buffer_0;
//----
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   //----
   int Wingdings_UP, Wingdings_DOWN;
   //----
   if(Bar_Wingdings==0) { Wingdings_UP = 167; Wingdings_DOWN = 167; }
   if(Bar_Wingdings==1) { Wingdings_UP = 217; Wingdings_DOWN = 218; }
   if(Bar_Wingdings!=0 && Bar_Wingdings!=1) { Alert("Please enter the correct value for Bar_Wingdings ! (0-3)"); return; }
   //----
   SetIndexStyle (0, DRAW_ARROW, STYLE_SOLID, Bar_Width, Bar_Color_Up);
   SetIndexArrow (0, Wingdings_UP);
   SetIndexBuffer(0, MA1_UP_Buffer);
   SetIndexEmptyValue(0, 0.0);
   SetIndexStyle (1, DRAW_ARROW, STYLE_SOLID, Bar_Width, Bar_Color_Down);
   SetIndexArrow (1, Wingdings_DOWN);
   SetIndexBuffer(1, MA1_DN_Buffer);
   SetIndexEmptyValue(1, 0.0);
   SetIndexStyle (2, DRAW_ARROW, STYLE_SOLID, Bar_Width, Bar_Color_Up);
   SetIndexArrow (2, Wingdings_UP);
   SetIndexBuffer(2, MA2_UP_Buffer);
   SetIndexEmptyValue(2, 0.0);
   SetIndexStyle (3, DRAW_ARROW, STYLE_SOLID, Bar_Width, Bar_Color_Down);
   SetIndexArrow (3, Wingdings_DOWN);
   SetIndexBuffer(3, MA2_DN_Buffer);
   SetIndexEmptyValue(3, 0.0);
   SetIndexStyle (4, DRAW_ARROW, STYLE_SOLID, Bar_Width, Bar_Color_Up);
   SetIndexArrow (4, Wingdings_UP);
   SetIndexBuffer(4, MA3_UP_Buffer);
   SetIndexEmptyValue(4, 0.0);
   SetIndexStyle (5, DRAW_ARROW, STYLE_SOLID, Bar_Width, Bar_Color_Down);
   SetIndexArrow (5, Wingdings_DOWN);
   SetIndexBuffer(5, MA3_DN_Buffer);
   SetIndexEmptyValue(5, 0.0);
   SetIndexStyle (6, DRAW_ARROW, STYLE_SOLID, Bar_Width, Bar_Color_Up);
   SetIndexArrow (6, Wingdings_UP);
   SetIndexBuffer(6, MA4_UP_Buffer);
   SetIndexEmptyValue(6, 0.0);
   SetIndexStyle (7, DRAW_ARROW, STYLE_SOLID, Bar_Width, Bar_Color_Down);
   SetIndexArrow (7, Wingdings_DOWN);
   SetIndexBuffer(7, MA4_DN_Buffer);
   SetIndexEmptyValue(7, 0.0);
   SetIndexLabel(0, "1_Buffer_UP");
   SetIndexLabel(1, "1_Buffer_DN");
   SetIndexLabel(2, "2_Buffer_UP");
   SetIndexLabel(3, "2_Buffer_DN");
   SetIndexLabel(4, "3_Buffer_UP");
   SetIndexLabel(5, "3_Buffer_DN");
   SetIndexLabel(6, "4_Buffer_UP");
   SetIndexLabel(7, "4_Buffer_DN");
   IndicatorDigits(0);
   Short_Name = "Alex5757000 - MTF Moving Average";
   IndicatorShortName(Short_Name);
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
   int Counted_Bars = IndicatorCounted(), i;
   if(Counted_Bars<0) return(-1);
   if(Counted_Bars>0) Counted_Bars--;
   int Limit = Bars - Counted_Bars;
   if(Counted_Bars==0) Limit--;
   color Text_Color_1, Text_Color_2, Text_Color_3, Text_Color_4;
   //----
   for(i=Limit; i>=0; i--)
     {
      MA0_Buffer_0 = iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_MEDIAN, i);
      //----
      MA1_Buffer_0 = iMA(NULL, 0, MA1_Period, 0, MA1_Mode, MA1_Price, i);
      MA1_Buffer_1 = iMA(NULL, 0, MA1_Period, 0, MA1_Mode, MA1_Price, i+1);
      MA2_Buffer_0 = iMA(NULL, 0, MA2_Period, 0, MA2_Mode, MA2_Price, i);
      MA2_Buffer_1 = iMA(NULL, 0, MA2_Period, 0, MA2_Mode, MA2_Price, i+1);
      MA3_Buffer_0 = iMA(NULL, 0, MA3_Period, 0, MA3_Mode, MA3_Price, i);
      MA3_Buffer_1 = iMA(NULL, 0, MA3_Period, 0, MA3_Mode, MA3_Price, i+1);
      MA4_Buffer_0 = iMA(NULL, 0, MA4_Period, 0, MA4_Mode, MA4_Price, i);
      MA4_Buffer_1 = iMA(NULL, 0, MA4_Period, 0, MA4_Mode, MA4_Price, i+1);
      
      MA1_UP_Buffer[i] = EMPTY_VALUE;
      MA1_DN_Buffer[i] = EMPTY_VALUE;
      
      if(MA1_Buffer_0 < MA1_Buffer_1) MA1_DN_Buffer[i] = Gap * P1_Position + 1.0;
      else                            MA1_UP_Buffer[i] = Gap * P1_Position + 1.0;
      if(MA1_Buffer_0 < MA0_Buffer_0) Text_Color_1 = Text_Color_UP;
      else                            Text_Color_1 = Text_Color_Down;
      //----
      MA2_UP_Buffer[i] = EMPTY_VALUE;
      MA2_DN_Buffer[i] = EMPTY_VALUE;
      
      if(MA2_Buffer_0 < MA2_Buffer_1) MA2_DN_Buffer[i] = Gap * P2_Position + 1.0;
      else                            MA2_UP_Buffer[i] = Gap * P2_Position + 1.0;
      if(MA2_Buffer_0 < MA0_Buffer_0) Text_Color_2 = Text_Color_UP;
      else                            Text_Color_2 = Text_Color_Down;
      //----
      MA3_UP_Buffer[i] = EMPTY_VALUE;
      MA3_DN_Buffer[i] = EMPTY_VALUE;
      
      if(MA3_Buffer_0 < MA3_Buffer_1) MA3_DN_Buffer[i] = Gap * P3_Position + 1.0;
      else                            MA3_UP_Buffer[i] = Gap * P3_Position + 1.0;
      if(MA3_Buffer_0 < MA0_Buffer_0) Text_Color_3 = Text_Color_UP;
      else                            Text_Color_3 = Text_Color_Down;
      //----
      MA4_UP_Buffer[i] = EMPTY_VALUE;
      MA4_DN_Buffer[i] = EMPTY_VALUE;
      
      if(MA4_Buffer_0 < MA4_Buffer_1) MA4_DN_Buffer[i] = Gap * P4_Position + 1.0;
      else                            MA4_UP_Buffer[i] = Gap * P4_Position + 1.0;
      if(MA4_Buffer_0 < MA0_Buffer_0) Text_Color_4 = Text_Color_UP;
      else                            Text_Color_4 = Text_Color_Down;
      //----
      //----
      LabelSet(Text_Color_1, Text_Color_2, Text_Color_3, Text_Color_4);
      //----
     }   
//----
   return(0);
  }
//+------------------------------------------------------------------+
int LabelSet(color Text_Color_1, color Text_Color_2, color Text_Color_3, color Text_Color_4)
  {
   //----
   int i;
   double Price, ID =Time[0] - Time[1];
   string Name, Text;
   color Text_Color;
   //----
   if(Show_Label==TRUE)
     {
      for(i=1; i<=4; i++)
        {
         switch(i)
           {
            case 1: Text       = Time_Frame() + " " + Mode(MA1_Mode) + " " + "(" + MA1_Period + ")";
                    Price      = Gap * P1_Position + 1.0 + V_Shift;
                    Text_Color = Text_Color_1;
                    break;
            case 2: Text       = Time_Frame() + " " + Mode(MA2_Mode) + " " + "(" + MA2_Period + ")";
                    Price      = Gap * P2_Position + 1.0 + V_Shift;
                    Text_Color = Text_Color_2;
                    break;
            case 3: Text       = Time_Frame() + " " + Mode(MA3_Mode) + " " + "(" + MA3_Period + ")";
                    Price      = Gap * P3_Position + 1.0 + V_Shift;
                    Text_Color = Text_Color_3;
                    break;
            case 4: Text       = Time_Frame() + " " + Mode(MA4_Mode) + " " + "(" + MA4_Period + ")";
                    Price      = Gap * P4_Position + 1.0 + V_Shift;
                    Text_Color = Text_Color_4;
           }
           
         Name = WindowFind(Short_Name);
         ObjectDelete (Name + i);
         ObjectCreate (Name + i, OBJ_TEXT, WindowFind(Short_Name), iTime(NULL, 0, 0) + ID * H_Shift, Price);
         ObjectSetText(Name + i, Text, 8, "Arial Bold", Text_Color);
        }
     }
   return(0);
  }       
//----
string Time_Frame()
  {
   if (Period() == PERIOD_M1 ) return ("M1");
   if (Period() == PERIOD_M5 ) return ("M5");
   if (Period() == PERIOD_M15) return ("M15");
   if (Period() == PERIOD_M30) return ("M30");
   if (Period() == PERIOD_H1 ) return ("H1");
   if (Period() == PERIOD_H4 ) return ("H4");
   if (Period() == PERIOD_D1 ) return ("D1");
   if (Period() == PERIOD_W1 ) return ("W1");
   if (Period() == PERIOD_MN1) return ("MN");
  }
//----
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
     }
  }
//+------------------------------------------------------------------+