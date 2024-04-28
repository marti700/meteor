# Motivation

I’ve long been fascinated by electronics, studying circuits, switches, relays,
and transistors. Now, I’m diving into the world of microcontrollers. My goal? To
learn how these tiny devices work by building an autonomous robot car that can
navigate on its own. Imagine powering up the robot, and it confidently moves
around, avoiding obstacles until its battery runs out.

## Learning Journey

I’ve been following a Udemy course on microcontroller programming. The
instructor primarily uses an STM32 Nucleo 64 microcontroller (which features an
ARM Cortex-4 MCU) for the classes. The course delves into navigating
microcontroller datasheets, a crucial skill for understanding hardware
interfaces.

## Choosing the Micro:bit Microcontroller

For my project, I’ve opted for the BBC micro:bit v2 microcontroller. Why? Well,
I’ve grown accustomed to the structure of STM32 documentation, and I want to
ensure I can decipher other microcontroller datasheets as well.

## Why Assembly Language?

Now, here’s where it gets interesting. While there are convenient libraries
available in Python, C++, Rust, and other programming languages that allow easy
control of micro:bit peripherals, these libraries abstract away many layers of
the underlying hardware. Sure, using them would make achieving my goal quicker,
but I’d miss out on truly understanding how microcontrollers execute software.
So, I’ve made the deliberate choice to write this project in assembly language.
