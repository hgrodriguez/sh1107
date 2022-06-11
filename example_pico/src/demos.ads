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

   type Demos_Available is (Black_Background_White_Arrow,
                            White_Background_With_Black_Rectangle_Full_Screen,
                            Black_Background_With_White_Rectangle_Full_Screen,
                            White_Background_4_Black_Corners,
                            Black_Background_4_White_Corners,
                            Black_Background_White_Geometry,
                            White_Background_Black_Geometry,
                            White_Diagonal_Line_On_Black,
                            Black_Diagonal_Line_On_White
                           );

   type Demo_Array is array (Demos_Available) of Boolean;

   All_Demos : Demo_Array
     := (Black_Background_White_Arrow => True,
         White_Background_With_Black_Rectangle_Full_Screen => True,
         Black_Background_With_White_Rectangle_Full_Screen => True,
         White_Background_4_Black_Corners => True,
         Black_Background_4_White_Corners => True,
         Black_Background_White_Geometry => True,
         White_Background_Black_Geometry => True,
         White_Diagonal_Line_On_Black => True,
         Black_Diagonal_Line_On_White => True);

   procedure Show_Multiple_Demos (S  : in out SH1107.SH1107_Screen;
                                  O  : SH1107.SH1107_Orientation;
                                  DA : Demo_Array);

   procedure Show_1_Demo (S    : in out SH1107.SH1107_Screen;
                          O    : SH1107.SH1107_Orientation;
                          Demo : Demos_Available);
end Demos;
