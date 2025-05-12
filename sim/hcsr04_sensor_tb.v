`timescale 1ns/1ps

module hcsr04_sensor_tb;
    reg clk = 0;
    reg start = 0;
    wire trigger;
    reg echo = 0;
    wire done;
    wire [15:0] distance;

    // Instantiate the sensor module
    hcsr04_sensor uut (
        .clk(clk),
        .start(start),
        .trigger(trigger),
        .echo(echo),
        .done(done),
        .distance(distance)
    );

    // 50 MHz clock
    always #10 clk = ~clk;

    // Create VCD file for waveform viewing with selective dumping
    initial begin
        $dumpfile("hcsr04_wave.vcd");
        // Only dump the signals we care about
        $dumpvars(0, clk, start, trigger, echo, done, distance);
    end

    // Function to simulate echo pulse for a given distance
    task simulate_distance;
        input integer distance_mm;
        reg [31:0] echo_cycles;  // Moved outside the begin block
        begin
            // Calculate echo pulse width in clock cycles
            // 294 cycles per mm at 50MHz
            echo_cycles = distance_mm * 294;
            
            // Wait for trigger pulse to complete
            wait(trigger == 0);
            
            // Generate echo pulse
            #100 echo = 1;
            #(echo_cycles * 20) echo = 0;  // 20ns per cycle
        end
    endtask

    initial begin
        $display("Starting HC-SR04 sensor simulation...");
        
        // Test case 1: 100mm distance
        #100;
        $display("Starting test case 1: 100mm");
        start = 1;
        #20 start = 0;
        $display("Waiting for trigger...");
        wait(trigger == 0);
        $display("Trigger complete, simulating echo...");
        simulate_distance(100);
        $display("Waiting for done signal...");
        wait(done);
        $display("Distance measured: %d mm", distance);
        
        // Test case 2: 500mm distance
        #1000;
        $display("Starting test case 2: 500mm");
        start = 1;
        #20 start = 0;
        $display("Waiting for trigger...");
        wait(trigger == 0);
        $display("Trigger complete, simulating echo...");
        simulate_distance(500);
        $display("Waiting for done signal...");
        wait(done);
        $display("Distance measured: %d mm", distance);
        
        // Test case 3: 1000mm distance
        #1000;
        $display("Starting test case 3: 1000mm");
        start = 1;
        #20 start = 0;
        $display("Waiting for trigger...");
        wait(trigger == 0);
        $display("Trigger complete, simulating echo...");
        simulate_distance(1000);
        $display("Waiting for done signal...");
        wait(done);
        $display("Distance measured: %d mm", distance);
        
        // Stop dumping after all tests are complete
        $dumpoff;
        #1000;
        $finish;
    end
endmodule