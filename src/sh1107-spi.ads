--===========================================================================
--
--  This package is the interface to the I2C connection implementation
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
   --  Writes the
   --     Cmd: to the OLED using
   --     Port: SPI of the device using
   --     CS_SPI : as the select pin
   procedure Write_Command (Port   : not null HAL.SPI.Any_SPI_Port;
                            CS_SPI : not null HAL.GPIO.Any_GPIO_Point;
                            Cmd    : HAL.UInt8);

   --------------------------------------------------------------------------
   --  Writes the
   --     Data: to the OLED using
   --     Port: SPI of the device using
   --     CS_SPI : as the select pin
   procedure Write_Data (Port   : not null HAL.SPI.Any_SPI_Port;
                         CS_SPI : not null HAL.GPIO.Any_GPIO_Point;
                         Data   : HAL.SPI.SPI_Data_8b);

end SH1107.SPI;
