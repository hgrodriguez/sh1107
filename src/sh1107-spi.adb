--===========================================================================
--
--  This package is the implementation of the SPI connection implementation
--  THIS IS NOT IMPLEMENTED YET, IT IS WIP!!!
--
--===========================================================================
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
package body SH1107.SPI is

   --------------------------------------------------------------------------
   --  see .ads
   procedure Write_Command (Port   : not null HAL.SPI.Any_SPI_Port;
                            CS_SPI : not null HAL.GPIO.Any_GPIO_Point;
                            Cmd    : HAL.UInt8) is
      use HAL;
      Data   : constant HAL.SPI.SPI_Data_8b := (1 => 0, 2 => (Cmd));
      Status : HAL.SPI.SPI_Status;
      use HAL.SPI;
   begin
      CS_SPI.Clear;
      Port.Transmit (Data    => Data,
                     Status  => Status);
      if Status /= HAL.SPI.Ok then
         --  No error handling...
         raise Program_Error;
      end if;
      CS_SPI.Set;
   end Write_Command;

   --------------------------------------------------------------------------
   --  see .ads
   procedure Write_Data (Port   : not null HAL.SPI.Any_SPI_Port;
                         CS_SPI : not null HAL.GPIO.Any_GPIO_Point;
                         Data   : HAL.SPI.SPI_Data_8b) is
      Status : HAL.SPI.SPI_Status;
      use HAL.SPI;
   begin
      CS_SPI.Clear;
      Port.Transmit (Data    => Data,
                     Status  => Status);
      if Status /= HAL.SPI.Ok then
         --  No error handling...
         raise Program_Error;
      end if;
      CS_SPI.Set;
   end Write_Data;

end SH1107.SPI;
