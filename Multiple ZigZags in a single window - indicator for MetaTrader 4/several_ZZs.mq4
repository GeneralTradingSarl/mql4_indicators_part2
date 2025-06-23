//+------------------------------------------------------------------+
//|                                                  several_ZZs.mq4 |
//|                                       Copyright © 2007, Mathemat |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2007, Mathemat"
#property indicator_chart_window
#property indicator_buffers 4

#property indicator_color1 Red         // H1
#property indicator_width1 2

#property indicator_color2 Goldenrod   // H4
#property indicator_width2 3

#property indicator_color3 Green       // D1
#property indicator_width3 4

#property indicator_color4 Blue        // W1
#property indicator_width4 5

//---- ZZ parameters
extern int _Depth=12;
extern int _Dev=5;
extern int _BStep=3;

//---- indicator buffers
double H1[],H4[],D1[],W1[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(4);

   for(int i=0; i<4; i++) SetIndexStyle(i,DRAW_SECTION);

   SetIndexBuffer(0,H1);
   SetIndexBuffer(1,H4);
   SetIndexBuffer(2,D1);
   SetIndexBuffer(3,W1);

   for(i=0; i<4; i++) SetIndexEmptyValue(i,0.0);

   IndicatorShortName("ZigZag("+(string)_Depth+","+(string)_Dev+","+(string)_BStep+")");

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
// конвертирует баровое смещение, указанное на H1, в баровое на более крупном ТФ
int convertShift(int sh,int toTF)
  {
   datetime time=iTime(NULL,PERIOD_H1,sh);
   return(iBarShift(NULL,toTF,time,true));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ZZ(int period,int shift)
  {
   return(iCustom(NULL,period,"ZigZag_Rosh",
          _Depth,_Dev,_BStep,
          0,shift));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   for(int shift=Bars-1; shift>=0; shift--)
     {
      H1[shift]=ZZ(PERIOD_H1,shift);

      int shiftH4 = convertShift( shift, PERIOD_H4 );
      int shiftD1 = convertShift( shift, PERIOD_D1 );
      int shiftW1 = convertShift( shift, PERIOD_W1 );

      bool condition1 = ( ZZ( PERIOD_H1, shift )   < 0.01 );
      bool condition2 = ( ZZ( PERIOD_H4, shiftH4 ) < 0.01 ) || condition1;
      bool condition3 = ( ZZ( PERIOD_D1, shiftD1 ) < 0.01 ) || condition2;


      if(condition1) H4[shift]=0.0;
      else               H4[shift]=ZZ(PERIOD_H4,shiftH4);

      if(condition2) D1[shift]=0.0;
      else               D1[shift]=ZZ(PERIOD_D1,shiftD1);

      if(condition3) W1[shift]=0.0;
      else               W1[shift]=ZZ(PERIOD_W1,shiftW1);
     }
   return(0);
  }
//+------------------------------------------------------------------+
