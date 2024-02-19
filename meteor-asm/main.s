    .thumb
    .syntax unified
    .global main

    .text
    .thumb_func

    .equ onesecond, 16000000

    main:
        // set pin 2 as output
        ldr R0, =0x50000518 // load the DIRSET register to R0
        ldr R1, [R0] // load R0 contents to R1
        orr R1, #(1<<2) // set bit 2 of DIRSET to 1
        str R1, [R0] // store the new value of R1 to R0, this will set pin 2 to ouput
        b loop // branch to loop 

    loop:
        ldr R5, =onesecond // 64 million clock cycles is aproximately 1 second
        bl turn_led_on // turn led on 
        bl delay1second // wait one second
        ldr R5, =onesecond // 64 million clock cycles is aproximately 1 second
        bl turn_led_off // turn led off 
        bl delay1second // wait one second
        b loop // start over
    
    delay1second:
        // substract 1 from r5, and store the new value in r5
        // eventually r5 is going to be 
        subs R5,R5, #1   
        bne delay1second // if 
        bx lr
    
    turn_led_on:
        ldr R0, =0x50000508 // load OUTSET register to R0
        ldr R1, [R0] // load contents of R0 to R1
        orr R1, #(1<<2) // set bit 2 of OUTSET to 1
        str R1, [R0] // store contents the new value of R1 to R0, this will set pin 2 high
        bx lr

    turn_led_off:
        ldr R0, =0x5000050C // load OUTCLR register to R0
        ldr R1, [R0] // load contents of R0 to R1
        orr R1, #(1<<2) // set bit 2 of OUTCLR to 1
        str R1, [R0] // store contents the new value of R1 to R0, this will set pin 2 low
        bx lr


