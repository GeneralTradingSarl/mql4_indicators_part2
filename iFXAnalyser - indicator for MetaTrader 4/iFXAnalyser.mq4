//+------------------------------------------------------------------+
//|                                                  iFXAnalyser.mq4 |
//|                           Copyright © 2006, Renato P. dos Santos |
//|                   inspired on 4xtraderCY's and SchaunRSA's ideas |
//|   http://www.strategybuilderfx.com/forums/showthread.php?t=16086 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Renato P. dos Santos"
#property link "http://www.strategybuilderfx.com/forums/showthread.php?t=16086"
//----
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Green
//---- indicator parameters
extern int MA_Shift=0;
extern int FastMA=4;
extern int SlowMA=6;
extern int Fast_MAMode=PRICE_CLOSE;
extern int Slow_MAMode=PRICE_OPEN;
string short_name="iFXAnalyser";
//---- indicator buffers
double ind_buffer0[];
double ind_buffer1[];
double ind_buffer2[];
//----
int counted_bars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   int    draw_begin;
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetLevelStyle(STYLE_DOT,1,Black);
   SetIndexShift(0,MA_Shift);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
   draw_begin=FastMA-1;
   SetIndexDrawBegin(0,draw_begin);
//---- indicator short name
   IndicatorShortName(short_name+"("+FastMA+","+SlowMA+")");
   SetIndexLabel(0,"Div");
   SetIndexLabel(1,"Slope");
   SetIndexLabel(2,"Acel");
//---- indicator buffers mapping
   SetIndexBuffer(0,ind_buffer0);
   SetIndexBuffer(1,ind_buffer1);
   SetIndexBuffer(2,ind_buffer2);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Shaun's 2MA difference                                           |
//+------------------------------------------------------------------+
int start()
  {
   if(Bars<=MathMax(FastMA,SlowMA)) return(0);
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+MathMax(FastMA,SlowMA);

   int i;
   for(i=0; i<limit; i++)
      ind_buffer0[i]=iMA(NULL,0,FastMA,0,MODE_SMA,Fast_MAMode,i)
                     -iMA(NULL,0,SlowMA,0,MODE_SMA,Slow_MAMode,i);
//---- Shaun's Slope counted in the 2-nd buffer
   for(i=0; i<limit-1; i++)
      ind_buffer1[i]=(iMA(NULL,0,FastMA,0,MODE_SMA,Fast_MAMode,i)
                      -iMA(NULL,0,SlowMA,0,MODE_SMA,Slow_MAMode,i))
      -(iMA(NULL,0,FastMA,0,MODE_SMA,Fast_MAMode,i+1)
        -iMA(NULL,0,SlowMA,0,MODE_SMA,Slow_MAMode,i+1));
//---- Shaun's Slope of Slope counted in the 3-3d buffer
   for(i=0; i<limit-2; i++)
      ind_buffer2[i]=((iMA(NULL,0,FastMA,0,MODE_SMA,Fast_MAMode,i)
                      -iMA(NULL,0,SlowMA,0,MODE_SMA,Slow_MAMode,i))
                      -(iMA(NULL,0,FastMA,0,MODE_SMA,Fast_MAMode,i+1)
                      -iMA(NULL,0,SlowMA,0,MODE_SMA,Slow_MAMode,i+1))
                      -(iMA(NULL,0,FastMA,0,MODE_SMA,Fast_MAMode,i+1)
                      -iMA(NULL,0,SlowMA,0,MODE_SMA,Slow_MAMode,i+1))
                      -(iMA(NULL,0,FastMA,0,MODE_SMA,Fast_MAMode,i+2)
                      -iMA(NULL,0,SlowMA,0,MODE_SMA,Slow_MAMode,i+2)));
//---- done
   return(0);
  }
//+------------------------------------------------------------------+
