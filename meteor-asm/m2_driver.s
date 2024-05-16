@ This file define functions to control microbit shield motor 2 according to the HR8833 datasheet
.thumb
  .syntax unified

  .global m2_reverse
  .global m2_stop
  .global m2_forward

  .text
  .thumb_func

  // LED 4
  .equ LED4_ON_L, 0x16
  .equ LED4_ON_H, 0x17
  .equ LED4_OFF_L, 0x18
  .equ LED4_OFF_H, 0x19
  // LED 5
  .equ LED5_ON_L, 0x1A
  .equ LED5_ON_H, 0x1B
  .equ LED5_OFF_L, 0x1C
  .equ LED5_OFF_H, 0x1D
  .equ MODE1, 0x00


  m2_forward:
    push {lr}
    bl reset_m2
    bl set_led4
    pop {lr}
    bx lr

  m2_reverse:
    push {lr}
    bl reset_m2
    bl set_led5
    pop {lr}
    bx lr

  m2_stop:
    push {lr}
    bl reset_m2
    bl set_led4
    bl set_led5
    pop {lr}
    bx lr

  // the motor in reverse sets pwm wave by assinging values to the LED3_ON and LED6_OFF registers
  set_led4:
    push {lr}
    // in order to use PWM is necesary to enable the PCA9685PW clock by setting the SLEEP bit of MODE 1 register to 0
    ldr r2, =MODE1
    mov r3, #0x00
    bl IIC_write
    bl stop_IIC

    ldr r2, =LED4_ON_H
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED4_ON_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED4_OFF_H
    mov r3, #0x0F
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED4_OFF_L
    mov r3, #0xFF
    bl IIC_write
    bl stop_IIC
    //
    pop {lr}
    bx lr


  set_led5:
    push {lr}
    // in order to use PWM is necesary to enable the PCA9685PW clock by setting the SLEEP bit of MODE 1 register to 0
    ldr r2, =MODE1
    mov r3, #0x00
    bl IIC_write
    bl stop_IIC

    ldr r2, =LED5_ON_H
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED5_ON_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED5_OFF_H
    mov r3, #0x0F
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED5_OFF_L
    mov r3, #0xFF
    bl IIC_write
    bl stop_IIC
    //
    pop {lr}
    bx lr

  reset_m2:
    push {lr}
    bl reset_l4
    bl reset_l5
    pop {lr}
    bx lr


  reset_l4:
    push {lr}
    // in order to use PWM is necesary to enable the PCA9685PW clock by setting the SLEEP bit of MODE 1 register to 0
    @ ldr r2, =MODE1
    @ mov r3, #0x00
    @ bl IIC_write
    @ bl stop_IIC

    ldr r2, =LED4_ON_H
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED4_ON_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED4_OFF_H
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED4_OFF_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    pop {lr}
    bx lr

  reset_l5:
    push {lr}
    // in order to use PWM is necesary to enable the PCA9685PW clock by setting the SLEEP bit of MODE 1 register to 0
    ldr r2, =MODE1
    mov r3, #0x00
    bl IIC_write
    bl stop_IIC

    ldr r2, =LED5_ON_H
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED5_ON_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED5_OFF_H
    mov r3, #0x00
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED5_OFF_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    pop {lr}
    bx lr
