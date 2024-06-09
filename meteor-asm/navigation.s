  @ This file defines function that control the car navigation logic
.thumb
  .syntax unified

  .global navigation_control

  .text
  .thumb_func

  .equ one_second, 2000
  .equ GIPIO_BASE, 0x50000000
  .equ THIRTY_CM, 1740 //1740us is 30cm

  go_to_mode_selection:
    bl car_stop
    b select_mode

  navigation_control:
    bl rc_pin_pulled_low
    cmp r1, #1
    beq go_to_mode_selection

    bl init_rng
    bl measure_distance

    check_distance:
    bl get_cc_1 // get CC1 register value from R1
    ldr r8, =THIRTY_CM
    cmp r1, r8
    ble find_new_path
    bgt advance
    b navigation_control

  advance:
   bl go_forward
   b navigation_control

  find_new_path:
    bl car_stop
    // this write a random number to R! see rng.s file
    bl get_rnd_number
    tst r1, #1 // test if the number is even/odd
    bne rotate_to_the_left // odd number
    b rotate_to_the_right // rotate right when number is even

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
