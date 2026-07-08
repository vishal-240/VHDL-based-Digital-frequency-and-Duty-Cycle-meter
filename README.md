# VHDL Digital Frequency & Duty Cycle Meter

A digital hardware system designed in VHDL to accurately measure the frequency and duty cycle of an unknown asynchronous input signal.

## 🧠 Overview

This project implements a custom hardware meter from scratch. It uses a 50 MHz system clock to generate a precise 1-second measurement gate, synchronizes external asynchronous signals to prevent metastability, and utilizes a Finite State Machine (FSM) to orchestrate data capture and mathematical calculation of the duty cycle.

**Key Features:**

- Auto-synchronization and edge-detection of raw input signals.
- Configurable measurement gate generated via a custom clock divider.
- Parallel high-time and period counters for real-time duty cycle calculation.
- Fully synthesizable synchronous logic.

## 🏗️ Hardware Architecture

The system is broken down into modular components wired together in `top_level.vhd`:

1. **Input Synchronizer:** 2-stage flip-flop to prevent metastability.
2. **Control FSM:** Manages the `IDLE`, `MEASURE`, `CAPTURE`, and `HOLD` states.
3. **Clock Divider:** Derives a 1 Hz gate signal from the 50 MHz system clock.
4. **Counters:** Reusable generic counter modules for frequency and period accumulation.



## 🚀 Simulation & Verification

This design has been thoroughly verified using a self-checking testbench.

**Tools Used:**

- **Intel Quartus Prime Lite** (Analysis and Elaboration)
- **ModelSim-Altera** (Waveform Visualization)
