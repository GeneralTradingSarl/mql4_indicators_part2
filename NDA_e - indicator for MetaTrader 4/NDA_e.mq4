//+------------------------------------------------------------------+
//|                                                          NDA.mq4 |
//|                                   Copyright © 2009, Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Yuriy Tokman"
#property link      "yuriytokman@gmail.com"// write to order

#property indicator_chart_window

string name1[]={"frequency 16K","frequency 14K","frequency 12K","frequency 6K","frequency 3K",
               "frequency 1K","frequency 600","frequency 310","frequency 170","frequency 60"};
string name2[]={"-20db","-16db","-12db","-8db","-4db","+0db","+4db","+8db","+12db","+16db","+20db"};
string name3[]={"W","r","i","t","e"," t","o"," o","r","d","e","r:"," y","u","r","i","y","t","o","k",
                "m","a","n","@ "," g","m","a","i","l.","c","o","m"," ",".",".",".",".",".",".",".","$"};
// write to order
int count = 0;
int old_tick = 0;               
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//----
  old_tick = Bid/Point;
//----
  MathSrand(TimeLocal());  
//----  
  for(int x=0;x<10;x++)SetText("NDA_txt1"+x,name1[x],1,(x+3)*20,520,9,"Tahoma", Gold,45);
  for(x=0;x<10;x++)SetText("NDA_Zero"+x,CharToStr(59),1,(x+2)*21,500,18, "Wingdings", Yellow);  
  for(x=0;x<11;x++)SetText("NDA_txt2"+x,name2[x],1,15,510-x*14,7,"Arial", Yellow);
  SetText("NDA_Centr",CharToStr(91),1,131,330,28,"Wingdings",Aqua);  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   string vName;
   for(int i=ObjectsTotal()-1; i>=0;i--)
    {
     vName = ObjectName(i);
     if (StringFind(vName,"NDA_") !=-1) ObjectDelete(vName);
    }   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int x;
   string vName2;
   for(int i=ObjectsTotal()-1; i>=0;i--)
    {
     vName2 = ObjectName(i);
     if (StringFind(vName2,"NDA_pole_") !=-1) ObjectDelete(vName2);
    }     
//----
   int new_tick = Bid/Point;
   int delta = MathAbs(new_tick-old_tick);
   if(delta==0)PlaySound("ok.wav");if(delta==1)PlaySound("tick.wav");
   if(delta==2)PlaySound("alert2.wav");if(delta==3)PlaySound("alert.wav");
   if(delta>3)PlaySound("timeout.wav");
   old_tick = Bid/Point;   
//----
  ObjectSet("NDA_Centr",OBJPROP_COLOR,GetColor(delta));
  for(x=0;x<delta;x++)SetText("NDA_pole_R"+x,CharToStr(59),1,105-x*21,333,18, "Wingdings",GetColor2(delta));  
  for(x=0;x<delta;x++)SetText("NDA_pole_L"+x,CharToStr(59),1,168+x*21,333,18, "Wingdings",GetColor2(delta));    
//----
   count++;
   color col = Gold;
   if (count>41){count=0;for(x=0;x<41;x++)ObjectDelete("NDA_txt3"+x);}
   if(count>20)col=Yellow;if(count>30)col=Lime;   
   for(x=0;x<count;x++)SetText("NDA_txt3"+x,name3[x],2,(x+1)*15,10,12,"Arial Black",col);       
//----
   int value1  = GetRand(0,10);int value2  = GetRand(0,10);int value3  = GetRand(0,10);
   int value4  = GetRand(0,10);int value5  = GetRand(0,10);int value6  = GetRand(0,10);   
   int value7  = GetRand(0,10);int value8  = GetRand(0,10);int value9  = GetRand(0,10);
   int value10 = GetRand(0,10);     
//---- +21
   for(x=0;x<value1;x++)SetText("NDA_pole_1"+x,CharToStr(59),1,42,485-x*14,18, "Wingdings", GetColor(value1));
   for(x=0;x<value2;x++)SetText("NDA_pole_2"+x,CharToStr(59),1,63,485-x*14,18, "Wingdings", GetColor(value2));
   for(x=0;x<value3;x++)SetText("NDA_pole_3"+x,CharToStr(59),1,84,485-x*14,18, "Wingdings", GetColor(value3));
   for(x=0;x<value4;x++)SetText("NDA_pole_4"+x,CharToStr(59),1,105,485-x*14,18, "Wingdings", GetColor(value4));
   for(x=0;x<value5;x++)SetText("NDA_pole_5"+x,CharToStr(59),1,126,485-x*14,18, "Wingdings", GetColor(value5));
   for(x=0;x<value6;x++)SetText("NDA_pole_6"+x,CharToStr(59),1,147,485-x*14,18, "Wingdings", GetColor(value6));
   for(x=0;x<value7;x++)SetText("NDA_pole_7"+x,CharToStr(59),1,168,485-x*14,18, "Wingdings", GetColor(value7));
   for(x=0;x<value8;x++)SetText("NDA_pole_8"+x,CharToStr(59),1,189,485-x*14,18, "Wingdings", GetColor(value8));
   for(x=0;x<value9;x++)SetText("NDA_pole_9"+x,CharToStr(59),1,210,485-x*14,18, "Wingdings", GetColor(value9));
   for(x=0;x<value10;x++)SetText("NDA_pole_10"+x,CharToStr(59),1,231,485-x*14,18, "Wingdings", GetColor(value10));
//----
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void SetText(string name,string text,int CORNER,int XDISTANCE,int YDISTANCE, 
             int font_size, string font_name, color text_color=CLR_NONE, double ANGLE = 0)
 {
  if (ObjectFind(name)!=-1) ObjectDelete(name);
  ObjectCreate(name,OBJ_LABEL,0,0,0,0,0);         
  ObjectSet(name,OBJPROP_CORNER,CORNER);
  ObjectSet(name,OBJPROP_XDISTANCE,XDISTANCE);
  ObjectSet(name,OBJPROP_YDISTANCE,YDISTANCE);
  ObjectSet(name, OBJPROP_ANGLE , ANGLE);
  ObjectSetText(name,text,font_size,font_name,text_color);
 }

//+----------------------------------------------------------------------------+
int GetRand(int vFrom, int vTo)
{
 int vV;
 while (true)
  {
   vV = MathRand();
   if (vV>=vFrom && vV<=vTo) break;
   
  }
 return(vV); 
}
//+----------------------------------------------------------------------------+
//|  Описание : Возвращает цвет по номеру                                      |
//+----------------------------------------------------------------------------+
//|  Параметры:                                                                |
//|    nambe - число от 0 до 10                                                |
//+----------------------------------------------------------------------------+
color GetColor(int nambe=0) 
 {
  switch (nambe)
  {
    case 0:  return(Crimson);
    case 1:  return(Aqua);
    case 2:  return(Red);
    case 3:  return(OrangeRed);
    case 4:  return(Tomato);
    case 5:  return(Salmon);
    case 6:  return(LightGreen);
    case 7:  return(GreenYellow);
    case 8:  return(LawnGreen);
    case 9:  return(LimeGreen);    
    case 10: return(Green);    
    default: return(Khaki);
  }
}
//+----------------------------------------------------------------------------+
//|  Описание : Возвращает цвет по номеру                                      |
//+----------------------------------------------------------------------------+
//|  Параметры:                                                                |
//|    nambe - число от 0 до 10                                                |
//+----------------------------------------------------------------------------+
color GetColor2(int nambe=0) 
 {switch (nambe)
  {
   case 1:  return(GreenYellow);
   case 2:  return(Lime);
   case 3:  return(OrangeRed);
   case 4:  return(DeepPink);    
   default: return(DeepPink);
  }
}