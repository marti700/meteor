.thumb
  .syntax unified
  .global main

  .text
  .thumb_func

  .equ one_second, 2000

  main:
    @ bl measure_distance
    bl init_PCA9685
    bl go_forward
    ldr r5, =one_second
    bl delay_ms

    bl car_stop
    ldr r5, =one_second
    bl delay_ms

    bl go_backwards
    ldr r5, =one_second
    bl delay_ms

    bl rotate_left
    ldr r5, =one_second
    bl delay_ms

    bl rotate_right
    ldr r5, =one_second
    bl delay_ms

    bl rotate_around_axis_left_rear
    ldr r5, =one_second
    bl delay_ms

    bl rotate_around_axis_right_rear
    ldr r5, =one_second
    bl delay_ms

    bl rotate_around_axis_left_front
    ldr r5, =one_second
    bl delay_ms

    bl rotate_around_axis_right_front
    ldr r5, =one_second
    bl delay_ms

    bl go_sideways_left
    ldr r5, =one_second
    bl delay_ms

    bl go_sideways_right
    ldr r5, =one_second
    bl delay_ms

    bl go_digonal_upwards_right
    ldr r5, =one_second
    bl delay_ms

    bl go_diagonal_upwards_left
    ldr r5, =one_second
    bl delay_ms

    bl go_diagonal_downwards_right
    ldr r5, =one_second
    bl delay_ms

    bl go_diagonal_downwards_left
    ldr r5, =one_second
    bl delay_ms

    b main
