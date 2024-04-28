# Building the Robot

Now that you know how to measure distance ([see Measuring Distance
guide](./MeasuringDistance.md)) and control a DC motor ([see the Making the
motors Turn guide](./MakingTheMotorsTurn.md)), we can assemble our robot! Since
the code for these functionalities is already explained elsewhere, this section
will focus on the final code structure after everything is put together.

I chose mecanum wheels because they allow the robot to move in any direction.
Here's the chassis I bought:
https://www.amazon.com/dp/B09CPZ51N4?psc=1&ref=ppx_yo2ov_dt_b_product_details

It has many holes, and I thought my PCB would fit on a set of them. However, it
would've been better to use cardboar or plexiglass with M3 copper pillars, and
directly attach the microbit to them. But since I have this chassis, I'll use
it.

**Note:** I won't detail the assembly process because this chassis isn't ideal
*for this project, and our focus is on the software. If you download the code,
*compile it for the microbit, and connect the microbit to the Df robot board, it
*should work.

## Making the Robot Move

As mentioned earlier, I'm using mecanum wheels. These wheels have rollers angled
at 45 degrees, allowing omnidirectional movement. To achieve this, you need four
wheels positioned in an X-shape. It's a bit tricky to explain with text, so
here's an image:

The rollers on each wheel should point towards the center of the robot.

Here's a guide to omnidirectional movement from Wikipedia for reference:
Wikipedia: Mecanum wheel: https://en.wikipedia.org/wiki/Mecanum_wheel

The basic movements (forward, backward, stop) for each motor are coded in
separate files named `m1_driver.s` (for motor 1), `m2_driver.s` (for motor 2),
and so on.

These "m" files control individual motor movements and send commands to the
`PCA9685PW` chip through the iic_driver.s file.

The iic_driver.s file enables communication with the `PCA9685PW` chip using I2C
protocol.

The overall car movement logic is coded in the `car_direction_controller.s`
file. This file incorporates the concepts explained in the Wikipedia article to
make the car move omnidirectionally.

## Distance Measurement

The code for distance measurement is located in the `hcsr04.s` file.

This file handles distance measurements using the HC-SR04 sensor. It relies
heavily on functions from the `timer_controller.s` file because distance
measurement with this sensor depends on sound travel time.

## Navigation Logic

The navigation logic is controlled by the `navigation.s` file. I've implemented
a simple logic here. Basically, when the HC-SR04 sensor detects an obstacle
within 30 cm, the car will stop and turn right for a second to avoid it. This
cycle repeats until you turn off the car.

## Limitations

The HC-SR04 ultrasonic sensor has a limited detection angle of less than 15
degrees. This means that if the car approaches a wall diagonally, and the
diagonal path exceeds 15 degrees, the sensor won't detect the obstacle, and the
car will collide.

This happens because the sound won't reflect back to the sensor. Instead, it
bounces off in a different direction!

Imagine the following: the square is the car moving towards a wall, and the
curved lines represent the sound waves emitted by the HC-SR04 sensor. In this
example (or if the angle is greater than 15 degrees), when the sound wave hits
the wall, it reflects in a different direction instead of bouncing back to the
sensor.

This limitation can be overcome by adding more sensors to the robot.