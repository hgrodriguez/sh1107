package body SH1107.Bitmap is

   ----------------------
   THE_VARIANT : constant Integer := 1;

   function Get_Transformed_X (Buffer  : SH1107_Buffer;
                               Pt      : HAL.Bitmap.Point) return Natural;
   function Get_Transformed_Y (Buffer  : SH1107_Buffer;
                               Pt      : HAL.Bitmap.Point) return Natural;
   function Get_Index (Buffer  : SH1107_Buffer;
                       X       : Natural;
                       Y       : Natural) return Natural;

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

   overriding
   procedure Set_Pixel
     (Buffer  : in out SH1107_Buffer;
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
     (Buffer  : in out SH1107_Buffer;
      Pt      : HAL.Bitmap.Point;
      Color   : HAL.Bitmap.Bitmap_Color)
   is
      use HAL.Bitmap;
   begin
      Buffer.Set_Pixel (Pt, (if Color = HAL.Bitmap.Black then 0 else 1));
   end Set_Pixel;

   overriding
   procedure Set_Pixel
     (Buffer  : in out SH1107_Buffer;
      Pt      : HAL.Bitmap.Point;
      Raw     : HAL.UInt32)
   is
   begin
      Buffer.Native_Source := Raw;
      Buffer.Set_Pixel (Pt);
   end Set_Pixel;

   overriding
   function Pixel
     (Buffer : SH1107_Buffer;
      Pt     : HAL.Bitmap.Point)
      return HAL.Bitmap.Bitmap_Color
   is
      use HAL;
   begin
      return (if Buffer.Pixel (Pt) = 0 then
                 HAL.Bitmap.Black
              else HAL.Bitmap.White);
   end Pixel;

   overriding -- IMPLEMENT
   function Pixel
     (Buffer : SH1107_Buffer;
      Pt     : HAL.Bitmap.Point)
      return HAL.UInt32
   is
      X     : constant Natural := Get_Transformed_X (Buffer, Pt);
      Y     : constant Natural := Get_Transformed_Y (Buffer, Pt);
      Index : constant Natural := Get_Index (Buffer, X, Y);
      Byte  : HAL.UInt8 renames Buffer.Data (Buffer.Data'First + Index);
      use HAL;
   begin
      if (Byte and (Shift_Left (1, Y mod 8))) /= 0 then
         return 1;
      else
         return 0;
      end if;
   end Pixel;

   overriding
   procedure Fill
     (Buffer : in out SH1107_Buffer)
   is
      use HAL;
      Val : constant HAL.UInt8
        := (if Buffer.Native_Source /= 0 then 16#FF# else 0);
   begin
      Buffer.Data := (others => Val);
   end Fill;

   function Get_Transformed_X (Buffer  : SH1107_Buffer;
                               Pt      : HAL.Bitmap.Point) return Natural is
   begin
      return Buffer.Width - Buffer.Width + Pt.X;
   end Get_Transformed_X;

   function Get_Transformed_Y (Buffer  : SH1107_Buffer;
                               Pt      : HAL.Bitmap.Point) return Natural is
   begin
      return Buffer.Height - Buffer.Height + Pt.Y;
   end Get_Transformed_Y;

   function Get_Index (Buffer  : SH1107_Buffer;
                       X       : Natural;
                       Y       : Natural) return Natural is
   begin
      return X + (Y / 8) * Buffer.Actual_Width;
   end Get_Index;

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

end SH1107.Bitmap;
