## Getting Started: Turning on an LED on a Breadboard

This section guides you through lighting up an LED connected to a breadboard
using the micro:bit.

### Tools

* micro:Bit Driver Expansion Board (link to micro:Bit Driver board: [https://www.dfrobot.com/product-1738.html](https://www.dfrobot.com/product-1738.html))
* Breadboard (link to breadboard: [https://www.amazon.com/Breadboards-Solderless-Breadboard-Distribution-Connecting/dp/B07DL13RZH/ref=sr_1_3_pp?crid=1U2EO7TVS29AK&keywords=breadboard&qid=1707004468&sprefix=breadbor%2Caps%2C173&sr=8-3](https://www.amazon.com/Breadboards-Solderless-Breadboard-Distribution-Connecting/dp/B07DL13RZH/ref=sr_1_3_pp?crid=1U2EO7TVS29AK&keywords=breadboard&qid=1707004468&sprefix=breadbor%2Caps%2C173&sr=8-3))
* LED (link to LED: [https://www.amazon.com/dp/B07PG84V17?ref=ppx_yo2ov_dt_b_product_details&th=1](https://www.amazon.com/dp/B07PG84V17?ref=ppx_yo2ov_dt_b_product_details&th=1))
* Resistor (any value will work for this project) (link to resistors: [https://www.amazon.com/dp/B0CN479PHC?ref=ppx_yo2ov_dt_b_product_details&th=1](https://www.amazon.com/dp/B0CN479PHC?ref=ppx_yo2ov_dt_b_product_details&th=1))
* Jumper wires (link to jumper wires: [invalid URL removed])

### Setup

1. **Connect the resistor and LED:** Insert both the resistor (any value will
do) and the LED into the breadboard. The longer leg of the LED (positive lead)
typically has a flat edge, while the shorter leg (negative lead) is round. Note
that it doesn't matter which way the resistor goes in the circuit.

2. **Connect jumper wires to power:** Use a female-to-male jumper wire. Connect
the male end to the power rails of the breadboard. The black wire typically
connects to ground (negative), and the red or yellow wire connects to VCC
(positive).

3. **Connect micro:bit to expansion board:** Attach the micro:bit securely to
the expansion board.

4. **Connect LED to micro:bit:** Connect the yellow jumper wire to pin 0 (on the
green lead) of the microbit expansion board. Connect the black jumper wire to
the black lead (negative side) of the LED.

### Explanation

The resistor is crucial in this circuit because the micro:bit can send a
relatively high current through pin 0. This current can damage the LED if not
limited. The resistor reduces the current to a safe level for the LED to operate
properly.

We use the yellow jumper wire on the green lead of pin 0 because this is the
microbit pin we will use to control the LED. The green leads on the expansion
board connect directly to their corresponding microbit pins. All the red leads
typically provide 3.3 volts, and all the black leads connect to ground. While
you could connect the black jumper wire to any of these ground points,
connecting it to the same pin you're using for control helps avoid confusion.

##  Coming Up Next...

In the next section, we'll delve into writing the code to control the LED using
ARM assembly language. We'll explore linker scripts, GPIO pins, and essential
functions like `Reset_Handler` and `main`.


## Delving into the Code: Turning on the LED with Assembly

Now that the circuit is set up, let's write the code to control the LED using
ARM assembly language. Here, we'll break down the code into two main sections:


## Delving into the Code: Turning on the LED with Assembly

Now that the circuit is set up, let's write the code to control the LED using
ARM assembly language. Here, we'll break down the code into two main sections:

**1. Assembly Code:**

The assembly code defines the instructions for the microcontroller to understand
and execute.

* **Linker Script:** We'll need a linker script to tell the compiler how to
 organize the code in the microcontroller's memory. You'll find resources
 online to learn how to create linker scripts specifically for the nRF52833
 microcontroller used in the micro:bit v2[^1].
* **Reset Handler Function (`Reset_Handler`):** This function gets called when
 the microcontroller powers on. Its primary purpose is to initialize essential
 settings and then call the `main` function, which is the heart of our program.

**Here's an example `Reset_Handler` function:**

```c++
.thumb // code in thumb mode
.syntax unified // uses unified syntax
.global Reset_Handler  // function can be seen by all assembly files

.section .vectors // declares the vector section
.word __stack
.word Reset_Handler  // reset handler jumps to this function

.text  // code is in the text section
.thumb_func

Reset_Handler:
  b main  // branch to main function

```

**2. Main Function (main):**

The main function is where the core functionalities of our program reside.
Here's how we'll control the LED:

**GPIO Pin Configuration:** The microbit v2 utilizes an nRF52833
microcontroller. We need to understand how the General Purpose Input/Output
(GPIO) pins work on this chip. Refer to the nRF52833 documentation[^2] for
detailed information on GPIO functionalities.

**Setting the Pin as Output:** We'll use assembly instructions to configure the
specific pin (pin 0 in this case) connected to the LED as an output pin.

**Turning on the LED:** Once the pin is set as output, we'll use instructions to
send a high signal (logic 1) to that pin, effectively turning on the LED.

Here's a basic example `main` function structure:

```c++
.thumb // code in thumb mode
.syntax unified // uses unified syntax
.global main // main function is global

.text  // code is in the text section
.thumb_func

main:
  ; Code to configure pin 0 as output
  ; Code to send a high signal to pin 0 (turning on LED)

  b loop  // branch to an infinite loop (optional)

loop:
  ; Code to repeat turning the LED on/off (optional)

  b loop  // branch back to loop

```

This is a simplified example, and the actual assembly instructions to configure
the pin and control the LED will depend on the specific nRF52833 registers and
instructions.

In the next section, we'll explore the code in more detail, including the
assembly instructions for pin configuration and LED control.

## Going Deeper: Assembly Code for LED Control

In the previous section, we discussed the high-level concepts of the code. Now,
let's dive into the specifics of the assembly instructions used to control the
LED.

1. **Understanding nRF52833 Registers:**

The nRF52833 microcontroller has dedicated registers for controlling GPIO pins.
Here are two key registers we'll use:

DIRSET Register (0x50000518): This register allows us to set specific GPIO pins
as outputs. Each bit in the DIRSET register corresponds to a GPIO pin. Setting a
bit to 1 configures the corresponding pin as output, while a 0 sets it as input.

OUTSET Register (0x50000508): This register controls the output state of the
GPIO pins. Setting a bit to 1 in the OUTSET register sends a high signal (logic
1) to the corresponding pin, and vice versa for a 0.

2. **Assembly Code for LED Control:**

Here's the complete main function with assembly instructions for controlling the
LED:

```c++
.thumb // code in thumb mode
.syntax unified // uses unified syntax
.global main // main function is global

.text  // code is in the text section
.thumb_func

main:
  // Set pin 2 (mapped to micro:bit pin 0) as output
  ldr R0, =0x50000518  // Load DIRSET register address into R0
  ldr R1, [R0]          // Load current value of DIRSET register into R1
  orr R1, #(1<<2)        // Set bit 2 of R1 (corresponding to pin 2) to 1 using OR operation
  str R1, [R0]          // Store the modified value back to DIRSET register

  // Turn on the LED (connected to pin 2)
  ldr R0, =0x50000508  // Load OUTSET register address into R0
  ldr R1, [R0]          // Load current value of OUTSET register into R1
  orr R1, #(1<<2)        // Set bit 2 of R1 to 1 to send high signal to pin 2
  str R1, [R0]          // Store the modified value back to OUTSET register

  b loop  // Branch to an infinite loop (optional)

loop:
  // Code to repeat turning the LED on/off (optional)

  b loop  // Branch back to loop

```

### Explanation:

**Setting Pin as Output:**

- `ldr R0, =0x50000518`: This instruction loads the address of the DIRSET register (0x50000518) into register R0.
- `ldr R1, [R0]`: This line loads the current value of the DIRSET register into register R1.
- `orr R1, #(1<<2)`: Here, we perform a bitwise OR operation. The operand #(1<<2) creates a binary value with only the bit position 2 set to 1 (other bits are 0). Performing the OR operation with the current value in R1 ensures that bit 2 is set to 1.
- `str R1, [R0]`: Finally, we store the modified value back into the DIRSET register, effectively configuring pin 2 (mapped to micro:bit pin 0) as an output pin.

**Turning on the LED:**

- `ldr R0, =0x50000508`: This line loads the address of the OUTSET register (0x50000508) into R0.
- `ldr R1, [R0]`: Similar to the previous step, we load the current value of the OUTSET register into R1.
- `orr R1, #(1<<2)`: Again, we perform a bitwise OR operation to set bit 2 of R1 to 1, sending a high signal (logic 1) to pin 2.
- `str R1, [R0]`: We store the modified value back into the OUTSET register, turning on the LED connected to pin 2.

3. **Loop (Optional):**

The loop section is optional and allows you to create a loop that repeatedly
turns the LED on and off. You can add your desired logic within the loop to
control the LED's blinking pattern.


[^1]: I have used a modified version of this one: https://github.com/cpmpercussion/microbit-v2-baremetal/blob/main/nRF52833.ld you can see it in the linker.ld file. What i did was remove the interrupts functions from the vector table.
[^2]: https://docs.nordicsemi.com/bundle/nRF52833_PS_v1.6/resource/nRF52833_PS_v1.6.pdf


