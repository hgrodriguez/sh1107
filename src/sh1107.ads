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
with HAL.I2C;

with Memory_Mapped_Bitmap;

package SH1107 is

   --------------------------------------------------------------------------
   --  Possible orientations of the OLED display
   --     Think of it as, how you would see it, when the display itself
   --     is laid out to the flat cable connector.
   --     Up = The display is pointing UP relative to the cable
   --     Right = The display is pointing RIGHT relative to the cable
   --     Down = The display is pointing DOWN relative to the cable
   --     Left = The display is pointing LEFT relative to the cable
   type SH1107_Orientation is (Up, Right, Down, Left);

   type SH1107_Screen
     (Buffer_Size_In_Byte : Positive;
      Width               : Positive;  --  Width in pixel
      Height              : Positive   --  Height in pixel
      )
   is limited new HAL.Framebuffer.Frame_Buffer_Display with private;

   type Any_SH1107_Screen is access all SH1107_Screen'Class;

   --------------------------------------------------------------------------
   --  Initializes an OLED screen connected by I2C
   procedure Initialize (This        : in out SH1107_Screen;
                         Orientation : SH1107_Orientation;
                         Port        : not null HAL.I2C.Any_I2C_Port;
                         Address     : HAL.I2C.I2C_Address);

   --------------------------------------------------------------------------
   --  Turns on the display
   procedure Turn_On (This : SH1107_Screen);

   --------------------------------------------------------------------------
   --  Turns off the display
   procedure Turn_Off (This : SH1107_Screen);

   --------------------------------------------------------------------------
   --  Sets the logical orientation of the display
   procedure Set_Orientation
     (This        : in out SH1107_Screen;
      Orientation : SH1107_Orientation);

   --========================================================================
   --
   --  This section is the collection of overriding procedures/functions
   --  from the parent class
   --
   --========================================================================
   overriding
   function Max_Layers
     (This : SH1107_Screen) return Positive is (1);

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
     (This : SH1107_Screen) return Positive is (This.Width);

   overriding
   function Height
     (This : SH1107_Screen) return Positive is (This.Height);

   overriding
   function Swapped
     (This : SH1107_Screen) return Boolean is (False);

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
   type Connector is (Connect_I2C, Connect_SPI);

   type SH1107_Bitmap_Buffer (Buffer_Size_In_Byte : Positive) is
     new Memory_Mapped_Bitmap.Memory_Mapped_Bitmap_Buffer with record
      Orientation : SH1107_Orientation;
      Data        : HAL.UInt8_Array (1 .. Buffer_Size_In_Byte);
   end record;

   type SH1107_Screen (Buffer_Size_In_Byte : Positive;
                       Width               : Positive;
                       Height              : Positive
                      )
   is limited new HAL.Framebuffer.Frame_Buffer_Display with
      record
         Orientation        : SH1107_Orientation;
         Memory_Layer       : aliased
           SH1107_Bitmap_Buffer (Buffer_Size_In_Byte);
         Layer_Initialized  : Boolean := False;
         Device_Initialized : Boolean := False;
         Connection         : Connector;
         --  In case of I2C:
         Port               : HAL.I2C.Any_I2C_Port;
         Address            : HAL.I2C.I2C_Address;
         --  in case of SPI:
      end record;

   --========================================================================
   --
   --  This section is the collection of overriding procedures/functions
   --  from the parent class for the Bitmap Buffer
   --
   --========================================================================
   overriding
   procedure Set_Pixel (Buffer  : in out SH1107_Bitmap_Buffer;
                        Pt      : HAL.Bitmap.Point);

   overriding
   procedure Set_Pixel (Buffer  : in out SH1107_Bitmap_Buffer;
                        Pt      : HAL.Bitmap.Point;
                        Color   : HAL.Bitmap.Bitmap_Color);

   overriding
   procedure Set_Pixel (Buffer  : in out SH1107_Bitmap_Buffer;
                        Pt      : HAL.Bitmap.Point;
                        Raw     : HAL.UInt32);

   overriding
   function Pixel (Buffer : SH1107_Bitmap_Buffer;
                   Pt     : HAL.Bitmap.Point) return HAL.Bitmap.Bitmap_Color;

   overriding
   function Pixel (Buffer : SH1107_Bitmap_Buffer;
                   Pt     : HAL.Bitmap.Point) return HAL.UInt32;

   overriding
   procedure Fill (Buffer : in out SH1107_Bitmap_Buffer);

end SH1107;
