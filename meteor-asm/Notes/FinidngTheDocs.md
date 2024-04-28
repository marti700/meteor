# Step One: Finding the Documentation

When working with assembly language, understanding the documentation for the
chips you're using is crucial. Let's explore the relevant documentation for this
project:

1. **nRF52833 Chip (Micro:bit)**: - The micro:bit utilizes the nRF52833 chip.
Since we'll be writing the robot software in assembly, it's essential to
understand how this chip operates. You can find detailed information in the
nRF52833 documentation[^1].

2. **Micro:bit Schematics and Pinout**: - Familiarize yourself with the
micro:bit's schematics[^2] and explore its connector and pinout[^3].
Understanding the hardware layout is essential for successful assembly
programming.

3. **micro:Driver Expansion Board (DFRobot)**: - We'll be using the
micro:Driver[^4], a driver expansion board for the micro:bit. Refer to the board
documentation[^5] to understand its features and connections. Additionally,
review the board's schematics[^6].

4. **PCA9685PW Chip (Motor Control)**: - The micro:Driver communicates with a
PCA9685PW chip to control the motors. Refer to the PCA9685PW datasheet[^7] for
details on these chip.

5. **HR8833 Motor Drivers**: - The micro:bit expansion board also features two
HR8833 motor drivers. Refer to the HR8833 datasheet[^8] for details on these
motor drivers.

Remember, thorough documentation study is the foundation for successful assembly
programming. Let's dive into the details and build our self-driving robot car!

[^1]: https://docs.nordicsemi.com/bundle/nRF52833_PS_v1.6/resource/nRF52833_PS_v1.6.pdf
[^2]: https://tech.microbit.org/hardware/schematic/
[^3]: https://tech.microbit.org/hardware/edgeconnector/
[^4]: https://www.dfrobot.com/product-1738.html
[^5]: https://wiki.dfrobot.com/Micro_bit_Driver_Expansion_Board_SKU_DFR0548
[^6]: https://github.com/Arduinolibrary/Micro_bit_Driver_Expansion_Board/blob/master/Microbit%20Driver%20Expansion%20Board.PDF
[^7]: https://pdf1.alldatasheet.com/datasheet-pdf/view/293577/NXP/PCA9685PW.html
[^8]: https://media.digikey.com/pdf/Data%20Sheets/DFRobot%20PDFs/DRI0040_Web.pdf