--===========================================================================
--
--  This package is the implementation of the Transforme package
--
--===========================================================================
--
--  Copyright 2021 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--

package body SH1107.Transformer is

   --========================================================================
   --
   --  This section is the implementation of the get byte index calculation
   --
   --========================================================================
   function Get_Page_Up (Y : Natural) return Natural;
   function Get_Page_Right (X : Natural) return Natural;
   function Get_Page_Down (Y : Natural) return Natural;
   function Get_Page_Left (X : Natural) return Natural;

   function Get_Column_Up (X : Natural) return Natural;
   function Get_Column_Right (Y : Natural) return Natural;
   function Get_Column_Down (X : Natural) return Natural;
   function Get_Column_Left (Y : Natural) return Natural;

   --------------------------------------------------------------------------
   --  see .ads
   function Get_Byte_Index (O    : SH1107_Orientation;
                            X, Y : Natural) return Natural is
   begin
      case O is
         when Up =>
            return 128 * Get_Page_Up (Y) + Get_Column_Up (X);
         when Right =>
            return 128 * Get_Page_Right (X) + Get_Column_Right (Y);
         when Down =>
            return 128 * Get_Page_Down (Y) + Get_Column_Down (X);
         when Left =>
            return 128 * Get_Page_Left (X) + Get_Column_Left (Y);
      end case;
   end Get_Byte_Index;

   --------------------------------------------------------------------------
   --  If the orienation is Up, this means, that the Y-coordinates
   --  map from a logical perspective:
   --  increasing Y coordinates are mapped to increasing pages
   function Get_Page_Up (Y : Natural) return Natural is
   begin
      return Y / 8;
   end Get_Page_Up;

   --------------------------------------------------------------------------
   --  If the orienation is Right, this means, that the X-coordinates
   --  map from a logical perspective:
   --  increasing X coordinates are mapped to decreasing pages
   function Get_Page_Right (X : Natural) return Natural is
   begin
      return 15 - X / 8;
   end Get_Page_Right;

   --------------------------------------------------------------------------
   --  If the orienation is Down, this means, that the Y-coordinates
   --  map from a logical perspective:
   --  increasing Y coordinates are mapped to decreasing pages
   function Get_Page_Down (Y : Natural) return Natural is
   begin
      return 15 - Y / 8;
   end Get_Page_Down;

   --------------------------------------------------------------------------
   --  If the orienation is Left, this means, that the X-coordinates
   --  map from a logical perspective:
   --  increasing X coordinates are mapped to increasing pages
   function Get_Page_Left (X : Natural) return Natural is
   begin
      return X / 8;
   end Get_Page_Left;

   --------------------------------------------------------------------------
   --  If the orienation is Up, this means, that the X-coordinates
   --  map from a logical perspective:
   --  increasing X coordinates are mapped to increasing columns
   function Get_Column_Up (X : Natural) return Natural is
   begin
      return X;
   end Get_Column_Up;

   --------------------------------------------------------------------------
   --  If the orienation is Right, this means, that the Y-coordinates
   --  map from a logical perspective:
   --  increasing Y coordinates are mapped to increasing columns
   function Get_Column_Right (Y : Natural) return Natural is
   begin
      return Y;
   end Get_Column_Right;

   --------------------------------------------------------------------------
   --  If the orienation is Down, this means, that the X-coordinates
   --  map from a logical perspective:
   --  increasing x coordinates are mapped to decreasing columns
   function Get_Column_Down (X : Natural) return Natural is
   begin
      return 127 - X;
   end Get_Column_Down;

   --------------------------------------------------------------------------
   --  If the orienation is Left, this means, that the Y-coordinates
   --  map from a logical perspective:
   --  increasing Y coordinates are mapped to decreasing columns
   function Get_Column_Left (Y : Natural) return Natural is
   begin
      return 127 - Y;
   end Get_Column_Left;

   --========================================================================
   --
   --  This section is the implementation of the bit mask calculation
   --
   --========================================================================
   function Bit_Mask_Up (Y : Natural) return HAL.UInt8;
   function Bit_Mask_Right (X : Natural) return HAL.UInt8;
   function Bit_Mask_Down (Y : Natural) return HAL.UInt8;
   function Bit_Mask_Left (X : Natural) return HAL.UInt8;

   --------------------------------------------------------------------------
   --  see .ads
   function Get_Bit_Mask (O    : SH1107_Orientation;
                          X, Y : Natural) return HAL.UInt8 is
   begin
      case O is
         when Up =>
            return Bit_Mask_Up (Y);
         when Right =>
            return Bit_Mask_Right (X);
         when Down =>
            return Bit_Mask_Down (Y);
         when Left =>
            return Bit_Mask_Left (X);
      end case;
   end Get_Bit_Mask;

   --------------------------------------------------------------------------
   --  LUT for bits moving from D0 to D7 in a byte
   LUT_DO_D7 : constant HAL.UInt8_Array (0 .. 7) := (
                                                     0 => 16#01#,
                                                     1 => 16#02#,
                                                     2 => 16#04#,
                                                     3 => 16#08#,
                                                     4 => 16#10#,
                                                     5 => 16#20#,
                                                     6 => 16#40#,
                                                     7 => 16#80#
                                                    );

   --------------------------------------------------------------------------
   --  LUT for bits moving from D7 to D0 in a byte
   LUT_D7_D0 : constant HAL.UInt8_Array (0 .. 7) := (
                                                     0 => 16#80#,
                                                     1 => 16#40#,
                                                     2 => 16#20#,
                                                     3 => 16#10#,
                                                     4 => 16#08#,
                                                     5 => 16#04#,
                                                     6 => 16#02#,
                                                     7 => 16#01#
                                                    );

   --------------------------------------------------------------------------
   --  If the orienation is Up, this means, that the Y-coordinates
   --  map from a logical perspective:
   --  increasing Y coordinates moves the bit mask from D0 -> D7
   function Bit_Mask_Up (Y : Natural) return HAL.UInt8 is
   begin
      return LUT_DO_D7 (Y mod 8);
   end Bit_Mask_Up;

   --------------------------------------------------------------------------
   --  If the orienation is Right, this means, that the X-coordinates
   --  map from a logical perspective:
   --  increasing X coordinates moves the bit mask from D7 -> D0
   function Bit_Mask_Right (X : Natural) return HAL.UInt8 is
   begin
      return LUT_D7_D0 (X mod 8);
   end Bit_Mask_Right;

   --------------------------------------------------------------------------
   --  If the orienation is Down, this means, that the Y-coordinates
   --  map from a logical perspective:
   --  increasing Y coordincates moves the bit mask from D7 -> D0
   function Bit_Mask_Down (Y : Natural) return HAL.UInt8 is
   begin
      return LUT_D7_D0 (Y mod 8);
   end Bit_Mask_Down;

   --------------------------------------------------------------------------
   --  If the orienation is Left, this means, that the X-coordinates
   --  map from a logical perspective:
   --  increasing X coordinates moves the bit mask from D0 -> D7
   function Bit_Mask_Left (X : Natural) return HAL.UInt8 is
   begin
      return LUT_DO_D7 (X mod 8);
   end Bit_Mask_Left;

end SH1107.Transformer;
