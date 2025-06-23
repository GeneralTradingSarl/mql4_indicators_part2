//+-----------------------------------------------------------------------+
//|                                                          Notarius.mq4 |
//+-----------------------------------------------------------------------+
#property copyright "Copyright © 2011, Andrey Vassiliev (MoneyJinn), v2.0"
#property link      "http://www.vassiliev.ru/"

//I Ain't Mad At Cha, MetaQuotes...

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 LimeGreen
#property indicator_color2 Red
#property indicator_width1 1
#property indicator_width2 1

extern int    Mode=0;       //  0...2
extern int    StartBar=2;   //  1...+n
extern double Confirm=25.0; // -n...+n
extern double Flat=-25.0;   // -n...+n
extern bool   SoundAlert=false;
extern bool   EmailAlert=false;

double B1[],B2[];
double IUP,IDN,E1,E2,Confirm2,Flat2,Z1,Z2;
int IN,F,C,BR1,BR2;

int init()
  {
   CLR();
   if(Mode<=0||Mode>2){C=0;F=0;}
   if(Mode==1){C=1;F=0;}
   if(Mode==2){C=0;F=1;}
   if(Digits==3||Digits==5){Confirm2=MathAbs(Confirm*10);Flat2=MathAbs(Flat*10);}else{Confirm2=MathAbs(Confirm);Flat2=MathAbs(Flat);}
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,B1);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,B2);
   return(0);
  }

void CLR(){if(ArraySize(B1)>0){ArrayInitialize(B1,0);ArrayInitialize(B2,0);}IN=0;Z1=0;Z2=0;IUP=0;IDN=0;E1=0;E2=0;BR1=0;BR2=0;}

int start()
  {
   int IndCounted=IndicatorCounted();
   if(IndCounted<0){return(-1);}
   if(IndCounted==0){CLR();}
   int pos=0;
   if(Bars>IndCounted+1){pos=(Bars-IndCounted)-1;}
   for(int i=pos;i>0;i--)
     {
      B1[i]=0; B2[i]=0;
      Z1=(Z1+Z2)/2;
      Z2=(Open[i]+High[i]+Low[i]+Close[i])/4;
      if(Z1<Z2)
      {
      BR1++;BR2=0;
      if((IN==0||IN==-1)&&(StartBar<=1||BR1>=StartBar)){if(Confirm==0){BU(i);}else{if(Confirm>0){IUP=Open[i];}else{IUP=Open[i];}IDN=0;if(C==1){IN=1;}}}
      }
      else
      {
      BR2++;BR1=0;
      if((IN==0||IN==1)&&(StartBar<=1||BR2>=StartBar)){if(Confirm==0){BD(i);}else{if(Confirm>0){IDN=Open[i];}else{IDN=Open[i];}IUP=0;if(C==1){IN=-1;}}}
      }
      if(IUP!=0){if(((Confirm>0)&&((High[i]-IUP)>=(Confirm2*Point))&&(Open[i]<=Close[i]))||((Confirm<0)&&((IUP-Low[i])>=(Confirm2*Point))&&(Open[i]>=Close[i]))){BU(i);IUP=0;}}
      if(IDN!=0){if(((Confirm>0)&&((IDN-Low[i])>=(Confirm2*Point))&&(Open[i]>=Close[i]))||((Confirm<0)&&((High[i]-IDN)>=(Confirm2*Point))&&(Open[i]<=Close[i]))){BD(i);IDN=0;}}
      }
   return(0);
  }

void BU(int i){if(Low[i]>=(E1+Flat2*Point)||Low[i]<=(E1-Flat2*Point)){B1[i]=Low[i];IN=1;E1=Low[i];if(Flat<0){E2=High[i];}Alerts(i,"UP "+Symbol()+" "+TimeToStr(Time[i]));}else{if(F==1){IN=1;}}}
void BD(int i){if(High[i]>=(E2+Flat2*Point)||High[i]<=(E2-Flat2*Point)){B2[i]=High[i];IN=-1;E2=High[i];if(Flat<0){E1=Low[i];}Alerts(i,"DN "+Symbol()+" "+TimeToStr(Time[i]));}else{if(F==1){IN=-1;}}}

void Alerts(int pos,string txt)
  {  
   if (SoundAlert==true&&pos==1){PlaySound("alert.wav");}
   if (EmailAlert==true&&pos==1){SendMail("Notarius alert signal: "+txt,txt);} 
  }