.thumb
  .syntax unified
  .global main

  .text
  .thumb_func

  .equ one_second, 30000000

  main:
    @ bl measure_distance
    bl init_PCA9685
    bl m1_forward
    bl m2_forward
    bl m3_forward
    bl m4_forward
    ldr r1, =one_second

  wait_one_second:
    sub r1, r1, #1
    cmp r1, #0
    bne wait_one_second

    bl m1_stop
    bl m2_stop
    bl m3_stop
    bl m4_stop
    ldr r1, =one_second

  wait_oone_second:
    sub r1, r1, #1
    cmp r1, #0
    bne wait_oone_second

    bl m1_reverse
    bl m2_reverse
    bl m3_reverse
    bl m4_reverse
    ldr r1, =one_second

  wait_ooone_second:
    sub r1, r1, #1
    cmp r1, #0
    bne wait_ooone_second

    b main
