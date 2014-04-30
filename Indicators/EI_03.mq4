//+------------------------------------------------------------------+
//|                                                        EI_03.mq4 |
//|                                             Copyright 2014, eita |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, eita"
#property link      ""
#property version   "1.02"
#property strict
#property indicator_separate_window
#property indicator_minimum 1
#property indicator_maximum 2.5
#property indicator_buffers 9
#property indicator_plots   9

//--- plot ADX_UP
#property indicator_label1  "ADX_UP"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot ADX_DOWN
#property indicator_label2  "ADX_DOWN"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRoyalBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot ADX_WAIT
#property indicator_label3  "ADX_WAIT"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrYellow
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

//--- plot CCI_UP
#property indicator_label4  "CCI_UP"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrOrangeRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot CCI_DOWN
#property indicator_label5  "CCI_DOWN"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrRoyalBlue
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot CCI_WAIT
#property indicator_label6  "CCI_WAIT"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrYellow
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1

//--- plot MAvsMA_UP
#property indicator_label7  "MAvsMA_UP"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrOrangeRed
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot MAvsMA_DOWN
#property indicator_label8  "MAvsMA_DOWN"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrRoyalBlue
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- plot MAvsMA_WAIT
#property indicator_label9  "MAvsMA_WAIT"
#property indicator_type9   DRAW_ARROW
#property indicator_color9  clrYellow
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1

//--- indicator buffers
double         ADX_UP_Buffer[];
double         ADX_DOWN_Buffer[];
double         ADX_WAIT_Buffer[];
double         CCI_UP_Buffer[];
double         CCI_DOWN_Buffer[];
double         CCI_WAIT_Buffer[];
double         MAvsMA_UP_Buffer[];
double         MAvsMA_DOWN_Buffer[];
double         MAvsMA_WAIT_Buffer[];

//--- object name
string obj_ADX = "object_title_ADX";
string obj_CCI = "object_title_CCI";
string obj_MAvsMA = "object_title_MAvsMA";

//--- defines
#define ADX_TITLE_POS      (1.25)
#define ADX_LINE_POS       (1.2)
#define CCI_TITLE_POS      (1.75)
#define CCI_LINE_POS       (1.7)
#define MAVSMA_TITLE_POS   (2.25)
#define MAVSMA_LINE_POS    (2.2)

//--- import function
#include <EA_MAvsMA.mqh>
#include <EA_ADX.mqh>
#include <EA_CCI.mqh>

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ADX_UP_Buffer);
   SetIndexBuffer(1,ADX_DOWN_Buffer);
   SetIndexBuffer(2,ADX_WAIT_Buffer);
   SetIndexBuffer(3,CCI_UP_Buffer);
   SetIndexBuffer(4,CCI_DOWN_Buffer);
   SetIndexBuffer(5,CCI_WAIT_Buffer);
   SetIndexBuffer(6,MAvsMA_UP_Buffer);
   SetIndexBuffer(7,MAvsMA_DOWN_Buffer);
   SetIndexBuffer(8,MAvsMA_WAIT_Buffer);

//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, 1, clrOrangeRed);
   SetIndexArrow(0,110);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 1, clrRoyalBlue);
   SetIndexArrow(1,110);
   SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, 1, clrYellow);
   SetIndexArrow(2,110);
   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 1, clrOrangeRed);
   SetIndexArrow(3,110);
   SetIndexStyle(4, DRAW_ARROW, STYLE_SOLID, 1, clrRoyalBlue);
   SetIndexArrow(4,110);
   SetIndexStyle(5, DRAW_ARROW, STYLE_SOLID, 1, clrYellow);
   SetIndexArrow(5,110);
   SetIndexStyle(6, DRAW_ARROW, STYLE_SOLID, 1, clrOrangeRed);
   SetIndexArrow(6,110);
   SetIndexStyle(7, DRAW_ARROW, STYLE_SOLID, 1, clrRoyalBlue);
   SetIndexArrow(7,110);
   SetIndexStyle(8, DRAW_ARROW, STYLE_SOLID, 1, clrYellow);
   SetIndexArrow(8,110);
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator destructor function                             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(WindowOnDropped());
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
   drawTitle();

   // draw line
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;

   for( int i=0; i<limit; i++ ) {
   
      drawADX(i);
      drawCCI(i);
      drawMAvsMA(i);

   } 
//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| drawing title                                                    |
//+------------------------------------------------------------------+
void drawTitle()
{
   if ( ObjectFind(obj_ADX) < 0 ) {
      ObjectCreate(obj_ADX, OBJ_TEXT, WindowOnDropped(), 0, 0);
   }
   
   if ( ObjectFind(obj_CCI) < 0 ) {
      ObjectCreate(obj_CCI, OBJ_TEXT, WindowOnDropped(), 0, 0);
   }

   if ( ObjectFind(obj_MAvsMA) < 0 ) {
      ObjectCreate(obj_MAvsMA, OBJ_TEXT, WindowOnDropped(), 0, 0);
   }

   ObjectSetText(obj_ADX, "ADX", 10, NULL, White);
   ObjectSetText(obj_CCI, "CCI", 10, NULL, White);
   ObjectSetText(obj_MAvsMA, "MvM", 10, NULL, White);

   // setting object
   datetime dtTitle = Time[0] + ((Time[0]-Time[1])*1);
   ObjectMove(obj_ADX, 0, dtTitle, ADX_TITLE_POS);
   ObjectMove(obj_CCI, 0, dtTitle, CCI_TITLE_POS);
   ObjectMove(obj_MAvsMA, 0, dtTitle, MAVSMA_TITLE_POS);
}

//+------------------------------------------------------------------+
//| drawing line of ADX                                              |
//+------------------------------------------------------------------+
void drawADX(int shift)
{
   int adxTrend = EA_getTrendOfADX( 0, shift );
 
   switch (adxTrend)
   {
      case EA_TREND_UP:
         ADX_UP_Buffer[shift] = ADX_LINE_POS;
         ADX_DOWN_Buffer[shift] = EMPTY_VALUE;
         ADX_WAIT_Buffer[shift] = EMPTY_VALUE;
         break;
      case EA_TREND_DOWN:
         ADX_UP_Buffer[shift] = EMPTY_VALUE;
         ADX_DOWN_Buffer[shift] = ADX_LINE_POS;
         ADX_WAIT_Buffer[shift] = EMPTY_VALUE;
         break;
      default:
         ADX_UP_Buffer[shift] = EMPTY_VALUE;
         ADX_DOWN_Buffer[shift] = EMPTY_VALUE;
         ADX_WAIT_Buffer[shift] = ADX_LINE_POS;
         break;
   }
}

//+------------------------------------------------------------------+
//| drawing line of CCI                                              |
//+------------------------------------------------------------------+
void drawCCI(int shift)
{
   int cciTrend = EA_getTrendOfCCI( 0, shift );

   switch (cciTrend)
   {
      case EA_TREND_UP:
         CCI_UP_Buffer[shift] = CCI_LINE_POS;
         CCI_DOWN_Buffer[shift] = EMPTY_VALUE;
         CCI_WAIT_Buffer[shift] = EMPTY_VALUE;
         break;
      case EA_TREND_DOWN:
         CCI_UP_Buffer[shift] = EMPTY_VALUE;
         CCI_DOWN_Buffer[shift] = CCI_LINE_POS;
         CCI_WAIT_Buffer[shift] = EMPTY_VALUE;
         break;
      default:
         CCI_UP_Buffer[shift] = EMPTY_VALUE;
         CCI_DOWN_Buffer[shift] = EMPTY_VALUE;
         CCI_WAIT_Buffer[shift] = CCI_LINE_POS;
         break;
   }
}

//+------------------------------------------------------------------+
//| drawing line of MAvsMA                                           |
//+------------------------------------------------------------------+
void drawMAvsMA(int shift)
{
   int mavsmaTrend = EA_getTrendOfMAvsMA( 0, shift );

   switch (mavsmaTrend)
   {
      case EA_TREND_UP:
         MAvsMA_UP_Buffer[shift] = MAVSMA_LINE_POS;
         MAvsMA_DOWN_Buffer[shift] = EMPTY_VALUE;
         MAvsMA_WAIT_Buffer[shift] = EMPTY_VALUE;
         break;
      case EA_TREND_DOWN:
         MAvsMA_UP_Buffer[shift] = EMPTY_VALUE;
         MAvsMA_DOWN_Buffer[shift] = MAVSMA_LINE_POS;
         MAvsMA_WAIT_Buffer[shift] = EMPTY_VALUE;
         break;
      default:
         MAvsMA_UP_Buffer[shift] = EMPTY_VALUE;
         MAvsMA_DOWN_Buffer[shift] = EMPTY_VALUE;
         MAvsMA_WAIT_Buffer[shift] = MAVSMA_LINE_POS;
         break;
   }
}
//+------------------------------------------------------------------+
