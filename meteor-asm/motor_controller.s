.thumb
  .syntax unified
  .global main

  .text
  .thumb_func

  .equ TWI_BASE, 0x40003000
  .equ STARTTX, 0x008
  .equ STARTRX, 0x000
  .equ TASk_STOP, 0x014
  .equ SCL, 0x508
  .equ SDA, 0x50C
  .equ TXD, 0x51C
  .equ RXD, 0x518
  .equ FREQUENCY, 0x524
  .equ ADDRESS, 0x588
  .equ ENABLE, 0x500
  .equ LED6_ON_L, 0x1E
  .equ LED6_OFF_L, 0x20
  .equ LED6_ON_H, 0x1F
  .equ LED6_OFF_H, 0x21
  .equ TXDSENT, 0x11C
  .equ RXDREADY, 0x108
  .equ ERROR_SRC, 0x4C4
  .equ MODE1, 0x00
  .equ RR, 6000

  main:
    b init_PCA9685

  init_PCA9685:
    ldr R0, =TWI_BASE
    // set SCL to 26 (this is pin 19 on the microbit)
    ldr R1, [R0, #SCL] // load R0 contents to R1
    mov r1, #0x1A
    str r1, [r0, #SCL]

    //set sda to pin 0 of port 1 (this is pin 20 in the microbit)
    ldr R1, [R0, #SDA] // load R0 contents to R1
    mov r1, #0x20
    str r1, [r0, #SDA]

    // set frecuency to 100kbps
    mov r1, #0x01980000
    str r1, [r0, #FREQUENCY]

    // enable TWI
    mov r1, #5
    str r1, [r0, #ENABLE]

    // set the slave address and the write bit (0)
    mov r1, #0x40
    str r1, [r0, #ADDRESS]


  // sets pwm wave by assinging values to the LED3_ON and LED6_OFF registers
  set_registers:
    // in order to use PWM is necesary to enable the PCA9685PW clock by setting the SLEEP bit of MODE 1 register to 0
    ldr r2, =MODE1
    mov r3, #0x00
    bl IIC_write
    bl stop_IIC

    ldr r2, =LED6_ON_H
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED6_ON_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED6_OFF_H
    mov r3, #0x0F
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED6_OFF_L
    mov r3, #0xFF
    bl IIC_write
    bl stop_IIC
    //
    @ bl IIC_read
    b set_registers

  stop_IIC:
    // stop transmision
    mov r1, #1
    str r1, [r0, #TASk_STOP]

    bx lr

  delay_1:
    push {lr}
    ldr r6, =RR
  delay_1_inner:
    subs r6, r6, #1
    @ cmp r6, #0
    bne delay_1_inner

    pop {lr}
    bx lr


  IIC_write:
    push {lr}
    // set the address of the led6_on register
    @ ldr r1, =LED6_OFF
    str r2, [r0, #TXD]

    // start IIC write transmition
    mov r1, #1
    str r1, [r0, #STARTTX]

    bl delay_1

    // Check for address error
    ldr r5, [r0, #ERROR_SRC]
    tst r5, #(1<<1)
    mov r5, #2
    str r5, [r0, #ERROR_SRC]
    // start over if there is an address error
    bne main

    //clear the TXDSENT event
    mov r1, #0
    str r1, [r0, #TXDSENT]

    // write 1 to the led_6 register
    @ mov r1, #4000
    str r3, [r0, TXD]

    //clear the TXDSENT event
    mov r1, #0
    str r1, [r0, #TXDSENT]

    pop {lr}
    bx lr

  IIC_read:
    // set the address of the led6_on register
    @ mov r1, #LED6_ON_H
    str r2, [r0, #TXD]

    // start IIC write transmition
    mov r1, #1
    str r1, [r0, #STARTRX]

    //clear the TXDSENT event
    mov r1, #0
    str r1, [r0, #RXDREADY]

    bx lr
