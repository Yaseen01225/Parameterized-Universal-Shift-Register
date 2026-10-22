# Parameterized Universal Shift Register (1–128 Bits)

**Project:** Parameterized Universal Shift Register  
**Developer:** Ghulam Yaseen Nangraj  
**Date:** October 20, 2026  
**HDL:** Verilog-2001  
**Target Platform:** Xilinx Vivado / XSIM  
**Design Type:** Synchronous sequential digital circuit  
**Default Register Width:** 8 bits  
**Supported Register Width:** 1–128 bits  
**Top-Level Module:** `parameterized_universal_shift_register`  
**Testbench Module:** `tb_parameterized_universal_shift_register`

---

## Table of Contents

1. Project Summary
2. Project Objectives
3. Universal Shift Register Fundamentals
4. Design Specifications
5. Project Directory Structure
6. Overall Architecture
7. Functional Block Diagram
8. Operation Mode Table
9. Detailed Module Descriptions
10. Top-Level Port Descriptions
11. Parameterization: 1–128 Bits
12. Working Mechanism
13. Clock, Reset, and Enable Behavior
14. Example Operation Walkthrough
15. Testbench Architecture
16. Verification and Expected Results
17. Vivado Project Setup
18. Simulation Using Icarus Verilog
19. Synthesis and FPGA Implementation
20. Design Limitations and Assumptions
21. Troubleshooting
22. Possible Future Enhancements
23. Engineering Learning Outcomes
24. Final Summary

---

## 1. Project Summary

The Parameterized Universal Shift Register is a reusable digital hardware design implemented in synthesizable Verilog-2001. It combines four fundamental register operations into one configurable module:

- **Hold:** Retain the current register value.
- **Shift Right:** Move the stored data one bit toward the least-significant bit.
- **Shift Left:** Move the stored data one bit toward the most-significant bit.
- **Parallel Load:** Load an entire data word in one clock cycle.

The design is parameterized, allowing the register width to be configured from 1 bit through 128 bits without rewriting the functional RTL.

The architecture separates the design into dedicated modules for holding data, shifting in each direction, parallel loading, operation selection, and clocked storage. A top-level module integrates these functions into a complete hardware component.

A separate self-checking testbench verifies the main operating modes, reset behavior, enable behavior, and reset priority.

The project is intended for learning modular RTL design, parameterized hardware, synchronous sequential logic, Verilog simulation, and FPGA synthesis workflows.

**Important scope statement:** The supplied testbench exercises the default 8-bit configuration. The RTL is designed to support widths from 1 to 128 bits, but each target width should be verified independently before being used in a production design.

---

## 2. Project Objectives

The main objectives are:

1. Develop a reusable universal shift register supporting widths from 1 to 128 bits.
2. Separate the implementation into function-wise Verilog modules.
3. Implement four operations selected through a two-bit mode input.
4. Use a synchronous, active-high reset.
5. Provide an active-high enable signal to control state updates.
6. Expose serial outputs from both ends of the register.
7. Handle the special case of a one-bit register without invalid Verilog part-selects.
8. Create a self-checking testbench for the main operating modes.
9. Maintain compatibility with Verilog-2001 coding conventions.
10. Provide a clear foundation for FPGA implementation and future enhancement.

---

## 3. Universal Shift Register Fundamentals

A shift register is a collection of storage elements that holds binary data. On a clock edge, the stored bits may move left or right, depending on the selected operation.

A **universal shift register** combines shifting with other operations, particularly parallel loading and holding the current value.

For a register of width \(N\), the state is represented by:

\[
Q = q[N-1:0]
\]

where:

- \(q[N-1]\) is the most-significant bit (MSB).
- \(q[0]\) is the least-significant bit (LSB).
- \(N\) is the configured `WIDTH` parameter.

For this project, the register width must be configured between 1 and 128 bits.

### Why use a universal shift register?

A universal shift register is useful when a circuit must process data in both serial and parallel forms. It can be used in:

- Serial-to-parallel data conversion.
- Parallel-to-serial data transmission.
- Digital communication interfaces.
- Data buffering and alignment.
- FPGA educational projects.
- Bitstream processing.
- Register-based datapaths.
- Digital control and signal-processing systems.

The exact suitability for a particular application depends on its timing, throughput, reset, and interface requirements.

---

## 4. Design Specifications

| Property | Specification |
|---|---|
| HDL standard | Verilog-2001 |
| Default width | 8 bits |
| Intended width range | 1–128 bits |
| Number of operations | 4 |
| Operation selector | 2 bits |
| Clock edge | Positive edge |
| Reset polarity | Active-high |
| Reset style | Synchronous |
| Enable polarity | Active-high |
| Shift-right input | `serial_in_right` |
| Shift-left input | `serial_in_left` |
| Parallel input | `parallel_in[WIDTH-1:0]` |
| Register output | `q[WIDTH-1:0]` |
| Left-end serial output | `serial_out_left` |
| Right-end serial output | `serial_out_right` |
| Operation datapaths | Combinational |
| Register storage | Sequential |
| Testbench style | Self-checking |
| Suggested FPGA tool | Xilinx Vivado |

### Design assumptions

- `WIDTH` is a legal integer from 1 through 128.
- All synchronous state updates occur on `posedge clk`.
- Reset is synchronous, not asynchronous.
- The operation selector is expected to be a known two-bit value during normal operation.
- The serial outputs continuously reflect the current MSB and LSB.
- No automatic rotation occurs during a shift.
- The design does not include arithmetic right shifting, scan controls, or a ready/valid handshake.

---

## 5. Project Directory Structure

Organize the project as follows:

```text
Parameterized_Universal_Shift_Register/
│
├── rtl/
│   ├── usr_hold.v
│   ├── usr_shift_right.v
│   ├── usr_shift_left.v
│   ├── usr_parallel_load.v
│   ├── usr_operation_selector.v
│   ├── usr_register_storage.v
│   └── parameterized_universal_shift_register.v
│
├── tb/
│   └── tb_parameterized_universal_shift_register.v
│
├── docs/
│   └── README.md
│
└── reports/
    └── simulation_results.txt
```

The seven RTL files are required for the top-level design. The testbench is used for simulation and must not be selected as the synthesis top.

The `README.md` may be placed in the project root, with an identical copy in `docs/` if desired.

---

## 6. Overall Architecture

The design uses a modular architecture with a combinational operation datapath and a sequential storage element.

The current register value `q` is distributed to the functional units. The functional units generate candidate next-state values. The operation selector chooses one candidate based on `sel[1:0]`. The register storage captures the selected result at the next rising clock edge, provided reset is inactive and enable is high.

### Main architecture stages

1. **Current state:** The storage module provides the current register value `q`.
2. **Operation datapaths:** Hold, shift-right, shift-left, and parallel-load modules generate candidate data.
3. **Operation selection:** The selector chooses the requested candidate.
4. **Control qualification:** Reset and enable determine whether the register clears, updates, or holds.
5. **State update:** The selected value becomes the new `q` on a rising clock edge.
6. **Serial observation:** The MSB and LSB are continuously available at the serial output pins.

---

## 7. Functional Block Diagram

```text
                    EXTERNAL INPUTS
        +--------------------------------------+
        | clk, rst, enable, sel[1:0]           |
        | parallel_in[WIDTH-1:0]               |
        | serial_in_left, serial_in_right      |
        +-------------------+------------------+
                            |
                            v
                +-----------------------+
     q -------->|       HOLD UNIT       |
                +-----------------------+
                            |
                +-----------------------+
     q -------->|    SHIFT-RIGHT UNIT   |<--- serial_in_right
                +-----------------------+
                            |
                +-----------------------+
     q -------->|     SHIFT-LEFT UNIT   |<--- serial_in_left
                +-----------------------+
                            |
                +-----------------------+
 parallel_in -->|   PARALLEL-LOAD UNIT  |
                +-----------------------+
                            |
                            v
                +-----------------------+
 sel[1:0] ----->|   OPERATION SELECTOR  |
                +-----------------------+
                            |
                       next_data
                            |
                            v
                +-----------------------+
 clk ---------->|                       |
 rst ---------->|   REGISTER STORAGE    |-----> q[WIDTH-1:0]
 enable ------->|                       |
                +-----------------------+
                            |
                 +----------+----------+
                 |                     |
                 v                     v
          serial_out_left      serial_out_right
             = q[WIDTH-1]          = q[0]
```

The functional blocks above are separate Verilog modules. The clocked register storage is the only block that changes the stored state.

The selector is combinational; it does not itself store data.

---

## 8. Operation Mode Table

The two-bit signal `sel` selects one of four operations.

| `sel[1:0]` | Operation | Behavior |
|---|---|---|
| `2'b00` | Hold | Retain the current register value |
| `2'b01` | Shift right | Shift data toward the LSB |
| `2'b10` | Shift left | Shift data toward the MSB |
| `2'b11` | Parallel load | Load the complete input word |

### 8.1 Hold operation

For hold mode:

\[
Q_{\text{next}}=Q
\]

The register retains its previous value at the active clock edge. The hold datapath simply passes the current state to the selector.

### 8.2 Shift-right operation

For `WIDTH > 1`:

```verilog
shift_right_data = {serial_in_right, q[WIDTH-1:1]};
```

The bits move one position toward the LSB. The serial input is inserted into the MSB.

For example:

```text
Before:             10110010
serial_in_right:           0
After shift right:  01011001
```

Immediately before the active edge, the old LSB is visible on `serial_out_right`. After the edge, that output reflects the new state’s LSB; the design does not latch the shifted-out bit into a separate output register.

### 8.3 Shift-left operation

For `WIDTH > 1`:

```verilog
shift_left_data = {q[WIDTH-2:0], serial_in_left};
```

The bits move one position toward the MSB. The serial input is inserted into the LSB.

For example:

```text
Before:             10110010
serial_in_left:            1
After shift left:   01100101
```

Immediately before the active edge, the old MSB is visible on `serial_out_left`. After the edge, that output reflects the new state’s MSB; the design does not latch the shifted-out bit into a separate output register.

### 8.4 Parallel-load operation

In parallel-load mode:

```verilog
parallel_load_data = parallel_in;
```

All register bits are loaded together on an enabled rising clock edge.

For example:

```text
parallel_in = 11001010

After parallel load:

q            = 11001010
```

### Special case: `WIDTH = 1`

The shift modules contain explicit generate branches for a one-bit register. In that configuration, a shift operation replaces the sole bit with its corresponding serial input.

This prevents invalid ranges such as `q[-1:0]` from being generated.

---

## 9. Detailed Module Descriptions

### 9.1 `usr_hold.v`

**Purpose:** Provides the hold-operation datapath.

**Inputs:**
- `q[WIDTH-1:0]`: Current register state.

**Outputs:**
- `hold_data[WIDTH-1:0]`: Unmodified register data.

**Working mechanism:**

The module uses a continuous assignment:

```verilog
assign hold_data = q;
```

No storage element exists inside this module. It simply passes the current value to the operation selector.

**Why separate this function?**

It makes the four operation datapaths explicit and keeps the top-level structure consistent.

### 9.2 `usr_shift_right.v`

**Purpose:** Produces the right-shifted candidate value.

**Inputs:**
- `q[WIDTH-1:0]`: Current register state.
- `serial_in_right`: Bit inserted at the MSB.

**Output:**
- `shift_right_data[WIDTH-1:0]`.

**Working mechanism:**

For widths greater than one, concatenation places the serial input at the MSB and shifts the remaining bits right.

For width one, the sole output bit is assigned directly from `serial_in_right`.

This module is combinational; it does not update `q` itself.

### 9.3 `usr_shift_left.v`

**Purpose:** Produces the left-shifted candidate value.

**Inputs:**
- `q[WIDTH-1:0]`: Current register state.
- `serial_in_left`: Bit inserted at the LSB.

**Output:**
- `shift_left_data[WIDTH-1:0]`.

**Working mechanism:**

For widths greater than one, the lower `WIDTH-1` bits are concatenated with `serial_in_left`, placing the serial input at the LSB.

For width one, the sole output bit is assigned directly from `serial_in_left`.

### 9.4 `usr_parallel_load.v`

**Purpose:** Provides the parallel-load candidate value.

**Input:**
- `parallel_in[WIDTH-1:0]`.

**Output:**
- `parallel_load_data[WIDTH-1:0]`.

**Working mechanism:**

The module passes the input word unchanged to the selector. Actual storage occurs later in the register-storage module.

### 9.5 `usr_operation_selector.v`

**Purpose:** Selects the candidate next-state value.

**Inputs:**
- `sel[1:0]`.
- `hold_data`.
- `shift_right_data`.
- `shift_left_data`.
- `parallel_load_data`.

**Output:**
- `next_data[WIDTH-1:0]`.

**Working mechanism:**

A combinational `always @(*)` block and `case` statement choose the appropriate candidate.

The selector maps `00` to hold, `01` to shift right, `10` to shift left, and `11` to parallel load.

A default assignment is included to provide a defined branch for the case statement. The default does not make an unknown `sel` value a supported operating mode; normal operation requires a known selector.

### 9.6 `usr_register_storage.v`

**Purpose:** Stores the selected next-state data.

**Inputs:**
- `clk`: Clock.
- `rst`: Synchronous active-high reset.
- `enable`: Active-high update enable.
- `next_data[WIDTH-1:0]`: Selected candidate value.

**Output:**
- `q[WIDTH-1:0]`: Stored register state.

**Working mechanism:**

```verilog
always @(posedge clk) begin
    if (rst)
        q <= {WIDTH{1'b0}};
    else if (enable)
        q <= next_data;
end
```

The reset condition has priority over enable. If reset is inactive and enable is low, no assignment occurs, so the register retains its previous value.

Nonblocking assignments (`<=`) are used for sequential logic, as is standard practice for clocked Verilog RTL.

### 9.7 `parameterized_universal_shift_register.v`

**Purpose:** Integrates all functional modules into the complete universal shift register.

**Responsibilities:**

- Declares the `WIDTH` parameter.
- Exposes the external control and data ports.
- Connects the four candidate datapaths.
- Connects the operation selector.
- Connects the clocked storage.
- Provides serial outputs from the current register state.

**Working mechanism:**

The top-level module passes the same `WIDTH` parameter into every submodule. This keeps all datapath widths consistent.

The top module does not contain the detailed logic for each operation. It instantiates the function-wise modules and connects their signals.

### 9.8 `tb_parameterized_universal_shift_register.v`

**Purpose:** Simulates the top-level module and checks its behavior.

**Responsibilities:**

- Generates a 10 ns clock.
- Initializes all test inputs.
- Instantiates the design under test (DUT).
- Applies reset and operation sequences.
- Compares the actual output against expected values.
- Counts test failures.
- Prints a final PASS or FAIL summary.

The testbench is simulation-only and is not intended for FPGA synthesis.

---

## 10. Top-Level Port Descriptions

| Port | Direction | Width | Description |
|---|---|---:|---|
| `clk` | Input | 1 bit | Positive-edge clock |
| `rst` | Input | 1 bit | Synchronous active-high reset |
| `enable` | Input | 1 bit | Allows register state updates |
| `sel` | Input | 2 bits | Selects the operation |
| `parallel_in` | Input | `WIDTH` bits | Parallel input data |
| `serial_in_left` | Input | 1 bit | Inserted at LSB during shift left |
| `serial_in_right` | Input | 1 bit | Inserted at MSB during shift right |
| `q` | Output | `WIDTH` bits | Current register contents |
| `serial_out_left` | Output | 1 bit | Current MSB |
| `serial_out_right` | Output | 1 bit | Current LSB |

The serial outputs are continuously assigned from the stored register value:

```verilog
assign serial_out_left  = q[WIDTH-1];
assign serial_out_right = q[0];
```

They are not separate registered pulses. Their values follow the current register state.

---

## 11. Parameterization: 1–128 Bits

The top-level parameter is declared in the module parameter-port list. A valid Verilog-2001 header pattern is:

```verilog
module parameterized_universal_shift_register #(
    parameter WIDTH = 8
) (
    // Declare the module ports here.
);
```

The default width is 8 bits. A different width can be selected at instantiation time.

### Example configurations

```verilog
// 1-bit register
parameterized_universal_shift_register #(
    .WIDTH(1)
) u_usr_1bit (
    // Connect ports
);

// 8-bit register
parameterized_universal_shift_register #(
    .WIDTH(8)
) u_usr_8bit (
    // Connect ports
);

// 32-bit register
parameterized_universal_shift_register #(
    .WIDTH(32)
) u_usr_32bit (
    // Connect ports
);

// 64-bit register
parameterized_universal_shift_register #(
    .WIDTH(64)
) u_usr_64bit (
    // Connect ports
);

// 128-bit register
parameterized_universal_shift_register #(
    .WIDTH(128)
) u_usr_128bit (
    // Connect ports
);
```

These are examples of parameter syntax; actual signal connections must be supplied.

### What changes with width?

When `WIDTH` changes:

- The `q` register changes size.
- The parallel input bus changes size.
- The internal operation datapaths change size.
- The selected next-state bus changes size.
- The MSB output index changes to `WIDTH-1`.
- The hardware resources needed for storage and datapath logic change.

The control interface remains the same: one clock, one reset, one enable, and a two-bit selector.

**Important:** The legal width range is a project requirement, not an automatic guarantee enforced by the parameter declaration. The build or verification flow should reject widths below 1 or above 128.

---

## 12. Working Mechanism

The complete design follows a repeatable synchronous process.

### Step 1: Read the current state

The register-storage module exposes the current contents through `q`.

### Step 2: Generate candidate data

The functional datapaths generate hold, shift-right, shift-left, and parallel-load candidates from the current state and input signals.

### Step 3: Select an operation

The operation selector reads `sel[1:0]` and places the selected candidate on `next_data`.

### Step 4: Evaluate reset and enable

At a rising clock edge:

- If `rst = 1`, clear the register.
- Otherwise, if `enable = 1`, store `next_data`.
- Otherwise, retain the current value.

### Step 5: Observe the updated state

After the clock edge, `q` reflects the new stored value. The serial outputs continuously reflect the MSB and LSB of that value.

### Conceptual next-state behavior

Let \(Q\) be the current state and \(D\) be the selected candidate data.

\[
Q_{\text{next}} =
\begin{cases}
0, & rst=1\\
D, & rst=0 \land enable=1\\
Q, & rst=0 \land enable=0
\end{cases}
\]

This equation summarizes the storage behavior. The selected candidate \(D\) depends on the operation selector.

---

## 13. Clock, Reset, and Enable Behavior

### Clock

All register state updates occur at the positive edge of `clk`.

### Synchronous reset

The reset is active-high and synchronous. If `rst` becomes high between clock edges, the stored state does not clear immediately. It clears at the next rising edge.

### Enable

When `enable` is high and reset is inactive, the register performs the selected operation on the next rising edge.

When `enable` is low, the register retains its state, regardless of the selected operation.

### Priority table

| `rst` | `enable` | Result at rising edge |
|---:|---:|---|
| 1 | 0 | Clear register |
| 1 | 1 | Clear register |
| 0 | 0 | Hold current state |
| 0 | 1 | Capture selected operation result |

Reset has higher priority than enable.

---

## 14. Example Operation Walkthrough

Assume the register width is 8 bits and the current value is:

```text
q = 10110010
```

### Operation A: Hold

```text
sel = 00
q before = 10110010
q after  = 10110010
```

No state change occurs.

### Operation B: Shift right

```text
sel = 01
serial_in_right = 0

q before = 10110010
q after  = 01011001
```

The new MSB is zero, and the remaining bits move right by one position.

### Operation C: Shift left

```text
sel = 10
serial_in_left = 1

q before = 10110010
q after  = 01100101
```

The new LSB is one, and the remaining bits move left by one position.

### Operation D: Parallel load

```text
sel = 11
parallel_in = 11001010

q after = 11001010
```

All bits are loaded together.

Each example assumes reset is low and enable is high at the relevant rising clock edge.

---

## 15. Testbench Architecture

The testbench uses a design-under-test instance with:

```verilog
localparam WIDTH = 8;
```

The clock generation is:

```verilog
initial clk = 1'b0;
always #5 clk = ~clk;
```

With a testbench timescale of `1ns/1ps`, this creates a 10 ns period, corresponding to 100 MHz in simulation. If the testbench uses a different timescale, the delay units change accordingly.

The testbench contains a comparison task that checks `q` against an expected value. It uses case inequality (`!==`) so unknown values do not silently pass as valid matches.

### Test cases included

1. Synchronous reset.
2. Parallel load.
3. Hold operation.
4. Shift right.
5. Reload before shift left.
6. Shift left.
7. Enable-low state retention.
8. Reset priority over enable.

The testbench counts failed comparisons and prints a final result.

### Why use a self-checking testbench?

A waveform can show what happened, but a self-checking testbench also determines whether the observed result matches the expected result. This makes regressions easier to detect and supports automated testing.

---

## 16. Verification and Expected Results

For the supplied 8-bit test sequence, the expected results are:

| Test | Expected result |
|---|---|
| Reset | `00000000` |
| Parallel load | `10110010` |
| Hold | `10110010` |
| Shift right with serial input 0 | `01011001` |
| Reload | `10110010` |
| Shift left with serial input 1 | `01100101` |
| Enable low | Retain `01100101` |
| Reset priority | `00000000` |

A successful testbench run should end with:

```text
ALL TESTS PASSED.
```

This is the expected result, not a claim that a simulator was executed during preparation of this document.

### Recommended expanded verification

For stronger confidence, run separate tests for:

- `WIDTH = 1`
- `WIDTH = 2`
- `WIDTH = 8`
- `WIDTH = 16`
- `WIDTH = 32`
- `WIDTH = 64`
- `WIDTH = 128`

For each width, test all operation modes, repeated shifts, serial input values of both 0 and 1, all-zero and all-one data, reset behavior, and disabled-enable behavior.

A reference-model testbench can compare the DUT state against an independently calculated expected state after each active clock edge.

---

## 17. Vivado Project Setup

### Step 1: Create an RTL project

Open Xilinx Vivado and create a new RTL project. Select the FPGA part or board if hardware implementation is planned.

### Step 2: Add design sources

Add all seven `.v` files from the `rtl/` directory.

Ensure the module names and file contents match the source list.

### Step 3: Set the synthesis top

Select:

```text
parameterized_universal_shift_register
```

as the synthesis top module.

### Step 4: Add the testbench

Add:

```text
tb_parameterized_universal_shift_register.v
```

as a simulation source.

### Step 5: Set the simulation top

Select:

```text
tb_parameterized_universal_shift_register
```

as the simulation top.

### Step 6: Run behavioral simulation

Run **Run Simulation → Run Behavioral Simulation**.

Inspect the transcript for PASS/FAIL messages and examine the waveform to confirm the state transitions occur at the intended clock edges.

### Step 7: Run synthesis

After successful elaboration and simulation, run synthesis with the top-level RTL module selected.

Review warnings, resource utilization, and timing results for the chosen FPGA target.

---

## 18. Simulation Using Icarus Verilog

If Icarus Verilog is installed, run these commands from the project root:

```bash
iverilog -g2001 \
  -s tb_parameterized_universal_shift_register \
  -o usr_sim \
  rtl/usr_hold.v \
  rtl/usr_shift_right.v \
  rtl/usr_shift_left.v \
  rtl/usr_parallel_load.v \
  rtl/usr_operation_selector.v \
  rtl/usr_register_storage.v \
  rtl/parameterized_universal_shift_register.v \
  tb/tb_parameterized_universal_shift_register.v
```

Then run:

```bash
vvp usr_sim
```

The `-g2001` option selects Verilog-2001 language compatibility.

Equivalent compilation and simulation steps can be performed with Vivado XSIM or another compatible simulator.

---

## 19. Synthesis and FPGA Implementation

The design separates combinational candidate generation from clocked storage.

The synthesis tool may map the register state to FPGA flip-flops and the operation selection to combinational logic. The exact implementation depends on the selected FPGA, synthesis settings, and tool version.

No specific resource count, maximum frequency, or timing result is guaranteed by this README.

Before hardware deployment:

1. Select the target FPGA.
2. Add a suitable constraints file.
3. Define the clock period.
4. Assign physical pins for external signals.
5. Run synthesis and implementation.
6. Review timing and utilization reports.
7. Verify reset and enable behavior on hardware if possible.

Do not assign arbitrary FPGA pins without checking the board schematic and device constraints.

---

## 20. Design Limitations and Assumptions

### 20.1 Width-range enforcement

The design is specified for `WIDTH` from 1 through 128. A plain parameter declaration does not automatically enforce this limit. The build or verification flow should reject illegal values.

### 20.2 No rotate operation

The shifted-out bit is not automatically fed back into the opposite end. Rotation would require additional logic.

### 20.3 No arithmetic shift

The design performs logical shifting. It does not preserve the sign bit as an arithmetic-right-shift operation would.

### 20.4 Synchronous reset

Reset is sampled on the rising edge. It does not clear the state asynchronously.

### 20.5 No scan-chain interface

The serial inputs support ordinary shifting, but scan-enable and dedicated scan-test behavior are not implemented.

### 20.6 No handshake interface

The module does not include `ready`, `valid`, `busy`, or `done` signals. Operations are controlled directly through `sel` and `enable`.

### 20.7 Verification scope

The included testbench checks the 8-bit configuration and a limited set of deterministic cases. Additional testing is required for all intended widths and integration conditions.

---

## 21. Troubleshooting

### Problem: Unknown module error

**Possible cause:** One or more RTL files are missing from the project.

**Solution:** Add all seven design modules and check that their declared module names match the instantiated names.

### Problem: Output does not update

**Possible causes:**

- Clock is not toggling.
- Reset remains high.
- Enable is low.
- Selector is not set to the intended mode.
- Inputs are changed at an inappropriate simulation time.

**Solution:** Inspect the control signals and `q` in the waveform.

### Problem: Width-one elaboration error

**Possible cause:** A shift expression uses an invalid part-select.

**Solution:** Retain the explicit `generate` branches in both shift modules and confirm the parameter is propagated to every submodule.

### Problem: Testbench reports a mismatch

**Possible cause:** Incorrect expected data, serial input, selector value, or sampling time.

**Solution:** Check the first failing test and compare the actual value against the expected state after the rising edge.

### Problem: Synthesis reports a latch

**Possible cause:** A combinational block does not assign its outputs on every path.

**Solution:** Ensure `usr_operation_selector` retains a complete `case` statement with a default assignment.

---

## 22. Possible Future Enhancements

The project can be extended with:

- Rotate-left and rotate-right modes.
- Arithmetic right shifting.
- Configurable reset value.
- Asynchronous reset variant.
- A synchronous clear input separate from reset.
- Cascading support for multiple register words.
- Scan-test functionality.
- Parameterized testbenches for widths 1 through 128.
- Randomized reference-model verification.
- Functional coverage of all modes and control combinations.
- Assertions or equivalent checks in a suitable verification environment.
- Vivado constraints and implementation reports for a selected board.
- A dedicated mode for serial-to-parallel and parallel-to-serial interfaces.

Additional features should be added only after defining their control encodings, priority rules, and verification requirements.

---

## 23. Engineering Learning Outcomes

This project demonstrates the following engineering concepts:

- Modular RTL design.
- Parameterized Verilog modules.
- Generate constructs.
- Concatenation and bit slicing.
- Combinational logic using `always @(*)`.
- Sequential logic using `always @(posedge clk)`.
- Nonblocking assignments for clocked state.
- Synchronous reset and enable priority.
- Hierarchical module instantiation.
- Self-checking simulation.
- Width-sensitive RTL design.
- FPGA synthesis and timing analysis.

The project also highlights the importance of handling edge cases such as one-bit configurations and validating expected behavior rather than relying on visual inspection alone.

---

## 24. Final Summary

The Parameterized Universal Shift Register is a modular, reusable Verilog-2001 design intended for register widths from 1 through 128 bits.

It supports hold, shift-right, shift-left, and parallel-load operations selected through `sel[1:0]`. Its storage module uses a rising-edge clock, synchronous active-high reset, and active-high enable. Serial outputs continuously reflect the current MSB and LSB.

The seven RTL modules separate the datapaths, selector, and register storage, while the top-level module integrates the complete design. A self-checking testbench verifies the primary operations in the default 8-bit configuration.

Before use in a larger FPGA design, verify every intended width, confirm the reset and enable conventions match the surrounding system, and inspect synthesis and timing reports for the selected device.

**End of README.md**
