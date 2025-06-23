//+------------------------------------------------------------------+
//| Индикатор на основе индикатора взятого отсюда                    |
//| http://codebase.mql4.com/ru/1729                                 |
//| TREND_alexcud v_2. mq4                                           |
//| Copyright © 2007, Aleksander Kudimov                             |
//| alexcud@rambler.ru                                               |
//| Рисует стрелки в основном окне                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Sergej Solujanov"
#property link "irasol@bk.ru"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

//  Для TF1 - TF3 допустимо  установить
//  следующие значения:
//     1   1 минута 
//     5   5 минут
//    15   15 минут
//    30   30 минут
//    60    1 час
//   240    4 часа
//  1440    1 день 
// 10080    1 неделя 
// 43200    1 месяц 
//
extern int TF1 = 5;
extern int TF2 = 15;
extern int TF3 = 60;
extern int maTrendPeriodv_1 = 5;
extern int maTrendPeriodv_2 = 8;
extern int maTrendPeriodv_3 = 13;
extern int maTrendPeriodv_4 = 21;
extern int maTrendPeriodv_5 = 34;
extern int CountBars = 2000;   // Количество баров для прорисовки стрелок

double  UPBuffer[];
double  DOWNBuffer[];
int     Shift;
int     TFperiod[], MAperiod[];
int     ResUP[], ResDown[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+

int init()
 {
 IndicatorShortName("asd");
 SetIndexStyle(0, DRAW_ARROW,DRAW_ARROW,2);
 SetIndexArrow(0, 228);        // стрелка для бай
 SetIndexStyle(1, DRAW_ARROW,DRAW_ARROW,2);
 SetIndexArrow(1, 230);        // стрелка для селл
 SetIndexBuffer(0,UPBuffer);
 SetIndexBuffer(1,DOWNBuffer);
 SetIndexDrawBegin(0, Bars - CountBars);
 SetIndexDrawBegin(1, Bars - CountBars);

 ArrayResize (TFperiod,3);
 ArrayResize (MAperiod,5);
 ArrayResize (ResUP,3);
 ArrayResize (ResDown,3);
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
   int    i, i00; 
   int    limit,shift,shi1;                  
datetime  Tbar;
   int    counted_bars = IndicatorCounted(); 
   int    iTF, iPer; 
   int    UP, Down; 
   int    uptrend, old;
   double MaSUR, MaPrev;
string    gotrend;

   if(Bars <= CountBars + 1) return(0);
   
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars-1;
   if (limit>CountBars) limit=CountBars;
   
   TFperiod[0] = TF1; TFperiod[1] = TF2; TFperiod[2]=TF3;
   MAperiod[0]=maTrendPeriodv_1; MAperiod[1]=maTrendPeriodv_2;
   MAperiod[2]=maTrendPeriodv_3; MAperiod[3]=maTrendPeriodv_4;
   MAperiod[4]=maTrendPeriodv_5;
   UPBuffer[CountBars-1] = Close[CountBars-1];
   uptrend = 1; 
   
for(shift = limit; shift >= 0; shift--) 
  {
  UP=0; Down=0;
  for(iTF=0; iTF<=2; iTF++)
      {
       UP=0; Down=0;

       for(iPer=0; iPer<=4; iPer++)
         {
         Tbar= iTime(NULL,0,shift);
         shi1=iBarShift(NULL,TFperiod[iTF],Tbar,false);
         MaSUR=iMA(NULL,TFperiod[iTF],MAperiod[iPer],0,MODE_SMA,PRICE_CLOSE, shi1);
         MaPrev=iMA(NULL,TFperiod[iTF],MAperiod[iPer],0,MODE_SMA,PRICE_CLOSE,shi1+1);
         if (MaSUR>MaPrev) UP++;
         if (MaSUR<MaPrev) Down++;
         }
       double ac0v = iAC(NULL, TFperiod[iTF], 0);
       double ac1v = iAC(NULL, TFperiod[iTF], 1);
       double ac2v = iAC(NULL, TFperiod[iTF], 2);
       double ac3v = iAC(NULL, TFperiod[iTF], 3);
       if ((ac1v>ac2v && ac2v>ac3v && ac0v<0 && ac0v>ac1v)
                      || (ac0v>ac1v && ac1v>ac2v && ac0v>0)) UP=UP+3;
       if ((ac1v<ac2v && ac2v<ac3v && ac0v>0 && ac0v<ac1v)
                      || (ac0v<ac1v && ac1v<ac2v && ac0v<0)) Down=Down+3;
       ResUP[iTF]=UP;
       ResDown[iTF]=Down;
     }
//   
   if(shift <= 1) 
       {
       for (i = 1; i <= CountBars; i++)
          if ((DOWNBuffer[i] != EMPTY_VALUE) || (UPBuffer[i] != EMPTY_VALUE))
             if (DOWNBuffer[i] != EMPTY_VALUE) 
                 {old = -1; i00=i;  uptrend = -1; break;}
             else 
                 {old = 1; i00= i; uptrend = 1; break;}
//       
       } 
   i=4;
   if (ResUP[0] > i && ResUP[1] > i && ResUP[2] > i) uptrend = 1;
   if (ResDown[0] > i && ResDown[1] > i && ResDown[2] > i) uptrend = -1;

   UPBuffer[shift] = EMPTY_VALUE;     // буфер для бай   ;
   DOWNBuffer[shift] = EMPTY_VALUE;   // буфер для селл

   if(old == -1 && uptrend == 1)
      {
        if (shift != 0) 
             {
              UPBuffer[shift+1] = Close[shift];
              old=uptrend;
              }
             else 
              UPBuffer[shift+1] = Bid;
       }
//----
   if(old == 1 && uptrend == -1)
      {
        if (shift != 0) 
             {
              DOWNBuffer[shift+1] = Close[shift];
              old=uptrend;
              }
             else 
              DOWNBuffer[shift+1] = Ask;
       }
   if (shift != 0) old=uptrend; 
   if (uptrend == 1) gotrend = "UP";
        else gotrend = "DOWN";    

   Comment("Trend ",gotrend," ",i00," bars", "\nResUP    ",
           ResUP[0]*12.5,"   ",ResUP[1]*12.5,"   ",ResUP[2]*12.5,
           "\nResDown  ",ResDown[0]*12.5,"   ",ResDown[1]*12.5,"   ",ResDown[2]*12.5);
 }  
return;
}

