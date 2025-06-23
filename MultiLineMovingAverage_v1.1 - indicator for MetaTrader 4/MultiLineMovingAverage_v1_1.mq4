//+------------------------------------------------------------------+
//|                                  MultiLineMovingAverage_v1.1.mq4 |
//|                                                          PozitiF |
//|                                                    Alex-W-@bk.ru |
//+------------------------------------------------------------------+
#property copyright "PozitiF"
#property link      "Alex-W-@bk.ru"
//+------------------------------------------------------------------+
//|   Данный индикатор предназначен для отображения линий            |
//|   скользящих средних с разных периодов на текущем графике.       |
//+------------------------------------------------------------------+
#property indicator_chart_window
//--- input parameters
extern bool    display_period_m1 = true;    // Какие периоды отображать на графике
extern bool    display_period_m5 = true;    // Те периоды которые требуется отображать должны быть открыты на графике.
extern bool    display_period_m15 = true;
extern bool    display_period_m30 = true;
extern bool    display_period_h1 = true;
extern bool    display_period_h4 = true;
extern bool    display_period_d1 = true;
extern bool    display_period_w1 = true;
extern bool    display_period_mn1= true;
// ------ Параметры MovingAverage.
extern int     average_bars_m1=14;      // Период, сколько дней усреднять
extern int     average_bars_m5= 14;
extern int     average_bars_m15 = 14;
extern int     average_bars_m30 = 14;
extern int     average_bars_h1 = 14;
extern int     average_bars_h4 = 14;
extern int     average_bars_d1 = 14;
extern int     average_bars_w1 = 14;
extern int     average_bars_mn1= 14;
// ------ Метод вычисления скользящего среднего (Moving Average)
extern int     ma_method_m1 = 3;
extern int     ma_method_m5 = 3;
extern int     ma_method_m15 = 3;           //MODE_SMA	0	Простое скользящее среднее
extern int     ma_method_m30 = 3;           //MODE_EMA	1	Экспоненциальное скользящее среднее
extern int     ma_method_h1 = 3;            //MODE_SMMA	2	Сглаженное скользящее среднее
extern int     ma_method_h4 = 3;            //MODE_LWMA	3	Линейно-взвешенное скользящее среднее
extern int     ma_method_d1 = 3;
extern int     ma_method_w1 = 3;
extern int     ma_method_mn1= 3;
// ------ Используемая цена.
extern int     applied_price_m1 = 4;         //PRICE_CLOSE	0	Цена закрытия
extern int     applied_price_m5 = 4;         //PRICE_OPEN	1	Цена открытия
extern int     applied_price_m15 = 4;        //PRICE_HIGH	2	Максимальная цена
extern int     applied_price_m30 = 4;        //PRICE_LOW	3	Минимальная цена
extern int     applied_price_h1 = 4;         //PRICE_MEDIAN	4	Средняя цена, (high+low)/2
extern int     applied_price_h4 = 4;         //PRICE_TYPICAL	5	Типичная цена, (high+low+close)/3
extern int     applied_price_d1 = 4;         //PRICE_WEIGHTED	6	Взвешенная цена закрытия, (high+low+close+close)/4
extern int     applied_price_w1 = 4;
extern int     applied_price_mn1= 4;
// ------ Цвета линий.
extern color   line_color_up=Lime;
extern color   line_color_down = OrangeRed;
extern color   line_color_flet = Indigo;

bool display_period[9];

int time_frame[9],applied_price[9],ma_method[9],average_bars[9];
double history_price[9];
string   name_period[9]={"m1","m5","m15","m30","h1","h4","d1","w1","mn1"};
int maxbars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   time_frame[0] = 1;
   time_frame[1] = 5;
   time_frame[2] = 15;
   time_frame[3] = 30;
   time_frame[4] = 60;
   time_frame[5] = 240;
   time_frame[6] = 1440;
   time_frame[7] = 10080;
   time_frame[8] = 43200;

   average_bars[0] = average_bars_m1;
   average_bars[1] = average_bars_m5;
   average_bars[2] = average_bars_m15;
   average_bars[3] = average_bars_m30;
   average_bars[4] = average_bars_h1;
   average_bars[5] = average_bars_h4;
   average_bars[6] = average_bars_d1;
   average_bars[7] = average_bars_w1;
   average_bars[8] = average_bars_mn1;

   maxbars=average_bars[0];
   for(int i=0; i<8; i++) if(average_bars[i]>maxbars) maxbars=average_bars[i];

   display_period[0] = display_period_m1;
   display_period[1] = display_period_m5;
   display_period[2] = display_period_m15;
   display_period[3] = display_period_m30;
   display_period[4] = display_period_h1;
   display_period[5] = display_period_h4;
   display_period[6] = display_period_d1;
   display_period[7] = display_period_w1;
   display_period[8] = display_period_mn1;

   applied_price[0] = applied_price_m1;
   applied_price[1] = applied_price_m5;
   applied_price[2] = applied_price_m15;
   applied_price[3] = applied_price_m30;
   applied_price[4] = applied_price_h1;
   applied_price[5] = applied_price_h4;
   applied_price[6] = applied_price_d1;
   applied_price[7] = applied_price_w1;
   applied_price[8] = applied_price_mn1;

   ma_method[0] = ma_method_m1;
   ma_method[1] = ma_method_m5;
   ma_method[2] = ma_method_m15;
   ma_method[3] = ma_method_m30;
   ma_method[4] = ma_method_h1;
   ma_method[5] = ma_method_h4;
   ma_method[6] = ma_method_d1;
   ma_method[7] = ma_method_w1;
   ma_method[8] = ma_method_mn1;

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for(int i=0; i<8; i++) ObjectDelete(name_period[i]);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int period_t,offset;
   double   price_ma[9];
   color    line_color;
//----
   if(IndicatorCounted()<maxbars) return;

   for(int cx=0; cx<8; cx++)
     {
      if(display_period[cx])
        {
         price_ma[cx]=iMA(Symbol(),time_frame[cx],average_bars[cx],0,ma_method[cx],applied_price[cx],0);

         if(history_price[cx]!=price_ma[cx])
           {
            if(ObjectFind(name_period[cx])>=0) ObjectDelete(name_period[cx]);

            history_price[cx]=price_ma[cx];

            period_t=Period();
            offset=offset+period_t*250;

            double ind_value=iMA(Symbol(),time_frame[cx],average_bars[cx],0,ma_method[cx],applied_price[cx],1);

            if(ind_value < price_ma[cx]) line_color = line_color_up;
            if(ind_value > price_ma[cx]) line_color = line_color_down;
            if(ind_value==price_ma[cx]) line_color=line_color_flet;

            ObjectCreate(name_period[cx],OBJ_TREND,0,Time[0]+period_t*1500-offset,price_ma[cx],Time[0]+period_t*2000,price_ma[cx]);
            ObjectSet(name_period[cx],OBJPROP_RAY,false);
            ObjectSet(name_period[cx],OBJPROP_COLOR,line_color);
            ObjectSetText(name_period[cx],name_period[cx]);
           }
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
