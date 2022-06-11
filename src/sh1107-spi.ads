--===========================================================================
--
--  This package is the interface to the SPI connection implementation
--  THIS IS NOT IMPLEMENTED YET, IT IS WIP!!!
--
--===========================================================================
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL;
with HAL.SPI;

package SH1107.SPI is

   --------------------------------------------------------------------------
   --  Using the
   --     Port   : SPI of the screen
   --     DC_SPI : Data/Command GPIO
   --  writes
   --     Cmd    : to the screen
   procedure Write_Command (Port   : not null HAL.SPI.Any_SPI_Port;
                            DC_SPI : not null HAL.GPIO.Any_GPIO_Point;
                            Cmd    : HAL.UInt8);

   --------------------------------------------------------------------------
   --  Using the
   --     Port   : SPI of the screen
   --     DC_SPI : Data/Command GPIO
   --  writes
   --     Cmd and Arg    : to the screen
   procedure Write_Command_Argument (Port   : not null HAL.SPI.Any_SPI_Port;
                                     DC_SPI : not null HAL.GPIO.Any_GPIO_Point;
                                     Cmd    : HAL.UInt8;
                                     Arg    : HAL.UInt8);

   --------------------------------------------------------------------------
   --  Using the
   --     Port   : SPI of the screen
   --     DC_SPI : Data/Command GPIO
   --  writes
   --     Data: to the OLED using
   procedure Write_Data (Port   : not null HAL.SPI.Any_SPI_Port;
                         DC_SPI : not null HAL.GPIO.Any_GPIO_Point;
                         Data   : HAL.SPI.SPI_Data_8b);

end SH1107.SPI;
