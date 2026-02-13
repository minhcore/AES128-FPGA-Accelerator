# FPGA AES-128 Accelerator

> **Device:** Tang Nano 9K (Gowin GW1NR-9)
> **Language:** Verilog HDL
> **Toolchain:** Open Source CAD Suite (Yosys + Nextpnr)

A bare-metal implementation of AES-128 encryption for educational purposes.
This project focuses on manual FSM design and logic optimization, stepping away from vendor IP cores.

##  Resource Utilization (Post-Synthesis)

| Resource | Usage | Note |
| :--- | :--- | :--- |
| **LUT4** | [1865/8640] | *Logic Elements* |
| **DFF** | [1660/6480] | *Flip-Flops* |
| **BSRAM** | [8/26] | *Used for S-Box & Key Expansion* |

*(Synthesized with Yosys + Nextpnr-gowin)*

##  Custom UART Protocol
The system processes 19-byte packets with a custom state machine for integrity checks:

**Structure:** `[HEADER] [16-BYTE PAYLOAD] [CHECKSUM] [FOOTER]`

* **Header:**
    * `0xAA`: Payload is **Data** to encrypt.
    * `0xBB`: Payload is **Key**.
* **Checksum:** XOR sum of Header + Payload.
* **Logic:** Invalid checksums trigger an immediate drop.

##  Development Workflow
This project is built and verified entirely using **Open Source** tools:

| Category | Tool | Role |
| :--- | :--- | :--- |
| **Synthesis** | **Yosys** | Logic synthesis & resource mapping |
| **P&R** | **Nextpnr** | Place and Route for Gowin FPGA |
| **Flash** | **OpenFPGALoader** | Bitstream upload |
| **Simulation** | **Icarus Verilog** | Testbench compilation |
| **Waveform** | **GTKWave / Surfer** | Signal tracing & debugging |

---
*Special thanks to the OSS-CAD-Suite community for providing these amazing tools.*