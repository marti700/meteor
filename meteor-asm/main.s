.thumb
  .syntax unified
  .global main

  .text
  .thumb_func

  main:
    bl measure_distance
    b main
