//+------------------------------------------------------------------+
//|                                                   Indexes_v4.mq4 |
//|                                         Copyright © 2007, Xupypr |
//|                                               fx_forever@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Xupypr"
#property link      "fx_forever@mail.ru"
//----
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Lime
#property indicator_color2 DodgerBlue
#property indicator_color3 Red
#property indicator_color4 Yellow
#property indicator_color5 DeepPink
#property indicator_color6 DarkOrange
#property indicator_color7 MediumSpringGreen
#property indicator_color8 LightSkyBlue
//---- input parameters
extern bool auto_detect_pair=true; // определять автоматически валютную пару и отображать соответсвующие индексы
extern bool reverse_index=false;   // "переворачивать" индекс валюты, которая стоит в знаменателе пары
extern int  applied_price=5;       // используемая цена: 0-PRICE_CLOSE; 4-PRICE_MEDIAN; 5-PRICE_TYPICAL; 6-PRICE_WEIGHTED;
extern int  ma_period=1;           // период усреднения для вычисления скользящего среднего
extern int  ma_method=1;           // метод усреднения: 0-MODE_SMA; 1-MODE_EMA; 2-MODE_SMMA; 3-MODE_LWMA;
extern int  select_indicator=0;    // 0-индексы валют без индикаторов; 1-CCI; 2-Momentum; 3-RSI;
extern int  period_indicator=14;   // период усреднения для вычисления индикатора
extern bool show_USD=true;         // показывать индекс доллара США
extern bool show_EUR=true;
extern bool show_GBP=true;
extern bool show_JPY=true;
extern bool show_CHF=true;
extern bool show_AUD=true;
extern bool show_CAD=true;
extern bool show_NZD=true;
//---- buffers
double iUSDBuffer[];
double iEURBuffer[];
double iGBPBuffer[];
double iJPYBuffer[];
double iCHFBuffer[];
double iAUDBuffer[];
double iCADBuffer[];
double iNZDBuffer[];
double xUSDBuffer[];
double xEURBuffer[];
double xGBPBuffer[];
double xJPYBuffer[];
double xCHFBuffer[];
double xAUDBuffer[];
double xCADBuffer[];
double xNZDBuffer[];
double USDBuffer[];
double EURBuffer[];
double GBPBuffer[];
double JPYBuffer[];
double CHFBuffer[];
double AUDBuffer[];
double CADBuffer[];
double NZDBuffer[];
//---- indicator parameters
int      i,AllBars;
bool     show_CUR[8],stop=false;
double   SPrice[23+1];
string   NmCS,DmCS;
string   Currency[8]={"USD","EUR","GBP","JPY","CHF","AUD","CAD","NZD"};
string   Symbols[23+1]={"EURUSD","EURGBP","EURJPY","EURCHF","EURAUD","EURCAD","EURNZD","GBPUSD","GBPJPY","GBPCHF","USDJPY","USDCHF","CHFJPY","USDCAD","AUDUSD","AUDJPY","AUDCHF","AUDCAD","AUDNZD","CADJPY","CADCHF","NZDUSD","NZDJPY"};
datetime SPoint;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   int      SBarCS,SBar[23],STime[23];
   bool     is_show=false;
   string   Name;
   datetime Week_End;
//----
   Comment("");
   if (Period()==PERIOD_MN1)
     {
      Comment("Период не может быть больше W1");
      stop=true;
      return(-1);
     }
   if (auto_detect_pair)
     {
      ArrayInitialize(show_CUR,false);
      NmCS=StringSubstr(Symbol(),0,3);
      DmCS=StringSubstr(Symbol(),3,3);
      for(i=0;i<8;i++)
        {
         if (NmCS==Currency[i]) {show_CUR[i]=true; is_show=true;}
         if (DmCS==Currency[i]) {show_CUR[i]=true; is_show=true;}
        }
      if (is_show==false)
        {
         ArrayInitialize(show_CUR,true);
         Comment("Внимание! Данному инструменту не соответствует ни один индекс");
        }
     }
   else
     {
      show_CUR[0]=show_USD;
      show_CUR[1]=show_EUR;
      show_CUR[2]=show_GBP;
      show_CUR[3]=show_JPY;
      show_CUR[4]=show_CHF;
      show_CUR[5]=show_AUD;
      show_CUR[6]=show_CAD;
      show_CUR[7]=show_NZD;
     }
   for(i=0;i<23;i++)
     {
      SBar[i]=iBars(Symbols[i],0);
      if (SBar[i]==0)
        {
         Comment("Ошибка! Отсутствует история для "+Symbols[i]);
         stop=true;
         return(-1);
        }
      STime[i]=iTime(Symbols[i],0,SBar[i]-1);
     }
   SPoint=STime[ArrayMaximum(STime)];
   SBarCS=iBarShift(NULL,0,SPoint,true);
   if (SBarCS==-1)
     {
      Comment("Ошибка! Для отображения индексов обновите исторические данные для "+Symbol());
      stop=true;
      return(-1);
     }
   i=0;
   while((iTime(NULL,0,i+1)+172800)>iTime(NULL,0,i)) i++;
   Week_End=iTime(NULL,0,i+1);
   if (applied_price!=0)
     {
      if (applied_price<4) applied_price=4;
      if (applied_price>6) applied_price=6;
     }
   for(i=0;i<23;i++)
     {
      SBar[i]=iBarShift(Symbols[i],0,Week_End,true);
      if (SBar[i]==-1)
        {
         Comment("Ошибка! Недостаточно исторических данных для "+Symbols[i]);
         stop=true;
         return(-1);
        }
      switch(applied_price)
        {
         case PRICE_CLOSE:    SPrice[i]=iClose(Symbols[i],0,SBar[i]); break;
         case PRICE_MEDIAN:   SPrice[i]=(iHigh(Symbols[i],0,SBar[i])+iLow(Symbols[i],0,SBar[i]))/2; break;
         case PRICE_TYPICAL:  SPrice[i]=(iHigh(Symbols[i],0,SBar[i])+iLow(Symbols[i],0,SBar[i])+iClose(Symbols[i],0,SBar[i]))/3; break;
         case PRICE_WEIGHTED: SPrice[i]=(iHigh(Symbols[i],0,SBar[i])+iLow(Symbols[i],0,SBar[i])+iClose(Symbols[i],0,SBar[i])+iClose(Symbols[i],0,SBar[i]))/4;
        }
     }
//---- drawing settings
   Name="Indexes( ";
   for(i=0;i<8;i++) if (show_CUR[i])
        {
         switch(i)
           {
            case 0: {SetIndexBuffer(0,USDBuffer); ArraySetAsSeries(iUSDBuffer,true); ArraySetAsSeries(xUSDBuffer,true);} break;
            case 1: {SetIndexBuffer(1,EURBuffer); ArraySetAsSeries(iEURBuffer,true); ArraySetAsSeries(xEURBuffer,true);} break;
            case 2: {SetIndexBuffer(2,GBPBuffer); ArraySetAsSeries(iGBPBuffer,true); ArraySetAsSeries(xGBPBuffer,true);} break;
            case 3: {SetIndexBuffer(3,JPYBuffer); ArraySetAsSeries(iJPYBuffer,true); ArraySetAsSeries(xJPYBuffer,true);} break;
            case 4: {SetIndexBuffer(4,CHFBuffer); ArraySetAsSeries(iCHFBuffer,true); ArraySetAsSeries(xCHFBuffer,true);} break;
            case 5: {SetIndexBuffer(5,AUDBuffer); ArraySetAsSeries(iAUDBuffer,true); ArraySetAsSeries(xAUDBuffer,true);} break;
            case 6: {SetIndexBuffer(6,CADBuffer); ArraySetAsSeries(iCADBuffer,true); ArraySetAsSeries(xCADBuffer,true);} break;
            case 7: {SetIndexBuffer(7,NZDBuffer); ArraySetAsSeries(iNZDBuffer,true); ArraySetAsSeries(xNZDBuffer,true);}
           }
         SetIndexStyle(i,DRAW_LINE,0,1);
         SetIndexDrawBegin(i,Bars-SBarCS-1);
         SetIndexLabel(i,Currency[i]);
         Name=StringConcatenate(Name,Currency[i]," ");
        }
   Name=Name+")";
   if (ma_period<1) ma_period=1;
   if (ma_method>3) ma_method=3;
   if (select_indicator<0) select_indicator=0;
   if (select_indicator>3) select_indicator=3;
   if (period_indicator<1) period_indicator=1;
   switch(select_indicator)
     {
      case 1: Name=StringConcatenate(Name,"+CCI(",period_indicator,")"); break;
      case 2: Name=StringConcatenate(Name,"+Momentum(",period_indicator,")"); break;
      case 3: Name=StringConcatenate(Name,"+RSI(",period_indicator,")");
     }
   Name=StringConcatenate(Name,"+MA(",ma_period,",",ma_method,")");
   IndicatorDigits(2);
   IndicatorShortName(Name);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int      b,c,Bar,limit,BarsCS;
   double   Change,Price,CIndex[8],Value[8];
   string   Nm,Dm;
   datetime BTime;
//----
   if (stop) return(-1);
   
   int size=ArraySize(USDBuffer);
   
   ArrayResize(xUSDBuffer,size);
   ArrayResize(xEURBuffer,size);
   ArrayResize(xGBPBuffer,size);
   ArrayResize(xJPYBuffer,size);
   ArrayResize(xCHFBuffer,size);
   ArrayResize(xAUDBuffer,size);
   ArrayResize(xCADBuffer,size);
   ArrayResize(xNZDBuffer,size);
   
   ArrayResize(iUSDBuffer,size);
   ArrayResize(iEURBuffer,size);
   ArrayResize(iGBPBuffer,size);
   ArrayResize(iJPYBuffer,size);
   ArrayResize(iCHFBuffer,size);
   ArrayResize(iAUDBuffer,size);
   ArrayResize(iCADBuffer,size);
   ArrayResize(iNZDBuffer,size);   
   
   /*if (isNewBar())
     {
      BarsCS=iBarShift(NULL,0,SPoint);
      if (show_CUR[0]) {ArrayResize(iUSDBuffer,BarsCS); ArrayResize(xUSDBuffer,BarsCS);}
      if (show_CUR[1]) {ArrayResize(iEURBuffer,BarsCS); ArrayResize(xEURBuffer,BarsCS);}
      if (show_CUR[2]) {ArrayResize(iGBPBuffer,BarsCS); ArrayResize(xGBPBuffer,BarsCS);}
      if (show_CUR[3]) {ArrayResize(iJPYBuffer,BarsCS); ArrayResize(xJPYBuffer,BarsCS);}
      if (show_CUR[4]) {ArrayResize(iCHFBuffer,BarsCS); ArrayResize(xCHFBuffer,BarsCS);}
      if (show_CUR[5]) {ArrayResize(iAUDBuffer,BarsCS); ArrayResize(xAUDBuffer,BarsCS);}
      if (show_CUR[6]) {ArrayResize(iCADBuffer,BarsCS); ArrayResize(xCADBuffer,BarsCS);}
      if (show_CUR[7]) {ArrayResize(iNZDBuffer,BarsCS); ArrayResize(xNZDBuffer,BarsCS);}
      for(i=BarsCS-1;i>0;i--)
        {
         if (show_CUR[0]) {iUSDBuffer[i]=iUSDBuffer[i-1]; xUSDBuffer[i]=xUSDBuffer[i-1];}
         if (show_CUR[1]) {iEURBuffer[i]=iEURBuffer[i-1]; xEURBuffer[i]=xEURBuffer[i-1];}
         if (show_CUR[2]) {iGBPBuffer[i]=iGBPBuffer[i-1]; xGBPBuffer[i]=xGBPBuffer[i-1];}
         if (show_CUR[3]) {iJPYBuffer[i]=iJPYBuffer[i-1]; xJPYBuffer[i]=xJPYBuffer[i-1];}
         if (show_CUR[4]) {iCHFBuffer[i]=iCHFBuffer[i-1]; xCHFBuffer[i]=xCHFBuffer[i-1];}
         if (show_CUR[5]) {iAUDBuffer[i]=iAUDBuffer[i-1]; xAUDBuffer[i]=xAUDBuffer[i-1];}
         if (show_CUR[6]) {iCADBuffer[i]=iCADBuffer[i-1]; xCADBuffer[i]=xCADBuffer[i-1];}
         if (show_CUR[7]) {iNZDBuffer[i]=iNZDBuffer[i-1]; xNZDBuffer[i]=xNZDBuffer[i-1];}
        }
     }*/

   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+period_indicator;
        
   //limit=Bars-IndicatorCounted();
   //if (limit>BarsCS) limit=BarsCS;
   for(b=limit;b>=0;b--)
     {
      ArrayInitialize(Value,0);
      ArrayInitialize(CIndex,1.0);
      BTime=iTime(NULL,0,b);
      for(i=0;i<23;i++)
        {
         Bar=iBarShift(Symbols[i],0,BTime);
         switch(applied_price)
           {
            case PRICE_CLOSE:    Price=iClose(Symbols[i],0,Bar); break;
            case PRICE_MEDIAN:   Price=(iHigh(Symbols[i],0,Bar)+iLow(Symbols[i],0,Bar))/2; break;
            case PRICE_TYPICAL:  Price=(iHigh(Symbols[i],0,Bar)+iLow(Symbols[i],0,Bar)+iClose(Symbols[i],0,Bar))/3; break;
            case PRICE_WEIGHTED: Price=(iHigh(Symbols[i],0,Bar)+iLow(Symbols[i],0,Bar)+iClose(Symbols[i],0,Bar)+iClose(Symbols[i],0,Bar))/4;
           }
         Change=Price/SPrice[i];
         Nm=StringSubstr(Symbols[i],0,3);
         Dm=StringSubstr(Symbols[i],3,3);
         for(c=0;c<8;c++) if (show_CUR[c])
              {
               if (Nm==Currency[c]) {CIndex[c]*=Change; Value[c]++;}
               if (Dm==Currency[c]) {CIndex[c]/=Change; Value[c]++;}
              }
        }
      for(c=0;c<8;c++) if (show_CUR[c])
           {
            CIndex[c]=100*MathPow(CIndex[c],1/Value[c]);
            if (reverse_index && DmCS==Currency[c]) CIndex[c]=200-CIndex[c];
           }
       if (show_CUR[0]) iUSDBuffer[b]=CIndex[0];
       if (show_CUR[1]) iEURBuffer[b]=CIndex[1];
       if (show_CUR[2]) iGBPBuffer[b]=CIndex[2];
       if (show_CUR[3]) iJPYBuffer[b]=CIndex[3];
       if (show_CUR[4]) iCHFBuffer[b]=CIndex[4];
       if (show_CUR[5]) iAUDBuffer[b]=CIndex[5];
       if (show_CUR[6]) iCADBuffer[b]=CIndex[6];
       if (show_CUR[7]) iNZDBuffer[b]=CIndex[7];
     }
   //if (limit>1 && select_indicator>0) limit=BarsCS-period_indicator-1;
   for(b=limit-1;b>=0;b--)
     {
      switch(select_indicator)
        {
         case 0:
           {
            if (show_CUR[0]) xUSDBuffer[b]=iUSDBuffer[b];
            if (show_CUR[1]) xEURBuffer[b]=iEURBuffer[b];
            if (show_CUR[2]) xGBPBuffer[b]=iGBPBuffer[b];
            if (show_CUR[3]) xJPYBuffer[b]=iJPYBuffer[b];
            if (show_CUR[4]) xCHFBuffer[b]=iCHFBuffer[b];
            if (show_CUR[5]) xAUDBuffer[b]=iAUDBuffer[b];
            if (show_CUR[6]) xCADBuffer[b]=iCADBuffer[b];
            if (show_CUR[7]) xNZDBuffer[b]=iNZDBuffer[b];
           } break;
         case 1:
           {
            if (show_CUR[0]) xUSDBuffer[b]=iCCIOnArray(iUSDBuffer,0,period_indicator,b);
            if (show_CUR[1]) xEURBuffer[b]=iCCIOnArray(iEURBuffer,0,period_indicator,b);
            if (show_CUR[2]) xGBPBuffer[b]=iCCIOnArray(iGBPBuffer,0,period_indicator,b);
            if (show_CUR[3]) xJPYBuffer[b]=iCCIOnArray(iJPYBuffer,0,period_indicator,b);
            if (show_CUR[4]) xCHFBuffer[b]=iCCIOnArray(iCHFBuffer,0,period_indicator,b);
            if (show_CUR[5]) xAUDBuffer[b]=iCCIOnArray(iAUDBuffer,0,period_indicator,b);
            if (show_CUR[6]) xCADBuffer[b]=iCCIOnArray(iCADBuffer,0,period_indicator,b);
            if (show_CUR[7]) xNZDBuffer[b]=iCCIOnArray(iNZDBuffer,0,period_indicator,b);
           } break;
         case 2:
           {
            if (show_CUR[0]) xUSDBuffer[b]=iMomentumOnArray(iUSDBuffer,0,period_indicator,b);
            if (show_CUR[1]) xEURBuffer[b]=iMomentumOnArray(iEURBuffer,0,period_indicator,b);
            if (show_CUR[2]) xGBPBuffer[b]=iMomentumOnArray(iGBPBuffer,0,period_indicator,b);
            if (show_CUR[3]) xJPYBuffer[b]=iMomentumOnArray(iJPYBuffer,0,period_indicator,b);
            if (show_CUR[4]) xCHFBuffer[b]=iMomentumOnArray(iCHFBuffer,0,period_indicator,b);
            if (show_CUR[5]) xAUDBuffer[b]=iMomentumOnArray(iAUDBuffer,0,period_indicator,b);
            if (show_CUR[6]) xCADBuffer[b]=iMomentumOnArray(iCADBuffer,0,period_indicator,b);
            if (show_CUR[7]) xNZDBuffer[b]=iMomentumOnArray(iNZDBuffer,0,period_indicator,b);
           } break;
         case 3:
           {
            if (show_CUR[0]) xUSDBuffer[b]=iRSIOnArray(iUSDBuffer,0,period_indicator,b);
            if (show_CUR[1]) xEURBuffer[b]=iRSIOnArray(iEURBuffer,0,period_indicator,b);
            if (show_CUR[2]) xGBPBuffer[b]=iRSIOnArray(iGBPBuffer,0,period_indicator,b);
            if (show_CUR[3]) xJPYBuffer[b]=iRSIOnArray(iJPYBuffer,0,period_indicator,b);
            if (show_CUR[4]) xCHFBuffer[b]=iRSIOnArray(iCHFBuffer,0,period_indicator,b);
            if (show_CUR[5]) xAUDBuffer[b]=iRSIOnArray(iAUDBuffer,0,period_indicator,b);
            if (show_CUR[6]) xCADBuffer[b]=iRSIOnArray(iCADBuffer,0,period_indicator,b);
            if (show_CUR[7]) xNZDBuffer[b]=iRSIOnArray(iNZDBuffer,0,period_indicator,b);
           }
        }
     }
   //if (limit>1) limit=limit-ma_period-1;
   for(b=limit;b>=0;b--)
     {
      if (show_CUR[0]) USDBuffer[b]=NormalizeDouble(iMAOnArray(xUSDBuffer,0,ma_period,0,ma_method,b),2);
      if (show_CUR[1]) EURBuffer[b]=NormalizeDouble(iMAOnArray(xEURBuffer,0,ma_period,0,ma_method,b),2);
      if (show_CUR[2]) GBPBuffer[b]=NormalizeDouble(iMAOnArray(xGBPBuffer,0,ma_period,0,ma_method,b),2);
      if (show_CUR[3]) JPYBuffer[b]=NormalizeDouble(iMAOnArray(xJPYBuffer,0,ma_period,0,ma_method,b),2);
      if (show_CUR[4]) CHFBuffer[b]=NormalizeDouble(iMAOnArray(xCHFBuffer,0,ma_period,0,ma_method,b),2);
      if (show_CUR[5]) AUDBuffer[b]=NormalizeDouble(iMAOnArray(xAUDBuffer,0,ma_period,0,ma_method,b),2);
      if (show_CUR[6]) CADBuffer[b]=NormalizeDouble(iMAOnArray(xCADBuffer,0,ma_period,0,ma_method,b),2);
      if (show_CUR[7]) NZDBuffer[b]=NormalizeDouble(iMAOnArray(xNZDBuffer,0,ma_period,0,ma_method,b),2);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isNewBar()
  {
   bool res=false;
   if (AllBars!=Bars)
     {
      AllBars=Bars;
      res=true;
     }
   return(res);
  }
//+------------------------------------------------------------------+

