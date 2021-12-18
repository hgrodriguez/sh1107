--===========================================================================
--
--  This program implements a demo program for the SH1107 OLED driver.
--     It is implemented on a Raspberry Pico.
--
--===========================================================================
--
--  Copyright 2021 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--

with HAL;
with HAL.GPIO;
with HAL.Bitmap;
with HAL.Framebuffer;

with RP.Clock;
with RP.Device;
with RP.I2C_Master;
with RP.GPIO;
with RP.Timer;

with Pico;

with SH1107;

procedure Example_Pico is

   type Demos_Available is (Show_All,
                            White_Background_With_Black_Rectangle_Full_Screen,
                            Black_Background_With_White_Rectangle_Full_Screen,
                            White_Background_4_Black_Corners,
                            Black_Background_4_White_Corners,
                            Black_Background_White_Geometry,
                            White_Background_Black_Geometry,
                            White_Diagonal_Line_On_Black,
                            Black_Diagonal_Line_On_White
                           );

   DEMO_SELECTED : constant Demos_Available
     := Show_All;

   My_Color_Mode : HAL.Framebuffer.FB_Color_Mode;

   My_I2C : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2C_0;

   Another_Timer    : RP.Timer.Delays;
   Initialize_Timer : aliased RP.Timer.Delays;
   My_Timer          : RP.Timer.Delays;

   My_Hidden_Buffer : HAL.Bitmap.Any_Bitmap_Buffer;

   THE_WIDTH                : constant Positive := 128;
   THE_HEIGHT               : constant Positive := 128;
   THE_BUFFER_SIZE_IN_BYTES : constant Positive
     := (THE_WIDTH * THE_HEIGHT) / 8;
   THE_LAYER                : constant Positive := 1;

   My_SH1107_Screen  : SH1107.SH1107_Screen (THE_BUFFER_SIZE_IN_BYTES,
                                             THE_WIDTH,
                                             THE_HEIGHT,
                                             Port => My_I2C'Access,
                                             Address => 16#3C#);
   Corner_0_0        : constant HAL.Bitmap.Point := (0, 0);
   Corner_1_1        : constant HAL.Bitmap.Point := (1, 1);
   Corner_0_127      : constant HAL.Bitmap.Point := (0, THE_HEIGHT - 1);
   Corner_127_0      : constant HAL.Bitmap.Point := (THE_WIDTH - 1, 0);
   Corner_127_127    : constant HAL.Bitmap.Point := (THE_WIDTH - 1,
                                                     THE_HEIGHT - 1);
   My_Area           : constant HAL.Bitmap.Rect := (Position => Corner_0_0,
                                                    Width => THE_WIDTH - 1,
                                                    Height => THE_HEIGHT - 1);

   procedure Initialize_Device;
   procedure Initialize_I2C_0;
   procedure Use_SH1107;
   procedure P_White_Background_With_Black_Rectangle_Full_Screen;
   procedure P_Black_Background_With_White_Rectangle_Full_Screen;
   procedure P_White_Background_4_Black_Corners;
   procedure P_Black_Background_4_White_Corners;

   procedure P_Black_Background_White_Geometry;
   procedure P_White_Background_Black_Geometry;

   procedure P_White_Diagonal_Line_On_Black;
   procedure P_Black_Diagonal_Line_On_White;

   procedure P_White_Background_With_Black_Rectangle_Full_Screen is
   begin
      --  White_Background_With_Black_Rectangle_Full_Screen
      My_Hidden_Buffer.Set_Source (Native => 1);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => My_SH1107_Screen,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Draw_Rect (Area      => My_Area);
      SH1107.Update_Layer (This      => My_SH1107_Screen,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
   end P_White_Background_With_Black_Rectangle_Full_Screen;

   procedure P_Black_Background_With_White_Rectangle_Full_Screen is
   begin
      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => My_SH1107_Screen,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);

      My_Hidden_Buffer.Set_Source (Native => 1);
      My_Hidden_Buffer.Draw_Rect (Area      => My_Area);
      SH1107.Update_Layer (This      => My_SH1107_Screen,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
   end P_Black_Background_With_White_Rectangle_Full_Screen;

   procedure P_White_Background_4_Black_Corners is
   begin
      My_Hidden_Buffer.Set_Source (Native => 1);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => My_SH1107_Screen,
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
      SH1107.Update_Layer (This      => My_SH1107_Screen,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => My_SH1107_Screen,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
   end P_White_Background_4_Black_Corners;

   procedure P_Black_Background_4_White_Corners is
   begin
      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => My_SH1107_Screen,
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
      SH1107.Update_Layer (This      => My_SH1107_Screen,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
      My_Hidden_Buffer.Set_Source (Native => 1);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => My_SH1107_Screen,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
   end P_Black_Background_4_White_Corners;

   My_Circle_Center : constant HAL.Bitmap.Point := (X => 64, Y => 38);
   My_Circle_Radius : constant Natural := 10;
   My_Rectangle : constant HAL.Bitmap.Rect := (Position => (X => 38, Y => 78),
                                      Width => 20,
                                      Height => 10);

   procedure P_Black_Background_White_Geometry is
   begin
      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => My_SH1107_Screen,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
      My_Hidden_Buffer.Set_Source (Native => 1);
      My_Hidden_Buffer.Draw_Circle (Center => My_Circle_Center,
                                    Radius => My_Circle_Radius);
      My_Hidden_Buffer.Draw_Rounded_Rect (Area      => My_Rectangle,
                                          Radius    => 4);
      SH1107.Update_Layer (This      => My_SH1107_Screen,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => My_SH1107_Screen,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
   end P_Black_Background_White_Geometry;

   procedure P_White_Background_Black_Geometry is
   begin
      My_Hidden_Buffer.Set_Source (Native => 1);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => My_SH1107_Screen,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Draw_Circle (Center => My_Circle_Center,
                                    Radius => My_Circle_Radius);
      My_Hidden_Buffer.Draw_Rounded_Rect (Area      => My_Rectangle,
                                          Radius    => 4);
      SH1107.Update_Layer (This      => My_SH1107_Screen,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
      My_Hidden_Buffer.Set_Source (Native => 1);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => My_SH1107_Screen,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
   end P_White_Background_Black_Geometry;

   procedure P_White_Diagonal_Line_On_Black is
   begin
      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => My_SH1107_Screen,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);

      My_Hidden_Buffer.Set_Source (Native => 1);
      My_Hidden_Buffer.Draw_Line (Start     => Corner_0_0,
                                  Stop      => Corner_127_127);
      SH1107.Update_Layer (This      => My_SH1107_Screen,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
   end P_White_Diagonal_Line_On_Black;

   procedure P_Black_Diagonal_Line_On_White is
   begin
      My_Hidden_Buffer.Set_Source (Native => 1);
      My_Hidden_Buffer.Fill;
      SH1107.Update_Layer (This      => My_SH1107_Screen,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);

      My_Hidden_Buffer.Set_Source (Native => 0);
      My_Hidden_Buffer.Draw_Line (Start     => Corner_0_0,
                                  Stop      => Corner_127_127);
      SH1107.Update_Layer (This      => My_SH1107_Screen,
                           Layer     => THE_LAYER);
      RP.Timer.Delay_Seconds (This => Another_Timer,
                              S    => 1);
   end P_Black_Diagonal_Line_On_White;

   procedure Initialize_Device is
   begin
      RP.Clock.Initialize (Pico.XOSC_Frequency);
      RP.Clock.Enable (RP.Clock.PERI);
      RP.Device.Timer.Enable;
      RP.Device.Timer.Enable;
      RP.Timer.Enable (This => My_Timer);
      RP.GPIO.Enable;
      Pico.LED.Configure (RP.GPIO.Output);

      RP.Timer.Enable (This => Another_Timer);

      RP.Timer.Enable (This => Initialize_Timer);
   end Initialize_Device;

   procedure Initialize_I2C_0 is
      SDA     : RP.GPIO.GPIO_Point renames Pico.GP0;
      SCL     : RP.GPIO.GPIO_Point renames Pico.GP1;
   begin
      SDA.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up, RP.GPIO.I2C);
      SCL.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up, RP.GPIO.I2C);
      My_I2C.Enable (100_000);
   end Initialize_I2C_0;

   procedure Use_SH1107 is
   begin
      SH1107.Initialize (This       => My_SH1107_Screen);
      if not SH1107.Initialized (This => My_SH1107_Screen) then
         Pico.LED.Clear;
      end if;

      My_Color_Mode := SH1107.Color_Mode (This  => My_SH1107_Screen,
                                          Layer => THE_LAYER);

      SH1107.Initialize_Layer (This   => My_SH1107_Screen,
                               Layer  => THE_LAYER,
                               Mode   => My_Color_Mode);

      My_Hidden_Buffer := SH1107.Hidden_Buffer (This  => My_SH1107_Screen,
                                                Layer => THE_LAYER);

      loop
         case DEMO_SELECTED is
            when Show_All =>
               P_White_Background_With_Black_Rectangle_Full_Screen;
               P_Black_Background_With_White_Rectangle_Full_Screen;
               P_White_Background_4_Black_Corners;
               P_Black_Background_4_White_Corners;
               P_Black_Background_White_Geometry;
               P_White_Background_Black_Geometry;
               P_White_Diagonal_Line_On_Black;
               P_Black_Diagonal_Line_On_White;
            when White_Background_With_Black_Rectangle_Full_Screen =>
               P_White_Background_With_Black_Rectangle_Full_Screen;
            when Black_Background_With_White_Rectangle_Full_Screen =>
               P_Black_Background_With_White_Rectangle_Full_Screen;
            when White_Background_4_Black_Corners =>
               P_White_Background_4_Black_Corners;
            when Black_Background_4_White_Corners =>
               P_Black_Background_4_White_Corners;
            when Black_Background_White_Geometry =>
               P_Black_Background_White_Geometry;
            when White_Background_Black_Geometry =>
               P_White_Background_Black_Geometry;
            when White_Diagonal_Line_On_Black =>
               P_White_Diagonal_Line_On_Black;
            when Black_Diagonal_Line_On_White =>
               P_Black_Diagonal_Line_On_White;
         end case;
      end loop;
   end Use_SH1107;

begin
   Initialize_Device;
   Pico.LED.Set;
   Initialize_I2C_0;

   Use_SH1107;

end Example_Pico;
