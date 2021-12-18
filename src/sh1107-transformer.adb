package body SH1107.Transformer is

   ----------------------

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

end SH1107.Transformer;
