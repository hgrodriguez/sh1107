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
   --  Selects the data transfer mode
   procedure Select_Data_Mode (DC_SPI : not null HAL.GPIO.Any_GPIO_Point);
   --------------------------------------------------------------------------
   --  Selects the command transfer mode
   procedure Select_Command_Mode (DC_SPI : not null HAL.GPIO.Any_GPIO_Point);

   --------------------------------------------------------------------------
   --  see .ads
   procedure Write_Command (Port        : not null HAL.SPI.Any_SPI_Port;
                            DC_SPI      : not null HAL.GPIO.Any_GPIO_Point;
                            Cmd         : HAL.UInt8) is
      use HAL;
      Data   : constant HAL.SPI.SPI_Data_8b := (1 => (Cmd));
      Status : HAL.SPI.SPI_Status;
      use HAL.SPI;
   begin
      Select_Command_Mode (DC_SPI);
      Port.Transmit (Data    => Data,
                     Status  => Status);
      if Status /= HAL.SPI.Ok then
         --  No error handling...
         raise Program_Error;
      end if;
   end Write_Command;

   --------------------------------------------------------------------------
   --  see .ads
   procedure Write_Command_Argument (Port   : not null HAL.SPI.Any_SPI_Port;
                                     DC_SPI : not null HAL.GPIO.Any_GPIO_Point;
                                     Cmd    : HAL.UInt8;
                                     Arg    : HAL.UInt8) is
   begin
      Write_Command (Port, DC_SPI, Cmd);
      Write_Command (Port, DC_SPI, Arg);
   end Write_Command_Argument;

   --------------------------------------------------------------------------
   --  see .ads
   procedure Write_Data (Port        : not null HAL.SPI.Any_SPI_Port;
                         DC_SPI      : not null HAL.GPIO.Any_GPIO_Point;
                         Data        : HAL.SPI.SPI_Data_8b) is
      Status : HAL.SPI.SPI_Status;
      use HAL.SPI;
   begin
      if False then
         for Idx in Data'First .. Data'Last loop
            if Idx = Data'First then
               Select_Command_Mode (DC_SPI);
            else
               Select_Data_Mode (DC_SPI);
            end if;
            Port.Transmit (Data    => Data,
                           Status  => Status);
            if Status /= HAL.SPI.Ok then
               --  No error handling...
               raise Program_Error;
            end if;
         end loop;
      else
         Select_Command_Mode (DC_SPI);
         Port.Transmit (Data    => Data (Data'First .. Data'First),
                        Status  => Status);
         if Status /= HAL.SPI.Ok then
            --  No error handling...
            raise Program_Error;
         end if;
         Select_Data_Mode (DC_SPI);
         Port.Transmit (Data    => Data (Data'First + 1 .. Data'Last),
                        Status  => Status);
         if Status /= HAL.SPI.Ok then
            --  No error handling...
            raise Program_Error;
         end if;
      end if;
   end Write_Data;

   --------------------------------------------------------------------------
   --------------------------------------------------------------------------
   --------------------------------------------------------------------------
   procedure Select_Data_Mode (DC_SPI : not null HAL.GPIO.Any_GPIO_Point) is
   begin
      DC_SPI.Set;
   end Select_Data_Mode;

   procedure Select_Command_Mode (DC_SPI : not null HAL.GPIO.Any_GPIO_Point) is
   begin
      DC_SPI.Clear;
   end Select_Command_Mode;

end SH1107.SPI;
