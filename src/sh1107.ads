--===========================================================================
--
--  This package is the interface to the SH1107 OLED controller
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
with HAL.I2C;
with HAL.SPI;

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

   --------------------------------------------------------------------------
   --  As this screen is black/white only, we only have one layer
   THE_LAYER : constant Positive := 1;

   --------------------------------------------------------------------------
   --  This driver can only support 128 x 128 bits black/white
   --  Therefore we daclare those constants here
   THE_WIDTH  : constant Positive := 128;
   THE_HEIGHT : constant Positive := 128;

   --------------------------------------------------------------------------
   --  Having the constants as above, and as one byte has 8 bits,
   --  The buffer size is a constant as below
   THE_BUFFER_SIZE_IN_BYTES : constant Positive
     := (THE_WIDTH * THE_HEIGHT) / 8;

   --------------------------------------------------------------------------
   --  The device can be connected via
   --  - I2C
   --  - SPI
   type Connector is (Connect_I2C, Connect_SPI);

   --------------------------------------------------------------------------
   --  Our screen type definition.
   --  Unlike other drivers, as this driver is constant, no discriminants
   --  needed for different scenarions.
   --    Connect_With : defines, how to connect to the display
   type SH1107_Screen (Connect_With : Connector)
   is limited new HAL.Framebuffer.Frame_Buffer_Display with private;

   --------------------------------------------------------------------------
   --  Our access screen type definition.
   type Any_SH1107_Screen is not null access all SH1107_Screen'Class;

   --------------------------------------------------------------------------
   --  Initializes an OLED screen connected by I2C
   procedure Initialize (This        : in out SH1107_Screen;
                         Orientation : SH1107_Orientation;
                         Port        : not null HAL.I2C.Any_I2C_Port;
                         Address     : HAL.I2C.I2C_Address);

   --------------------------------------------------------------------------
   --  Initializes an OLED screen connected by SPI
   procedure Initialize (This        : in out SH1107_Screen;
                         Orientation : SH1107_Orientation;
                         Port        : not null HAL.SPI.Any_SPI_Port;
                         DC_SPI      : not null HAL.GPIO.Any_GPIO_Point);

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
     (This : SH1107_Screen) return Positive is (THE_WIDTH);

   overriding
   function Height
     (This : SH1107_Screen) return Positive is (THE_HEIGHT);

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

   pragma Warnings (Off, "formal parameter ""Layer"" is not referenced");
   overriding
   function Color_Mode
     (This  : SH1107_Screen;
      Layer : Positive := THE_LAYER) return HAL.Framebuffer.FB_Color_Mode
   is (HAL.Bitmap.M_1);
   pragma Warnings (On, "formal parameter ""Layer"" is not referenced");

   overriding
   function Hidden_Buffer
     (This  : in out SH1107_Screen;
      Layer : Positive := THE_LAYER)
      return not null HAL.Bitmap.Any_Bitmap_Buffer;

   overriding
   function Pixel_Size
     (Display : SH1107_Screen;
      Layer   : Positive := THE_LAYER) return Positive;

private
   --------------------------------------------------------------------------
   --  The bitmap buffer used for the display
   type SH1107_Bitmap_Buffer is
     new Memory_Mapped_Bitmap.Memory_Mapped_Bitmap_Buffer with record
      Orientation : SH1107_Orientation;
      Data        : HAL.UInt8_Array (1 .. THE_BUFFER_SIZE_IN_BYTES);
   end record;

   type SH1107_Screen  (Connect_With : Connector)
   is limited new HAL.Framebuffer.Frame_Buffer_Display with
      record
         Buffer_Size_In_Byte : Positive := THE_BUFFER_SIZE_IN_BYTES;
         Width               : Positive := THE_WIDTH;
         Height              : Positive := THE_HEIGHT;
         Orientation         : SH1107_Orientation;
         Memory_Layer        : aliased SH1107_Bitmap_Buffer;
         Layer_Initialized   : Boolean := False;
         Device_Initialized  : Boolean := False;
         case Connect_With is
            when Connect_I2C =>
               Port_I2C            : HAL.I2C.Any_I2C_Port;
               Address_I2C         : HAL.I2C.I2C_Address;
            when Connect_SPI =>
               Port_SPI            : HAL.SPI.Any_SPI_Port;
               DC_SPI              : HAL.GPIO.Any_GPIO_Point;
         end case;
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
