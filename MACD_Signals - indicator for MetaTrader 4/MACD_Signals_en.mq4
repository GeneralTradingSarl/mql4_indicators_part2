//+------------------------------------------------------------------+
//|                                                    MyMACD_V2.mq4 |
//|                                       Copyright © 2008, TheXpert |
//|                                           theforexpert@gmail.com |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 2

#property indicator_color1 SkyBlue
#property indicator_color2 FireBrick

#property indicator_width1 2
#property indicator_width2 2

extern string Copyright = "Copyright (c) TheXpert, mailto:TheForEXpert@gmail.com";

extern string _1 = "Parameters for MACD";
extern int MaFast = 5;
extern int MaSlow = 73;
extern int MaSignal = 13;

extern string _2 = "Applied price (0, 1 ... 6)";
extern int Price = 3;

extern string _3 = "Extremum is valuable when distance in bars from previous valuable extremum to current is not less than <Sequence>";
extern int Sequence = 17;

extern string _4 = "Draw signal arrows or not";
extern bool DrawArrows = true;

extern string _5 = "Delete signal arrows when deleting indicator or not";
extern bool DeleteArrows = true;

extern string _6 = "Alert or not when signal appears";
extern bool UseAlert = false;

#define NONE   0
#define UP     1
#define DN     -1

int Direction = NONE; 
double Last = 0;

datetime LastTime;

//---- buffers
double UpValue[];
double DnValue[];
double PatternSignal[];
double Signal[];
double SignalDirection[];

string symbol;

int Length = 0;

int Prev = 0;
int PrevPrev = 0;
int PrevPrevPrev = 0;

double PrevValue = 0;
double PrevPrevValue = 0;
double PrevPrevPrevValue = 0;

double LastSignalValue = 0;
int LastSignal = 0;
bool IsLastSignal = false;

void PushBack(int Now, double NowValue)
{
   if (Prev == Now)
   {
      PrevValue = NowValue;
   }
   else
   {
      PrevPrevPrev = PrevPrev;
      PrevPrevPrevValue = PrevPrevValue;

      PrevPrev = Prev;
      PrevPrevValue = PrevValue;
   
      Prev = Now;
      PrevValue = NowValue;
   }
}

int init()
{
   IndicatorBuffers(5);
   
   IndicatorShortName("-=<MyMACD>=-");

   SetIndexBuffer(0, UpValue);
   SetIndexBuffer(1, DnValue);
   SetIndexBuffer(2, SignalDirection);
   SetIndexBuffer(3, PatternSignal);
   SetIndexBuffer(4, Signal);
   
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexStyle(1, DRAW_HISTOGRAM);

   symbol = Symbol();
   
   LastTime = Time[0];
   
   return(0);
}

int start()
{
   if (LastTime > Time[0])
   {
      return(0);
   }
   
   LastTime = Time[0];
   int ToCount = Bars - IndicatorCounted();
   
   bool dataIsLoaded = false;
   
   while (!dataIsLoaded)
   {
      double price = 0;
      int error = 0;
      
      dataIsLoaded = true;

      for (int i = ToCount - 2; i >= 0; i--)
      {
         price = Open[i];
         error = GetLastError();
      
         if (4066 == error) 
         {
            Sleep(1000);
            dataIsLoaded = false;
            
            break;
         }
      }
   }

   for (i = ToCount - 2; i >= 0; i--)
   {
      double ma = iMA(symbol, 0, MaSlow, 0, MODE_EMA, Price, i + 1);
      
      if(ma == 0 || ma == EMPTY_VALUE) continue;
      
      // normalizing MACD values
      double now = iMACD(symbol, 0, MaFast, MaSlow, MaSignal, Price, MODE_SIGNAL, i + 1)/ma;
      
      UpValue[i + 1] = now;
      Signal[i + 1] = 0;
      SignalDirection[i + 1] = SignalDirection[i + 2];
      PatternSignal[i + 1] = 0;

      if (Last == 0)
      {
         Last = now;
         continue;
      }

      if (Direction == NONE)
      {
         if (Last > now) Direction = DN;
         if (Last < now) Direction = UP;

         Last = now;
         Length = 1;
         
         continue;
      }
      
      if ((now - Last)*Direction > 0)
      {
         Last = now;
         Length++;
         
         Signal[i + 1] = 0;
         
         continue;
      }

      if ((now - Last)*Direction < 0)
      {
         Direction = -Direction;
         Signal[i + 1] = Direction*UpValue[i + 1];
         
         Last = now;
         
         if (Prev == 0)
         {
            PushBack(Direction, now);
            Length = 1;
            continue;
         }
         else
         {
            if (IsLastSignal)
            {
               if (Length > Sequence)
               {
                  PushBack(LastSignal, LastSignalValue);
                  PushBack(Direction, now);
                  IsLastSignal = false;
               }
               else
               {
                  LastSignal = Direction;
                  LastSignalValue = now;
                  Length = 1;
                  continue;
               }
            }
            else
            {
               if (Length > Sequence)
               {
                  PushBack(Direction, now);
               }
               else
               {
                  LastSignal = Direction;
                  LastSignalValue = now;
                  IsLastSignal = true;
                  Length = 1;
                  continue;
               }
            }

            Length = 1;
            
            // patterns
            if (     Prev == 1 
                  && PrevValue > PrevPrevPrevValue) PatternSignal[i + 1] = 1;
         
            if (     Prev == -1 
                  && PrevValue < PrevPrevPrevValue) PatternSignal[i + 1] = -1;
         
            if (     Prev == 1 
                  && PrevValue > -0.1*PrevPrevValue) PatternSignal[i + 1] = 1;
         
            if (     Prev == -1 
                  && PrevValue < -0.1*PrevPrevValue) PatternSignal[i + 1] = -1; 
                  
            if (PatternSignal[i + 1] != 0) 
            {
               if (PatternSignal[i + 1] > 0) 
               {
                  if (DrawArrows)
                  {
                     string name = "MyMACD_Arrow #" + Time[i + 1];
                     
                     ObjectCreate(name, OBJ_ARROW, 0, Time[i], Open[i]);
                     ObjectSet(name, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
                  }

                  if (UseAlert)
                  {
                     Alert("Buy Signal");
                  }

                  SignalDirection[i + 1] = 1;
               }
               
               if (PatternSignal[i + 1] < 0) 
               {
                  if (DrawArrows)
                  {
                     name = "MyMACD_Arrow #" + Time[i + 1];
                     
                     ObjectCreate(name, OBJ_ARROW, 0, Time[i], Open[i]);
                     ObjectSet(name, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
                  }
                  
                  if (UseAlert)
                  {
                     Alert("Sell signal");
                  }

                  SignalDirection[i + 1] = -1;
               }
            }
         }
      }
   }
   
   for (i = ToCount - 2; i >= 0; i--)
   {
      DnValue[i + 1] = EMPTY_VALUE;
      
      if (SignalDirection[i + 1] == -1)
      {
         DnValue[i + 1] = UpValue[i + 1];
      }
   }
   
   return(0);
}

int deinit ()
{
   if (!DeleteArrows) return (0);
   
   for (int i = ObjectsTotal() - 1; i >= 0; i--)
   {
      string name = ObjectName(i);
      
      if (StringFind(name, "MyMACD_Arrow") != -1)
      {
         ObjectDelete(name);
      }
   }
}