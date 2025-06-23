//+------------------------------------------------------------------+
//|                                               Happy New Year.mq4 |
//|                                                     YURIY TOKMAN |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "YURIY TOKMAN"
#property link      "yuriytokman@gmail.com"

#property indicator_chart_window

int y = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   GetAvtor();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   GetDellName();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {   
   y = y+1;
//----
   Label("ytg_stroka_0","Happy New Year",4,200,100,60,"Comic Sans MS",Blue);
   Label("ytg_stroka_1","2010",4,400,300,60,"Comic Sans MS",Blue);
   Label("ytg_stroka_2","a",4,280,320,60,"Wingdings 2",Blue);
   Label("ytg_stroka_3","b",4,630,320,60,"Wingdings 2",Blue);      

   int x = 0, z = 0;
   if(y>5)y=0;

   if(y==1){x=5;z=-5;}
   if(y==2){x=10;z=-10;}   
   if(y==3){x=-5;z=5;}
   if(y==4){x=-10;z=10;}   
   if(y==5){x=15;z=-15;}      
   
   Label("ytg_stroka_4","г",4,50+x,320+z,60,"Wingdings 2",Aqua);
   Label("ytg_stroka_5","г",4,250+z,220+x,60,"Wingdings 2",Aqua);   
   Label("ytg_stroka_6","г",4,450+x,30+z,60,"Wingdings 2",Aqua);   
   Label("ytg_stroka_7","г",4,600+z,220+x,60,"Wingdings 2",Aqua);         
   Label("ytg_stroka_8","г",4,850+x,320+z,60,"Wingdings 2",Aqua);
   
   Label("ytg_stroka_9","г",4,50+z,30+x,60,"Wingdings 2",Aqua);   
   Label("ytg_stroka_10","г",4,700+x,480+z,60,"Wingdings 2",Aqua);         
   Label("ytg_stroka_11","г",4,210+z,480+x,60,"Wingdings 2",Aqua);   
   Label("ytg_stroka_12","г",4,800+x,30+z,60,"Wingdings 2",Aqua);      
//----
   return(0);
  }
//+------------------------------------------------------------------+
//+----------------------------------------------------------------------+
//| Описание: Создание текстовой метки                                   | 
//| Автор:    Юрий Токмань                                               |
//| e-mail:   yuriytokman@gmail.com                                      |
//+----------------------------------------------------------------------+
 void Label(string name_label,           //Имя объекта.
            string text_label,           //Текст обьекта. 
            int corner = 2,              //Hомер угла привязки 
            int x = 3,                   //Pасстояние X-координаты в пикселях 
            int y = 15,                   //Pасстояние Y-координаты в пикселях 
            int font_size = 10,          //Размер шрифта в пунктах.
            string font_name = "Arial",  //Наименование шрифта.
            color text_color = LimeGreen //Цвет текста.
           )
  {
   if (ObjectFind(name_label)!=-1) ObjectDelete(name_label);
       ObjectCreate(name_label,OBJ_LABEL,0,0,0,0,0);         
       ObjectSet(name_label,OBJPROP_CORNER,corner);
       ObjectSet(name_label,OBJPROP_XDISTANCE,x);
       ObjectSet(name_label,OBJPROP_YDISTANCE,y);
       ObjectSetText(name_label,text_label,font_size,font_name,text_color);
  }
//-----+
 void GetDellName (string name_n = "ytg_")
  {
   string vName;
   for(int i=ObjectsTotal()-1; i>=0;i--)
    {
     vName = ObjectName(i);
     if (StringFind(vName,name_n) !=-1) ObjectDelete(vName);
    }  
  }
//-----
void GetAvtor()
 {
  string char[256]; int i;
  for (i = 0; i < 256; i++) char[i] = CharToStr(i);   
  string txtt = char[70]+char[97]+char[99]+char[116]+char[111]+char[114]+char[121]+char[32]
  +char[111]+char[102]+char[32]+char[116]+char[104]+char[101]+char[32]+char[97]
  +char[100]+char[118]+char[105]+char[115]+char[101]+char[114]+char[115]+char[58]
  +char[32]+char[121]+char[117]+char[114]+char[105]+char[121]+char[116]+char[111]
  +char[107]+char[109]+char[97]+char[110]+char[64]+char[103]+char[109]+char[97]
  +char[105]+char[108]+char[46]+char[99]+char[111]+char[109];Label("label",txtt,2,3,15);  
 }11]+char1[109];Label("label",txtt,2,3,15);  
 }