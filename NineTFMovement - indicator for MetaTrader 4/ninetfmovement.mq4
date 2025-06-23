//+------------------------------------------------------------------+
//|                                               NineTFMovement.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014 - By 3RJ ~ Roy Philips-Jacobs ~ 27/11/2014"
#property link      "http://www.mql5.com"
#property link      "http://www.gol2you.com ~ Forex Videos"
#property version   "1.00"
/* Update (2015/04/05): 
   1. Simplify the code to improve the performance of the Indicator.
   2. Eliminate the noisy signal.
   //--
   Update (2015/07/03):
   1. Minor changes in the codes for indicator arrow trend consideration.
   //--
   Update (2015/09/07):
   1. Improve signal formula.
   2. Add alerts.
   //--
*/
//---
#property indicator_separate_window
//--
extern string NineTFMovement = "Copyright © 2014 By 3RJ ~ Roy Philips-Jacobs";
extern color         ArrowUp = clrLime;
extern color         ArrowDn = clrRed;
extern color         NoArrow = clrYellow;
extern bool      SoundAlerts = true;
extern bool      MsgAlerts   = true;
extern bool      eMailAlerts = false;
extern string SoundAlertFile = "alert.wav";
//--
//--- spacing
int scaleX=60,scaleY=40,scaleYt=18,offsetX=250,offsetY=3,fontSize=9; // coordinate
double scaleXp=45;
double scaleYp=29;
//--- arrays for various things
int TF[]={1,5,15,30,60,240,1440,10080,43200};
int xx;
int br=100;
int ndigs=0;
//---
double er;
double digs;
//---
string periodStr[]={" M1"," M5","M15","M30"," H1"," H4"," D1"," W1","MN1"}; // Text Timeframes
string labelNameStr[]={"TIMEFRAMES","PRICEMOVEMENT","HIGHLOWRANGE"}; // Indicator labels
//---
string CRight;
string short_name;
string alBase,alSubj,alMsg;
//--
int tmr;
int cal;
int pal;
int cmnt;
int pmnt;
//---
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   CRight="Copyright © 2014 By 3RJ ~ Roy Philips-Jacobs";
//--
   EventSetTimer(60);
//---- indicators
   short_name="NineTFMovement: ";
   IndicatorShortName("NineTFMovement ("+_Symbol+")");
//--
   IndicatorDigits(Digits);
//----
// Checking the Digits Point
   digs=Digits;
   if(digs==3 || digs==5)
     {er=Point*10; ndigs=1; xx=10;}
   else {er=Point; ndigs=0; xx=1;}
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   ObjectsDeleteAll();
//--
   EventKillTimer();
   GlobalVariablesDeleteAll();
//----
   return;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----  
   if(NineTFMovement!=CRight) return(0);
//--- Set Last error value to Zero
   ResetLastError();
   ChartSetInteger(0,CHART_AUTOSCROLL,0,true);
   WindowRedraw();
   ChartRedraw(0);
   Sleep(500);
   RefreshRates();
   cal=0;
   int x,y;
   int ocB=0,ocS=0;
   int ntf=WindowFirstVisibleBar();
   double crrsi[];
   double macri[];
   ArraySetAsSeries(crrsi,true);
   ArraySetAsSeries(macri,true);
   ArrayResize(crrsi,br);
   ArrayResize(macri,br);
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
//--- create timeframe text labels
   for(x=0;x<9;x++)
     {
      ObjectCreate(0,"txPeriod"+x,OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
      ObjectSetText("txPeriod"+x,periodStr[x],fontSize,"Bodoni MT Black",clrGold);
      ObjectSetInteger(0,"txPeriod"+x,OBJPROP_CORNER,0);
      ObjectSetInteger(0,"txPeriod"+x,OBJPROP_XDISTANCE,scaleXp+x*scaleX+offsetX);
      ObjectSetInteger(0,"txPeriod"+x,OBJPROP_YDISTANCE,y*scaleY+offsetY+7);
     }
//--- create indicator labels time
   ObjectCreate(0,"txTime"+"0",OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
   ObjectSetText("txTime"+"0",StringConcatenate("H: ",hr),11,"Arial Bold",clrGold);
   ObjectSetInteger(0,"txTime"+"0",OBJPROP_CORNER,0);
   ObjectSetInteger(0,"txTime"+"0",OBJPROP_XDISTANCE,offsetX-230);
   ObjectSetInteger(0,"txTime"+"0",OBJPROP_YDISTANCE,0*scaleYt+offsetY+scaleYp);
//--
   ObjectCreate(0,"txTime"+"1",OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
   ObjectSetText("txTime"+"1",StringConcatenate("M: ",mi),11,"Arial Bold",clrGold);
   ObjectSetInteger(0,"txTime"+"1",OBJPROP_CORNER,0);
   ObjectSetInteger(0,"txTime"+"1",OBJPROP_XDISTANCE,offsetX-232);
   ObjectSetInteger(0,"txTime"+"1",OBJPROP_YDISTANCE,1*scaleYt+offsetY+scaleYp);
//--
   ObjectCreate(0,"txTime"+"2",OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
   ObjectSetText("txTime"+"2",StringConcatenate("S: ",sc),11,"Arial Bold",clrGold);
   ObjectSetInteger(0,"txTime"+"2",OBJPROP_CORNER,0);
   ObjectSetInteger(0,"txTime"+"2",OBJPROP_XDISTANCE,offsetX-229);
   ObjectSetInteger(0,"txTime"+"2",OBJPROP_YDISTANCE,2*scaleYt+offsetY+scaleYp);
//--
   ObjectCreate(0,"txTime"+"3",OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
   ObjectSetText("txTime"+"3",StringConcatenate("EST TZ:  ",tztxt),8,"Arial Bold",clrGold);
   ObjectSetInteger(0,"txTime"+"3",OBJPROP_CORNER,0);
   ObjectSetInteger(0,"txTime"+"3",OBJPROP_XDISTANCE,offsetX-243);
   ObjectSetInteger(0,"txTime"+"3",OBJPROP_YDISTANCE,3*scaleYt+offsetY+35);
//--- create indicator arrow trend consideration
   RefreshRates();
   ObjectDelete("txCons"+"3");
   ObjectDelete("txCons"+"3"+"a");
   ObjectDelete("txCons"+"3"+"a"+"1");
//--
   RefreshRates();
   double doppr=iOpen(_Symbol,TF[6],0);
   double cclose=Close[0];
   double dmacd0=iMACD(_Symbol,TF[4],12,26,9,0,0,0)-iMACD(_Symbol,TF[4],12,26,9,0,1,0);
   double dmacd1=iMACD(_Symbol,TF[4],12,26,9,0,0,1)-iMACD(_Symbol,TF[4],12,26,9,0,1,1);
   double macdm0=iMACD(_Symbol,TF[4],12,26,9,0,0,0);
   double macdm1=iMACD(_Symbol,TF[4],12,26,9,0,0,1);
   double ptc1=(iHigh(_Symbol,TF[2],1)+iLow(_Symbol,TF[2],1)+iClose(_Symbol,TF[2],1))/3;
   double ptc0=(iHigh(_Symbol,TF[2],0)+iLow(_Symbol,TF[2],0)+iClose(_Symbol,TF[2],0))/3;
   for(int i=br-1; i>=0; i--)
     {crrsi[i]=iRSI(_Symbol,TF[2],14,5,i);}
   for(i=br-1; i>=0; i--)
     {macri[i]=iMAOnArray(crrsi,0,34,0,MODE_SMA,i);}
   double macr0=crrsi[0]-macri[0];
   double macr1=crrsi[1]-macri[1];
   if(macr0>macr1) {bool crockup=true;}
   if(macr0<macr1) {bool crockdn=true;}
//--
   for(x=1;x<5;x++)
     {
      if((iClose(_Symbol,TF[6],0)>iClose(_Symbol,TF[x],1)) && (iClose(_Symbol,TF[x],0)>iOpen(_Symbol,TF[x],0)))
        {ocB++;}
      if((iClose(_Symbol,TF[6],0)<iClose(_Symbol,TF[x],1)) && (iClose(_Symbol,TF[x],0)<iOpen(_Symbol,TF[x],0)))
        {ocS++;}
     }
//--
   if(ocB==4) {bool clsup=true;}
   if(ocS==4) {bool clsdn=true;}
   if(ptc0>ptc1) {bool up15=true;}
   if(ptc0<ptc1) {bool dn15=true;}
   bool macdup=((dmacd0>dmacd1)&&(macdm0>macdm1));
   bool macddn=((dmacd0<dmacd1)&&(macdm0<macdm1));
//--
   if((cclose>doppr) && (up15))
     {
      //--
      ObjectDelete("txCons"+x);
      ObjectDelete("txCons"+x+"a");
      ObjectDelete("txCons"+x+"a"+"1");
      //--
      ObjectCreate(0,"txCons"+x,OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
      ObjectSetText("txCons"+x,CharToStr(164),25,"Wingdings",clrLime);
      ObjectSetInteger(0,"txCons"+x,OBJPROP_CORNER,0);
      ObjectSetInteger(0,"txCons"+x,OBJPROP_XDISTANCE,offsetX-172);
      ObjectSetInteger(0,"txCons"+x,OBJPROP_YDISTANCE,1*scaleYt+offsetY+19);
      //--
      ObjectCreate(0,"txCons"+x+"a",OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
      ObjectSetText("txCons"+x+"a",CharToStr(217),18,"Wingdings",clrLime);
      ObjectSetInteger(0,"txCons"+x+"a",OBJPROP_CORNER,0);
      ObjectSetInteger(0,"txCons"+x+"a",OBJPROP_XDISTANCE,offsetX-168);
      ObjectSetInteger(0,"txCons"+x+"a",OBJPROP_YDISTANCE,0*scaleYt+offsetY+24);
      //--
      if((clsup) && (macdup) && (crockup))
        {
         ObjectCreate(0,"txCons"+x+"a"+"1",OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
         ObjectSetText("txCons"+x+"a"+"1","UP",6,"Bodoni MT Black",clrYellow);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_CORNER,0);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_XDISTANCE,offsetX-164);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_YDISTANCE,2*scaleYt+offsetY+33);
         cal=7;
        }
      //--
      else
        {
         ObjectCreate(0,"txCons"+x+"a"+"1",OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
         ObjectSetText("txCons"+x+"a"+"1","WAIT",6,"Bodoni MT Black",clrYellow);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_CORNER,0);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_XDISTANCE,offsetX-171);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_YDISTANCE,2*scaleYt+offsetY+33);
         cal=6;
        }
     }
//--
   else if((cclose<doppr) && (up15))
     {
      //--
      ObjectDelete("txCons"+x);
      ObjectDelete("txCons"+x+"a");
      ObjectDelete("txCons"+x+"a"+"1");
      //--
      ObjectCreate(0,"txCons"+x,OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
      ObjectSetText("txCons"+x,CharToStr(164),25,"Wingdings",clrRed);
      ObjectSetInteger(0,"txCons"+x,OBJPROP_CORNER,0);
      ObjectSetInteger(0,"txCons"+x,OBJPROP_XDISTANCE,offsetX-172);
      ObjectSetInteger(0,"txCons"+x,OBJPROP_YDISTANCE,1*scaleYt+offsetY+19);
      //--
      ObjectCreate(0,"txCons"+x+"a",OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
      ObjectSetText("txCons"+x+"a",CharToStr(217),18,"Wingdings",clrLime);
      ObjectSetInteger(0,"txCons"+x+"a",OBJPROP_CORNER,0);
      ObjectSetInteger(0,"txCons"+x+"a",OBJPROP_XDISTANCE,offsetX-168);
      ObjectSetInteger(0,"txCons"+x+"a",OBJPROP_YDISTANCE,0*scaleYt+offsetY+24);
      //--
      if((clsup) && (macdup) && (crockup))
        {
         ObjectCreate(0,"txCons"+x+"a"+"1",OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
         ObjectSetText("txCons"+x+"a"+"1","UP",6,"Bodoni MT Black",clrYellow);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_CORNER,0);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_XDISTANCE,offsetX-164);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_YDISTANCE,2*scaleYt+offsetY+33);
         cal=7;
        }
      //--
      else
        {
         ObjectCreate(0,"txCons"+x+"a"+"1",OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
         ObjectSetText("txCons"+x+"a"+"1","WAIT",6,"Bodoni MT Black",clrYellow);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_CORNER,0);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_XDISTANCE,offsetX-171);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_YDISTANCE,2*scaleYt+offsetY+33);
         cal=6;
        }
     }
//--
   else if((cclose>doppr) && (dn15))
     {
      //--
      ObjectDelete("txCons"+x);
      ObjectDelete("txCons"+x+"a");
      ObjectDelete("txCons"+x+"a"+"1");
      //--
      ObjectCreate(0,"txCons"+x,OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
      ObjectSetText("txCons"+x,CharToStr(164),25,"Wingdings",clrLime);
      ObjectSetInteger(0,"txCons"+x,OBJPROP_CORNER,0);
      ObjectSetInteger(0,"txCons"+x,OBJPROP_XDISTANCE,offsetX-172);
      ObjectSetInteger(0,"txCons"+x,OBJPROP_YDISTANCE,1*scaleYt+offsetY+19);
      //--
      ObjectCreate(0,"txCons"+x+"a",OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
      ObjectSetText("txCons"+x+"a",CharToStr(218),18,"Wingdings",clrRed);
      ObjectSetInteger(0,"txCons"+x+"a",OBJPROP_CORNER,0);
      ObjectSetInteger(0,"txCons"+x+"a",OBJPROP_XDISTANCE,offsetX-168);
      ObjectSetInteger(0,"txCons"+x+"a",OBJPROP_YDISTANCE,2*scaleYt+offsetY+22);
      //--
      if((clsdn) && (macddn) && (crockdn))
        {
         ObjectCreate(0,"txCons"+x+"a"+"1",OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
         ObjectSetText("txCons"+x+"a"+"1","DOWN",6,"Bodoni MT Black",clrYellow);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_CORNER,0);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_XDISTANCE,offsetX-171);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_YDISTANCE,0*scaleYt+offsetY+31);
         cal=3;
        }
      //--
      else
        {
         ObjectCreate(0,"txCons"+x+"a"+"1",OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
         ObjectSetText("txCons"+x+"a"+"1","WAIT",6,"Bodoni MT Black",clrYellow);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_CORNER,0);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_XDISTANCE,offsetX-171);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_YDISTANCE,0*scaleYt+offsetY+31);
         cal=4;
        }
     }
//--
   else if((cclose<doppr) && (dn15))
     {
      //--
      ObjectDelete("txCons"+x);
      ObjectDelete("txCons"+x+"a");
      ObjectDelete("txCons"+x+"a"+"1");
      //--
      ObjectCreate(0,"txCons"+x,OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
      ObjectSetText("txCons"+x,CharToStr(164),25,"Wingdings",clrRed);
      ObjectSetInteger(0,"txCons"+x,OBJPROP_CORNER,0);
      ObjectSetInteger(0,"txCons"+x,OBJPROP_XDISTANCE,offsetX-172);
      ObjectSetInteger(0,"txCons"+x,OBJPROP_YDISTANCE,1*scaleYt+offsetY+19);
      //--
      ObjectCreate(0,"txCons"+x+"a",OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
      ObjectSetText("txCons"+x+"a",CharToStr(218),18,"Wingdings",clrRed);
      ObjectSetInteger(0,"txCons"+x+"a",OBJPROP_CORNER,0);
      ObjectSetInteger(0,"txCons"+x+"a",OBJPROP_XDISTANCE,offsetX-168);
      ObjectSetInteger(0,"txCons"+x+"a",OBJPROP_YDISTANCE,2*scaleYt+offsetY+22);
      //--
      if((clsdn) && (macddn) && (crockdn))
        {
         ObjectCreate(0,"txCons"+x+"a"+"1",OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
         ObjectSetText("txCons"+x+"a"+"1","DOWN",6,"Bodoni MT Black",clrYellow);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_CORNER,0);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_XDISTANCE,offsetX-171);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_YDISTANCE,0*scaleYt+offsetY+31);
         cal=3;
        }
      //--
      else
        {
         ObjectCreate(0,"txCons"+x+"a"+"1",OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
         ObjectSetText("txCons"+x+"a"+"1","WAIT",6,"Bodoni MT Black",clrYellow);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_CORNER,0);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_XDISTANCE,offsetX-171);
         ObjectSetInteger(0,"txCons"+x+"a"+"1",OBJPROP_YDISTANCE,0*scaleYt+offsetY+31);
         cal=4;
        }
     }
//--
   else
     {
      //--
      ObjectCreate(0,"txCons"+x,OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
      ObjectSetText("txCons"+x,CharToStr(164),25,"Wingdings",clrYellow);
      ObjectSetInteger(0,"txCons"+x,OBJPROP_CORNER,0);
      ObjectSetInteger(0,"txCons"+x,OBJPROP_XDISTANCE,offsetX-172);
      ObjectSetInteger(0,"txCons"+x,OBJPROP_YDISTANCE,1*scaleYt+offsetY+19);
      cal=5;
     }
//--- create indicator text labels
   for(y=0;y<3;y++)
     {
      ObjectCreate(0,"txLabel"+y,OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
      ObjectSetText("txLabel"+y,labelNameStr[y],fontSize,"Bodoni MT Black",clrGold);
      ObjectSetInteger(0,"txLabel"+y,OBJPROP_CORNER,0);
      ObjectSetInteger(0,"txLabel"+y,OBJPROP_XDISTANCE,offsetX-100);
      ObjectSetInteger(0,"txLabel"+y,OBJPROP_YDISTANCE,y*scaleY+offsetY+7);
     }
//--- create arrow movement for each timeframes
   RefreshRates();
   for(x=0;x<9;x++)
     {ObjectDelete("barMove"+x);}
//--
   for(x=0;x<9;x++)
     {
      if(iClose(_Symbol,TF[x],0)>iClose(_Symbol,TF[x],1))
        {
         //--
         ObjectCreate(0,"barMove"+x,OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
         ObjectSetString(0,"barMove"+x,OBJPROP_TEXT,CharToStr(217));
         ObjectSetString(0,"barMove"+x,OBJPROP_FONT,"Wingdings");
         ObjectSetInteger(0,"barMove"+x,OBJPROP_FONTSIZE,27);
         ObjectSetInteger(0,"barMove"+x,OBJPROP_COLOR,ArrowUp);
         ObjectSetInteger(0,"barMove"+x,OBJPROP_CORNER,0);
         ObjectSetInteger(0,"barMove"+x,OBJPROP_XDISTANCE,scaleXp+x*scaleX+offsetX-3);
         ObjectSetInteger(0,"barMove"+x,OBJPROP_YDISTANCE,1*scaleY+offsetY-3);
        }
      else if(iClose(_Symbol,TF[x],0)<iClose(_Symbol,TF[x],1))
        {
         ObjectCreate(0,"barMove"+x,OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
         ObjectSetString(0,"barMove"+x,OBJPROP_TEXT,CharToStr(218));
         ObjectSetString(0,"barMove"+x,OBJPROP_FONT,"Wingdings");
         ObjectSetInteger(0,"barMove"+x,OBJPROP_FONTSIZE,27);
         ObjectSetInteger(0,"barMove"+x,OBJPROP_COLOR,ArrowDn);
         ObjectSetInteger(0,"barMove"+x,OBJPROP_CORNER,0);
         ObjectSetInteger(0,"barMove"+x,OBJPROP_XDISTANCE,scaleXp+x*scaleX+offsetX-3);
         ObjectSetInteger(0,"barMove"+x,OBJPROP_YDISTANCE,1*scaleY+offsetY-3);
        }
      else
        {
         ObjectCreate(0,"barMove"+x,OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
         ObjectSetString(0,"barMove"+x,OBJPROP_TEXT,CharToStr(108));
         ObjectSetString(0,"barMove"+x,OBJPROP_FONT,"Wingdings");
         ObjectSetInteger(0,"barMove"+x,OBJPROP_FONTSIZE,27);
         ObjectSetInteger(0,"barMove"+x,OBJPROP_COLOR,NoArrow);
         ObjectSetInteger(0,"barMove"+x,OBJPROP_CORNER,0);
         ObjectSetInteger(0,"barMove"+x,OBJPROP_XDISTANCE,scaleXp+x*scaleX+offsetX-3);
         ObjectSetInteger(0,"barMove"+x,OBJPROP_YDISTANCE,1*scaleY+offsetY-3);
        }
     }
//--- create count of points range
   RefreshRates();
   for(x=0;x<9;x++)
     {
      double hilo=iHigh(_Symbol,TF[x],0)-iLow(_Symbol,TF[x],0);
      string tcent=DoubleToStr(NormalizeDouble((hilo/er)*xx,ndigs),ndigs);
      if(ndigs==1)
        {
         if(StringLen(tcent)<=4) {double ltx=3.5-StringLen(tcent);}
         else if(StringLen(tcent)==5) {ltx=4-StringLen(tcent);}
         else {ltx=4.5-StringLen(tcent);}
        }
      else {ltx=3-StringLen(tcent);}
      if(iClose(_Symbol,TF[x],0)>iOpen(_Symbol,TF[x],0))
        {
         ObjectCreate(0,"txPips"+x,OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
         ObjectSetText("txPips"+x,tcent,9,"Bodoni MT Black",ArrowUp);
         ObjectSetInteger(0,"txPips"+x,OBJPROP_CORNER,0);
         ObjectSetInteger(0,"txPips"+x,OBJPROP_XDISTANCE,scaleXp+x*scaleX+offsetX+(ltx*4));
         ObjectSetInteger(0,"txPips"+x,OBJPROP_YDISTANCE,2*scaleY+offsetY+7);
        }
      else if(iClose(_Symbol,TF[x],0)<iOpen(_Symbol,TF[x],0))
        {
         ObjectCreate(0,"txPips"+x,OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
         ObjectSetText("txPips"+x,tcent,9,"Bodoni MT Black",ArrowDn);
         ObjectSetInteger(0,"txPips"+x,OBJPROP_CORNER,0);
         ObjectSetInteger(0,"txPips"+x,OBJPROP_XDISTANCE,scaleXp+x*scaleX+offsetX+(ltx*4));
         ObjectSetInteger(0,"txPips"+x,OBJPROP_YDISTANCE,2*scaleY+offsetY+7);
        }
      else
        {
         ObjectCreate(0,"txPips"+x,OBJ_LABEL,WindowFind("NineTFMovement ("+_Symbol+")"),0,0);
         ObjectSetText("txPips"+x,tcent,9,"Bodoni MT Black",NoArrow);
         ObjectSetInteger(0,"txPips"+x,OBJPROP_CORNER,0);
         ObjectSetInteger(0,"txPips"+x,OBJPROP_XDISTANCE,scaleXp+x*scaleX+offsetX+(ltx*4));
         ObjectSetInteger(0,"txPips"+x,OBJPROP_YDISTANCE,2*scaleY+offsetY+7);
        }
     }
//--
   p_alerts(cal);
   OnTimer();
//----
   return(0);
//----
  } //-end start()
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   MqlRates rate9[];
   ArraySetAsSeries(rate9,true);
   tmr=CopyRates(_Symbol,0,0,100,rate9);
   if(tmr==0) return;
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Do_Alerts(string msgText,string eMailSub)
  {
//--
   if(MsgAlerts) Alert(msgText);
   if(SoundAlerts) PlaySound(SoundAlertFile);
   if(eMailAlerts) SendMail(eMailSub,msgText);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string strTF(int period)
  {
   switch(period)
     {
      //--
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
   return(_Period);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void p_alerts(int alert)
  {
//--
   cmnt=(int)Minute();
   if(cmnt!=pmnt)
     {
      //--
      if((cal!=pal) && (alert==4))
        {
         alBase=StringConcatenate(short_name,_Symbol,", TF: ",strTF(_Period)," @ ",TimeToStr(TimeLocal()));
         alSubj=StringConcatenate(alBase,". The Price Began to Down,");
         alMsg=StringConcatenate(alSubj," Action: Wait and See.!!");
         pmnt=cmnt;
         pal=cal;
         Do_Alerts(alMsg,alSubj);
        }
      //--
      if((cal!=pal) && (alert==7))
        {
         alBase=StringConcatenate(short_name,_Symbol,", TF: ",strTF(_Period)," @ ",TimeToStr(TimeLocal()));
         alSubj=StringConcatenate(alBase,". The Price Goes Up,");
         alMsg=StringConcatenate(alSubj," Action: Open BUY.!!");
         pmnt=cmnt;
         pal=cal;
         Do_Alerts(alMsg,alSubj);
        }
      //--
      if((cal!=pal) && (alert==6))
        {
         alBase=StringConcatenate(short_name,_Symbol,", TF: ",strTF(_Period)," @ ",TimeToStr(TimeLocal()));
         alSubj=StringConcatenate(alBase,". The Price Began to Up,");
         alMsg=StringConcatenate(alSubj," Action: Wait and See.!!");
         pmnt=cmnt;
         pal=cal;
         Do_Alerts(alMsg,alSubj);
        }
      //--
      if((cal!=pal) && (alert==3))
        {
         alBase=StringConcatenate(short_name,_Symbol,", TF: ",strTF(_Period)," @ ",TimeToStr(TimeLocal()));
         alSubj=StringConcatenate(alBase,". The Price Goes Down,");
         alMsg=StringConcatenate(alSubj," Action: Open SELL.!!");
         pmnt=cmnt;
         pal=cal;
         Do_Alerts(alMsg,alSubj);
        }
      //--
      if((cal!=pal) && (alert==5))
        {
         alBase=StringConcatenate(short_name,_Symbol,", TF: ",strTF(_Period)," @ ",TimeToStr(TimeLocal()));
         alSubj=StringConcatenate(alBase,". Prices move was not significant,");
         alMsg=StringConcatenate(alSubj," Action: Waiting for confirmation.!!");
         pmnt=cmnt;
         pal=cal;
         Do_Alerts(alMsg,alSubj);
        }
     }
//--
   return;
//----
  } //-end p_alerts()
//+------------------------------------------------------------------+
