//+------------------------------------------------------------------+
//|                                                  MultiStrend.mq4 |
//|                                                             Rosh |
//|                    http://www.alpari-idc.ru/ru/experts/articles/ |
//+------------------------------------------------------------------+
#property copyright "Rosh"
#property link      "http://www.alpari-idc.ru/ru/experts/articles/"
//----
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Red
#property indicator_color2 DarkBlue
#property indicator_color3 Red
#property indicator_color4 DarkBlue
#property indicator_color5 Red
#property indicator_color6 DarkBlue
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
int myPeriod,superPeriod,super2;
//+------------------------------------------------------------------+
//| возвращает период                                                |
//+------------------------------------------------------------------+
int PeriodNumber(int number)
   {
   int per_min;
   switch (number)
      {
      case 0: per_min=PERIOD_M1;break;
      case 1: per_min=PERIOD_M5;break;
      case 2: per_min=PERIOD_M15;break;
      case 3: per_min=PERIOD_M30;break;
      case 4: per_min=PERIOD_H1;break;
      case 5: per_min=PERIOD_H4;break;
      default: per_min=PERIOD_D1;break;
      }
   return(per_min);   
   }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  bool periodNotDetect=true;
  int k;
//---- indicators
   SetIndexStyle(0, DRAW_LINE, STYLE_DOT, 0);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1, DRAW_LINE, STYLE_DOT, 0);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2, DRAW_LINE, STYLE_DASH, 1);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3, DRAW_LINE, STYLE_DASH, 1);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexBuffer(5,ExtMapBuffer6);
   //
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0);
   SetIndexEmptyValue(5,0.0);
//----
   while(periodNotDetect)
      {
      if (PeriodNumber(k)==Period()) {periodNotDetect=false;break;}
      k++;
      }
   myPeriod=k;
   superPeriod=k+1;
   super2=k+2;
   //Print("Number Period=",myPeriod,",  Period on Number=",PeriodNumber(myPeriod));   
   SetIndexLabel(0,"UP_Strend-"+Period());
   SetIndexLabel(1,"Down_Strend-"+Period());
   SetIndexLabel(2,"UP_Strend-"+PeriodNumber(superPeriod));
   SetIndexLabel(3,"Down_Strend-"+PeriodNumber(superPeriod));
   SetIndexLabel(4,"UP_Strend-"+PeriodNumber(super2));
   SetIndexLabel(5,"Down_Strend-"+PeriodNumber(super2));
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
   int    counted_bars=IndicatorCounted();
//----
   
   int limit,limit1,limit2,k1,k2;
   double var1,var2;
   double m1,m2; 
   
   
   if (counted_bars==0)
      {
      limit=Bars-1;
      limit1=iBars(Symbol(),PeriodNumber(superPeriod));
      limit2=iBars(Symbol(),PeriodNumber(super2));
      if (limit1==0) return;
      if (limit2==0) return;
      for(int k=limit;k>=0;k--)
         {
         m1=iCustom(NULL,0,"Supertrend",1,k);
         if (m1>10000) m1=0;
         ExtMapBuffer1[k]=m1;

         m2=iCustom(NULL,0,"Supertrend",0,k);
         if (m2>10000) m2=0;
         
         ExtMapBuffer2[k]=m2;
         k1=iBarShift(NULL,PeriodNumber(superPeriod),Time[k]);
         var1=iCustom(NULL,PeriodNumber(superPeriod),"Supertrend",1,k1);
         if (var1>10000) var1=0;
         
         var2=iCustom(NULL,PeriodNumber(superPeriod),"Supertrend",0,k1);
         if (var2>10000) var2=0;

         ExtMapBuffer3[k]=var1;
         ExtMapBuffer4[k]=var2;
         k2=iBarShift(NULL,PeriodNumber(super2),Time[k]);

         var1=iCustom(NULL,PeriodNumber(super2),"Supertrend",1,k2);
         if (var1>10000) var1=0;

         var2=iCustom(NULL,PeriodNumber(super2),"Supertrend",0,k2);
         if (var2>10000) var2=0;

         ExtMapBuffer5[k]=var1;
         ExtMapBuffer6[k]=var2;
         }
      }
   else
      {
      limit=Bars-counted_bars;
      for(k=limit;k>=0;k--)
         {
         m1=iCustom(NULL,0,"Supertrend",1,k);
         if (m1>10000) m1=0;
         ExtMapBuffer1[k]=m1;

         m2=iCustom(NULL,0,"Supertrend",0,k);
         if (m2>10000) m2=0;
         ExtMapBuffer2[k]=m2;

         k1=iBarShift(NULL,PeriodNumber(superPeriod),Time[k]);
         var1=iCustom(NULL,PeriodNumber(superPeriod),"Supertrend",1,k1);
         if (var1>10000) var1=0;
         
         var2=iCustom(NULL,PeriodNumber(superPeriod),"Supertrend",0,k1);
         if (var2>10000) var2=0;

         ExtMapBuffer3[k]=var1;
         ExtMapBuffer4[k]=var2;
         k2=iBarShift(NULL,PeriodNumber(super2),Time[k]);

         var1=iCustom(NULL,PeriodNumber(super2),"Supertrend",1,k2);
         if (var1>10000) var1=0;

         var2=iCustom(NULL,PeriodNumber(super2),"Supertrend",0,k2);
         if (var2>10000) var2=0;

         ExtMapBuffer5[k]=var1;
         ExtMapBuffer6[k]=var2;
         
         
         
         }
         
      }   
//----
   return(0);
  }
//+------------------------------------------------------------------+