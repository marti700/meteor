.thumb
  .syntax unified
  .global main

  .text
  .thumb_func

  .equ one_second, 30000000

  main:
    @ bl measure_distance
    bl init_PCA9685
    bl m1_reverse
    ldr r1, =one_second

  wait_one_second:
    sub r1, r1, #1
    cmp r1, #0
    bne wait_one_second

    bl m1_stop
    ldr r1, =one_second

  wait_oone_second:
    sub r1, r1, #1
    cmp r1, #0
    bne wait_oone_second

    b main
