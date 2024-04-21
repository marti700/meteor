.thumb
  .syntax unified
  .global init_PCA9685
  .global stop_IIC
  .global IIC_write
  .global IIC_read

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
  .equ TXDSENT, 0x11C
  .equ RXDREADY, 0x108
  .equ ERROR_SRC, 0x4C4
  .equ MODE1, 0x00

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

    bx lr

  stop_IIC:
    // stop transmision
    ldr r0, =TWI_BASE
    mov r1, #1
    str r1, [r0, #TASk_STOP]

    bx lr

  IIC_write:
    push {lr}
    ldr r0, =TWI_BASE
    // set the address of the led6_on register
    @ ldr r1, =LED6_OFF
    str r2, [r0, #TXD]

    // start IIC write transmition
    mov r1, #1
    str r1, [r0, #STARTTX]

    bl wait_for_ack

    // Check for address error
    ldr r5, [r0, #ERROR_SRC]
    tst r5, #(1<<1)
    mov r5, #2
    str r5, [r0, #ERROR_SRC]
    // start over if there is an address error
    bne main

    // write 1 to the led_6 register
    @ mov r1, #4000
    str r3, [r0, TXD]
    @ bl wait_for_ack

    bl wait_for_ack


    pop {lr}
    bx lr

  IIC_read:
    ldr r0, =TWI_BASE
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

  wait_for_ack:
    push {lr}
    ldr r0, =TWI_BASE
  wait_for_ack_inner:
    ldr r1, [r0, #TXDSENT]
    tst r1, #1
    beq wait_for_ack_inner

    //clear the TXDSENT event
    mov r1, #0
    str r1, [r0, #TXDSENT]

    pop {lr}
    bx lr

