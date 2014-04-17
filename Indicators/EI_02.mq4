//+------------------------------------------------------------------+
//|                                                        EI_02.mq4 |
//|                                             Copyright 2014, eita |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, eita"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- plot UpArrow
#property indicator_label1  "UpArrow"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "DownArrow"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- indicator buffers
double         UpArrowBuffer[];
double         DownArrowBuffer[];

#include <EA_ADX.mqh>
#include <EA_CCI.mqh>

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,UpArrowBuffer);
   SetIndexBuffer(1,DownArrowBuffer);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW

   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, 1, OrangeRed);
   SetIndexArrow(0,233);
   
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 1, RoyalBlue);
   SetIndexArrow(1,234);

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
      int trend = checkTrend( i );
      switch (trend)
      {
      case EA_TREND_UP:
         UpArrowBuffer[i] = high[i];
         DownArrowBuffer[i] = EMPTY_VALUE;
         break;
      case EA_TREND_DOWN:
         UpArrowBuffer[i] = EMPTY_VALUE;
         DownArrowBuffer[i] = low[i];
         break;
      default:
         UpArrowBuffer[i] = EMPTY_VALUE;
         DownArrowBuffer[i] = EMPTY_VALUE;
         break;
      }
   }
   

//--- return value of prev_calculated for next call
   return(rates_total);
}

int checkTrend( int shift )
{
   int upCount = 0;
   int downCount = 0;

   // ***** get trend information *****
   int adxTrend = EA_getTrendOfADX( 0, 3, shift );
   countTrend( adxTrend, upCount, downCount );

   int cciTrend = EA_getTrendOfCCI( 0, 2, shift );
   countTrend( adxTrend, upCount, downCount );
   
   // ***** judge trend *****
   int resTrend = EA_TREND_STAY;
   if ( (upCount > downCount) && (downCount<=0) ) {
      resTrend = EA_TREND_UP;
   }
   else if ( (downCount > upCount) && (upCount<=0) ) {
      resTrend = EA_TREND_DOWN;
   }
   else {
      resTrend = EA_TREND_STAY;
   }
   
   return (resTrend);
}

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
