--===========================================================================
--
--  This package is the interface to the demo package showing examples
--  for the SH1107 OLED controller
--
--===========================================================================
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with SH1107;

package Demos is

   procedure Black_Background_White_Arrow (S : in out SH1107.SH1107_Screen);
   procedure White_Background_With_Black_Rectangle_Full_Screen
     (S : in out SH1107.SH1107_Screen);
   procedure Black_Background_With_White_Rectangle_Full_Screen
     (S : in out SH1107.SH1107_Screen);
   procedure White_Background_4_Black_Corners
     (S : in out SH1107.SH1107_Screen);
   procedure Black_Background_4_White_Corners
     (S : in out SH1107.SH1107_Screen);
   procedure Black_Background_White_Geometry (S : in out SH1107.SH1107_Screen);
   procedure White_Background_Black_Geometry (S : in out SH1107.SH1107_Screen);
   procedure White_Diagonal_Line_On_Black (S : in out SH1107.SH1107_Screen);
   procedure Black_Diagonal_Line_On_White (S : in out SH1107.SH1107_Screen);
end Demos;
