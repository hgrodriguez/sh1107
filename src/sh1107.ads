--===========================================================================
--
--  This package is the interface to the SH1107 OLED controller
--
--===========================================================================
--
--  Copyright 2021 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--

with HAL;
with HAL.Bitmap;
with HAL.Framebuffer;
with HAL.GPIO;
with HAL.I2C;
with HAL.Time;

with Memory_Mapped_Bitmap;

package SH1107 is

   type SH1107_Screen
     (Buffer_Size_In_Byte : Positive;
      --  Number of byte in the bitmap buffer: ((Width * Height) / 8)

      Width               : Positive;
      --  Width in pixel

      Height              : Positive;
      --  Height in pixel

      Port                : not null HAL.I2C.Any_I2C_Port;
      --  I2C communication port. Depending on the bus configuration, SSD1306
      --  drivers can work up to 1MHz.

      Address             : HAL.I2C.I2C_Address)
   is limited new HAL.Framebuffer.Frame_Buffer_Display with private;

   type Any_SH1107_Screen is access all SH1107_Screen'Class;

   procedure Initialize (This       : in out SH1107_Screen;
                         This_Delay : HAL.Time.Any_Delays);
   procedure Turn_On (This : SH1107_Screen);
   procedure Turn_Off (This : SH1107_Screen);

   overriding
   function Max_Layers
     (This : SH1107_Screen) return Positive;

   overriding
   function Supported
     (This : SH1107_Screen;
      Mode : HAL.Framebuffer.FB_Color_Mode) return Boolean;

   overriding
   procedure Set_Orientation
     (This        : in out SH1107_Screen;
      Orientation : HAL.Framebuffer.Display_Orientation);

   overriding
   procedure Set_Mode
     (This    : in out SH1107_Screen;
      Mode    : HAL.Framebuffer.Wait_Mode);

   overriding
   function Initialized
     (This : SH1107_Screen) return Boolean;

   overriding
   function Width
     (This : SH1107_Screen) return Positive;

   overriding
   function Height
     (This : SH1107_Screen) return Positive;

   overriding
   function Swapped
     (This : SH1107_Screen) return Boolean;

   overriding
   procedure Set_Background
     (This : SH1107_Screen; R, G, B : HAL.UInt8);

   overriding
   procedure Initialize_Layer
     (This   : in out SH1107_Screen;
      Layer  : Positive;
      Mode   : HAL.Framebuffer.FB_Color_Mode;
      X      : Natural := 0;
      Y      : Natural := 0;
      Width  : Positive := Positive'Last;
      Height : Positive := Positive'Last);

   overriding
   function Initialized
     (This  : SH1107_Screen;
      Layer : Positive) return Boolean;

   overriding
   procedure Update_Layer
     (This      : in out SH1107_Screen;
      Layer     : Positive;
      Copy_Back : Boolean := False);

   overriding
   procedure Update_Layers
     (This : in out SH1107_Screen);

   overriding
   function Color_Mode
     (This  : SH1107_Screen;
      Layer : Positive) return HAL.Framebuffer.FB_Color_Mode;

   overriding
   function Hidden_Buffer
     (This  : in out SH1107_Screen;
      Layer : Positive)
      return not null HAL.Bitmap.Any_Bitmap_Buffer;

   overriding
   function Pixel_Size
     (Display : SH1107_Screen;
      Layer   : Positive) return Positive;

private
   type SH1107_Bitmap_Buffer (Buffer_Size_In_Byte : Positive) is
     new Memory_Mapped_Bitmap.Memory_Mapped_Bitmap_Buffer with record
      Data : HAL.UInt8_Array (1 .. Buffer_Size_In_Byte);
   end record;

   type SH1107_Screen
     (Buffer_Size_In_Byte : Positive;
      Width               : Positive;
      Height              : Positive;
      Port                : not null HAL.I2C.Any_I2C_Port;
      Address             : HAL.I2C.I2C_Address)
   is limited new HAL.Framebuffer.Frame_Buffer_Display with
      record
         Memory_Layer       : aliased
           SH1107_Bitmap_Buffer (Buffer_Size_In_Byte);
         Layer_Initialized  : Boolean := False;
         Device_Initialized : Boolean := False;
      end record;

   overriding
   procedure Set_Pixel
     (Buffer  : in out SH1107_Bitmap_Buffer;
      Pt      : HAL.Bitmap.Point);

   overriding
   procedure Set_Pixel
     (Buffer  : in out SH1107_Bitmap_Buffer;
      Pt      : HAL.Bitmap.Point;
      Color   : HAL.Bitmap.Bitmap_Color);

   overriding
   procedure Set_Pixel
     (Buffer  : in out SH1107_Bitmap_Buffer;
      Pt      : HAL.Bitmap.Point;
      Raw     : HAL.UInt32);

   overriding
   function Pixel
     (Buffer : SH1107_Bitmap_Buffer;
      Pt     : HAL.Bitmap.Point)
      return HAL.Bitmap.Bitmap_Color;

   overriding
   function Pixel
     (Buffer : SH1107_Bitmap_Buffer;
      Pt     : HAL.Bitmap.Point)
      return HAL.UInt32;

   overriding
   procedure Fill
     (Buffer : in out SH1107_Bitmap_Buffer);

end SH1107;
