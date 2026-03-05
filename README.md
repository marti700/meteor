# Motivation 🚀  

I’ve always been fascinated by electronics. Over time, I’ve explored the basics of circuits, switches, relays, and transistors. Now, I’m taking the next step: diving into the world of microcontrollers.  

The goal of this project is to build an autonomous robot car capable of self-navigation. Once powered on, the robot should be able to move around, avoid obstacles, and continue operating until its battery is depleted.  

To prepare, I’ve been following a Udemy course on microcontroller programming. The instructor uses an STM32 Nucleo-64 board (based on an ARM Cortex-M4 MCU) and teaches how to read and navigate microcontroller datasheets.  

For this project, however, I’ll be using the **BBC micro:bit v2** microcontroller, and all robot software will be written in **assembly language**.  

---

## Why the Micro:bit? 🔧  

While I’ve grown accustomed to the structure of STM32 documentation, I want to challenge myself to understand other microcontroller ecosystems. The micro:bit provides a different architecture and documentation style, making it a great opportunity to broaden my skills.  

---

## Why Assembly? ⚙️  

There are high-level libraries in Python, C++, Rust, and other languages that make controlling the micro:bit’s peripherals much easier. However, these abstractions hide the low-level details of how the hardware actually works.  

By writing this project in assembly, I’ll gain a deeper understanding of how microcontrollers execute instructions and interact directly with hardware. This approach may be slower and more challenging, but it aligns perfectly with my goal: **to truly learn how microcontrollers work at the bare-metal level.**  
