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

   --     Demos_Selectable : constant Demos.Demo_Array
   --       := (Demos.Black_Background_White_Arrow =>
   --             (True),
   --           Demos.White_Background_With_Black_Rectangle_Full_Screen =>
   --             (False),
   --           Demos.Black_Background_With_White_Rectangle_Full_Screen =>
   --             (False),
   --           Demos.White_Background_4_Black_Corners =>
   --           (False),
   --           Demos.Black_Background_4_White_Corners =>
   --           (False),
   --           Demos.Black_Background_White_Geometry =>
   --           (False),
   --           Demos.White_Background_Black_Geometry =>
   --           (False),
   --           Demos.White_Diagonal_Line_On_Black =>
   --           (False),
   --           Demos.Black_Diagonal_Line_On_White =>
   --             (False)
   --          );
   --
   --  My_Color_Mode : HAL.Framebuffer.FB_Color_Mode;

   --  Trigger button when to act on the screen
   --  This trigger is generated using a function generator
   --    providing a square signal with a settable frequency
   --     Button                : RP.GPIO.GPIO_Point renames Pico.GP16;
   --     Button_State          : Boolean;
   --     procedure Wait_For_Trigger_Fired is
   --     begin
   --        loop
   --           Button_State := RP.GPIO.Get (Button);
   --           exit when Button_State;
   --        end loop;
   --     end Wait_For_Trigger_Fired;
   --     procedure Wait_For_Trigger_Resume is
   --     begin
   --        loop
   --           Button_State := RP.GPIO.Get (Button);
   --           exit when not Button_State;
   --        end loop;
   --     end Wait_For_Trigger_Resume;

   Initialize_Timer      : aliased RP.Timer.Delays;
   My_Timer              : RP.Timer.Delays;

   --   THE_LAYER                : constant Positive := 1;

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
      --        --  define a trigger input to enable oscilloscope tracking
      --        RP.GPIO.Configure (This => Button,
      --                           Mode => RP.GPIO.Input,
      --                           Pull => RP.GPIO.Pull_Down,
      --                           Func => RP.GPIO.SIO);
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

   My_SPI    : RP.SPI.SPI_Port renames RP.Device.SPI_0;
   My_DC_SPI : RP.GPIO.GPIO_Point renames Pico.GP13;

   procedure Initialize_SPI_0 is
      SCK    : RP.GPIO.GPIO_Point renames Pico.GP2;
      MOSI   : RP.GPIO.GPIO_Point renames Pico.GP3;
      MISO   : RP.GPIO.GPIO_Point renames Pico.GP4;
      CS     : RP.GPIO.GPIO_Point renames Pico.GP5;
      DC     : RP.GPIO.GPIO_Point renames My_DC_SPI;
      CONFIG : constant RP.SPI.SPI_Configuration := (Role     => RP.SPI.Master,
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

   --     procedure Show_Demo_With (S : in out SH1107.SH1107_Screen) is
   --     begin
   --        My_Color_Mode := SH1107.Color_Mode (This  => S);
   --
   --        SH1107.Initialize_Layer (This   => S,
   --                                 Layer  => THE_LAYER,
   --                                 Mode   => My_Color_Mode);
   --
   --        for O in SH1107.SH1107_Orientation'First
   --          ..
   --            SH1107.SH1107_Orientation'Last loop
   --           S.Set_Orientation (O);
   --
   --           Demos.Show_Multiple_Demos (S, O, Demos_Selectable);
   --        end loop;
   --     end Show_Demo_With;

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
                      DC_SPI => My_DC_SPI'Access);
   if not SH1107.Initialized (This => My_Screen_SPI) then
      Pico.LED.Clear;
   end if;

   Pico.LED.Set;

   loop
      if False then
         null;
      else

         if True then
            Demos.Show_1_Demo (S    => My_Screen_I2C,
                               O    => SH1107.Up,
                               Demo =>  Demos.Black_Background_White_Arrow);
         end if;
         if True then
            Demos.Show_1_Demo (S    => My_Screen_SPI,
                               O    => SH1107.Up,
                               Demo =>  Demos.Black_Background_White_Arrow);
         end if;
      end if;
   end loop;

end Example_Pico;
