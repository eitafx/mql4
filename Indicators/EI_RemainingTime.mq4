//+------------------------------------------------------------------+
//|                                             EI_RemainingTime.mq4 |
//|                                             Copyright 2014, eita |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, eita"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window

string objectName = "ei_remining_time";

input color FontColor = OrangeRed;
input int FontSize = 18;
input string Description_about_corner = "0:Upper left 1:Upper right 2:Lower left 3:Lower right";
input int Corner = 0;

#define LocationX 5
#define LocationY 20

int VariableCorner;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   VariableCorner = Corner;
   EventSetTimer(1);
   
   ObjectCreate(objectName, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(objectName, "", FontSize, NULL, FontColor);
   
//---
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
{
   ObjectDelete(objectName);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   // calculate the remaining time
   int rt = (int)(Time[0] + (Period()*60) - TimeCurrent());

   // calculate each time
   int hour = 0;
   int min = 0;
   int sec = 0;

   hour = rt / 3600;
   rt -= ( hour * 3600 );

   min = rt / 60;
   rt -= ( min * 60 );
   
   sec = rt;
   
   // make the display text.
   string displayText = "";
   if ( hour > 0 ) {
      displayText += DoubleToStr(hour,0) + "h";
   }
   
   if ( min > 0 ) {
      displayText += DoubleToStr(min,0) + "m";
   }
   
   displayText += DoubleToStr(sec,0) + "s";
   
   ObjectSetText(objectName, displayText, FontSize, NULL, FontColor);
	ObjectSet(objectName, OBJPROP_XDISTANCE, LocationX);
	ObjectSet(objectName, OBJPROP_YDISTANCE, LocationY);
	ObjectSet(objectName, OBJPROP_CORNER, VariableCorner);
  }

//+------------------------------------------------------------------+
//| Event function                                                   |
//+------------------------------------------------------------------+
void OnChartEvent( const int id,
                   const long& lparam,
                   const double& dparama,
                   const string& sparam )
{
   if ( (id == CHARTEVENT_KEYDOWN) && (lparam == 80) ) {
      VariableCorner++;
      if ( VariableCorner > 3) {
         VariableCorner = 0;
      }
      ObjectSet(objectName, OBJPROP_CORNER, VariableCorner);
   }
}


//+------------------------------------------------------------------+
