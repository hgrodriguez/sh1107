--===========================================================================
--
--  This package is the implementation of the I2C connection
--
--===========================================================================
--
--  Copyright 2021 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
package body SH1107.I2C is

   procedure Write_Command (Port    : not null HAL.I2C.Any_I2C_Port;
                            Address : HAL.I2C.I2C_Address;
                            Cmd     : HAL.UInt8) is
      use HAL;
      Correct_Address : constant HAL.I2C.I2C_Address := Address * 2;
      Status : HAL.I2C.I2C_Status;
      use HAL.I2C;
   begin
      Port.Master_Transmit (Addr    => Correct_Address,
                            Data    => (1 => 0, 2 => (Cmd)),
                            Status  => Status);
      if Status /= HAL.I2C.Ok then
         --  No error handling...
         raise Program_Error;
      end if;
   end Write_Command;

   procedure Write_Data (Port    : not null HAL.I2C.Any_I2C_Port;
                         Address : HAL.I2C.I2C_Address;
                         Data    : HAL.UInt8_Array) is
      use HAL;
      Correct_Address : constant HAL.I2C.I2C_Address := Address * 2;
      Status          : HAL.I2C.I2C_Status;
      use HAL.I2C;
   begin
      Port.Master_Transmit (Addr    => Correct_Address,
                            Data    => Data,
                            Status  => Status);
      if Status /= HAL.I2C.Ok then
         --  No error handling...
         raise Program_Error;
      end if;
   end Write_Data;

end SH1107.I2C;
