    .thumb
    .syntax unified

    .global select_mode

    .text

    .thumb_func

    .equ RC_BUTTON_ONE,               0xffa25d
    .equ RC_BUTTON_TWO,               0xff629d

    select_mode:
        bl prepare_for_ir_transmission
        bl on_transmission_start
        //RC mode
        ldr r6, = RC_BUTTON_ONE
        cmp r5, r6
        beq enter_rc_mode
        // autonommus mode
        ldr r6, = RC_BUTTON_TWO
        cmp r5, r6
        beq enter_autonomus_mode

    enter_rc_mode:
        mov r5, #0
        b rc_mode

    enter_autonomus_mode:
        mov r5, #0
        b navigation_control
