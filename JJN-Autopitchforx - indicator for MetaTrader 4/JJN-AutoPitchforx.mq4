//+------------------------------------------------------------------+
//|                                            JJN-AutoPitchforx.mq4 |
//|                                      Copyright © 2010, JJ Newark |
//|                                           http://jjnewark.atw.hu |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, JJ Newark"
#property link      "http://jjnewark.atw.hu"

#property indicator_chart_window

extern string     _Copyright_                     = "http://jjnewark.atw.hu";
extern string     _IndicatorSetup_                = ">>> Indicator Setup:<<<";
extern bool       AutoRefresh                     = true;
extern string     Help_For_Number_of_Pitchforks   = "Maximum: 100";
extern int        Number_of_Pitchforks            = 4;
extern string     Help_For_Pitchfork_Type         = "Andrews: 0; Schiff: 1; Mod.Schiff: 2";
extern int        Pitchfork_Type                  = 0;
extern int        ZZ_TimeFrame                    = 0;
extern int        ZZ_ExtDepth                     = 12;
extern int        ZZ_ExtDeviation                 = 5;
extern int        ZZ_ExtBackstep                  = 3;
extern string     _DisplaySetup_                  = ">>> Display Setup:<<<";
extern int        Line1_Width                     = 2;
extern int        Line2_Width                     = 1;
extern int        Line3_Width                     = 1;
extern int        Line4_Width                     = 1;
extern int        Line5_Width                     = 1;
extern color      Last1_Color                     = Tomato;
extern color      Last2_Color                     = CornflowerBlue;
extern color      Last3_Color                     = LimeGreen;
extern color      Last4_Color                     = DarkOrange;
extern color      Last5_Color                     = Orchid;
extern int        MoreLine_Width                  = 1;



color P_Color[];
//int UniqueId;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 
      
      if(Number_of_Pitchforks>100) Number_of_Pitchforks=100;
      
      ArrayResize(P_Color,Number_of_Pitchforks+1);
      
      MathSrand(TimeLocal());
      //UniqueId=MathRand();
      for(int i=1; i<=Number_of_Pitchforks; i++)
      {
      int R=MathFloor(MathRand()/128);
      int G=MathFloor(MathRand()/128);
      int B=MathFloor(MathRand()/128);
      
      P_Color[i]=rgb2int(R,G,B);
      }      
      
   
         
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----

      for(int i=1; i<=Number_of_Pitchforks; i++)
      {
      ObjectDelete("_Pitch"+i);
      }  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
//----
      
      if(AutoRefresh)
      {
      
      double swingprice[];
      datetime swingdate[];
      double trendprice[];
      datetime trenddate[];
      ArrayResize(swingprice,Number_of_Pitchforks+3);
      ArrayResize(swingdate,Number_of_Pitchforks+3);
      ArrayResize(trendprice,Number_of_Pitchforks+3);
      ArrayResize(trenddate,Number_of_Pitchforks+3);
      for(int i=1; i<=Number_of_Pitchforks; i++)
      {
      swingprice[i]=0;
      swingdate[i]=0;
      trendprice[i]=0;
      trenddate[i]=0;
      }
      
      
      int found=0;
      i=0;
      
      while(found<Number_of_Pitchforks+3)
      {
         if(iCustom(Symbol(),ZZ_TimeFrame,"ZigZag",ZZ_ExtDepth,ZZ_ExtDeviation,ZZ_ExtBackstep,0,i)!=0)
         {
            swingprice[found]=iCustom(Symbol(),ZZ_TimeFrame,"ZigZag",ZZ_ExtDepth,ZZ_ExtDeviation,ZZ_ExtBackstep,0,i);
            swingdate[found]=iTime(Symbol(),ZZ_TimeFrame,i);
            found++;
         }
         i++;
      }
      
      ///////////////////////
      
      for(i=1; i<=Number_of_Pitchforks; i++)
      {
      ObjectDelete("_Pitch"+i);
      }
      
      
      
      
      if(Pitchfork_Type==1) // Schiff
      {      
      for(i=1; i<=Number_of_Pitchforks; i++)
      {
      trendprice[i]=(swingprice[i+1]+swingprice[i+2])/2;
      trenddate[i]=swingdate[i+1]-((swingdate[i+1]-swingdate[i+2])/2);
      ObjectCreate("_Pitch"+i,OBJ_PITCHFORK,0,trenddate[i],trendprice[i],swingdate[i],swingprice[i],swingdate[i+1],swingprice[i+1]);
      ObjectSet("_Pitch"+i,OBJPROP_COLOR,P_Color[i]);
      ObjectSet("_Pitch"+i,OBJPROP_WIDTH,MoreLine_Width);
      //ObjectSet("_Pitch"+i,OBJPROP_BACK,TRUE); // obj in the background
      }
      }
      if(Pitchfork_Type==2) // Modified Schiff
      {      
      for(i=1; i<=Number_of_Pitchforks; i++)
      {
      ObjectCreate("_Pitch"+i,OBJ_PITCHFORK,0,swingdate[i+2],swingprice[i],swingdate[i],swingprice[i],swingdate[i+1],swingprice[i+1]);
      ObjectSet("_Pitch"+i,OBJPROP_COLOR,P_Color[i]);
      ObjectSet("_Pitch"+i,OBJPROP_WIDTH,MoreLine_Width);
      //ObjectSet("_Pitch"+i,OBJPROP_BACK,TRUE); // obj in the background
      }
      }
      else // Andrews
      {
      for(i=1; i<=Number_of_Pitchforks; i++)
      {
      ObjectCreate("_Pitch"+i,OBJ_PITCHFORK,0,swingdate[i+2],swingprice[i+2],swingdate[i],swingprice[i],swingdate[i+1],swingprice[i+1]);
      ObjectSet("_Pitch"+i,OBJPROP_COLOR,P_Color[i]);
      ObjectSet("_Pitch"+i,OBJPROP_WIDTH,MoreLine_Width);
      //ObjectSet("_Pitch"+i,OBJPROP_BACK,TRUE); // obj in the background
      }
      }
      
           
      ObjectSet("_Pitch1",OBJPROP_COLOR,Last1_Color);
      ObjectSet("_Pitch1",OBJPROP_WIDTH,Line1_Width);
      ObjectSet("_Pitch2",OBJPROP_COLOR,Last2_Color);
      ObjectSet("_Pitch2",OBJPROP_WIDTH,Line2_Width);
      ObjectSet("_Pitch3",OBJPROP_COLOR,Last3_Color);
      ObjectSet("_Pitch3",OBJPROP_WIDTH,Line3_Width);
      ObjectSet("_Pitch4",OBJPROP_COLOR,Last4_Color);
      ObjectSet("_Pitch4",OBJPROP_WIDTH,Line4_Width);
      ObjectSet("_Pitch5",OBJPROP_COLOR,Last5_Color);
      ObjectSet("_Pitch5",OBJPROP_WIDTH,Line5_Width);
      
      //////////////////////
      
      }  
//----
   return(0);
  }
//+------------------------------------------------------------------+

//+----------------------------------------+
//| Color making from R,G,B                |
//+----------------------------------------+ 

      int rgb2int(int R,int G,int B) 
      {
      return(B*65536+G*256+R);
      }