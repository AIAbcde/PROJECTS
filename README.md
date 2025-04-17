# ABCDE FPGA Board Projects

Welcome to the official repository for the **ABCDE Board** projects. This board is based on an FPGA architecture and serves as a platform for developing and running custom digital logic projects.

### 🧠 What is ABCDE?

The **ABCDE Board** (short for *Any Buddy Can Design Electronics*) is a custom FPGA-based development board created to demonstrate how FPGAs can serve as both **programmable logic** and **microcontroller alternatives**. Compared to traditional microcontrollers (MCUs), **FPGAs offer superior performance, power efficiency, and flexibility**, making them ideal for high-speed or parallel processing tasks.

---

## 📁 Project List

- **DAC/**  
  Digital-to-Analog Converter implemented using PWM techniques and FPGA logic.

- **HEX_KEYPAD/**  
  Scanning and decoding a hexadecimal keypad through matrix-style input using Verilog.

- **LCD/**  
  Driving a standard character LCD using custom FSMs (Finite State Machines) designed in Verilog/VHDL.

- **LCD_KEYPAD/**  
  Combines the LCD and Keypad interface to create a basic user interface for input/output on the FPGA.

- **LED_MANAGEMENT/**  
  Includes multiple LED control modules such as blinking patterns, binary counters, and status indicators.

---

## 🛠️ Technologies Used

- **Verilog** – RTL design of digital logic.
- **SystemVerilog** – Enhanced hardware modeling and testbench development.
- **VHDL** – Used in some modules for design portability and abstraction.

Tools used may include:
- **Vivado / Quartus / GOWIN IDE**
- **GTKWave**
- **ModelSim / Verilator**
- **Make / Shell scripting for build automation**

---

## 🧪 Getting Started

Each folder contains a `README.md` or documentation to explain:
- Required hardware
- Wiring/schematics
- Source code files and build instructions
- Expected output
### 🔧 Prerequisites

Make sure you have the following installed:

- FPGA development tools (Vivado / Quartus / GOWIN IDE – depending on your FPGA vendor)
- A supported FPGA board (ABCDE or any compatible one)
- USB programmer (JTAG)
- Serial terminal software (e.g., PuTTY, Tera Term)
- Optional: GTKWave or simulation tools for waveform analysis

---

### 🚀 How to Build & Flash

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/abcde-fpga-projects.git
   cd abcde-fpga-projects
