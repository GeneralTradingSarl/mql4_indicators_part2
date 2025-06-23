//+------------------------------------------------------------------+
//|                                         !RDS2689SignalAlerts.mq4 |
//|                                               Roy Philips-Jacobs |
//|                        Create 23/11/2013  http://www.gol2you.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013,Roy Philips Jacobs ~ Last Edited 02/07/2014"
#property link      "http://www.gol2you.com ~ Forex Videos"
//----
#property indicator_chart_window
#property indicator_buffers 5
//----
extern string RDS2689SignalAlerts="Copyright © 2013 3RJ ~ Roy Philips-Jacobs";
extern bool     MsgLevelAlerts =true;
extern bool    SoundAlertsLevel=true;
extern bool    eMailLevelAlerts=false;
extern string    SoundAlertFile="alert.wav";
extern bool    DrawHLine=true;
//----
//---- buffers
double SRBuf1[];
double SRBuf2[];
double wprBuf[];
double BuyBuf[];
double SelBuf[];
//----
double FB1,FB2;
double PLow1H,PHigh1H,PClose1H;
double L20,L40,L60,L80,SR1,SS1;
double pcls,ccls,bpcls,bccls,_price;
double POpen,PLow,PHigh,PClose,PLow1,PHigh1,PClose1,POpen1;
double PvtS,PR1,PS1,PR2,PS2,PR3,PS3,PR4,PS4,PR5,PS5,PR6,PS6;
//----
double bwbuff,bwbuff1;
//----
color font_color=Snow;
color ps_font_color=Red;
int font_size=10;
string font_face="Courier";
int corner=3; //0-for top-left corner,1-top-right,2-bottom-left,3-bottom-right
int distance_x=8;
int distance_y=9;
color color_Act=Lime;
color color_L60=Yellow;
color color_L40=Yellow;
color color_trdA=Aqua;
color color_trdB=Red;
color color_limitA=Yellow;
color color_limitB=Yellow;
//----
string PAIR,BWR,UorD;
string base,Subj,Msg,TrArea,TrdSig;
string short_name,CheckCopy,LvlD,WSign;
//----
int ccp=6;
int ccprc=5;
int bwper=26;
int LastAlertBar;
int cMnt,dec=2,pMnt;
//----
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   PAIR=Symbol(); 
   CheckCopy="Copyright © 2013 3RJ ~ Roy Philips-Jacobs";
//---- 5 additional buffers are used for counting.
   IndicatorBuffers(5);
   short_name="RDSAlerts: ";
//---- 5 indicator buffers mapping
   SetIndexBuffer(0,SRBuf1);
   SetIndexBuffer(1,SRBuf2);
   SetIndexBuffer(2,wprBuf);
   SetIndexBuffer(3,BuyBuf);
   SetIndexBuffer(4,SelBuf);
//---- indicator line
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexStyle(4,DRAW_NONE);
//---- name for DataWindow and indicator subwindow label
   SetIndexLabel(0,"RDSUp");
   SetIndexLabel(1,"RDSDn");
   SetIndexLabel(2,"WPR+(%)");
   SetIndexLabel(3,"SignalBuy");
   SetIndexLabel(4,"SignalSell");
//----
   IndicatorShortName(short_name);
   IndicatorDigits(Digits);
//----
   pcls=Close[0];
   pMnt=Minute();
   LastAlertBar=Bars-1;
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
     ObjectsDeleteAll(0,OBJ_HLINE);
     ObjectsDeleteAll(0,OBJ_LABEL); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----  
    if (RDS2689SignalAlerts!=CheckCopy) return(0);
//----
    double plw,phalf,hdprice,ldprice,tdwpr,lbwpr,cpwpr,closenow;
    double CCIAD1,CCIBD1,CCIA1,CCIB1,MA4C0,MA4C1,MA4C150,MA4C151;
    //--
    bool sigUpPrm,sigDnPrm,sigUpDn,sigDnUp,MA415U,MA415D;
    bool trsigUp,trsigDn,xtrsigUp,xtrsigDn,trsigUpDn,trsigDnUp; 
//----
    int i,cwind,hwind,lwind,owind,pwind,wwind;
    int limit,nCountedBars,prd,prdH,prdMb,prdMk,mint;
    nCountedBars=IndicatorCounted(); //ncountedbars 655
//---- check for possible errors
    if (nCountedBars<0) return(-1);
//---- last counted bar will be recounted    
    if (nCountedBars<=3)
       limit=Bars-nCountedBars-4;    
    if (nCountedBars>2)
      {
       nCountedBars--;
       limit=Bars-nCountedBars-1; //number of bars in current chart-655-1
      }
   if (limit>77) limit=77;
//----
   mint=Minute();
   if (mint==0) {Sleep(35000); RefreshRates();}
   //----
   if (Period()==43200) prd=PERIOD_MN1;
   if (Period()==10080) prd=PERIOD_W1;
   if (Period()<=1440) prd=PERIOD_D1;
   //----
   if (prd==PERIOD_MN1) {TrdSig="MonthLevelSignal: ";}
   if (prd==PERIOD_W1) {TrdSig="WeekLevelSignal: ";}
   if (prd==PERIOD_D1) {TrdSig="DayLevelSignal: ";}      
//----
   for(i=5; i>=0; i--) //- for(1)
     {         
     //----
        RefreshRates();
        POpen=iOpen(PAIR,prd,i);   
        PLow=iLow(PAIR,prd,i);
        PHigh=iHigh(PAIR,prd,i);
        PClose=iClose(PAIR,prd,i);     
        PLow1=iLow(PAIR,prd,i+1);
        PHigh1=iHigh(PAIR,prd,i+1);
        PClose1=iClose(PAIR,prd,i+1);
        POpen1=iOpen(PAIR,prd,i+1);
        //----
        PvtS=(PHigh1+PLow1+PClose1)/3;
        phalf=PHigh-((PHigh-PLow)/2);
        hdprice=iHigh(PAIR,prd,i);
        ldprice=iLow(PAIR,prd,i);
        tdwpr=100-MathAbs(iWPR(PAIR,prd,bwper,i));
        cpwpr=(PHigh-PLow)/100;
        lbwpr=PLow+(tdwpr*cpwpr);
        //----
        CCIAD1=iCCI(PAIR,prd,ccp,ccprc,i); 
        CCIBD1=iCCI(PAIR,prd,ccp,ccprc,i+1);
        sigUpPrm=(CCIAD1>0)||(CCIAD1>CCIBD1)||(CCIAD1>0&&CCIBD1<0);
        sigDnPrm=(CCIAD1<0)||(CCIAD1<CCIBD1)||(CCIAD1<0&&CCIBD1>0);
     //----
     } //-end for(1)
//----
   for (i=limit; i>=0; i--) //- for(2)
     {       
     //----    
        //----
        RefreshRates();
        PR1=((PvtS*2)-PLow1);
        PS1=((PvtS*2)-PHigh1);
        PR2=(PvtS+PHigh1-PLow1);
        PS2=(PvtS-PHigh1+PLow1);
        PR3=(PvtS*2)+(PHigh1)-(PLow1*2);
        PS3=(PvtS*2)-((PHigh1*2)-(PLow1));
        PR4=(PvtS*3)+(PHigh1)-(PLow1*3);
        PS4=(PvtS*3)-((PHigh1*3)-(PLow1));
        PR5=(PvtS*4)+(PHigh1)-(PLow1*4);
        PS5=(PvtS*4)-((PHigh1*4)-(PLow1));
        PR6=(PvtS*5)+(PHigh1)-(PLow1*5);
        PS6=(PvtS*5)-((PHigh1*5)-(PLow1));        
        //--
        if ((PHigh1-POpen1)>(POpen1-PLow1)) {SS1=(PS1-((PS1-PS2)*(0.54))); SR1=(PR1+((PR2-PR1)*(0.618)));} 
        else {SS1=(PS1-((PS1-PS2)*(0.618))); SR1=(PR1+((PR2-PR1)*(0.618)));}
        //--
        if ((PHigh1-POpen1)<(POpen1-PLow1)) {SS1=(PS1-((PS1-PS2)*(0.618))); SR1=(PR1+((PR2-PR1)*(0.54)));}
        else {SS1=(PS1-((PS1-PS2)*(0.618))); SR1=(PR1+((PR2-PR1)*(0.618)));}
        //--
        L20=(PS1+((PR1-PS1)*(0.2)));
        L40=(PS1+((PR1-PS1)*(0.4)));
        L60=(PS1+((PR1-PS1)*(0.6)));
        L80=(PS1+((PR1-PS1)*(0.8)));
        //----       
        if (prd==PERIOD_D1) 
           {
              if (Period()<=60) {prdH=PERIOD_H1; prdMb=PERIOD_M15; prdMk=PERIOD_M5;}
              else {prdH=PERIOD_H4; prdMb=PERIOD_M30; prdMk=PERIOD_M15;}
           }
        //--
        if (prd==PERIOD_W1) {prdH=PERIOD_D1; prdMb=PERIOD_H1; prdMk=PERIOD_M30;}
        //--
        if (prd==PERIOD_MN1) {prdH=PERIOD_W1; prdMb=PERIOD_H4; prdMk=PERIOD_H1;}
        //----
        RefreshRates();
        CCIA1=iCCI(PAIR,prdH,ccp,ccprc,i);
        CCIB1=iCCI(PAIR,prdH,ccp,ccprc,i+1);
        //----
        MA4C0=iMA(PAIR,prdMb,3,0,MODE_EMA,PRICE_CLOSE,i);
        MA4C1=iMA(PAIR,prdMb,3,0,MODE_EMA,PRICE_CLOSE,i+1);
        //----
        MA4C150=iMA(PAIR,prdMk,3,0,MODE_EMA,PRICE_CLOSE,i);
        MA4C151=iMA(PAIR,prdMk,3,0,MODE_EMA,PRICE_CLOSE,i+1);
        MA415U=MA4C150>MA4C151;
        MA415D=MA4C150<MA4C151;
        //----
        sigUpDn=(sigUpPrm&&(MA4C0<MA4C1));
        sigDnUp=(sigDnPrm&&(MA4C0>MA4C1));
        //----
        RefreshRates();
        trsigUp=((CCIA1>0)||(CCIA1>CCIB1)||(CCIA1>0&&CCIB1<0))&&MA415U;
        trsigDn=((CCIA1<0)||(CCIA1<CCIB1)||(CCIA1<0&&CCIB1>0))&&MA415D;
        xtrsigUp=((CCIA1>0)||(CCIA1>CCIB1)||(CCIA1>0&&CCIB1<0));
        xtrsigDn=((CCIA1<0)||(CCIA1<CCIB1)||(CCIA1<0&&CCIB1>0)); 
        trsigUpDn=(xtrsigUp&&MA415D);
        trsigDnUp=(xtrsigDn&&MA415U);
        //----
        RefreshRates();
        if (trsigDn||trsigUpDn) plw=iHigh(PAIR,PERIOD_H1,i);
        if (trsigUp||trsigDnUp) plw=iLow(PAIR,PERIOD_H1,i);
        bccls=plw;
        //--
        //----
        if (trsigUp||trsigDnUp) // Price Up
           SRBuf1[i]=plw;
           SRBuf2[i]=EMPTY_VALUE;
        //--
        if (trsigDn||trsigUpDn) // Price Down
           SRBuf2[i]=plw;
           SRBuf1[i]=EMPTY_VALUE;
        //----
        wprBuf[i]=100-MathAbs(iWPR(PAIR,1440,bwper,i));
        bwbuff=100-MathAbs(iWPR(PAIR,1440,bwper,i));
        bwbuff1=100-MathAbs(iWPR(PAIR,1440,bwper,i+1));
        if (bwbuff>100) {bwbuff=100.00;}
        if (bwbuff<0) {bwbuff=0.00;}
        if (bwbuff>bwbuff1) {UorD="Up";}
        else if (bwbuff<bwbuff1) {UorD="Down";}
        else {UorD="Flat";}
        BWR="WPR+:";
        //----
//------//
        //----
        font_color=Snow;
        color_limitA=Yellow;
        color_limitB=Yellow;
        color_L60=Yellow;
        color_L40=Yellow;
        color_Act=Lime; 
        color_trdA=Aqua;
        color_trdB=Red;
        //----     
        ObjectCreate("SignalToday",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("SignalToday",OBJPROP_CORNER,corner);
        ObjectSet("SignalToday",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("SignalToday",OBJPROP_YDISTANCE,distance_y);
        if (prd==PERIOD_MN1) ObjectSetText("SignalToday",StringConcatenate(BWR,DoubleToStr(bwbuff,dec),CharToStr(37),CharToStr(32),UorD,CharToStr(32),CharToStr(187)," MonthPrimeSignal: not significant..!"),font_size,font_face,Yellow);
        if (prd==PERIOD_W1) ObjectSetText("SignalToday",StringConcatenate(BWR,DoubleToStr(bwbuff,dec),CharToStr(37),CharToStr(32),UorD,CharToStr(32),CharToStr(187)," WeekPrimeSignal: not significant..!"),font_size,font_face,Yellow);
        if (prd==PERIOD_D1) ObjectSetText("SignalToday",StringConcatenate(BWR,DoubleToStr(bwbuff,dec),CharToStr(37),CharToStr(32),UorD,CharToStr(32),CharToStr(187)," DayPrimeSignal: not significant..!"),font_size,font_face,Yellow);
        //----
        if (sigDnPrm||sigUpDn) 
           {
              //----
              RefreshRates();
              closenow=Close[0];
              //--    
              WSign="SELL Below ";
              //--
              if (closenow<=PS6) {LvlD="PS6: "; _price=PS6;}
              if ((closenow>PS6)&&(closenow<=PS5)) {LvlD="PS5: "; _price=PS5;}
              if ((closenow>PS5)&&(closenow<=PS4)) {LvlD="PS4: "; _price=PS4;}
              if ((closenow>PS4)&&(closenow<=PS3)) {LvlD="PS3: "; _price=PS3;}
              if ((closenow>PS3)&&(closenow<=PS2)) {LvlD="PS2: "; _price=PS2;}
              if ((closenow>PS2)&&(closenow<=SS1)) {LvlD="SS1: "; _price=SS1;}
              if ((closenow>SS1)&&(closenow<=PS1)) {LvlD="PS1: "; _price=PS1;}
              if ((closenow>PS1)&&(closenow<=L20)) {LvlD="L20: "; _price=L20;}
              if ((closenow>L20)&&(closenow<=L40)) {LvlD="L40: "; _price=L40;}
              if ((closenow>L40)&&(closenow<=L60)) {LvlD="L60: "; _price=L60;}
              if ((closenow>L60)&&(closenow<=L80)) {LvlD="L80: "; _price=L80;}
              if ((closenow>L80)&&(closenow<=PR1)) {LvlD="PR1: "; _price=PR1;}
              if ((closenow>PR1)&&(closenow<=SR1)) {LvlD="SR1: "; _price=SR1;}
              if ((closenow>SR1)&&(closenow<=PR2)) {LvlD="PR2: "; _price=PR2;}
              if ((closenow>PR2)&&(closenow<=PR3)) {LvlD="PR3: "; _price=PR3;}
              if ((closenow>PR3)&&(closenow<=PR4)) {LvlD="PR4: "; _price=PR4;}
              if ((closenow>PR4)&&(closenow<=PR5)) {LvlD="PR5: "; _price=PR5;}
              if ((closenow>PR5)&&(closenow<=PR6)) {LvlD="PR6: "; _price=PR6;}
              if (closenow>PR6) {LvlD="PR7: "; _price=iHigh(PAIR,60,i);}
              SelBuf[i]=_price;
              BuyBuf[i]=EMPTY_VALUE;
              //----
              if (prd==PERIOD_MN1) ObjectSetText("SignalToday",StringConcatenate(BWR,DoubleToStr(bwbuff,dec),CharToStr(37),CharToStr(32),UorD,CharToStr(32),CharToStr(187)," MonthPrimeSignal: ",WSign,LvlD,DoubleToStr(_price,Digits)),font_size,font_face,Yellow);
              if (prd==PERIOD_W1) ObjectSetText("SignalToday",StringConcatenate(BWR,DoubleToStr(bwbuff,dec),CharToStr(37),CharToStr(32),UorD,CharToStr(32),CharToStr(187)," WeekPrimeSignal: ",WSign,LvlD,DoubleToStr(_price,Digits)),font_size,font_face,Yellow);
              if (prd==PERIOD_D1) ObjectSetText("SignalToday",StringConcatenate(BWR,DoubleToStr(bwbuff,dec),CharToStr(37),CharToStr(32),UorD,CharToStr(32),CharToStr(187)," DayPrimeSignal: ",WSign,LvlD,DoubleToStr(_price,Digits)),font_size,font_face,Yellow);
             //---              
           }
        //----        
        if (sigUpPrm||sigDnUp)
           {   
              //----
              RefreshRates();
              closenow=Close[0];
              //--
              WSign="BUY Above ";
              //--
              if (closenow<PS6) {LvlD="PS7: "; _price=iLow(PAIR,60,i);}
              if ((closenow>=PS6)&&(closenow<PS5)) {LvlD="PS6: "; _price=PS6;}
              if ((closenow>=PS5)&&(closenow<PS4)) {LvlD="PS5: "; _price=PS5;}
              if ((closenow>=PS4)&&(closenow<PS3)) {LvlD="PS4: "; _price=PS4;}
              if ((closenow>=PS3)&&(closenow<PS2)) {LvlD="PS3: "; _price=PS3;}
              if ((closenow>=PS2)&&(closenow<SS1)) {LvlD="PS2: "; _price=PS2;}
              if ((closenow>=SS1)&&(closenow<PS1)) {LvlD="SS1: "; _price=SS1;}
              if ((closenow>=PS1)&&(closenow<L20)) {LvlD="PS1: "; _price=PS1;}
              if ((closenow>=L20)&&(closenow<L40)) {LvlD="L20: "; _price=L20;}
              if ((closenow>=L40)&&(closenow<L60)) {LvlD="L40: "; _price=L40;}
              if ((closenow>=L60)&&(closenow<L80)) {LvlD="L60: "; _price=L60;}
              if ((closenow>=L80)&&(closenow<PR1)) {LvlD="L80: "; _price=L80;}
              if ((closenow>=PR1)&&(closenow<SR1)) {LvlD="PR1: "; _price=PR1;}
              if ((closenow>=SR1)&&(closenow<PR2)) {LvlD="SR1: "; _price=SR1;}
              if ((closenow>=PR2)&&(closenow<PR3)) {LvlD="PR2: "; _price=PR2;}
              if ((closenow>=PR3)&&(closenow<PR4)) {LvlD="PR3: "; _price=PR3;}
              if ((closenow>=PR4)&&(closenow<PR5)) {LvlD="PR4: "; _price=PR4;}
              if ((closenow>=PR5)&&(closenow<PR6)) {LvlD="PR5: "; _price=PR5;}
              if (closenow>PR6) {LvlD="PR6: "; _price=PR6;}
              BuyBuf[i]=_price;
              SelBuf[i]=EMPTY_VALUE;
              //----
              if (prd==PERIOD_MN1) ObjectSetText("SignalToday",StringConcatenate(BWR,DoubleToStr(bwbuff,dec),CharToStr(37),CharToStr(32),UorD,CharToStr(32),CharToStr(187)," MonthPrimeSignal: ",WSign,LvlD,DoubleToStr(_price,Digits)),font_size,font_face,Yellow);
              if (prd==PERIOD_W1) ObjectSetText("SignalToday",StringConcatenate(BWR,DoubleToStr(bwbuff,dec),CharToStr(37),CharToStr(32),UorD,CharToStr(32),CharToStr(187)," WeekPrimeSignal: ",WSign,LvlD,DoubleToStr(_price,Digits)),font_size,font_face,Yellow);
              if (prd==PERIOD_D1) ObjectSetText("SignalToday",StringConcatenate(BWR,DoubleToStr(bwbuff,dec),CharToStr(37),CharToStr(32),UorD,CharToStr(32),CharToStr(187)," DayPrimeSignal: ",WSign,LvlD,DoubleToStr(_price,Digits)),font_size,font_face,Yellow);
              //----
           }                  
        //---- 
        ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
        ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);        
        if (prd==PERIOD_MN1) ObjectSetText("TradeSignal","MonthLevelSignal: not significant..!",font_size,font_face,Yellow);
        if (prd==PERIOD_W1) ObjectSetText("TradeSignal","WeekLevelSignal: not significant..!",font_size,font_face,Yellow);
        if (prd==PERIOD_D1) ObjectSetText("TradeSignal","DayLevelSignal: not significant..!",font_size,font_face,Yellow);
        //----
        if (DrawHLine)
          {
           //---// Create Price Line
           ObjectCreate("PivotPriceToday",OBJ_HLINE,pwind,0,PvtS);
           ObjectSet("PivotPriceToday",OBJPROP_COLOR,Snow);
           ObjectSet("PivotPriceToday",OBJPROP_PRICE1,PvtS);
           //--
           ObjectCreate("OpenPriceToday",OBJ_HLINE,owind,0,POpen);
           ObjectSet("OpenPriceToday",OBJPROP_COLOR,LightGray);
           ObjectSet("OpenPriceToday",OBJPROP_PRICE1,POpen);
           //--        
           ObjectCreate("HighestPriceToday",OBJ_HLINE,hwind,0,hdprice);
           ObjectSet("HighestPriceToday",OBJPROP_COLOR,Lime);
           ObjectSet("HighestPriceToday",OBJPROP_PRICE1,hdprice);
           //--
           ObjectCreate("LowestPriceToday",OBJ_HLINE,lwind,0,ldprice);
           ObjectSet("LowestPriceToday",OBJPROP_COLOR,Yellow);
           ObjectSet("LowestPriceToday",OBJPROP_PRICE1,ldprice);
           //--
           ObjectCreate("MidPriceToday",OBJ_HLINE,cwind,0,phalf);
           ObjectSet("MidPriceToday",OBJPROP_COLOR,DeepPink);
           ObjectSet("MidPriceToday",OBJPROP_PRICE1,phalf);
           //--
           ObjectCreate("WPRPriceToday",OBJ_HLINE,wwind,0,lbwpr);
           ObjectSet("WPRPriceToday",OBJPROP_COLOR,Aqua);
           ObjectSet("WPRPriceToday",OBJPROP_PRICE1,lbwpr);
           //---
           //-- Creat Fibo Line
           double level=0.0;
           int indH=iHighest(PAIR,0,MODE_HIGH,10,0);
           int indL=iLowest(PAIR,0,MODE_LOW,10,0);
           if ((indH>=0)&& (indH<Bars)) double maxHigh=High[indH];
           if ((indL>=0)&& (indL<Bars)) double minLow=Low[indL];
           FB1=High[0];
           FB2=Low[0];
           bool TrendDown=High[1]>Low[0];
           if(Open[i]>Close[i]) 
             {
               if(!(!TrendDown && (maxHigh-minLow)*level < (Close[i]-minLow))) {TrendDown=true;} 
               else {TrendDown=false;}
             } 
           else 
             {
               if(!(TrendDown && (maxHigh-minLow)*level < (maxHigh-Close[i]))) {TrendDown =false;}
               else {TrendDown=true;}
             }
           if(TrendDown) {FB1=High[0]; FB2=Low[0];}
           else {FB1=Low[0]; FB2=High[0];}
           //--
           if((i==0)) 
             {
               ObjectDelete("FiboLevels");
               if(ObjectFind("FiboLevels")<0) 
                 {
                   if(TrendDown)
                     ObjectCreate("FiboLevels",OBJ_HLINE,0,Time[0],maxHigh-(maxHigh-minLow)*level);
                   else
                     ObjectCreate("FiboLevels",OBJ_HLINE,0,Time[0],minLow+(maxHigh-minLow)*level); 
                 } 
               else 
                 {
                   if(TrendDown)
                     ObjectMove("FiboLevels",0,Time[0],maxHigh-(maxHigh-minLow)*level);
                   else
                     ObjectMove("FiboLevels",0,Time[0],minLow+(maxHigh-minLow)*level); 
                 }
               ObjectSet("FiboLevels",OBJPROP_COLOR,Gold) ;
             }
          }
        //----
        ObjectCreate("Support_6",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("Support_6",OBJPROP_CORNER,corner);
        ObjectSet("Support_6",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("Support_6",OBJPROP_YDISTANCE,distance_y + 24);
        ObjectSetText("Support_6",StringConcatenate("PS6: ",DoubleToStr(PS6,Digits)),font_size,font_face,color_limitB);
        //----                
        ObjectCreate("Support_5",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("Support_5",OBJPROP_CORNER,corner);
        ObjectSet("Support_5",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("Support_5",OBJPROP_YDISTANCE,distance_y + 35);
        ObjectSetText("Support_5",StringConcatenate("PS5: ",DoubleToStr(PS5,Digits)),font_size,font_face,color_limitB);
        //----   
        ObjectCreate("Support_4",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("Support_4",OBJPROP_CORNER,corner);
        ObjectSet("Support_4",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("Support_4",OBJPROP_YDISTANCE,distance_y + 46);
        ObjectSetText("Support_4",StringConcatenate("PS4: ",DoubleToStr(PS4,Digits)),font_size,font_face,font_color);   
        //----
        ObjectCreate("Support_3",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("Support_3",OBJPROP_CORNER,corner);
        ObjectSet("Support_3",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("Support_3",OBJPROP_YDISTANCE,distance_y + 57);
        ObjectSetText("Support_3",StringConcatenate("PS3: ",DoubleToStr(PS3,Digits)),font_size,font_face,font_color);         
        //----
        ObjectCreate("Support_2",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("Support_2",OBJPROP_CORNER,corner);
        ObjectSet("Support_2",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("Support_2",OBJPROP_YDISTANCE,distance_y + 68);
        ObjectSetText("Support_2",StringConcatenate("PS2: ",DoubleToStr(PS2,Digits)),font_size,font_face,font_color);     
        //----
        ObjectCreate("Strong_Support_1",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("Strong_Support_1",OBJPROP_CORNER,corner);
        ObjectSet("Strong_Support_1",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("Strong_Support_1",OBJPROP_YDISTANCE,distance_y + 79);
        ObjectSetText("Strong_Support_1",StringConcatenate("SS1: ",DoubleToStr(SS1,Digits)),font_size,font_face,font_color);       
        //----   
        ObjectCreate("Support_1",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("Support_1",OBJPROP_CORNER,corner);
        ObjectSet("Support_1",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("Support_1",OBJPROP_YDISTANCE,distance_y + 90);
        ObjectSetText("Support_1",StringConcatenate("PS1: ",DoubleToStr(PS1,Digits)),font_size,font_face,font_color);       
        //----
        ObjectCreate("LevelTrade20",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("LevelTrade20",OBJPROP_CORNER,corner);
        ObjectSet("LevelTrade20",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("LevelTrade20",OBJPROP_YDISTANCE,distance_y + 101);
        ObjectSetText("LevelTrade20",StringConcatenate("L20: ",DoubleToStr(L20,Digits)),font_size,font_face,font_color);        
        //----
        ObjectCreate("LevelTrade40",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("LevelTrade40",OBJPROP_CORNER,corner);
        ObjectSet("LevelTrade40",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("LevelTrade40",OBJPROP_YDISTANCE,distance_y + 112);
        ObjectSetText("LevelTrade40",StringConcatenate("L40: ",DoubleToStr(L40,Digits)),font_size,font_face,color_L40);     
        //----
        ObjectCreate("LevelTrade60",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("LevelTrade60",OBJPROP_CORNER,corner);
        ObjectSet("LevelTrade60",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("LevelTrade60",OBJPROP_YDISTANCE,distance_y + 123);
        ObjectSetText("LevelTrade60",StringConcatenate("L60: ",DoubleToStr(L60,Digits)),font_size,font_face,color_L60);     
        //----   
        ObjectCreate("LevelTrade80",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("LevelTrade80",OBJPROP_CORNER,corner);
        ObjectSet("LevelTrade80",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("LevelTrade80",OBJPROP_YDISTANCE,distance_y + 134);
        ObjectSetText("LevelTrade80",StringConcatenate("L80: ",DoubleToStr(L80,Digits)),font_size,font_face,font_color);     
        //----
        ObjectCreate("Resistance_1",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("Resistance_1",OBJPROP_CORNER,corner);
        ObjectSet("Resistance_1",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("Resistance_1",OBJPROP_YDISTANCE,distance_y + 145);
        ObjectSetText("Resistance_1",StringConcatenate("PR1: ",DoubleToStr(PR1,Digits)),font_size,font_face,font_color);         
        //----   
        ObjectCreate("Strong_Resistance_1",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("Strong_Resistance_1",OBJPROP_CORNER,corner);
        ObjectSet("Strong_Resistance_1",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("Strong_Resistance_1",OBJPROP_YDISTANCE,distance_y + 156);
        ObjectSetText("Strong_Resistance_1",StringConcatenate("SR1: ",DoubleToStr(SR1,Digits)),font_size,font_face,font_color);     
        //----
        ObjectCreate("Resistance_2",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("Resistance_2",OBJPROP_CORNER,corner);
        ObjectSet("Resistance_2",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("Resistance_2",OBJPROP_YDISTANCE,distance_y + 167);
        ObjectSetText("Resistance_2",StringConcatenate("PR2: ",DoubleToStr(PR2,Digits)),font_size,font_face,font_color);      
        //----   
        ObjectCreate("Resistance_3",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("Resistance_3",OBJPROP_CORNER,corner);
        ObjectSet("Resistance_3",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("Resistance_3",OBJPROP_YDISTANCE,distance_y + 178);
        ObjectSetText("Resistance_3",StringConcatenate("PR3: ",DoubleToStr(PR3,Digits)),font_size,font_face,font_color);       
        //----
        ObjectCreate("Resistance_4",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("Resistance_4",OBJPROP_CORNER,corner);
        ObjectSet("Resistance_4",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("Resistance_4",OBJPROP_YDISTANCE,distance_y + 189);
        ObjectSetText("Resistance_4",StringConcatenate("PR4: ",DoubleToStr(PR4,Digits)),font_size,font_face,font_color);          
        //----
        ObjectCreate("Resistance_5",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("Resistance_5",OBJPROP_CORNER,corner);
        ObjectSet("Resistance_5",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("Resistance_5",OBJPROP_YDISTANCE,distance_y + 200);
        ObjectSetText("Resistance_5",StringConcatenate("PR5: ",DoubleToStr(PR5,Digits)),font_size,font_face,color_limitA); 
        //----        
        ObjectCreate("Resistance_6",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("Resistance_6",OBJPROP_CORNER,corner);
        ObjectSet("Resistance_6",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("Resistance_6",OBJPROP_YDISTANCE,distance_y + 211);
        ObjectSetText("Resistance_6",StringConcatenate("PR6: ",DoubleToStr(PR6,Digits)),font_size,font_face,color_limitA);  
        //----
        ObjectCreate("LogoName",OBJ_LABEL,0,0,0,0,0);
        ObjectSet("LogoName",OBJPROP_CORNER,corner);
        ObjectSet("LogoName",OBJPROP_XDISTANCE,distance_x);
        ObjectSet("LogoName",OBJPROP_YDISTANCE,distance_y + 223);
        ObjectSetText("LogoName",StringConcatenate(CharToStr(169),"3RJ",CharToStr("8482")),font_size,font_face,Gold);
        //----         
//----   
        //---- 
        if (bccls<=PS6)
           {
              //---- 
              ObjectCreate("Support_6",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Support_6",OBJPROP_CORNER,corner);
              ObjectSet("Support_6",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Support_6",OBJPROP_YDISTANCE,distance_y + 24); 
              //-- 
              if (trsigDn||trsigUpDn) font_color=color_trdB;
              else font_color=color_limitB;
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_limitB;
              //--               
              ObjectSetText("Support_6",StringConcatenate("PS6: ",DoubleToStr(PS6,Digits)),font_size,font_face,font_color);
              //---- 
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PS6: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }
              if (trsigUp||trsigDnUp)
                 {        
                   TrArea="BUY Above ";
                   font_color=color_trdA;                   
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PS6: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }                                                
              //----                   
           }
        //----  
        if ((bccls>=PS6)&&(bccls<=PS5))
           {          
              //----
              ObjectCreate("Support_6",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Support_6",OBJPROP_CORNER,corner);
              ObjectSet("Support_6",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Support_6",OBJPROP_YDISTANCE,distance_y + 24);
              //--
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_limitB;
              //--              
              ObjectSetText("Support_6",StringConcatenate("PS6: ",DoubleToStr(PS6,Digits)),font_size,font_face,font_color);
              //----                 
              ObjectCreate("Support_5",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Support_5",OBJPROP_CORNER,corner);
              ObjectSet("Support_5",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Support_5",OBJPROP_YDISTANCE,distance_y + 35);
              //--
              if (trsigUp||trsigDnUp) font_color=color_Act;
              else font_color=color_trdB;
              //--                 
              ObjectSetText("Support_5",StringConcatenate("PS5: ",DoubleToStr(PS5,Digits)),font_size,font_face,font_color); 
              //---- 
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PS5: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }
              if (trsigUp||trsigDnUp)
                 {  
                   TrArea="BUY Above ";
                   font_color=color_trdA;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PS6: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }                 
              //----
           }
        //---- 
        if ((bccls>=PS5)&&(bccls<=PS4))
           {          
              //----
              ObjectCreate("Support_5",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Support_5",OBJPROP_CORNER,corner);
              ObjectSet("Support_5",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Support_5",OBJPROP_YDISTANCE,distance_y + 35);
              //--
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_limitB;
              //--
              ObjectSetText("Support_5",StringConcatenate("PS5: ",DoubleToStr(PS5,Digits)),font_size,font_face,font_color);
              //----
              ObjectCreate("Support_4",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Support_4",OBJPROP_CORNER,corner);
              ObjectSet("Support_4",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Support_4",OBJPROP_YDISTANCE,distance_y + 46);
              //--
              if (trsigUp||trsigDnUp) font_color=color_Act;
              else font_color=color_trdB;
              //--     
              ObjectSetText("Support_4",StringConcatenate("PS4: ",DoubleToStr(PS4,Digits)),font_size,font_face,font_color);
              //----
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PS4: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }
              if (trsigUp||trsigDnUp)
                 {  
                   TrArea="BUY Above ";
                   font_color=color_trdA;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PS5: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);           
                 }                 
              //----
           }
        //----  
        if ((bccls>=PS4)&&(bccls<=PS3))
           {
              //----
              ObjectCreate("Support_4",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Support_4",OBJPROP_CORNER,corner);
              ObjectSet("Support_4",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Support_4",OBJPROP_YDISTANCE,distance_y + 46);
              //--
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_Act;
              //--                   
              ObjectSetText("Support_4",StringConcatenate("PS4: ",DoubleToStr(PS4,Digits)),font_size,font_face,font_color);   
              //----              
              ObjectCreate("Support_3",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Support_3",OBJPROP_CORNER,corner);
              ObjectSet("Support_3",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Support_3",OBJPROP_YDISTANCE,distance_y + 57);
              //--
              if (trsigUp||trsigDnUp) font_color=color_Act;
              else font_color=color_trdB;
              //--
              ObjectSetText("Support_3",StringConcatenate("PS3: ",DoubleToStr(PS3,Digits)),font_size,font_face,font_color);
              //----
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PS3: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);                  
                 }
              if (trsigUp||trsigDnUp)
                 {
                   TrArea="BUY Above ";
                   font_color=color_trdA;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PS4: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }                    
              //---- 
           }
        //----        
        if ((bccls>=PS3)&&(bccls<=PS2))
           {
              //----
              ObjectCreate("Support_3",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Support_3",OBJPROP_CORNER,corner);
              ObjectSet("Support_3",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Support_3",OBJPROP_YDISTANCE,distance_y + 57);
              //--
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_Act;
              //--               
              ObjectSetText("Support_3",StringConcatenate("PS3: ",DoubleToStr(PS3,Digits)),font_size,font_face,font_color);           
              //----
              ObjectCreate("Support_2",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Support_2",OBJPROP_CORNER,corner);
              ObjectSet("Support_2",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Support_2",OBJPROP_YDISTANCE,distance_y + 68);
              //--
              if (trsigUp||trsigDnUp) font_color=color_Act;
              else font_color=color_trdB;
              //--                
              ObjectSetText("Support_2",StringConcatenate("PS2: ",DoubleToStr(PS2,Digits)),font_size,font_face,font_color); 
              //---- 
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PS2: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }
              if (trsigUp||trsigDnUp)
                 { 
                   TrArea="BUY Above ";
                   font_color=color_trdA;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PS3: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }                    
              //----             
           }
        //----
        if ((bccls>=PS2)&&(bccls<=SS1))
           {
              //----
              ObjectCreate("Support_2",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Support_2",OBJPROP_CORNER,corner);
              ObjectSet("Support_2",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Support_2",OBJPROP_YDISTANCE,distance_y + 68);
              //--
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_Act;
              //--              
              ObjectSetText("Support_2",StringConcatenate("PS2: ",DoubleToStr(PS2,Digits)),font_size,font_face,font_color);
              //----
              ObjectCreate("Strong_Support_1",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Strong_Support_1",OBJPROP_CORNER,corner);
              ObjectSet("Strong_Support_1",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Strong_Support_1",OBJPROP_YDISTANCE,distance_y + 79);
              //--
              if (trsigUp||trsigDnUp) font_color=color_Act;
              else font_color=color_trdB;
              //--                
              ObjectSetText("Strong_Support_1",StringConcatenate("SS1: ",DoubleToStr(SS1,Digits)),font_size,font_face,font_color);
              //---- 
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"SS1: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }
              if (trsigUp||trsigDnUp)
                 {
                   TrArea="BUY Above ";
                   font_color=color_trdA;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PS2: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }                   
              //----                    
           }
        //----
        if ((bccls>=SS1)&&(bccls<=PS1))
           {
              //----
              ObjectCreate("Strong_Support_1",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Strong_Support_1",OBJPROP_CORNER,corner);
              ObjectSet("Strong_Support_1",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Strong_Support_1",OBJPROP_YDISTANCE,distance_y + 79);
              //--
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_Act;
              //--                
              ObjectSetText("Strong_Support_1",StringConcatenate("SS1: ",DoubleToStr(SS1,Digits)),font_size,font_face,font_color); 
              //----   
              ObjectCreate("Support_1",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Support_1",OBJPROP_CORNER,corner);
              ObjectSet("Support_1",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Support_1",OBJPROP_YDISTANCE,distance_y + 90);
              //--
              if (trsigUp||trsigDnUp) font_color=color_Act;
              else font_color=color_trdB;
              //--               
              ObjectSetText("Support_1",StringConcatenate("PS1: ",DoubleToStr(PS1,Digits)),font_size,font_face,font_color);  
              //---- 
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PS1: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }
              if (trsigUp||trsigDnUp)
                 {   
                   TrArea="BUY Above ";
                   font_color=color_trdA;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"SS1: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }                     
              //----             
           }
        //----
        if ((bccls>=PS1)&&(bccls<=L20))
           {
              //----
              ObjectCreate("Support_1",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Support_1",OBJPROP_CORNER,corner);
              ObjectSet("Support_1",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Support_1",OBJPROP_YDISTANCE,distance_y + 90);
              //--
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_Act;
              //--               
              ObjectSetText("Support_1",StringConcatenate("PS1: ",DoubleToStr(PS1,Digits)),font_size,font_face,font_color);        
              //----
              ObjectCreate("LevelTrade20",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("LevelTrade20",OBJPROP_CORNER,corner);
              ObjectSet("LevelTrade20",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("LevelTrade20",OBJPROP_YDISTANCE,distance_y + 101);
              //--
              if (trsigUp||trsigDnUp) font_color=color_Act;
              else font_color=color_trdB;
              //--               
              ObjectSetText("LevelTrade20",StringConcatenate("L20: ",DoubleToStr(L20,Digits)),font_size,font_face,font_color);
              //---- 
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"L20: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }
              if (trsigUp||trsigDnUp)
                 {
                   TrArea="BUY Above ";
                   font_color=color_trdA;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PS1: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }                     
              //----                    
           }
        //----
        if ((bccls>=L20)&&(bccls<=L40))
           {
              //----
              ObjectCreate("LevelTrade20",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("LevelTrade20",OBJPROP_CORNER,corner);
              ObjectSet("LevelTrade20",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("LevelTrade20",OBJPROP_YDISTANCE,distance_y + 101);
              //--
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_Act;
              //--               
              ObjectSetText("LevelTrade20",StringConcatenate("L20: ",DoubleToStr(L20,Digits)),font_size,font_face,font_color);          
              //----
              ObjectCreate("LevelTrade40",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("LevelTrade40",OBJPROP_CORNER,corner);
              ObjectSet("LevelTrade40",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("LevelTrade40",OBJPROP_YDISTANCE,distance_y + 112);
              //--
              if (trsigUp||trsigDnUp) font_color=color_Act;
              else font_color=color_trdB;
              //--                 
              ObjectSetText("LevelTrade40",StringConcatenate("L40: ",DoubleToStr(L40,Digits)),font_size,font_face,font_color);
              //---- 
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"L40: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }
              if (trsigUp||trsigDnUp)
                 {
                   TrArea="BUY Above ";
                   font_color=color_trdA;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"L20: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }                  
              //----                  
           }
        //----        
        if ((bccls>=L40)&&(bccls<=L60))
           {
              //----
              ObjectCreate("LevelTrade40",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("LevelTrade40",OBJPROP_CORNER,corner);
              ObjectSet("LevelTrade40",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("LevelTrade40",OBJPROP_YDISTANCE,distance_y + 112);
              //--
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_Act;
              //--                
              ObjectSetText("LevelTrade40",StringConcatenate("L40: ",DoubleToStr(L40,Digits)),font_size,font_face,font_color);
              //----           
              ObjectCreate("LevelTrade60",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("LevelTrade60",OBJPROP_CORNER,corner);
              ObjectSet("LevelTrade60",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("LevelTrade60",OBJPROP_YDISTANCE,distance_y + 123);
              //--
              if (trsigUp||trsigDnUp) font_color=color_Act;
              else font_color=color_trdB;
              //--                
              ObjectSetText("LevelTrade60",StringConcatenate("L60: ",DoubleToStr(L60,Digits)),font_size,font_face,font_color);
              //---- 
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"L60: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }
              if (trsigUp||trsigDnUp)
                 {
                   TrArea="BUY Above ";
                   font_color=color_trdA;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"L40: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }               
              //----                         
           }
        //----
        if ((bccls>=L60)&&(bccls<=L80))
           {
              //----
              ObjectCreate("LevelTrade60",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("LevelTrade60",OBJPROP_CORNER,corner);
              ObjectSet("LevelTrade60",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("LevelTrade60",OBJPROP_YDISTANCE,distance_y + 123);
              //--
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_Act;
              //--                
              ObjectSetText("LevelTrade60",StringConcatenate("L60: ",DoubleToStr(L60,Digits)),font_size,font_face,font_color);    
              //----  
              ObjectCreate("LevelTrade80",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("LevelTrade80",OBJPROP_CORNER,corner);
              ObjectSet("LevelTrade80",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("LevelTrade80",OBJPROP_YDISTANCE,distance_y + 134);
              //--
              if (trsigUp||trsigDnUp) font_color=color_Act;
              else font_color=color_trdB;
              //--               
              ObjectSetText("LevelTrade80",StringConcatenate("L80: ",DoubleToStr(L80,Digits)),font_size,font_face,font_color);
              //---- 
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"L80: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }
              if (trsigUp||trsigDnUp)
                 {    
                   TrArea="BUY Above ";
                   font_color=color_trdA;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"L60: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }               
              //----           
           }
        //----
        if ((bccls>=L80)&&(bccls<=PR1))
           {
              //----
              ObjectCreate("LevelTrade80",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("LevelTrade80",OBJPROP_CORNER,corner);
              ObjectSet("LevelTrade80",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("LevelTrade80",OBJPROP_YDISTANCE,distance_y + 134);
              //--
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_Act;
              //--               
              ObjectSetText("LevelTrade80",StringConcatenate("L80: ",DoubleToStr(L80,Digits)),font_size,font_face,font_color);  
              //----  
              ObjectCreate("Resistance_1",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Resistance_1",OBJPROP_CORNER,corner);
              ObjectSet("Resistance_1",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Resistance_1",OBJPROP_YDISTANCE,distance_y + 145);
              //--
              if (trsigUp||trsigDnUp) font_color=color_Act;
              else font_color=color_trdB;
              //--               
              ObjectSetText("Resistance_1",StringConcatenate("PR1: ",DoubleToStr(PR1,Digits)),font_size,font_face,font_color);
              //---- 
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PR1: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }
              if (trsigUp||trsigDnUp)
                 {              
                   TrArea="BUY Above ";
                   font_color=color_trdA;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"L80: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }                    
              //----                 
           }
        //----        
        if ((bccls>=PR1)&&(bccls<=SR1))
           {
              //----            
              ObjectCreate("Resistance_1",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Resistance_1",OBJPROP_CORNER,corner);
              ObjectSet("Resistance_1",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Resistance_1",OBJPROP_YDISTANCE,distance_y + 145);
              //--
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_Act;
              //--                 
              ObjectSetText("Resistance_1",StringConcatenate("PR1: ",DoubleToStr(PR1,Digits)),font_size,font_face,font_color);         
              //---- 
              ObjectCreate("Strong_Resistance_1",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Strong_Resistance_1",OBJPROP_CORNER,corner);
              ObjectSet("Strong_Resistance_1",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Strong_Resistance_1",OBJPROP_YDISTANCE,distance_y + 156);
              //--
              if (trsigUp||trsigDnUp) font_color=color_Act;
              else font_color=color_trdB;
              //--                   
              ObjectSetText("Strong_Resistance_1",StringConcatenate("SR1: ",DoubleToStr(SR1,Digits)),font_size,font_face,font_color);
              //---- 
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"SR1: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }
              if (trsigUp||trsigDnUp)
                 {                 
                   TrArea="BUY Above ";
                   font_color=color_trdA;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PR1: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }                
              //----                                
           }
        //----   
        if ((bccls>=SR1)&&(bccls<=PR2))
           {
              //----   
              ObjectCreate("Strong_Resistance_1",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Strong_Resistance_1",OBJPROP_CORNER,corner);
              ObjectSet("Strong_Resistance_1",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Strong_Resistance_1",OBJPROP_YDISTANCE,distance_y + 156);
              //--
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_Act;
              //--                 
              ObjectSetText("Strong_Resistance_1",StringConcatenate("SR1: ",DoubleToStr(SR1,Digits)),font_size,font_face,font_color);  
              //----    
              ObjectCreate("Resistance_2",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Resistance_2",OBJPROP_CORNER,corner);
              ObjectSet("Resistance_2",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Resistance_2",OBJPROP_YDISTANCE,distance_y + 167);
              //--
              if (trsigUp||trsigDnUp) font_color=color_Act;
              else font_color=color_trdB;
              //--               
              ObjectSetText("Resistance_2",StringConcatenate("PR2: ",DoubleToStr(PR2,Digits)),font_size,font_face,font_color);
              //---- 
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PR2: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }
              if (trsigUp||trsigDnUp)
                 {        
                   TrArea="BUY Above ";
                   font_color=color_trdA;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"SR1: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }                     
              //----                               
           }
        //----           
        if ((bccls>=PR2)&&(bccls<=PR3))
           {
              //----
              ObjectCreate("Resistance_2",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Resistance_2",OBJPROP_CORNER,corner);
              ObjectSet("Resistance_2",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Resistance_2",OBJPROP_YDISTANCE,distance_y + 167);
              //--
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_Act;
              //--                 
              ObjectSetText("Resistance_2",StringConcatenate("PR2: ",DoubleToStr(PR2,Digits)),font_size,font_face,font_color);      
              //---- 
              ObjectCreate("Resistance_3",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Resistance_3",OBJPROP_CORNER,corner);
              ObjectSet("Resistance_3",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Resistance_3",OBJPROP_YDISTANCE,distance_y + 178);
              //--
              if (trsigUp||trsigDnUp) font_color=color_Act;
              else font_color=color_trdB;
              //--                
              ObjectSetText("Resistance_3",StringConcatenate("PR3: ",DoubleToStr(PR3,Digits)),font_size,font_face,font_color);
              //---- 
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PR3: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }
              if (trsigUp||trsigDnUp)
                 {           
                   TrArea="BUY Above ";
                   font_color=color_trdA;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PR2: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }                   
              //----               
           }
        //----
        if ((bccls>=PR3)&&(bccls<=PR4))
           {
              //----   
              ObjectCreate("Resistance_3",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Resistance_3",OBJPROP_CORNER,corner);
              ObjectSet("Resistance_3",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Resistance_3",OBJPROP_YDISTANCE,distance_y + 178);
              //--
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_Act;
              //--                
              ObjectSetText("Resistance_3",StringConcatenate("PR3: ",DoubleToStr(PR3,Digits)),font_size,font_face,font_color);       
              //----  
              ObjectCreate("Resistance_4",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Resistance_4",OBJPROP_CORNER,corner);
              ObjectSet("Resistance_4",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Resistance_4",OBJPROP_YDISTANCE,distance_y + 189);
              //--
              if (trsigUp||trsigDnUp) font_color=color_Act;
              else font_color=color_trdB;
              //--               
              ObjectSetText("Resistance_4",StringConcatenate("PR4: ",DoubleToStr(PR4,Digits)),font_size,font_face,font_color);
              //---- 
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PR4: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }
              if (trsigUp||trsigDnUp)
                 {                   
                   TrArea="BUY Above ";
                   font_color=color_trdA;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PR3: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }                          
              //----                      
           }
        //----
        if ((bccls>=PR4)&&(bccls<=PR5))
           {
              //----
              ObjectCreate("Resistance_4",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Resistance_4",OBJPROP_CORNER,corner);
              ObjectSet("Resistance_4",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Resistance_4",OBJPROP_YDISTANCE,distance_y + 189);
              //--
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_Act;
              //--                  
              ObjectSetText("Resistance_4",StringConcatenate("PR4: ",DoubleToStr(PR4,Digits)),font_size,font_face,font_color);          
              //----   
              ObjectCreate("Resistance_5",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Resistance_5",OBJPROP_CORNER,corner);
              ObjectSet("Resistance_5",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Resistance_5",OBJPROP_YDISTANCE,distance_y + 200);
              //--
              if (trsigUp||trsigDnUp) font_color=color_Act;
              else font_color=color_trdB;
              //--                
              ObjectSetText("Resistance_5",StringConcatenate("PR5: ",DoubleToStr(PR5,Digits)),font_size,font_face,font_color); 
              //---- 
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PR5: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }
              if (trsigUp||trsigDnUp)
                 {                  
                   TrArea="BUY Above ";
                   font_color=color_trdA;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PR4: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }                 
              //----                       
           }
        //----
        if ((bccls>=PR5)&&(bccls<=PR6))
           {
              //----
              ObjectCreate("Resistance_5",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Resistance_5",OBJPROP_CORNER,corner);
              ObjectSet("Resistance_5",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Resistance_5",OBJPROP_YDISTANCE,distance_y + 200);
              //--
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_Act;
              //--                  
              ObjectSetText("Resistance_5",StringConcatenate("PR5: ",DoubleToStr(PR5,Digits)),font_size,font_face,font_color);          
              //----   
              ObjectCreate("Resistance_6",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Resistance_6",OBJPROP_CORNER,corner);
              ObjectSet("Resistance_6",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Resistance_6",OBJPROP_YDISTANCE,distance_y + 211);
              //--
              if (trsigUp||trsigDnUp) font_color=color_Act;
              else font_color=color_trdB;
              //--                
              ObjectSetText("Resistance_6",StringConcatenate("PR6: ",DoubleToStr(PR6,Digits)),font_size,font_face,font_color); 
              //---- 
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PR6: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }
              if (trsigUp||trsigDnUp)
                 {                  
                   TrArea="BUY Above ";
                   font_color=color_trdA;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea ,"PR5: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }                 
              //----                       
           }
        //----
        if (bccls>=PR6)
           {
              //----
              ObjectCreate("Resistance_6",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("Resistance_6",OBJPROP_CORNER,corner);
              ObjectSet("Resistance_6",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("Resistance_6",OBJPROP_YDISTANCE,distance_y + 211);
              //--
              if (trsigUp||trsigDnUp) font_color=color_trdA;
              else font_color=color_limitA;
              if (trsigDn||trsigUpDn) font_color=color_trdB;
              else font_color=color_limitA;
              //--                
              ObjectSetText("Resistance_6",StringConcatenate("PR6: ",DoubleToStr(PR6,Digits)),font_size,font_face,font_color); 
              //---- 
              ObjectCreate("TradeSignal",OBJ_LABEL,0,0,0,0,0);
              ObjectSet("TradeSignal",OBJPROP_CORNER,corner);
              ObjectSet("TradeSignal",OBJPROP_XDISTANCE,distance_x);
              ObjectSet("TradeSignal",OBJPROP_YDISTANCE,distance_y + 13);
              if (trsigDn||trsigUpDn) 
                 {
                   TrArea="SELL Below ";
                   font_color=color_trdB;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PR6: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }
              if (trsigUp||trsigDnUp)
                 {
                   TrArea="BUY Above ";
                   font_color=color_trdA;
                   ObjectSetText("TradeSignal",StringConcatenate(TrdSig,TrArea,"PR6: ",DoubleToStr(plw,Digits)),font_size,font_face,font_color);
                 }                
              //----         
           }         
        //----
        CkLevel();
     //----   
     } //-end for(2)
   //--
//---- //-end start()
   return(0);
  }
//----//

//+--+
void DoAlerts(string msgLevelText,string eMailLevelSub)
  {
     if (MsgLevelAlerts) Alert(msgLevelText);
     if (SoundAlertsLevel) PlaySound(SoundAlertFile);    
     if (eMailLevelAlerts) SendMail(eMailLevelSub,msgLevelText);
  }
//+--+

//+--+
string TF2Str(int period)
  {
   switch(period)
     {
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
   return(Period());
  }  
//+--+

int CkLevel()
   {
      //----
      RefreshRates();
      cMnt=Minute();
      ccls=Close[0];
      if (cMnt != pMnt)
         {
            //----
            if ((pcls<PS6)&&(ccls>=PS6&&ccls<PS5))
               {      
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PS6,Digits),", Support 6 (S6) Level Cross Up");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }       
            //----
            if ((pcls<PS5)&&(ccls>=PS5&&ccls<PS4))
               {      
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PS5,Digits),", Support 5 (S5) Level Cross Up");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }                         
            //----             
            if ((pcls>=PS5&&pcls<PS4)&&(ccls>=PS4&&ccls<PS3))
               {      
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PS4,Digits),", Support 4 (S4) Level Cross Up");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }                         
            //----             
            if ((pcls>=PS4&&pcls<PS3)&&(ccls>=PS3&&ccls<PS2))
               {      
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PS3,Digits),", Support 3 (S3) Level Cross Up");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }                         
            //----    
            if ((pcls>=PS3&&pcls<PS2)&&(ccls>=PS2&&ccls<SS1))
               {                    
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PS2,Digits),", Support 2 (S2) Level Cross Up");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }                                                    
            //----                                                    
            if ((pcls>=PS2&&pcls<SS1)&&(ccls>=SS1&&ccls<PS1))
               {                      
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(SS1,Digits)," Strong Support 1 (SS1) Level Cross Up");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }                                       
            //----    
            if ((pcls>=SS1&&pcls<PS1)&&(ccls>=PS1&&ccls<L20))
               {                    
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PS1,Digits),", Support 1 (S1) Level Cross Up");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }                                         
            //----    
            if ((pcls>=PS1&&pcls<L20)&&(ccls>=L20&&ccls<L40))
               {                    
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(L20,Digits),", Line 20 Level Cross Up");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }                                        
            //----   
            if ((pcls>=L20&&pcls<L40)&&(ccls>=L40&&ccls<L60))
               {                         
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(L40,Digits),", Line 40 Level Cross Up");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }   
            //----                            
            if ((pcls>=L40&&pcls<L60)&&(ccls>=L60&&ccls<L80))
               {                   
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(L60,Digits),", Line 60 Level Cross Up");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }   
            //----                       
            if ((pcls>=L60&&pcls<L80)&&(ccls>=L80&&ccls<PR1))
               {                  
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(L80,Digits),", Line 80 Level Cross Up");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }   
            //----                      
            if ((pcls>=L80&&pcls<PR1)&&(ccls>=PR1&&ccls<SR1))
               {                   
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PR1,Digits),", Resistance 1 (R1) Level Cross Up");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }                                       
            //----    
            if ((pcls>=PR1&&pcls<SR1)&&(ccls>=SR1&&ccls<PR2))
               {                 
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(SR1,Digits),", Strong Resistance 1 (SR1) Level Cross Up");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }                                             
            //----    
            if ((pcls>=SR1&&pcls<PR2)&&(ccls>=PR2&&ccls<PR3))
               {                  
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PR2,Digits),", Resistance 2 (R2) Level Cross Up");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }   
            //----                       
            if ((pcls>=PR2&&pcls<PR3)&&(ccls>=PR3&&ccls<PR4))
               {                     
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PR3,Digits),", Resistance 3 (R3) Level Cross Up");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }   
            //----                       
            if ((pcls>=PR3&&pcls<PR4)&&(ccls>=PR4&&ccls<PR5))
               {                     
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PR4,Digits),", Resistance 4 (R4) Level Cross Up");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               } 
            //----                       
            if ((pcls>=PR4&&pcls<PR5)&&(ccls>=PR5&&ccls<PR6))
               {                     
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PR5,Digits),", Resistance 5 (R5) Level Cross Up");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }                
            //----                      
            if ((pcls>=PR5&&pcls<PR6)&&(ccls>=PR6))
               {                     
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PR6,Digits),", Resistance 6 (R6) Level Cross Up");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }                
            //----
            //----             
            if ((pcls>=PR6)&&(ccls<PR6&&ccls>=PR5))
               {                  
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PR6,Digits),", Resistance 6 (R6) Level Cross Down");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }                                                                                  
            //----             
            if ((pcls>=PR5)&&(ccls<PR5&&ccls>=PR4))
               {                  
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PR5,Digits),", Resistance 5 (R5) Level Cross Down");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }  
            //---- 
            if ((pcls>=PR4&&pcls<PR5)&&(ccls<PR4&&ccls>=PR3))
               {                  
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PR4,Digits),", Resistance 4 (R4) Level Cross Down");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }  
            //----                                                      
            if ((pcls>=PR3&&pcls<PR4)&&(ccls<PR3&&ccls>=PR2))
               {                  
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PR3,Digits),", Resistance 3 (R3) Level Cross Down");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }                                       
            //----       
            if ((pcls>=PR2&&pcls<PR3)&&(ccls<PR2&&ccls>=SR1))
               {                  
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PR2,Digits),", Resistance 2 (R2) Level Cross Down");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }                                          
            //----    
            if ((pcls>=SR1&&pcls<PR2)&&(ccls<SR1&&ccls>=PR1))
               {                    
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(SR1,Digits)," Strong Resistance 1 (SR1) Level Cross Down");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }   
            //----             
            if ((pcls>=PR1&&pcls<SR1)&&(ccls<PR1&&ccls>=L80))
               {                   
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PR1,Digits),", Resistance 1 (R1) Level Cross Down");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }   
            //----                    
            if ((pcls>=L80&&pcls<PR1)&&(ccls<L80&&ccls>=L60))
               {                   
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(L80,Digits),", Line 80 Level Cross Down");
                  Msg=StringConcatenate(Subj ," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }                                            
            //----    
            if ((pcls>=L60&&pcls<L80)&&(ccls<L60&&ccls>=L40))
               {                    
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(L60,Digits),", Line 60 Level Cross Down");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }                                         
            //----    
            if ((pcls>=L40&&pcls<L60)&&(ccls<L40&&ccls>=L20))
               {                  
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(L40,Digits),", Line 40 Level Cross Down");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }   
            //----                                             
            if ((pcls>=L20&&pcls<L40)&&(ccls<L20&&ccls>=PS1))
               {                    
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(L20,Digits),", Line 20 Level Cross Down");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }   
            //----                                          
            if ((pcls>=PS1&&pcls<L20)&&(ccls<PS1&&ccls>=SS1))
               {                     
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PS1,Digits),", Support 1 (S1) Level Cross Down");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }   
            //----                                            
            if ((pcls>=SS1&&pcls<PS1)&&(ccls<SS1&&ccls>=PS2))
               {                     
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(SS1,Digits),", Strong Support 1 (SS1) Level Cross Down");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }   
            //----     
            if ((pcls>=PS2&&pcls<SS1)&&(ccls<PS2&&ccls>=PS3))
               {                  
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PS2,Digits),", Support 2 (S2) Level Cross Down");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }   
            //----   
            if ((pcls>=PS3&&pcls<PS2)&&(ccls<PS3&&ccls>=PS4))
               {                   
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PS3,Digits),", Support 3 (S3) Level Cross Down");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }  
            //----                 
            if ((pcls>=PS4&&pcls<PS3)&&(ccls<PS4&&ccls>=PS5))
               {                   
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PS4,Digits),", Support 4 (S4) Level Cross Down");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }    
            //----                 
            if ((pcls>=PS5&&pcls<PS4)&&(ccls<PS5&&ccls>=PS6))
               {                   
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PS5,Digits),", Support 5 (S5) Level Cross Down");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }                                                     
             //---- 
            if ((pcls>=PS6&&pcls<PS5)&&(ccls<PS6))
               {                   
                  base=StringConcatenate(PAIR,", RDS TF: ",TF2Str(Period()));
                  Subj=StringConcatenate(base,", ",DoubleToStr(PS6,Digits),", Support 6 (S6) Level Cross Down");
                  Msg=StringConcatenate(Subj," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
                  if (Bars>LastAlertBar) {LastAlertBar=Bars; DoAlerts(Msg,Subj);}
               }                                                     
             //----              
             pcls=ccls;
             pMnt=cMnt;           
         } //- end if cMnt
      return(pcls);
   } //-end CkLevel() 
//+--+
//+------------------------------------------------------------------+