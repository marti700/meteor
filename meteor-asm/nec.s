.thumb
    .syntax unified

    .global nec


    .text
    .thumb_func

    .equ GIPIO_BASE,                  0x50000000
    .equ GPIOTE_BASE,                 0x40006000
    .equ GPIOTE_EVENTS_IN_0,          0x100
    .equ GPIOTE_CONFIG_0,             0x510
    .equ GPIOTE_CONFIG_0_CONF,        0x20201
    .equ NINE_SECONDS,                9000
    .equ RC_BUTTON_ONE,               0xffa25d
    .equ RC_BUTTON_TWO,               0xff629d
    .equ RC_BUTTON_THREE,             0xffe21d
    .equ RC_BUTTON_FOUR,              0xff22dd
    .equ RC_BUTTON_FIVE,              0xff02fd
    .equ RC_BUTTON_SIX,               0xffc23d
    .equ RC_BUTTON_SEVEN,             0xffe01f
    .equ RC_BUTTON_EIGHT,             0xffa857
    .equ RC_BUTTON_NINE,              0xff906f
    .equ RC_BUTTON_ZERO,              0xff9867
    .equ RC_BUTTON_ASTERISK,          0xff6897
    .equ RC_BUTTON_HASHTAG,           0xffb04f
    .equ RC_BUTTON_UP,                0xff18e7
    .equ RC_BUTTON_LEFT,              0xff10ef
    .equ RC_BUTTON_DOWN,              0xff4ab5
    .equ RC_BUTTON_RIGHT,             0xff5aa5
    @ .equ BUTTON_TABLE_SIZE,           12

    @ BUTTON_TABLE:
    @     .word drive_forward                 // Action for RC_BUTTON_LEFT (or any default button)
    @     .word drive_backwards               // Action for RC_BUTTON_RIGHT
    @     .word drive_diagonal_upper_right    // Action for RC_BUTTON_ONE
    @     .word drive_diagonal_upper_left     // Action for RC_BUTTON_SEVEN
    @     .word drive_diagonal_lower_right    // Action for RC_BUTTON_THREE
    @     .word drive_diagonal_lower_left     // Action for RC_BUTTON_NINE
    @     .word drive_sideways_right          // Action for RC_BUTTON_TWO
    @     .word drive_sideways_left           // Action for RC_BUTTON_EIGHT
    @     .word rotate_axis_front             // Action for RC_BUTTON_FOUR
    @     .word rotate_axis_back              // Action for RC_BUTTON_SIX
    @     .word rotate_right                  // Action for RC_BUTTON_UP
    @     .word rotate_left                   // Action for RC_BUTTON_DOWN

    nec:
        mov r8, #0
        ldr r2, =GPIOTE_BASE
        ldr r1, =GPIOTE_CONFIG_0_CONF
        str r1, [r2, #GPIOTE_CONFIG_0]

    on_pin_event:
        ldr r1, [r2, #GPIOTE_EVENTS_IN_0]
        tst r1, #1
        bne wait_for_status_change
        beq on_pin_event

    wait_for_status_change:
        cmp r8, #32
        beq execute_action
        ldr r2, =GPIOTE_BASE
        mov r1, #0
        str r1, [r2, #GPIOTE_EVENTS_IN_0]
        bl prepare_timer
    wait_for_status_change_inner:
        ldr r1, [r2, #GPIOTE_EVENTS_IN_0]
        tst r1, #1
        bne capture_time_inf
        b wait_for_status_change_inner

    prepare_timer:
        bl light_timer_reset
        bl start_timer
        b wait_for_status_change_inner

    capture_time_inf:
        @ cmp r3, #1
        @ beq ccc
        bl capture_time
        bl get_cc_1
        ldr r4, =NINE_SECONDS
        cmp r1, r4
        bgt wait_for_status_change
        cmp r1, #1600
        blt add_zero
        bgt add_one

    add_zero:
        lsl r5, 1
        orr r5, #(0<<0)
        add r8, r8, #1
        b wait_for_status_change
    add_one:
        lsl r5, 1
        orr r5, #(1<<0)
        add r8, r8, #1
        b wait_for_status_change

    execute_action:
        // go forward when the left button is pressed
        ldr r6, =RC_BUTTON_LEFT
        cmp r5, r6
        beq drive_forward
        // go backwards when the right button is pressed
        ldr r6, =RC_BUTTON_RIGHT
        cmp r5, r6
        beq drive_backwards

        // THE DIAGONALS
        // go upper diagonal right when button 1 is pressed
        ldr r6, =RC_BUTTON_ONE
        cmp r5, r6
        beq drive_diagonal_upper_right
        // go upper diagonal left when button 7 is pressed
        ldr r6, =RC_BUTTON_SEVEN
        cmp r5, r6
        beq drive_diagonal_upper_left
        // go downwards diagonal right when the button 3 is pressed
        ldr r6, =RC_BUTTON_THREE
        cmp r5, r6
        beq drive_diagonal_lower_right
        // go downwards diagonal left when button 9 is pressed
        ldr r6, =RC_BUTTON_NINE
        cmp r5, r6
        beq drive_diagonal_lower_left
        // THE DIAGONALS END

        // SIDEWAYS
        // go sideways right when button 2 is pressed
        ldr r6, =RC_BUTTON_TWO
        cmp r5, r6
        beq drive_sideways_right

        // go sideways left when button 8 is pressed
        ldr r6, =RC_BUTTON_EIGHT
        cmp r5, r6
        beq drive_sideways_left
        // SIDEWAYS END

        // ROTATION AROUND AN AXIS
        // rotate over an axis front when button 4 is pressed
        ldr r6, =RC_BUTTON_FOUR
        cmp r5, r6
        beq rotate_axis_front
        // rotata around an axis rear when button 6 is pressed
        ldr r6, =RC_BUTTON_SIX
        cmp r5, r6
        beq rotate_axis_back
        // ROTATION AROUND AN AXIS END

        //ROTATION
        // rotate to the right when up button is pressed
        ldr r6, =RC_BUTTON_UP
        cmp r5, r6
        beq drive_rotate_right
        // rotate to the left when down button is pressed
        ldr r6, =RC_BUTTON_DOWN
        cmp r5, r6
        beq drive_rotate_left
        //ROTATION END

    after_action_cleanup:
        mov r8, #0
        b wait_for_status_change

    drive_forward:
        bl go_forward
        b after_action_cleanup

    drive_backwards:
        bl go_backwards
        b after_action_cleanup

    drive_diagonal_upper_right:
        bl go_digonal_upwards_right
        b after_action_cleanup

    drive_diagonal_upper_left:
        bl go_diagonal_upwards_left
        b after_action_cleanup

    drive_diagonal_lower_right:
        bl go_diagonal_downwards_right
        b after_action_cleanup

    drive_diagonal_lower_left:
        bl go_diagonal_downwards_left
        b after_action_cleanup

    drive_sideways_right:
        bl go_sideways_right
        b after_action_cleanup

    drive_sideways_left:
        bl go_sideways_left
        b after_action_cleanup

    rotate_axis_front:
        bl rotate_around_axis_right_front
        b after_action_cleanup

    rotate_axis_back:
        bl rotate_around_axis_left_rear
        b after_action_cleanup

    drive_rotate_right:
        bl rotate_right
        b after_action_cleanup

    drive_rotate_left:
        bl rotate_left
        b after_action_cleanup


    @ execute_action:
    @     ldr r6 =BUTTON_TABLE
    @     lsl r5, r5, #2
    @     add r6, r6, r5
    @     ldr pc, [r6]

