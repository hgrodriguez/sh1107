package body SH1107.Transformer is

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

   ----------------------

   function Get_Bit_Mask (O    : SH1107_Orientation;
                          X, Y : Natural) return HAL.UInt8 is
      pragma Unreferenced (O);
      pragma Unreferenced (X);
   begin
      return Bit_Mask_Functions (SH1107.Transformer.THE_VARIANT) (Y);
   end Get_Bit_Mask;

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

   function Get_Byte_Index (O    : SH1107_Orientation;
                            X, Y : Natural) return Natural is
      pragma Unreferenced (O);
   begin
      return 128 * Get_Page_Functions (THE_VARIANT) (Y)
        + Get_Column_Functions (THE_VARIANT) (X);
   end Get_Byte_Index;

end SH1107.Transformer;
