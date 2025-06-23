//+------------------------------------------------------------------+
//|                                           New_Fractals_Lines.mq4 |
//|                                      Copyright © -2007, olyakish |
//|                                           plutonia-dmb#yandex.ru |
//+------------------------------------------------------------------+
#property copyright "olyakish"
#property link "plutonia-dmb#yandex.ru"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green // Приседающий
#property indicator_color2 Red   // Приседающий
//----
extern int			Pips		= 5;
double ExtGreenBuffer[];
double ExtRedBuffer[];
double AllHLDown, AllVolDown, AllHLUp, AllVolUp, AllMFIDown, AllMFIUp;
int OldFractal = 2;
bool Up = false, Down = false;
bool objects_initialized=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexShift(0, 0);
   SetIndexShift(1, 0);
//----
   SetIndexBuffer(0, ExtGreenBuffer);
   SetIndexBuffer(1, ExtRedBuffer);
//----
   SetIndexStyle(0, DRAW_ARROW, 0, 1);
   SetIndexStyle(1, DRAW_ARROW, 0, 1);
//----
   SetIndexArrow(0, 177);
   SetIndexArrow(1, 177);
            
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ObjectsInit()
  {
//---- check if we have enough bars
   if(ArraySize(High)<3)
     {
      Print("Timeseries is not ready yet - exit");
      return(false);
     }
//---
   ObjectCreate("Up", OBJ_TREND, 0, iTime(NULL, 0, 2), High[2], 
                iTime(NULL, 0, 1), High[1],0,0);
   ObjectSet("Up", OBJPROP_COLOR, Blue);
   ObjectSet("Up", OBJPROP_RAY, true);
//----   
   ObjectCreate("Down", OBJ_TREND, 0, iTime(NULL, 0, 2), Low[2], 
                iTime(NULL, 0, 1), Low[1],0,0);
   ObjectSet("Down", OBJPROP_COLOR, Brown);
   ObjectSet("Down", OBJPROP_RAY, true);
//----
   return(true);
  }   
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("Up");
   ObjectDelete("Down");
   return(0);
  }        
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {  
   if(!objects_initialized)
     {
      objects_initialized=ObjectsInit();
     }  
   ArrayInitialize(ExtGreenBuffer, NULL);
   ArrayInitialize(ExtRedBuffer, NULL);
   for(int i = 100; i >= 3; i--)
     {
       // нас интересует только ситуация когда на баре один фрактал 
       // (в любую сторону)
       // если два фрактала на одном баре то отсеиваем такие ситуации
       if(iFractals(NULL, 0, MODE_UPPER, i) != 0)
         {
           Up = true;
           Down = false;   
         }
       if(iFractals(NULL, 0, MODE_LOWER, i) != 0)
         {
           Up = false;
           Down = true;
         }
       // два фрактала сразу - игнорируем
       if(iFractals(NULL, 0, MODE_UPPER, i) != 0 &&
          iFractals(NULL, 0, MODE_LOWER,i) != 0) 
         {
           Up = false;   
           Down = false;    
         }
       // на текущем баре есть фрактал вниз 
       if(Up == false && Down ==true)   
         {
           AllHLDown = 0;
           AllVolDown = 0;
           AllHLDown = High[i+2] - Low[i+2] + High[i+1] - Low[i+1] + 
                       High[i] - Low[i] + High[i-1] - Low[i-1] + 
                       High[i-2] - Low[i-2];
           AllVolDown = Volume[i+2] + Volume[i+1] + Volume[i] + 
                        Volume[i-1] + Volume[i-2];
           AllMFIDown = AllHLDown / AllVolDown;
           // предыдущий фрактал был вверх - сравниваем два фрактала 
           // (вверх и текущий вниз)
           if(OldFractal ==1 ) 
             {
               // имеем приседающий фрактал (MFI - объем +)
               if(AllMFIDown < AllMFIUp && AllVolDown > AllVolUp) 
                 {
                   // заполняем буферы
                   ExtGreenBuffer[i] = NULL;
                   ExtRedBuffer[i] = Low[i]; // - Pips*Point;

                 }
             }
           OldFractal = 0;
         }
       // на текущем баре есть фрактал вверх 
       if(Up == true && Down == false)  
         {
           AllHLUp = 0;
           AllVolUp = 0;
           AllHLUp = High[i+2] - Low[i+2] + High[i+1] - Low[i+1] + 
                     High[i] - Low[i] + High[i-1] - Low[i-1] + 
                     High[i-2] - Low[i-2];
           AllVolUp = Volume[i+2] + Volume[i+1] + Volume[i] + 
                      Volume[i-1] + Volume[i-2];
           AllMFIUp = AllHLUp / AllVolUp;
           // предыдущий фрактал был вниз - сравниваем два фрактала 
           // (вверх и текущий вниз)
           if(OldFractal == 0) 
             {
               // имеем приседающий фрактал (MFI - объем +)
               if(AllMFIUp < AllMFIDown && AllVolUp > AllVolDown) 
                 {
                   // заполняем буферы
                   ExtGreenBuffer[i] = High[i]; // + Pips*Point;
                   ExtRedBuffer[i] = NULL;

                 }
             }
           OldFractal=1;
         }    
     } 
   double _Price[2,2];
   int  _Time[2,2];
   ArrayInitialize(_Price, -1);
   ArrayInitialize(_Time, -1);
//----
   for(i = 3; i <= 100; i++)
     {
       //up
       if(ExtGreenBuffer[i] != NULL && _Price[0,0] != -1 && _Price[1,0] == -1)
         {
           _Price[1,0] = ExtGreenBuffer[i];
           _Time[1,0] = iTime(NULL, 0, i);         
         }
       if(ExtGreenBuffer[i] != NULL && _Price[0,0] == -1)
         {
           _Price[0,0] = ExtGreenBuffer[i];
           _Time[0,0] = iTime(NULL, 0, i);
         }
       // down 
       if(ExtRedBuffer[i] != NULL && _Price[0,1] != -1 && _Price[1,1] == -1)
         {
           _Price[1,1]=ExtRedBuffer[i];_Time[1,1]=iTime(NULL, 0, i);         
         } 
       if (ExtRedBuffer[i]!=NULL && _Price[0,1]==-1)
          {
          _Price[0,1]=ExtRedBuffer[i];_Time[0,1]=iTime(NULL, 0, i);
           }        
     }
   ObjectMove("Up", 1, _Time[0,0], _Price[0,0]);
   ObjectMove("Up", 0, _Time[1,0], _Price[1,0]);
   ObjectMove("Down", 1, _Time[0,1], _Price[0,1]);
   ObjectMove("Down", 0, _Time[1,1], _Price[1,1]);
   return(0);
  }
//+------------------------------------------------------------------+



