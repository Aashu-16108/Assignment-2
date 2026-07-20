# FPGA Control Unit - Instruction Set Reference

## Student Information

- **Name:** Ashutosh Kumar Sah
- **Roll No.:** 079BEI009

---

## Project Overview

This project implements an **8-bit FPGA Control Unit** in **Verilog HDL**. The control unit decodes instructions, generates the required control signals, and coordinates data movement between registers and the Arithmetic Logic Unit (ALU). It supports register transfers, immediate data loading, and accumulator-based ALU operations through a compact 8-bit instruction format.

---

## Instruction Format

Each instruction is **8 bits** wide.

| Bits | Description |
|------|-------------|
| **[7:6]** | Instruction Class |
| **[5:3]** | Destination Register / Register Index |
| **[2:0]** | Source Register or ALU Operation Code |

---

## Register Conventions

The following registers are defined in the control unit.

| Register | Address | Description |
|----------|:-------:|-------------|
| **ACC (R0)** | `3'b000` | Accumulator register |
| **G (R6)** | `3'b110` | Hard-wired constant **1** |
| **H (R7)** | `3'b111` | Hard-wired constant **0** |

---

## ALU Operation Codes

The following 3-bit operation codes are used for accumulator-based ALU operations.

| ALU Code | Operation | Description |
|:-------:|-----------|-------------|
| `000` | NULL | No operation |
| `001` | ADD | `ACC + Register` (also used as pass-through when adding 0) |
| `010` | INC | `ACC + 1` |
| `011` | DEC | `ACC - 1` |
| `100` | XOR | Bitwise XOR |
| `101` | AND | Bitwise AND |
| `110` | OR | Bitwise OR |
| `111` | NOT | Bitwise complement of ACC |

---

## Instruction Classes

### 1. Register-to-Register Move

**Format**

```
00 DDD SSS
```

**Operation**

```
Rd ← Rs
```

**Implementation**

- Uses the ALU with **ADD** operation.
- Register **H (R7)** provides a constant `0`.
- Performs:

```
Source + 0 → Destination
```

---

### 2. Immediate-to-Register Move

**Format**

```
01 DDD XXX
```

> The lower three bits are ignored.

**Operation**

```
Rd ← Immediate
```

**Implementation**

- The next byte in memory is fetched as the immediate value.
- `immux` selects the immediate input.
- ALU performs:

```
Immediate + 0 → Destination
```

---

### 3. Accumulator ALU Operations

**Format**

```
10 RRR OOO
```

Where:

- **RRR** = Register operand
- **OOO** = ALU operation code

The result is always written back to the accumulator.

```
ACC ← ALU Result
```

### Operand Selection

| ALU Operation | Operand B |
|--------------|-----------|
| ADD | Register selected by **RRR** |
| INC | Constant **1** (G) |
| DEC | Constant **1** (G) |
| XOR | Register selected by **RRR** |
| AND | Register selected by **RRR** |
| OR | Register selected by **RRR** |
| NOT | Constant **0** (H) |

---

### 4. Reserved Instructions

**Format**

```
11 XXXXXXX
```

This instruction class is **reserved** and is **not implemented** in `control.v`.

Reserved instructions are ignored by the instruction decoder.

---

## Controller State Machine

The controller operates using a simple three-state finite state machine.

| State | Description |
|-------|-------------|
| **S_DECODE** | Decode the current instruction |
| **S_FETCH_IMM** | Fetch immediate operand from memory |
| **S_EXECUTE** | Execute instruction and update registers |

---

## Immediate Instruction Flow

```
Instruction Decode
        │
        ▼
S_FETCH_IMM
        │
        ▼
Read Immediate Byte
        │
        ▼
S_EXECUTE
        │
        ▼
Write Register
```

---

## Write Enable Logic

The write enable signal is asserted only during the execution stage.

```verilog
writeenable = (state == S_EXECUTE);
```

---

## Design Features

- Compact **8-bit instruction set**
- Three-state finite state machine
- Register-to-register data transfer
- Immediate data loading
- Accumulator-based ALU operations
- Dedicated constant registers (R6 = 1, R7 = 0)
- Simple and modular control logic
- FPGA-friendly implementation

---

## File Description

| File | Description |
|------|-------------|
| `control.v` | Main Control Unit implementation |
| `alu.v` | Arithmetic Logic Unit used by the controller |
| `register_file.v` | Register file containing processor registers |
| `control_tb.v` | Testbench for functional verification |
| `*.vcd` | Simulation waveform generated during testing |

---

## Applications

- FPGA-Based Processor Design
- Digital System Design
- CPU Control Logic
- Computer Architecture
- Verilog HDL Learning
- Educational Microprocessor Projects

---

## Conclusion

This project demonstrates the implementation of an **8-bit FPGA Control Unit** using Verilog HDL. The controller efficiently decodes instructions, manages register transfers, executes accumulator-based ALU operations, and handles immediate data loading through a simple three-state finite state machine. The modular design makes it suitable for FPGA implementation and provides a strong foundation for learning processor architecture and digital control systems.

---

## Author

**Ashutosh Kumar Sah**  
**Roll No.:** 079BEI009
