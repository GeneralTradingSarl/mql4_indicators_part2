//+------------------------------------------------------------------+
//|                                                      i-5days.mq4 |
//|                                          Copyright © 2007, RickD |
//|                                                   www.e2e-fx.net |
//+------------------------------------------------------------------+
#property copyright "© RickD 2006"
#property link      "www.e2e-fx.net"
//----
#define major   1
#define minor   0
//----
#property  indicator_chart_window
#property  indicator_buffers 0
//----
extern string __1__= "";
extern int MaxDays = 20;
extern int FontSize= 16;
extern string FontName="System";
extern int Offset=160;
extern string __2__ = "";
extern string Text1 = "mon";
extern string Text2 = "tue";
extern string Text3 = "wed";
extern string Text4 = "thu";
extern string Text5 = "fri";
extern string __3__ = "";
extern color Color1 = clrDodgerBlue;
extern color Color2 = clrDeepPink;
extern color Color3 = clrForestGreen;
extern color Color4 = clrCoral;
extern color Color5 = clrMediumPurple;
extern string __4__ = "";
extern bool ShowDay1 = true;
extern bool ShowDay2 = true;
extern bool ShowDay3 = true;
extern bool ShowDay4 = true;
extern bool ShowDay5 = true;
//----
string Text[5];
color Color[5];
bool ShowDay[5];
string prefix="5days_";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {
   Text[0] = Text1;
   Text[1] = Text2;
   Text[2] = Text3;
   Text[3] = Text4;
   Text[4] = Text5;
//----  
   Color[0] = Color1;
   Color[1] = Color2;
   Color[2] = Color3;
   Color[3] = Color4;
   Color[4] = Color5;
//----
   ShowDay[0] = ShowDay1;
   ShowDay[1] = ShowDay2;
   ShowDay[2] = ShowDay3;
   ShowDay[3] = ShowDay4;
   ShowDay[4] = ShowDay5;
//----
   clear();
   show();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start()
  {
   show();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void show()
  {
   int P=Period();
   if(P>PERIOD_D1)
      return;
   string name="";
   int cnt=MathMin(Bars,PERIOD_D1/P*MaxDays);
   if(cnt==Bars) cnt--;
   for(int i=0; i<cnt; i++)
     {
      if(TimeDayOfWeek(Time[i])!=TimeDayOfWeek(Time[i+1]))
        {
         name=prefix+TimeToStr(Time[i]);
         int res= ObjectFind(name);
         if(res == -1)
           {
            int day=TimeDayOfWeek(Time[i]);
            if(day>0)
              {
               ObjectCreate(name,OBJ_TEXT,0,Time[i],High[i]+
                            Offset*Point);
               ObjectSetText(name,Text[day-1],FontSize,FontName,
                             Color[day-1]);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void clear()
  {
   int P=Period();
   if(P>PERIOD_D1)
      return;
   string name="";
   int cnt=MathMin(Bars,PERIOD_D1/P*MaxDays);
   for(int i=0; i<cnt; i++)
     {
      name=prefix+TimeToStr(Time[i]);
      int res = ObjectFind(name);
      if(res != -1)
         ObjectDelete(name);
     }
  }
//+------------------------------------------------------------------+
