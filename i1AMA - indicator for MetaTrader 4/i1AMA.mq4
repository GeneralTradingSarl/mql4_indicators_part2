//+------------------------------------------------------------------+
//| Web:                                                   i1AMA.mq4 |
//|                                                           MNS777 |
//|                                                mns777.ru@mail.ru |
//+------------------------------------------------------------------+
#property copyright "MNS777"
#property link      "Web:" 
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color2 Blue
//---- Внешние параметры
extern int PeriodMA = 3;
extern int KMA = 1;
extern int ShiftMA = 0 ;
extern int ModeMA = 0 ;// 0 = SMA, 1 = EMA, 2 = SMMA, 3 = LWMA
extern int PriceMA = 0 ;  // 0 = Close, 1 = Open, 2 = High, 3 = Low, 4 = HL/2, 5 = HLC/3, 6 = HLCC/4

extern int ToProcess = 20000;
//---- Буферы индикатора
double IndexBuffer1[];
double IndexBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexBuffer(0,IndexBuffer1);
   SetIndexStyle( 0, DRAW_NONE);
   SetIndexBuffer(1,IndexBuffer2);
   SetIndexStyle(1,DRAW_LINE);
     
   IndicatorShortName("i1AMA");
   SetIndexLabel(0,"Бары");
   SetIndexLabel(1,"i1AMA");
         
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
     int limit,i,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,pma;
     int counted_bars=IndicatorCounted();
        
  //---- проверка на возможные ошибки
     if(counted_bars<0) return(-1);

  //---- последний посчитанный бар будет пересчитан
     if(counted_bars>0) counted_bars--;
     limit=Bars-counted_bars;
     
     if(limit>ToProcess)
      limit=ToProcess;
//---- основной цикл
     for(i=limit;i>=0;i--)
{
 
 if(i==ToProcess)
 IndexBuffer1[i]=1;
 else if(Close[i]>High[i+1]&&IndexBuffer1[i+1]<0)
 IndexBuffer1[i]=1;
 else if(Close[i]<Low[i+1]&&IndexBuffer1[i+1]>0)
 IndexBuffer1[i]=-1;
 else if(IndexBuffer1[i+1]>0)
 IndexBuffer1[i]=IndexBuffer1[i+1]+1;
 else if(IndexBuffer1[i+1]<0)
 IndexBuffer1[i]=IndexBuffer1[i+1]-1;
 
 a0=MathAbs(IndexBuffer1[i]);
 a1=MathAbs(IndexBuffer1[i+a0]);
 a2=MathAbs(IndexBuffer1[i+a0+a1]);
 a3=MathAbs(IndexBuffer1[i+a0+a1+a2]);
 a4=MathAbs(IndexBuffer1[i+a0+a1+a2+a3]);
 a5=MathAbs(IndexBuffer1[i+a0+a1+a2+a3+a4]);
 a6=MathAbs(IndexBuffer1[i+a0+a1+a2+a3+a4+a5]);
 a7=MathAbs(IndexBuffer1[i+a0+a1+a2+a3+a4+a5+a6]);
 a8=MathAbs(IndexBuffer1[i+a0+a1+a2+a3+a4+a5+a6+a7]);
 a9=MathAbs(IndexBuffer1[i+a0+a1+a2+a3+a4+a5+a6+a7+a8]);
 
 if(PeriodMA==1)
 pma=a0;
 if(PeriodMA==2)
 pma=a0+a1;
 if(PeriodMA==3)
 pma=a0+a1+a2;
 if(PeriodMA==4)
 pma=a0+a1+a2+a3;
 if(PeriodMA==5)
 pma=a0+a1+a2+a3+a4;
 if(PeriodMA==6)
 pma=a0+a1+a2+a3+a4+a5;
 if(PeriodMA==7)
 pma=a0+a1+a2+a3+a4+a5+a6;
 if(PeriodMA==8)
 pma=a0+a1+a2+a3+a4+a5+a6+a7;
 if(PeriodMA==9)
 pma=a0+a1+a2+a3+a4+a5+a6+a7+a8;
 
 IndexBuffer2[i]=iMA(NULL,0,pma*KMA,ShiftMA,ModeMA,PriceMA,i);
    
} 
}
//----
   return(0);
  

