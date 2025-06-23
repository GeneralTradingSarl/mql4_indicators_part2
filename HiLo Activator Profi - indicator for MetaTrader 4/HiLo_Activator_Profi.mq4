//+------------------------------------------------------------------+
//|                                         HiLo_Activator_Profi.mq4 |
//|                                                Copyright © 2005, |
//|                                               rvm_fam@fromru.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005"
#property link      "rvm_fam@fromru.com"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DeepSkyBlue
#property indicator_color2 Black
//---- input parameters
extern int       Range=3;
//---- buffers
double Up[];
double Dn[];
double ur1[];
double ur2[];
double h1[];
double l1[];
//-----
int cb;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(6);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexArrow(1,159);
   SetIndexBuffer(0,Up);
   SetIndexBuffer(1,Dn);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexLabel(0,"HL_Act_Up");
   SetIndexLabel(1,"HL_Act_Dn");
   SetIndexBuffer(2,ur1);
   SetIndexBuffer(3,ur2);
   SetIndexBuffer(4,h1);
   SetIndexBuffer(5,l1);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//------ объявление локальных переменных
   int counted_bars=IndicatorCounted();
   int NumBars=1000, n=0, Nbar=0, k=0, hh=0, ll=0, mm=0;
   double MaH=0.0, MaL=0.0;
//-----
   if(Bars<Range*12-10) return(0);
   if(counted_bars>=Bars-1)
     {
      NumBars=0;
     }
   else
     {
      NumBars=MathMax(Bars-1-counted_bars-(Range*12-10),Range*12-10);
     }
   //
   for( cb=NumBars; cb>=0; cb--)
     {
      Nbar=-1;
      k=1;
      mm=0;
      Dn[cb]=0.0;
      Up[cb]=0.0;
      ur1[cb]=0.0;
      ur2[cb]=0.0;
      h1[cb]=0.0;
      l1[cb]=0.0;
      //-----------------------------------------------------------------------------
      if(Period()==5)//если график - М5
        {
         //Print("Текущая свечка "+cb+" дата "+TimeToStr(Time[cb]) );
         //Print("----   Dn[cb]= "+Dn[cb]+" Up[cb]= "+Up[cb] );
         if(TimeHour(Time[cb+1])!=TimeHour(Time[cb]) )
           {
            //Print("----   Nbar= "+Nbar+" k= "+k+" mm= "+mm );
            n=cb-15;
            //Print("----   n= "+n );
            while( n<=cb+Range*12+5 )
              {
               if(n<0 )
                 {
                  Nbar=0;
                  n=1;
                  //Print("----   n= "+n+" Nbar= "+Nbar );
                 }
               if(TimeHour(Time[n+1])!=TimeHour(Time[n]) )
                 {
                  if(Nbar==-1 )
                    {
                     Nbar=n;
                     mm=n;
                     n++;
                     //Print("----   n= "+n+" Nbar= "+Nbar+" mm= "+mm );
                     continue;
                    }
                  else
                    {
                     h1[k]=High[Highest(NULL,0,MODE_HIGH,(n-Nbar),n)];
                     l1[k]=Low[Lowest(NULL,0,MODE_LOW,(n-Nbar),n)];
                     //Print("----   k= "+k+" Nbar= "+Nbar+" n= "+n+" h1["+k+"]= "+h1[k]+" l1["+k+"]= "+l1[k]+" "+(Low[Lowest(NULL,0,MODE_LOW,(n-Nbar),n)])+" "+(High[Lowest(NULL,0,MODE_HIGH,(n-Nbar),n)]) );
                     k++;
                     Nbar=n;
                    }
                 }
               n++;
              }
            MaH=0;
            MaL=0;
            for( n=1;n<=Range;n++)
              {
               MaH=MaH+h1[n];
               MaL=MaL+l1[n];
              }
            MaH=MaH/Range;
            MaL=MaL/Range;
            ur1[cb]=MaH;
            ur2[cb]=MaL;
            //Print("----   MaH= "+MaH+" MaL= "+MaL+" ur1["+cb+"]= "+ur1[cb]+" ur2["+cb+"]= "+ur2[cb] );
            if(Close[mm+1]>=MaH )
              {
               ll=1;
               hh=0;
               //Print("----   Close["+(mm+1)+"]"+Close[mm+1]+">="+"MaH"+MaH+"  ="+(Close[mm+1]>=MaH) );
              }
            if(Close[mm+1]<=MaL )
              {
               hh=1;
               ll=0;
               //Print("----   Close["+(mm+1)+"]"+Close[mm+1]+"<="+"MaL"+MaL+"  ="+(Close[mm+1]<=MaL) );
              }
            //Print("----   ll= "+ll+" hh= "+hh );
           }
         if(ur1[cb]==0.0 )
           {
            ur1[cb]=ur1[cb+1];
            ur2[cb]=ur2[cb+1];
            //Print("----  ur1["+cb+"]= "+ur1[cb]+" ur2["+cb+"]= "+ur2[cb] );
           }
         if(ll==1 )
           {
            Up[cb]=ur2[cb];
            //Print("----  Dn["+cb+"]= "+Dn[cb]+" Up["+cb+"]= "+Up[cb] );
            //Print("----  1 Up["+cb+"]= "+Up[cb]+" ur2[cb]="+ur2[cb] );
           }
         else
           {
            if(hh==1 )
              {
               Dn[cb]=ur1[cb];
               //Print("----  Dn["+cb+"]= "+Dn[cb]+" Up["+cb+"]= "+Up[cb] );
               //Print("----                                        2 Up["+cb+"]= "+Up[cb] );
              }
            else
              {
               Dn[cb]=Dn[cb+1];
               Up[cb]=Up[cb+1];
              }
           }
        }
        else {
         //-----------------------------------------------------------------------------
         if(Period()==15)//если график - М15
           {
            if(TimeHour(Time[cb+1])!=TimeHour(Time[cb]))//если наступил новый час
              {
               n=cb-5;
               while( n<=cb+Range*4+2 )
                 {
                  if(n<0 )
                    {
                     Nbar=0;
                     n=1;
                    }
                  if(TimeHour(Time[n+1])!=TimeHour(Time[n]))//если время м15 не совпадает с н1
                    {
                     if(Nbar==-1)//если рассчитывается первая итерация
                       {
                        Nbar=n;
                        mm=n;
                        n++;
                        continue;
                       }
                     else
                       {
                        h1[k]=High[Highest(NULL,0,MODE_HIGH,(n-Nbar),n)];
                        l1[k]=Low[Lowest(NULL,0,MODE_LOW,(n-Nbar),n)];
                        k++;
                        Nbar=n;
                       }
                    }
                  n++;
                 }
               MaH=0;
               MaL=0;
               for( n=1;n<=Range;n++ )
                 {
                  MaH=MaH+h1[n];
                  MaL=MaL+l1[n];
                 }
               MaH=MaH/Range;
               MaL=MaL/Range;
               ur1[cb]=MaH;
               ur2[cb]=MaL;
               if(Close[mm+1]>=MaH )
                 {
                  ll=1;
                  hh=0;
                 }
               if(Close[mm+1]<=MaL )
                 {
                  hh=1;
                  ll=0;
                 }
              }
            if(ur1[cb]==0.0 )
              {
               ur1[cb]=ur1[cb+1];
               ur2[cb]=ur2[cb+1];
              }
            if(ll==1 )
              {
               Up[cb]=ur2[cb];
              }
            else
              {
               if(hh==1 )
                 {
                  Dn[cb]=ur1[cb];
                 }
              }
           }
           else {
            //-----------------------------------------------------------------------------
            if(Period()==30)//если график - М30
              {
               if((TimeMinute(Time[cb])==0 && (TimeHour(Time[cb])==0 || TimeHour(Time[cb])==4 || TimeHour(Time[cb])==8 ||
                    TimeHour(Time[cb])==12 || TimeHour(Time[cb])==16 || TimeHour(Time[cb])==20)) )
                 {
                  n=cb-10;
                  while( n<=cb+Range*8+5 )
                    {
                     if(n<0 )
                       {
                        Nbar=0;
                        n=1;
                       }
                     if((TimeMinute(Time[n])==0 && (TimeHour(Time[n])==0 || TimeHour(Time[n])==4 || TimeHour(Time[n])==8 |
                          TimeHour(Time[n])==12 || TimeHour(Time[n])==16 || TimeHour(Time[n])==20)) )
                       {
                        if(Nbar==-1 )
                          {
                           Nbar=n;
                           mm=n;
                           n++;
                           continue;
                          }
                        else
                          {
                           h1[k]=High[Highest(NULL,0,MODE_HIGH,(n-Nbar),n)];
                           l1[k]=Low[Lowest(NULL,0,MODE_LOW,(n-Nbar),n)];
                           k++;
                           Nbar=n;
                          }
                       }
                     n++;
                    }
                  MaH=0;
                  MaL=0;
                  for( n=1;n<=Range;n++ )
                    {
                     MaH=MaH+h1[n];
                     MaL=MaL+l1[n];
                    }
                  MaH=MaH/Range;
                  MaL=MaL/Range;
                  ur1[cb]=MaH;
                  ur2[cb]=MaL;
                  if(Close[mm+1]>=MaH )
                    {
                     ll=1;
                     hh=0;
                    }
                  if(Close[mm+1]<=MaL )
                    {
                     hh=1;
                     ll=0;
                    }
                 }
               if(ur1[cb]==0 )
                 {
                  ur1[cb]=ur1[cb+1];
                  ur2[cb]=ur2[cb+1];
                 }
               if(ll==1 )
                 {
                  Up[cb]=ur2[cb];
                 }
               else
                 {
                  if(hh==1 )
                    {
                     Dn[cb]=ur1[cb];
                    }
                 }
              }
              else 
              {
               //-----------------------------------------------------------------------------
               if(Period()==60)//если график - H1
                 {
                  if((TimeMinute(Time[cb])==0 && (TimeHour(Time[cb])==0 || TimeHour(Time[cb])==4 || TimeHour(Time[cb])==8 ||
                       TimeHour(Time[cb])==12 || TimeHour(Time[cb])==16 || TimeHour(Time[cb])==20)) )
                    {
                     n=cb-6;
                     while( n<=cb+Range*4+3 )
                       {
                        if(n<0 )
                          {
                           Nbar=0;
                           n=1;
                          }
                        if((TimeMinute(Time[n])==0 && (TimeHour(Time[n])==0 || TimeHour(Time[n])==4 || TimeHour(Time[n])==8 |
                             TimeHour(Time[n])==12 || TimeHour(Time[n])==16 || TimeHour(Time[n])==20)))
                          {
                           if(Nbar==-1 )
                             {
                              Nbar=n;
                              mm=n;
                              n++;
                              continue;
                             }
                           else
                             {
                              h1[k]=High[Highest(NULL,0,MODE_HIGH,(n-Nbar),n)];
                              l1[k]=Low[Lowest(NULL,0,MODE_LOW,(n-Nbar),n)];
                              k++;
                              Nbar=n;
                             }
                          }
                        n++;
                       }
                     MaH=0;
                     MaL=0;
                     for( n=1;n<=Range;n++ )
                       {
                        MaH=MaH+h1[n];
                        MaL=MaL+l1[n];
                       }
                     MaH=MaH/Range;
                     MaL=MaL/Range;
                     ur1[cb]=MaH;
                     ur2[cb]=MaL;
                     if(Close[mm+1]>=MaH )
                       {
                        ll=1;
                        hh=0;
                       }
                     if(Close[mm+1]<=MaL )
                       {
                        hh=1;
                        ll=0;
                       }
                    }
                  if(ur1[cb]==0 )
                    {
                     ur1[cb]=ur1[cb+1];
                     ur2[cb]=ur2[cb+1];
                    }
                  if(ll==1 )
                    {
                     Up[cb]=ur2[cb];
                    }
                  else
                    {
                     if(hh==1 )
                       {
                        Dn[cb]=ur1[cb];
                       }
                    }
                 }
                 else 
                 {
                  //-----------------------------------------------------------------------------
                  if(Period()==240)//если график - H4
                    {
                     if(TimeDay(Time[cb+1])!=TimeDay(Time[cb]) )
                       {
                        n=cb-8;
                        while( n<=cb+Range*8+4 )
                          {
                           if(n<0 )
                             {
                              Nbar=0;
                              n=1;
                             }
                           if(TimeDay(Time[n+1])!=TimeDay(Time[n]) )
                             {
                              if(Nbar==-1 )
                                {
                                 Nbar=n;
                                 mm=n;
                                 n++;
                                 continue;
                                }
                              else
                                {
                                 h1[k]=High[Highest(NULL,0,MODE_HIGH,(n-Nbar),n)];
                                 l1[k]=Low[Lowest(NULL,0,MODE_LOW,(n-Nbar),n)];
                                 k++;
                                 Nbar=n;
                                }
                             }
                           n++;
                          }
                        MaH=0;
                        MaL=0;
                        for( n=1;n<=Range;n++ )
                          {
                           MaH=MaH+h1[n];
                           MaL=MaL+l1[n];
                          }
                        MaH=MaH/Range;
                        MaL=MaL/Range;
                        ur1[cb]=MaH;
                        ur2[cb]=MaL;
                        if(Close[mm+1]>=MaH )
                          {
                           ll=1;
                           hh=0;
                          }
                        if(Close[mm+1]<=MaL )
                          {
                           hh=1;
                           ll=0;
                          }
                       }
                     if(ur1[cb]==0 )
                       {
                        ur1[cb]=ur1[cb+1];
                        ur2[cb]=ur2[cb+1];
                       }
                     if(ll==1 )
                       {
                        Up[cb]=ur2[cb];
                       }
                     else
                       {
                        if(hh==1 )
                          {
                           Dn[cb]=ur1[cb];
                          }
                       }
                    }
                    else 
                    {
                     //-----------------------------------------------------------------------------
                     if(Period()==1440)//если график - D1
                       {
                        if(TimeDayOfWeek(Time[cb+1])==5 && TimeDayOfWeek(Time[cb])==1 )
                          {
                           n=cb-6;
                           while( n<=cb+Range*5+3 )
                             {
                              if(n<0 )
                                {
                                 Nbar=0;
                                 n=1;
                                }
                              if(TimeDayOfWeek(Time[n+1])==6 || TimeDayOfWeek(Time[n])==2 )
                                {
                                 if(Nbar==-1 )
                                   {
                                    Nbar=n;
                                    mm=n;
                                    n++;
                                    continue;
                                   }
                                 else
                                   {
                                    h1[k]=High[Highest(NULL,0,MODE_HIGH,(n-Nbar),n)];
                                    l1[k]=Low[Lowest(NULL,0,MODE_LOW,(n-Nbar),n)];
                                    k++;
                                    Nbar=n;
                                   }
                                }
                              n++;
                             }
                           MaH=0;
                           MaL=0;
                           for( n=1;n<=Range;n++ )
                             {
                              MaH=MaH+h1[n];
                              MaL=MaL+l1[n];
                             }
                           MaH=MaH/Range;
                           MaL=MaL/Range;
                           ur1[cb]=MaH;
                           ur2[cb]=MaL;
                           if(Close[mm+1]>=MaH )
                             {
                              ll=1;
                              hh=0;
                             }
                           if(Close[mm+1]<=MaL )
                             {
                              hh=1;
                              ll=0;
                             }
                          }
                        if(ur1[cb]==0 )
                          {
                           ur1[cb]=ur1[cb+1];
                           ur2[cb]=ur2[cb+1];
                          }
                        if(ll==1 )
                          {
                           Up[cb]=ur2[cb];
                          }
                        else
                          {
                           if(hh==1 )
                             {
                              Dn[cb]=ur1[cb];
                             }
                          }
                       }
                       else 
                       {
                        //-----------------------------------------------------------------------------
                        if(Period()== 10080)//если график - W1
                          {
                           if(TimeMonth(Time[cb+1])!=TimeMonth(Time[cb]) )
                             {
                              n=cb-8;
                              while( n<=cb+Range*8+4 )
                                {
                                 if(n<0 )
                                   {
                                    Nbar=0;
                                    n=1;
                                   }
                                 if(TimeMonth(Time[n+1])!=TimeMonth(Time[n]) )
                                   {
                                    if(Nbar==-1 )
                                      {
                                       Nbar=n;
                                       mm=n;
                                       n++;
                                       continue;
                                      }
                                    else
                                      {
                                       h1[k]=High[Highest(NULL,0,MODE_HIGH,(n-Nbar),n)];
                                       l1[k]=Low[Lowest(NULL,0,MODE_LOW,(n-Nbar),n)];
                                       k++;
                                       Nbar=n;
                                      }
                                   }
                                 n++;
                                }
                              MaH=0;
                              MaL=0;
                              for( n=1;n<=Range;n++ )
                                {
                                 MaH=MaH+h1[n];
                                 MaL=MaL+l1[n];
                                }
                              MaH=MaH/Range;
                              MaL=MaL/Range;
                              ur1[cb]=MaH;
                              ur2[cb]=MaL;
                              if(Close[mm+1]>=MaH )
                                {
                                 ll=1;
                                 hh=0;
                                }
                              if(Close[mm+1]<=MaL )
                                {
                                 hh=1;
                                 ll=0;
                                }
                             }
                           if(ur1[cb]==0 )
                             {
                              ur1[cb]=ur1[cb+1];
                              ur2[cb]=ur2[cb+1];
                             }
                           if(ll==1 )
                             {
                              Up[cb]=ur2[cb];
                             }
                           else
                             {
                              if(hh==1 )
                                {
                                 Dn[cb]=ur1[cb];
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
      //-----------------------------------------------------------------------------
      if (Dn[cb+1]==0.0 && Dn[cb]!=0.0)
        {
         if(cb==0) Alert("Три раза дзинь!!!  :)  Пора продавать.");
         SetSymbol("sell_sig",cb,0,Time[cb],High[cb]+15*Point,Black,2,218);
        }
      if (Up[cb+1]==0.0 && Up[cb]!=0.0)
        {
         if(cb==0) Alert("Три раза дзинь!!!  :)  Пора покупать.");
         SetSymbol("buy_sig",cb,0,Time[cb],Low[cb]-15*Point,DeepSkyBlue,2,217);
        }
     }
//-----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetSymbol(string txt,int _cb,int win,datetime stime, double sprice,int scol,int swidth,int scode)
  {
//---- 
   if(ObjectFind(txt+" "+(string)_cb)==-1)
     {
      ObjectCreate(txt+" "+(string)_cb,OBJ_ARROW,win,stime,sprice);
      ObjectSet(txt+" "+(string)_cb,OBJPROP_COLOR,scol);
      ObjectSet(txt+" "+(string)_cb,OBJPROP_WIDTH,swidth);
      ObjectSet(txt+" "+(string)_cb,OBJPROP_ARROWCODE,scode);
     }
   else
     {
      ObjectMove(txt+" "+(string)_cb,0,stime,sprice);
     }
//----
   return;
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
  int deinit() 
  {
//---- TODO: add your code here
   int _cb;
   for(_cb=Bars-1-Range;_cb>=0;_cb--)
     {
      if(ObjectFind("buy_sig "+(string)_cb)!=-1 )
        {
         ObjectDelete("buy_sig "+(string)_cb);
        }
      else
        {
         if(ObjectFind("sell_sig "+(string)_cb)!=-1)
           {
            ObjectDelete("sell_sig "+(string)_cb);
           }
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+