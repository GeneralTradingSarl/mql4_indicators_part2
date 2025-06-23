//+------------------------------------------------------------------+
//|                                              MTF_MARSI_v0.10.mq4 |
//|                                                               RL |
//|                                                          http:// |
//|   28.jul.2009  - add modeMA = EMA (1)                            |
//+------------------------------------------------------------------+
#property copyright "RL (Rafaell)"
#property link      "http://"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Gold

#property indicator_level1 30
#property indicator_level2 70
#property indicator_levelcolor DarkSlateGray

extern int RSIPeriod = 14;

extern int MARSIPeriod =8;
extern int ModeMA = MODE_EMA; //Avalible: 0-SMA, 1-EMA

extern int showBars =1;
extern int fontsize = 10;
extern int Side = 1;
extern int Y = 5;
extern int X = 5;
extern color maRsiCoolor = Gold;
extern color rsiCoolor = Blue;
extern color BarLabel_color = DarkGreen;
extern int minBars = 250;

int tf[] = {1, 5, 15, 30, 60, 240};


double rsi1[],
         rsi5[],
         rsi15[],
         rsi30[],
         rsi1H[],
         rsi4H[];
double maRsi1[],
         maRsi5[],
         maRsi15[],
         maRsi30[],
         maRsi1H[],
         maRsi4H[]; 
double dRsi[];
double dMaRsi[];

string ind;
int i, j;
int pperiod;
int limit[6];
int cBars[6],
   pBars[6];
color ncol[6];   
int pTime ;  
   
//---- buffers

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

   if (ModeMA == MODE_EMA && minBars < 3*MARSIPeriod)
      minBars = 3*MARSIPeriod;   
//---- indicators

   IndicatorBuffers(8);

   SetIndexStyle(0,DRAW_LINE, Blue);
   SetIndexLabel( 0, "RSI"+Period()); 
   SetIndexBuffer(0, dRsi);
   SetIndexStyle(1,DRAW_LINE, Green);
   SetIndexLabel( 1, "MARSI"+Period()); 
   SetIndexBuffer(1, dMaRsi); 
   SetIndexBuffer(2, rsi1);
   SetIndexBuffer(3, rsi5);
   SetIndexBuffer(4, rsi15);
   SetIndexBuffer(5, rsi30);
   SetIndexBuffer(6, rsi1H);
   SetIndexBuffer(7, rsi4H);
   
   ind = StringConcatenate(WindowExpertName(),"  RSI (",RSIPeriod,")  MARSI(",MARSIPeriod,")");
   IndicatorShortName(ind);
   
   
   ArraySetAsSeries(maRsi1, true);
   ArraySetAsSeries(maRsi5, true);
   ArraySetAsSeries(maRsi15, true);
   ArraySetAsSeries(maRsi30,true);
   ArraySetAsSeries(maRsi1H, true);
   ArraySetAsSeries(maRsi4H, true);
  


   
//----

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
ObjectDelete("NumberRsi"+WindowFind(ind));
DeleteAllVObj();

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  
//----
   
   
   
   for (i=0; i<6; i++) { 
      cBars[i] = iBars(Symbol(), tf[i]);
      
      if (pBars[i] <= 0)
         limit[i] = cBars[i] - RSIPeriod - 1;
         else 
           limit[i] = cBars[i] - pBars[i];      
   }
 
   
   limit[0] = CheckArray(maRsi1, tf[0], limit[0], 0); 
   limit[1] = CheckArray(maRsi5, tf[1], limit[1], 1);
   limit[2] = CheckArray(maRsi15, tf[2], limit[2], 2);
   limit[3] = CheckArray(maRsi30, tf[3], limit[3], 3);
   limit[4] = CheckArray(maRsi1H, tf[4], limit[4], 4);
   limit[5] = CheckArray(maRsi4H, tf[5], limit[5], 5);
   

   for (i=limit[0]+MARSIPeriod; i>=0; i--)
      rsi1[i] = iRSI(Symbol(),tf[0],RSIPeriod,PRICE_CLOSE,i);
   for (i=limit[1]+MARSIPeriod; i>=0; i--)
      rsi5[i] = iRSI(Symbol(),tf[1],RSIPeriod,PRICE_CLOSE,i);   
   for (i=limit[2]+MARSIPeriod; i>=0; i--)
      rsi15[i] = iRSI(Symbol(),tf[2],RSIPeriod,PRICE_CLOSE,i);
   for (i=limit[3]+MARSIPeriod; i>=0; i--)
      rsi30[i] = iRSI(Symbol(),tf[3],RSIPeriod,PRICE_CLOSE,i);
   for (i=limit[4]+MARSIPeriod; i>=0; i--)
      rsi1H[i] = iRSI(Symbol(),tf[4],RSIPeriod,PRICE_CLOSE,i);     
   for (i=limit[5]+MARSIPeriod; i>=0; i--)
      rsi4H[i] = iRSI(Symbol(),tf[5],RSIPeriod,PRICE_CLOSE,i);
   
     
   if (ModeMA == MODE_EMA) {
      maRsi1[limit[0]] = iMAOA(maRsi1, rsi1, MARSIPeriod, MODE_SMA, limit[0]); 
      maRsi5[limit[1]] = iMAOA(maRsi5, rsi5, MARSIPeriod, MODE_SMA, limit[1]);                
      maRsi15[limit[2]] = iMAOA(maRsi15, rsi15, MARSIPeriod, MODE_SMA, limit[2]);        
      maRsi30[limit[3]] = iMAOA(maRsi30, rsi30, MARSIPeriod, MODE_SMA, limit[3]);     
      maRsi1H[limit[4]] = iMAOA(maRsi1H, rsi1H, MARSIPeriod, MODE_SMA, limit[4]);        
      maRsi4H[limit[5]] = iMAOA(maRsi4H, rsi4H, MARSIPeriod, MODE_SMA, limit[5]);   
   
      for (i=0; i<6; i++)
         limit[i] --;
   }   
   for (i=limit[0]; i>=0; i--)    
      maRsi1[i] = iMAOA(maRsi1, rsi1, MARSIPeriod, ModeMA, i); 
   for (i=limit[1]; i>=0; i--)  
      maRsi5[i] = iMAOA(maRsi5, rsi5, MARSIPeriod, ModeMA, i); 
   for (i=limit[2]; i>=0; i--)               
      maRsi15[i] = iMAOA(maRsi15, rsi15, MARSIPeriod, ModeMA, i);
   for (i=limit[3]; i>=0; i--)         
      maRsi30[i] = iMAOA(maRsi30, rsi30, MARSIPeriod, ModeMA, i);
   for (i=limit[4]; i>=0; i--)      
      maRsi1H[i] = iMAOA(maRsi1H, rsi1H, MARSIPeriod, ModeMA, i); 
   for (i=limit[5]; i>=0; i--)       
      maRsi4H[i] = iMAOA(maRsi4H, rsi4H, MARSIPeriod, ModeMA, i); 
   
   
   
   
   switch (Period()) {
      case 1: {
         if (pperiod != Period()) {
            ArrayResize(maRsi1, cBars[0]);
            
         }        
         limit[0]= cBars[0] - RSIPeriod;
         for (i=cBars[0] - RSIPeriod; i>=0; i--)
            maRsi1[i] = iMAOnArray(rsi1,0,MARSIPeriod,0,ModeMA,i);                
         ArrayCopy(dRsi, rsi1, 0, 0, WHOLE_ARRAY);
         ArrayCopy(dMaRsi, maRsi1, 0, 0, WHOLE_ARRAY);
               
      } break;
      
      case 5: {
         if (pperiod != Period()) {
            ArrayResize(maRsi5, cBars[1]);
            
         }
         limit[1]= cBars[1] - RSIPeriod;
         for (i=cBars[1] - RSIPeriod; i>=0; i--)
            maRsi5[i] = iMAOnArray(rsi5,0,MARSIPeriod,0,ModeMA,i);
         ArrayCopy(dRsi, rsi5, 0, 0, WHOLE_ARRAY);
         ArrayCopy(dMaRsi, maRsi5, 0, 0, WHOLE_ARRAY);      
      } break;

      case 15: {
         if (pperiod != Period()) {
            ArrayResize(maRsi15, cBars[2]); 
             
         }
         limit[2]= cBars[2] - RSIPeriod;          
         for (i=cBars[2] - RSIPeriod; i>=0; i--)
            maRsi15[i] = iMAOnArray(rsi15,0,MARSIPeriod,0,ModeMA,i);
         ArrayCopy(dRsi, rsi15, 0, 0, WHOLE_ARRAY);
         ArrayCopy(dMaRsi, maRsi15, 0, 0, WHOLE_ARRAY);      
      } break;

      case 30: {
         if (pperiod != Period()) {
            ArrayResize(maRsi30, cBars[3]); 
            
         } 
         limit[3]= cBars[3] - RSIPeriod;       
         for (i=cBars[3] - RSIPeriod; i>=0; i--)
            maRsi30[i] = iMAOnArray(rsi30,0,MARSIPeriod,0,ModeMA,i);
         ArrayCopy(dRsi, rsi30, 0, 0);
         ArrayCopy(dMaRsi, maRsi30, 0, 0);      
      } break;

      case 60: {
         if (pperiod != Period()) {
            ArrayResize(maRsi1H, cBars[4]);
            
         }
         limit[4]= cBars[4] - RSIPeriod;
         for (i=cBars[4] - RSIPeriod; i>=0; i--)
            maRsi1H[i] = iMAOnArray(rsi1H,0,MARSIPeriod,0,ModeMA,i);
         ArrayCopy(dRsi, rsi1H, 0, 0);
         ArrayCopy(dMaRsi, maRsi1H, 0, 0);      
      } break;

      case 240: {
         if (pperiod != Period()) {
            ArrayResize(maRsi4H, cBars[5]);
            
         }
         limit[5]= cBars[5] - RSIPeriod;
         for (i=cBars[5] - RSIPeriod; i>=0; i--)
            maRsi4H[i] = iMAOnArray(rsi4H,0,MARSIPeriod,0,ModeMA,i);
         ArrayCopy(dRsi, rsi4H, 0, 0);
         ArrayCopy(dMaRsi, maRsi4H, 0, 0);      
      } break;
      default: {
         ArrayInitialize(dRsi, EMPTY_VALUE);
         ArrayInitialize(dMaRsi, EMPTY_VALUE);
         
            
      } break;
   }


   for (i=0; i<6; i++)       
      pBars[i] = cBars[i];
   pperiod = Period();
   
    
   ncol[0] = SetColor(maRsi1, 0);      
   ncol[1] = SetColor(maRsi5, 1);
   ncol[2] = SetColor(maRsi15, 2);
   ncol[3] = SetColor(maRsi30, 3);
   ncol[4] = SetColor(maRsi1H, 4);
   ncol[5] = SetColor(maRsi4H, 5);
       
   
   if (ObjectFind("NumberRsi"+WindowFind(ind)) < 0 ) { 
   if (Side == 1 || Side == 3)
      Write("NumberRsi"+WindowFind(ind), Side, X+(12*fontsize/8), Y, "H4     H1     M30     M15     M5     M1", (fontsize+2), "Tahoma", BarLabel_color);   
   else
      Write("NumberRsi"+WindowFind(ind), Side, X+(12*fontsize/8), Y, "M1     M5     M15     M30     H1     H4", fontsize+2, "Tahoma", BarLabel_color); 
   }
   
   if (showBars == 1) {
      //int wi = WindowBarsPerChart()/6;
      int wi = WindowFirstVisibleBar()/6;
      int ce = WindowFirstVisibleBar();
      
      if (ObjectFind("bRSI4H"+WindowFind(ind)) > 0) {
         UpdateObj("bRSI4H"+WindowFind(ind), Time[ce], maRsi4H[0], Time[ce-wi], Time[ce-wi/2], ncol[5]);
         UpdateObj("bRSI1H"+WindowFind(ind), Time[ce-wi], maRsi1H[0], Time[ce-2*wi], Time[ce-3*wi/2], ncol[4]);
         UpdateObj("bRSI30"+WindowFind(ind), Time[ce-2*wi], maRsi30[0], Time[ce-3*wi], Time[ce-5*wi/2], ncol[3]);
         UpdateObj("bRSI15"+WindowFind(ind), Time[ce-3*wi], maRsi15[0], Time[ce-4*wi], Time[ce-7*wi/2], ncol[2]);
         UpdateObj("bRSI5"+WindowFind(ind), Time[ce-4*wi], maRsi5[0], Time[ce-5*wi], Time[ce-9*wi/2], ncol[1]);
         UpdateObj("bRSI1"+WindowFind(ind), Time[ce-5*wi], maRsi1[0], Time[ce-6*wi], Time[ce-11*wi/2], ncol[0]);                  
      }
      else {
         HBar("bRSI4H"+WindowFind(ind), Time[ce],  maRsi4H[0], Time[ce-wi], "H4", 20, "Tahoma", C'53,73,93', ncol[5]);
         HBar("bRSI1H"+WindowFind(ind), Time[ce-wi],  maRsi1H[0], Time[ce-2*wi], "H1", 20, "Tahoma", C'53,63,83', ncol[4]);
         HBar("bRSI30"+WindowFind(ind), Time[ce-2*wi],  maRsi30[0], Time[ce-3*wi], "M30", 20, "Tahoma", C'50,53,63', ncol[3]);
         HBar("bRSI15"+WindowFind(ind), Time[ce-3*wi],  maRsi15[0], Time[ce-4*wi], "M15", 20, "Tahoma", C'40,43,43', ncol[2]);
         HBar("bRSI5"+WindowFind(ind), Time[ce-4*wi],  maRsi5[0], Time[ce-5*wi], "M5", 20, "Tahoma", C'30,33,36', ncol[1]);
         HBar("bRSI1"+WindowFind(ind), Time[ce-5*wi],  maRsi1[0], Time[0], "M1", 20, "Tahoma", C'25,28,31', ncol[0]);
      }        
   }      
  
   if (ModeMA <= MODE_EMA && ModeMA >= 0) {
      Write("maRSI1"+WindowFind(ind),  Side, X+(5*fontsize/6) , Y+(10*fontsize/6), DoubleToStr(maRsi1[0], 2),  fontsize, "Tahoma", ncol[0]);
      Write("maRSI5"+WindowFind(ind),  Side, X+(29*fontsize/6),  Y+(10*fontsize/6), DoubleToStr(maRsi5[0], 2),  fontsize, "Tahoma", ncol[1]);
      Write("maRSI15"+WindowFind(ind), Side, X+(51*fontsize/6),  Y+(10*fontsize/6), DoubleToStr(maRsi15[0], 2), fontsize, "Tahoma", ncol[2]);
      Write("maRSI30"+WindowFind(ind), Side, X+(74*fontsize/6),  Y+(10*fontsize/6), DoubleToStr(maRsi30[0], 2), fontsize, "Tahoma", ncol[3]);
      Write("maRSI1H"+WindowFind(ind), Side, X+(97*fontsize/6),  Y+(10*fontsize/6), DoubleToStr(maRsi1H[0], 2), fontsize, "Tahoma", ncol[4]);
      Write("maRSI4H"+WindowFind(ind), Side, X+(120*fontsize/6),  Y+(10*fontsize/6), DoubleToStr(maRsi4H[0], 2), fontsize, "Tahoma", ncol[5]);
      Write("RSI1"+WindowFind(ind),  Side, X+(5*fontsize/6) , Y+(18*fontsize/6), DoubleToStr(rsi1[0], 2),  fontsize, "Tahoma", rsiCoolor);
      Write("RSI5"+WindowFind(ind),  Side, X+(29*fontsize/6),  Y+(18*fontsize/6), DoubleToStr(rsi5[0], 2),  fontsize, "Tahoma", rsiCoolor);
      Write("RSI15"+WindowFind(ind), Side, X+(51*fontsize/6),  Y+(18*fontsize/6), DoubleToStr(rsi15[0], 2), fontsize, "Tahoma", rsiCoolor);
      Write("RSI30"+WindowFind(ind), Side, X+(74*fontsize/6),  Y+(18*fontsize/6), DoubleToStr(rsi30[0], 2), fontsize, "Tahoma", rsiCoolor);
      Write("RSI1H"+WindowFind(ind), Side, X+(97*fontsize/6),  Y+(18*fontsize/6), DoubleToStr(rsi1H[0], 2), fontsize, "Tahoma", rsiCoolor);
      Write("RSI4H"+WindowFind(ind), Side, X+(120*fontsize/6),  Y+(18*fontsize/6), DoubleToStr(rsi4H[0], 2), fontsize, "Tahoma", rsiCoolor);
   }
   else 
      DeleteAllVObj();


//----
//----
   return(0);
  }
//+------------------------------------------------------------------+


void Write(string LBL, double Side, int X, int Y, string text, int fontsize, string fontname, color Tcolor)
{

   if (ObjectFind(LBL) < 0) { 
      ObjectCreate(LBL, OBJ_LABEL, WindowFind(ind), 0 , 0);
  
      ObjectSet(LBL, OBJPROP_CORNER, Side);
      ObjectSet(LBL, OBJPROP_XDISTANCE, X);
      ObjectSet(LBL, OBJPROP_YDISTANCE, Y);
   }
   ObjectSetText(LBL,text, fontsize, fontname, Tcolor);
 
}

//+------------------------------------------------------------------+
void HBar(string LBL, datetime X,  double h, datetime X1, string text, int fontsize, string fontname, color Tcolor, color T1color)
{



   ObjectCreate(LBL, OBJ_RECTANGLE, WindowFind(ind), X , 0, X1, h);
   ObjectSet(LBL, OBJPROP_COLOR, Tcolor);
   ObjectCreate(LBL+"1", OBJ_TEXT, WindowFind(ind), (X+X1)/2 , 0.9*h);
   ObjectSet(LBL+"1", OBJPROP_CORNER, 0);
   ObjectSetText(LBL+"1",text, fontsize, fontname, T1color);
//   ObjectSet(LBL+"1", OBJPROP_ANGLE, 90);
 
 
}  

//+------------------------------------------------------------------+
void DeleteAllVObj() {
   ObjectDelete("maRSI1"+WindowFind(ind));
   ObjectDelete("maRSI5"+WindowFind(ind));
   ObjectDelete("maRSI15"+WindowFind(ind));
   ObjectDelete("maRSI30"+WindowFind(ind));
   ObjectDelete("maRSI1H"+WindowFind(ind));
   ObjectDelete("maRSI4H"+WindowFind(ind));   

   ObjectDelete("RSI1"+WindowFind(ind));
   ObjectDelete("RSI5"+WindowFind(ind));
   ObjectDelete("RSI15"+WindowFind(ind));
   ObjectDelete("RSI30"+WindowFind(ind));
   ObjectDelete("RSI1H"+WindowFind(ind));
   ObjectDelete("RSI4H"+WindowFind(ind)); 
   
   if (ObjectFind("bRSI4H"+WindowFind(ind)) > 0) {
      ObjectDelete("bRSI4H"+WindowFind(ind));
      ObjectDelete("bRSI4H"+WindowFind(ind)+"1"); 
      ObjectDelete("bRSI1H"+WindowFind(ind));
      ObjectDelete("bRSI1H"+WindowFind(ind)+"1");
      ObjectDelete("bRSI30"+WindowFind(ind));
      ObjectDelete("bRSI30"+WindowFind(ind)+"1");
      ObjectDelete("bRSI15"+WindowFind(ind));
      ObjectDelete("bRSI15"+WindowFind(ind)+"1");
      ObjectDelete("bRSI5"+WindowFind(ind));
      ObjectDelete("bRSI5"+WindowFind(ind)+"1");
      ObjectDelete("bRSI1"+WindowFind(ind));
      ObjectDelete("bRSI1"+WindowFind(ind)+"1");
      
      
   }  
}

//+------------------------------------------------------------------+ 
int CheckArray(double arr[], int tf, int n, int c)
{
   
   if (Period() != tf && ArraySize(arr) != minBars+1) {
      ArrayResize(arr, minBars+1);
      return (minBars);
   }
   else if (Period() != tf) {
      return (minBars);
   }
   else 
      return (n);
}


//+------------------------------------------------------------------+
double iMAOA(double ma[], double a[],int per,int ModeMa,int sh)
{
   int i;
   double res = 0.0;
   double k;
   
   switch (ModeMa) {
      case MODE_SMA: {
         for (i=0+sh; i<per+sh;i++)
            res += a[i];
         return (res/per);
      } break;
      case MODE_EMA: {
         k = 2.0/(per+1.0);
         res = k*a[sh] + (1-k)*ma[sh+1];
         return (res);
      } break;
      default:
         return (EMPTY_VALUE);
       break;
   }
}


//+------------------------------------------------------------------+
color SetColor(double mac[], int n) 
{ 
   if (mac[0] < 30) 
      return(Red);
   else if (mac[0] > 70) 
      return(Green);
   else  {
      for (i=1; i<=limit[n]; i++) {
         if (mac[i] < 30)
            return(Green);
         if (mac[i] > 70)
            return (Red);
      }
   }  
   return(maRsiCoolor);
}


//+------------------------------------------------------------------+
void UpdateObj(string LBL, datetime X, double h, datetime X1, datetime XT,color col)
{
   ObjectMove(LBL, 0 , X, 0);
   ObjectMove(LBL, 1 , X1, h);
   ObjectMove(LBL+"1", 0 , XT, 0.9*h); 
   ObjectSet(LBL+"1", OBJPROP_COLOR, col);
}


//+------------------------------------------------------------------+     