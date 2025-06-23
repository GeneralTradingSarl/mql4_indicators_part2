//+------------------------------------------------------------------+
//|                                           Parabolic_standart.mq4 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                      Copyright © 2008, Лукашук В.Г. aka lukas1.  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes + lukas1"

#property indicator_chart_window
#property indicator_color1 Orchid
//---- input parameters
extern double    Step=0.02;
extern double    Maximum=0.04;
//---- buffers
double SarBuffer[];
//----
static bool first=false;
bool   dirlong;
double start,last_high,last_low;
double ep,sar,price_low,price_high;
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
   SetIndexDrawBegin(0, 4/Step); 
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
   int i=Bars-4;
   while(i>=0)
     {
      price_low=Low[i];
      price_high=High[i];
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
            if(High[i]<last_high) SarBuffer[i]=last_high;
            else SarBuffer[i]=High[i];
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
            if(Low[i]>last_low) SarBuffer[i]=last_low;
            else SarBuffer[i]=Low[i];
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