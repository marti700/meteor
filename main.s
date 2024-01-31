    .thumb
    .syntax unified
    .global main

    .text
    .thumb_func

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
