//+----------------------------------------------------------------------------+
//|                                                               информер.mq4 |
//|                                      Copyright © 2009, Maxim `ax` Sviridov |
//|                                                 http://ax.tm3912.ru/trade/ |
//|                                                                            |
//| 13.11.2009 Пофиксена ошибка "zero divide", небольшая оптимизация           | 
//| 30.12.2009 Метки для незакрытых позиций, магик-фильтр, уровни TP&SL        |
//|            корректное удаление объектов индикатора                         |
//| 07.01.2010 Язык Englesh or not (Russian)                                   |
//+----------------------------------------------------------------------------+
#property copyright "Copyright © 2009, Maxim `ax` Sviridov"
#property link      "http://ax.tm3912.ru/trade/"

extern bool   Lang_Eng       = True;   // Englesh or not (Russian)

extern bool   DealMarkers    = True;    // Размечать сделки на графике или нет
extern bool   DepoStats      = True;    // Отображать статистику счёта
extern bool   ShowLive		  = True;	 // Показывать ценовые метки на незакрытые позиции или нет

extern string MagicFilter	  = "";		//	Если здесь перечислить MagicNumber (через запятую, без пробелов)
													//	то будут отображаться только сделки с этими мэджиками

extern color  clAccName      = Silver;  // Цвет подписи имени владальца аккаунта
extern color  clInfData      = Gray;    // Цвет подписей разных данных о счёте
extern int    FontSize       = 8;       // Размер шрифта
extern int    DigitsLength   = 9;       // Длинна денежных цыфр (для выравнивания) 
extern int    PercentLength  = 5;       // Длинна процентных цыфр (для выравнивания) 


extern color  clLineProfit   = Lime;    // Цвет прибыльных линий
extern color  clLineLoss     = Red;     // Цвет убыточных линий

extern color  clMarkerBuy    = Lime;    // Цвет метки покупки
extern color  clMarkerSell   = Red;     // Цвет метки продажи
extern color  clMarkerClose  = Silver;  // Цвет метки закрытия ордера


//------- Глобальные переменные -----------------------------------------------+

int      X,Y;           // начальные координаты
int      i;             // счётчик
int      inf_count;     // количество инфо-блоков
string   inf_name[10];  // Массив имён инфо-блоков
string   inf_data[10];  // Массив значений инфо-блоков

int      maxLengthN, maxLengthD;     // Максимальная длинна (для выравнивания текста)
string   accName;                    // Имя аккаунта



#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   X = 10;
   Y = 35;
   inf_count  = 8;            // Счёт, Депо, Баланс, Прибыль, Снятие, Залог, Позиция, Средства
   maxLengthN = 13; 
   maxLengthD = 18+(DigitsLength-6); 
   
   for(i=0; i<=inf_count-1; i++) {inf_name[i]="";inf_data[i]="";}
 
   if (Lang_Eng){
      inf_name[0] = "Account №: ";
      inf_name[1] = "Deposit: ";
      inf_name[2] = "Balance: ";
      inf_name[3] = "Profit: ";
      inf_name[4] = "Withdraw: ";
      inf_name[5] = "Margin: ";
      inf_name[6] = "Equity-Balance: ";
      inf_name[7] = "Equity: ";
   }else{  
      inf_name[0] = "Счёт №: ";
      inf_name[1] = "Депозит: ";
      inf_name[2] = "Баланс: ";
      inf_name[3] = "Прибыль: ";
      inf_name[4] = "Снятие: ";
      inf_name[5] = "Залог: ";
      inf_name[6] = "Позиция: ";
      inf_name[7] = "Средства: ";
   }

	if(MagicFilter != "") MagicFilter = "," + MagicFilter + ",";

   return(0);
 }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   // удалим все объекты созданные индикатором
   DeleteIndObjects();
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   if(DepoStats)  // Показать статистику счёта
   {
      string accName     = AccountName();
      string accNumber   = AccountNumber();
      string accCurrency = AccountCurrency();
      double accBalance  = AccountBalance();
      double accMargin   = AccountMargin();
      double accEquity   = AccountEquity();
      double accDepo     = Depo();
      double accProfit   = Profit();
      double accWidch    = Widch();
      
      int md = ((maxLengthN + maxLengthD - StringLen(accName))/2) + StringLen(accName);
      while(StringLen(accName) < md ) accName = accName + " ";
      
      
      string sign="";   // знак для изменения в процентах
      if (accBalance>accDepo) sign = "+";
      
      if(ObjectFind("AccountName")<0)ObjectCreate("AccountName", OBJ_LABEL, 0, 0, 0);
      ObjectSet("AccountName", OBJPROP_CORNER, 1);
      ObjectSetText("AccountName", accName, FontSize, "Lucida Console", clAccName);
      ObjectSet("AccountName", OBJPROP_XDISTANCE, X);
      ObjectSet("AccountName", OBJPROP_YDISTANCE, Y - 15);


      inf_data[0] = RAlignD(accNumber) + " (" + accCurrency + ") 1:" + AccountLeverage();   // Счёт №
      inf_data[1] = RAlignD(DoubleToStr(accDepo,2));
      inf_data[2] = RAlignD(DoubleToStr(accBalance, 2));   // Баланс
      inf_data[3] = RAlignD(DoubleToStr(accProfit,2));
      inf_data[4] = RAlignD(DoubleToStr(accWidch,2));              // Снятие
      inf_data[5] = RAlignD(DoubleToStr(accMargin,2));             // Залог
      inf_data[6] = RAlignD(DoubleToStr(accEquity-accBalance,2)) + " | " + RAlignP(DoubleToStr((accEquity/accBalance-1)*100,2)) + "%";  // 
      inf_data[7] = RAlignD(DoubleToStr(accEquity, 2));            // Эквити

      if(accDepo>0){
         inf_data[2] = inf_data[2] + " | " + RAlignP(sign + DoubleToStr(accProfit/accDepo*100,2)) + "%" ;
         inf_data[7] = inf_data[7] + " | " + RAlignP(DoubleToStr((accEquity/accDepo-1)*100,2)) + "%";
      }
      
      for(i=0; i<=inf_count-1; i++) // Для всех инфо-блоков обновим значения
      {  
         //if (inf_name[i]=="") continue; // Пропустим пустые
         while(StringLen(inf_data[i]) < maxLengthD) inf_data[i] = inf_data[i] + " ";
         if(ObjectFind(inf_name[i])<0) ObjectCreate(inf_name[i], OBJ_LABEL, 0, 0, 0);
         ObjectSet(inf_name[i], OBJPROP_CORNER, 1);
         ObjectSetText(inf_name[i], inf_name[i] + inf_data[i], FontSize, "Lucida Console", clInfData);
         ObjectSet(inf_name[i], OBJPROP_XDISTANCE, X);
         ObjectSet(inf_name[i], OBJPROP_YDISTANCE, Y + i*11);
      }
   }
   // Визуализация сделок на графике
   if (DealMarkers || ShowLive){
      datetime ot, ct;
      double   op, cp, tp, sl;
      int      i,  ty, k, iMagicNum;

		if (DealMarkers){
         k=OrdersHistoryTotal();
         for (i=0; i<k; i++){
            if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){
		    		if(MagicFilter != "") {
		 	  	     	iMagicNum = OrderMagicNumber();
			   		iMagicNum = StringFind(MagicFilter, "," + iMagicNum + ",");
               }
				  else iMagicNum = 1;
            
              ty=OrderType();
				  if (OrderSymbol()==Symbol() && ty<2 && iMagicNum != -1){
                  ot=OrderOpenTime();
                  op=OrderOpenPrice();
                  ct=OrderCloseTime();
                  cp=OrderClosePrice();
                  SetObj(OrderTicket(), ty, ot, op, ct, cp);
               }
            }
         }
      }
      
		if (ShowLive) {
			k=OrdersTotal();
			for (i=0; i<k; i++) {
				if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
					if(MagicFilter != "") {
						iMagicNum = OrderMagicNumber();
						iMagicNum = StringFind(MagicFilter, "," + iMagicNum + ",");
					}
					else iMagicNum = 1;
					ty=OrderType();
					
					if (OrderSymbol()==Symbol() && ty<2 && iMagicNum != -1){
                  ot=OrderOpenTime();
                  op=OrderOpenPrice();
                  tp=OrderTakeProfit();
                  sl=OrderStopLoss();
						SetObj(OrderTicket(), ty, ot, op, 0, 0, tp, sl);
					}
				}
			}
		}
   }
   return(0);
  }
//+----------------------------------------------------------------------------+

//+----------------------------------------------------------------------------+
string RAlignD(string s="") {
while(StringLen(s) < DigitsLength) s = StringConcatenate(" ", s);
return(s);}
//+----------------------------------------------------------------------------+
string RAlignP(string s="") {
while(StringLen(s) < PercentLength+3) s = StringConcatenate(" ", s);
return(s);}
//+----------------------------------------------------------------------------+
double Depo(){int y=0; double d=0;
for(y=0;y<OrdersHistoryTotal();y++){OrderSelect(y,SELECT_BY_POS,MODE_HISTORY);
if(OrderType()==6 && OrderProfit()>0) d+=OrderProfit();}
return(d);}
//+----------------------------------------------------------------------------+
double Widch(){int y=0; double w=0;
for(y=0;y<OrdersHistoryTotal();y++){OrderSelect(y,SELECT_BY_POS,MODE_HISTORY);
if(OrderType()==6 && OrderProfit()<0) w+=OrderProfit();}
return(w);}
//+----------------------------------------------------------------------------+
double Profit(){int y=0; double p=0;
for(y=0;y<OrdersHistoryTotal();y++){OrderSelect(y,SELECT_BY_POS,MODE_HISTORY);
if(OrderType()<2) p+=OrderProfit()+OrderSwap()+OrderCommission();}
return(p);}
//+----------------------------------------------------------------------------+
//|  SetObj: установка объектов                                                |
//|  Параметры:                                                                |
//|    or - номер объекта                                                      |
//|    ty - операция                                                           |
//|    ot - дата, время открытия                                               |
//|    op - цена открытия                                                      |
//|    ct - дата, время закрытия                                               |
//|    cp - цена закрытия                                                      |
//|    tp - цена тейк-профита                                                  |
//|    sl - цена стоп-лоса                                                     |
//+----------------------------------------------------------------------------+
void SetObj(int or, int ty, datetime ot, double op, datetime ct=0, double cp=0, double tp=0, double sl=0)
{

   datetime tc = TimeCurrent()-(240*Period());
   datetime tf = TimeCurrent()+(600*Period());


   // Линия от открытия до закрытия сделки
   if (ct!=0)
   {
      string no="Deal";

      if(ObjectFind(no+or)<0) ObjectCreate(no+or, OBJ_TREND, 0, 0, 0, 0, 0);
         ObjectSet(no+or, OBJPROP_STYLE, STYLE_DOT);
         ObjectSet(no+or, OBJPROP_TIME1 , ot);
         ObjectSet(no+or, OBJPROP_PRICE1, op);
         ObjectSet(no+or, OBJPROP_TIME2 , ct);
         ObjectSet(no+or, OBJPROP_PRICE2, cp);
   
      if(ty==OP_BUY){
         if (op<cp) ObjectSet(no+or, OBJPROP_COLOR, clLineProfit);
         if (op>cp) ObjectSet(no+or, OBJPROP_COLOR, clLineLoss);
      }
  
      if(ty==OP_SELL){
         if (op>cp) ObjectSet(no+or, OBJPROP_COLOR, clLineProfit);
         if (op<cp) ObjectSet(no+or, OBJPROP_COLOR, clLineLoss);
      }
      
      ObjectSet(no+or, OBJPROP_RAY , False);
      
      // удаляем уже не нужное
      if (ObjectFind("ADealTP"+or)!=-1)      ObjectDelete("ADealTP"+or);  
      if (ObjectFind("ADealTP-l-"+or)!=-1)   ObjectDelete("ADealTP-l-"+or);  
      if (ObjectFind("ADealSL"+or)!=-1)      ObjectDelete("ADealSL"+or);  
      if (ObjectFind("ADealSL-l-"+or)!=-1)   ObjectDelete("ADealSL-l-"+or);  
    }

   // Метки открытия сделок   
   no="ADealOp";
   if (ObjectFind(no+or)<0) ObjectCreate(no+or, OBJ_ARROW, 0, 0,0); ObjectSet(no+or, OBJPROP_TIME1, ot);
   if (ty==OP_BUY){
      ObjectSet(no+or, OBJPROP_PRICE1   , op);
      ObjectSet(no+or, OBJPROP_COLOR    , clMarkerBuy);
      ObjectSet(no+or, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
   }
   if (ty==OP_SELL){
      ObjectSet(no+or, OBJPROP_PRICE1   , op);
      ObjectSet(no+or, OBJPROP_COLOR    , clMarkerSell);
      ObjectSet(no+or, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
   }

   // Метки закрытия сделок   
   if (cp!=0){
      no="ADealCl";
      if (ObjectFind(no+or)<0) ObjectCreate(no+or, OBJ_ARROW, 0, 0,0); ObjectSet(no+or, OBJPROP_TIME1, ct);
      ObjectSet(no+or, OBJPROP_PRICE1  , cp);
      ObjectSet(no+or, OBJPROP_COLOR   , clMarkerClose);
      ObjectSet(no+or, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
   }
   
   // Метки тейк-профита
   if (tp!=0)
   {
      no="ADealTP";
      
      if (ObjectFind(no+or)<0) ObjectCreate(no+or, OBJ_ARROW, 0, 0,0); ObjectSet(no+or, OBJPROP_TIME1, tf);
      ObjectSet(no+or, OBJPROP_PRICE1  , tp);
      ObjectSet(no+or, OBJPROP_COLOR   , clLineProfit);
      ObjectSet(no+or, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
      
      if(ObjectFind(no+"-l-"+or)<0) ObjectCreate(no+"-l-"+or, OBJ_TREND, 0, 0, 0, 0, 0);
         ObjectSet(no+"-l-"+or, OBJPROP_RAY , False);
         ObjectSet(no+"-l-"+or, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSet(no+"-l-"+or, OBJPROP_TIME1 , tc);
         ObjectSet(no+"-l-"+or, OBJPROP_PRICE1, tp);
         ObjectSet(no+"-l-"+or, OBJPROP_TIME2 , tf+60*Period());
         ObjectSet(no+"-l-"+or, OBJPROP_PRICE2, tp);
         ObjectSet(no+"-l-"+or, OBJPROP_COLOR, clLineProfit);
   } 
   

   // Метки стоп-лоса   
   if (sl!=0)
   {
      no="ADealSL";
      
      if (ObjectFind(no+or)<0) ObjectCreate(no+or, OBJ_ARROW, 0, 0,0); ObjectSet(no+or, OBJPROP_TIME1, tf);
      ObjectSet(no+or, OBJPROP_PRICE1  , sl);
      ObjectSet(no+or, OBJPROP_COLOR   , clLineLoss);
      ObjectSet(no+or, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
      
      if(ObjectFind(no+"-l-"+or)<0) ObjectCreate(no+"-l-"+or, OBJ_TREND, 0, 0, 0, 0, 0);
         ObjectSet(no+"-l-"+or, OBJPROP_RAY , False);
         ObjectSet(no+"-l-"+or, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSet(no+"-l-"+or, OBJPROP_TIME1 , tc);
         ObjectSet(no+"-l-"+or, OBJPROP_PRICE1, sl);
         ObjectSet(no+"-l-"+or, OBJPROP_TIME2 , tf+60*Period());
         ObjectSet(no+"-l-"+or, OBJPROP_PRICE2, sl);
         ObjectSet(no+"-l-"+or, OBJPROP_COLOR, clLineLoss);
   } 
}
//+----------------------------------------------------------------------------+
void DeleteIndObjects()
{
   int ot, iMagicNum;
   
   // Удалить стат-данные
   ObjectDelete("AccountName");
   for(i=0; i<=inf_count-1; i++) ObjectDelete(inf_name[i]);
   
   // Удалить маркеры позиций
   if (DealMarkers){
      int i,  ty, k=OrdersHistoryTotal();
      for (i=0; i<k; i++){
         if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){
            ty=OrderType();
            ot=OrderTicket();
            if (OrderSymbol()==Symbol() && ty<2){
               ObjectDelete("ADealOp"+ot);
               ObjectDelete("ADealCl"+ot);
               ObjectDelete("Deal"+ot);
            }
         }
      }
   }
   
   if (ShowLive){
      if (OrdersTotal()>0){
 			k=OrdersTotal();
			for (i=0; i<k; i++) {
				if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
					if(MagicFilter != "") {
						iMagicNum = OrderMagicNumber();
						iMagicNum = StringFind(MagicFilter, "," + iMagicNum + ",");
					}
					else iMagicNum = 1;
					ty=OrderType();
					ot=OrderTicket();
					if (OrderSymbol()==Symbol() && ty<2 && iMagicNum != -1){
                  ObjectDelete("ADealOp"+ot);
                  ObjectDelete("ADealTP"+ot);
                  ObjectDelete("ADealTP-l-"+ot);
                  ObjectDelete("ADealSL"+ot);
                  ObjectDelete("ADealSL-l-"+ot);
					}
				}
			}
      }
   }
}