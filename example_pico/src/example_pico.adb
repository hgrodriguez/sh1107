--===========================================================================
--
--  This program implements a demo program for the SH1107 OLED driver.
--     It is implemented on a Raspberry Pico.
--
--===========================================================================
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--

with HAL;
with HAL.Bitmap;
with HAL.Framebuffer;
with HAL.GPIO;
with HAL.SPI;

with RP.Clock;
with RP.Device;
with RP.GPIO;
with RP.I2C_Master;
with RP.SPI;
with RP.Timer;

with Pico;

with SH1107;

with Demos;

procedure Example_Pico is

   ORIENTIATION_SELECTED : constant SH1107.SH1107_Orientation := SH1107.Up;

   type Demos_Available is (Show_All,
                            Black_Background_White_Arrow,
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

   Initialize_Timer  : aliased RP.Timer.Delays;
   My_Timer          : RP.Timer.Delays;

   THE_LAYER                : constant Positive := 1;

   procedure Initialize_Device is
   begin
      RP.Clock.Initialize (Pico.XOSC_Frequency);
      RP.Clock.Enable (RP.Clock.PERI);
      RP.Device.Timer.Enable;
      RP.Device.Timer.Enable;
      RP.Timer.Enable (This => My_Timer);
      RP.GPIO.Enable;
      Pico.LED.Configure (RP.GPIO.Output);

      RP.Timer.Enable (This => Initialize_Timer);
   end Initialize_Device;

   My_I2C : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2C_0;

   procedure Initialize_I2C_0 is
      SDA     : RP.GPIO.GPIO_Point renames Pico.GP0;
      SCL     : RP.GPIO.GPIO_Point renames Pico.GP1;
   begin
      SDA.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up, RP.GPIO.I2C);
      SCL.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up, RP.GPIO.I2C);
      My_I2C.Enable (100_000);
   end Initialize_I2C_0;

   My_Screen_I2C : SH1107.SH1107_Screen (Connect_With => SH1107.Connect_I2C);

   My_SPI : RP.SPI.SPI_Port renames RP.Device.SPI_0;
   My_CS_SPI : RP.GPIO.GPIO_Point renames Pico.GP15;

   procedure Initialize_SPI_0 is
      SCK    : RP.GPIO.GPIO_Point renames Pico.GP2;
      MOSI   : RP.GPIO.GPIO_Point renames Pico.GP3;
      MISO   : RP.GPIO.GPIO_Point renames Pico.GP4;
      CS     : RP.GPIO.GPIO_Point renames Pico.GP5;
      CONFIG : constant RP.SPI.SPI_Configuration
        := (Role      => RP.SPI.Master,
            Baud      => 10_000_000,
            Data_Size => HAL.SPI.Data_Size_8b,
            Polarity  => RP.SPI.Active_Low,
            Phase     => RP.SPI.Falling_Edge,
            Blocking  => True);

   begin
      SCK.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up, RP.GPIO.SPI);
      MOSI.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up, RP.GPIO.SPI);
      CS.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up, RP.GPIO.SPI);

      MISO.Configure (RP.GPIO.Input, RP.GPIO.Pull_Up, RP.GPIO.SPI);

      My_CS_SPI.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up);

      My_SPI.Configure (CONFIG);
   end Initialize_SPI_0;

   My_Screen_SPI : SH1107.SH1107_Screen (Connect_With => SH1107.Connect_SPI);

   procedure Show_Demo_With (S : in out SH1107.SH1107_Screen) is
   begin
      My_Color_Mode := SH1107.Color_Mode (This  => S);

      SH1107.Initialize_Layer (This   => S,
                               Layer  => THE_LAYER,
                               Mode   => My_Color_Mode);

      for O in SH1107.SH1107_Orientation'First
        ..
          SH1107.SH1107_Orientation'Last loop
         S.Set_Orientation (O);

         case DEMO_SELECTED is
            when Show_All =>
               Demos.Black_Background_White_Arrow (S);
               Demos.White_Background_With_Black_Rectangle_Full_Screen
                 (S);
               Demos.Black_Background_With_White_Rectangle_Full_Screen
                 (S);
               Demos.White_Background_4_Black_Corners
                 (S);

               Demos.Black_Background_4_White_Corners
                 (S);

               Demos.Black_Background_White_Geometry
                 (S);

               Demos.White_Background_Black_Geometry
                 (S);

               Demos.White_Diagonal_Line_On_Black
                 (S);

               Demos.Black_Diagonal_Line_On_White
                 (S);

            when White_Background_With_Black_Rectangle_Full_Screen =>
               Demos.White_Background_With_Black_Rectangle_Full_Screen
                 (S);
            when Black_Background_With_White_Rectangle_Full_Screen =>
               Demos.Black_Background_With_White_Rectangle_Full_Screen
                 (S);
            when White_Background_4_Black_Corners =>
               Demos.White_Background_4_Black_Corners
                 (S);

            when Black_Background_4_White_Corners =>
               Demos.Black_Background_4_White_Corners
                 (S);

            when Black_Background_White_Geometry =>
               Demos.Black_Background_White_Geometry
                 (S);

            when White_Background_Black_Geometry =>
               Demos.White_Background_Black_Geometry
                 (S);

            when White_Diagonal_Line_On_Black =>
               Demos.White_Diagonal_Line_On_Black
                 (S);

            when Black_Diagonal_Line_On_White =>
               Demos.Black_Diagonal_Line_On_White
                 (S);

            when Black_Background_White_Arrow =>
               Demos.Black_Background_White_Arrow (S);
         end case;
      end loop;
   end Show_Demo_With;

begin
   Initialize_Device;
   Pico.LED.Set;

   Initialize_I2C_0;
   SH1107.Initialize (This    => My_Screen_I2C,
                      Orientation => ORIENTIATION_SELECTED,
                      Port    => My_I2C'Access,
                      Address => 16#3C#);
   if not SH1107.Initialized (This => My_Screen_I2C) then
      Pico.LED.Clear;
   end if;

   Initialize_SPI_0;
   SH1107.Initialize (This    => My_Screen_SPI,
                      Orientation => ORIENTIATION_SELECTED,
                      Port    => My_SPI'Access,
                      CS_SPI => My_CS_SPI'Access);
   if not SH1107.Initialized (This => My_Screen_SPI) then
      Pico.LED.Clear;
   end if;

   loop
      Show_Demo_With (My_Screen_I2C);
      Show_Demo_With (My_Screen_SPI);
   end loop;

end Example_Pico;
