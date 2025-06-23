//+------------------------------------------------------------------+
//|                                                Levels_A_Vlad.mq4 |
//|                                                   Andrei Andreev |
//|                                             http://www.andand.ru |
//+------------------------------------------------------------------+

// BASED ON:
//+------------------------------------------------------------------+
//|                                                   ^X_Sensors.mq4 |
//|                                                    Version 2.0.1 |
//|------------------------------------------------------------------|
//|                     Copyright © 2007, Mr.WT, Senior Linux Hacker |
//|                                     http://w-tiger.narod.ru/wk2/ |
//+------------------------------------------------------------------+
#property copyright "Andrei Andreev"
#property link      "http://www.andand.ru"

#property indicator_chart_window
extern int _Mode=2;
extern int _Shift = 100;
extern color _R_Color = Crimson;
extern color _S_Color = Gold;

int _N_Time,  _My_Period,  ObjectId;
string OBJECT_PREFIX = "LEVELS";
//-------------------------------------------------------------------------------------------
int init() {

_My_Period=PERIOD_D1;
if (Period()<PERIOD_M30) _My_Period=PERIOD_H1;
if (Period()>=PERIOD_H4) _My_Period=PERIOD_W1;
if (Period()>=PERIOD_W1) _My_Period=PERIOD_MN1;


_N_Time = 0;

ObjectCreate("S1 line", OBJ_TREND, 0, Time[_Shift], 0, Time[0], 0);
ObjectCreate("S2 line", OBJ_TREND, 0, Time[_Shift], 0, Time[0], 0);
ObjectCreate("S3 line", OBJ_TREND, 0, Time[_Shift], 0, Time[0], 0);
ObjectCreate("S4 line", OBJ_TREND, 0, Time[_Shift], 0, Time[0], 0);
ObjectCreate("S5 line", OBJ_TREND, 0, Time[_Shift], 0, Time[0], 0);
ObjectCreate("R1 line", OBJ_TREND, 0, Time[_Shift], 0, Time[0], 0);
ObjectCreate("R2 line", OBJ_TREND, 0, Time[_Shift], 0, Time[0], 0);
ObjectCreate("R3 line", OBJ_TREND, 0, Time[_Shift], 0, Time[0], 0);
ObjectCreate("R4 line", OBJ_TREND, 0, Time[_Shift], 0, Time[0], 0);
ObjectCreate("R5 line", OBJ_TREND, 0, Time[_Shift], 0, Time[0], 0);


ObjectSet("S1 line", OBJPROP_RAY, 1);
ObjectSet("S1 line", OBJPROP_STYLE, STYLE_DASH);
ObjectSet("S1 line", OBJPROP_COLOR, _S_Color);

ObjectSet("S2 line", OBJPROP_RAY, 1);
ObjectSet("S2 line", OBJPROP_STYLE, STYLE_DASH);
ObjectSet("S2 line", OBJPROP_COLOR, _S_Color);

ObjectSet("S3 line", OBJPROP_RAY, 1);
ObjectSet("S3 line", OBJPROP_STYLE, STYLE_DASH);
ObjectSet("S3 line", OBJPROP_COLOR, _S_Color);

ObjectSet("S4 line", OBJPROP_RAY, 1);
ObjectSet("S4 line", OBJPROP_STYLE, STYLE_DASH);
ObjectSet("S4 line", OBJPROP_COLOR, _S_Color);

ObjectSet("S5 line", OBJPROP_RAY, 1);
ObjectSet("S5 line", OBJPROP_STYLE, STYLE_DASH);
ObjectSet("S5 line", OBJPROP_COLOR, _S_Color);

ObjectSet("R1 line", OBJPROP_RAY, 1);
ObjectSet("R1 line", OBJPROP_STYLE, STYLE_DASH);
ObjectSet("R1 line", OBJPROP_COLOR, _R_Color);

ObjectSet("R2 line", OBJPROP_RAY, 1);
ObjectSet("R2 line", OBJPROP_STYLE, STYLE_DASH);
ObjectSet("R2 line", OBJPROP_COLOR, _R_Color);

ObjectSet("R3 line", OBJPROP_RAY, 1);
ObjectSet("R3 line", OBJPROP_STYLE, STYLE_DASH);
ObjectSet("R3 line", OBJPROP_COLOR, _R_Color);

ObjectSet("R4 line", OBJPROP_RAY, 1);
ObjectSet("R4 line", OBJPROP_STYLE, STYLE_DASH);
ObjectSet("R4 line", OBJPROP_COLOR, _R_Color);

ObjectSet("R5 line", OBJPROP_RAY, 1);
ObjectSet("R5 line", OBJPROP_STYLE, STYLE_DASH);
ObjectSet("R5 line", OBJPROP_COLOR, _R_Color);




ObjectCreate("R1 label", OBJ_TEXT, 0, Time[0], 0);
ObjectCreate("R2 label", OBJ_TEXT, 0, Time[0], 0);
ObjectCreate("R3 label", OBJ_TEXT, 0, Time[0], 0);
ObjectCreate("R4 label", OBJ_TEXT, 0, Time[0], 0);
ObjectCreate("R5 label", OBJ_TEXT, 0, Time[0], 0);
ObjectCreate("S1 label", OBJ_TEXT, 0, Time[0], 0);
ObjectCreate("S2 label", OBJ_TEXT, 0, Time[0], 0);
ObjectCreate("S3 label", OBJ_TEXT, 0, Time[0], 0);
ObjectCreate("S4 label", OBJ_TEXT, 0, Time[0], 0);
ObjectCreate("S5 label", OBJ_TEXT, 0, Time[0], 0);


ObjectId = 0;
return(0);
}
//-------------------------------------------------------------------------------------------
int deinit() {

Comment("");
ObjectDelete("R1 label");
ObjectDelete("R1 line");
ObjectDelete("R2 label");
ObjectDelete("R2 line");
ObjectDelete("R3 label");
ObjectDelete("R3 line");
ObjectDelete("R4 label");
ObjectDelete("R4 line");
ObjectDelete("R5 label");
ObjectDelete("R5 line");
ObjectDelete("S1 label");
ObjectDelete("S1 line");
ObjectDelete("S2 label");
ObjectDelete("S2 line");
ObjectDelete("S3 label");
ObjectDelete("S3 line");
ObjectDelete("S4 label");
ObjectDelete("S4 line");
ObjectDelete("S5 label");
ObjectDelete("S5 line");

ObDeleteObjectsByPrefix(OBJECT_PREFIX);
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start() {

if ( _N_Time == Time[0] ) return(0);

double close, high, low, koeff1, koeff2,P, R1, R2, R3, R4, R5, S1, S2, S3, S4,S5;
double _rates[][6];

ArrayCopyRates(_rates, NULL, _My_Period);
int err = GetLastError();
if(err == 4066) {
  Sleep(1000);
  if(iClose(NULL, _My_Period, 0) != Close[0]) {
    Sleep(1000);
    return(0);
  }
}
close = _rates[1][4];
high = _rates[1][3];
low = _rates[1][2];

if (_Mode==1)
    {
    koeff1=0.146;
    koeff2=0.236;
    Comment ("\nУменьшенный ценовой диапазон");
    }
if (_Mode==2)
    {
    koeff1=0.236;
    koeff2=0.382;
    Comment ("\nНормальный ценовой диапазон");
    }
if (_Mode==3)
    {
    koeff1=0.382;
    koeff2=0.618;
    Comment ("\nРасширенный ценовой диапазон"); 
    }       

S1 =close-((high-low)*koeff1)/2;
R1 =((high-low)*koeff1)/2+close ;

S2 =S1-((high-low)*koeff2);
S3 =S1-((high-low)*koeff2)*2;
S4 =S3-(R1-S1);
S5 =S4-((high-low)*koeff2);

R2 =((high-low)*koeff2)+R1;
R3 = R1+2*((high-low)*koeff2);
R4 = R3 + (R1 - S1); 
R5 = R4 + ((high-low)*koeff2);
 

string s1,s2,s3,s4,s5,r1,r2,r3,r4,r5;
if(Point == 0.01) {
  s1 = DoubleToStr(S1, 2);
  s2 = DoubleToStr(S2, 2);
  s3 = DoubleToStr(S3, 2);
  s4 = DoubleToStr(S4, 2);
  s5 = DoubleToStr(S5, 2);
  r1 = DoubleToStr(R1, 2);
  r2 = DoubleToStr(R2, 2);
  r3 = DoubleToStr(R3, 2);
  r4 = DoubleToStr(R4, 2);
  r5 = DoubleToStr(R5, 2);
 
} else {
  s1 = DoubleToStr(S1, 4);
  s2 = DoubleToStr(S2, 4);
  s3 = DoubleToStr(S3, 4);
  s4 = DoubleToStr(S4, 4);
  s5 = DoubleToStr(S5, 4);
  r1 = DoubleToStr(R1, 4);
  r2 = DoubleToStr(R2, 4);
  r3 = DoubleToStr(R3, 4);
  r4 = DoubleToStr(R4, 4);
  r5 = DoubleToStr(R5, 4);
  
}
//---- Pivot Lines
ObjectSetText("R1 label", "                          Сопротивление1 "+r1+"", 8, "Fixedsys", _R_Color);
ObjectSetText("R2 label", "                          Сопротивление2 "+r2+"", 8, "Fixedsys", _R_Color);
ObjectSetText("R3 label", "                          Сопротивление3 "+r3+"", 8, "Fixedsys", _R_Color);
ObjectSetText("R4 label", "                          Сопротивление4 "+r4+"", 8, "Fixedsys", _R_Color);
ObjectSetText("R5 label", "                          Сопротивление5 "+r5+"", 8, "Fixedsys", _R_Color);
ObjectSetText("S1 label", "                        Поддержка1 "+s1+"", 8, "Fixedsys", _S_Color);
ObjectSetText("S2 label", "                        Поддержка2 "+s2+"", 8, "Fixedsys", _S_Color);
ObjectSetText("S3 label", "                        Поддержка3 "+s3+"", 8, "Fixedsys", _S_Color);
ObjectSetText("S4 label", "                        Поддержка4 "+s4+"", 8, "Fixedsys", _S_Color);
ObjectSetText("S5 label", "                        Поддержка5 "+s5+"", 8, "Fixedsys", _S_Color);


ObjectMove("R1 label", 0, Time[0], R1);
ObjectMove("R2 label", 0, Time[0], R2);
ObjectMove("R3 label", 0, Time[0], R3);
ObjectMove("R4 label", 0, Time[0], R4);
ObjectMove("R5 label", 0, Time[0], R5);

ObjectMove("S1 label", 0, Time[0], S1);
ObjectMove("S2 label", 0, Time[0], S2);
ObjectMove("S3 label", 0, Time[0], S3);
ObjectMove("S4 label", 0, Time[0], S4);
ObjectMove("S5 label", 0, Time[0], S5);

ObjectMove("S1 line", 0, Time[_Shift], S1);
ObjectMove("S1 line", 1, Time[0], S1);

ObjectMove("S2 line", 0, Time[_Shift], S2);
ObjectMove("S2 line", 1, Time[0], S2);

ObjectMove("S3 line", 0, Time[_Shift], S3);
ObjectMove("S3 line", 1, Time[0], S3);

ObjectMove("S4 line", 0, Time[_Shift], S4);
ObjectMove("S4 line", 1, Time[0], S4);

ObjectMove("S5 line", 0, Time[_Shift], S5);
ObjectMove("S5 line", 1, Time[0], S5);



ObjectMove("R1 line", 0, Time[_Shift], R1);
ObjectMove("R1 line", 1, Time[0], R1);

ObjectMove("R2 line", 0, Time[_Shift], R2);
ObjectMove("R2 line", 1, Time[0], R2);

ObjectMove("R3 line", 0, Time[_Shift], R3);
ObjectMove("R3 line", 1, Time[0], R3);

ObjectMove("R4 line", 0, Time[_Shift], R4);
ObjectMove("R4 line", 1, Time[0], R4);

ObjectMove("R5 line", 0, Time[_Shift], R5);
ObjectMove("R5 line", 1, Time[0], R5);
//====
   
_N_Time = Time[0];
//---- End Of Program
return(0);
}
//+------------------------------------------------------------------+



void ObDeleteObjectsByPrefix(string Prefix)
  {
   int L = StringLen(Prefix);
   int i = 0; 
   while(i < ObjectsTotal())
     {
       string ObjName = ObjectName(i);
       if(StringSubstr(ObjName, 0, L) != Prefix) 
         { 
           i++; 
           continue;
         }
       ObjectDelete(ObjName);
     }
  }
//-------------------------------------------------------------------------------------------

