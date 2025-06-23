//+------------------------------------------------------------------+
//|                                                 Grucha Index.mq4 |
//|                                                   gaa1@poczta.fm |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Grzegorz Antosiewicz"
#property link      "gaa1@poczta.fm "

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

#property indicator_minimum 0
#property indicator_maximum 100
//---- buffers
double ExtMapBuffer1[];
double tab[];
double srednia[];
double dResult,gora,dol,suma,close,open,wynik;

extern int Okresy=10;
extern int MA_Okresy=10;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(3);
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexLabel(0,"Grucha % Index");
   SetIndexLabel(1,"Ma of Grucha % Index");
   SetIndexBuffer(1,srednia);
   SetIndexBuffer(2,tab);
   SetIndexDrawBegin(0,Okresy);
//----
   return(1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   Comment("\nIf you need MQL CODER quote to AUTOR."
           +"\n\n- polish student of computer since with big experience in mql"+" \n"+
           "\n                                     mail to:\n\n>>>>>>>>>>>>   gaa1@poczta.fm    <<<<<<<<<<< "
           +"\n\nLOW PRICE and HIGH QUAILTY"
           );

   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+Okresy;

   int pos=limit;
//---- g³ówna pêtla
   while(pos>=0)
     {
      close= Close[pos];
      open = Open[pos];

      dResult=open-close;                          //wartos swiecy do zmiennej
      tab[pos]=dResult; //przypisuje wartosc do tablicy

      if(Bars-pos>(Okresy-1)) //sprawdzam czy istnieje n elemntowa tablica
        {
         gora = 0;
         dol  = 0;
         for(int l=pos+(Okresy-1); l>=pos; l--) //odliczam n okresow
           {
            if(tab[l]<0)
              {
               gora+=tab[l];
              }                    //sumuje wartosci ze wzrostowych slupkow  do gora
            else if(tab[l]>=0)
              {
               dol-=tab[l];
              }
           }
         if(dol<=0)
           {dol=dol*(-1);}
         if(gora<=0)
           {gora=gora*(-1);}
         suma=dol+gora; // sumuje wartosci wszytkich slupkow

         if(suma==0)
           {
            wynik=0;
            //Print("Suma = 0");
           }
        }

      if(suma>0)
        {
         wynik=((gora/suma) *100);
        }
      else
        {
         wynik=0;
        }

      ExtMapBuffer1[pos]=wynik;
      pos--;
      //Comment(dol,"dol",gora,"gora" );
     }

   int   index=Bars-MA_Okresy;
   while(index>=0)
     {
      srednia[index]=iMAOnArray(ExtMapBuffer1,0,MA_Okresy,0,0,index);
      //Comment(tab2[index],"srednia->",srednia[index]);  
      index--;
     }
   return(0);
  }
//+------------------------------------------------------------------+ 
