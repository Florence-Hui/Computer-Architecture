# Miniproject 1: HSV Color Wheel LED Cycler

## 1. Project Overview
This project implements a hardware-based HSV color wheel state machine.

The circuit continuously cycles through six colors  at a rate of one full cycle per second.

---

## 2. Hardware Architecture & Design Logic

### Clock 
* **Timing Calculation**: To complete 6 color transitions in 1 second, each color state must persist for:
  $$\text{Interval} = \frac{12,000,000 \text{ cycles}}{6} = 2,000,000 \text{ cycles}$$
* **Counter**: The code counts from 0 up to 1,999,999.
* **State**: When the counter reaches 2 million, it resets to 0 and moves to the next color state (0 to 5).

### Color 
* **Active-Low Configuration**
* **Color Mapping**: 
  * `State 0 (RED)`: `{RGB_R, RGB_G, RGB_B} = 3'b011` (Red ON)
  * `State 1 (YELLOW)`: `{RGB_R, RGB_G, RGB_B} = 3'b001` (Red + Green ON)
  * `State 2 (GREEN)`: `{RGB_R, RGB_G, RGB_B} = 3'b101` (Green ON)
  * `State 3 (CYAN)`: `{RGB_R, RGB_G, RGB_B} = 3'b100` (Green + Blue ON)
  * `State 4 (BLUE)`: `{RGB_R, RGB_G, RGB_B} = 3'b110` (Blue ON)
  * `State 5 (MAGENTA)`: `{RGB_R, RGB_G, RGB_B} = 3'b010` (Red + Blue ON)


---

## 4. Key Learnings & Reflections

 My biggest learning from this project was understanding the difference between software and hardware design. Since I used to program in python and C++, I am used to instructions running line by line on a processor. In SystemVerilog, the code actually builds physical components like flip-flops and logic gates that exist and run at the same time.

### Note for writing SystemVerilog

The standard architectural pattern used in SystemVerilog:
* A typical module separates sequential state tracking from combinational decision-making. 
* `always_ff @(posedge clk)` block: Physical storage elements and registers
* `always_comb` block: Decision-making, arithmetic, and decoding logic

