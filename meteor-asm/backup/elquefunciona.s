    .thumb
    .syntax unified
        .global Reset_Handler

    .section .vectors
    .word __stack
    .word Reset_Handler

    .text
    .thumb_func

    Reset_Handler:
        mov r6, #42

    main:
       b loop 

    loop:
        ldr R0, =0x50000518
        ldr R1, [R0]
        orr R1, #(1<<2)
        str R1, [R0]

        ldr R0, =0x50000508
        ldr R1, [R0]
        orr R1, #(1<<2)
        str R1, [R0]
        b loop
