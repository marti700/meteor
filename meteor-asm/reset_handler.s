    .thumb
    .syntax unified
    .global Reset_Handler

    .section .vectors
    .word __stack
    .word Reset_Handler

    .text
    .thumb_func

    Reset_Handler:
        b main
