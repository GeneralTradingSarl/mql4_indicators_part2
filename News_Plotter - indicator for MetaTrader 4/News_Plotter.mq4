//+------------------------------------------------------------------+
//|                                             Des_News_Plotter.mq4 |
//|                                                        DesORegan |
//|                                   mailto: oregan_des@hotmail.com |
//+------------------------------------------------------------------+
// ========================================================================================================
// This indicator displays lines on the chart corresponding to upcoming news events. It has the following features:
//        1. Customizable audio alerts prior to the news event itself.
//        2. Allows the user to display lines according to event rating. e.g. display High rated events only.
//        3. Deletes old news lines from the chart(older than today's)".
//        4. Adjusts GMT from file to local (using GMT_Offset).
//        5. Converts AM/PM time in file to 24hr for correct plotting.
//        6. Prioritises higher rated events at same time as lower events. Prevents High "hiding" behind Low etc..
//            (assuming appropriate timeframe is selected)
//        7. Event descriptions used to populate object descriptions.
//
// To be able to use this indicator you must first save the file from the DailyFx website to the 
// C:\Program Files\Broker Metatrader\experts\files folder. The file is located at:
//         http://www.dailyfx.com/calendar/Dailyfx_Global_Economic_Calendar.csv
// IMPORTANT: It must be saved as "News.csv". Make sure it's for the current week.
//
// Save your own preferences by changing the external inputs in the code and recompiling.
// There may be bugs in this indicator but I think I've got most if not all ironed out.
// Only one way to find out. ;-) 
//
// ========================================================================================================

#property copyright "DesORegan"
#property link      "mailto: oregan_des@hotmail.com"

#property indicator_chart_window

#include <stdlib.mqh>


// =========================                        
// External Global Variables
// =========================

extern int     GMT_Offset=2;  // change this to suit, default (+2) is for CET
extern bool    Display_Low=true; 
extern color   Low_Color=Blue;   
extern bool    Display_Medium=true;
extern color   Medium_Color=Orange;
extern bool    Display_High=true;
extern color   High_Color=Red;
extern bool    News_Alerts=true;
extern bool    Low_Alerts=false;
extern bool    Medium_Alerts=false;
extern bool    High_Alerts=true;
extern int     Warning_In_Mins=15;
extern bool    Delete_Old_News=false; // deletes events older than today's


// =========================                        
// Internal Global Variables
// =========================
datetime Today_Start;


// =========================                        
// Internal Global Arrays
// =========================
string News_Array [][5]; // 0=Date,1=Description,2=Rating,3=Rating No.,4=Alert Given?



// =================================================================================================    
// =================================================================================================
// Custom indicator initialization function                          
// =================================================================================================          
// =================================================================================================  
int init()
   {
   
   //======================
   // Variable Init
   //======================     
   Today_Start = iTime(Symbol(),PERIOD_D1,0);   
   GMT_Offset = GMT_Offset*3600; // *secs in hour
   Warning_In_Mins = Warning_In_Mins*60; // *secs in minute
   
   
   
   News_Plotter();   // reads file and plots news according to preferences
   
   if (Delete_Old_News == true) Delete_Old_News();    // deletes old event lines



   return(0);
   }
   
   
// =================================================================================================    
// =================================================================================================
// Custom indicator deinitialization function                          
// =================================================================================================          
// =================================================================================================    
int deinit()
   {
      
   ObjectsDeleteAll();

   return(0);
   }
   
   
   
// =================================================================================================    
// =================================================================================================
// Custom indicator iteration function                          
// =================================================================================================          
// ================================================================================================= 

int start()
  {
   

   if (News_Alerts == true) Check_News(); // checks for imminent news events
   
   if (Delete_Old_News == true && Today_Start != iTime(Symbol(),PERIOD_D1,0)) // only calls if new day
      {
      Delete_Old_News();
      Today_Start = iTime(Symbol(),PERIOD_D1,0);
      }
   
   

   return(0);
  }



// =================================================================================================
//| News_Plotter function                          
// =================================================================================================     
int News_Plotter ()
   {   
   

   
   string Event_Date, Event_Month, Event_Day, Event_Time;
   string Gap, Event_Description, Event_Rating, Event_Rating_No;
   string Hrs, Mins;
   int Int_Hrs, Int_Mins, Last_Int_Event_Rating, i=0;
   datetime Real_Event_DateTime, Real_Event_Time;
   color Market_Event_Color;
   
   int File = FileOpen("News.CSV", FILE_CSV|FILE_READ,','); // opens News.csv file 
   
   
   if (File == -1)
      {    
      Alert("News Events File Error.");
      int err=GetLastError();
      Print("Error(",err,"): ",ErrorDescription(err));      
      }
      
   FileSeek(File, 96, SEEK_SET); // move file pointer to beginning of valid data
      
    
   while(FileIsEnding(File)==false)  // While the file pointer is not at the end of the file      
      {                                
      
      ArrayResize(News_Array,i+1);  //resizes array for every loop (event)
      
      // ===========================
      // Reads file and formats data
      // ===========================      
      Event_Date =  FileReadString(File);                                     // Read Date from file
      
      if(StringSubstr(Event_Date,4,3) == "Jan") Event_Month = "01";           // extract Month and convert to number
      else if(StringSubstr(Event_Date,4,3) == "Feb") Event_Month = "02";      // in string format for adding to 
      else if(StringSubstr(Event_Date,4,3) == "Mar") Event_Month = "03";      // other components of Date
      else if(StringSubstr(Event_Date,4,3) == "Apr") Event_Month = "04";
      else if(StringSubstr(Event_Date,4,3) == "May") Event_Month = "05";
      else if(StringSubstr(Event_Date,4,3) == "Jun") Event_Month = "06";
      else if(StringSubstr(Event_Date,4,3) == "Jul") Event_Month = "07";
      else if(StringSubstr(Event_Date,4,3) == "Aug") Event_Month = "08";
      else if(StringSubstr(Event_Date,4,3) == "Sep") Event_Month = "09";
      else if(StringSubstr(Event_Date,4,3) == "Oct") Event_Month = "10";
      else if(StringSubstr(Event_Date,4,3) == "Nov") Event_Month = "11"; 
      else if(StringSubstr(Event_Date,4,3) == "Dec") Event_Month = "12";   
      else Alert ("Date Reading Error in News Function");   

      Event_Day = StringSubstr(Event_Date, (StringLen(Event_Date)-2), 0);     // extract Day
      Event_Date = TimeYear(TimeCurrent())+"."+Event_Month+"."+Event_Day;     // reconfigure Date
      Event_Time = StringConcatenate("0000",FileReadString(File)) ;           // read Time and fill out with 0's
      

      // ===========================
      // Converts AM/PM to 24hr
      // =========================== 
      if (StringSubstr(Event_Time, (StringLen(Event_Time)-2), 2) == "PM") // PM time conversion
         {
         Mins = StringSubstr(Event_Time,(StringLen(Event_Time)-5),2);
         Hrs = StringSubstr(Event_Time,(StringLen(Event_Time)-8),2);
         Int_Hrs = StrToInteger(Hrs)*3600;
         Int_Mins = StrToInteger(Mins)*60;         
         Real_Event_Time = Int_Hrs + Int_Mins;
         if (Real_Event_Time < 43200) Real_Event_Time = Real_Event_Time + 43200; // prevents 12:12PM etc from being altered
         }
      else  // AM time conversion 
         {
         Mins = StringSubstr(Event_Time,(StringLen(Event_Time)-5),2);   
         Hrs = StringSubstr(Event_Time,(StringLen(Event_Time)-8),2);
         Int_Hrs = StrToInteger(Hrs)*3600;
         Int_Mins = StrToInteger(Mins)*60;         
         Real_Event_Time = Int_Hrs + Int_Mins;
         }
        
      
      Gap = FileReadString(File) ;
      Gap = FileReadString(File) ;
      Event_Description = FileReadString(File);
      Event_Rating = FileReadString(File) ;
      for (int p = 1; p <= 5; p++) Gap = FileReadString(File) ; // more gaps in file for unused data
      
      
      if (Real_Event_Time == 0) // if no time is specified in file 
         {
         Real_Event_DateTime = StrToTime(Event_Date) + Real_Event_Time;  
         //Print("Warning: "+Event_Date+" "+Event_Rating+" - "+Event_Description+" - Event Time Unknown");
         //Print("Please check internet for updates.");
         Event_Description = "Event Time Unknown "+Event_Description;
         }
      else Real_Event_DateTime = StrToTime(Event_Date) + Real_Event_Time + GMT_Offset;      
         
         
      // ==================
      // Fills News_Array
      // ==================   
      News_Array[i,0] = TimeToStr(Real_Event_DateTime);  // fills datetime data in compatible format
      News_Array[i,1] = Event_Description;   // fills description data
      News_Array[i,2] = Event_Rating;  // fills rating data
      if (Event_Rating == "High") Event_Rating_No = "3";
      if (Event_Rating == "Medium") Event_Rating_No = "2";
      if (Event_Rating == "Low") Event_Rating_No = "1";      
      News_Array[i,3] = Event_Rating_No;  // number equivalent for ratings
      News_Array[i,4] = "0";  // used for prevents repetition of alerts
      
      
      i++; // required to increment News_Array
         
 

      }

   FileClose( File );      
   
      
   // =================================================================
   // Helps set rating color for events at same time to highest rating.
   // Used with Market_Event_Color below.
   // =================================================================
   for (p = 1; (p <= ArraySize(News_Array)/5); p++) // this helps give priority to higher rated events
      {
      if (News_Array[p,0] == News_Array[p-1,0] && StrToInteger(News_Array[p,3]) < StrToInteger(News_Array[p-1,3]))
         {
         News_Array[p,3] = News_Array[p-1,3];
         }
      }         

   // ============================
   // Plots event lines on chart 
   // ============================        
   for (p = 0; p < (ArraySize(News_Array)/5); p++)
      {
      
      if (News_Array[p,3] == "1") Market_Event_Color = Low_Color;
      if (News_Array[p,3] == "2") Market_Event_Color = Medium_Color;
      if (News_Array[p,3] == "3") Market_Event_Color = High_Color;
      
      if(Display_Low == true && News_Array[p,2] == "Low") 
         {
         ObjectCreate(p+".News: "+News_Array[p,0],OBJ_VLINE,0,StrToTime(News_Array[p,0]),NULL);
         ObjectSet(p+".News: "+News_Array[p,0],OBJPROP_COLOR,Market_Event_Color);      
         ObjectSet(p+".News: "+News_Array[p,0],OBJPROP_WIDTH,1);
         ObjectSet(p+".News: "+News_Array[p,0], OBJPROP_BACK, true);   
         ObjectSet(p+".News: "+News_Array[p,0],OBJPROP_STYLE,STYLE_DOT);
         ObjectSetText(p+".News: "+News_Array[p,0], News_Array[p,2]+": "+News_Array[p,1], 8);   
         }
      if(Display_Medium == true && News_Array[p,2] == "Medium") 
         {
         ObjectCreate(p+".News: "+News_Array[p,0],OBJ_VLINE,0,StrToTime(News_Array[p,0]),NULL);
         ObjectSet(p+".News: "+News_Array[p,0],OBJPROP_COLOR,Market_Event_Color);      
         ObjectSet(p+".News: "+News_Array[p,0],OBJPROP_WIDTH,1);
         ObjectSet(p+".News: "+News_Array[p,0], OBJPROP_BACK, true);   
         ObjectSet(p+".News: "+News_Array[p,0],OBJPROP_STYLE,STYLE_DOT);
         ObjectSetText(p+".News: "+News_Array[p,0], News_Array[p,2]+": "+News_Array[p,1], 8);   
         }
      if(Display_High == true && News_Array[p,2] == "High") 
         {
         ObjectCreate(p+".News: "+News_Array[p,0],OBJ_VLINE,0,StrToTime(News_Array[p,0]),NULL);
         ObjectSet(p+".News: "+News_Array[p,0],OBJPROP_COLOR,Market_Event_Color);      
         ObjectSet(p+".News: "+News_Array[p,0],OBJPROP_WIDTH,1);
         ObjectSet(p+".News: "+News_Array[p,0], OBJPROP_BACK, true);   
         ObjectSet(p+".News: "+News_Array[p,0],OBJPROP_STYLE,STYLE_DOT);
         ObjectSetText(p+".News: "+News_Array[p,0], News_Array[p,2]+": "+News_Array[p,1], 8);   
         }               

      }
      
      
   // ==================================
   // DEBUG TOOL - PRINTS ARRAY CONTENTS
   // ==================================   
   //for (p = 0; p < (ArraySize(News_Array)/5); p++) 
   //   {      
   //   Print(News_Array[p,0]+" "+News_Array[p,1]+" "+News_Array[p,2]+" "+News_Array[p,3]+" "+News_Array[p,4]);
   //   }



   return(0);
   }            
   

// =================================================================================================
// Check News function                          
// =================================================================================================     
int Check_News ()
   {      
   
   
   for (int p = 0; p < (ArraySize(News_Array)/5); p++)
      {
      if (TimeCurrent()-TimeSeconds(TimeCurrent()) == (StrToTime(News_Array[p,0])-Warning_In_Mins) && News_Array[p,4] == "0") 
         {
         if (Low_Alerts == true && News_Array[p,2] == "Low")
            {
            Alert(News_Array[p,1]+" rated "+News_Array[p,2]+" occurs in "+Warning_In_Mins/60+"mins.");
            News_Array[p,4] = "1";
            }
         if (Medium_Alerts == true && News_Array[p,2] == "Medium")
            {
            Alert(News_Array[p,1]+" rated "+News_Array[p,2]+" occurs in "+Warning_In_Mins/60+"mins.");
            News_Array[p,4] = "1";
            }
         if (High_Alerts == true && News_Array[p,2] == "High")
            {
            Alert(News_Array[p,1]+" rated "+News_Array[p,2]+" occurs in "+Warning_In_Mins/60+"mins.");
            News_Array[p,4] = "1";
            }                                
            
         }
      }
   return(0);
   }        
   
   
// =================================================================================================
// Delete_Old_News function                          
// =================================================================================================    
int Delete_Old_News()
   {
   
   for (int p = 0; p < (ArraySize(News_Array)/5); p++)
      {

      if (iTime(Symbol(),PERIOD_D1,0) > StrToTime(News_Array[p,0]))
         {
         ObjectDelete(p+".News: "+News_Array[p,0]);
         }
      }
   return(0);
   }       