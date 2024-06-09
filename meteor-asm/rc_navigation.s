    // This file define functions to control the car remotely
    .thumb
    .syntax unified

    .global rc_mode

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
    .equ RC_BUTTON_OK,                0xff38c7

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


    rc_mode:
        bl prepare_for_ir_transmission
    action_loop:
        bl on_transmission_start
        // go forward when the up button is pressed
        ldr r6, =RC_BUTTON_UP
        cmp r5, r6
        beq drive_forward
        // go backwards when the down button is pressed
        ldr r6, =RC_BUTTON_DOWN
        cmp r5, r6
        beq drive_backwards

        // THE DIAGONALS
        // go upper diagonal right when button 3 is pressed
        ldr r6, =RC_BUTTON_THREE
        cmp r5, r6
        beq drive_diagonal_upper_right
        // go upper diagonal left when button 1 is pressed
        ldr r6, =RC_BUTTON_ONE
        cmp r5, r6
        beq drive_diagonal_upper_left
        // go downwards diagonal right when the button 9 is pressed
        ldr r6, =RC_BUTTON_NINE
        cmp r5, r6
        beq drive_diagonal_lower_right
        // go downwards diagonal left when button 7 is pressed
        ldr r6, =RC_BUTTON_SEVEN
        cmp r5, r6
        beq drive_diagonal_lower_left
        // THE DIAGONALS END

        // SIDEWAYS
        // go sideways right when button 6 is pressed
        ldr r6, =RC_BUTTON_SIX
        cmp r5, r6
        beq drive_sideways_right

        // go sideways left when button 4 is pressed
        ldr r6, =RC_BUTTON_FOUR
        cmp r5, r6
        beq drive_sideways_left
        // SIDEWAYS END

        // ROTATION AROUND AN AXIS
        // rotate over an axis front when button 2 is pressed
        ldr r6, =RC_BUTTON_TWO
        cmp r5, r6
        beq rotate_axis_front
        // rotata around an axis rear when button 8 is pressed
        ldr r6, =RC_BUTTON_EIGHT
        cmp r5, r6
        beq rotate_axis_back
        // ROTATION AROUND AN AXIS END

        //ROTATION
        // rotate to the right when right button is pressed
        ldr r6, =RC_BUTTON_RIGHT
        cmp r5, r6
        beq drive_rotate_right
        // rotate to the left when left button is pressed
        ldr r6, =RC_BUTTON_LEFT
        cmp r5, r6
        beq drive_rotate_left
        //ROTATION END

        //stop the car when button 5 is pressed
        ldr r6, =RC_BUTTON_FIVE
        cmp r5, r6
        beq drive_stop

        //enter selection_mode when OK button is pressed
        ldr r6, =RC_BUTTON_OK
        cmp r5, r6
        beq go_to_mode_selection

        b action_loop

    clear_pin_evt:
        ldr r2, =GPIOTE_BASE
        mov r1, #0
        str r1, [r2, #GPIOTE_EVENTS_IN_0]
        bx lr

    go_to_mode_selection:
        bl car_stop
        b select_mode

    drive_stop:
        bl car_stop
        b action_loop

    drive_forward:
        bl go_forward
        b action_loop

    drive_backwards:
        bl go_backwards
        b action_loop

    drive_diagonal_upper_right:
        bl go_digonal_upwards_right
        b action_loop

    drive_diagonal_upper_left:
        bl go_diagonal_upwards_left
        b action_loop

    drive_diagonal_lower_right:
        bl go_diagonal_downwards_right
        b action_loop

    drive_diagonal_lower_left:
        bl go_diagonal_downwards_left
        b action_loop

    drive_sideways_right:
        bl go_sideways_right
        b action_loop

    drive_sideways_left:
        bl go_sideways_left
        b action_loop

    rotate_axis_front:
        bl rotate_around_axis_right_front
        b action_loop

    rotate_axis_back:
        bl rotate_around_axis_left_rear
        b action_loop

    drive_rotate_right:
        bl rotate_right
        b action_loop

    drive_rotate_left:
        bl rotate_left
        b action_loop
