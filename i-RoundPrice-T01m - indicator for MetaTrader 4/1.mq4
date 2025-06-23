//+------------------------------------------------------------------+
//|                                            i-RoundPrice-T01m.mq4 |
//|          25.07.2006  Translated on MT4 by Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//+------------------------------------------------------------------+
/*[[
	Name := RoundPrice
	Author := Copyright © 2006, HomeSoft Tartan Corp.
	Link := spiky@transkeino.ru
	Separate Window := No
	First Color := Lime
	First Draw Type := Line
	First Symbol := 217
	Use Second Data := Yes
	Second Color := Red
	Second Draw Type := Line
	Second Symbol := 218
]]*/
#property copyright "Copyright © 2006, HomeSoft Tartan Corp."
#property link      "spiky@transkeino.ru"
//----
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Aqua
#property indicator_color2 Red
#property indicator_color3 MediumTurquoise
#property indicator_color4 DarkOrange
#property indicator_color5 DodgerBlue
#property indicator_color6 Chocolate
#property indicator_color7 Blue
#property indicator_color8 Gold
//------- Внешние параметры индикатора -------------------------------
extern int t3_period1=5;
extern double b1=0.2;
extern int t3_period2=5;
extern double b2=0.3;
extern int t3_period3=5;
extern double b3=0.4;
extern int t3_period4=5;
extern double b4=0.5;
extern int mBar=300;
//------- Глобальные переменные индикатора ---------------------------
double dBuf0[], dBuf1[];
double dBuf2[], dBuf3[];
double dBuf4[], dBuf5[];
double dBuf6[], dBuf7[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  void init()
  {
   SetIndexBuffer    (0, dBuf0);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexStyle     (0, DRAW_LINE,1);
   SetIndexBuffer    (1, dBuf1);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexStyle     (1, DRAW_LINE,1);
   SetIndexBuffer    (2, dBuf2);
   SetIndexEmptyValue(2, EMPTY_VALUE);
   SetIndexStyle     (2, DRAW_LINE,2);
   SetIndexBuffer    (3, dBuf3);
   SetIndexEmptyValue(3, EMPTY_VALUE);
   SetIndexStyle     (3, DRAW_LINE,2);
   SetIndexBuffer    (4, dBuf4);
   SetIndexEmptyValue(4, EMPTY_VALUE);
   SetIndexStyle     (4, DRAW_LINE,3);
   SetIndexBuffer    (5, dBuf5);
   SetIndexEmptyValue(5, EMPTY_VALUE);
   SetIndexStyle     (5, DRAW_LINE,3);
   SetIndexBuffer    (6, dBuf6);
   SetIndexEmptyValue(6, EMPTY_VALUE);
   SetIndexStyle     (6, DRAW_LINE,4);
   SetIndexBuffer    (7, dBuf7);
   SetIndexEmptyValue(7, EMPTY_VALUE);
   SetIndexStyle     (7, DRAW_LINE,4);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
  void start()
  {
   bool   ft1=True;
   double e11, e21, e31, e41, e51, e61, c11, c21, c31, c41, n1, w11, w21, b21, b31;
   double t31[];
   int    LoopBegin1, shift1;
   bool   ft2=True;
   double e12, e22, e32, e42, e52, e62, c12, c22, c32, c42, n2, w12, w22, b22, b32;
   double t32[];
   int    LoopBegin2, shift2;
   bool   ft3=True;
   double e13, e23, e33, e43, e53, e63, c13, c23, c33, c43, n3, w13, w23, b23, b33;
   double t33[];
   int    LoopBegin3, shift3;
   bool   ft4=True;
   double e14, e24, e34, e44, e54, e64, c14, c24, c34, c44, n4, w14, w24, b24, b34;
   double t34[];
   int    LoopBegin4, shift4;
   if (mBar==0) LoopBegin1=Bars-t3_period1-1;
   else LoopBegin1=mBar;
   LoopBegin1=MathMin(LoopBegin1, Bars-t3_period1-1);
   ArrayResize(t31, Bars);
   if (ft1)
     {
      b21=b1*b1;
      b31=b21*b1;
      c11=-b31;
      c21=(3*(b21+b31));
      c31=-3*(2*b21+b1+b31);
      c41=(1+3*b1+b31+3*b21);
      n1=t3_period1;
      if (n1<1) n1=1;
      n1=1+0.5*(n1-1);
      w11=2/(n1+1);
      w21=1-w11;
      ft1=False;
     }
   for(shift1=LoopBegin1; shift1>=0; shift1--)
     {
      e11=w11*Close[shift1]+w21*e11;
      e21=w11*e11+w21*e21;
      e31=w11*e21+w21*e31;
      e41=w11*e31+w21*e41;
      e51=w11*e41+w21*e51;
      e61=w11*e51+w21*e61;
      t31[shift1]=c11*e61+c21*e51+c31*e41+c41*e31;
      if (t31[shift1+1]<=t31[shift1]) dBuf0[shift1]=t31[shift1]; else dBuf0[shift1]=EMPTY_VALUE;
      if (t31[shift1+1]>t31[shift1]) dBuf1[shift1]=t31[shift1]; else dBuf1[shift1]=EMPTY_VALUE;
     }
   if (mBar==0) LoopBegin2=Bars-t3_period2-1;
   else LoopBegin2=mBar;
   LoopBegin2=MathMin(LoopBegin2, Bars-t3_period2-1);
   ArrayResize(t32, Bars);
     if (ft2) {
      b22=b2*b2;
      b32=b22*b2;
      c12=-b32;
      c22=(3*(b22+b32));
      c32=-3*(2*b22+b2+b32);
      c42=(1+3*b2+b32+3*b22);
      n2=t3_period2;
      if (n2<1) n2=1;
      n2=1+0.5*(n2-1);
      w12=2/(n2+1);
      w22=1-w12;
      ft2=False;
     }
   for(shift2=LoopBegin2; shift2>=0; shift2--)
     {
      e12=w12*Close[shift2]+w22*e12;
      e22=w12*e12+w22*e22;
      e32=w12*e22+w22*e32;
      e42=w12*e32+w22*e42;
      e52=w12*e42+w22*e52;
      e62=w12*e52+w22*e62;
      t32[shift2]=c12*e62+c22*e52+c32*e42+c42*e32;
      if (t32[shift2+1]<=t32[shift2]) dBuf2[shift2]=t32[shift2]; else dBuf2[shift2]=EMPTY_VALUE;
      if (t32[shift2+1]>t32[shift2]) dBuf3[shift2]=t32[shift2]; else dBuf3[shift2]=EMPTY_VALUE;
     }
   if (mBar==0) LoopBegin3=Bars-t3_period3-1;
   else LoopBegin3=mBar;
   LoopBegin3=MathMin(LoopBegin3, Bars-t3_period3-1);
   ArrayResize(t33, Bars);
   if (ft3)
     {
      b23=b3*b3;
      b33=b23*b3;
      c13=-b33;
      c23=(3*(b23+b33));
      c33=-3*(2*b23+b3+b33);
      c43=(1+3*b3+b33+3*b23);
      n3=t3_period3;
      if (n3<1) n3=1;
      n3=1+0.5*(n3-1);
      w13=2/(n3+1);
      w23=1-w13;
      ft3=False;
     }
   for(shift3=LoopBegin3; shift3>=0; shift3--)
     {
      e13=w13*Close[shift3]+w23*e13;
      e23=w13*e13+w23*e23;
      e33=w13*e23+w23*e33;
      e43=w13*e33+w23*e43;
      e53=w13*e43+w23*e53;
      e63=w13*e53+w23*e63;
      t33[shift3]=c13*e63+c23*e53+c33*e43+c43*e33;
      if (t33[shift3+1]<=t33[shift3]) dBuf4[shift3]=t33[shift3]; else dBuf4[shift3]=EMPTY_VALUE;
      if (t33[shift3+1]>t33[shift3]) dBuf5[shift3]=t33[shift3]; else dBuf5[shift3]=EMPTY_VALUE;
     }
   if (mBar==0) LoopBegin4=Bars-t3_period4-1;
   else LoopBegin4=mBar;
   LoopBegin4=MathMin(LoopBegin4, Bars-t3_period4-1);
   ArrayResize(t34, Bars);
   if (ft4)
     {
      b24=b4*b4;
      b34=b24*b4;
      c14=-b34;
      c24=(3*(b24+b34));
      c34=-3*(2*b24+b4+b34);
      c44=(1+3*b4+b34+3*b24);
      n4=t3_period4;
      if (n4<1) n4=1;
      n4=1+0.5*(n4-1);
      w14=2/(n4+1);
      w24=1-w14;
      ft4=False;
     }
   for(shift4=LoopBegin4; shift4>=0; shift4--)
     {
      e14=w14*Close[shift4]+w24*e14;
      e24=w14*e14+w24*e24;
      e34=w14*e24+w24*e34;
      e44=w14*e34+w24*e44;
      e54=w14*e44+w24*e54;
      e64=w14*e54+w24*e64;
      t34[shift4]=c14*e64+c24*e54+c34*e44+c44*e34;
      if (t34[shift4+1]<=t34[shift4]) dBuf6[shift4]=t34[shift4]; else dBuf6[shift4]=EMPTY_VALUE;
      if (t34[shift4+1]>t34[shift4]) dBuf7[shift4]=t34[shift4]; else dBuf7[shift4]=EMPTY_VALUE;
     }
   if (dBuf0[0]!=0) string z1="UP";
   if (dBuf1[0]!=0) z1="DOWN";
   if (dBuf2[0]!=0) string z2="UP";
   if (dBuf3[0]!=0) z2="DOWN";
   if (dBuf4[0]!=0) string z3="UP";
   if (dBuf5[0]!=0) z3="DOWN";
   if (dBuf6[0]!=0) string z4="UP";
   if (dBuf7[0]!=0) z4="DOWN";
   Comment(TimeToStr(iTime(NULL,0,0),TIME_MINUTES),
           "\nПервый t3=",t3_period1," b=",b1, " направление ",z1,
           "\nПервый t3=",t3_period2," b=",b2, " направление ",z2,
           "\nПервый t3=",t3_period3," b=",b3, " направление ",z3,
           "\nПервый t3=",t3_period4," b=",b4, " направление ",z4);
  }
//+------------------------------------------------------------------+

