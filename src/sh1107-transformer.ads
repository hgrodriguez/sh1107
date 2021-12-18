--===========================================================================
--
--  This package is the interface to the SH1107 transfomer
--     The transformer transforms the logical coordinates in the given
--     orientation the corresponding indices and bits.
--
--===========================================================================
--
--  Copyright 2021 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--

private package SH1107.Transformer is

   --------------------------------------------------------------------------
   --  Calculates the byte index into the memory area,
   --  which corresponds to the logical
   --  Orientation and X, Y coordinates
   function Get_Byte_Index (O    : SH1107_Orientation;
                            X, Y : Natural) return Natural;

   --------------------------------------------------------------------------
   --  Calculates the bit mask to use
   --  which corresponds to the logical
   --  Orientation and X, Y coordinates
   function Get_Bit_Mask (O    : SH1107_Orientation;
                          X, Y : Natural) return HAL.UInt8;

end SH1107.Transformer;
