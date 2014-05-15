//+------------------------------------------------------------------+
//|                                                        EI_04.mq4 |
//|                                             Copyright 2014, eita |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, eita"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_minimum 1
#property indicator_maximum 4.0
#property indicator_buffers 12
#property indicator_plots   12

//--- plot 5min_UP
#property indicator_label1  "5min_UP"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot 5min_DOWN
#property indicator_label2  "5min_DOWN"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRoyalBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- plot 15min_UP
#property indicator_label3  "15min_UP"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrOrangeRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot 15min_DOWN
#property indicator_label4  "15min_DOWN"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRoyalBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

//--- plot 30min_UP
#property indicator_label5  "30min_UP"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrOrangeRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot 30min_DOWN
#property indicator_label6  "30min_DOWN"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrRoyalBlue
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1

//--- plot 1h_UP
#property indicator_label7  "1h_UP"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrOrangeRed
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot 1h_DOWN
#property indicator_label8  "1h_DOWN"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrRoyalBlue
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1

//--- plot 4h_UP
#property indicator_label9  "4h_UP"
#property indicator_type9   DRAW_ARROW
#property indicator_color9  clrOrangeRed
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1
//--- plot 4h_DOWN
#property indicator_label10  "4h_DOWN"
#property indicator_type10   DRAW_ARROW
#property indicator_color10  clrRoyalBlue
#property indicator_style10  STYLE_SOLID
#property indicator_width10  1

//--- plot 1d_UP
#property indicator_label11  "1d_UP"
#property indicator_type11   DRAW_ARROW
#property indicator_color11  clrOrangeRed
#property indicator_style11  STYLE_SOLID
#property indicator_width11  1
//--- plot 1d_DOWN
#property indicator_label12  "1d_DOWN"
#property indicator_type12   DRAW_ARROW
#property indicator_color12  clrRoyalBlue
#property indicator_style12  STYLE_SOLID
#property indicator_width12  1

//--- input parameters
input int      prm_Period_5min = 21;
input int      prm_Depth_5min = 1;
input int      prm_Period_15min = 21;
input int      prm_Depth_15min = 1;
input int      prm_Period_30min = 21;
input int      prm_Depth_30min = 1;
input int      prm_Period_1h = 21;
input int      prm_Depth_1h = 1;
input int      prm_Period_4h = 21;
input int      prm_Depth_4h = 1;
input int      prm_Period_1d = 21;
input int      prm_Depth_1d = 1;

//--- indicator buffers
double         Buffer_5min_up[];
double         Buffer_5min_down[];
double         Buffer_15min_up[];
double         Buffer_15min_down[];
double         Buffer_30min_up[];
double         Buffer_30min_down[];
double         Buffer_1h_up[];
double         Buffer_1h_down[];
double         Buffer_4h_up[];
double         Buffer_4h_down[];
double         Buffer_1d_up[];
double         Buffer_1d_down[];

//--- object name
string obj_title_5min = "object_title_5min";
string obj_title_15min = "object_title_15min";
string obj_title_30min = "object_title_30min";
string obj_title_1h = "object_title_1h";
string obj_title_4h = "object_title_4h";
string obj_title_1d = "object_title_1d";

//--- object position
#define TITLE_START         (1.4)
#define LINE_START          (1.2)
#define LINE_OFFSET         (0.5)
#define TITLE_POS_5MIN      (TITLE_START + (LINE_OFFSET * 0))
#define LINE_POS_5MIN       (LINE_START + (LINE_OFFSET * 0))
#define TITLE_POS_15MIN     (TITLE_START + (LINE_OFFSET * 1))
#define LINE_POS_15MIN      (LINE_START + (LINE_OFFSET * 1))
#define TITLE_POS_30MIN     (TITLE_START + (LINE_OFFSET * 2))
#define LINE_POS_30MIN      (LINE_START + (LINE_OFFSET * 2))
#define TITLE_POS_1H        (TITLE_START + (LINE_OFFSET * 3))
#define LINE_POS_1H         (LINE_START + (LINE_OFFSET * 3))
#define TITLE_POS_4H        (TITLE_START + (LINE_OFFSET * 4))
#define LINE_POS_4H         (LINE_START + (LINE_OFFSET * 4))
#define TITLE_POS_1D        (TITLE_START + (LINE_OFFSET * 5))
#define LINE_POS_1D         (LINE_START + (LINE_OFFSET * 5))

#include <EA_stdlib.mqh>
#include <EA_TrendCoefficient.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,Buffer_5min_up);
   SetIndexBuffer(1,Buffer_5min_down);
   SetIndexBuffer(2,Buffer_15min_up);
   SetIndexBuffer(3,Buffer_15min_down);
   SetIndexBuffer(4,Buffer_30min_up);
   SetIndexBuffer(5,Buffer_30min_down);
   SetIndexBuffer(6,Buffer_1h_up);
   SetIndexBuffer(7,Buffer_1h_down);
   SetIndexBuffer(8,Buffer_4h_up);
   SetIndexBuffer(9,Buffer_4h_down);
   SetIndexBuffer(10,Buffer_1d_up);
   SetIndexBuffer(11,Buffer_1d_down);

   
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, 1, clrOrangeRed);
   SetIndexArrow(0,110);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 1, clrRoyalBlue);
   SetIndexArrow(1,110);
   SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, 1, clrOrangeRed);
   SetIndexArrow(2,110);
   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 1, clrRoyalBlue);
   SetIndexArrow(3,110); 
   SetIndexStyle(4, DRAW_ARROW, STYLE_SOLID, 1, clrOrangeRed);
   SetIndexArrow(4,110);
   SetIndexStyle(5, DRAW_ARROW, STYLE_SOLID, 1, clrRoyalBlue);
   SetIndexArrow(5,110);
   SetIndexStyle(6, DRAW_ARROW, STYLE_SOLID, 1, clrOrangeRed);
   SetIndexArrow(6,110);
   SetIndexStyle(7, DRAW_ARROW, STYLE_SOLID, 1, clrRoyalBlue);
   SetIndexArrow(7,110);
   SetIndexStyle(8, DRAW_ARROW, STYLE_SOLID, 1, clrOrangeRed);
   SetIndexArrow(8,110);
   SetIndexStyle(9, DRAW_ARROW, STYLE_SOLID, 1, clrRoyalBlue);
   SetIndexArrow(9,110);
   SetIndexStyle(10, DRAW_ARROW, STYLE_SOLID, 1, clrOrangeRed);
   SetIndexArrow(10,110);
   SetIndexStyle(11, DRAW_ARROW, STYLE_SOLID, 1, clrRoyalBlue);
   SetIndexArrow(11,110);
         
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
    drawTitle();

    int counted_bars=IndicatorCounted();
    if(counted_bars<0) return(-1);
    if(counted_bars>0) counted_bars--;
    int limit=Bars-counted_bars;

    int idx_5min = 0;
    int idx_15min = 0;
    int idx_30min = 0;
    int idx_1hour = 0;
    int idx_4hour = 0;
    int idx_1day = 0;
    
    for( int i=0; i<limit; i++ ) {
    
        drawLine( PERIOD_M5, prm_Period_5min, prm_Depth_5min, i, idx_5min );
        drawLine( PERIOD_M15, prm_Period_15min, prm_Depth_15min, i, idx_15min );
        drawLine( PERIOD_M30, prm_Period_30min, prm_Depth_30min, i, idx_30min );
        drawLine( PERIOD_H1, prm_Period_1h, prm_Depth_1h, i, idx_1hour );
        drawLine( PERIOD_H4, prm_Period_4h, prm_Depth_4h, i, idx_4hour );
        drawLine( PERIOD_D1, prm_Period_1d, prm_Depth_1d, i, idx_1day );
    
    }   
//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| drawing title                                                    |
//+------------------------------------------------------------------+
void drawTitle()
{
   if ( ObjectFind(obj_title_5min) < 0 ) {
      ObjectCreate(obj_title_5min, OBJ_TEXT, WindowOnDropped(), 0, 0);
   }
   
   if ( ObjectFind(obj_title_15min) < 0 ) {
      ObjectCreate(obj_title_15min, OBJ_TEXT, WindowOnDropped(), 0, 0);
   }

   if ( ObjectFind(obj_title_30min) < 0 ) {
      ObjectCreate(obj_title_30min, OBJ_TEXT, WindowOnDropped(), 0, 0);
   }

   if ( ObjectFind(obj_title_1h) < 0 ) {
      ObjectCreate(obj_title_1h, OBJ_TEXT, WindowOnDropped(), 0, 0);
   }
   
   if ( ObjectFind(obj_title_4h) < 0 ) {
      ObjectCreate(obj_title_4h, OBJ_TEXT, WindowOnDropped(), 0, 0);
   }
   
   if ( ObjectFind(obj_title_1d) < 0 ) {
      ObjectCreate(obj_title_1d, OBJ_TEXT, WindowOnDropped(), 0, 0);
   }
   
   
   ObjectSetText(obj_title_5min, "M5", 10, NULL, White);
   ObjectSetText(obj_title_15min, "M15", 10, NULL, White);
   ObjectSetText(obj_title_30min, "M30", 10, NULL, White);
   ObjectSetText(obj_title_1h, "H1", 10, NULL, White);
   ObjectSetText(obj_title_4h, "H4", 10, NULL, White);
   ObjectSetText(obj_title_1d, "D1", 10, NULL, White);


   // setting object
   datetime dtTitle = Time[0] + ((Time[0]-Time[1])*1);
   ObjectMove(obj_title_5min, 0, dtTitle, TITLE_POS_5MIN);
   ObjectMove(obj_title_15min, 0, dtTitle, TITLE_POS_15MIN);
   ObjectMove(obj_title_30min, 0, dtTitle, TITLE_POS_30MIN);
   ObjectMove(obj_title_1h, 0, dtTitle, TITLE_POS_1H);
   ObjectMove(obj_title_4h, 0, dtTitle, TITLE_POS_4H);
   ObjectMove(obj_title_1d, 0, dtTitle, TITLE_POS_1D);
}

//+------------------------------------------------------------------+
//| drawing line                                                     |
//+------------------------------------------------------------------+
void drawLine( const int timeframe,
               const int period,
               const int depth,
               const int shift,
               int& mt_shift )
{
     mt_shift = EA_convertIndexForMT( timeframe, shift, mt_shift );
    double value = EA_getTrendCoefficien( timeframe, period, depth, mt_shift );
    int trend = EA_judgeTrenfForTrendCoefficien( value ) ;

    setLineValue( timeframe, shift, trend );
}

//+------------------------------------------------------------------+
//| choose a line and set a value                                    |
//+------------------------------------------------------------------+
void setLineValue( const int timeframe,
                   const int shift,
                   const int trend )
{
    switch(timeframe)
    {
        case PERIOD_M5:
            setValueToBuffer( Buffer_5min_up[shift], Buffer_5min_down[shift], trend, LINE_POS_5MIN );
            break;
        case PERIOD_M15:
            setValueToBuffer( Buffer_15min_up[shift], Buffer_15min_down[shift], trend, LINE_POS_15MIN );
            break;
        case PERIOD_M30:
            setValueToBuffer( Buffer_30min_up[shift], Buffer_30min_down[shift], trend, LINE_POS_30MIN );
            break;
        case PERIOD_H1:
            setValueToBuffer( Buffer_1h_up[shift], Buffer_1h_down[shift], trend, LINE_POS_1H );
            break;
        case PERIOD_H4:
            setValueToBuffer( Buffer_4h_up[shift], Buffer_4h_down[shift], trend, LINE_POS_4H );
            break;
        case PERIOD_D1:
            setValueToBuffer( Buffer_1d_up[shift], Buffer_1d_down[shift], trend, LINE_POS_1D );
            break;
        default:
            break;
    }
}

//+------------------------------------------------------------------+
//| set the value to line buffer                                     |
//+------------------------------------------------------------------+
void setValueToBuffer( double& bufferUp,
                       double& bufferDown,
                       int trend,
                       double pos )
{
    switch (trend)
    {
        case EA_TREND_UP:
            bufferUp = pos;
            bufferDown = EMPTY_VALUE;
            break;
        case EA_TREND_DOWN:
            bufferUp = EMPTY_VALUE;
            bufferDown = pos;
            break;
        default:
            bufferUp = EMPTY_VALUE;
            bufferDown = EMPTY_VALUE;
            break;
    }
}
//+------------------------------------------------------------------+
