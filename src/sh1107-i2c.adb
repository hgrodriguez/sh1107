package body SH1107.I2C is

   procedure Write_Command (Port    : not null HAL.I2C.Any_I2C_Port;
                            Address : HAL.I2C.I2C_Address;
                            Cmd     : HAL.UInt8)
   is
      Status : HAL.I2C.I2C_Status;
      use HAL.I2C;
   begin
      Port.Master_Transmit (Addr    => Address,
                            Data    => (1 => 0, 2 => (Cmd)),
                            Status  => Status);
      if Status /= HAL.I2C.Ok then
         --  No error handling...
         raise Program_Error;
      end if;
   end Write_Command;

   procedure Write_Data (Port    : not null HAL.I2C.Any_I2C_Port;
                         Address : HAL.I2C.I2C_Address;
                         Data    : HAL.UInt8_Array)
   is
      Status : HAL.I2C.I2C_Status;
      use HAL.I2C;
   begin
      Port.Master_Transmit (Addr    => Address,
                            Data    => Data,
                            Status  => Status);
      if Status /= HAL.I2C.Ok then
         --  No error handling...
         raise Program_Error;
      end if;
   end Write_Data;

end SH1107.I2C;
