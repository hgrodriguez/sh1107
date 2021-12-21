with HAL;

package SH1107.Communication is

   type Channel is interface;
   type Any_Channel is access all Channel;

   procedure Transmit (C : Channel; Cmd  : HAL.UInt8) is abstract;
   procedure Transmit (C : Channel; Data : HAL.UInt8_Array) is abstract;

   type I2C_Channel is new Channel with private;
   function Construct (Port    : not null HAL.I2C.Any_I2C_Port;
                       Address : HAL.I2C.I2C_Address) return I2C_Channel;
   procedure Transmit (C : I2C_Channel; Cmd  : HAL.UInt8);
   procedure Transmit (C : I2C_Channel; Data : HAL.UInt8_Array);

private
   type I2C_Channel is new Channel with record
      Port    : HAL.I2C.Any_I2C_Port;
      Address : HAL.I2C.I2C_Address;
   end record;

end SH1107.Communication;
