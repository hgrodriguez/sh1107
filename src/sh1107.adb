--===========================================================================
--
--  This package is the implementation of the SH1107 package
--
--===========================================================================
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--

with SH1107.I2C;
with SH1107.SPI;
with SH1107.Transformer;

package body SH1107 is

   --------------------------------------------------------------------------
   --  Commands
   --------------------------------------------------------------------------
   --  Display On/Off
   CMD_DISPLAY_OFF : constant HAL.UInt8 := 16#AE#;
   CMD_DISPLAY_ON  : constant HAL.UInt8 := 16#AF#;

   --  Setup commands to initialize the display
   CMD_PAGE_ADDRESSING_MODE                  : constant HAL.UInt8 := 16#20#;
   CMD_SET_CONTRAST                          : constant HAL.UInt8 := 16#81#;
   CMD_SEGMENT_REMAP_DOWN                    : constant HAL.UInt8 := 16#A0#;
   CMD_NORMAL_DISPLAY                        : constant HAL.UInt8 := 16#A6#;
   CMD_SET_DISPLAY_OFFSET                    : constant HAL.UInt8 := 16#D3#;
   CMD_COMMON_OUPUT_SCAN_DIRECTION_INCREMENT : constant HAL.UInt8 := 16#C0#;
   CMD_SET_DISPLAY_START_LINE                : constant HAL.UInt8 := 16#DC#;

   --  Memory addressing
   CMD_SET_PAGE_ADDRESS                      : constant HAL.UInt8 := 16#B0#;
   CMD_SET_LOWER_COLUMN_ADDRESS              : constant HAL.UInt8 := 16#00#;
   CMD_SET_HIGHER_COLUMN_ADDRESS             : constant HAL.UInt8 := 16#10#;

   --------------------------------------------------------------------------
   --  Package internal rocedures to write to the device
   --  Implementation at the end of the file.
   --------------------------------------------------------------------------
   --------------------------------------------------------------------------
   --  Writes the
   --    Cmd : to
   --    This : Screen
   procedure Write_Command (This : SH1107_Screen;
                            Cmd  : HAL.UInt8);
   --------------------------------------------------------------------------
   --  Writes the
   --    Data : to
   --    This : Screen
   procedure Write_Data (This : SH1107_Screen;
                         Data : HAL.UInt8_Array);
   --------------------------------------------------------------------------
   --  Writes
   --    Data : as raw pixels to
   --    This : Screen
   procedure Write_Raw_Pixels (This : SH1107_Screen;
                               Data : HAL.UInt8_Array);

   procedure Initialize_Screen (This        : in out SH1107_Screen) is
   begin
      Write_Command (This, CMD_DISPLAY_OFF);
      Write_Command (This, CMD_PAGE_ADDRESSING_MODE);
      Write_Command (This, CMD_SET_DISPLAY_OFFSET);
      Write_Command (This, 16#00#);
      Write_Command (This, CMD_SEGMENT_REMAP_DOWN);
      Write_Command (This, CMD_COMMON_OUPUT_SCAN_DIRECTION_INCREMENT);
      Write_Command (This, CMD_SET_CONTRAST);
      Write_Command (This, CMD_DISPLAY_ON);
      Write_Command (This, CMD_NORMAL_DISPLAY);
      Write_Command (This, CMD_SET_DISPLAY_START_LINE);
      Write_Command (This, 16#00#);
      Write_Command (This, CMD_DISPLAY_ON);
   end Initialize_Screen;

   --------------------------------------------------------------------------
   --  see .ads
   procedure Initialize (This        : in out SH1107_Screen;
                         Orientation : SH1107_Orientation;
                         Port        : not null HAL.I2C.Any_I2C_Port;
                         Address     : HAL.I2C.I2C_Address) is
   begin
      if This.Connect_With /= Connect_I2C then
         raise Program_Error with "Invalid screen parameters, must be I2C!";
      end if;

      This.Orientation := Orientation;
      This.Port_I2C := Port;
      This.Address_I2C := Address;

      Initialize_Screen (This);

      This.Device_Initialized := True;
   end Initialize;

   --------------------------------------------------------------------------
   --  see .ads
   procedure Initialize (This        : in out SH1107_Screen;
                         Orientation : SH1107_Orientation;
                         Port        : not null HAL.SPI.Any_SPI_Port;
                         CS_SPI      : not null HAL.GPIO.Any_GPIO_Point;
                         DC_SPI      : not null HAL.GPIO.Any_GPIO_Point) is
   begin
      if This.Connect_With /= Connect_SPI then
         raise Program_Error with "Invalid screen parameters, must be SPI!";
      end if;

      This.Orientation := Orientation;
      This.Port_SPI := Port;
      This.CS_SPI := CS_SPI;
      This.DC_SPI := DC_SPI;

      Initialize_Screen (This);

      This.Device_Initialized := True;
   end Initialize;

   --------------------------------------------------------------------------
   --  see .ads
   procedure Turn_On (This : SH1107_Screen) is
   begin
      Write_Command (This, CMD_DISPLAY_ON);
   end Turn_On;

   --------------------------------------------------------------------------
   --  see .ads
   procedure Turn_Off (This : SH1107_Screen) is
   begin
      Write_Command (This, CMD_DISPLAY_OFF);
   end Turn_Off;

   --========================================================================
   --
   --  This section is the collection of overriding procedures/functions
   --  from the parent class
   --
   --========================================================================
   procedure Set_Orientation
     (This        : in out SH1107_Screen;
      Orientation : SH1107_Orientation) is
   begin
      This.Orientation := Orientation;
      This.Memory_Layer.Orientation := Orientation;
   end Set_Orientation;

   overriding
   function Supported
     (This : SH1107_Screen;
      Mode : HAL.Framebuffer.FB_Color_Mode) return Boolean is
      pragma Unreferenced (This);
      use HAL.Bitmap;
   begin
      return (Mode = HAL.Bitmap.M_1);
   end Supported;

   overriding
   procedure Set_Orientation
     (This        : in out SH1107_Screen;
      Orientation : HAL.Framebuffer.Display_Orientation) is
      pragma Unreferenced (This);
      pragma Unreferenced (Orientation);
   begin
      null;
   end Set_Orientation;

   overriding
   procedure Set_Mode
     (This    : in out SH1107_Screen;
      Mode    : HAL.Framebuffer.Wait_Mode) is
      pragma Unreferenced (This);
      pragma Unreferenced (Mode);
   begin
      null;
   end Set_Mode;

   overriding
   function Initialized
     (This : SH1107_Screen) return Boolean is
     (This.Device_Initialized);

   overriding
   procedure Set_Background
     (This : SH1107_Screen; R, G, B : HAL.UInt8) is
   begin
      --  Does it make sense when there's no alpha channel...
      raise Program_Error;
   end Set_Background;

   overriding
   procedure Initialize_Layer
     (This   : in out SH1107_Screen;
      Layer  : Positive;
      Mode   : HAL.Framebuffer.FB_Color_Mode;
      X      : Natural := 0;
      Y      : Natural := 0;
      Width  : Positive := Positive'Last;
      Height : Positive := Positive'Last) is
      pragma Unreferenced (X, Y, Width, Height);
      use HAL.Bitmap;
   begin
      if Layer /= 1 or else Mode /= HAL.Bitmap.M_1 then
         raise Program_Error;
      end if;
      This.Memory_Layer.Orientation := This.Orientation;
      This.Memory_Layer.Actual_Width  := This.Width;
      This.Memory_Layer.Actual_Height := This.Height;
      This.Memory_Layer.Addr := This.Memory_Layer.Data'Address;
      This.Memory_Layer.Actual_Color_Mode := Mode;
      This.Layer_Initialized := True;
   end Initialize_Layer;

   overriding
   function Initialized
     (This  : SH1107_Screen;
      Layer : Positive) return Boolean is
   begin
      return Layer = 1 and then This.Layer_Initialized;
   end Initialized;

   overriding
   procedure Update_Layer
     (This      : in out SH1107_Screen;
      Layer     : Positive;
      Copy_Back : Boolean := False) is
      pragma Unreferenced (Copy_Back);
   begin
      if Layer /= 1 then
         raise Program_Error;
      end if;

      This.Write_Raw_Pixels (This.Memory_Layer.Data);
   end Update_Layer;

   overriding
   procedure Update_Layers
     (This : in out SH1107_Screen) is
   begin
      Update_Layer (This, 1);
   end Update_Layers;

   overriding
   function Hidden_Buffer
     (This  : in out SH1107_Screen;
      Layer : Positive := THE_LAYER)
      return not null HAL.Bitmap.Any_Bitmap_Buffer is
   begin
      if Layer /= 1 then
         raise Program_Error with "This screen only supports one layer";
      end if;
      return This.Memory_Layer'Unchecked_Access;
   end Hidden_Buffer;

   overriding
   function Pixel_Size
     (Display : SH1107_Screen;
      Layer   : Positive := THE_LAYER) return Positive is (1);

   --========================================================================
   --
   --  This section is the collection of overriding procedures/functions
   --  from the parent class for the Bitmap Buffer
   --
   --========================================================================
   overriding
   procedure Set_Pixel (Buffer  : in out SH1107_Bitmap_Buffer;
                        Pt      : HAL.Bitmap.Point) is
      Index : constant Natural
        := SH1107.Transformer.Get_Byte_Index (Buffer.Orientation, Pt.X, Pt.Y);
      Byte  : HAL.UInt8 renames Buffer.Data (Buffer.Data'First + Index);
      Bit   : constant HAL.UInt8
        := SH1107.Transformer.Get_Bit_Mask (Buffer.Orientation, Pt.X, Pt.Y);
      use HAL;
   begin
      if Buffer.Native_Source = 0 then
         Byte := Byte and not Bit;
      else
         Byte := Byte or Bit;
      end if;
   end Set_Pixel;

   overriding
   procedure Set_Pixel (Buffer  : in out SH1107_Bitmap_Buffer;
                        Pt      : HAL.Bitmap.Point;
                        Color   : HAL.Bitmap.Bitmap_Color) is
      use HAL.Bitmap;
   begin
      Buffer.Set_Pixel (Pt, (if Color = HAL.Bitmap.Black then 0 else 1));
   end Set_Pixel;

   overriding
   procedure Set_Pixel (Buffer  : in out SH1107_Bitmap_Buffer;
                        Pt      : HAL.Bitmap.Point;
                        Raw     : HAL.UInt32) is
   begin
      Buffer.Native_Source := Raw;
      Buffer.Set_Pixel (Pt);
   end Set_Pixel;

   overriding
   function Pixel (Buffer : SH1107_Bitmap_Buffer;
                   Pt     : HAL.Bitmap.Point) return HAL.Bitmap.Bitmap_Color is
      use HAL;
   begin
      return (if Buffer.Pixel (Pt) = 0 then
                 HAL.Bitmap.Black
              else HAL.Bitmap.White);
   end Pixel;

   overriding
   function Pixel (Buffer : SH1107_Bitmap_Buffer;
                   Pt     : HAL.Bitmap.Point) return HAL.UInt32 is
      Index : constant Natural
        := SH1107.Transformer.Get_Byte_Index (Buffer.Orientation, Pt.X, Pt.Y);
      Byte  : HAL.UInt8 renames Buffer.Data (Buffer.Data'First + Index);
      Bit   : constant HAL.UInt8
        := SH1107.Transformer.Get_Bit_Mask (Buffer.Orientation, Pt.X, Pt.Y);
      use HAL;
   begin
      if (Byte and Bit) /= 0 then
         return 1;
      else
         return 0;
      end if;
   end Pixel;

   overriding
   procedure Fill (Buffer : in out SH1107_Bitmap_Buffer) is
      use HAL;
      Val : constant HAL.UInt8
        := (if Buffer.Native_Source /= 0 then 16#FF# else 0);
   begin
      Buffer.Data := (others => Val);
   end Fill;

   --------------------------------------------------------------------------
   --  Package internal procedures to write to the device
   --------------------------------------------------------------------------
   procedure Write_Command (This : SH1107_Screen;
                            Cmd  : HAL.UInt8) is
   begin
      case This.Connect_With is
         when Connect_I2C =>
            SH1107.I2C.Write_Command (This.Port_I2C, This.Address_I2C, Cmd);
         when Connect_SPI =>
            SH1107.SPI.Write_Command (This.Port_SPI,
                                      This.CS_SPI,
                                      This.DC_SPI,
                                      Cmd);
      end case;
   end Write_Command;

   procedure Write_Data (This : SH1107_Screen;
                         Data : HAL.UInt8_Array) is
      SPI_DATA : HAL.SPI.SPI_Data_8b (Data'First .. Data'Last);

   begin
      case This.Connect_With is
         when Connect_I2C =>
            SH1107.I2C.Write_Data (This.Port_I2C, This.Address_I2C, Data);
         when Connect_SPI =>
            for I in Data'First .. Data'Last loop
               SPI_DATA (I) := Data (I);
            end loop;
            SH1107.SPI.Write_Data (This.Port_SPI,
                                   This.CS_SPI,
                                   This.DC_SPI,
                                   SPI_DATA);
      end case;
   end Write_Data;

   procedure Write_Raw_Pixels (This : SH1107_Screen;
                               Data : HAL.UInt8_Array) is
      Index         : Natural := 1;

      Page_Address  : HAL.UInt8;
      use HAL;
   begin
      for Page_Number in HAL.UInt8 (0) .. HAL.UInt8 (15) loop
         Page_Address := CMD_SET_PAGE_ADDRESS + Page_Number;
         Write_Command (This, CMD_SET_LOWER_COLUMN_ADDRESS);
         Write_Command (This, CMD_SET_HIGHER_COLUMN_ADDRESS);
         Write_Command (This, Page_Address);
         Write_Data (This,
                     (1 => 16#40#) & Data (Index .. Index + 128));
         Index := Index + 128;
      end loop;
   end Write_Raw_Pixels;

end SH1107;
