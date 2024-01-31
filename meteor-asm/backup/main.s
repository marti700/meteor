    .thumb
    .syntax unified

    .text

    main:
        ldr r0, =$50000518
        ldr r1, [R0]
        orr r1, #(1<<2)
        str r1, [R0]

        ldr r0, =#50000508
        ldr r1, [R0]
        orr r1, #(1<<2)
        str r1, [R0]
       b loop 

    loop:
        b loop
