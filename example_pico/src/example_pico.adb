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

--  with HAL;
--  with HAL.Framebuffer;
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

   Initialize_Timer      : aliased RP.Timer.Delays;

   procedure Initialize_Device is
   begin
      RP.Clock.Initialize (Pico.XOSC_Frequency);
      RP.Clock.Enable (RP.Clock.PERI);
      RP.Device.Timer.Enable;
      RP.Device.Timer.Enable;
      RP.GPIO.Enable;
      Pico.LED.Configure (RP.GPIO.Output);

      RP.Timer.Enable (This => Initialize_Timer);
   end Initialize_Device;

   --========================================================================
   --
   --  I2C Section
   --
   --========================================================================
   My_I2C : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2C_0;

   procedure Initialize_I2C_0 is
      SDA     : RP.GPIO.GPIO_Point renames Pico.GP0;
      SCL     : RP.GPIO.GPIO_Point renames Pico.GP1;
   begin
      SDA.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up, RP.GPIO.I2C);
      SCL.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up, RP.GPIO.I2C);
      My_I2C.Enable (400_000);
   end Initialize_I2C_0;

   My_Screen_I2C : SH1107.SH1107_Screen (Connect_With => SH1107.Connect_I2C);

   --========================================================================
   --
   --  I2C Section
   --
   --========================================================================
   My_SPI    : RP.SPI.SPI_Port renames RP.Device.SPI_0;
   My_DC_SPI : RP.GPIO.GPIO_Point renames Pico.GP13;

   procedure Initialize_SPI_0 is
      SCK    : RP.GPIO.GPIO_Point renames Pico.GP2;
      MOSI   : RP.GPIO.GPIO_Point renames Pico.GP3;
      MISO   : RP.GPIO.GPIO_Point renames Pico.GP4;
      CS     : RP.GPIO.GPIO_Point renames Pico.GP5;
      DC     : RP.GPIO.GPIO_Point renames My_DC_SPI;
      CONFIG : constant RP.SPI.SPI_Configuration
        := (Role     => RP.SPI.Master,
            Baud      => 1_000_000,
            Data_Size => HAL.SPI.Data_Size_8b,
            Polarity  => RP.SPI.Active_Low,
            Phase     => RP.SPI.Rising_Edge,
            Blocking  => True
           );

   begin
      SCK.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up, RP.GPIO.SPI);
      MOSI.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up, RP.GPIO.SPI);
      CS.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up, RP.GPIO.SPI);
      MISO.Configure (RP.GPIO.Input, RP.GPIO.Pull_Up, RP.GPIO.SPI);
      DC.Configure (RP.GPIO.Output, RP.GPIO.Pull_Up);
      My_SPI.Configure (CONFIG);
   end Initialize_SPI_0;

   My_Screen_SPI : SH1107.SH1107_Screen (Connect_With => SH1107.Connect_SPI);

begin
   Initialize_Device;
   --  Show we are alive
   Pico.LED.Set;

   if True then
      Initialize_I2C_0;
      SH1107.Initialize (This    => My_Screen_I2C,
                         Orientation => ORIENTIATION_SELECTED,
                         Port    => My_I2C'Access,
                         Address => 16#3C#);
      if not SH1107.Initialized (This => My_Screen_I2C) then
         --  STOP here
         Pico.LED.Clear;
         loop
            null;
         end loop;
      end if;
   end if;

   if True then
      Initialize_SPI_0;
      SH1107.Initialize (This    => My_Screen_SPI,
                         Orientation => ORIENTIATION_SELECTED,
                         Port    => My_SPI'Access,
                         DC_SPI => My_DC_SPI'Access);
      if not SH1107.Initialized (This => My_Screen_SPI) then
         --  STOP here
         Pico.LED.Clear;
         loop
            null;
         end loop;
      end if;
   end if;

   Pico.LED.Set;

   loop
      for Orientation_To_Use in SH1107.SH1107_Orientation loop
         for Demo_To_Show in Demos.Demos_Available'Range loop
            if True then
               Demos.Show_1_Demo (S    => My_Screen_I2C,
                                  O    => Orientation_To_Use,
                                  Demo => Demo_To_Show);
            end if;
            if True then
               Demos.Show_1_Demo (S    => My_Screen_SPI,
                                  O    => Orientation_To_Use,
                                  Demo => Demo_To_Show);
            end if;
         end loop;
      end loop;
   end loop;

end Example_Pico;
