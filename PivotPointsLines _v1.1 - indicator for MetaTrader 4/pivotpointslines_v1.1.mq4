//+------------------------------------------------------------------+
//|                                        PivotPointsLines_v1.0.mq4 |
//|                                         Copyright 2020, NickBixy |
//|             https://www.forexfactory.com/showthread.php?t=904734 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, NickBixy"
#property link      "https://www.forexfactory.com/showthread.php?t=904734"
//#property version   "1.00"
#property strict
#property indicator_chart_window

enum pivotTypes
  {
   Standard,//Standard(Floor) Pivot Formula
   Fibonacci,//Fibonacci Pivot Formula
   Camarilla,//Camarilla Pivot Formula
   Woodie//Woodie Pivot Formula
  };

enum yesnoChoiceToggle
  {
   No,
   Yes
  };

input string Header="----------------- Pivot Point Settings------------------------------------------";//----- Pivot Point Settings
input pivotTypes pivotSelection=Standard;//Pivot Point Formula
input yesnoChoiceToggle drawFloorMidPP=No;//Draw Floor Mid Pivot Points?
input yesnoChoiceToggle showPriceLabel=No;//Show Price In Label?
input ENUM_TIMEFRAMES timeFrame=PERIOD_D1;//TimeFrame
input string Header2="----------------- Pivot Point Line/Label Customize Settings------------------------------------------";//----- Pivot Point Line/Label Customize Settings
input string customMSG="";//Custom Message Before Pivot Name
input yesnoChoiceToggle useShortLines=Yes;//Draw Short Lines
input int Line_Length=15;//Length of Short Line
input ENUM_LINE_STYLE lineStyle=STYLE_SOLID;//Line Style
input int lineWidth=1;//Line Width
input string Font="Arial";//Label Font
input int labelFontSize=9;//Label Font Size
input int ShiftLabel=10;//Label Shift +move right -move left
input yesnoChoiceToggle useSameColorLabelChoice=No;//Label use Same Color?
input color useSameColorLabelColor=clrWhite;//Label Color for Label use Same Color
input color resistantColor=clrDodgerBlue;//Resistant Line/Label Color
input color pivotColor=clrMagenta;//Pivot Line/Label Color
input color supportColor=clrRed;//Support Line/Label PP Color
input color midColor=clrGreen;//Mid PP Line/Label Color


string indiName="PPL"+" "+EnumToString(pivotSelection)+" "+EnumToString(timeFrame);

string camarillaPivotNames[]=
  {
   "PP",
   "S1",
   "S2",
   "S3",
   "S4",
   "R1",
   "R2",
   "R3",
   "R4",
   "R5",
   "S5",
  };
double camarillaValueArray[11];
string standardPivotNames[]=
  {
   "PP",
   "S1",
   "S2",
   "S3",
   "R1",
   "R2",
   "R3",
   "R4",
   "S4",
   "MR4",
   "MR3",
   "MR2",
   "MR1",
   "MS1",
   "MS2",
   "MS3",
   "MS4",
  };
double standardValueArray[17];
string woodiePivotNames[]=
  {
   "PP",
   "S1",
   "S2",
   "R1",
   "R2",
   "S3",
   "S4",
   "R3",
   "R4",
  };
double woodieValueArray[9];
string fibonacciPivotNames[]=
  {
   "PP",
   "R38",
   "R61",
   "R78",
   "R100",
   "R138",
   "R161",
   "R200",
   "S38",
   "S61",
   "S78",
   "S100",
   "S138",
   "S161",
   "S200",
  };
double fibonacciValueArray[15];
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectsDeleteAll(0,indiName,0,OBJ_TREND) ;
   ObjectsDeleteAll(0,indiName,0,OBJ_TEXT) ;


   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void deinit()
  {
   ObjectsDeleteAll(0,indiName,0,OBJ_TREND) ;
   ObjectsDeleteAll(0,indiName,0,OBJ_TEXT) ;
  }
//+------------------------------------------------------------------+
int start()
  {
   if(pivotSelection==Camarilla)
     {
      camarillaPivotPoint(camarillaValueArray);
      for(int i=0; i<ArraySize(camarillaValueArray); i++)
        {
         DrawPivotLines(camarillaValueArray[i],camarillaPivotNames[i]);
        }
     }
   if(pivotSelection==Standard)
     {

      if(drawFloorMidPP==Yes)
        {
         standardPivotPoint(standardValueArray);
         for(int i=0; i<17; i++)
           {
            DrawPivotLines(standardValueArray[i],standardPivotNames[i]);
           }
        }
      else
        {
         standardPivotPoint(standardValueArray);
         for(int i=0; i<9; i++)
           {
            DrawPivotLines(standardValueArray[i],standardPivotNames[i]);
           }
        }

     }
   if(pivotSelection==Fibonacci)
     {
      fibonacciPivotPoint(fibonacciValueArray);
      for(int i=0; i<ArraySize(fibonacciValueArray); i++)
        {
         DrawPivotLines(fibonacciValueArray[i],fibonacciPivotNames[i]);
        }
     }
   if(pivotSelection==Woodie)
     {
      woodiePivotPoint(woodieValueArray);
      for(int i=0; i<ArraySize(woodieValueArray); i++)
        {
         DrawPivotLines(woodieValueArray[i],woodiePivotNames[i]);
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
void DrawPivotLines(double value,string pivotName)
  {
   color lineLabelColor=clrNONE;
   string message="Poop";
   if(showPriceLabel==Yes)
     {
      message=customMSG+pivotName+": "+DoubleToString(value,Digits);
     }
   else
     {
      message=customMSG+pivotName;
     }


   if('R'==StringGetChar(pivotName,0))
     {
      lineLabelColor=resistantColor;
     }
   else
      if('P'==StringGetChar(pivotName,0))
        {
         lineLabelColor=pivotColor;
        }
      else
         if('S'==StringGetChar(pivotName,0))
           {
            lineLabelColor=supportColor;
           }
         else
            if('M'==StringGetChar(pivotName,0))
              {
               lineLabelColor=midColor;
              }




   string nameLine=indiName+" "+EnumToString(pivotSelection)+EnumToString(timeFrame)+pivotName+" Line";
   string nameLabel=indiName+" "+EnumToString(pivotSelection)+EnumToString(timeFrame)+pivotName+" Label";
   if(ObjectFind(nameLine) != 0)
     {
      if(useShortLines==Yes)
        {
         ObjectCreate(nameLine, OBJ_TREND, 0, Time[1]+Period()*60, value, Time[0]+Period()*60*Line_Length, value);
         ObjectSet(nameLine,OBJPROP_RAY,false);
        }
      else
        {
         ObjectCreate(nameLine,OBJ_TREND,0,iTime(NULL,timeFrame,0),value,Time[0]+Period()*60,value);
         ObjectSet(nameLine,OBJPROP_RAY,true);
        }
      ObjectSet(nameLine,OBJPROP_COLOR,lineLabelColor);
      ObjectSet(nameLine,OBJPROP_STYLE,lineStyle);
      ObjectSet(nameLine,OBJPROP_WIDTH,lineWidth);
      ObjectSet(nameLine,OBJPROP_BACK,true);
      ObjectSet(nameLine,OBJPROP_SELECTED,false);
      ObjectSet(nameLine,OBJPROP_SELECTABLE,false);
     }
   else
     {
      if(useShortLines==Yes)
        {
         ObjectSet(nameLine,OBJPROP_RAY,false);
         ObjectMove(nameLine, 0, Time[1]+Period()*60, value);
         ObjectMove(nameLine, 1, Time[0]+Period()*60*Line_Length, value);
        }
      else
        {
         ObjectSet(nameLine,OBJPROP_RAY,true);
         ObjectMove(nameLine,0,iTime(NULL,timeFrame,0),value);
         ObjectMove(nameLine,1,Time[0]+Period()*60,value);
        }

     }
   if(ObjectFind(nameLabel) != 0)
     {
      ObjectCreate(nameLabel,OBJ_TEXT,0,Time[0]+Period()*60*ShiftLabel,value);
      if(useSameColorLabelChoice==Yes)
        {
         ObjectSetText(nameLabel,message,labelFontSize,Font,useSameColorLabelColor);
        }
      else
        {
         ObjectSetText(nameLabel,message,labelFontSize,Font,lineLabelColor);
        }
      ObjectSet(nameLabel,OBJPROP_BACK,true);
      ObjectSet(nameLabel,OBJPROP_SELECTED,false);
      ObjectSet(nameLabel,OBJPROP_SELECTABLE,false);
     }
   else
     {
      ObjectMove(nameLabel, 0,Time[0]+Period()*60*ShiftLabel,value);
      if(useSameColorLabelChoice==Yes)
        {
         ObjectSetText(nameLabel,message,labelFontSize,Font,useSameColorLabelColor);
        }
      else
        {
         ObjectSetText(nameLabel,message,labelFontSize,Font,lineLabelColor);
        }
     }
   ChartRedraw(0);
  }
//camarilla formula
void camarillaPivotPoint(double &ppArrayRef[])//camrilla pivot point formula
  {
   double camRange= iHigh(NULL,timeFrame,1)-iLow(NULL,timeFrame,1);
   double prevHigh=iHigh(NULL,timeFrame,1);
   double prevLow=iLow(NULL,timeFrame,1);
   double prevClose=iClose(NULL,timeFrame,1);
   int symbolDigits=(int)MarketInfo(NULL,MODE_DIGITS);
   double R1 = ((1.1 / 12) * camRange) + prevClose;
   double R2 = ((1.1 / 6) * camRange) + prevClose;
   double R3 = ((1.1 / 4) * camRange) + prevClose;
   double R4= ((1.1/2) * camRange)+prevClose;
   double S1= prevClose -((1.1/12) * camRange);
   double S2= prevClose -((1.1/6) * camRange);
   double S3 = prevClose - ((1.1 / 4) * camRange);
   double S4 = prevClose - ((1.1 / 2) * camRange);
   double PP = (R4+S4)/2;
   double R5=((prevHigh/prevLow)*prevClose);
   double S5=(prevClose-(R5-prevClose));
   ppArrayRef[0]=PP;
   ppArrayRef[1]=S1;
   ppArrayRef[2]=S2;
   ppArrayRef[3]=S3;
   ppArrayRef[4]=S4;
   ppArrayRef[5]=R1;
   ppArrayRef[6]=R2;
   ppArrayRef[7]=R3;
   ppArrayRef[8]=R4;
   ppArrayRef[9]=R5;
   ppArrayRef[10]=S5;
  }
//+------------------------------------------------------------------+
//standard pivot point formula
void standardPivotPoint(double &ppArrayRef[])//the formula for the standard floor pivot points
  {
   double prevRange= iHigh(NULL,timeFrame,1)-iLow(NULL,timeFrame,1);
   double prevHigh = iHigh(NULL,timeFrame,1);
   double prevLow=iLow(NULL,timeFrame,1);
   double prevClose=iClose(NULL,timeFrame,1);
   double PP = (prevHigh+prevLow+prevClose)/3;
   double R1 = (PP * 2)-prevLow;
   double S1 = (PP * 2)-prevHigh;
   double R2 = PP + prevHigh - prevLow;
   double S2 = PP - prevHigh + prevLow;
   double R3 = R1 + (prevHigh-prevLow);
   double S3 = prevLow - 2 * (prevHigh-PP);
   double R4 = R3+(R2-R1);
   double S4 = S3-(S1-S2);
   ppArrayRef[0]=PP;
   ppArrayRef[1]=S1;
   ppArrayRef[2]=S2;
   ppArrayRef[3]=S3;
   ppArrayRef[4]=R1;
   ppArrayRef[5]=R2;
   ppArrayRef[6]=R3;
   ppArrayRef[7]=R4;
   ppArrayRef[8]=S4;

   if(drawFloorMidPP==Yes)
     {
      //mid pivots
      ppArrayRef[9]=(R3+R4)/2;
      ppArrayRef[10]=(R2+R3)/2;
      ppArrayRef[11]=(R1+R2)/2;
      ppArrayRef[12]=(PP+R1)/2;
      ppArrayRef[13]=(PP+S1)/2;
      ppArrayRef[14]=(S1+S2)/2;
      ppArrayRef[15]=(S2+S3)/2;
      ppArrayRef[16]=(S3+S4)/2;
     }
  }
//+------------------------------------------------------------------+
void woodiePivotPoint(double &ppArrayRef[])//woodie pivot point formula
  {
   double prevRange= iHigh(NULL,timeFrame,1)-iLow(NULL,timeFrame,1);
   double prevHigh = iHigh(NULL,timeFrame,1);
   double prevLow=iLow(NULL,timeFrame,1);
   double prevClose = iClose(NULL, timeFrame,1);
   double todayOpen = iOpen(NULL, timeFrame,0);
   double PP = (prevHigh+prevLow+(todayOpen*2))/4;
   double R1 = (PP * 2)-prevLow;
   double R2 = PP + prevRange;
   double S1 = (PP * 2)-prevHigh;
   double S2 = PP - prevRange;

   double S3 = (prevLow-2*(prevHigh-PP));
   double S4 = (S3-prevRange);

   double R3 = (prevHigh+2*(PP-prevLow));
   double R4 = (R3+prevRange);

   ppArrayRef[0]=PP;
   ppArrayRef[1]=S1;
   ppArrayRef[2]=S2;
   ppArrayRef[3]=R1;
   ppArrayRef[4]=R2;

   ppArrayRef[5]=S3;
   ppArrayRef[6]=S4;

   ppArrayRef[7]=R3;
   ppArrayRef[8]=R4;
  }
//fibonacci formula
void fibonacciPivotPoint(double &ppArrayRef[])//fibonacchi pivot point formula
  {
   double prevRange= iHigh(NULL,timeFrame,1)-iLow(NULL,timeFrame,1);
   double prevHigh = iHigh(NULL,timeFrame,1);
   double prevLow=iLow(NULL,timeFrame,1);
   double prevClose=iClose(NULL,timeFrame,1);
   double Pivot=(prevHigh+prevLow+prevClose)/3;
   double R38=  Pivot + ((prevRange) * 0.382);
   double R61=  Pivot + ((prevRange) * 0.618);
   double R78=  Pivot + ((prevRange) * 0.786);
   double R100= Pivot + ((prevRange) * 1.000);
   double R138= Pivot + ((prevRange) * 1.382);
   double R161= Pivot + ((prevRange) * 1.618);
   double R200= Pivot + ((prevRange) * 2.000);
   double S38 = Pivot - ((prevRange) * 0.382);
   double S61 = Pivot - ((prevRange) * 0.618);
   double S78 = Pivot -((prevRange)  * 0.786);
   double S100= Pivot - ((prevRange) * 1.000);
   double S138= Pivot - ((prevRange) * 1.382);
   double S161= Pivot - ((prevRange) * 1.618);
   double S200= Pivot - ((prevRange) * 2.000);
   ppArrayRef[0]=Pivot;
   ppArrayRef[1]=R38;
   ppArrayRef[2]=R61;
   ppArrayRef[3]=R78;
   ppArrayRef[4]=R100;
   ppArrayRef[5]=R138;
   ppArrayRef[6]=R161;
   ppArrayRef[7]=R200;
   ppArrayRef[8]=S38;
   ppArrayRef[9]=S61;
   ppArrayRef[10]=S78;
   ppArrayRef[11]=S100;
   ppArrayRef[12]=S138;
   ppArrayRef[13]=S161;
   ppArrayRef[14]=S200;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
