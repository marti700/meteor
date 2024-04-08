.thumb
  .syntax unified

  .global m1_reverse
  .global m1_stop

  .text
  .thumb_func

  // LED 6
  .equ LED6_ON_L, 0x1E
  .equ LED6_ON_H, 0x1F
  .equ LED6_OFF_L, 0x20
  .equ LED6_OFF_H, 0x21
  // LED 7
  .equ LED7_ON_L, 0x22
  .equ LED7_ON_H, 0x23
  .equ LED7_OFF_L, 0x24
  .equ LED7_OFF_H, 0x25
  .equ MODE1, 0x00


  m1_reverse:
    push {lr}
    bl reset_m1
    bl set_led6
    pop {lr}
    bx lr

  m1_stop:
    push {lr}
    bl reset_m1
    bl set_led6
    bl set_led7
    pop {lr}
    bx lr

  // the motor in reverse sets pwm wave by assinging values to the LED3_ON and LED6_OFF registers
  set_led6:
    push {lr}
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
    pop {lr}
    bx lr


  set_led7:
    push {lr}
    // in order to use PWM is necesary to enable the PCA9685PW clock by setting the SLEEP bit of MODE 1 register to 0
    ldr r2, =MODE1
    mov r3, #0x00
    bl IIC_write
    bl stop_IIC

    ldr r2, =LED7_ON_H
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED7_ON_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED7_OFF_H
    mov r3, #0x0F
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED7_OFF_L
    mov r3, #0xFF
    bl IIC_write
    bl stop_IIC
    //
    pop {lr}
    bx lr

  reset_m1:
    push {lr}
    bl reset_l6
    bl reset_l7
    pop {lr}
    bx lr


  reset_l6:
    push {lr}
    // in order to use PWM is necesary to enable the PCA9685PW clock by setting the SLEEP bit of MODE 1 register to 0
    @ ldr r2, =MODE1
    @ mov r3, #0x00
    @ bl IIC_write
    @ bl stop_IIC

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
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED6_OFF_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    pop {lr}
    bx lr

  reset_l7:
    push {lr}
    // in order to use PWM is necesary to enable the PCA9685PW clock by setting the SLEEP bit of MODE 1 register to 0
    ldr r2, =MODE1
    mov r3, #0x00
    bl IIC_write
    bl stop_IIC

    ldr r2, =LED7_ON_H
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED7_ON_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED7_OFF_H
    mov r3, #0x00
    bl IIC_write
    bl stop_IIC
    //
    ldr r2, =LED7_OFF_L
    mov r3, #0x0
    bl IIC_write
    bl stop_IIC
    //
    pop {lr}
    bx lr
