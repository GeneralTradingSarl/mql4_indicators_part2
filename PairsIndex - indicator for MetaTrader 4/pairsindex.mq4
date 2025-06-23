//+------------------------------------------------------------------+
//|                                                   PairsIndex.mq4 |
//|         Copyright 2015,  Roy Roberto Philips Jacobs ~ 20/05/2015 |
//|                              https://www.mql5.com/en/users/3rjfx |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015,  3rjfx ~ 20/05/2015"
#property link      "http://www.mql5.com"
#property link      "https://www.mql5.com/en/users/3rjfx"
#property version   "1.00"
//---
#property indicator_separate_window
//---
extern string PairsIndex="Copyright © 2015 3rjfx";
//--- spacing
int scaleX=60,scaleY=21,scaleYt=18,offsetX=250,offsetY=0,fontSize=9; // coordinate
double scaleXp=71.5;
//--- arrays for various things
int TF[]={5,15,30,60,240,1440}; // Timeframes CCI
int TFM[]={5,5,5,5,15,30}; // Timeframes MA
int TFsto[]={5,15,30,60,240}; // Timeframes Stochastic
int TFosm[]={5,15,30,60,240}; // Timeframes OsMA
int prCCI[]={3,3,3,3,3,3}; // CCI Period
int light=174; // Arrow code wingdings
//---
//PRICE_CLOSE = 0 = Close price. 
//PRICE_OPEN = 1 = Open price. 
//PRICE_HIGH = 2 = High price. 
//PRICE_LOW = 3 = Low price. 
//PRICE_MEDIAN = 4 = Median price, (high+low)/2. 
//PRICE_TYPICAL = 5 = Typical price, (high+low+close)/3. 
//PRICE_WEIGHTED = 6 = Weighted close price, (high+low+close+close)/4.
//---
int maprc=0;
int ccprc=0;
int xdig=0;
int xx;
int rts;
double xr;
//---
string periodStr[]={" 5 MIN","15 MIN","30 MIN"," 1 HR "," 4 HR ","DAILY","SUGGEST","     PROFITPOINTS"}; // Text Timeframes
string labelNameStr[]={"TIMEFRAMES","TRAFFICSIGNAL","DIRECTION","POINTSRANGE","PAIRSINDEX"}; // Indicator labels
//---
string prx0[]={"AUDCHF","AUDNZD","AUDUSD","AUDJPY","AUDCAD","EURAUD","GBPAUD"}; // 7 pairs AUD
string prx1[]={"USDCAD","EURCAD","AUDCAD","NZDCAD","GBPCAD","CADCHF","CADJPY"}; // 7 pairs CAD
string prx2[]={"GBPCHF","USDCHF","EURCHF","AUDCHF","NZDCHF","CADCHF","CHFJPY"}; // 7 pairs CHF
string prx3[]={"EURAUD","EURUSD","EURJPY","EURGBP","EURCHF","EURCAD","EURNZD"}; // 7 pairs EUR
string prx4[]={"GBPUSD","GBPJPY","GBPCHF","GBPCAD","GBPAUD","GBPNZD","EURGBP"}; // 7 pairs GBP
string prx5[]={"GBPJPY","USDJPY","EURJPY","NZDJPY","CHFJPY","AUDJPY","CADJPY"}; // 7 pairs JPY
string prx6[]={"NZDJPY","NZDUSD","NZDCHF","NZDCAD","EURNZD","AUDNZD","GBPNZD"}; // 7 pairs NZD
string prx7[]={"USDCHF","USDCAD","USDJPY","AUDUSD","EURUSD","GBPUSD","NZDUSD"}; // 7 pairs USD
int TFpr[]={5,15,30,60}; // Timeframes Index __Symbols
//---
string CRi;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CRi="Copyright © 2015 3rjfx";
//--- indicators
   EventSetTimer(60);
//---
   IndicatorShortName("PairsIndex ("+_Symbol+","+strTF(_Period)+")");
//--- Checking the Digits Point
   if(Digits==3 || Digits==5)
     {xr=Point*10; xdig=1; xx=10;}
   else {xr=Point; xdig=0; xx=1;}
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll();
//---
   EventKillTimer();
   GlobalVariablesDeleteAll();
//---
   return;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//---
   if(PairsIndex!=CRi) return(0);
//---
   int r,x,y,aB,aS,aW,dB,dS,dW;
   int stB,stS;
   int osmB,osmS;
   int angry=76;
   int sarca=75;
   int smile=74;
   int stop=251;
//--- Symbols Index -->
   int auu,aud;
   int cau,cad;
   int chu,chd;
   int euu,eud;
   int gbu,gbd;
   int jpu,jpd;
   int nzu,nzd;
   int usu,usd;
//---
   bool AUup;
   bool CAup;
   bool CHup;
   bool EUup;
   bool GBup;
   bool JPup;
   bool NZup;
   bool USup;
//---
   RefreshRates();
   string hr=StringSubstr(TimeToStr(TimeCurrent(),TIME_MINUTES),0,2);
   string mi=StringSubstr(TimeToStr(TimeCurrent(),TIME_MINUTES),3,2);
   string sc=StringSubstr(TimeToStr(TimeCurrent(),TIME_SECONDS),6,2);
   string tztxt;
   int tcurr=TimeHour(TimeCurrent()); // Server Time == GMT+2 == (05:00 AM WIB-Jakarta Time)
   if(tcurr==23) {tztxt="NYC/NZD";} // 04 WIB -> (23+5-24= 04:00 AM WIB -> Server Time + 5 Hours = WIB or Jakarta Time)
   if(tcurr==0) {tztxt="NZD";}  // 05 WIB
   if(tcurr==1) {tztxt="NZD/AUS";} // 06 WIB
   if(tcurr>=2 && tcurr<=4) {tztxt="NZD/AUS/TOK";} // 07 -> <= 09 WIB
   if(tcurr>=5 && tcurr<=8) {tztxt="AUS/TOK";} // 10 -> <= 13 WIB
   if(tcurr>=9 && tcurr<=10) {tztxt="AUS/TOK/LON";} // 14 -> <= 15 WIB
   if(tcurr>=11 && tcurr<=13) {tztxt="LON";}  // 16 -> <= 18 WIB
   if(tcurr>=14 && tcurr<=18) {tztxt="LON/NYC";} // 19 -> <= 23 WIB
   if(tcurr>=19 && tcurr<=22) {tztxt="NYC";} // 24(00) -> <= 03 WIB
//---
   int totalord=OrdersTotal();
   int orb=0,ors=0;
   double bprovit,sprovit;
   double atrB,atrS;
   string ptxt=" ";
//---
   for(int i=0; i<totalord; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==True)
        {
         if(OrderSymbol()==_Symbol)
           {
            if(OrderType()==OP_BUY)
              {
               bprovit+=((Bid-OrderOpenPrice())/xr);
               atrB=OrderOpenPrice()-iATR(_Symbol,240,20,0)*0.7;
               orb++;
              }
            if(OrderType()==OP_SELL)
              {
               sprovit+=((OrderOpenPrice()-Ask)/xr);
               atrS=OrderOpenPrice()+iATR(_Symbol,240,20,0)*0.7;
               ors++;
              }
           }
        }
     }
//---
   if(orb==0) {bprovit=0;}
   if(ors==0) {sprovit=0;}
//--- create timeframe text labels 
   for(x=0;x<8;x++)
     {
      ObjectCreate("txPeriod"+x+y,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("txPeriod"+x+y,periodStr[x],fontSize,"Bodoni MT Black",Snow);
      ObjectSet("txPeriod"+x+y,OBJPROP_CORNER,0);
      ObjectSet("txPeriod"+x+y,OBJPROP_XDISTANCE,x*scaleX+offsetX);
      ObjectSet("txPeriod"+x+y,OBJPROP_YDISTANCE,y*scaleY+offsetY+7);
     }
//--- create indicator labels time
   ObjectCreate("txTime"+y+"0",OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
   ObjectSetText("txTime"+y+"0",StringConcatenate("H: ",hr),11,"Arial Bold",Gold);
   ObjectSet("txTime"+y+"0",OBJPROP_CORNER,0);
   ObjectSet("txTime"+y+"0",OBJPROP_XDISTANCE,offsetX-230);
   ObjectSet("txTime"+y+"0",OBJPROP_YDISTANCE,0*scaleYt+offsetY+29);
//---
   ObjectCreate("txTime"+y+"1",OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
   ObjectSetText("txTime"+y+"1",StringConcatenate("M: ",mi),11,"Arial Bold",Gold);
   ObjectSet("txTime"+y+"1",OBJPROP_CORNER,0);
   ObjectSet("txTime"+y+"1",OBJPROP_XDISTANCE,offsetX-232);
   ObjectSet("txTime"+y+"1",OBJPROP_YDISTANCE,1*scaleYt+offsetY+29);
//---
   ObjectCreate("txTime"+y+"2",OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
   ObjectSetText("txTime"+y+"2",StringConcatenate("S: ",sc),11,"Arial Bold",Gold);
   ObjectSet("txTime"+y+"2",OBJPROP_CORNER,0);
   ObjectSet("txTime"+y+"2",OBJPROP_XDISTANCE,offsetX-229);
   ObjectSet("txTime"+y+"2",OBJPROP_YDISTANCE,2*scaleYt+offsetY+29);
//---
   ObjectCreate("txTime"+y+"3",OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
   ObjectSetText("txTime"+y+"3",StringConcatenate("EST TZ:  ",tztxt),8,"Arial Bold",Gold);
   ObjectSet("txTime"+y+"3",OBJPROP_CORNER,0);
   ObjectSet("txTime"+y+"3",OBJPROP_XDISTANCE,offsetX-243);
   ObjectSet("txTime"+y+"3",OBJPROP_YDISTANCE,3*scaleYt+offsetY+38);
//--- create indicator arrow trend consideration
   RefreshRates();
   ObjectDelete("txCons"+y+"0");
   ObjectDelete("txCons"+y+"0"+"a");
   ObjectDelete("txCons"+y+"0"+"a"+"1");
//---
   double mcdm[],mcds[];
   ArrayResize(mcdm,100);
   ArrayResize(mcds,100);
   ArraySetAsSeries(mcdm,true);
   ArraySetAsSeries(mcds,true);
//---
   for(int mm=99; mm>=0; mm--)
     {mcdm[mm]=iMA(_Symbol,0,12,0,1,0,mm)-iMA(_Symbol,0,26,0,1,0,mm);}
   for(int ms=99; ms>=0; ms--)
     {mcds[ms]=iMAOnArray(mcdm,0,9,0,0,ms);}
//---
   if((mcdm[0]>mcds[0])&&(mcdm[0]>mcdm[1])) {bool bulls=true;}
   if((mcdm[0]<mcds[0])&&(mcdm[0]<mcdm[1])) {bool bears=true;}
   if((mcdm[1]<=mcds[1])&&(mcdm[0]>=mcds[0])&&(mcdm[0]>mcdm[1])) {bulls=true; bears=false;}
   if((mcdm[1]>=mcds[1])&&(mcdm[0]<=mcds[0])&&(mcdm[0]<mcdm[1])) {bears=true; bulls=false;}
//---
   if(bulls==true)
     {
      ObjectCreate("txCons"+y+"0",OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("txCons"+y+"0",CharToStr(164),25,"Wingdings",Lime);
      ObjectSet("txCons"+y+"0",OBJPROP_CORNER,0);
      ObjectSet("txCons"+y+"0",OBJPROP_XDISTANCE,offsetX-172);
      ObjectSet("txCons"+y+"0",OBJPROP_YDISTANCE,1*scaleYt+offsetY+19);
      //---
      ObjectCreate("txCons"+y+"0"+"a",OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("txCons"+y+"0"+"a",CharToStr(217),18,"Wingdings",Lime);
      ObjectSet("txCons"+y+"0"+"a",OBJPROP_CORNER,0);
      ObjectSet("txCons"+y+"0"+"a",OBJPROP_XDISTANCE,offsetX-168);
      ObjectSet("txCons"+y+"0"+"a",OBJPROP_YDISTANCE,0*scaleYt+offsetY+24);
      //---
      ObjectCreate("txCons"+y+"0"+"a"+"1",OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("txCons"+y+"0"+"a"+"1","BULLISH",6,"Bodoni MT Black",Yellow);
      ObjectSet("txCons"+y+"0"+"a"+"1",OBJPROP_CORNER,0);
      ObjectSet("txCons"+y+"0"+"a"+"1",OBJPROP_XDISTANCE,offsetX-178);
      ObjectSet("txCons"+y+"0"+"a"+"1",OBJPROP_YDISTANCE,2*scaleYt+offsetY+32);
     }
//---
   if(bears==true)
     {
      ObjectCreate("txCons"+y+"0",OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("txCons"+y+"0",CharToStr(164),25,"Wingdings",Red);
      ObjectSet("txCons"+y+"0",OBJPROP_CORNER,0);
      ObjectSet("txCons"+y+"0",OBJPROP_XDISTANCE,offsetX-172);
      ObjectSet("txCons"+y+"0",OBJPROP_YDISTANCE,1*scaleYt+offsetY+19);
      //---
      ObjectCreate("txCons"+y+"0"+"a",OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("txCons"+y+"0"+"a",CharToStr(218),18,"Wingdings",Red);
      ObjectSet("txCons"+y+"0"+"a",OBJPROP_CORNER,0);
      ObjectSet("txCons"+y+"0"+"a",OBJPROP_XDISTANCE,offsetX-168);
      ObjectSet("txCons"+y+"0"+"a",OBJPROP_YDISTANCE,2*scaleYt+offsetY+22);
      //---
      ObjectCreate("txCons"+y+"0"+"a"+"1",OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("txCons"+y+"0"+"a"+"1","BEARISH",6,"Bodoni MT Black",Yellow);
      ObjectSet("txCons"+y+"0"+"a"+"1",OBJPROP_CORNER,0);
      ObjectSet("txCons"+y+"0"+"a"+"1",OBJPROP_XDISTANCE,offsetX-178);
      ObjectSet("txCons"+y+"0"+"a"+"1",OBJPROP_YDISTANCE,0*scaleYt+offsetY+31);
     }
//---
   else
     {
      ObjectCreate("txCons"+y+"0",OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("txCons"+y+"0",CharToStr(164),25,"Wingdings",Yellow);
      ObjectSet("txCons"+y+"0",OBJPROP_CORNER,0);
      ObjectSet("txCons"+y+"0",OBJPROP_XDISTANCE,offsetX-172);
      ObjectSet("txCons"+y+"0",OBJPROP_YDISTANCE,1*scaleYt+offsetY+19);
     }
//--- create indicator text labels
   for(y=0;y<5;y++)
     {
      ObjectCreate("txLabel"+y,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("txLabel"+y,labelNameStr[y],fontSize,"Bodoni MT Black",Snow);
      ObjectSet("txLabel"+y,OBJPROP_CORNER,0);
      ObjectSet("txLabel"+y,OBJPROP_XDISTANCE,offsetX-120);
      ObjectSet("txLabel"+y,OBJPROP_YDISTANCE,y*scaleY+offsetY+7);
     }
//---
   ObjectCreate("arInd"+x+y,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
   ObjectSetText("arInd"+x+y,StringConcatenate("BUY :  ",DoubleToStr(NormalizeDouble(bprovit*xx,xdig),xdig),ptxt),
                 fontSize,"Bodoni MT Black",Lime);
   ObjectSet("arInd"+x+y,OBJPROP_CORNER,0);
   ObjectSet("arInd"+x+y,OBJPROP_XDISTANCE,7*scaleX+offsetX+15); // scaleX == 83, offsetX == 220
   ObjectSet("arInd"+x+y,OBJPROP_YDISTANCE,1*scaleY+offsetY+15);
//--- create order profit BUY and smile
   if(orb==0)
     {
      ObjectCreate("arInd"+x+y+3,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("arInd"+x+y+3,CharToStr(69),21,"Wingdings",Lime);
      ObjectSet("arInd"+x+y+3,OBJPROP_CORNER,0);
      ObjectSet("arInd"+x+y+3,OBJPROP_XDISTANCE,7*scaleX+offsetX+108); // scaleX == 83, offsetX == 220
      ObjectSet("arInd"+x+y+3,OBJPROP_YDISTANCE,1*scaleY+offsetY+7);
     }
   if(orb>0)
     {
      if(bprovit>0)
        {
         ObjectCreate("arInd"+x+y+3,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
         ObjectSetText("arInd"+x+y+3,CharToStr(smile),21,"Wingdings",Snow);
         ObjectSet("arInd"+x+y+3,OBJPROP_CORNER,0);
         ObjectSet("arInd"+x+y+3,OBJPROP_XDISTANCE,7*scaleX+offsetX+110); // scaleX == 83, offsetX == 220
         ObjectSet("arInd"+x+y+3,OBJPROP_YDISTANCE,1*scaleY+offsetY+7);
        }
      else if(bprovit<0)
        {
         ObjectCreate("arInd"+x+y+3,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
         ObjectSetText("arInd"+x+y+3,CharToStr(angry),21,"Wingdings",Red);
         ObjectSet("arInd"+x+y+3,OBJPROP_CORNER,0);
         ObjectSet("arInd"+x+y+3,OBJPROP_XDISTANCE,7*scaleX+offsetX+110); // scaleX == 83, offsetX == 220
         ObjectSet("arInd"+x+y+3,OBJPROP_YDISTANCE,1*scaleY+offsetY+7);
        }
      else if(Bid<atrB)
        {
         ObjectCreate("arInd"+x+y+3,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
         ObjectSetText("arInd"+x+y+3,CharToStr(stop),21,"Wingdings",Red);
         ObjectSet("arInd"+x+y+3,OBJPROP_CORNER,0);
         ObjectSet("arInd"+x+y+3,OBJPROP_XDISTANCE,7*scaleX+offsetX+110); // scaleX == 83, offsetX == 220
         ObjectSet("arInd"+x+y+3,OBJPROP_YDISTANCE,1*scaleY+offsetY+7);
        }
      else
        {
         ObjectCreate("arInd"+x+y+3,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
         ObjectSetText("arInd"+x+y+3,CharToStr(sarca),21,"Wingdings",Yellow);
         ObjectSet("arInd"+x+y+3,OBJPROP_CORNER,0);
         ObjectSet("arInd"+x+y+3,OBJPROP_XDISTANCE,7*scaleX+offsetX+110); // scaleX == 83, offsetX == 220
         ObjectSet("arInd"+x+y+3,OBJPROP_YDISTANCE,1*scaleY+offsetY+7);
        }
     }
//---  
   ObjectCreate("txDir"+x+y,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
   ObjectSetText("txDir"+x+y,StringConcatenate("SELL:  ",DoubleToStr(NormalizeDouble(sprovit*xx,xdig),xdig),ptxt),
                 fontSize,"Bodoni MT Black",LightYellow);
   ObjectSet("txDir"+x+y,OBJPROP_CORNER,0);
   ObjectSet("txDir"+x+y,OBJPROP_XDISTANCE,7*scaleX+offsetX+15); // scaleX == 83, offsetX == 220
   ObjectSet("txDir"+x+y,OBJPROP_YDISTANCE,2*scaleY+offsetY+21);
//--- create order profit SELL and smile
   if(ors==0)
     {
      ObjectCreate("txDir"+x+y+3,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("txDir"+x+y+3,CharToStr(69),21,"Wingdings",LightYellow);
      ObjectSet("txDir"+x+y+3,OBJPROP_CORNER,0);
      ObjectSet("txDir"+x+y+3,OBJPROP_XDISTANCE,7*scaleX+offsetX+108); // scaleX == 83, offsetX == 220
      ObjectSet("txDir"+x+y+3,OBJPROP_YDISTANCE,2*scaleY+offsetY+13);
     }
   if(ors>0)
     {
      if(sprovit>0)
        {
         ObjectCreate("txDir"+x+y+3,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
         ObjectSetText("txDir"+x+y+3,CharToStr(smile),21,"Wingdings",Snow);
         ObjectSet("txDir"+x+y+3,OBJPROP_CORNER,0);
         ObjectSet("txDir"+x+y+3,OBJPROP_XDISTANCE,7*scaleX+offsetX+110); // scaleX == 83, offsetX == 220
         ObjectSet("txDir"+x+y+3,OBJPROP_YDISTANCE,2*scaleY+offsetY+13);
        }
      else if(sprovit<0)
        {
         ObjectCreate("txDir"+x+y+3,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
         ObjectSetText("txDir"+x+y+3,CharToStr(angry),21,"Wingdings",Red);
         ObjectSet("txDir"+x+y+3,OBJPROP_CORNER,0);
         ObjectSet("txDir"+x+y+3,OBJPROP_XDISTANCE,7*scaleX+offsetX+110); // scaleX == 83, offsetX == 220
         ObjectSet("txDir"+x+y+3,OBJPROP_YDISTANCE,2*scaleY+offsetY+13);
        }
      else if(Ask>atrS)
        {
         ObjectCreate("txDir"+x+y+3,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
         ObjectSetText("txDir"+x+y+3,CharToStr(stop),21,"Wingdings",Red);
         ObjectSet("txDir"+x+y+3,OBJPROP_CORNER,0);
         ObjectSet("txDir"+x+y+3,OBJPROP_XDISTANCE,7*scaleX+offsetX+110); // scaleX == 83, offsetX == 220
         ObjectSet("txDir"+x+y+3,OBJPROP_YDISTANCE,2*scaleY+offsetY+13);
        }
      else
        {
         ObjectCreate("txDir"+x+y+3,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
         ObjectSetText("txDir"+x+y+3,CharToStr(sarca),21,"Wingdings",Yellow);
         ObjectSet("txDir"+x+y+3,OBJPROP_CORNER,0);
         ObjectSet("txDir"+x+y+3,OBJPROP_XDISTANCE,7*scaleX+offsetX+110); // scaleX == 83, offsetX == 220
         ObjectSet("txDir"+x+y+3,OBJPROP_YDISTANCE,2*scaleY+offsetY+13);
        }
     }
//--- create count light arrows
   for(x=0;x<6;x++)
     {
      if((iMA(_Symbol,TFM[x],3,0,MODE_EMA,maprc,0)>iMA(_Symbol,TFM[x],3,0,MODE_EMA,maprc,1))
         && (iCCI(_Symbol,TF[x],prCCI[x],ccprc,0)>0)) // if entry cci above zero
        {
         if((iCCI(_Symbol,TF[x],prCCI[x],ccprc,0)>iCCI(_Symbol,TF[x],prCCI[x],ccprc,1)) || 
            (iCCI(_Symbol,TF[x],prCCI[x],ccprc,0)>0 && iCCI(_Symbol,TF[x],prCCI[x],ccprc,1)<0))
           {
            ObjectCreate("arrow"+x+1,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
            ObjectSetText("arrow"+x+1,CharToStr(light),22,"Wingdings",Lime); aB++;
            ObjectSet("arrow"+x+1,OBJPROP_CORNER,0);
            ObjectSet("arrow"+x+1,OBJPROP_XDISTANCE,x*scaleX+offsetX+9); // scaleX == 83, offsetX == 220
            ObjectSet("arrow"+x+1,OBJPROP_YDISTANCE,1*scaleY+offsetY-1);
           }
         else
           {
            ObjectCreate("arrow"+x+1,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
            ObjectSetText("arrow"+x+1,CharToStr(light),22,"Wingdings",Red); aS++;
            ObjectSet("arrow"+x+1,OBJPROP_CORNER,0);
            ObjectSet("arrow"+x+1,OBJPROP_XDISTANCE,x*scaleX+offsetX+9); // scaleX == 83, offsetX == 220
            ObjectSet("arrow"+x+1,OBJPROP_YDISTANCE,1*scaleY+offsetY-1);
           }
        }
      else if((iMA(_Symbol,TFM[x],3,0,MODE_EMA,maprc,0)<iMA(_Symbol,TFM[x],3,0,MODE_EMA,maprc,1))
         && (iCCI(_Symbol,TF[x],prCCI[x],ccprc,0)<0)) // if entry cci below zero
           {
            if((iCCI(_Symbol,TF[x],prCCI[x],ccprc,0)<iCCI(_Symbol,TF[x],prCCI[x],ccprc,1)) || 
               (iCCI(_Symbol,TF[x],prCCI[x],ccprc,0)<0 && iCCI(_Symbol,TF[x],prCCI[x],ccprc,1)>0))
              {
               ObjectCreate("arrow"+x+1,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
               ObjectSetText("arrow"+x+1,CharToStr(light),22,"Wingdings",Red); aS++;
               ObjectSet("arrow"+x+1,OBJPROP_CORNER,0);
               ObjectSet("arrow"+x+1,OBJPROP_XDISTANCE,x*scaleX+offsetX+9); // scaleX == 83, offsetX == 220
               ObjectSet("arrow"+x+1,OBJPROP_YDISTANCE,1*scaleY+offsetY-1);
              }
            else
              {
               ObjectCreate("arrow"+x+1,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
               ObjectSetText("arrow"+x+1,CharToStr(light),22,"Wingdings",Lime); aB++;
               ObjectSet("arrow"+x+1,OBJPROP_CORNER,0);
               ObjectSet("arrow"+x+1,OBJPROP_XDISTANCE,x*scaleX+offsetX+9); // scaleX == 83, offsetX == 220
               ObjectSet("arrow"+x+1,OBJPROP_YDISTANCE,1*scaleY+offsetY-1);
              }
           }
         else
           {
            ObjectCreate("arrow"+x+1,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
            ObjectSetText("arrow"+x+1,CharToStr(light),23,"Wingdings",Yellow); aW++;
            ObjectSet("arrow"+x+1,OBJPROP_CORNER,0);
            ObjectSet("arrow"+x+1,OBJPROP_XDISTANCE,x*scaleX+offsetX+9); // scaleX == 83, offsetX == 220
            ObjectSet("arrow"+x+1,OBJPROP_YDISTANCE,1*scaleY+offsetY-1);
           }
     }
//--- create count text direction
   for(x=0;x<6;x++)
     {
      if((iMA(_Symbol,TFM[x],3,0,MODE_EMA,maprc,0)>iMA(_Symbol,TFM[x],3,0,MODE_EMA,maprc,1))
         && (iCCI(_Symbol,TF[x],prCCI[x],ccprc,0)>0)) // if entry cci above zero
        {
         if((iCCI(_Symbol,TF[x],prCCI[x],ccprc,0)>iCCI(_Symbol,TF[x],prCCI[x],ccprc,1)) || 
            (iCCI(_Symbol,TF[x],prCCI[x],ccprc,0)>0 && iCCI(_Symbol,TF[x],prCCI[x],ccprc,1)<0))
           {
            ObjectCreate("txDir"+x+"2",OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
            ObjectSetText("txDir"+x+"2"," BUY",fontSize,"Bodoni MT Black",Aqua); dB++;
            ObjectSet("txDir"+x+"2",OBJPROP_CORNER,0);
            ObjectSet("txDir"+x+"2",OBJPROP_XDISTANCE,x*scaleX+offsetX+5); // scaleX == 83, offsetX == 220
            ObjectSet("txDir"+x+"2",OBJPROP_YDISTANCE,2*scaleY+offsetY+8);
           }
         else
           {
            ObjectCreate("txDir"+x+"2",OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
            ObjectSetText("txDir"+x+"2","SELL",fontSize,"Bodoni MT Black",Red); dS++;
            ObjectSet("txDir"+x+"2",OBJPROP_CORNER,0);
            ObjectSet("txDir"+x+"2",OBJPROP_XDISTANCE,x*scaleX+offsetX+5); // scaleX == 83, offsetX == 220
            ObjectSet("txDir"+x+"2",OBJPROP_YDISTANCE,2*scaleY+offsetY+8);
           }
        }
      else if((iMA(_Symbol,TFM[x],3,0,MODE_EMA,maprc,0)<iMA(_Symbol,TFM[x],3,0,MODE_EMA,maprc,1))
         && (iCCI(_Symbol,TF[x],prCCI[x],ccprc,0)<0)) // if entry cci below zero
           {
            if((iCCI(_Symbol,TF[x],prCCI[x],ccprc,0)<iCCI(_Symbol,TF[x],prCCI[x],ccprc,1)) || 
               (iCCI(_Symbol,TF[x],prCCI[x],ccprc,0)<0 && iCCI(_Symbol,TF[x],prCCI[x],ccprc,1)>0))
              {
               ObjectCreate("txDir"+x+"2",OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
               ObjectSetText("txDir"+x+"2","SELL",fontSize,"Bodoni MT Black",Red); dS++;
               ObjectSet("txDir"+x+"2",OBJPROP_CORNER,0);
               ObjectSet("txDir"+x+"2",OBJPROP_XDISTANCE,x*scaleX+offsetX+5); // scaleX == 83, offsetX == 220
               ObjectSet("txDir"+x+"2",OBJPROP_YDISTANCE,2*scaleY+offsetY+8);
              }
            else
              {
               ObjectCreate("txDir"+x+"2",OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
               ObjectSetText("txDir"+x+"2"," BUY",fontSize,"Bodoni MT Black",Aqua); dB++;
               ObjectSet("txDir"+x+"2",OBJPROP_CORNER,0);
               ObjectSet("txDir"+x+"2",OBJPROP_XDISTANCE,x*scaleX+offsetX+5); // scaleX == 83, offsetX == 220
               ObjectSet("txDir"+x+"2",OBJPROP_YDISTANCE,2*scaleY+offsetY+8);
              }
           }
         else
           {
            ObjectCreate("txDir"+x+"2",OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
            ObjectSetText("txDir"+x+"2","WAIT",fontSize,"Bodoni MT Black",Yellow); dW++;
            ObjectSet("txDir"+x+"2",OBJPROP_CORNER,0);
            ObjectSet("txDir"+x+"2",OBJPROP_XDISTANCE,x*scaleX+offsetX+5); // scaleX == 83, offsetX == 220
            ObjectSet("txDir"+x+"2",OBJPROP_YDISTANCE,2*scaleY+offsetY+8);
           }
     }
//--- create suggest light arrows
   RefreshRates();
   if(aB>aS && aW<3)
     {
      ObjectCreate("arInd"+6+1,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("arInd"+6+1,CharToStr(light),22,"Wingdings",Lime);
      ObjectSet("arInd"+6+1,OBJPROP_CORNER,0);
      ObjectSet("arInd"+6+1,OBJPROP_XDISTANCE,6*scaleX+offsetX+15); // scaleX == 83, offsetX == 220
      ObjectSet("arInd"+6+1,OBJPROP_YDISTANCE,1*scaleY+offsetY-1);
     }
//---
   else if(aS>aB && aW<3)
     {
      ObjectCreate("arInd"+6+1,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("arInd"+6+1,CharToStr(light),22,"Wingdings",Red);
      ObjectSet("arInd"+6+1,OBJPROP_CORNER,0);
      ObjectSet("arInd"+6+1,OBJPROP_XDISTANCE,6*scaleX+offsetX+15); // scaleX == 83, offsetX == 220
      ObjectSet("arInd"+6+1,OBJPROP_YDISTANCE,1*scaleY+offsetY-1);
     }
//---
   else
     {
      ObjectCreate("arInd"+6+1,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("arInd"+6+1,CharToStr(light),22,"Wingdings",Yellow);
      ObjectSet("arInd"+6+1,OBJPROP_CORNER,0);
      ObjectSet("arInd"+6+1,OBJPROP_XDISTANCE,6*scaleX+offsetX+15); // scaleX == 83, offsetX == 220
      ObjectSet("arInd"+6+1,OBJPROP_YDISTANCE,1*scaleY+offsetY-1);
     }
//--- create suggest text direction
   if(dB>dS && dW<3)
     {
      ObjectCreate("txDir"+6+2,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("txDir"+6+2," BUY",fontSize,"Bodoni MT Black",Aqua);
      ObjectSet("txDir"+6+2,OBJPROP_CORNER,0);
      ObjectSet("txDir"+6+2,OBJPROP_XDISTANCE,6*scaleX+offsetX+10); // scaleX == 83, offsetX == 220
      ObjectSet("txDir"+6+2,OBJPROP_YDISTANCE,2*scaleY+offsetY+8);
     }
//---
   else if(dS>dB && dW<3)
     {
      ObjectCreate("txDir"+6+2,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("txDir"+6+2,"SELL",fontSize,"Bodoni MT Black",Red);
      ObjectSet("txDir"+6+2,OBJPROP_CORNER,0);
      ObjectSet("txDir"+6+2,OBJPROP_XDISTANCE,6*scaleX+offsetX+12); // scaleX == 83, offsetX == 220
      ObjectSet("txDir"+6+2,OBJPROP_YDISTANCE,2*scaleY+offsetY+8);
     }
//---
   else
     {
      ObjectCreate("txDir"+6+2,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("txDir"+6+2,"WAIT",fontSize,"Bodoni MT Black",Yellow);
      ObjectSet("txDir"+6+2,OBJPROP_CORNER,0);
      ObjectSet("txDir"+6+2,OBJPROP_XDISTANCE,6*scaleX+offsetX+10); // scaleX == 83, offsetX == 220
      ObjectSet("txDir"+6+2,OBJPROP_YDISTANCE,2*scaleY+offsetY+8);
     }
//---
   RefreshRates();
//--- create count of pips range
   RefreshRates();
   for(x=0;x<6;x++)
     {
      double hilo=iHigh(_Symbol,TF[x],0)-iLow(_Symbol,TF[x],0);
      string tcent=DoubleToStr(NormalizeDouble((hilo/xr)*xx,xdig),xdig);
      if(xdig==1)
        {
         if(StringLen(tcent)<=4) {double ltx=3.5-StringLen(tcent);}
         else if(StringLen(tcent)==5) {ltx=4.2-StringLen(tcent);}
         else {ltx=4-StringLen(tcent);}
        }
      else {ltx=3-StringLen(tcent);}
      if(iClose(_Symbol,TF[x],0)>iOpen(_Symbol,TF[x],0))
        {
         ObjectCreate("txPips"+x+y+1,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
         ObjectSetText("txPips"+x+y+1,tcent,9,"Bodoni MT Black",Lime);
         ObjectSet("txPips"+x+y+1,OBJPROP_CORNER,0);
         ObjectSet("txPips"+x+y+1,OBJPROP_XDISTANCE,x*scaleX+offsetX+10+(ltx*4.5)); // scaleX == 83, offsetX == 220
         ObjectSet("txPips"+x+y+1,OBJPROP_YDISTANCE,2*scaleY+offsetY+29);
        }
      else if(iClose(_Symbol,TF[x],0)<iOpen(_Symbol,TF[x],0))
        {
         ObjectCreate("txPips"+x+y+1,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
         ObjectSetText("txPips"+x+y+1,tcent,9,"Bodoni MT Black",LightYellow);
         ObjectSet("txPips"+x+y+1,OBJPROP_CORNER,0);
         ObjectSet("txPips"+x+y+1,OBJPROP_XDISTANCE,x*scaleX+offsetX+10+(ltx*4.5)); // scaleX == 83, offsetX == 220
         ObjectSet("txPips"+x+y+1,OBJPROP_YDISTANCE,2*scaleY+offsetY+29);
        }
      else
        {
         ObjectCreate("txPips"+x+y+1,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
         ObjectSetText("txPips"+x+y+1,tcent,9,"Bodoni MT Black",Yellow);
         ObjectSet("txPips"+x+y+1,OBJPROP_CORNER,0);
         ObjectSet("txPips"+x+y+1,OBJPROP_XDISTANCE,x*scaleX+offsetX+10+(ltx*4.5)); // scaleX == 83, offsetX == 220
         ObjectSet("txPips"+x+y+1,OBJPROP_YDISTANCE,2*scaleY+offsetY+29);
        }
     }
//--- create suggest text pips range
   RefreshRates();
   double dhp=MarketInfo(_Symbol,MODE_HIGH);
   double dpc1=dhp-iClose(_Symbol,5,1);
   double dpc0=dhp-iClose(_Symbol,5,0);
//---
   for(x=0;x<5;x++)
     {
      if(iStochastic(_Symbol,TFsto[x],5,3,3,MODE_SMA,0,MODE_MAIN,0)
         >iStochastic(_Symbol,TFsto[x],5,3,3,MODE_SMA,0,MODE_SIGNAL,0))
        {stB++;}
      if(iStochastic(_Symbol,TFsto[x],5,3,3,MODE_SMA,0,MODE_MAIN,0)
         <iStochastic(_Symbol,TFsto[x],5,3,3,MODE_SMA,0,MODE_SIGNAL,0))
        {stS++;}
     }
//---
   for(x=0;x<5;x++)
     {
      if(iOsMA(_Symbol,TFosm[x],12,26,9,0,0)>iOsMA(_Symbol,TFosm[x],12,26,9,0,1))
        {osmB++;}
      if(iOsMA(_Symbol,TFosm[x],12,26,9,0,0)<iOsMA(_Symbol,TFosm[x],12,26,9,0,1))
        {osmS++;}
     }
//---
   if(dpc0<dpc1 && stB>stS && osmB>osmS)
     {
      ObjectCreate("txPips"+6+3,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("txPips"+6+3," BUY",fontSize,"Bodoni MT Black",Lime);
      ObjectSet("txPips"+6+3,OBJPROP_CORNER,0);
      ObjectSet("txPips"+6+3,OBJPROP_XDISTANCE,6*scaleX+offsetX+10); // scaleX == 83, offsetX == 220
      ObjectSet("txPips"+6+3,OBJPROP_YDISTANCE,2*scaleY+offsetY+29);
     }
   else if(dpc0>dpc1 && stB<stS && osmB<osmS)
     {
      ObjectCreate("txPips"+6+3,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("txPips"+6+3,"SELL",fontSize,"Bodoni MT Black",LightYellow);
      ObjectSet("txPips"+6+3,OBJPROP_CORNER,0);
      ObjectSet("txPips"+6+3,OBJPROP_XDISTANCE,6*scaleX+offsetX+12); // scaleX == 83, offsetX == 220
      ObjectSet("txPips"+6+3,OBJPROP_YDISTANCE,2*scaleY+offsetY+29);
     }
   else
     {
      ObjectCreate("txPips"+6+3,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("txPips"+6+3,"WAIT",fontSize,"Bodoni MT Black",Yellow);
      ObjectSet("txPips"+6+3,OBJPROP_CORNER,0);
      ObjectSet("txPips"+6+3,OBJPROP_XDISTANCE,6*scaleX+offsetX+10); // scaleX == 83, offsetX == 220
      ObjectSet("txPips"+6+3,OBJPROP_YDISTANCE,2*scaleY+offsetY+29);
     }
//--- create __Symbols index
//--- delete indicator __Symbols index
   ObjectDelete("prIdx"+8+0);
   ObjectDelete("prIdx"+8+1);
   ObjectDelete("prIdx"+8+2);
   ObjectDelete("prIdx"+8+3);
   ObjectDelete("prIdx"+8+4);
   ObjectDelete("prIdx"+8+5);
   ObjectDelete("prIdx"+8+6);
   ObjectDelete("prIdx"+8+7);
//--- Index Symbol AUD
   RefreshRates();
//---
   for(x=0;x<7;x++)
     {
      for(r=0;r<4;r++)
        {
         if(StringSubstr(prx0[x],0,3)=="AUD")
           {
            if(iClose(prx0[x],TFpr[r],0)>iClose(prx0[x],TFpr[r],1))
              {auu++;}
            else {aud++;}
           }
         else if(StringSubstr(prx0[x],3,3)=="AUD")
           {
            if(iClose(prx0[x],TFpr[r],0)>iClose(prx0[x],TFpr[r],1))
              {aud++;}
            else {auu++;}
           }
        }
     }
   if(auu>=aud) {AUup=true;}
   else {AUup=false;}
//---   
   ObjectCreate("prIdx"+x+y+8+0,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
   ObjectSetText("prIdx"+x+y+8+0,"AUDX",8,"Bodoni MT Black",Snow);
   ObjectSet("prIdx"+x+y+8+0,OBJPROP_CORNER,0);
   ObjectSet("prIdx"+x+y+8+0,OBJPROP_XDISTANCE,0*scaleXp+offsetX+3); // scaleX == 83, offsetX == 220
   ObjectSet("prIdx"+x+y+8+0,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
//---
   if(AUup==true)
     {
      ObjectCreate("prIdx"+8+0,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+0,CharToStr(217),12,"Wingdings",Lime);
      ObjectSet("prIdx"+8+0,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+0,OBJPROP_XDISTANCE,0*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+0,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
   else if(AUup==false)
     {
      ObjectCreate("prIdx"+8+0,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+0,CharToStr(218),12,"Wingdings",Red);
      ObjectSet("prIdx"+8+0,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+0,OBJPROP_XDISTANCE,0*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+0,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
   else
     {
      ObjectCreate("prIdx"+8+0,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+0,CharToStr(164),12,"Wingdings",Yellow);
      ObjectSet("prIdx"+8+0,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+0,OBJPROP_XDISTANCE,0*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+0,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
//--- Index Symbol CAD
   for(x=0;x<7;x++)
     {
      for(r=0;r<4;r++)
        {
         if(StringSubstr(prx1[x],0,3)=="CAD")
           {
            if(iClose(prx1[x],TFpr[r],0)>iClose(prx1[x],TFpr[r],1))
              {cau++;}
            else {cad++;}
           }
         else if(StringSubstr(prx1[x],3,3)=="CAD")
           {
            if(iClose(prx1[x],TFpr[r],0)>iClose(prx1[x],TFpr[r],1))
              {cad++;}
            else {cau++;}
           }
        }
     }
   if(cau>=cad) {CAup=true;}
   else {CAup=false;}
//---    
   ObjectCreate("prIdx"+x+y+8+1,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
   ObjectSetText("prIdx"+x+y+8+1,"CADX",8,"Bodoni MT Black",Snow);
   ObjectSet("prIdx"+x+y+8+1,OBJPROP_CORNER,0);
   ObjectSet("prIdx"+x+y+8+1,OBJPROP_XDISTANCE,1*scaleXp+offsetX+3); // scaleX == 83, offsetX == 220
   ObjectSet("prIdx"+x+y+8+1,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
//---
   if(CAup==true)
     {
      ObjectCreate("prIdx"+8+1,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+1,CharToStr(217),12,"Wingdings",Lime);
      ObjectSet("prIdx"+8+1,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+1,OBJPROP_XDISTANCE,1*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+1,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
   else if(CAup==false)
     {
      ObjectCreate("prIdx"+8+1,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+1,CharToStr(218),12,"Wingdings",Red);
      ObjectSet("prIdx"+8+1,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+1,OBJPROP_XDISTANCE,1*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+1,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
   else
     {
      ObjectCreate("prIdx"+8+1,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+1,CharToStr(164),12,"Wingdings",Yellow);
      ObjectSet("prIdx"+8+1,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+1,OBJPROP_XDISTANCE,1*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+1,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
//--- Index Symbol CHF
   for(x=0;x<7;x++)
     {
      for(r=0;r<4;r++)
        {
         if(StringSubstr(prx2[x],0,3)=="CHF")
           {
            if(iClose(prx2[x],TFpr[r],0)>iClose(prx2[x],TFpr[r],1))
              {chu++;}
            else {chd++;}
           }
         else if(StringSubstr(prx2[x],3,3)=="CHF")
           {
            if(iClose(prx2[x],TFpr[r],0)>iClose(prx2[x],TFpr[r],1))
              {chd++;}
            else {chu++;}
           }
        }
     }
   if(chu>=chd) {CHup=true;}
   else {CHup=false;}
//---
   ObjectCreate("prIdx"+x+y+8+2,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
   ObjectSetText("prIdx"+x+y+8+2,"CHFX",8,"Bodoni MT Black",Snow);
   ObjectSet("prIdx"+x+y+8+2,OBJPROP_CORNER,0);
   ObjectSet("prIdx"+x+y+8+2,OBJPROP_XDISTANCE,2*scaleXp+offsetX+3); // scaleX == 83, offsetX == 220
   ObjectSet("prIdx"+x+y+8+2,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
//---
   if(CHup==true)
     {
      ObjectCreate("prIdx"+8+2,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+2,CharToStr(217),12,"Wingdings",Lime);
      ObjectSet("prIdx"+8+2,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+2,OBJPROP_XDISTANCE,2*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+2,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
   else if(CHup==false)
     {
      ObjectCreate("prIdx"+8+2,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+2,CharToStr(218),12,"Wingdings",Red);
      ObjectSet("prIdx"+8+2,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+2,OBJPROP_XDISTANCE,2*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+2,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
   else
     {
      ObjectCreate("prIdx"+8+2,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+2,CharToStr(164),12,"Wingdings",Yellow);
      ObjectSet("prIdx"+8+2,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+2,OBJPROP_XDISTANCE,2*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+2,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
//--- Index Symbol EUR
   for(x=0;x<7;x++)
     {
      for(r=0;r<4;r++)
        {
         if(StringSubstr(prx3[x],0,3)=="EUR")
           {
            if(iClose(prx3[x],TFpr[r],0)>iClose(prx3[x],TFpr[r],1))
              {euu++;}
            else {eud++;}
           }
         else if(StringSubstr(prx3[x],3,3)=="EUR")
           {
            if(iClose(prx3[x],TFpr[r],0)>iClose(prx3[x],TFpr[r],1))
              {eud++;}
            else {euu++;}
           }
        }
     }
   if(euu>=eud) {EUup=true;}
   else {EUup=false;}
//---       
   ObjectCreate("prIdx"+x+y+8+3,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
   ObjectSetText("prIdx"+x+y+8+3,"EURX",8,"Bodoni MT Black",Snow);
   ObjectSet("prIdx"+x+y+8+3,OBJPROP_CORNER,0);
   ObjectSet("prIdx"+x+y+8+3,OBJPROP_XDISTANCE,3*scaleXp+offsetX+3); // scaleX == 83, offsetX == 220
   ObjectSet("prIdx"+x+y+8+3,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
//---
   if(EUup==true)
     {
      ObjectCreate("prIdx"+8+3,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+3,CharToStr(217),12,"Wingdings",Lime);
      ObjectSet("prIdx"+8+3,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+3,OBJPROP_XDISTANCE,3*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+3,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
   else if(EUup==false)
     {
      ObjectCreate("prIdx"+8+3,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+3,CharToStr(218),12,"Wingdings",Red);
      ObjectSet("prIdx"+8+3,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+3,OBJPROP_XDISTANCE,3*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+3,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
   else
     {
      ObjectCreate("prIdx"+8+3,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+3,CharToStr(164),12,"Wingdings",Yellow);
      ObjectSet("prIdx"+8+3,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+3,OBJPROP_XDISTANCE,3*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+3,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
//--- Index Symbol GBP
   for(x=0;x<7;x++)
     {
      for(r=0;r<4;r++)
        {
         if(StringSubstr(prx4[x],0,3)=="GBP")
           {
            if(iClose(prx4[x],TFpr[r],0)>iClose(prx4[x],TFpr[r],1))
              {gbu++;}
            else {gbd++;}
           }
         else if(StringSubstr(prx4[x],3,3)=="GBP")
           {
            if(iClose(prx4[x],TFpr[r],0)>iClose(prx4[x],TFpr[r],1))
              {gbd++;}
            else {gbu++;}
           }
        }
     }
   if(gbu>=gbd) {GBup=true;}
   else {GBup=false;}
//---       
   ObjectCreate("prIdx"+x+y+8+4,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
   ObjectSetText("prIdx"+x+y+8+4,"GBPX",8,"Bodoni MT Black",Snow);
   ObjectSet("prIdx"+x+y+8+4,OBJPROP_CORNER,0);
   ObjectSet("prIdx"+x+y+8+4,OBJPROP_XDISTANCE,4*scaleXp+offsetX+3); // scaleX == 83, offsetX == 220
   ObjectSet("prIdx"+x+y+8+4,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
//---
   if(GBup==true)
     {
      ObjectCreate("prIdx"+8+4,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+4,CharToStr(217),12,"Wingdings",Lime);
      ObjectSet("prIdx"+8+4,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+4,OBJPROP_XDISTANCE,4*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+4,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
   else if(GBup==false)
     {
      ObjectCreate("prIdx"+8+4,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+4,CharToStr(218),12,"Wingdings",Red);
      ObjectSet("prIdx"+8+4,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+4,OBJPROP_XDISTANCE,4*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+4,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
   else
     {
      ObjectCreate("prIdx"+8+4,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+4,CharToStr(164),12,"Wingdings",Yellow);
      ObjectSet("prIdx"+8+4,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+4,OBJPROP_XDISTANCE,4*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+4,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
//--- Index Symbol JPY
   for(x=0;x<7;x++)
     {
      for(r=0;r<4;r++)
        {
         if(StringSubstr(prx5[x],0,3)=="JPY")
           {
            if(iClose(prx5[x],TFpr[r],0)>iClose(prx5[x],TFpr[r],1))
              {jpu++;}
            else {jpd++;}
           }
         else if(StringSubstr(prx5[x],3,3)=="JPY")
           {
            if(iClose(prx5[x],TFpr[r],0)>iClose(prx5[x],TFpr[r],1))
              {jpd++;}
            else {jpu++;}
           }
        }
     }
   if(jpu>=jpd) {JPup=true;}
   else {JPup=false;}
//---
   ObjectCreate("prIdx"+x+y+8+5,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
   ObjectSetText("prIdx"+x+y+8+5,"JPYX",8,"Bodoni MT Black",Snow);
   ObjectSet("prIdx"+x+y+8+5,OBJPROP_CORNER,0);
   ObjectSet("prIdx"+x+y+8+5,OBJPROP_XDISTANCE,5*scaleXp+offsetX+3); // scaleX == 83, offsetX == 220
   ObjectSet("prIdx"+x+y+8+5,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
//---
   if(JPup==true)
     {
      ObjectCreate("prIdx"+8+5,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+5,CharToStr(217),12,"Wingdings",Lime);
      ObjectSet("prIdx"+8+5,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+5,OBJPROP_XDISTANCE,5*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+5,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
   else if(JPup==false)
     {
      ObjectCreate("prIdx"+8+5,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+5,CharToStr(218),12,"Wingdings",Red);
      ObjectSet("prIdx"+8+5,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+5,OBJPROP_XDISTANCE,5*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+5,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
   else
     {
      ObjectCreate("prIdx"+8+5,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+5,CharToStr(164),12,"Wingdings",Yellow);
      ObjectSet("prIdx"+8+5,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+5,OBJPROP_XDISTANCE,5*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+5,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
//--- Index Symbol NZD
   for(x=0;x<7;x++)
     {
      for(r=0;r<4;r++)
        {
         if(StringSubstr(prx6[x],0,3)=="NZD")
           {
            if(iClose(prx6[x],TFpr[r],0)>iClose(prx6[x],TFpr[r],1))
              {nzu++;}
            else {nzd++;}
           }
         else if(StringSubstr(prx6[x],3,3)=="NZD")
           {
            if(iClose(prx6[x],TFpr[r],0)>iClose(prx6[x],TFpr[r],1))
              {nzd++;}
            else {nzu++;}
           }
        }
     }
   if(nzu>=nzd) {NZup=true;}
   else {NZup=false;}
//---     
   ObjectCreate("prIdx"+x+y+8+6,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
   ObjectSetText("prIdx"+x+y+8+6,"NZDX",8,"Bodoni MT Black",Snow);
   ObjectSet("prIdx"+x+y+8+6,OBJPROP_CORNER,0);
   ObjectSet("prIdx"+x+y+8+6,OBJPROP_XDISTANCE,6*scaleXp+offsetX+3); // scaleX == 83, offsetX == 220
   ObjectSet("prIdx"+x+y+8+6,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
//---
   if(NZup==true)
     {
      ObjectCreate("prIdx"+8+6,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+6,CharToStr(217),12,"Wingdings",Lime);
      ObjectSet("prIdx"+8+6,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+6,OBJPROP_XDISTANCE,6*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+6,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
   else if(NZup==false)
     {
      ObjectCreate("prIdx"+8+6,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+6,CharToStr(218),12,"Wingdings",Red);
      ObjectSet("prIdx"+8+6,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+6,OBJPROP_XDISTANCE,6*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+6,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
   else
     {
      ObjectCreate("prIdx"+8+6,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+6,CharToStr(164),12,"Wingdings",Yellow);
      ObjectSet("prIdx"+8+6,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+6,OBJPROP_XDISTANCE,6*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+6,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
//--- Index Symbol USD
   for(x=0;x<7;x++)
     {
      for(r=0;r<4;r++)
        {
         if(StringSubstr(prx7[x],0,3)=="USD")
           {
            if(iClose(prx7[x],TFpr[r],0)>iClose(prx7[x],TFpr[r],1))
              {usu++;}
            else {usd++;}
           }
         else if(StringSubstr(prx7[x],3,3)=="USD")
           {
            if(iClose(prx7[x],TFpr[r],0)>iClose(prx7[x],TFpr[r],1))
              {usd++;}
            else {usu++;}
           }
        }
     }
   if(usu>=usd) {USup=true;}
   else {USup=false;}
//---       
   ObjectCreate("prIdx"+x+y+8+7,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
   ObjectSetText("prIdx"+x+y+8+7,"USDX",8,"Bodoni MT Black",Snow);
   ObjectSet("prIdx"+x+y+8+7,OBJPROP_CORNER,0);
   ObjectSet("prIdx"+x+y+8+7,OBJPROP_XDISTANCE,7*scaleXp+offsetX+3); // scaleX == 83, offsetX == 220
   ObjectSet("prIdx"+x+y+8+7,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
//---
   if(USup==true)
     {
      ObjectCreate("prIdx"+8+7,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+7,CharToStr(217),12,"Wingdings",Lime);
      ObjectSet("prIdx"+8+7,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+7,OBJPROP_XDISTANCE,7*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+7,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
   else if(USup==false)
     {
      ObjectCreate("prIdx"+8+7,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+7,CharToStr(218),12,"Wingdings",Red);
      ObjectSet("prIdx"+8+7,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+7,OBJPROP_XDISTANCE,7*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+7,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
   else
     {
      ObjectCreate("prIdx"+8+7,OBJ_LABEL,WindowFind("PairsIndex ("+_Symbol+","+strTF(_Period)+")"),0,0);
      ObjectSetText("prIdx"+8+7,CharToStr(164),12,"Wingdings",Yellow);
      ObjectSet("prIdx"+8+7,OBJPROP_CORNER,0);
      ObjectSet("prIdx"+8+7,OBJPROP_XDISTANCE,7*scaleXp+offsetX+38); // scaleX == 83, offsetX == 220
      ObjectSet("prIdx"+8+7,OBJPROP_YDISTANCE,3*scaleY+offsetY+29);
     }
//--- end __Symbols index     
   OnTimer();
   ChartRedraw(0);
   Sleep(500);
   RefreshRates();
//---
   return(0);
//---
  } //---end start()
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   rts=CopyRates(_Symbol,0,0,100,rates);
   if(rts==0) return;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
string strTF(int period)
  {
   switch(period)
     {
      //---
      case PERIOD_M1: return("M1");
      case PERIOD_M5: return("M5");
      case PERIOD_M15: return("M15");
      case PERIOD_M30: return("M30");
      case PERIOD_H1: return("H1");
      case PERIOD_H4: return("H4");
      case PERIOD_D1: return("D1");
      case PERIOD_W1: return("W1");
      case PERIOD_MN1: return("MN");
     }
   return(period);
  }
//+------------------------------------------------------------------+
