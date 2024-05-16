@ This file define functions to control microbit shield motor 4 according to the HR8833 datasheet
.thumb
  .syntax unified

  .global m4_reverse
  .global m4_stop
  .global m4_forward

  .text
  .thumb_func

  // LED 0
  .equ LED0_ON_L, 0x06
  .equ LED0_ON_H, 0x07
  .equ LED0_OFF_L, 0x08
  .equ LED0_OFF_H, 0x09
  // LED 1
  .equ LED1_ON_L, 0x0A
  .equ LED1_ON_H, 0x0B
  .equ LED1_OFF_L, 0x0C
  .equ LED1_OFF_H, 0x0D
  .equ MODE1, 0x00


  m4_forward:
    push {lr}
    bl reset_m4
    bl set_led0
    pop {lr}
    bx lr

  m4_reverse:
    push {lr}
    bl reset_m4
    bl set_led1
    pop {lr}
    bx lr

  m4_stop:
    push {lr}
    bl reset_m4
    bl set_led0
    bl set_led1
    pop {lr}
    bx lr

  // the motor in reverse sets pwm wave by assinging values to the LED3_ON and LED6_OFF registers
  set_led0:
    push {lr}
    // in order to use PWM is necesary to enable the PCA9685PW clock by setting the SLEEP bit of MODE 1 register to 0
    ldr r2, =MODE1
    mov r3, #0x00
    bl IIC_write
    bl stop_IIC

    ldr r2, =LED0_ON_H
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED0_ON_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED0_OFF_H
    mov r3, #0x0F
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED0_OFF_L
    mov r3, #0xFF
    bl IIC_write
    bl stop_IIC
    //
    pop {lr}
    bx lr


  set_led1:
    push {lr}
    // in order to use PWM is necesary to enable the PCA9685PW clock by setting the SLEEP bit of MODE 1 register to 0
    ldr r2, =MODE1
    mov r3, #0x00
    bl IIC_write
    bl stop_IIC

    ldr r2, =LED1_ON_H
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED1_ON_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED1_OFF_H
    mov r3, #0x0F
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED1_OFF_L
    mov r3, #0xFF
    bl IIC_write
    bl stop_IIC
    //
    pop {lr}
    bx lr

  reset_m4:
    push {lr}
    bl reset_l0
    bl reset_l1
    pop {lr}
    bx lr


  reset_l0:
    push {lr}
    // in order to use PWM is necesary to enable the PCA9685PW clock by setting the SLEEP bit of MODE 1 register to 0
    @ ldr r2, =MODE1
    @ mov r3, #0x00
    @ bl IIC_write
    @ bl stop_IIC

    ldr r2, =LED0_ON_H
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED0_ON_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED0_OFF_H
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED0_OFF_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    pop {lr}
    bx lr

  reset_l1:
    push {lr}
    // in order to use PWM is necesary to enable the PCA9685PW clock by setting the SLEEP bit of MODE 1 register to 0
    ldr r2, =MODE1
    mov r3, #0x00
    bl IIC_write
    bl stop_IIC

    ldr r2, =LED1_ON_H
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED1_ON_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED1_OFF_H
    mov r3, #0x00
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED1_OFF_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    pop {lr}
    bx lr
