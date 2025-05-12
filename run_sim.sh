#!/bin/bash
iverilog -o hcsr04_sim ./src/hcsr04_sensor.v ./sim/hcsr04_sensor_tb.v && vvp hcsr04_sim
