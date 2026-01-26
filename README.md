# AES128-FPGA-Accelerator
A hardware-based AES-128 encryption accelerator on Tang Nano 9K FPGA, controlled by an MSP430G2553 via UART interface.


## Project Goals
- **Hardware Acceleration:** Implement the core AES-128 algorithm on FPGA fabric.
- **IC Design Mindset:** Practice RTL design using Verilog (FSM, Pipeline, Registers).
- **Security Application:** Prototype a simplified cryptographic module inspired by HSM architectures.
- **Embedded Integration:** Build a bare-metal UART data bridge between MCU and FPGA.

## List
- **FPGA:** Tang Nano 9K (Gowin GW1NR-9C).
- **MCU:** MSP430G2553 (Texas Instruments).
- **Language:** Verilog HDL (Gateware), Bare-metal C (Firmware).
- **Tools:** Gowin EDA, Code Composer Studio, Logic Analyzer.

## Architecture Overview
- MSP430 acts as host controller.
- AES-128 core implemented as a hardware accelerator on FPGA.
- Communication via UART using command/data protocol.

## Repository Structure
- Update later

