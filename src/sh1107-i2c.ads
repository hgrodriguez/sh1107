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
   --  Writes the
   --     Cmd: to the OLED using
   --     Port / Address: I2C of the device
   procedure Write_Command (Port    : not null HAL.I2C.Any_I2C_Port;
                            Address : HAL.I2C.I2C_Address;
                            Cmd     : HAL.UInt8);

   --------------------------------------------------------------------------
   --  Writes the
   --     Cmd: to the OLED with the
   --     Arg: using
   --     Port / Address: I2C of the device
   procedure Write_Command_Argument (Port    : not null HAL.I2C.Any_I2C_Port;
                                     Address : HAL.I2C.I2C_Address;
                                     Cmd     : HAL.UInt8;
                                     Arg     : HAL.UInt8);

   --------------------------------------------------------------------------
   --  Writes the
   --     Data: to the OLED using
   --     Port / Address: I2C of the device
   procedure Write_Data (Port    : not null HAL.I2C.Any_I2C_Port;
                         Address : HAL.I2C.I2C_Address;
                         Data    : HAL.UInt8_Array);

end SH1107.I2C;
