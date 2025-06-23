
//+------------------------------------------------------------------+
//|                                       MTF Inside Bar v1.2        |
//|                                  2014 - Joca (nc32007a@gmail.com)|
//+------------------------------------------------------------------+

#property indicator_chart_window

//---- input parameters
extern int       TFup=3;
extern int       bars_back=20;
extern bool      stats=false;
extern color     UpCandleColor=Green;
extern color     DownCandleColor=Salmon;
extern int       width = 3;
extern bool      filling=false;
extern int       Font_Size=15;
extern int       Corner=3;


//---- internal parameters

int timeFrame[] = {1,5,15,30,60,240,1440,10080,43200};
string TimeFrames[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int nextTF;
color clr;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

void init() 

  {

for(int i=0;i<ArraySize(timeFrame);i++)

{
if(i==ArraySize(timeFrame)-TFup){nextTF=timeFrame[8];Print("Sorry maximum time frame reached");break;}
if(timeFrame[i]==Period()){nextTF=timeFrame[i+TFup];break;}

  }
   
  
  }

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+


void deinit() 
{

  ObjectDelete("Timeframe");
  for(int ind=0;ind<=bars_back*3+2;ind++)
  {
  ObjectDelete("rect"+ind);
  }

  
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+


int start()


  {
   
  
  
   
   //----
   
   datetime dif=Period();
   datetime difTF=nextTF;
   int ii=0;
   int ix=0;
   datetime Tini, Tfim, Tmed;
   
   
     {
     
     while(ix<=bars_back)
     
     {
     
      Tini=iTime(NULL,nextTF,ix);
      Tfim=iTime(NULL,nextTF,ix-1)-dif; //if (ix==0) {Tfim=Tfim;}
      double aux=iClose(NULL,nextTF,ix);
      double range_bar=MathAbs((iClose(NULL,nextTF,ix)-iOpen(NULL,nextTF,ix))*10000);
      
      if (iOpen(NULL,nextTF,ix) > iClose(NULL,nextTF,ix)) aux=iOpen(NULL,nextTF,ix);
          
      if (ix<=1) {Tini =iTime(NULL,nextTF,ix); Tfim=Tini+(difTF-dif)*60;}
      
      Tmed=(Tini+Tfim)/2+dif;
      
      ObjectDelete("rect"+ii);
      
      ObjectCreate("rect"+ii,OBJ_RECTANGLE, 0, 0, iOpen(NULL,nextTF,ix), 0, iClose(NULL,nextTF,ix));
      clr=DownCandleColor; if (iOpen(NULL,nextTF,ix) < iClose(NULL,nextTF,ix)) clr=UpCandleColor;
      
      ObjectSet("rect"+ii, OBJPROP_TIME1,Tini);
      ObjectSet("rect"+ii, OBJPROP_TIME2, Tfim);
      ObjectSet("rect"+ii, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("rect"+ii, OBJPROP_BACK, filling);
      ObjectSet("rect"+ii, OBJPROP_COLOR, clr);
      ObjectSet("rect"+ii, OBJPROP_WIDTH, width );
      ObjectSet("rect"+ii, OBJPROP_RAY, False);
      if (stats) ObjectSetText("rect"+ii," This Bar=  "+ MathRound(range_bar)+ " Pips", 15,"Times New Roman");
      
      ii+=1;
      
      ObjectDelete("rect"+ii);

      
      
      ObjectCreate("rect"+ii,OBJ_TREND, 0, 0, iHigh(NULL,nextTF,ix), 0, aux);
      
      
      
      ObjectSet("rect"+ii, OBJPROP_TIME1, Tmed);
      ObjectSet("rect"+ii, OBJPROP_TIME2, Tmed);
      ObjectSet("rect"+ii, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("rect"+ii, OBJPROP_BACK, 0);
      ObjectSet("rect"+ii, OBJPROP_COLOR, clr);
      ObjectSet("rect"+ii, OBJPROP_WIDTH, width );
      ObjectSet("rect"+ii, OBJPROP_RAY, False);
      
      
      
      ii+=1;
      
      ObjectDelete("rect"+ii);
      
      aux=iOpen(NULL,nextTF,ix);
      
      if (iOpen(NULL,nextTF,ix) > iClose(NULL,nextTF,ix)) aux=iClose(NULL,nextTF,ix);
      
      
      ObjectCreate("rect"+ii,OBJ_TREND, 0, 0, iLow(NULL,nextTF,ix), 0, aux);
      
      

      ObjectSet("rect"+ii, OBJPROP_TIME1, Tmed);
      ObjectSet("rect"+ii, OBJPROP_TIME2, Tmed);
      ObjectSet("rect"+ii, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("rect"+ii, OBJPROP_BACK, 0);
      ObjectSet("rect"+ii, OBJPROP_COLOR, clr);
      ObjectSet("rect"+ii, OBJPROP_WIDTH, width );
      ObjectSet("rect"+ii, OBJPROP_RAY, False);
      
      ii+=1;
      ix+=1;

      }
      
      string Message;
      
      
      for(int i=0;i<ArraySize(timeFrame);i++)
      
      {if(timeFrame[i]==nextTF){Message=TimeFrames[i]+ "\n";}}
   
   
      ObjectDelete("Timeframe");
      clr=DownCandleColor; if (iOpen(NULL,nextTF,0) < iClose(NULL,nextTF,0)) clr=UpCandleColor;
      ObjectCreate   ("Timeframe", OBJ_LABEL, 0, 0, 0);
      ObjectSet      ("Timeframe", OBJPROP_CORNER, Corner);
      ObjectSet      ("Timeframe", OBJPROP_YDISTANCE, 40);
      ObjectSet      ("Timeframe", OBJPROP_XDISTANCE, 40);
      ObjectSetText  ("Timeframe", "Inside MTF Bar = "+ Message, Font_Size, "Verdana", clr);
   
      //WindowRedraw();
      
}

   return(0);
}
//+------------------------------------------------------------------+--------+