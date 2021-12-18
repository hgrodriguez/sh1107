private package SH1107.Transformer is

   THE_VARIANT : constant Integer := 1;

   function Get_Byte_Index (X, Y : Natural) return Natural;
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

end SH1107.Transformer;
