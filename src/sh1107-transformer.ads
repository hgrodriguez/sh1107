private package SH1107.Transformer is

   THE_VARIANT : constant Integer := 1;

   function Get_Byte_Index (O    : SH1107_Orientation;
                            X, Y : Natural) return Natural;

   function Get_Bit_Mask (O    : SH1107_Orientation;
                          X, Y : Natural) return HAL.UInt8;

end SH1107.Transformer;
