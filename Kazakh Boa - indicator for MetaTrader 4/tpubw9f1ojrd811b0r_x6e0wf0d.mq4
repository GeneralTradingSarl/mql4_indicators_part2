//+------------------------------------------------------------------+
//|                                                                  |
//|                 Copyright © 2000-2007, MetaQuotes Software Corp. |
//|                                         http://www.metaquotes.ru |
//+------------------------------------------------------------------+
// Казахский Удав.mq4
#property copyright "слова - Mandor, музыка - народная"
#property link "mandorr@gmail.com"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Green
//----
extern int Length=6;
extern int CountBars=1000;   // Количество отображаемых баров
//----
double buffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {
   SetIndexStyle(0,DRAW_SECTION,0,1);
   SetIndexBuffer(0,buffer);
   SetIndexLabel(0,"Value");
   SetIndexDrawBegin(0,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start()
  {
   int shift, zu, zd, Swing, Swing_n;
   double HH, LL, BH, BL;
//----
   Swing=0;
   Swing_n=0;
   shift=CountBars-1;
   zu=shift;
   zd=shift;
   BH=High[shift];
   BL=Low[shift];
//----
   for(shift=CountBars-1; shift>=0; shift--)
     {
      HH=High[Highest(NULL,0,MODE_HIGH,Length,shift+1)];
      LL=Low [Lowest (NULL,0,MODE_LOW ,Length,shift+1)];
      if (Low[shift]<LL && High[shift]>HH)
        {
         Swing=2;
         if (Swing_n== 1) zu=shift+1;
         if (Swing_n==-1) zd=shift+1;
        }
      else
        {
         if (Low [shift]<LL) Swing=-1;
         if (High[shift]>HH) Swing= 1;
        }
      if (Swing!=Swing_n && Swing_n!=0)
        {
         if (Swing== 2) {Swing=-Swing_n; BH=High[shift]; BL=Low[shift];}
         if (Swing== 1) buffer[zd]=BL;
         if (Swing==-1) buffer[zu]=BH;
         BH=High[shift];
         BL=Low [shift];
        }
      if (Swing== 1) {if (High[shift]>=BH) {BH=High[shift]; zu=shift;}}
      if (Swing==-1) {if (Low [shift]<=BL) {BL=Low [shift]; zd=shift;}}
      Swing_n=Swing;
     }
  }
//+------------------------------------------------------------------+