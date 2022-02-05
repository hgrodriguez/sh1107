--===========================================================================
--
--  This package is the implementation of the demo package showing examples
--  for the SH1107 OLED controller
--
--===========================================================================
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL;
with HAL.Bitmap;

with RP.Timer;

package body Demos is

   Another_Timer : RP.Timer.Delays;

   THE_LAYER     : constant Positive := 1;

   Corner_0_0        : constant HAL.Bitmap.Point := (0, 0);
   Corner_1_1     : constant HAL.Bitmap.Point := (1, 1);
   Corner_0_127   : constant HAL.Bitmap.Point := (0, SH1107.THE_HEIGHT - 1);
   Corner_127_0   : constant HAL.Bitmap.Point := (SH1107.THE_WIDTH - 1, 0);
   Corner_127_127 : constant HAL.Bitmap.Point := (SH1107.THE_WIDTH - 1,
                                                  SH1107.THE_HEIGHT - 1);
   My_Area       : constant HAL.Bitmap.Rect
     := (Position => Corner_0_0,
         Width => SH1107.THE_WIDTH - 1,
         Height => SH1107.THE_HEIGHT - 1);

   My_Circle_Center : constant HAL.Bitmap.Point := (X => 64, Y => 38);
   My_Circle_Radius : constant Natural := 10;
   My_Rectangle     : constant HAL.Bitmap.Rect
     := (Position => (X => 38, Y => 78),
         Width => 20,
         Height => 10);

   procedure Black_Background_White_Arrow
     (S : in out SH1107.SH1107_Screen) is
      Corners : constant HAL.Bitmap.Point_Array (1 .. 7)
        := (
            1 => (40, 118),
            2 => (86, 118),
            3 => (86, 60),
            4 => (96, 60),
            5 => (63, 10),
            6 => (30, 60),
            7 => (40, 60));
      Start   : HAL.Bitmap.Point;
      Stop    : HAL.Bitmap.Point;

      My_Hidden_Buffer : HAL.Bitmap.Any_Bitmap_Buffer;

   begin
      My_Hidden_Buffer := SH1107.Hidden_Buffer (This  => S,
                                                Layer => THE_LAYER);

      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);

      My_Hidden_Buffer.Set_Source (Native => 1);

      for N in Corners'First .. Corners'Last loop
         Start := Corners (N);
         if N = Corners'Last then
            Stop := Corners (1);
         else
            Stop := Corners (N + 1);
         end if;
         My_Hidden_Buffer.Draw_Line (Start, Stop);
      end loop;

      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
   end Black_Background_White_Arrow;

   procedure White_Background_With_Black_Rectangle_Full_Screen
     (S : in out SH1107.SH1107_Screen) is
      My_Hidden_Buffer : HAL.Bitmap.Any_Bitmap_Buffer;

   begin
      My_Hidden_Buffer := SH1107.Hidden_Buffer (This  => S,
                                                Layer => THE_LAYER);

      My_Hidden_Buffer.Set_Source (Native => 1);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Draw_Rect (Area      => My_Area);
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
   end White_Background_With_Black_Rectangle_Full_Screen;

   procedure Black_Background_With_White_Rectangle_Full_Screen
     (S : in out SH1107.SH1107_Screen) is
      My_Hidden_Buffer : HAL.Bitmap.Any_Bitmap_Buffer;

   begin
      My_Hidden_Buffer := SH1107.Hidden_Buffer (This  => S,
                                                Layer => THE_LAYER);

      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);

      My_Hidden_Buffer.Set_Source (Native => 1);
      My_Hidden_Buffer.Draw_Rect (Area      => My_Area);
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
   end Black_Background_With_White_Rectangle_Full_Screen;

   procedure White_Background_4_Black_Corners
     (S : in out SH1107.SH1107_Screen) is
      My_Hidden_Buffer : HAL.Bitmap.Any_Bitmap_Buffer;

   begin
      My_Hidden_Buffer := SH1107.Hidden_Buffer (This  => S,
                                                Layer => THE_LAYER);

      My_Hidden_Buffer.Set_Source (Native => 1);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
      My_Hidden_Buffer.Set_Pixel (Pt     => Corner_0_0,
                                  Native => 0);
      My_Hidden_Buffer.Set_Pixel (Pt     => Corner_1_1,
                                  Native => 0);
      My_Hidden_Buffer.Set_Pixel (Pt     => Corner_0_127,
                                  Native => 0);
      My_Hidden_Buffer.Set_Pixel (Pt     => Corner_127_0,
                                  Native => 0);
      My_Hidden_Buffer.Set_Pixel (Pt     => Corner_127_127,
                                  Native => 0);
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
   end White_Background_4_Black_Corners;

   procedure Black_Background_4_White_Corners
     (S : in out SH1107.SH1107_Screen) is
      My_Hidden_Buffer : HAL.Bitmap.Any_Bitmap_Buffer;

   begin
      My_Hidden_Buffer := SH1107.Hidden_Buffer (This  => S,
                                                Layer => THE_LAYER);

      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
      My_Hidden_Buffer.Set_Pixel (Pt     => Corner_0_0,
                                  Native => 1);
      My_Hidden_Buffer.Set_Pixel (Pt     => Corner_0_127,
                                  Native => 1);
      My_Hidden_Buffer.Set_Pixel (Pt     => Corner_127_0,
                                  Native => 1);
      My_Hidden_Buffer.Set_Pixel (Pt     => Corner_127_127,
                                  Native => 1);
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
      My_Hidden_Buffer.Set_Source (Native => 1);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
   end Black_Background_4_White_Corners;

   procedure Black_Background_White_Geometry
     (S : in out SH1107.SH1107_Screen) is
      My_Hidden_Buffer : HAL.Bitmap.Any_Bitmap_Buffer;

   begin
      My_Hidden_Buffer := SH1107.Hidden_Buffer (This  => S,
                                                Layer => THE_LAYER);

      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
      My_Hidden_Buffer.Set_Source (Native => 1);
      My_Hidden_Buffer.Draw_Circle (Center => My_Circle_Center,
                                    Radius => My_Circle_Radius);
      My_Hidden_Buffer.Draw_Rounded_Rect (Area      => My_Rectangle,
                                          Radius    => 4);
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
   end Black_Background_White_Geometry;

   procedure White_Background_Black_Geometry
     (S : in out SH1107.SH1107_Screen) is
      My_Hidden_Buffer : HAL.Bitmap.Any_Bitmap_Buffer;

   begin
      My_Hidden_Buffer := SH1107.Hidden_Buffer (This  => S,
                                                Layer => THE_LAYER);

      My_Hidden_Buffer.Set_Source (Native => 1);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Draw_Circle (Center => My_Circle_Center,
                                    Radius => My_Circle_Radius);
      My_Hidden_Buffer.Draw_Rounded_Rect (Area      => My_Rectangle,
                                          Radius    => 4);
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
      My_Hidden_Buffer.Set_Source (Native => 1);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
   end White_Background_Black_Geometry;

   procedure White_Diagonal_Line_On_Black
     (S : in out SH1107.SH1107_Screen) is
      My_Hidden_Buffer : HAL.Bitmap.Any_Bitmap_Buffer;

   begin
      My_Hidden_Buffer := SH1107.Hidden_Buffer (This  => S,
                                                Layer => THE_LAYER);

      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);

      My_Hidden_Buffer.Set_Source (Native => 1);
      My_Hidden_Buffer.Draw_Line (Start     => Corner_0_0,
                                  Stop      => Corner_127_127);
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
   end White_Diagonal_Line_On_Black;

   procedure Black_Diagonal_Line_On_White
     (S : in out SH1107.SH1107_Screen) is
      My_Hidden_Buffer : HAL.Bitmap.Any_Bitmap_Buffer;

   begin
      My_Hidden_Buffer := SH1107.Hidden_Buffer (This  => S,
                                                Layer => THE_LAYER);

      My_Hidden_Buffer.Set_Source (Native => 1);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);

      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Draw_Line (Start     => Corner_0_0,
                                  Stop      => Corner_127_127);
      SH1107.Update_Layer (This      => S,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
   end Black_Diagonal_Line_On_White;

end Demos;
