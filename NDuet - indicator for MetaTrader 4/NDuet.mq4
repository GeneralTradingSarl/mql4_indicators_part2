/*Тут покумекал и сделал на индикаторе уровни ещё один сигнализатор
входов. Похоже он самый надёжный из ранее предложенных, но и самый опаздывающий. 
Подробнее о его использовании.
Выставляете три индикатора на чарт(ADXCross, NDuet и SUrovny)
Два первых ставят стрелки на входы в интервале 1-2 бара друг от друга
- это вход с перекресным подтверждение и по нему входим. 
Также на чарте строим ЕМА55 (она участвует, но буфера не хватает для неё)
Третий индикатор будет ставить свою стрелку с подтверждение много позже, но надёжно. 
Если подтверждения первых 2-х сигналов от третьего индикатора не поступило и 
цена развернулась и ЕМА55 ушла внутрь канала - закрыться по рынку - это будет
или ноль или небольшой плюс или небольшой минус и ждать следующего сигнала. 
Такая тактика даёт возможность избежать больших рисков и просадок, а также не
нужен стоп - стопом будет положение ЕМА55 по отношению к каналу. */
//+------------------------------------------------------------------+
//|                                                        NDuet.mq4 |
//|                                         Copyright © 2006, Tartan |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//----
#property indicator_separate_window
#property indicator_buffers 4
//----
extern int sper=55;
extern int fper=21;
extern int nBar=300;
extern int depth=15;
extern int deviation=5;
extern int backstep=3;
extern int per=14;
//+------------------------------------------------------------------+
//| Local variables                                                  |
//+------------------------------------------------------------------+
//double Close = 0;
//double High = 0;
//double Low = 0;
int shift=0;
double i=0;
double mas=0;
double maf=0;
double zz=0;
double zzold=0;
double mstwo=0;
double mftwo=0;
double blokb=0;
double bloks=0;
double cci=0;
double trend=0;
//---- buffers
double ExtMapBuffer[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_LINE,EMPTY,EMPTY,Lime);
   SetIndexStyle(1,DRAW_LINE,EMPTY,EMPTY,Red);
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(3,DRAW_ARROW,EMPTY,1,Aqua);
   SetIndexArrow(3,241);
   SetIndexBuffer(3,ExtMapBuffer3);
   SetIndexLabel(3,"UpArrow");
   //   SetIndexEmptyValue(3,0.0);
   SetIndexStyle(4,DRAW_ARROW,EMPTY,1,Red);
   SetIndexArrow(4,242);
   SetIndexBuffer(4,ExtMapBuffer4);
   SetIndexLabel(4,"DownArrow");
   //   SetIndexEmptyValue(4,0.0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
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
   for(shift=nBar;shift>=0 ;shift--)
     {
      if(zz!=0 && zzold!=zz)zzold=zz;
      zz=iCustom(NULL, 0, "ZigZag",depth,deviation,backstep,shift);
      cci=iCCI(NULL, 0, per, PRICE_CLOSE, shift);
      trend=((Close[shift+fper]-Close[shift])/Point);
      mas=iMA(NULL, 0, sper, 0, MODE_EMA, PRICE_CLOSE, shift);
      mstwo=iMA(NULL, 0, sper, 0, MODE_EMA, PRICE_CLOSE, shift+2);
//----
      maf=iMA(NULL, 0, fper, 0, MODE_EMA, PRICE_CLOSE, shift);
      mftwo=iMA(NULL, 0, fper, 0, MODE_EMA, PRICE_CLOSE, shift+2);
//----
      ExtMapBuffer[shift]=mas;
      ExtMapBuffer2[shift]=maf;
//----      
      if(mas>maf && ((mas-maf)/Point)<10 && ((mas-maf)/Point)>0 && mstwo<mftwo && cci<0 && trend>0 && bloks==0)
        {
         bloks=1;blokb=0; ExtMapBuffer3[shift]=High[shift]+3*Point;
        }
      if(mas<maf && ((maf-mas)/Point)<10 && ((maf-mas)/Point)>0 && mstwo>mftwo && cci>0 && trend<0 && blokb==0 )
        {
         blokb=1;bloks=0; ExtMapBuffer4[shift]=Low[shift]-3*Point;
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+