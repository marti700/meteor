.thumb
  .syntax unified

  .global m3_reverse
  .global m3_stop
  .global m3_forward

  .text
  .thumb_func

  // LED 2
  .equ LED2_ON_L, 0x0E
  .equ LED2_ON_H, 0x0F
  .equ LED2_OFF_L, 0x10
  .equ LED2_OFF_H, 0x11
  .equ MODE1, 0x00

  // LED 3
  .equ LED3_ON_L, 0x12
  .equ LED3_ON_H, 0x13
  .equ LED3_OFF_L, 0x14
  .equ LED3_OFF_H, 0x15

  m3_forward:
    push {lr}
    bl reset_m3
    bl set_led2
    pop {lr}
    bx lr

  m3_reverse:
    push {lr}
    bl reset_m3
    bl set_led3
    pop {lr}
    bx lr

  m3_stop:
    push {lr}
    bl reset_m3
    bl set_led2
    bl set_led3
    pop {lr}
    bx lr

  // the motor in reverse sets pwm wave by assinging values to the LED3_ON and LED6_OFF registers
  set_led2:
    push {lr}
    // in order to use PWM is necesary to enable the PCA9685PW clock by setting the SLEEP bit of MODE 1 register to 0
    ldr r2, =MODE1
    mov r3, #0x00
    bl IIC_write
    bl stop_IIC

    ldr r2, =LED2_ON_H
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED2_ON_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED2_OFF_H
    mov r3, #0x0F
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED2_OFF_L
    mov r3, #0xFF
    bl IIC_write
    bl stop_IIC
    //
    pop {lr}
    bx lr


  set_led3:
    push {lr}
    // in order to use PWM is necesary to enable the PCA9685PW clock by setting the SLEEP bit of MODE 1 register to 0
    ldr r2, =MODE1
    mov r3, #0x00
    bl IIC_write
    bl stop_IIC

    ldr r2, =LED3_ON_H
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED3_ON_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED3_OFF_H
    mov r3, #0x0F
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED3_OFF_L
    mov r3, #0xFF
    bl IIC_write
    bl stop_IIC
    //
    pop {lr}
    bx lr

  reset_m3:
    push {lr}
    bl reset_l2
    bl reset_l3
    pop {lr}
    bx lr


  reset_l2:
    push {lr}
    // in order to use PWM is necesary to enable the PCA9685PW clock by setting the SLEEP bit of MODE 1 register to 0
    @ ldr r2, =MODE1
    @ mov r3, #0x00
    @ bl IIC_write
    @ bl stop_IIC

    ldr r2, =LED2_ON_H
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED2_ON_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED2_OFF_H
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED2_OFF_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    pop {lr}
    bx lr

  reset_l3:
    push {lr}
    // in order to use PWM is necesary to enable the PCA9685PW clock by setting the SLEEP bit of MODE 1 register to 0
    ldr r2, =MODE1
    mov r3, #0x00
    bl IIC_write
    bl stop_IIC

    ldr r2, =LED3_ON_H
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED3_ON_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED3_OFF_H
    mov r3, #0x00
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED3_OFF_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    pop {lr}
    bx lr
