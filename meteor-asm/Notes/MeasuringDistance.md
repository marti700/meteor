# Distance Measurements Using Ultrasonic Sensor (HC-SR04)

To measure distances accurately for our obstacle avoidance module, we'll use an ultrasonic sensor. Specifically, we've chosen the HC-SR04 module. Here's how it works:

1. **Principle of Operation**:
   - The HC-SR04 emits a burst of sound waves from its trigger pin.
   - If there's an obstacle in front of the sensor, the echo pin will go high.
   - The distance to the object is proportional to the time the echo pin stays high.
   - By dividing this time by 58, we can calculate the distance in centimeters.

2. **Procedure**:
   - Keep the trigger pin high for at least 10 microseconds.
   - Measure the time the echo pin stays high.
   - Calculate the distance using the formula: `distance (cm) = (time_echo_high / 58)`.
   - Wait for at least 80 milliseconds before triggering again.

3. **Time Measurement**:
   - To measure time accurately, we have options with the nRF52833:
     - **Manual Calculation**: We can manually calculate time based on the MCU clock frequency (64 MHz). Each second corresponds to 64 million clock cycles.
     - **MCU Clock Peripheral**: Alternatively, we can use the MCU's built-in clock peripheral for precise timing.


# Ultrasonic Distance Measurement with HC-SR04 Sensor Overview

In our obstacle avoidance module, we'll use an ultrasonic sensor (specifically the HC-SR04 module) to measure distances. Let's break down the process step by step:

1. **Sensor Overview**:
   - The HC-SR04 emits a burst of sound waves from its trigger pin.
   - If there's an obstacle in front of the sensor, the echo pin will go high.
   - The distance to the object is proportional to the time the echo pin stays high.
   - By dividing this time by 58, we can calculate the distance in centimeters.

2. **GPIO Initialization**:
   - We configure the microcontroller pins:
     - Pin 0 (output): Used for testing the HC-SR04 sensor.
     - Pin 1 (output): Connected to the trigger pin of the HC-SR04.
     - Pin 2 (input): Connected to the echo pin of the HC-SR04.
   - We enable the input buffer and configure the pulldown resistor for pin 2.

3. **Timer Initialization**:
   - We set up the timer:
     - Stop the timer, clear it, and clear event registers.
     - Set the timer to 32-bit mode.
     - Set the prescaler to achieve a 1 MHz clock.
     - Configure Capture Compare registers (CC0 for 10 μs and CC3 for 80 ms).

4. **Trigger Logic**:
   - We set the trigger pin (pin 1) high to send an ultrasound burst.
   - Wait for 10 μs (time for the trigger signal).
   - Set the trigger pin low.
   - Reset the timer and wait for the echo pin to go high.

5. **Echo Detection**:
   - When the echo pin goes high, start the timer.
   - Wait for the echo pin to go low.
   - Capture the timer value when the echo pin goes low.

6. **Distance Calculation**:
   - Calculate the time duration (in microseconds) the echo pin stayed high.
   - Divide this time by 58 to get the distance in centimeters.
   - If the distance is less than or equal to 5 cm, turn on an LED (indicating an obstacle).

7. **Wait and Repeat**:
   - Wait for 80 ms (recommended by the sensor datasheet).
   - Start the measurement process again.


here is the complete code with comments:


```c++
    .thumb
    .syntax unified
    .global main

    .text
    .thumb_func

    .equ eighty_ms, 800000
    .equ TIMER0_BASE, 0x40008000
    .equ GIPIO_BASE, 0x50000000
    .equ TIMER_PRESCALER, 4

    // IMPORTANT STUFF
    // for some reason the reset button of the microbit needs to be pressed for this program to work
    // i don't know why but hopefully one of this days i will know XD

   // This assembly code is used to measure distances using the hs-sr04 ultrasonic
   // sensor and it works as follows:

   // 1. set pin 2 and 3 to output
   // 2. set pin 4 to input
   // 3. set pin 3 high (to engage the trigger pin)
   // 4. wait 10_us
   // 5. set pin 3 low (to disable the trigger pin)
   // 6. waits for the echo pin to go high
   // 7. measures the time the echo pin is high
   // 8. check the distance

    main:
        bl init_gpio
        b measure_distance

    measure_distance:
        b init_trigger

    init_gpio:
        ldr R0, =GIPIO_BASE // load the DIRSET register to R0
        ldr R1, [R0] // load R0 contents to R1

        orr R1, #(1<<2) // set bit 2 of DIRSET to 1
        orr R1, #(1<<3) // set bit 3 of DIRSET to 1
        str R1, [R0, #0x518] // store the new value of R1 to R0, this will set microbit pin 0 and 1 to ouput

        ldr R1, [R0, #0x514]
        bic R1, #(1<<4)
        str R1, [R0, #0x514] // set pin 2 of micro bit to input

        // in order for the input pin to work one must enable the input buffer in the PIN_CNF[n] register
        // (where n is the pin number), one must also specify if the input will be pulldown or pullup to get
        // reproducile behavior (this is also configured in the PIN_CNF[n] register)
        ldr r1, [r0, #0x710]
        mov r1, #0x4
        str r1, [r0, #0x710] // enables pin 2 input buffer and configure pulldown resistor

        bx lr

    init_timer:
        ldr r0, =TIMER0_BASE
        mov r1, #1
        str r1, [r0, #0x004] // stop timer
        str r1, [r0, #0x00C] // clear timer

        mov r1, #0
        str r1, [r0, #0x140] // clear 10_us event
        str r1, [r0, #0x14C] // clear 80 ms event

        @ set bit mode to 32 bits
        mov r1, #3
        str r1, [r0, #0x508]

        ldr r1, =TIMER_PRESCALER
        str r1, [r0, #0x510]

        @ set caputure register 0 to 10 micro seconds
        mov r1, #10
        str r1, [r0, #0x540]

        @ set capture register 3 to 80 ms
        ldr r1, =eighty_ms
        str r1, [r0, #0x54C]

        bx lr

    init_trigger:
        bl init_timer
        ldr r0, =GIPIO_BASE
        // set trigger high
        ldr r1, [r0, #0x504]
        orr r1, #(1<<3)
        str r1, [r0, #0x504]
        bl start_timer
        bl wait_10_us
        // set trigger low
        ldr r0, =GIPIO_BASE
        ldr r1, [r0, #0x504]
        bic r1, #(1<<3)
        str r1, [r0, #0x504]
        bl init_timer
        b wait_for_echo

    wait_10_us:
        ldr r1, [r0, #0x140]
        tst r1, #(1<<0)
        bne wait_10_us
        bx lr

    wait_for_echo:
        ldr r0, =GIPIO_BASE
        ldr r1, [r0, #0x510]
        tst r1, #(1<<4)

        /// THIS IS A TIMEOUT its porpouse is to start measuring distance from the
        //beginning when no echo is recieved but apparently this is not necessary
        @ ldr r2, =TIMER0_BASE
        @ ldr r3, [r2, #0x14C]
        @ tst r3, #1
        @ beq measure_distance
        ///

        beq wait_for_echo
        bl start_timer
        b wait_echo_to_go_low

    wait_echo_to_go_low:
        ldr r0, =GIPIO_BASE
        ldr r1, [r0, #0x510]
        tst r1, #(1<<4)
        bne wait_echo_to_go_low

        @ bl capture_time
        ldr r0, =TIMER0_BASE
        mov r1, #1
        str r1, [r0, #0x044]

        b check_distance


    check_distance:
        ldr r0, =TIMER0_BASE
        ldr r1, [r0, #0x544]
        cmp r1, #290 //290 is 5cm
        ble led_on
        bgt led_off

    wait_80_ms:
        bl init_timer
        ldr r1, [r0, #0x14C]
        tst r1, #1
        bne wait_80_ms

        b measure_distance

    start_timer:
        ldr r0, =TIMER0_BASE
        mov r1, #1
        str r1, [r0, #0x000]

        bx lr

    led_on:
        ldr R0, =GIPIO_BASE // load OUT register to R0
        ldr R1, [R0, #0x504] // load contents of R0 to R1
        orr R1, #(1<<2) // toogle bit 2 of OUT register on/off
        str R1, [R0, #0x504] // store contents the new value of R1 to R0, this will set pin 2 high
        b wait_80_ms
    led_off:
        ldr R0, =GIPIO_BASE // load OUT register to R0
        ldr R1, [R0, #0x504] // load contents of R0 to R1
        and R1, #(0<<2) // toogle bit 2 of OUT register on/off
        str R1, [R0, #0x504] // store contents the new value of R1 to R0, this will set pin 2 high
        b wait_80_ms
```
