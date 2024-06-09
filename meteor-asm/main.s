.thumb
  .syntax unified
  .global main

  .text
  .thumb_func

  .equ one_second, 2000

  main:
    bl init_PCA9685
    b select_mode
