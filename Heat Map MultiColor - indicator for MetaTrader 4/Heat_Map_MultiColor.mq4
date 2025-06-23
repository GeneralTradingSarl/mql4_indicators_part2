//+------------------------------------------------------------------+
//|                 This has been coded by MT-Coder                  |
//|                                                                  |
//|                     Email: mt-coder@hotmail.com                  |
//|                      Website: mt-coder.110mb.com                 |
//|                                                                  |
//|         For any strategy you have in mind to be coded into EA    |
//|                 For any indicator you have in mind               |
//|                                                                  |
//|          Don't hesitate to contact me at mt-coder@hotmail.com    |
//|            Or on the Website: mt-coder.110mb.com                 |
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//|    The purpose of this indicator is to highlight the price zones |
//|     that had the most activity : the hottest zones.              |
//|                                                                  |
//|    The indicator shows a gradiant of colors from Cold to Hot     |
//|                                                                  |
//|                Latest issue Aug 05 2010                          |
//|                                                                  |
//|                                                                  |
//|    ** ** ** * ** * *** SETTINGS ** ** **** ** * **               |
//|       HMPeriod : the number of bars included in the count        |
//|       Scale : the size of each zone.                             |
//|       NbZone : the number of zones to create.                    |
//|       Cold : the color of the coldest zones.                     |
//|       Hot : the color of the hottest zones.                      |
//|                                                                  |
//|            --------------------------------------                |
//|                                                                  |
//| The two functions rgb2int() and colorgradient() were used from   |                                                            |
//|   http://www.thetradingtheory.com/colors-in-mql4/                |
//|       thanks to zenhop for pointing out to them                  |
//+------------------------------------------------------------------+



#property copyright "Copyright © 2010, MT-Coder."
#property link      "http://mt-coder.110mb.com/"

#property indicator_chart_window



//---- input parameters
extern int HMPeriod = 500;
extern int Scale = 10;
extern int NbZone = 100;
extern color Cold = C'151,249,234';
extern color Hot = C'255,87,83';



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {

datetime dt2, dt;

dt = Time[0];
dt2 = dt + 3000*Period();
 
  
  DeleteObjects();
  for (int i=1; i<=NbZone; i++) {
    CreateObjects("zone"+i,dt,Close[0]+(Scale*Point*(i-1)),dt2,Close[0]+(Scale*Point*i));
    int m = -i;
    CreateObjects("zone"+m,dt,Close[0]-(Scale*Point*(i-1)),dt2,Close[0]-(Scale*Point*i));
  }
  return(0);
  
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() {

  DeleteObjects();
  return(0);
  
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateObjects(string no, datetime t1, double p1, datetime t2, double p2) {
  ObjectCreate(no, OBJ_RECTANGLE, 0, t1,p1, t2,p2);
  ObjectSet(no, OBJPROP_STYLE, STYLE_SOLID);

  ObjectSet(no, OBJPROP_BACK, True);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteObjects() {
  for (int i=1; i<=NbZone; i++) {
    ObjectDelete("zone"+i);
   int m=-i; 
    ObjectDelete("zone"+m);
   
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
  Comment("Heat Map MultiColor\n","Programed By: MT-Coder\n", "** MT-Coder@hotmail.com **\n", "http://MT-Coder.110mb.com");
init();

   double var1, var2;
    var1=0;
    var2=0;
    

    
      //----
      for(int j=1; j<=NbZone; j++)
      {

  
  
         int m=-j;
        
         
           for(int i=1; i<HMPeriod; i++)
            {
             
            //-----for the values upper than the actual price
             if(Low[i]<Close[0]+(Scale*Point*j) && High[i]>Close[0]+(Scale*Point*(j-1)))
             {
             
               //---the possible cases of presence of the bar fully or partially within the scale
               if(High[i]-Low[i]>Scale*Point){ var1 = var1 + 1 ;}
               //---
               if(High[i]>= Bid+(Scale*Point*j) && Low[i]<=Bid+(Scale*Point*(j-1))){ var1 = var1 + ((High[i]-Low[i])/(Scale*Point));}
               //---

               if(High[i]>Bid+(Scale*Point*j) && Low[i]>Bid+(Scale*Point*(j-1))){ var1 = var1 + ((Bid+(Scale*Point*j)-Low[i])/(Scale*Point));}
               //---
               if(Low[i]<Bid+(Scale*Point*(j-1)) && High[i]<Bid+(Scale*Point*j)) {var1 = var1 + ((High[i]-Bid+(Scale*Point*(j-1)))/(Scale*Point));}
               
           
             } 
           
           
            
             //-----for the values lower than the actual price
             
               if(Low[i]<Close[0]+(Scale*Point*(m+1)) && High[i]>Close[0]+(Scale*Point*m))
             {
                //---the possible cases of presence of the bar fully or partially within the scale
                if(High[i]-Low[i]>Scale*Point) var2 = var2 + 1;
                //---  
                if(High[i]>= Bid+(Scale*Point*(m+1)) && Low[i]<=Bid+(Scale*Point*m)) var2 = var2 + ((High[i]-Low[i])/(Scale*Point));
                //---
              
                if(Low[i]<=Bid+(Scale*Point*m) && High[i]<=Bid+(Scale*Point*(m+1))) var2 = var2 + ((High[i]-(Bid+(Scale*Point*m)))/(Scale*Point));
                //---
                if(High[i]>Bid+(Scale*Point*(m+1)) && Low[i]>Bid+(Scale*Point*m)) var2 = var2 + ((Bid+(Scale*Point*(m+1))-Low[i])/(Scale*Point));
                  
      
             }
   
            }     
            
             
 

        
            //----determine the heat and therefore the color
            //frags1, frags2 will be used to define the class of 'heat' : 1 hottest, 0 coldest
            
            double frags1 = var1/(var1+var2);
            double frags2 = var2/(var1+var2);

           double min = 0;
           double max = 100;
           //
           color cl1 = colorgradient(GetRed(Hot),GetGreen(Hot),GetBlue(Hot), GetRed(Cold),GetGreen(Cold),GetBlue(Cold), min,max,frags1*100); //
           color cl2 = colorgradient(GetRed(Hot),GetGreen(Hot),GetBlue(Hot), GetRed(Cold),GetGreen(Cold),GetBlue(Cold), min,max,frags2*100); //

           
            //----give the right color to the rectangle
            DrawObjects("zone"+j, cl1);//give the upper rectangle j the color cl1
            DrawObjects("zone"+m, cl2);//give the lower rectangle m=-j the color cl2
          
     }
 
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawObjects(string no, color col) {

  ObjectSet(no, OBJPROP_COLOR, col);

}

/*
//--these two functions rgb2int() and colorgradient() were used from http://www.thetradingtheory.com/colors-in-mql4/
//thanks to zenhop for pointing out to them
*/
int rgb2int(int r, int g, int b) {

return (b*65536 + g*256 + r);
}

int colorgradient(int r, int g, int b, int r2, int g2, int b2, double min, double max, double pos) {
double steps = (max-min);
pos = max-pos;
double stepR = (r-r2)/(steps-1);
double stepG = (g-g2)/(steps-1);
double stepB = (b-b2)/(steps-1);
return (rgb2int((r-(stepR*pos)),(g-(stepG*pos)),(b-(stepB*pos))));

}
/*
//--these three functions are used to extract the RGB values from the user's external color
*/
int GetBlue(int clr)
{
int blue = MathFloor(clr / 65536);
return (blue);
}

int GetGreen(int clr)
{
int blue = MathFloor(clr / 65536);
int green = MathFloor((clr-(blue*65536)) / 256);
return (green);
}

int GetRed(int clr)
{
int blue = MathFloor(clr / 65536);
int green = MathFloor((clr-(blue*65536)) / 256);
int red = clr -(blue*65536) - (green*256);
return (red);
}
//+------------------------------------------------------------------+