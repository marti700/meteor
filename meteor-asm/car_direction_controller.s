  @ This file defines low level functions to control the direction of the car

  .thumb
  .syntax unified

  .global go_forward
  .global car_stop
  .global go_backwards
  .global rotate_left
  .global rotate_right
  .global go_sideways_right
  .global go_sideways_left
  .global go_digonal_upwards_right
  .global go_diagonal_downwards_left
  .global go_diagonal_upwards_left
  .global go_diagonal_downwards_right
  .global rotate_around_axis_left_rear
  .global rotate_around_axis_right_rear
  .global rotate_around_axis_right_front
  .global rotate_around_axis_left_front

  .text
  .thumb_func

  go_forward:
    push {lr}
    bl m1_forward
    bl m2_forward
    bl m3_forward
    bl m4_forward
    pop {lr}
    bx lr

  car_stop:
    push {lr}
    bl m1_stop
    bl m2_stop
    bl m3_stop
    bl m4_stop
    pop {lr}
    bx lr

  go_backwards:
    push {lr}
    bl m1_reverse
    bl m2_reverse
    bl m3_reverse
    bl m4_reverse
    pop {lr}
    bx lr

  rotate_left:
    push {lr}
    bl m1_forward
    bl m2_forward
    bl m3_reverse
    bl m4_reverse
    pop {lr}
    bx lr

  rotate_right:
    push {lr}
    bl m1_reverse
    bl m2_reverse
    bl m3_forward
    bl m4_forward
    pop {lr}
    bx lr

  go_sideways_right:
    push {lr}
    bl m1_forward
    bl m2_reverse
    bl m3_forward
    bl m4_reverse
    pop {lr}
    bx lr

  go_sideways_left:
    push {lr}
    bl m1_reverse
    bl m2_forward
    bl m3_reverse
    bl m4_forward
    pop {lr}
    bx lr

  go_digonal_upwards_right:
    push {lr}
    bl m1_forward
    bl m2_stop
    bl m3_forward
    bl m4_stop
    pop {lr}
    bx lr

  go_diagonal_downwards_left:
    push {lr}
    bl m1_reverse
    bl m2_stop
    bl m3_reverse
    bl m4_stop
    pop {lr}
    bx lr

  go_diagonal_upwards_left:
    push {lr}
    bl m1_stop
    bl m2_forward
    bl m3_stop
    bl m4_forward
    pop {lr}
    bx lr

  go_diagonal_downwards_right:
    push {lr}
    bl m1_stop
    bl m2_reverse
    bl m3_stop
    bl m4_reverse
    pop {lr}
    bx lr

  rotate_around_axis_right_rear:
    push {lr}
    bl m1_stop
    bl m2_reverse
    bl m3_forward
    bl m4_stop
    pop {lr}
    bx lr

  rotate_around_axis_left_rear:
    push {lr}
    bl m1_stop
    bl m2_forward
    bl m3_reverse
    bl m4_stop
    pop {lr}
    bx lr

  rotate_around_axis_right_front:
    push {lr}
    bl m1_reverse
    bl m2_stop
    bl m3_stop
    bl m4_forward
    pop {lr}
    bx lr

  rotate_around_axis_left_front:
    push {lr}
    bl m1_forward
    bl m2_stop
    bl m3_stop
    bl m4_reverse
    pop {lr}
    bx lr



