package body SH1107.Transformer is

   function Get_Page_Up (Y : Natural) return Natural;
   function Get_Page_Down (Y : Natural) return Natural;

   function Get_Column_Up (X : Natural) return Natural;
   function Get_Column_Down (X : Natural) return Natural;

   function Get_Page_Up (Y : Natural) return Natural is
   begin
      return Y / 8;
   end Get_Page_Up;

   function Get_Page_Down (Y : Natural) return Natural is
   begin
      return 15 - Y / 8;
   end Get_Page_Down;

   function Get_Column_Up (X : Natural) return Natural is
   begin
      return X;
   end Get_Column_Up;

   function Get_Column_Down (X : Natural) return Natural is
   begin
      return 127 - X;
   end Get_Column_Down;

   function Get_Byte_Index (O    : SH1107_Orientation;
                            X, Y : Natural) return Natural is
   begin
      case O is
         when Up =>
            return 128 * Get_Page_Up (Y) + Get_Column_Up (X);
         when Down =>
            return 128 * Get_Page_Down (Y) + Get_Column_Down (X);
         when others =>
            return 0;
      end case;
   end Get_Byte_Index;

   --========================================================================
   --
   --  This section is the implementation of the bit mask calculation
   --
   --========================================================================
   function Bit_Mask_Up (Y : Natural) return HAL.UInt8;
   function Bit_Mask_Down (Y : Natural) return HAL.UInt8;

   function Get_Bit_Mask (O    : SH1107_Orientation;
                          X, Y : Natural) return HAL.UInt8 is
      pragma Unreferenced (X);
   begin
      case O is
         when Up =>
            return Bit_Mask_Up (Y);
         when Down =>
            return Bit_Mask_Down (Y);
         when others =>
            return 16#00#;
      end case;
   end Get_Bit_Mask;

   --------------------------------------------------------------------------
   --  If the orienation is Up, this means, that the Y-coordinates
   --  map from a logical perspective:
   --  increasing Y coordincates moves the bit mask from D0 -> D7
   function Bit_Mask_Up (Y : Natural) return HAL.UInt8 is
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
   end Bit_Mask_Up;

   --------------------------------------------------------------------------
   --  If the orienation is Down, this means, that the Y-coordinates
   --  map from a logical perspective:
   --  increasing Y coordincates moves the bit mask from D7 -> D0
   function Bit_Mask_Down (Y : Natural) return HAL.UInt8 is
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
   end Bit_Mask_Down;

end SH1107.Transformer;
