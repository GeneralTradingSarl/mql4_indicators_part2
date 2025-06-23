//+------------------------------------------------------------------+
//|                                               Madeleine_v2.0.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property indicator_chart_window
//----
string str="Madeleine_v2.0";
extern string _Bars="Количество баров для отрисовки";
extern int cfg_Bars=18; //количество баров для отрисовки
extern string Ray="Отрисовка лучей";
extern bool cfg_Ray=false; //отрисовка лучей
extern string HL1="High (315), Low (45)";
extern bool cfg_HL1=true; //отрисовка только по High (315), Low (45)
extern string OC1="Open (315), Close (45)";
extern bool cfg_OC1=false; //отрисовка только по Open (315), Close (45)
extern string HL2="High (45), Low (315)";
extern bool cfg_HL2=false; //отрисовка только по High (45), Low (315)
extern string OC2="Open (45), Close (315)";
extern bool cfg_OC2=false; //отрисовка только по Open (45), Close (315)
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   DrawLine45();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   //авто-удаление всех линий
     for(int i=1;i<Bars;i++){
      string ss=TimeToStr(Time[i]);
        for(int j=0;j<StringLen(ss);j++){
         if(StringGetChar(ss,j)=='.' || StringGetChar(ss,j)==':' || StringGetChar(ss,j)==' ')
            ss=StringSetChar(ss,j,'_');
        }
      string n45L="trend45L_"+ss;
      string n45H="trend45H_"+ss;
      string n315L="trend315L_"+ss;
      string n315H="trend315H_"+ss;
      string n45O="trend45O_"+ss;
      string n45C="trend45C_"+ss;
      string n315O="trend315O_"+ss;
      string n315C="trend315C_"+ss;
      if(ObjectFind(n45L)==0) ObjectDelete(n45L);
      if(ObjectFind(n315L)==0) ObjectDelete(n315L);
      if(ObjectFind(n45H)==0) ObjectDelete(n45H);
      if(ObjectFind(n315H)==0) ObjectDelete(n315H);
      if(ObjectFind(n45O)==0) ObjectDelete(n45O);
      if(ObjectFind(n315O)==0) ObjectDelete(n315O);
      if(ObjectFind(n45C)==0) ObjectDelete(n45C);
      if(ObjectFind(n315C)==0) ObjectDelete(n315C);
     }
   // Print("Deinit");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   DrawLine45();
//----
   return(0);
  }
//+------------------------------------------------------------------+
  void DrawLine45()
  {
     for(int i=1;i<=cfg_Bars;i++)
     {
      string ss=TimeToStr(Time[i]);
        for(int j=0;j<StringLen(ss);j++)
        {
         if(StringGetChar(ss,j)=='.' || StringGetChar(ss,j)==':' || StringGetChar(ss,j)==' ')
            ss=StringSetChar(ss,j,'_');
        }
      string n45L="trend45L_"+ss;
      string n45H="trend45H_"+ss;
      string n315L="trend315L_"+ss;
      string n315H="trend315H_"+ss;
//----
      string n45O="trend45O_"+ss;
      string n45C="trend45C_"+ss;
      string n315O="trend315O_"+ss;
      string n315C="trend315C_"+ss;
      // Print(n45);
      // Print(n315);
      //High 45 - Low 315
        if(ObjectFind(n315L)==-1)
        {
         if (cfg_HL2)
            ObjectCreate(n315L,OBJ_TRENDBYANGLE,0,Time[i],Low[i]);
         ObjectSet (n315L,OBJPROP_RAY,cfg_Ray);
         ObjectSet (n315L,OBJPROP_ANGLE,315);
         ObjectSet (n315L,OBJPROP_TIME2,Time[0]);
         ObjectSet (n315L,OBJPROP_COLOR,Blue);
        }
        if(ObjectFind(n45H)==-1)
        {
         if (cfg_HL2)
            ObjectCreate(n45H,OBJ_TRENDBYANGLE,0,Time[i],High[i]);
         ObjectSet (n45H,OBJPROP_RAY,cfg_Ray);
         ObjectSet (n45H,OBJPROP_ANGLE,45);
         ObjectSet (n45H,OBJPROP_TIME2,Time[0]);
         ObjectSet (n45H,OBJPROP_COLOR,Lime);
        }
      //Open-Close 
        if(ObjectFind(n45O)==-1)
        {
         if (cfg_OC2)
            if (iOpen(NULL,0,i)>iClose(NULL,0,i))
               ObjectCreate(n45O,OBJ_TRENDBYANGLE,0,Time[i],Open[i]);
         ObjectSet (n45O,OBJPROP_RAY,cfg_Ray);
         ObjectSet (n45O,OBJPROP_ANGLE,45);
         ObjectSet (n45O,OBJPROP_TIME2,Time[0]);
         ObjectSet (n45O,OBJPROP_COLOR,White);
        }
        if(ObjectFind(n315O)==-1)
        {
         if (cfg_OC2)
            if (iOpen(NULL,0,i)<iClose(NULL,0,i))
               ObjectCreate(n315O,OBJ_TRENDBYANGLE,0,Time[i],Open[i]);
         ObjectSet (n315O,OBJPROP_RAY,cfg_Ray);
         ObjectSet (n315O,OBJPROP_ANGLE,315);
         ObjectSet (n315O,OBJPROP_TIME2,Time[0]);
         ObjectSet (n315O,OBJPROP_COLOR,White);
        }
        if(ObjectFind(n45C)==-1)
        {
         if (cfg_OC2)
            if (iClose(NULL,0,i)>iOpen(NULL,0,i))
               ObjectCreate(n45C,OBJ_TRENDBYANGLE,0,Time[i],Close[i]);
         ObjectSet (n45C,OBJPROP_RAY,cfg_Ray);
         ObjectSet (n45C,OBJPROP_ANGLE,45);
         ObjectSet (n45C,OBJPROP_TIME2,Time[0]);
         ObjectSet (n45C,OBJPROP_COLOR,Red);
        }
        if(ObjectFind(n315C)==-1)
        {
         if (cfg_OC2)
            if (iClose(NULL,0,i)<iOpen(NULL,0,i))
               ObjectCreate(n315C,OBJ_TRENDBYANGLE,0,Time[i],Close[i]);
         ObjectSet (n315C,OBJPROP_RAY,cfg_Ray);
         ObjectSet (n315C,OBJPROP_ANGLE,315);
         ObjectSet (n315C,OBJPROP_TIME2,Time[0]);
         ObjectSet (n315C,OBJPROP_COLOR,Red);
        }
      //High 315 - Low 45
        if(ObjectFind(n45L)==-1)
        {
         if (cfg_HL1)
            ObjectCreate(n45L,OBJ_TRENDBYANGLE,0,Time[i],Low[i]);
         ObjectSet (n45L,OBJPROP_RAY,cfg_Ray);
         ObjectSet (n45L,OBJPROP_ANGLE,45);
         ObjectSet (n45L,OBJPROP_TIME2,Time[0]);
         ObjectSet (n45L,OBJPROP_COLOR,Blue);
        }
        if(ObjectFind(n315H)==-1)
        {
         if (cfg_HL1)
            ObjectCreate(n315H,OBJ_TRENDBYANGLE,0,Time[i],High[i]);
         ObjectSet (n315H,OBJPROP_RAY,cfg_Ray);
         ObjectSet (n315H,OBJPROP_ANGLE,315);
         ObjectSet (n315H,OBJPROP_TIME2,Time[0]);
         ObjectSet (n315H,OBJPROP_COLOR,Lime);
        }
      //Open 315 or 45 - Close 315 or 45 (if Close>Open or Close<Open)
        if(ObjectFind(n45O)==-1)
        {
         if (cfg_OC1)
            if (iOpen(NULL,0,i)<iClose(NULL,0,i))
               ObjectCreate(n45O,OBJ_TRENDBYANGLE,0,Time[i],Open[i]);
         ObjectSet (n45O,OBJPROP_RAY,cfg_Ray);
         ObjectSet (n45O,OBJPROP_ANGLE,45);
         ObjectSet (n45O,OBJPROP_TIME2,Time[0]);
         ObjectSet (n45O,OBJPROP_COLOR,White);
        }
        if(ObjectFind(n315O)==-1)
        {
         if (cfg_OC1)
            if (iOpen(NULL,0,i)>iClose(NULL,0,i))
               ObjectCreate(n315O,OBJ_TRENDBYANGLE,0,Time[i],Open[i]);
         ObjectSet (n315O,OBJPROP_RAY,cfg_Ray);
         ObjectSet (n315O,OBJPROP_ANGLE,315);
         ObjectSet (n315O,OBJPROP_TIME2,Time[0]);
         ObjectSet (n315O,OBJPROP_COLOR,White);
        }
        if(ObjectFind(n45C)==-1)
        {
         if (cfg_OC1)
            if (iClose(NULL,0,i)<iOpen(NULL,0,i))
               ObjectCreate(n45C,OBJ_TRENDBYANGLE,0,Time[i],Close[i]);
         ObjectSet (n45C,OBJPROP_RAY,cfg_Ray);
         ObjectSet (n45C,OBJPROP_ANGLE,45);
         ObjectSet (n45C,OBJPROP_TIME2,Time[0]);
         ObjectSet (n45C,OBJPROP_COLOR,Red);
        }
        if(ObjectFind(n315C)==-1)
        {
         if (cfg_OC1)
            if (iClose(NULL,0,i)>iOpen(NULL,0,i))
               ObjectCreate(n315C,OBJ_TRENDBYANGLE,0,Time[i],Close[i]);
         ObjectSet (n315C,OBJPROP_RAY,cfg_Ray);
         ObjectSet (n315C,OBJPROP_ANGLE,315);
         ObjectSet (n315C,OBJPROP_TIME2,Time[0]);
         ObjectSet (n315C,OBJPROP_COLOR,Red);
        }
     }
  }
//+------------------------------------------------------------------+