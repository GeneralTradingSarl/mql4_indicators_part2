//+------------------------------------------------------------------+
//|                                        Horizontal_Grid_Lines.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//| Edits and Improvements: File45                                   |
//| https://www.mql5.com/en/users/file45/publications                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "3.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum LW
  {
   One = 1,
   Two = 2,
   Three= 3,
   Four = 4,
   Five = 5,
  };

// DEFAULT INPUTS : START

input int   HGrid_Weeks = 10;            // Weeks 
input double HGrid_Pips = 15.0;          // H-Grid Size  
input color HLine_2=MidnightBlue;    // H-Grid 1 Round Number Color
input LW Line_2_Width=1;               // H-Grid 1 Width
input ENUM_LINE_STYLE Line_2_Style=STYLE_DOT;  // H-Grid 1 Style
input color HLine_1=MidnightBlue;    // H-Grid 2 Non Round Number Color
input LW Line_1_Width=1;               // H-Grid 2 Width
input ENUM_LINE_STYLE Line_1_Style=STYLE_DOT;  // H-Grid 2 Style

input string H_Grid="hg";  // Label Text 
input bool Show_Label=true;            // Label Visible
input color Font_Color=DodgerBlue;  // Label Color
input int Font_Size = 11;                // Font Size
input bool Font_Bold = false;            // Font Bold
input int Font_Corner = 1;               // Corner
input int Left_Right = 25;               // Left - Right
input int Up_Down = 190;                 // Up - Down

// DEFAULT INPUTS : END

string HGrid_text;
string FB;

bool firstTime=true;
datetime lastTime=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   firstTime=true;

   switch(Font_Bold)
     {
      case 0 : FB = "Arial"; break;
      case 1 : FB = "Arial Bold"; break;
     }
   return(INIT_SUCCEEDED);
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
   ObjectCreate("HGrid_txt",OBJ_LABEL,0,0,0);
   ObjectSet("HGrid_txt",OBJPROP_CORNER,Font_Corner);
   ObjectSet("HGrid_txt",OBJPROP_XDISTANCE,Left_Right);
   ObjectSet("HGrid_txt",OBJPROP_YDISTANCE,Up_Down);
   if(Show_Label==1)
     {
      ObjectSetText("HGrid_txt",H_Grid+": "+DoubleToString(HGrid_Pips,1),Font_Size,FB,Font_Color);
     }
   else
     {
      ObjectSetText("HGrid_txt","");
     }

   int    counted_bars=IndicatorCounted();

   if(true /*lastTime == 0 || CurTime() - lastTime > 5*/)
     {
      firstTime= false;
      lastTime = CurTime();

      if(HGrid_Weeks>0 && HGrid_Pips*10>0)
        {
         double weekH = iHigh( NULL, PERIOD_W1, 0 );
         double weekL = iLow( NULL, PERIOD_W1, 0 );

         for(int i=1; i<HGrid_Weeks; i++)
           {
            weekH = MathMax( weekH, iHigh( NULL, PERIOD_W1, i ) );
            weekL = MathMin( weekL, iLow( NULL, PERIOD_W1, i ) );
           }

         double pipRange=HGrid_Pips *10*Point;
         if(Symbol()=="GOLD" || Symbol()=="XAUUSD")
           {
            pipRange=pipRange*10.0;
           }

         double topPips = (weekH + pipRange) - MathMod( weekH, pipRange );
         double botPips = weekL - MathMod( weekL, pipRange );

         for(double p=botPips; p<=topPips; p+=pipRange)
           {
            string gridname="grid_"+DoubleToStr(p,Digits);
            ObjectCreate(gridname,OBJ_HLINE,0,0,p);

            double pp=p/Point;
            //int pInt = MathRound(pp);
            int pInt=StrToInteger(DoubleToStr(pp,0));
            int mod=100;
            if(Symbol()=="GOLD" || Symbol()=="XAUUSD")
               mod=1000;
            if((pInt%mod)==0)
              {
               ObjectSet(gridname,OBJPROP_COLOR,HLine_2);
               ObjectSet(gridname,OBJPROP_STYLE,Line_2_Style);
               ObjectSet(gridname,OBJPROP_WIDTH,Line_2_Width);
              }
            else
              {
               ObjectSet(gridname,OBJPROP_COLOR,HLine_1);
               ObjectSet(gridname,OBJPROP_STYLE,Line_1_Style);
               ObjectSet(gridname,OBJPROP_WIDTH,Line_1_Width);
               ObjectSet(gridname,OBJPROP_PRICE1,p);
               ObjectSet(gridname,OBJPROP_BACK,true);
              }
           }
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int i=ObjectsTotal()-1; i>=0; i--)
     {
      string name=ObjectName(i);
      if(StringFind(name,"grid_")>=0)
         ObjectDelete(name);
     }
   ObjectDelete("HGrid_txt");

   return;
  }
//+------------------------------------------------------------------+
