# sh1107
Driver implementation for the SH1107 driver used by OLED displays

## Connection capabilities
1. I2C - Implemented
2. SPI - Planned to implement

## TO DO:
1. use the newest pico_bsp/rp2040_hal libraries
2. implement SPI

## Versioning scheme
Major.Minor.Patch

### Major
1 = I2C; Status: **Implemented**

2 = I2C + SPI; Status: **Implemented**

### Minor
1 = basic version; implementation only supports orentiation UP [without any selection possibility] -> OLED is pointing UPwards, when looking from front and the small flat cable is at the bottom of the display

2 = implementation supports UP/RIGHT/DOWN/LEFT orientation, so the OLED can be used in any desirable orientation

