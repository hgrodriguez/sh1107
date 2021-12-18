with HAL;

with Memory_Mapped_Bitmap;

package SH1107.Bitmap is

   subtype Parent is Memory_Mapped_Bitmap.Memory_Mapped_Bitmap_Buffer;

   type SH1107_Buffer (Buffer_Size_In_Byte : Positive) is
     new Parent with record
      Data : HAL.UInt8_Array (1 .. Buffer_Size_In_Byte);
   end record;

   overriding
   procedure Set_Pixel
     (Buffer  : in out SH1107_Buffer;
      Pt      : HAL.Bitmap.Point);

   overriding
   procedure Set_Pixel
     (Buffer  : in out SH1107_Buffer;
      Pt      : HAL.Bitmap.Point;
      Color   : HAL.Bitmap.Bitmap_Color);

   overriding
   procedure Set_Pixel
     (Buffer  : in out SH1107_Buffer;
      Pt      : HAL.Bitmap.Point;
      Raw     : HAL.UInt32);

   overriding
   function Pixel
     (Buffer : SH1107_Buffer;
      Pt     : HAL.Bitmap.Point)
      return HAL.Bitmap.Bitmap_Color;

   overriding
   function Pixel
     (Buffer : SH1107_Buffer;
      Pt     : HAL.Bitmap.Point)
      return HAL.UInt32;

   overriding
   procedure Fill
     (Buffer : in out SH1107_Buffer);

end SH1107.Bitmap;
