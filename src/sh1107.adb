--===========================================================================
--
--  This package is the interface to the LED part of the EDC Client
--
--===========================================================================
--
--  Copyright 2021 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--

with SH1107.I2C;

package body SH1107 is

   --     type Memory_Addressing_Mode is (Page_Addressing,
   --   Vertical_AddressingLow_Level, High_Level, Falling_Edge, Rising_Edge)
   --       with Size => 4;
   --     for Interrupt_Triggers use
   --       (Low_Level    => 2#0001#,
   --        High_Level   => 2#0010#,
   --        Falling_Edge => 2#0100#,
   --        Rising_Edge  => 2#1000#);

--     type SH1107_Screen_I2C is new SH1107_Screen with record
--        XXX : Integer;
--     end record;

   --  I2C part
   procedure Write_Command (This : SH1107_Screen;
                            Cmd  : HAL.UInt8);
   procedure Write_Command (This : SH1107_Screen;
                            Cmd  : HAL.UInt8) is
   begin
      SH1107.I2C.Write_Command (This.Port, This.Address, Cmd);
   end Write_Command;

   procedure Write_Data (This : SH1107_Screen;
                         Data : HAL.UInt8_Array);

   procedure Write_Data (This : SH1107_Screen;
                         Data : HAL.UInt8_Array) is
   begin
      SH1107.I2C.Write_Data (This.Port, This.Address, Data);
   end Write_Data;

   procedure Write_Raw_Pixels (This : SH1107_Screen;
                               Data : HAL.UInt8_Array);

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

   ----------------------
   THE_VARIANT : constant Integer := 1;

   function Bit_Mask_1 (Y : Natural) return HAL.UInt8;
   function Bit_Mask_2_3 (Y : Natural) return HAL.UInt8;
   type Bit_Mask_Function is access function (Y : Natural) return HAL.UInt8;
   Bit_Mask_Functions : constant array (1 .. 3) of Bit_Mask_Function
     := (1 => Bit_Mask_1'Access,
         2 => Bit_Mask_2_3'Access,
         3 => Bit_Mask_2_3'Access
        );

   function Get_Page_1_2 (Y : Natural) return Natural;
   function Get_Page_3 (Y : Natural) return Natural;
   type Get_Page_Function is access function (Y : Natural) return Natural;
   Get_Page_Functions : constant array (1 .. 3) of Get_Page_Function
     := (1 => Get_Page_1_2'Access,
         2 => Get_Page_1_2'Access,
         3 => Get_Page_3'Access
        );

   function Get_Column_1_2 (X : Natural) return Natural;
   function Get_Column_3 (X : Natural) return Natural;
   type Get_Column_Function is access function (X : Natural) return Natural;
   Get_Column_Functions : constant array (1 .. 3) of Get_Column_Function
     := (1 => Get_Column_1_2'Access,
         2 => Get_Column_1_2'Access,
         3 => Get_Column_3'Access
        );

   function Get_Byte_Index (X, Y : Natural) return Natural;

   procedure Initialize (This       : in out SH1107_Screen;
                         Port       : not null HAL.I2C.Any_I2C_Port;
                         Address    : HAL.I2C.I2C_Address) is
   begin
      if This.Width * This.Height /= (This.Buffer_Size_In_Byte * 8) then
         raise Program_Error with "Invalid screen parameters";
      end if;

      This.Port := Port;
      This.Address := Address;

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

      This.Device_Initialized := True;
   end Initialize;

   procedure Turn_On (This : SH1107_Screen) is
   begin
      Write_Command (This, CMD_DISPLAY_ON);
   end Turn_On;

   procedure Turn_Off (This : SH1107_Screen) is
   begin
      Write_Command (This, CMD_DISPLAY_OFF);
   end Turn_Off;

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
   function Color_Mode
     (This  : SH1107_Screen;
      Layer : Positive) return HAL.Framebuffer.FB_Color_Mode is
      pragma Unreferenced (This);
   begin
      if Layer /= 1 then
         raise Program_Error;
      end if;
      return HAL.Bitmap.M_1;
   end Color_Mode;

   overriding
   function Hidden_Buffer
     (This  : in out SH1107_Screen;
      Layer : Positive)
      return not null HAL.Bitmap.Any_Bitmap_Buffer is
   begin
      if Layer /= 1 then
         raise Program_Error;
      end if;
      return This.Memory_Layer'Unchecked_Access;
   end Hidden_Buffer;

   overriding
   function Pixel_Size
     (Display : SH1107_Screen;
      Layer   : Positive) return Positive is (1);

   overriding
   procedure Set_Pixel
     (Buffer  : in out SH1107_Bitmap_Buffer;
      Pt      : HAL.Bitmap.Point)
   is
      Index : constant Natural := Get_Byte_Index (Pt.X, Pt.Y);
      Byte  : HAL.UInt8 renames Buffer.Data (Buffer.Data'First + Index);
      Bit   : constant HAL.UInt8 := Bit_Mask_Functions (THE_VARIANT) (Pt.Y);
      use HAL;
   begin
      if Buffer.Native_Source = 0 then
         Byte := Byte and not Bit;
      else
         Byte := Byte or Bit;
      end if;
   end Set_Pixel;

   overriding
   procedure Set_Pixel
     (Buffer  : in out SH1107_Bitmap_Buffer;
      Pt      : HAL.Bitmap.Point;
      Color   : HAL.Bitmap.Bitmap_Color)
   is
      use HAL.Bitmap;
   begin
      Buffer.Set_Pixel (Pt, (if Color = HAL.Bitmap.Black then 0 else 1));
   end Set_Pixel;

   overriding
   procedure Set_Pixel
     (Buffer  : in out SH1107_Bitmap_Buffer;
      Pt      : HAL.Bitmap.Point;
      Raw     : HAL.UInt32)
   is
   begin
      Buffer.Native_Source := Raw;
      Buffer.Set_Pixel (Pt);
   end Set_Pixel;

   overriding
   function Pixel
     (Buffer : SH1107_Bitmap_Buffer;
      Pt     : HAL.Bitmap.Point)
      return HAL.Bitmap.Bitmap_Color
   is
      use HAL;
   begin
      return (if Buffer.Pixel (Pt) = 0 then
                 HAL.Bitmap.Black
              else HAL.Bitmap.White);
   end Pixel;

   overriding
   function Pixel
     (Buffer : SH1107_Bitmap_Buffer;
      Pt     : HAL.Bitmap.Point)
      return HAL.UInt32
   is
      Index : constant Natural := Get_Byte_Index (Pt.X, Pt.Y);
      Byte  : HAL.UInt8 renames Buffer.Data (Buffer.Data'First + Index);
      Bit   : constant HAL.UInt8 := Bit_Mask_Functions (THE_VARIANT) (Pt.Y);
      use HAL;
   begin
      if (Byte and Bit) /= 0 then
         return 1;
      else
         return 0;
      end if;
   end Pixel;

   overriding
   procedure Fill
     (Buffer : in out SH1107_Bitmap_Buffer)
   is
      use HAL;
      Val : constant HAL.UInt8
        := (if Buffer.Native_Source /= 0 then 16#FF# else 0);
   begin
      Buffer.Data := (others => Val);
   end Fill;

   function Bit_Mask_1 (Y : Natural) return HAL.UInt8 is
      LUT : constant HAL.UInt8_Array (0 .. 7)
        := (
            0 => 16#01#,
            1 => 16#02#,
            2 => 16#04#,
            3 => 16#08#,
            4 => 16#10#,
            5 => 16#20#,
            6 => 16#40#,
            7 => 16#80#
           );
   begin
      return LUT (Y mod 8);
   end Bit_Mask_1;

   function Bit_Mask_2_3 (Y : Natural) return HAL.UInt8 is
      LUT : constant HAL.UInt8_Array (0 .. 7)
        := (
            0 => 16#80#,
            1 => 16#40#,
            2 => 16#20#,
            3 => 16#10#,
            4 => 16#08#,
            5 => 16#04#,
            6 => 16#02#,
            7 => 16#01#
           );
   begin
      return LUT (Y mod 8);
   end Bit_Mask_2_3;

   function Get_Page_1_2 (Y : Natural) return Natural is
   begin
      return Y / 8;
   end Get_Page_1_2;

   function Get_Page_3 (Y : Natural) return Natural is
   begin
      return 15 - Y / 8;
   end Get_Page_3;

   function Get_Column_1_2 (X : Natural) return Natural is
   begin
      return X;
   end Get_Column_1_2;

   function Get_Column_3 (X : Natural) return Natural is
   begin
      return 127 - X;
   end Get_Column_3;

   function Get_Byte_Index (X, Y : Natural) return Natural is
   begin
      return 128 * Get_Page_Functions (THE_VARIANT) (Y)
        + Get_Column_Functions (THE_VARIANT) (X);
   end Get_Byte_Index;

end SH1107;
