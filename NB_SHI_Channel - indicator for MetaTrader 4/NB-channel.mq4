//+------------------------------------------------------------------+
//|                                               NB_SHI_Channel.mq4 |
//|                                     Copyright © 2005, Nick Bilak |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Nick Bilak"
#property link      ""
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
//#property indicator_color2 Green
//#property indicator_color3 Green
//#property indicator_color4 Green
double buf1[];
double buf2[];
double buf3[];
double ExtMapBuffer1[];
//---- input parameters
extern int       AllBars=240;
extern int       BarsForFract=0;
int CurrentBar=0;
double Step=0;
int B1=-1,B2=-1;
int UpDown=0;
double P1=0,P2=0,PP=0;
int i=0,AB=300,BFF=0;
int ishift=0;
double iprice=0;
datetime T1,T2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,164);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,buf1);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,buf2);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,buf3);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
//----
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DelObj()
  {
   ObjectDelete("TL1");
   ObjectDelete("TL2");
   ObjectDelete("MIDL");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   //  if( Time[0]>= StrToTime("2005.8.19 06:00")) return(0);
   int    counted_bars=IndicatorCounted();
//---- 
   if ((AllBars==0) || (Bars<AllBars)) AB=Bars; else AB=AllBars; 
   if (BarsForFract>0)
      BFF=BarsForFract;
   else
     {
      switch(Period())
        {
         case 1: BFF=12; break;
         case 5: BFF=48; break;
         case 15: BFF=24; break;
         case 30: BFF=24; break;
         case 60: BFF=12; break;
         case 240: BFF=15; break;
         case 1440: BFF=10; break;
         case 10080: BFF=6; break;
         default: DelObj(); return(-1); break;
        }
     }
   CurrentBar=2;
   B1=-1; B2=-1; UpDown=0;
   while(((B1==-1) || (B2==-1)) && (CurrentBar<AB))
     {

      if((UpDown<1) && (CurrentBar==Lowest(Symbol(),Period(),MODE_LOW,BFF*2+1,CurrentBar-BFF)))
        {
         if(UpDown==0) { UpDown=-1; B1=CurrentBar; P1=Low[B1]; }
         else { B2=CurrentBar; P2=Low[B2];}
        }
      if((UpDown>-1) && (CurrentBar==Highest(Symbol(),Period(),MODE_HIGH,BFF*2+1,CurrentBar-BFF)))
        {
         if(UpDown==0) { UpDown=1; B1=CurrentBar; P1=High[B1]; }
         else { B2=CurrentBar; P2=High[B2]; }
        }
      CurrentBar++;
     }
   if((B1==-1) || (B2==-1)) {DelObj(); return(-1);}
   Step=(P2-P1)/(B2-B1);
   P1=P1-B1*Step; B1=0;
   ishift=0; iprice=0;
   if(UpDown==1)
     {
      PP=Low[2]-2*Step;
      for(i=3;i<=B2;i++)
        {
         if(Low[i]<PP+Step*i) { PP=Low[i]-i*Step; }
        }
      if(Low[0]<PP) {ishift=0; iprice=PP;}
      if(Low[1]<PP+Step) {ishift=1; iprice=PP+Step;}
      if(High[0]>P1) {ishift=0; iprice=P1;}
      if(High[1]>P1+Step) {ishift=1; iprice=P1+Step;}
     }
   else
     {
      PP=High[2]-2*Step;
      for(i=3;i<=B2;i++)
        {
         if(High[i]>PP+Step*i) { PP=High[i]-i*Step;}
        }
      if(Low[0]<P1) {ishift=0; iprice=P1;}
      if(Low[1]<P1+Step) {ishift=1; iprice=P1+Step;}
      if(High[0]>PP) {ishift=0; iprice=PP;}
      if(High[1]>PP+Step) {ishift=1; iprice=PP+Step;}
     }
   P2=P1+AB*Step;
   T1=Time[B1]; T2=Time[AB];
//----
   if(iprice!=0) ExtMapBuffer1[ishift]=iprice;
   DelObj();
   ObjectCreate("TL1",OBJ_TREND,0,T2,PP+Step*AB,T1,PP);
   ObjectSet("TL1",OBJPROP_COLOR,Lime);
   ObjectSet("TL1",OBJPROP_WIDTH,2);
   ObjectSet("TL1",OBJPROP_STYLE,STYLE_SOLID);
   ObjectCreate("TL2",OBJ_TREND,0,T2,P2,T1,P1);
   ObjectSet("TL2",OBJPROP_COLOR,Lime);
   ObjectSet("TL2",OBJPROP_WIDTH,2);
   ObjectSet("TL2",OBJPROP_STYLE,STYLE_SOLID);
   ObjectCreate("MIDL",OBJ_TREND,0,T2,(P2+PP+Step*AB)/2,T1,(P1+PP)/2);
   ObjectSet("MIDL",OBJPROP_COLOR,Lime);
   ObjectSet("MIDL",OBJPROP_WIDTH,1);
   ObjectSet("MIDL",OBJPROP_STYLE,STYLE_DOT);
//----
   double cbars=AB-B1;
   double startPP=PP+Step*AB, endPP=PP;
   double startP1=P2, endP1=P1;
   double startP2=(P2+PP+Step*AB)/2, endP2=(P1+PP)/2;
   double deltaPP=(startPP-endPP)/cbars;
   double deltaP1=(startP1-endP1)/cbars;
   double deltaP2=(startP2-endP2)/cbars;
   buf1[AB]=startPP;
   buf2[AB]=startP1;
   buf3[AB]=startP2;
     for(int i=AB-1; i>=0; i--) 
     {
      buf1[i]=buf1[i+1]-deltaPP;
      buf2[i]=buf2[i+1]-deltaP1;
      buf3[i]=buf3[i+1]-deltaP2;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+