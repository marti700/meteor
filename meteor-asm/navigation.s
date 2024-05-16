.thumb
  .syntax unified

  .global navigation_control

  .text
  .thumb_func

  .equ RNG_BASE, 0x4000D000
  .equ TASK_START, 0x000
  .equ TAST_STOP, 0x004
  .equ EVENTS_VALRDY, 0x100
  .equ CONFIG, 0x504
  .equ VALUE, 0x508

  .equ one_second, 2000
  .equ GIPIO_BASE, 0x50000000
  .equ THIRTY_CM, 1740 //1740 is 30cm

  navigation_control:
    bl measure_distance

  check_distance:
    bl get_cc_1 // puts CC1 register value to R1
    ldr r8, =THIRTY_CM
    cmp r1, r8
    ble find_new_path
    bgt advance
    b navigation_control

  @ led_on:
  @   ldr R0, =GIPIO_BASE // load OUT register to R0
  @   ldr R1, [R0, #0x504] // load contents of R0 to R1
  @   orr R1, #(1<<2) // toogle bit 2 of OUT register on/off
  @   str R1, [R0, #0x504] // store contents the new value of R1 to R0, this will set pin 2 high
  @   pop {lr}
  @   b navigation_control

  @ led_off:
  @   ldr R0, =GIPIO_BASE // load OUT register to R0
  @   ldr R1, [R0, #0x504] // load contents of R0 to R1
  @   and R1, #(0<<2) // toogle bit 2 of OUT register on/off
  @   str R1, [R0, #0x504] // store contents the new value of R1 to R0, this will set pin 2 high
  @   b navigation_control

  advance:
   bl go_forward
   b navigation_control
  find_new_path:
    bl car_stop
    // this write a random number to R! see rng.s file
    bl get_rnd_number
    tst r1, #1
    bne rotate_to_the_left // odd number
    b rotate_to_the_right

  rotate_to_the_right:
    bl rotate_right
    mov r5, #500
    bl delay_ms
    b navigation_control
  rotate_to_the_left:
    bl rotate_left
    mov r5, #500
    bl delay_ms
    b navigation_control

    @ bl go_forward
    @ ldr r5, =one_second
    @ bl delay_ms

    @ bl car_stop
    @ ldr r5, =one_second
    @ bl delay_ms

    @ bl go_backwards
    @ ldr r5, =one_second
    @ bl delay_ms

    @ bl rotate_left
    @ ldr r5, =one_second
    @ bl delay_ms

    @ bl rotate_right
    @ ldr r5, =one_second
    @ bl delay_ms

    @ bl rotate_around_axis_left_rear
    @ ldr r5, =one_second
    @ bl delay_ms

    @ bl rotate_around_axis_right_rear
    @ ldr r5, =one_second
    @ bl delay_ms

    @ bl rotate_around_axis_left_front
    @ ldr r5, =one_second
    @ bl delay_ms

    @ bl rotate_around_axis_right_front
    @ ldr r5, =one_second
    @ bl delay_ms

    @ bl go_sideways_left
    @ ldr r5, =one_second
    @ bl delay_ms

    @ bl go_sideways_right
    @ ldr r5, =one_second
    @ bl delay_ms

    @ bl go_digonal_upwards_right
    @ ldr r5, =one_second
    @ bl delay_ms

    @ bl go_diagonal_upwards_left
    @ ldr r5, =one_second
    @ bl delay_ms

    @ bl go_diagonal_downwards_right
    @ ldr r5, =one_second
    @ bl delay_ms

    @ bl go_diagonal_downwards_left
    @ ldr r5, =one_second
    @ bl delay_ms