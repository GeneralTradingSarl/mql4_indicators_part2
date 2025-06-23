
//+------------------------------------------------------------------+
//|                                                          msh.mq4 |
//|                                 Copyright © 2010, Thomas Quester |
//| Market structure low / market structure low                      |
//|                                                  tquester@gmx.de |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Thomas Quester"
#property link      "tquester@gmx.de"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Yellow
#property indicator_color4 Yellow
//---- buffers
extern int PipRange=5;
extern int Porcent=20;
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
int    counter[];
double index[];
int    count;
int    colors[] = {White,Yellow,DodgerBlue,Orange,Red};


int       maxcount;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void clearIndex()
{
   ArrayResize(counter,Bars);
   ArrayResize(index,Bars);
   count =0;
   maxcount=0;
   ArrayInitialize(counter,0);
   ArrayInitialize(index,0);
}

// adds a price to the price arry
// we calculate the price in pips/10
void addPrice(double price)
{
   int i;
   bool found = false;
   int pips = price/Point;
   pips/=PipRange;
   pips*=PipRange;
   
   for (i=0;i<count;i++)
   {    
      if (index[i] == pips)
      {
         found = true;
         counter[i] = counter[i]+1;
         if (counter[i] > maxcount)
             maxcount = counter[i];
         
         break;
      }      
   }
   if (!found)
   {
      index[count] = pips;
      counter[i] = 1;
      count++;
   }
}
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexBuffer(3,ExtMapBuffer4);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
  
void clearLines()
{
    int i;
    string s;
    for (i=0;i<400;i++)
    {
        s = "----------line---------"+i;
        ObjectDelete(s);
        
    }
}

void createLines()
{
   int i;
   int id;
   int c;
   int w;
   double price;
   string name;
   int min = maxcount*Porcent;
   
   min /= 100;
   Print("maxcount="+maxcount+" min="+min);
   int range = maxcount- min;
   if (range<5)
      range=5;
   id = 0;
   for (i=0;i<count;i++)
   {
       if (counter[i] > min)
       {
           price = index[i] * Point;
           name = "----------line---------"+id;
           id=id+1;
           c  = counter[i];
           ObjectCreate(name,OBJ_HLINE,0,0,price);
           // maxcount=100
           // min=75
           // range 0..24
           // 24 soll 5 sein
           // 0  soll 1 sein
           w = c-min;
           
           
    //       w /= range/5;
    //       Print("price="+price+" w = "+w, " range="+range," maxcount="+ maxcount+" min="+min);
           
           
           ObjectSet(name,OBJPROP_COLOR,colors[w]);
           ObjectSetText(name,c + " points w="+w,10);
           if (id > 400) break;
       }
   }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i,j,k,cnt;
   double a,b,c,
          d,e,f;
   int    counted_bars=IndicatorCounted();
   a = 0;
   b = 0;
   c = 0;
   clearIndex();  
   for (i=Bars;i>=0;i--)
   {
     ExtMapBuffer1[i] = -1;
     ExtMapBuffer2[i] = -1;
     ExtMapBuffer3[i] = -1;
     ExtMapBuffer4[i] = -1;
     a = b;
     b = c;
     c = High[i];
     
     d = e;
     e = f;
     f = Low[i];
     
     
     if (a <= b && c <= b)
     {
         ExtMapBuffer1[i+1] = b;
         ExtMapBuffer3[i+1] = b;
         addPrice(b);
     }
         
     if (d >= e && f >= e)
     {
         ExtMapBuffer2[i+1] = e;
         ExtMapBuffer3[i+1] = e;
         addPrice(e);
     }
     
   }
//----
   //connect points with lines (interploating)
   a = 0;
   j = -1;
   for (i=Bars;i>=0;i--)
   {
      if (ExtMapBuffer1[i] != -1)
      {
         if (j != -1)
         {
            cnt = i-j;
            b = ExtMapBuffer1[i];
            c = (b-a)/cnt;
            for (k=i;k<j;k++)
            {
               ExtMapBuffer1[k] = b;
               b += c;
            }
            
         }
         j = i;
         a = ExtMapBuffer1[i]; 
      }
   }
   for (i=0;i<Bars;i++)
   {
      if (ExtMapBuffer1[i] != -1) break;
      ExtMapBuffer1[i] = a;
   }

   a = 0;
   j = -1;
   for (i=Bars;i>=0;i--)
   {
      if (ExtMapBuffer2[i] != -1)
      {
         if (j != -1)
         {
            cnt = i-j;
            b = ExtMapBuffer2[i];
            c = (b-a)/cnt;
            for (k=i;k<j;k++)
            {
               ExtMapBuffer2[k] = b;
               b += c;
            }
            
         }
         j = i;
         a = ExtMapBuffer2[i]; 
      }
   }
   for (i=0;i<Bars;i++)
   {
      if (ExtMapBuffer2[i] != -1) break;
      ExtMapBuffer2[i] = a;
   }
   
   clearLines();
   createLines();

//----
   return(0);
  }
//+------------------------------------------------------------------+