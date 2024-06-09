    // This file contains functions that allow the user to select
    // between the robot autonomus mode or the RC mode
    .thumb
    .syntax unified

    .global select_mode

    .text

    .thumb_func

    .equ RC_BUTTON_ONE,               0xffa25d
    .equ RC_BUTTON_TWO,               0xff629d

    // this fuction is executed until the user selects a mode using the IR controller
    // button 1 puts the robot in RC mode.
    // buttons 2 puts the robot in autonomus mode
    // any other button press will have no effect
    select_mode:
        bl prepare_for_ir_transmission
        bl on_transmission_start
        //RC mode
        ldr r6, =RC_BUTTON_ONE
        cmp r5, r6
        beq enter_rc_mode
        // autonommus mode
        ldr r6, =RC_BUTTON_TWO
        cmp r5, r6
        beq enter_autonomus_mode

        b select_mode

    enter_rc_mode:
        mov r5, #0
        b rc_mode

    enter_autonomus_mode:
        mov r5, #0
        b navigation_control
