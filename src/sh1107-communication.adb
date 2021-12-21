package body SH1107.Communication is

   function Construct (Port    : not null HAL.I2C.Any_I2C_Port;
                       Address : HAL.I2C.I2C_Address) return I2C_Channel is
      My_I2C : I2C_Channel;
   begin
      My_I2C.Port := Port;
      My_I2C.Address := Address;
      return My_I2C;
   end Construct;

   procedure Transmit (C : I2C_Channel; Cmd  : HAL.UInt8) is
   begin
      null;
   end Transmit;

   procedure Transmit (C : I2C_Channel; Data : HAL.UInt8_Array) is
   begin
      null;
   end Transmit;

end SH1107.Communication;
