.thumb
  .syntax unified
  .global main

  .text
  .thumb_func

  .equ one_second, 30000000

  main:
    @ bl measure_distance
    bl init_PCA9685
    bl go_forward
    ldr r1, =one_second

  wait_one_second:
    sub r1, r1, #1
    cmp r1, #0
    bne wait_one_second

    bl car_stop
    ldr r1, =one_second

  wait_oone_second:
    sub r1, r1, #1
    cmp r1, #0
    bne wait_oone_second

    bl go_backwards
    ldr r1, =one_second

  wait_ooone_second:
    sub r1, r1, #1
    cmp r1, #0
    bne wait_ooone_second

    b main
