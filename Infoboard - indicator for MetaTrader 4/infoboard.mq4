//+------------------------------------------------------------------+
//|                                                    Infoboard.mq4 |
//|                                         Copyright © 2014, TrueTL |
//|                                            http://www.truetl.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, TrueTL"
#property link      "http://www.truetl.com"
#property indicator_chart_window

#import "user32.dll" 
int PostMessageW(int hWnd,int Msg,int wParam,int lParam);
int RegisterWindowMessageW(string lpString);
#import

extern string Version_140="www.truetl.com";
extern int Corner=1;
extern int Offset_X = 1;
extern int Offset_Y = 21;
extern bool All_Other_Objects_To_Background=true;
extern int Days_For_ATR=100;

extern bool Show_Symbol_and_Timeframe=1;
extern bool Show_Price_and_Spread=1;
extern bool Show_Time_and_Tick = 1;
extern bool Show_Fractal_Trend = 1;
extern bool Show_Average_Hi_Lo = 1;
extern bool Show_Today_Hi_Lo=1;
extern bool Show_Hi_Lo_to_Spread=1;
extern bool Show_Current_Bar_Hi_Lo=1;
extern bool Show_Previous_Bar_Hi_Lo=1;
extern bool Show_Tickvalue = 1;
extern bool Show_Stoplevel = 1;
extern bool Show_Swap=1;

extern color Background_Color=C'40,40,40';
extern color Text_Color=C'220,220,220';
extern color Text_Label_Color=C'120,120,120';
extern color Up_Color=Green;
extern color Middle_Color=Yellow;
extern color Down_Color=Red;

double old_price,old_spread;
string timeframe;
string tick="n";
int di,po,ti;

string info_font="Verdana";
int info_fontsize=8;

int tf[]={1,5,15,30,60,240,1440};
string tf_label[]={"M1","M5","M15","M30","H1","H4","D1"};
int tf_lab_ofset[]={4,4,2,2,4,4,4};
int xp[4],yo[10],lo[3];
int x,y,ofs_sema=23;;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init() 
  {

   int ylen=3;
   int TitleX,TitleY,WebX,WebY,extend_board,offset_col;
   int symlen=StringLen(Symbol());

   if(All_Other_Objects_To_Background) 
     {
      int hwnd=WindowHandle(Symbol(),Period());
      int msg=RegisterWindowMessageW("MetaTrader4_Internal_Message");
      PostMessageW(hwnd,msg,2,1);
     }

   if(Show_Symbol_and_Timeframe) 
     {
      if(symlen>7) 
        {
         extend_board=symlen-6;
         offset_col=symlen*5;
        }
      ylen+=3;
     }

   if(Show_Price_and_Spread) ylen+=3;
   if(Show_Time_and_Tick) ylen+=3;
   if(Show_Fractal_Trend) ylen+=4;
   if(Show_Average_Hi_Lo) ylen+=1;
   if(Show_Today_Hi_Lo) ylen+=1;
   if(Show_Hi_Lo_to_Spread) ylen+=1;
   if(Show_Current_Bar_Hi_Lo) ylen+=1;
   if(Show_Previous_Bar_Hi_Lo) ylen+=1;
   if(Show_Tickvalue) ylen+=1;
   if(Show_Stoplevel) ylen+=1;
   if(Show_Swap) ylen+=2;

   if(Corner>3) Corner=1;

   switch(Corner) 
     {
      case 0:  x = Offset_X;
      y = Offset_Y;
      TitleX = x+42;
      TitleY = y+3;
      WebX = x+60;
      WebY = y+21;
      xp[0] = x+132+offset_col;
      xp[1] = x+10;
      xp[2] = x+10;
      xp[3] = x+123;
      yo[0] = y+40;
      yo[1] = 14;
      yo[2] = 26;
      yo[3] = 6;
      yo[4] = 0;
      yo[5] = 10;
      yo[6] = 14;
      yo[7] = 24;
      yo[8] = 45;
      yo[9] = 14;
      lo[0] = -32;
      lo[1] = -28;
      lo[2] = 10;

      CreateBox("XBoard_Main",x,y,14+extend_board,ylen);

      break;

      case 1:  x = Offset_X;
      y = Offset_Y;
      TitleX = x+42;
      TitleY = y+3;
      WebX = x+60;
      WebY = y+21;
      xp[0] = x+10;
      xp[1] = x+80;
      xp[2] = x+74;
      xp[3] = x+10;
      yo[0] = y+40;
      yo[1] = 14;
      yo[2] = 26;
      yo[3] = 6;
      yo[4] = 0;
      yo[5] = 10;
      yo[6] = 14;
      yo[7] = 24;
      yo[8] = 45;
      yo[9] = 14;
      lo[0] = -32;
      lo[1] = -28;
      lo[2] = 10;

      CreateBox("XBoard_Main",x,y,14+extend_board,ylen);

      ArraySetAsSeries(tf,true);
      ArraySetAsSeries(tf_label,true);
      ArraySetAsSeries(tf_lab_ofset,true);

      break;

      case 2:  x = Offset_X;
      y = Offset_Y-(25-ylen)*14;
      TitleX = x+42;
      TitleY = y+3+330;
      WebX = x+60;
      WebY = y+325;
      xp[0] = x+132+offset_col;
      xp[1] = x+10;
      xp[2] = x+10;
      xp[3] = x+123;
      yo[0] = y+295;
      yo[1] = -30;
      yo[2] = -10;
      yo[3] = 9;
      yo[4] = 12;
      yo[5] = -29;
      yo[6] = -300;
      yo[7] = -4;
      yo[8] = -28;
      yo[9] = -14;
      lo[0] = 24;
      lo[1] = 22;
      lo[2] = -11;

      CreateBox("XBoard_Main",x,y+(25-ylen)*14,14+extend_board,ylen);

      break;

      case 3:  x = Offset_X;
      y = Offset_Y-(25-ylen)*14;
      TitleX = x+42;
      TitleY = y+3+330;
      WebX = x+60;
      WebY = y+325;
      xp[0] = x+10;
      xp[1] = x+80;
      xp[2] = x+75;
      xp[3] = x+10;
      yo[0] = y+295;
      yo[1] = -30;
      yo[2] = -10;
      yo[3] = 9;
      yo[4] = 12;
      yo[5] = -29;
      yo[6] = -300;
      yo[7] = -4;
      yo[8] = -28;
      yo[9] = -14;
      lo[0] = 24;
      lo[1] = 22;
      lo[2] = -11;

      CreateBox("XBoard_Main",x,y+(25-ylen)*14,14+extend_board,ylen);

      ArraySetAsSeries(tf,true);
      ArraySetAsSeries(tf_label,true);
      ArraySetAsSeries(tf_lab_ofset,true);

      break;
     }

   switch(Period()) 
     {
      case 1     : timeframe = "M1"; break;
      case 5     : timeframe = "M5"; break;
      case 15    : timeframe = "M15"; break;
      case 30    : timeframe = "M30"; break;
      case 60    : timeframe = "H1"; break;
      case 240   : timeframe = "H4"; break;
      case 1440  : timeframe = "D1"; break;
      case 10080 : timeframe = "W1"; break;
      case 43200 : timeframe = "MN1"; break;
      default    : timeframe = Period()+" Min"; break;
     }

   switch(Digits) 
     {
      case 0: di = 0; po = 1; ti = 1; break;
      case 1: di = 1; po = 1; ti = 10; break;
      case 2: di = 0; po = 100; ti = 1; break;
      case 3: di = 1; po = 100; ti = 10; break;
      case 4: di = 0; po = 10000; ti = 1; break;
      case 5: di = 1; po = 10000; ti = 10; break;
      default: di= Digits;
     }

   CreateText("XBoard_Title",TitleX,TitleY,"INFOBOARD",11,"Arial Black",Text_Color);
   CreateText("XBoard_Web",WebX,WebY,"www.truetl.com",7,"Arial",Text_Color);

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit() 
  {

   for(int i=ObjectsTotal(); i>=0; i--) 
     {
      if(StringSubstr(ObjectName(i),0,7)=="XBoard_") 
        {
         ObjectDelete(ObjectName(i));
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start() 
  {

   int i,c,a;
   double uplevel,dolevel,new_price,new_spread,avg;

   if(All_Other_Objects_To_Background) 
     {
      for(i=ObjectsTotal(); i>=0; i--) 
        {
         if(StringSubstr(ObjectName(i),0,7)!="XBoard_") 
           {
            ObjectSet(ObjectName(i),OBJPROP_BACK,1);
           }
        }
     }

   y=yo[0];

   for(a=1; a<11; a++) CreateText("XBoard_Line1"+"_"+a,a*16+x-3,y+lo[0],"_",20,"Verdana",Text_Label_Color);

   if(Show_Symbol_and_Timeframe) 
     {
      CreateText("XBoard_Tf",xp[0],y,timeframe,16,"Verdana",Text_Color);
      CreateText("XBoard_Symbol",xp[1],y,Symbol(),16,"Verdana",Text_Color);
      y+=yo[2];

      CreateText("XBoard_Tf_label",xp[0],y,"TF",6,"Verdana",Text_Label_Color);
      CreateText("XBoard_Symbol_label",xp[1],y,"SYMBOL",6,"Verdana",Text_Label_Color);
      y+=yo[1];
     }

   if(Show_Price_and_Spread) 
     {

      new_price=Bid;

      if(old_price<new_price) 
        {
         CreateText("XBoard_Price",xp[1],y,DoubleToStr(new_price,Digits),16,"Verdana",Up_Color);
           } else if(old_price>new_price) {
         CreateText("XBoard_Price",xp[1],y,DoubleToStr(new_price,Digits),16,"Verdana",Down_Color);
           } else {
         CreateText("XBoard_Price",xp[1],y,DoubleToStr(new_price,Digits),16,"Verdana",Middle_Color);
        }

      old_price=new_price;

      new_spread=(Ask-Bid)*po;

      if(old_spread<new_spread) 
        {
         CreateText("XBoard_Spread",xp[0],y,DoubleToStr(new_spread,di),16,"Verdana",Up_Color);
           } else if(old_spread>new_spread) {
         CreateText("XBoard_Spread",xp[0],y,DoubleToStr(new_spread,di),16,"Verdana",Down_Color);
           } else {
         CreateText("XBoard_Spread",xp[0],y,DoubleToStr(new_spread,di),16,"Verdana",Middle_Color);
        }

      old_spread=new_spread;

      y+=yo[2];
      CreateText("XBoard_Spread_label",xp[0],y,"SPREAD",6,"Verdana",Text_Label_Color);
      CreateText("XBoard_Price_label",xp[1],y,"BID PRICE",6,"Verdana",Text_Label_Color);
      y+=yo[1];
     }

   if(Show_Time_and_Tick) 
     {

      CreateText("XBoard_Tick",xp[0],y,tick,18,"Wingdings",Text_Color);

      datetime closetime=Time[0]+(Time[0]-Time[1])-TimeCurrent();
      string TimeRemain = TimeToStr(closetime,TIME_SECONDS);
      if(TimeRemain=="invalid time" || StringFind(TimeRemain,"-",0)>=0 || StringLen(TimeRemain)==0 || TimeRemain==" ") 
        {
         TimeRemain= "Waiting...";
        }

      CreateText("XBoard_Time",xp[1],y,TimeRemain,16,"Verdana",Text_Color);

      if(tick=="n") 
        {
         tick= "o";
           } else {
         tick="n";
        }

      y+=yo[2];
      CreateText("XBoard_Tick_label",xp[0],y,"TICK",6,"Verdana",Text_Label_Color);
      CreateText("XBoard_Time_label",xp[1],y,"TIME REMAIN",6,"Verdana",Text_Label_Color);
      y+=yo[1];
     }

   if(Show_Symbol_and_Timeframe || Show_Price_and_Spread || Show_Time_and_Tick) 
     {
      for(a=1; a<11; a++) CreateText("XBoard_Line2"+"_"+a,a*16+x-3,y+lo[1],"_",20,"Verdana",Text_Label_Color);
      y+=yo[3];
        } else {
      y+=yo[4];
     }

   if(Show_Fractal_Trend) 
     {

      CreateText("XBoard_Fractal_label",x+57,y,"FRACTAL TREND",6,"Verdana",Text_Label_Color);
      y+=yo[5];

      for(i=0; i<7; i++) 
        {

         CreateText("XBoard_Segment_"+i,x+16+ofs_sema*i,y,CharToStr(108),20,"Wingdings",Gray);
         CreateText("XBoard_Segment_Label_"+i,x+16+tf_lab_ofset[i]+ofs_sema*i,y+yo[7],tf_label[i],6,"Verdana",Text_Label_Color);

         for(c=3; c<200; c++) 
           {
            if(iHigh(Symbol(),tf[i],c) >= iHigh(Symbol(),tf[i],c+1) &&
               iHigh(Symbol(),tf[i],c) >= iHigh(Symbol(),tf[i],c+2) &&
               iHigh(Symbol(),tf[i],c) >= iHigh(Symbol(),tf[i],c-1) &&
               iHigh(Symbol(),tf[i],c) >= iHigh(Symbol(),tf[i],c-2))
               break;
           }
         uplevel=iHigh(Symbol(),tf[i],c);

         for(c=3; c<200; c++) 
           {
            if(iLow(Symbol(),tf[i],c) <= iLow(Symbol(),tf[i],c+1) &&
               iLow(Symbol(),tf[i],c) <= iLow(Symbol(),tf[i],c+2) &&
               iLow(Symbol(),tf[i],c) <= iLow(Symbol(),tf[i],c-1) &&
               iLow(Symbol(),tf[i],c) <= iLow(Symbol(),tf[i],c-2))
               break;
           }
         dolevel=iLow(Symbol(),tf[i],c);

         if(Bid<dolevel) ObjectSet("XBoard_Segment_"+i,OBJPROP_COLOR,Down_Color);
         if(Bid>=dolevel && Bid<=uplevel) ObjectSet("XBoard_Segment_"+i,OBJPROP_COLOR,Middle_Color);
         if(Bid>uplevel) ObjectSet("XBoard_Segment_"+i,OBJPROP_COLOR,Up_Color);
        }

      for(a=1; a<11; a++) CreateText("XBoard_Line3"+"_"+a,a*16+x-3,y+lo[2],"_",20,"Verdana",Text_Label_Color);
      y+=yo[8];
     }

   if(Show_Average_Hi_Lo) 
     {
      for(i=1; i<=Days_For_ATR; i++) 
        {
         avg+=iHigh(Symbol(),1440,i)-iLow(Symbol(),1440,i);
        }
      double PrevHiLo=(avg/Days_For_ATR)*po;
      CreateText("XBoard_ATR",xp[3],y,DoubleToStr(PrevHiLo,di),info_fontsize,"Verdana",Text_Color);
      CreateText("XBoard_ATR_label",xp[2],y,Days_For_ATR+" Days ATR:",info_fontsize,"Verdana",Text_Color);
      y+=yo[9];
     }

   if(Show_Today_Hi_Lo) 
     {
      double TodayHiLo=(iHigh(Symbol(),1440,0)-iLow(Symbol(),1440,0))*po;
      CreateText("XBoard_TodayHiLo",xp[3],y,DoubleToStr(TodayHiLo,di),info_fontsize,"Verdana",Text_Color);
      CreateText("XBoard_TodayHiLo_label",xp[2],y,"Today Hi-Lo:",info_fontsize,"Verdana",Text_Color);
      y+=yo[9];
     }

   if(Show_Hi_Lo_to_Spread) 
     {
      double HiLoToSpread=PrevHiLo/NormalizeDouble((Ask-Bid)*po,di);
      CreateText("XBoard_ATRToSpread",xp[3],y,DoubleToStr(HiLoToSpread,2)+"X",info_fontsize,"Verdana",Text_Color);
      CreateText("XBoard_ATRToSpread_label",xp[2],y,"ATR/Spread Ratio:",info_fontsize,"Verdana",Text_Color);
      y+=yo[9];
     }

   if(Show_Current_Bar_Hi_Lo) 
     {
      double BarHiLo=(High[0]-Low[0])*po;
      CreateText("XBoard_CurrentBarHiLo",xp[3],y,DoubleToStr(BarHiLo,di),info_fontsize,"Verdana",Text_Color);
      CreateText("XBoard_CurrentBarHiLo_label",xp[2],y,"Current Bar Hi-Lo:",info_fontsize,"Verdana",Text_Color);
      y+=yo[9];
     }

   if(Show_Previous_Bar_Hi_Lo) 
     {
      double PrevBarHiLo=(High[1]-Low[1])*po;
      CreateText("XBoard_PrevBarHiLo",xp[3],y,DoubleToStr(PrevBarHiLo,di),info_fontsize,"Verdana",Text_Color);
      CreateText("XBoard_PrevBarHiLo_label",xp[2],y,"Prev Bar Hi-Lo:",info_fontsize,"Verdana",Text_Color);
      y+=yo[9];
     }

   if(Show_Tickvalue) 
     {
      CreateText("XBoard_Tickvalue",xp[3],y,DoubleToStr(MarketInfo(Symbol(),MODE_TICKVALUE)*ti,3),info_fontsize,"Verdana",Text_Color);
      CreateText("XBoard_Tickvalue_label",xp[2],y,"Tickvalue:",info_fontsize,"Verdana",Text_Color);
      y+=yo[9];
     }

   if(Show_Stoplevel) 
     {
      CreateText("XBoard_Stoplevel",xp[3],y,DoubleToStr(MarketInfo(Symbol(),MODE_STOPLEVEL),3),info_fontsize,"Verdana",Text_Color);
      CreateText("XBoard_Stoplevel_label",xp[2],y,"Stoplevel:",info_fontsize,"Verdana",Text_Color);
      y+=yo[9];
     }

   if(Show_Swap) 
     {
      CreateText("XBoard_SwapLong",xp[3],y,DoubleToStr(MarketInfo(Symbol(),MODE_SWAPLONG),Digits),info_fontsize,"Verdana",Text_Color);
      CreateText("XBoard_SwapLong_label",xp[2],y,"Swap Long:",info_fontsize,"Verdana",Text_Color);
      y+=yo[9];

      CreateText("XBoard_SwapShort",xp[3],y,DoubleToStr(MarketInfo(Symbol(),MODE_SWAPSHORT),Digits),info_fontsize,"Verdana",Text_Color);
      CreateText("XBoard_SwapShort_label",xp[2],y,"Swap Short:",info_fontsize,"Verdana",Text_Color);
     }

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateText(string label,int posx,int posy,string text,int fontsize,string font,color fontcolor) 
  {
   ObjectDelete(label);
   ObjectCreate(label,OBJ_LABEL,0,0,0);
   ObjectSet(label,OBJPROP_CORNER,Corner);
   ObjectSet(label,OBJPROP_XDISTANCE,posx);
   ObjectSet(label,OBJPROP_YDISTANCE,posy);
   ObjectSet(label,OBJPROP_BACK,false);
   ObjectSetText(label,text,fontsize,font,fontcolor);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateBox(string name,int xpos,int ypos,int xsize,int ysize) 
  {
   for(int a=0; a<xsize; a++) 
     {
      for(int b=0; b<ysize; b++) 
        {
         CreateText(name+"_"+a+"_"+b,a*13+xpos,b*14+ypos,CharToStr(110),18,"Wingdings",Background_Color);
        }
     }
  }
//+------------------------------------------------------------------+
