//+------------------------------------------------------------------+
//|                                                        EI_02.mq4 |
//|                                             Copyright 2014, eita |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, eita"
#property link      ""
#property version   "1.01"
#property strict
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   6

//--- plot UpArrow
#property indicator_label1  "UpArrow_L1"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "UpArrow_L2"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "UpArrow_L3"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#property indicator_label4  "DownArrow_L1"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

#property indicator_label5  "DownArrow_L2"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1

#property indicator_label6  "DownArrow_L3"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1

//--- indicator buffers
double         UpArrowL1Buffer[];
double         UpArrowL2Buffer[];
double         UpArrowL3Buffer[];
double         DownArrowL1Buffer[];
double         DownArrowL2Buffer[];
double         DownArrowL3Buffer[];

#define TREND_NONE      (0)
#define TREND_UP_L1     (1)
#define TREND_UP_L2     (2)
#define TREND_UP_L3     (3)
#define TREND_DOWN_L1   (-1)
#define TREND_DOWN_L2   (-2)
#define TREND_DOWN_L3   (-3)

#include <EA_ADX.mqh>
#include <EA_CCI.mqh>

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,UpArrowL1Buffer);
   SetIndexBuffer(1,UpArrowL2Buffer);
   SetIndexBuffer(2,UpArrowL3Buffer);
   SetIndexBuffer(3,DownArrowL1Buffer);
   SetIndexBuffer(4,DownArrowL2Buffer);
   SetIndexBuffer(5,DownArrowL3Buffer);
 
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, 1, White);
   SetIndexArrow(0,234);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 1, LightPink);
   SetIndexArrow(1,232);
   SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, 1, OrangeRed);
   SetIndexArrow(2,233);
      
   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 1, White);
   SetIndexArrow(3,233);
   SetIndexStyle(4, DRAW_ARROW, STYLE_SOLID, 1, LightBlue);
   SetIndexArrow(4,231);
   SetIndexStyle(5, DRAW_ARROW, STYLE_SOLID, 1, RoyalBlue);
   SetIndexArrow(5,234); 
//---
   return(INIT_SUCCEEDED);
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
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;

   for( int i=0; i<limit; i++ )
   {
      int upTrand, downTrend;
      
      calcTrendRate( upTrand, downTrend, i );
      switch ( upTrand )
      {
         case TREND_UP_L3:
            UpArrowL3Buffer[i] = high[i];
            UpArrowL2Buffer[i] = EMPTY_VALUE;
            UpArrowL1Buffer[i] = EMPTY_VALUE;
            break;
         case TREND_UP_L2:
            UpArrowL3Buffer[i] = EMPTY_VALUE;
            UpArrowL2Buffer[i] = high[i];
            UpArrowL1Buffer[i] = EMPTY_VALUE;
            break;
         case TREND_UP_L1:
            UpArrowL3Buffer[i] = EMPTY_VALUE;
            UpArrowL2Buffer[i] = EMPTY_VALUE;
            UpArrowL1Buffer[i] = high[i];
            break;
         default:
            UpArrowL3Buffer[i] = EMPTY_VALUE;
            UpArrowL2Buffer[i] = EMPTY_VALUE;
            UpArrowL1Buffer[i] = EMPTY_VALUE;
            break;
      }
      
      switch ( downTrend )
      {
         case TREND_DOWN_L3:
            DownArrowL3Buffer[i] = low[i];
            DownArrowL2Buffer[i] = EMPTY_VALUE;
            DownArrowL1Buffer[i] = EMPTY_VALUE;
            break;
         case TREND_DOWN_L2:
            DownArrowL3Buffer[i] = EMPTY_VALUE;
            DownArrowL2Buffer[i] = low[i];
            DownArrowL1Buffer[i] = EMPTY_VALUE;
            break;
         case TREND_DOWN_L1:
            DownArrowL3Buffer[i] = EMPTY_VALUE;
            DownArrowL2Buffer[i] = EMPTY_VALUE;
            DownArrowL1Buffer[i] = low[i];
            break;
         default:
            DownArrowL3Buffer[i] = EMPTY_VALUE;
            DownArrowL2Buffer[i] = EMPTY_VALUE;
            DownArrowL1Buffer[i] = EMPTY_VALUE;
            break;           
      }
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+
//| calculate the trend rate                                         |
//+------------------------------------------------------------------+
void calcTrendRate( int& upTrand,int& downTrand, int shift )
{
   int upCount = 0;
   int downCount = 0;
   
   const double chackNum = 2.0;

   // ***** get trend information *****
   int adxTrend = EA_getTrendOfADX( 0, 2, shift );
   countTrend( adxTrend, upCount, downCount );

   int cciTrend = EA_getTrendOfCCI( 0, 3, shift );
   countTrend( cciTrend, upCount, downCount );
   
   // ***** calcarate trend rate *****
   double upTrendRate = (double)(upCount) / chackNum;
   double downTrendRate = (double)(downCount) / chackNum;

   
   // ***** judge trend *****
   if ( upTrendRate >= 1.0 ) {
      upTrand = TREND_UP_L3;
   }
   else if ( upTrendRate >= 0.5 ) {
      upTrand = TREND_UP_L2;
   }
   else if ( upTrendRate >= 0.2 ) {
      upTrand = TREND_UP_L1;
   }
   else {
      upTrand = TREND_NONE;
   }

   if ( downTrendRate >= 1.0 ) {
      downTrand = TREND_DOWN_L3;
   }
   else if ( downTrendRate >= 0.5 ) {
      downTrand = TREND_DOWN_L2;
   }
   else if ( downTrendRate >= 0.2 ) {
      downTrand = TREND_DOWN_L1;
   }
   else {
      downTrand = TREND_NONE;
   }
}

//+------------------------------------------------------------------+
//| Subfunction for counting the trend                               |
//+------------------------------------------------------------------+
void countTrend( const int trend, int& upCount, int& downCount )
{
   switch (trend)
   {
      case EA_TREND_UP:
         upCount++;
         break;
      case EA_TREND_DOWN:
         downCount++;
         break;
      default:
         break;
   }
}
//+------------------------------------------------------------------+
