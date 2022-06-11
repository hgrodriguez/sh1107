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
with HAL.I2C;

private package SH1107.I2C is

   --------------------------------------------------------------------------
   --  Using the
   --     Port / Address: I2C of the screen
   --  writes
   --     Cmd: to the screen
   procedure Write_Command (Port    : not null HAL.I2C.Any_I2C_Port;
                            Address : HAL.I2C.I2C_Address;
                            Cmd     : HAL.UInt8);

   --------------------------------------------------------------------------
   --  Using the
   --     Port / Address: I2C of the screen
   --  writes
   --     Cmd with Arg: to the screen
   procedure Write_Command_Argument (Port    : not null HAL.I2C.Any_I2C_Port;
                                     Address : HAL.I2C.I2C_Address;
                                     Cmd     : HAL.UInt8;
                                     Arg     : HAL.UInt8);

   --------------------------------------------------------------------------
   --  Using the
   --     Port / Address: I2C of the screen
   --  Writes the
   --     Data: to the screen
   procedure Write_Data (Port    : not null HAL.I2C.Any_I2C_Port;
                         Address : HAL.I2C.I2C_Address;
                         Data    : HAL.UInt8_Array);

end SH1107.I2C;
