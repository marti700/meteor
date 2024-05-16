// this file defines function to enable the random number generation module of the nrf52833 and to
// retrieve the generated random number
.thumb
  .syntax unified

  .global init_rng
  .global get_rnd_number

  .text
  .thumb_func

  .equ RNG_BASE, 0x4000D000
  .equ TASK_START, 0x000
  .equ TASTK_STOP, 0x004
  .equ EVENTS_VALRDY, 0x100
  .equ CONFIG, 0x504
  .equ VALUE, 0x508

  .equ one_second, 2000
  .equ GIPIO_BASE, 0x50000000
  .equ THIRTY_CM, 1740 //1740 is 30cm

  init_rng:
    // start randon number generation
    ldr r0, =RNG_BASE
    mov r1, #1
    str r1, [r0, #TASK_START]

    bx lr

  get_rnd_number:
    ldr r0, =RNG_BASE
    ldr r1, [r0, #VALUE]

    bx lr


