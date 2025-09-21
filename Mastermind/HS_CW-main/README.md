# MasterMind Embedded Systems Project

## Overview
This project implements a MasterMind board game on a Raspberry Pi (models 2, 3, or 4) using C and ARM Assembler. The application interfaces with external hardware components including LEDs, a button, and an LCD display to create an interactive gaming experience.

## Hardware Requirements
- Raspberry Pi 2, 3, or 4 (not 5)
- Breadboard
- 2 LEDs (green and red)
- 1 push button
- 16x2 LCD display with potentiometer for contrast control
- Wiring components (jumper wires, resistors, etc.)

## Wiring Configuration
The devices are connected to the Raspberry Pi GPIO pins as follows:

### LEDs:
- Green LED (data): GPIO 13
- Red LED (control): GPIO 5

### Button:
- Input button: GPIO 19

### LCD Display:
- RS: GPIO 25
- EN: GPIO 24
- D4: GPIO 23
- D5: GPIO 10
- D6: GPIO 27
- D7: GPIO 22
- Backlight+: 3.3V power
- Backlight-: Ground

The potentiometer for contrast control should be connected with its middle pin to LCD pin 3, and the other legs to ground and power.

I have attached a photo showing the complete wiring connections below.

## Software Requirements
- Raspbian (32-bit) OS
- GNU toolchain (gcc, as, ld)
- GNU debugger (gdb) for debugging

## Installation & Compilation
1. Clone the repository to your Raspberry Pi
2. Navigate to the project directory
3. Compile the project using:
   ```
   make
   ```
4. The executable `cw2` will be generated

## Usage
Run the application with:
```
./cw2 [options]
```

### Command-line Options:
- `-v`: Verbose mode
- `-d`: Debug mode (shows secret sequence)
- `-u <seq1> <seq2>`: Unit test mode (tests matching function)
- `-s <secret sequence>`: Set custom secret sequence

### Examples:
- Normal gameplay: `./cw2`
- Debug mode: `./cw2 -d`
- Unit test: `./cw2 -u 123 321`
- Custom secret: `./cw2 -s 123`

## Gameplay Instructions
1. The Raspberry Pi generates a secret sequence of 3 numbers (1-3)
2. As the codebreaker, you attempt to guess the sequence
3. For each number in your guess:
   - Press the button the number of times corresponding to your guess (e.g., press 3 times for number 3)
   - Wait for the timeout (input separation)
   - The red LED will blink once to acknowledge input
   - The green LED will echo your input by blinking the same number of times
4. After entering all three numbers:
   - The red LED blinks twice to indicate input completion
5. The answer is provided through LED patterns:
   - Green LED blinks for exact matches (correct number in correct position)
   - Red LED blinks once as a separator
   - Green LED blinks for approximate matches (correct number in wrong position)
   - Red LED blinks three times to start a new round
6. The LCD display shows the number of exact and approximate matches
7. On successful guess, the green LED blinks three times with red LED on, and "SUCCESS" appears on the LCD

## Project Structure
- `master-mind.c`: Main application logic in C
- `mm-matches.s`: ARM Assembler implementation of the matching function
- `lcdBinary.c`: Low-level LCD control functions
- Additional files for GPIO control and hardware interaction

## Key Features
- Hardware interfacing using ARM Assembler for direct GPIO control
- Timer-based input handling with timeout detection
- LED-based feedback system
- LCD display output
- Unit testing capability
- Debug mode for development
