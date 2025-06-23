//+------------------------------------------------------------------+
//|                                             Ma-Parabolic_st2.mq4 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                      Copyright © 2008, Лукашук В.Г. aka lukas1.  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes + lukas1"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Orchid
#property indicator_color2 Maroon
//---- input parameters
extern int    Ma=14;
extern int    method=3;
extern int    app_price=0;
extern double Step=0.02;
extern double Maximum=0.04;
//---- buffers
double SarBuffer[];
double MaBuffer[];
//----
static bool first=false;
bool   dirlong;
double start,last_high,last_low;
double ep,sar,price_low,price_high;
int    i,j;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorDigits(Digits);
   string SS=DoubleToStr(Step,4);
   string MM=DoubleToStr(Maximum,4);
   SetIndexLabel(0,"Step= "+SS+", Max= "+MM); 
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexBuffer(0,SarBuffer);
   int draw_bars=4/Step;
   if(draw_bars>Bars-100) draw_bars=Bars-100;
   SetIndexDrawBegin(0, draw_bars); 
//----
   SetIndexLabel(1,"period= "+Ma); 
   SetIndexStyle(1,DRAW_LINE,0,2);
   SetIndexBuffer(1,MaBuffer);
   SetIndexDrawBegin(0, draw_bars); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Parabolic Sell And Reverse system                                |
//+------------------------------------------------------------------+
int start()
  {
   if(Bars<5) return(0);
   dirlong=true;
   start=Step;
//--------------------------------------------+
   for(j=Bars-4;j>=0;j--)
      MaBuffer[j] = iMA(Symbol(),0,Ma,0,method,app_price,j);

   int i=Bars-4;
   while(i>=0)
     {
      price_low=MaBuffer[i]-Point;
      price_high=MaBuffer[i]+Point;
      //sar равен цена предыдущего бара плюс шаг умножить на 
      //(старая цена минус значение SarBuffer предыдущего бара)
      sar=SarBuffer[i+1]+start*(ep-SarBuffer[i+1]);
//----
      if(dirlong)//цепочка вверх
        {
         if(ep<price_high && (start+Step)<=Maximum) start+=Step;
         if(sar>=price_low)//если условия для переключения наступили
           {
            start=Step; 
            dirlong=false; 
            ep=price_low;//устанавливаем последнюю цену = минимум
            last_low=price_low;
            if(MaBuffer[i]+Point<last_high) SarBuffer[i]=last_high;
            else SarBuffer[i]=MaBuffer[i]+Point;
            i--;
            continue;
           }
         else
           {
            if(ep<price_low && (start+Step)<=Maximum) start+=Step;
            //и пересчитываем last_high и ep для расчета следующей точки максимума
            if(ep<price_high) { last_high=price_high; ep=price_high; }
           }
        }
//----
      else//цепочка вниз
        {
         if(ep>price_low && (start+Step)<=Maximum) start+=Step;
         if(sar<=price_high)//если наступили условия переключения
           {
            start=Step; 
            dirlong=true; 
            ep=price_high;//устанавливаем последнюю цену = максимум
            last_high=price_high;
            if(MaBuffer[i]-Point>last_low) SarBuffer[i]=last_low;
            else SarBuffer[i]=MaBuffer[i]-Point;
            i--;
            continue;
           }
         else
           {
            if(ep>price_high && (start+Step)<=Maximum) start+=Step;
            //если условия для переключения не наступили
            //то пересчитываем last_low и ep для расчета следующей точки минимума
            if(ep>price_low){last_low=price_low;ep=price_low;}
           }
        }
      SarBuffer[i]=sar;
      i--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+