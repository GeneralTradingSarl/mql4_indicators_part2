//+------------------------------------------------------------------+
//|                                                    TPEHEP_MM.mq4 |
//|                                                   Copyright 2016.|
//+------------------------------------------------------------------+
#property link      "Fedor10_10@mail.ru"
#property version   "1.02"
#property strict
#property indicator_chart_window
#property description "Индикатор TPEHEP_MM предназначен для тестирования стратегии"
#property description "на истории в пошаговом режиме с автоматическим контролем"
#property description "исполнения приказов, ошибок, и созданием отчета для Excel."
#property description "  Горячие клавиши:  'B'- BUY,  'S'- SELL,  'C'- CLOSE"
#property description "                                   F12 или Step- сдвиг графика на 1 шаг"
#property description "                                   '<'- Область влево, '>'- Область вправо"
#property description "                                   'P'- сохранение файла отчета"
extern string K="+:+:+:+";     //Параметры исполнения приказов
input bool    Traid=true;      //Торговля/Разметка
input double  Lots=0.01;       //Лот Фиксированный или Минимальный
extern double Risk=0.0;        //ММ %Риска от StopLoss. 0- Фиксированный Лот
input double  LotsMax=10.0;    //максимальный Лот
extern double StopLoss=100.0;  //StopLoss (в 5-значном)
extern double TakeProfit=100.0;//TakeProfit (в 5-значном)
extern double Money=100.0;     //Начальные средства
extern double Spread=0.0;      //Спред (в 5-значном) 0 - из истории
extern double Freeze=0.0;      //Заморозка (в 5-значном) 0 - из истории
extern string M="+:+:+:+";     //разное
input bool    Color=true;      //фон белый/черный
input bool    Vertical=true;   //рисование/нет вертикальных линий
input bool    Alerts=false;    //запрет предупреждений
input bool    Gluk=false;      //устранение конфликта с Exel
input int     Step=46;         //Клавиша сдвига графика на 1 шаг
color  Zone,OpBUY,OpSELL,ClsAll,TakePr,StopLs;
int    tik,bar0,Ordr,Tr,SH,file;
double Ask0,Ask1,Bid0,Bid1,Lev,LevOrd,LevUp,LevDn,lott,MaxLot,MinLot;
string FileName,FileNamo,Namo,Uplev,Oplev,Dnlev;
long   result,resold;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Color)//фон белый
     {
      Zone=clrSilver;      //цвет выделения рассматриваемого бара
      OpBUY=clrSteelBlue;  //цвет линии BUY
      OpSELL=clrPlum;      //цвет линии SELL
      ClsAll=clrDarkOrange;//цвет линии закрытия ручного
      TakePr=clrLimeGreen; //цвет линии закрытия по TakeProfit
      StopLs=clrYellow;    //цвет линии закрытия по StopLoss
        }else{//фон черный
      Zone=clrDimGray;     //цвет выделения рассматриваемого бара
      OpBUY=clrLightSkyBlue;//цвет линии BUY
      OpSELL=clrLightPink; //цвет линии SELL
      ClsAll=clrKhaki;     //цвет линии закрытия ручного
      TakePr=clrPaleGreen; //цвет линии закрытия по TakeProfit
      StopLs=clrYellow;    //цвет линии закрытия по StopLoss
     }
   FileName=Symbol()+"."+IntegerToString(Period())+" ";//временный файл для записи сделок
   if(Traid)//пропуск при отказе от расчета
     {
      if(Spread==0.0) Spread=MarketInfo(Symbol(),MODE_SPREAD);//Спред
      if(Spread==0.0) Alert("Spread ","не определен");
      Spread=NormalizeDouble((Spread*Point),Digits);//спред
      if(Freeze==0.0) Freeze=MarketInfo(Symbol(),MODE_FREEZELEVEL);//уровень заморозки
      if(Freeze==0.0) Alert("Уровень заморозки ","не определен");
      Freeze=NormalizeDouble((Freeze*Point),Digits);//уровень заморозки
      Lev=NormalizeDouble((MarketInfo(Symbol(),MODE_STOPLEVEL)*Point),Digits);//минимальный стоп
      if(Lev==0.0) Alert("STOPLEVEL ","не определен");
      else
        {
         if(StopLoss<Lev) {StopLoss=Lev; Alert("StopLoss=",StopLoss/Point);}
         if(TakeProfit<Lev) {TakeProfit=Lev; Alert("TakeProfit=",TakeProfit/Point);}
        }
      TakeProfit=NormalizeDouble((TakeProfit*Point),Digits);//TakeProfit
      StopLoss=NormalizeDouble((StopLoss*Point),Digits);//StopLoss
      Risk=(Risk/100)/(StopLoss/Point);//перевод в коэффициент MM
      MinLot=NormalizeDouble((MarketInfo(Symbol(),MODE_MINLOT)),Digits);//минимальный стоп
      if(MinLot>0.0) MinLot=fmax(Lots,MinLot); else MinLot=Lots;
      MaxLot=NormalizeDouble((MarketInfo(Symbol(),MODE_MAXLOT)),Digits);//минимальный стоп
      if(MaxLot>0.0) MaxLot=fmin(LotsMax,MaxLot); else MaxLot=LotsMax;
      lott=Lot();
      Comment("Spread=",IntegerToString(int(Spread/Point)),"\n","Freeze=",IntegerToString(int(Freeze)),"\n",
              "StopLoss=",IntegerToString(int(StopLoss/Point)),"\n","TakeProfit=",
              IntegerToString(int(TakeProfit/Point)),"\n","MINLOT=",MinLot,"\n","MAXLOT=",MaxLot);
      ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,result);//количество пикселей по Х
      ObjectCreate("Show1",OBJ_LABEL,0,0,0); //место отрисовки на экране
      ObjectSet("Show1",OBJPROP_XDISTANCE,result/2-200);
      ObjectSet("Show1",OBJPROP_YDISTANCE,0);
      ObjectSet("Show1",OBJPROP_CORNER,0);
      ObjectSetText("Show1","ЛОТ:          ПРОФИТ:               БАЛАНС:               ",14,"Arial",clrDarkGray);//надпись
      ObjectCreate("Show2",OBJ_LABEL,0,0,0); //место отрисовки на экране
      ObjectSet("Show2",OBJPROP_XDISTANCE,result/2-155);
      ObjectSet("Show2",OBJPROP_YDISTANCE,0);
      ObjectSet("Show2",OBJPROP_CORNER,0);
      ObjectSetText("Show2",DoubleToString(lott,2),14,"Arial",clrBlueViolet);//ЛОТ
      ObjectCreate("Show3",OBJ_LABEL,0,0,0); //место отрисовки на экране
      ObjectSet("Show3",OBJPROP_XDISTANCE,result/2-15);
      ObjectSet("Show3",OBJPROP_YDISTANCE,0);
      ObjectSet("Show3",OBJPROP_CORNER,0);
      ObjectSetText("Show3",DoubleToString(0.0,2),14,"Arial",clrBlueViolet);//ПРОФИТ
      ObjectCreate("Show4",OBJ_LABEL,0,0,0); //место отрисовки на экране
      ObjectSet("Show4",OBJPROP_XDISTANCE,result/2+140);
      ObjectSet("Show4",OBJPROP_YDISTANCE,0);
      ObjectSet("Show4",OBJPROP_CORNER,0);
      ObjectSetText("Show4",DoubleToString(Money,2),14,"Arial",clrBlueViolet);//БАЛАНС
      resold=result;
      file=FileOpen(FileName,FILE_WRITE|FILE_SHARE_READ|FILE_TXT);
      FileWrite(file,"  Ticket\tOpnDate\tOpnTime\t    Type\t    Size\t   Item\t  Price\tClsDate\tClsTime\t  Price\tTradeP/L\t  Equity");
     }
   ObjectCreate("Zona",OBJ_TREND,0,Time[0],(Close[0]-StopLoss),Time[0],(Close[0]+StopLoss));//выделяем область рассматриваемого бара
   ObjectSet("Zona",OBJPROP_STYLE,DRAW_LINE);
   ObjectSet("Zona",OBJPROP_WIDTH,8);
   ObjectSet("Zona",OBJPROP_COLOR,Zone);
   ObjectSet("Zona",OBJPROP_BACK,true);
   ObjectSet("Zona",OBJPROP_RAY_RIGHT,false);
   ObjectSet("Zona",OBJPROP_TIME1,Time[0]);//уточним
   ObjectSet("Zona",OBJPROP_PRICE1,(Close[0]-StopLoss));//уточним
   ObjectSet("Zona",OBJPROP_TIME2,Time[0]);//уточним
   ObjectSet("Zona",OBJPROP_PRICE2,(Close[0]+StopLoss));//уточним
   ChartRedraw(); //перерисуем
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(Traid) FileClose(file);//сохранение после расчета
   ObjectDel();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   return(rates_total);//пустышка
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // идентификатор события
                  const long& lparam,   // параметр события типа long
                  const double& dparam, // параметр события типа double
                  const string& sparam) // параметр события типа string
  {
//+------------------------------------------------------------------+
//| проверка нажатия клавиши или мышки                               |
//+------------------------------------------------------------------+
   if(CHARTEVENT_CHART_CHANGE)
     {
      ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,result);//контроль за размером экрана
      if(result!=resold) Show(result);
     }
   if(Traid && Ordr!=0)
     {
      if(id==CHARTEVENT_OBJECT_DRAG)
        {
         if(sparam==Uplev)//проверка верхнего уровня
            if(LevUp!=ObjectGet(Uplev,OBJPROP_PRICE1))
               LevUp=MouseUp();//при изменении уровня
         if(sparam==Dnlev)//проверка нижнего уровня
            if(LevDn!=ObjectGet(Dnlev,OBJPROP_PRICE1))
               LevDn=MouseDn();//при изменении уровня
        }
     }
   if(id==CHARTEVENT_KEYDOWN)
     {
      switch(int(lparam))
        {
         case 37: Alert("Попытка повторить историю"); break;//KEY_LEFT_ARROW
         case 39: Alert("Пошаговая прокрутка по F12"); break;//KEY_RIGHT_ARROW по F12
         case 66: if(Traid)
           {
            if(Ordr==0)//KEY_BUY
              {
               Ordr=bar0;
               Levl("BUY");//рисуем линии открытия и стопы
               if(Vertical) Vert("BUY",OpBUY);//рисуем вертикальную линию BUY
              }
            else Alert("Сделка уже открыта");
           }
         else if(Tr!=1){Tr=1; Vert("BUY",OpBUY);}//рисуем вертикальную линию BUY
         else Alert("Тренд вверх уже отмечен");
         tik++; if(tik==1) {Namo=TimeToString(Time[Bar()],TIME_DATE); Comment("");}
         break;
         case 67: if(Traid)
           {
            if(Ordr!=0)//KEY_CLOSE
              {
               if(Freez()) break;//проверка на заморозку
               if(Vertical) Vert("CL",ClsAll);//рисуем вертикальную линию Clоsе
               Profit("CL",Ordr);//подсчитаем итог
               Ordr=0; if(Traid) Delet();//удаление уровней
              }
            else Alert("Нет сделки");
           }
         else if(Tr!=0) {Tr=0; Vert("CL",ClsAll);}//рисуем вертикальную линию Clоsе
         else Alert("Тренд не отмечен");
         break;
         case 80:
            if(tik<1)//чистый шаблон
              {
               ObjectsDeleteAll();  Comment("");
               if(ChartSaveTemplate(0,FileName+"."))
                  Alert("шаблон ",FileName," сохранен"); break;
              }
            else
              {
               ObjectDel();
               FileNamo=FileName+Namo+"-"+TimeToString(Time[Bar()],TIME_DATE);
               if(Traid)//сохранение файла отчета
                 {
                  FileFlush(file); FileClose(file);
                  if(FileMove(FileName,0,FileNamo+".xls",FILE_REWRITE))
                     Alert("отчет ",FileNamo," сохранен");
                  if(ChartSaveTemplate(0,FileNamo+"."))//шаблон с разметкой
                     Alert("разметка ",FileNamo," сохранена"); break;
                 }
               else//шаблон с разметкой
                 {
                  if(ChartSaveTemplate(0,FileNamo+"."))
                     Alert("разметка ",FileNamo," сохранена"); break;
                 }
              }
         case 83: if(Traid)
           {
            if(Ordr==0)//KEY_SELL
              {
               Ordr=-bar0;
               Levl("SEL");//рисуем линии открытия и стопы
               if(Vertical) Vert("SEL",OpSELL);//рисуем вертикальную линию SELL
              }
            else Alert("Сделка уже открыта");
           }
         else if(Tr!=-1) {Tr=-1; Vert("SEL",OpSELL);}//рисуем вертикальную линию SELL
         else Alert("Тренд вниз уже отмечен");
         tik++; if(tik==1) {Namo=TimeToString(Time[Bar()],TIME_DATE); Comment("");}
         break;
         case 188: SH++;//KEY_LEFT
         if(SH>WindowBarsPerChart()){Alert("Область на границе слева"); SH=WindowBarsPerChart();}
         break;//увеличим номер рассматриваемого бара
         case 190: SH--;//KEY_RIGHT
         if(SH<0){Alert("Область на границе справа"); SH=0;}
         break;//уменьшим номер рассматриваемого бара 
         default: if(lparam==Step) {ChartNavigate(0,CHART_CURRENT_POS,1); break;}//KEY_Shift
         else Alert("Нажата не та клавиша",(lparam));
        }
     }
   if(Bar()<=0) {if(tik>0) Alert("Прорисован последний бар"); return;}//контроль окончания истории
   bar0=Bar()+SH;//номер нужного бара на графике
   if(Time[bar0]!=ObjectGet("Zona",OBJPROP_TIME1))//проверим рассматриваемый бар
     {
      Bid0=Close[bar0]; Ask0=Close[bar0]+Spread;//цена закрытия рассматриваемого бара
      Bid1=Open[bar0-1]; Ask1=Open[bar0-1]+Spread;//цена открытия будущего бара
      LevStop();//проверка автоматического срабатывания уровней 
      Prof();//проверка средств
      ObjectSet("Zona",OBJPROP_TIME1,Time[bar0]);//изменение привязки рассматриваемого бара
      ObjectSet("Zona",OBJPROP_PRICE1,(Close[bar0]-StopLoss+Spread));//изменение нижнего уровня рассматриваемого бара
      ObjectSet("Zona",OBJPROP_TIME2,Time[bar0]);//изменение привязки рассматриваемого бара
      ObjectSet("Zona",OBJPROP_PRICE2,(Close[bar0]+StopLoss-Spread));//изменение верхнего уровня рассматриваемого бара
      ChartRedraw();//перерисуем
     }
  }
//+------------------------------------------------------------------+
//| приложения                                                       |
//+------------------------------------------------------------------+
void LevStop()//проверка автоматического срабатывания приказов
  {
   if(Ordr>0)//контроль BUY
     {
      if(Low[bar0]<=LevDn)//при пробитии нижнего уровня
        {
         if(Vertical) Vert("SL",StopLs);
         if(Traid) {Profit("SL",Ordr); Delet();}
         if(Alerts) Alert("Сработал StopLoss");
         Ordr=0;
        }
      if(High[bar0]>=LevUp)//при пробитии верхнего уровня
        {
         if(Vertical) Vert("TP",TakePr);
         if(Traid) {Profit("TP",Ordr); Delet();}
         if(Alerts) Alert("сработал TakeProfit");
         Ordr=0;
        }
     }
   if(Ordr<0)//контроль SELL
     {
      if(High[bar0]+Spread>=LevUp)//при пробитии верхнего уровня
        {
         if(Vertical) Vert("SL",StopLs);
         if(Traid) {Profit("SL",Ordr); Delet();}
         if(Alerts) Alert("Сработал StopLoss");
         Ordr=0;
        }
      if(Low[bar0]+Spread<=LevDn)//при пробитии нижнего уровня
        {
         if(Vertical) Vert("TP",TakePr);
         if(Traid) {Profit("TP",Ordr); Delet();}
         if(Alerts) Alert("сработал TakeProfit");
         Ordr=0;
        }
     }
  }
//+------------------------------------------------------------------+
double Lot()//MoneyManagement
  {
   if(Risk>0.0)
     {
      double LotResult=Money*Risk;//расчет лота
      LotResult=fmax(LotResult,MinLot);//не меньше
      LotResult=fmin(LotResult,MaxLot);//и не больше
      return(LotResult);//Что получилось
     }
   else return(MinLot);
  }
//+------------------------------------------------------------------+
void Profit(string cmd,int ord)//бухгалтерия
  {
   if(ord>0)//был BUY   Bid-Ask
     {
      if(cmd=="CL") Write("CL_BUY",ord,Time[bar0-1],Bid1,NormalizeDouble(Bid1-LevOrd,Digits));//Man
      if(cmd=="SL") Write("SL_BUY",ord,Time[bar0],LevDn,NormalizeDouble(LevDn-LevOrd,Digits));//SL
      if(cmd=="TP") Write("TP_BUY",ord,Time[bar0],LevUp,NormalizeDouble(LevUp-LevOrd,Digits));//TP
     }
   if(ord<0)//был SELL  Ask-Bid
     {
      if(cmd=="CL") Write("CL_SEL",ord,Time[bar0-1],Ask1,NormalizeDouble(LevOrd-Ask1,Digits));//Man
      if(cmd=="SL") Write("SL_SEL",ord,Time[bar0],LevUp,NormalizeDouble(LevOrd-LevUp,Digits));//SL
      if(cmd=="TP") Write("TP_SEL",ord,Time[bar0],LevDn,NormalizeDouble(LevOrd-LevDn,Digits));//TP
     }
  }
//+------------------------------------------------------------------+
void Write(string cmd,int ord,datetime tm,double cls,double pip)//запись в файл
  {
   Money+=NormalizeDouble(lott*(pip/Point),2);//общий итог в центах
   FileWrite(file,tik,"\t",Dat(TimeToStr(Time[fabs(ord)],TIME_DATE)),"\t",TimeToStr(Time[fabs(ord)],TIME_SECONDS),
             "\t",cmd,"\t",Rus(DoubleToString(lott,2)),"\t",Symbol(),"\t",Rus(DoubleToString(LevOrd,Digits)),
             "\t",Dat(TimeToStr(tm,TIME_DATE)),"\t",TimeToStr(tm,TIME_SECONDS),"\t",Rus(DoubleToString(cls,Digits)),
             "\t",Rus(DoubleToString(lott*(pip/Point),2)),"\t",Rus(DoubleToString(Money,2)));
   lott=Lot();//новый ЛОТ
   ObjectSetText("Show2",DoubleToString(lott,2),14,"Arial",clrBlueViolet);
   Trend(cmd,ord,pip); Metca(cmd,ord);//рисуем результат
  }
//+------------------------------------------------------------------+
void Trend(string cmd,int ord,double pip)//рисуем линию от открытия до закрытия
  {
   string name="Trl"+IntegerToString(tik);
   color clr=clrBlue; if(pip<0) clr=clrRed;
   if(cmd=="CL_BUY") Tr(name, ord,Bid1,Time[bar0-1],clr);//Man
   if(cmd=="SL_BUY") Tr(name, ord,LevDn,Time[bar0], clr);//SL
   if(cmd=="TP_BUY") Tr(name, ord,LevUp,Time[bar0], clr);//TP
   if(cmd=="CL_SEL") Tr(name,-ord,Ask1,Time[bar0-1],clr);//Man
   if(cmd=="SL_SEL") Tr(name,-ord,LevUp,Time[bar0], clr);//SL
   if(cmd=="TP_SEL") Tr(name,-ord,LevDn,Time[bar0], clr);//TP
  }
//+------------------------------------------------------------------+
void Tr(string cmd,int ord,double pr,datetime tm,color clr)//рисуем линию от открытия до закрытия
  {
   ObjectCreate(cmd,OBJ_TREND,0,Time[ord-1],LevOrd,tm,pr);
   ObjectSetInteger(0,cmd,OBJPROP_RAY_RIGHT,false);//отключим (false) отображение линии вправо
   ObjectSet(cmd,OBJPROP_STYLE,STYLE_DOT);
   ObjectSet(cmd,OBJPROP_COLOR,clr);
   ChartRedraw();//перерисуем
  }
//+------------------------------------------------------------------+
void Metca(string cmd,int ord)//рисуем ценовую метку
  {
   if(cmd=="CL_BUY")
     {
      Met("OP_BUY"+IntegerToString(tik),LevOrd+5*Point,Time[ord-1],OpBUY);//Open BUY
      Met("CL_BUY"+IntegerToString(tik),Bid1+5*Point,Time[bar0-1],ClsAll);//Man BUY
     }
   if(cmd=="SL_BUY")
     {
      Met("OP_BUY"+IntegerToString(tik),LevOrd+5*Point,Time[ord-1],OpBUY);//Open BUY
      Met("SL_BUY"+IntegerToString(tik),LevDn+5*Point,Time[bar0],StopLs);//SL BUY
     }
   if(cmd=="TP_BUY")
     {
      Met("OP_BUY"+IntegerToString(tik),LevOrd+5*Point,Time[ord-1],OpBUY);//Open BUY
      Met("TP_BUY"+IntegerToString(tik),LevUp+5*Point,Time[bar0],TakePr);//TP BUY
     }
   if(cmd=="CL_SEL")
     {
      Met("OP_SELL"+IntegerToString(tik),LevOrd+5*Point,Time[-ord-1],OpSELL);//Open SELL
      Met("CL_SELL"+IntegerToString(tik),Ask1+5*Point,Time[bar0-1],ClsAll);//Man SELL
     }
   if(cmd=="SL_SEL")
     {
      Met("OP_SELL"+IntegerToString(tik),LevOrd+5*Point,Time[-ord-1],OpSELL);//Open SELL
      Met("SL_SELL"+IntegerToString(tik),LevUp+5*Point,Time[bar0],StopLs);//SL SELL
     }
   if(cmd=="TP_SEL")
     {
      Met("OP_SELL"+IntegerToString(tik),LevOrd+5*Point,Time[-ord-1],OpSELL);//Open SELL
      Met("TP_SELL"+IntegerToString(tik),LevDn+5*Point,Time[bar0],TakePr);//TP SELL
     }
  }
//+------------------------------------------------------------------+
void Met(string cmd,double pr,datetime tm,color clr)//рисуем ценовую метку
  {
   ObjectCreate(cmd,OBJ_ARROW_LEFT_PRICE,0,tm,pr);
   ObjectSet(cmd,OBJPROP_ARROWCODE,119);
   ObjectSet(cmd,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(cmd,OBJPROP_COLOR,clr);
   ChartRedraw();//перерисуем
  }
//+------------------------------------------------------------------+
void Vert(string cmd,color clr)//рисуем вертикальную линию
  {
   cmd+=IntegerToString(tik);
   ObjectCreate(cmd,OBJ_VLINE,0,Time[bar0],0);
   ObjectSet(cmd,OBJPROP_STYLE,STYLE_DASH);
   ObjectSet(cmd,OBJPROP_COLOR,clr);
   ObjectSet(cmd,OBJPROP_BACK,true);
   ChartRedraw();//перерисуем
  }
//+------------------------------------------------------------------+
void Levl(string cmd)//рисуем горизонтальные линии приказов
  {
   Oplev=cmd;
   if(cmd=="BUY")
     {
      LevOrd=Ask1;//уровень Ask открытия
      Uplev="TakeProfit"; LevUp=LevOrd+TakeProfit;//уровень Bid StopLoss от открытия
      Dnlev="StopLoss"; LevDn=LevOrd-StopLoss;//уровень Bid TakeProfit от открытия
     }
   if(cmd=="SEL")
     {
      LevOrd=Bid1;//уровень Bid открытия
      Uplev="StopLoss"; LevUp=LevOrd+StopLoss;//уровень Ask TakeProfit от открытия
      Dnlev="TakeProfit"; LevDn=LevOrd-TakeProfit;//уровень Ask StopLoss от открытия
     }
   ObjectCreate(Uplev,OBJ_HLINE,0,0,LevUp);
   ObjectSet(Uplev,OBJPROP_STYLE,STYLE_DASHDOT);
   ObjectSet(Uplev,OBJPROP_COLOR,clrOrangeRed);
   ObjectSetInteger(0,Uplev,OBJPROP_BACK,true);
   ObjectCreate(Oplev,OBJ_HLINE,0,0,LevOrd);
   ObjectSet(Oplev,OBJPROP_STYLE,STYLE_DASHDOT);
   ObjectSet(Oplev,OBJPROP_COLOR,clrLimeGreen);
   ObjectSetInteger(0,Oplev,OBJPROP_BACK,true);
   ObjectCreate(Dnlev,OBJ_HLINE,0,0,LevDn);
   ObjectSet(Dnlev,OBJPROP_STYLE,STYLE_DASHDOT);
   ObjectSet(Dnlev,OBJPROP_COLOR,clrOrangeRed);
   ObjectSetInteger(0,Dnlev,OBJPROP_BACK,true);
   ChartRedraw();//перерисуем
  }
//+------------------------------------------------------------------+
string Rus(string ru)//Функция заменяет(.)на(,)для русской Excel
  {
   if(Gluk) StringReplace(ru,".",",");
   return ru;
  }
//+------------------------------------------------------------------+
string Dat(string dt)//Функция заменяет(.)на(,)для русской Excel
  {
   if(Gluk) StringReplace(dt,"."," ");
   return dt;
  }
//+------------------------------------------------------------------+
void Prof()//прорисовка профита
  {
   double rezalt;
   if(Ordr>0)
     {
      rezalt=lott*(Bid1-LevOrd)/Point;//при возможном закрытии фиксация на этом уровне
      if(Money+rezalt<0.0 || Money+lott*(Low[bar0]-LevOrd)/Point<0.0) End();//кончились средства
     }
   else if(Ordr<0)
     {
      rezalt=lott*(LevOrd-Ask1)/Point;//при возможном закрытии фиксация на этом уровне
      if(Money+rezalt<0.0 || Money+lott*(LevOrd-High[bar0]+Spread)/Point<0.0) End();//кончились средства
     }
   else rezalt=0.0;
   color Cl=clrBlueViolet; if(rezalt<0.0) Cl=clrCrimson;//цвет ПРОФИТА
   ObjectSetText("Show3",DoubleToString(rezalt,2),14,"Arial",Cl);//ПРОФИТ
   ObjectSetText("Show4",DoubleToString((Money+rezalt),2),14,"Arial",clrBlueViolet);//изменение результата
  }
//+------------------------------------------------------------------+
bool Freez()//заморозка
  {
   if(Ordr>0)
     {
      if(LevUp<=Bid0+Freeze)
        {
         Alert("TakeProfit в зоне заморозки");
         return(true);
        }
      if(LevDn>=Bid0-Freeze)
        {
         Alert("StopLoss в зоне заморозки");
         return(true);
        }
     }
   if(Ordr<0)
     {
      if(LevUp<=Ask0+Freeze)
        {
         Alert("StopLoss в зоне заморозки");
         return(true);
        }
      if(LevDn>=Ask0-Freeze)
        {
         Alert("TakeProfit в зоне заморозки");
         return(true);
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
int Bar()//номер первого видимого бара на графике.
  {
   long res=0;// подготовим переменную
   res+=ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0,res);//запросим номер левого бара 
   res-=WindowBarsPerChart()+1;//найдем номер правого бара
   return(int(res));//--- вернем номер нужного бара
  }
//+------------------------------------------------------------------+
void Delet()//проверка уровней
  {
   ObjectDelete(Uplev);//удаление верхнего уровня
   ObjectDelete(Oplev);//удаление уровня открытия
   ObjectDelete(Dnlev);//удаление нижнего уровня
   ChartRedraw();//перерисуем
  }
//+------------------------------------------------------------------+
double MouseUp()
  {
   if(Freez()) ObjectSet(Uplev,OBJPROP_PRICE1,LevUp);//возвращаем линию на старое место
   else
     {
      if(Ordr>0 && ObjectGet(Uplev,OBJPROP_PRICE1)<=Ask0+Lev)//если линия в зоне минимума
        {
         Alert("TakeProfit= ",Lev,"+1");
         ObjectSet(Uplev,OBJPROP_PRICE1,(Ask0+Lev+Point));//отводим TakeProfit за минимум
        }
      if(Ordr<0 && ObjectGet(Uplev,OBJPROP_PRICE1)<=Bid0+Lev)//если линия в зоне минимума
        {
         Alert("StopLoss= ",Lev,"+1");
         ObjectSet(Uplev,OBJPROP_PRICE1,(Bid0+Lev+Point));//отводим StopLoss за минимум
        }
     }
// ObjectSetInteger(0,Uplev,OBJPROP_SELECTED,false);//закроем
   ChartRedraw();//перерисуем
   return(ObjectGet(Uplev,OBJPROP_PRICE1));//возвращаем верхний выставленный уровень
  }
//+------------------------------------------------------------------+
double MouseDn()
  {
   if(Freez()) ObjectSet(Dnlev,OBJPROP_PRICE1,LevDn);//возвращаем линию на старое место
   else
     {
      if(Ordr>0 && ObjectGet(Dnlev,OBJPROP_PRICE1)>=Ask0-Lev)//если линия в зоне минимума
        {
         Alert("StopLoss= ",Lev,"+1");
         ObjectSet(Dnlev,OBJPROP_PRICE1,(Ask0-Lev-Point));//отводим StopLoss за минимум
        }
      if(Ordr<0 && ObjectGet(Dnlev,OBJPROP_PRICE1)>=Bid0-Lev)//если линия в зоне минимума
        {
         Alert("StopLoss= ",Lev,"+1");
         ObjectSet(Dnlev,OBJPROP_PRICE1,(Bid0-Lev-Point));//отводим TakeProfit за минимум
        }
     }
//ObjectSetInteger(0,Dnlev,OBJPROP_SELECTED,false);//закроем
   ChartRedraw();//перерисуем
   return(ObjectGet(Dnlev,OBJPROP_PRICE1));//возвращаем нижний выставленный уровень
  }
//+------------------------------------------------------------------+
void Show(long res)//контроль за размером экрана
  {
   ObjectSet("Show1",OBJPROP_XDISTANCE,res/2-200);
   ObjectSet("Show2",OBJPROP_XDISTANCE,res/2-155);
   ObjectSet("Show3",OBJPROP_XDISTANCE,res/2-15);
   ObjectSet("Show4",OBJPROP_XDISTANCE,res/2+140);
   ChartRedraw();//перерисуем
   resold=result;
  }
//+------------------------------------------------------------------+
void End()//конец
  {
   ObjectDel();
   ObjectCreate("Show7",OBJ_LABEL,0,0,0); //место отрисовки на экране
   ObjectSet("Show7",OBJPROP_XDISTANCE,result/2-275);
   ObjectSet("Show7",OBJPROP_YDISTANCE,350);
   ObjectSet("Show7",OBJPROP_CORNER,0);
   ObjectSetText("Show7","СОХРАНИТЕ ОТЧЕТ (Р)  И ПЕРЕУСТАНОВИТЕ СТРАТЕГИЮ!",14,"Arial",clrDarkGray);//надпись GAME OVER
   ObjectCreate("Show8",OBJ_LABEL,0,0,0); //место отрисовки на экране
   ObjectSet("Show8",OBJPROP_XDISTANCE,result/2-500);
   ObjectSet("Show8",OBJPROP_YDISTANCE,50);
   ObjectSet("Show8",OBJPROP_CORNER,0);
   ObjectSetText("Show8","GAME OVER",125,"Arial",clrBrown);//надпись GAME OVER
  }
//+------------------------------------------------------------------+
void ObjectDel()
  {
   ObjectDelete("Zona");
   ObjectDelete("Show1");
   ObjectDelete("Show2");
   ObjectDelete("Show3");
   ObjectDelete("Show4");
   ObjectDelete("Show5");
   ObjectDelete("Show6");
   ChartRedraw();//перерисуем
  }
//+------------------------------------------------------------------+
