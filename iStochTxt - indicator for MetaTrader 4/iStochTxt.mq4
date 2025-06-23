//+------------------------------------------------------------------+
//|                                                    iStochTxt.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 1
#property indicator_width2 1
//----
extern int k = 5, s = 3, l = 20;
extern color txtColor = Brown;
//----
int d=3;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, 1);
   SetIndexArrow(0, 241);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexEmptyValue(0, 0.0);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 1);
   SetIndexArrow(1, 242);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexEmptyValue(1, 0.0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for(int i = 0; i < ObjectsTotal(); i++)
     {
       if(StringFind(ObjectName(i), "txt_", 0) == 0)
         {
           ObjectDelete(ObjectName(i));
           i--;
         }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   string on;
   int limit;
	  int counted_bars = IndicatorCounted(); // определим количество просчитаных баров у индикатора
	  if(counted_bars > 0)
	    {
	      counted_bars--;
	    }	
	  limit = Bars - counted_bars; // определяем границу до которой рассчитываем значения индикатора
//----
	  for(int i = 0; i < limit; i++)
	    {
       double mc = iStochastic(NULL, 0, k, d, s, 0, 0, MODE_MAIN, i);
       double mp = iStochastic(NULL, 0, k, d, s, 0, 0, MODE_MAIN, i + 1);
       //----
       ExtMapBuffer1[i] = EMPTY_VALUE;
       ExtMapBuffer2[i] = EMPTY_VALUE;      
       //----
       if(mc > l && mp <= l)
         {
           ExtMapBuffer1[i] = Low[i] - iATR(NULL, 0, 14, i);
           on = "txt_" + Time[i];
           ObjectDelete(on);
           ObjectCreate(on, OBJ_TEXT, 0, Time[i], Low[i] - 1.5*iATR(NULL, 0, 14, i));
           ObjectSetText(on, DoubleToStr(Close[i], Digits) + " " + TimeToStr(Time[i], 
                         TIME_MINUTES), 8, "Arial", txtColor);
         }
       if(mc < 100 - l && mp >= 100 - l)
         {
           ExtMapBuffer2[i] = High[i] + iATR(NULL, 0, 14, i);         
           on = "txt_" + Time[i];
           ObjectDelete(on);
           ObjectCreate(on, OBJ_TEXT, 0, Time[i], High[i] + 2*iATR(NULL, 0, 14, i));
           ObjectSetText(on, DoubleToStr(Close[i], Digits) + " " + TimeToStr(Time[i], 
                         TIME_MINUTES), 8, "Arial", txtColor);
         }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+