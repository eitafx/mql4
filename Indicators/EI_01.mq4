//+------------------------------------------------------------------+
//|                                                        EI_01.mq4 |
//|                                             Copyright 2014, eita |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, eita"
#property link      ""
#property version   "1.01"
#property strict
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   9
//--- plot cur_short
#property indicator_label1  "cur_short"
#property indicator_type1   DRAW_ARROW
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot cur_medium
#property indicator_label2  "cur_medium"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRoyalBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot cur_long
#property indicator_label3  "cur_long"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrWhite
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot mt_5min
#property indicator_label4  "mt_5min"
#property indicator_type4   DRAW_LINE
#property indicator_color4  Tomato
#property indicator_style4  STYLE_DOT
#property indicator_width4  1
//--- plot mt_15min
#property indicator_label5  "mt_15min"
#property indicator_type5   DRAW_LINE
#property indicator_color5  MediumPurple
#property indicator_style5  STYLE_DOT
#property indicator_width5  1
//--- plot mt_30min
#property indicator_label6  "mt_30min"
#property indicator_type6   DRAW_LINE
#property indicator_color6  CornflowerBlue
#property indicator_style6  STYLE_DOT
#property indicator_width6  1
//--- plot mt_1hour
#property indicator_label7  "mt_1hour"
#property indicator_type7   DRAW_LINE
#property indicator_color7  SandyBrown
#property indicator_style7  STYLE_DOT
#property indicator_width7  1
//--- plot mt_4hour
#property indicator_label8  "mt_4hour"
#property indicator_type8   DRAW_LINE
#property indicator_color8  HotPink
#property indicator_style8  STYLE_DOT
#property indicator_width8  1
//--- plot mt_1day
#property indicator_label9  "mt_1day"
#property indicator_type9   DRAW_LINE
#property indicator_color9  LightGreen
#property indicator_style9  STYLE_DOT
#property indicator_width9  1
//--- input parameters
input int      Input_cu_period_short=21;
input int      Input_cu_period_medium=89;
input int      Input_cu_period_long=200;
input string   note_mt="When you don't want to draw the line, set 0.";
input int      Input_mt_period_5min=21;
input int      Input_mt_period_15min=21;
input int      Input_mt_period_30min=21;
input int      Input_mt_period_1hour=21;
input int      Input_mt_period_4hour=21;
input int      Input_mt_period_1day=21;

//--- indicator buffers
double         cur_shortBuffer[];
double         cur_mediumBuffer[];
double         cur_longBuffer[];
double         mt_5minBuffer[];
double         mt_15minBuffer[];
double         mt_30minBuffer[];
double         mt_1hourBuffer[];
double         mt_4hourBuffer[];
double         mt_1dayBuffer[];

bool           flagRedraw;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,cur_shortBuffer);
   SetIndexBuffer(1,cur_mediumBuffer);
   SetIndexBuffer(2,cur_longBuffer);
   SetIndexBuffer(3,mt_5minBuffer);
   SetIndexBuffer(4,mt_15minBuffer);
   SetIndexBuffer(5,mt_30minBuffer);
   SetIndexBuffer(6,mt_1hourBuffer);
   SetIndexBuffer(7,mt_4hourBuffer);
   SetIndexBuffer(8,mt_1dayBuffer);
   
   flagRedraw = false;
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
   if ( (flagRedraw == true) || (tick_volume[0] == 1) ){
      flagRedraw = false;
      limit = Bars; 
   }

   int idx_5min = 0;
   int idx_15min = 0;
   int idx_30min = 0;
   int idx_1hour = 0;
   int idx_4hour = 0;
   int idx_1day = 0;

   for( int i=0; i<limit; i++ )
   {    
      cur_shortBuffer[i]   = iMA( NULL, 0, Input_cu_period_short,   0, MODE_SMA,PRICE_CLOSE, i );
      cur_mediumBuffer[i]  = iMA( NULL, 0, Input_cu_period_medium,  0, MODE_SMA,PRICE_CLOSE, i );
      cur_longBuffer[i]    = iMA( NULL, 0, Input_cu_period_long,    0, MODE_SMA,PRICE_CLOSE, i );

      idx_5min = calcIndexForMT( PERIOD_M5, i, idx_5min );
      if ( (Input_mt_period_5min != 0) && (idx_5min >= 0) ) {
         mt_5minBuffer[i] = iMA( NULL, PERIOD_M5, Input_mt_period_5min, 0, MODE_SMA,PRICE_CLOSE, idx_5min );
      }
      else {
         mt_5minBuffer[i] = EMPTY_VALUE;
      }
      
      idx_15min = calcIndexForMT( PERIOD_M15, i, idx_15min );
      if ( (Input_mt_period_15min != 0) && (idx_15min >= 0) ) {
         mt_15minBuffer[i] = iMA( NULL, PERIOD_M15, Input_mt_period_15min, 0, MODE_SMA,PRICE_CLOSE, idx_15min );
      }
      else {
         mt_15minBuffer[i] = EMPTY_VALUE;
      }
      
      idx_30min = calcIndexForMT( PERIOD_M30, i, idx_30min );
      if ( (Input_mt_period_30min != 0) && (idx_30min >= 0) ) {
         mt_30minBuffer[i] = iMA( NULL, PERIOD_M30, Input_mt_period_30min, 0, MODE_SMA,PRICE_CLOSE, idx_30min );
      }
      else {
         mt_30minBuffer[i] = EMPTY_VALUE;
      }
      
      idx_1hour = calcIndexForMT( PERIOD_H1, i, idx_1hour );
      if ( (Input_mt_period_1hour != 0) && (idx_1hour >= 0) ) {
         mt_1hourBuffer[i] = iMA( NULL, PERIOD_H1, Input_mt_period_1hour, 0, MODE_SMA,PRICE_CLOSE, idx_1hour );
      }
      else {
         mt_1hourBuffer[i] = EMPTY_VALUE;
      }
      
      idx_4hour = calcIndexForMT( PERIOD_H4, i, idx_4hour );
      if ( (Input_mt_period_4hour != 0) && (idx_4hour >= 0) ) {
         mt_4hourBuffer[i] = iMA( NULL, PERIOD_H4, Input_mt_period_4hour, 0, MODE_SMA,PRICE_CLOSE, idx_4hour );
      }
      else {
         mt_4hourBuffer[i] = EMPTY_VALUE;
      }
      
      idx_1day = calcIndexForMT( PERIOD_D1, i, idx_1day );
      if ( (Input_mt_period_1day != 0) && (idx_1day >= 0) ) {
         mt_1dayBuffer[i] = iMA( NULL, PERIOD_D1, Input_mt_period_1day, 0, MODE_SMA,PRICE_CLOSE, idx_1day );
      }
      else {
         mt_1dayBuffer[i] = EMPTY_VALUE;
      }
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| calculate the index for multi time                               |
//+------------------------------------------------------------------+
int calcIndexForMT(const int timeframe, const int shift, const int calcIndexShift)
{
   int calcIndex = calcIndexShift;
   
   if ( calcIndexShift >=  0 ) {
      datetime timeArray[];
   
      int result = ArrayCopySeries( timeArray, MODE_TIME, Symbol(), timeframe  );
      if (result == ERR_HISTORY_WILL_UPDATED) {
         flagRedraw = True;
         calcIndex = -1;
      }
      else {
         while(1)
         {
            if (Time[shift]<timeArray[calcIndex]) {
               if ( ArraySize(timeArray) > (calcIndex+1) ) {
                  calcIndex++;
               }
               else {
                  calcIndex = -1;
                  break;
               }
            }
            else {
               break;
            }
         }
      }
    }

   return calcIndex;
}