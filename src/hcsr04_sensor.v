module hcsr04_sensor (
    input clk,          // 50MHz clock
    input start,        // Start measurement
    output reg trigger, // Trigger pulse output
    input echo,         // Echo pulse input
    output reg done,    // Measurement complete
    output reg [15:0] distance  // Distance in mm
);

    // States for the state machine
    localparam IDLE = 2'b00;
    localparam TRIGGER = 2'b01;
    localparam WAIT_ECHO = 2'b10;
    localparam MEASURE = 2'b11;

    reg [1:0] state = IDLE;  // Initialize state to IDLE
    reg [9:0] counter = 0;      // Initialize counter
    reg [15:0] echo_count = 0;  // Initialize echo count
    reg measuring = 0;          // Initialize measuring flag

    // Speed of sound = 340 m/s = 340,000 mm/s
    // Time = Distance * 2 / Speed
    // For 1mm: Time = 2mm / 340,000mm/s = 5.88µs
    // At 50MHz (20ns period): 5.88µs / 20ns = 294 cycles per mm

    always @(posedge clk) begin
        case (state)
            IDLE: begin
                trigger <= 0;
                done <= 0;
                if (start) begin
                    state <= TRIGGER;
                    counter <= 0;
                end
            end

            TRIGGER: begin
                trigger <= 1;
                counter <= counter + 1;
                if (counter >= 499) begin  // 10µs trigger pulse (500 cycles at 50MHz)
                    state <= WAIT_ECHO;
                    trigger <= 0;
                    measuring <= 0;
                    echo_count <= 0;
                end
            end

            WAIT_ECHO: begin
                if (echo) begin
                    state <= MEASURE;
                    measuring <= 1;
                end
            end

            MEASURE: begin
                if (measuring) begin
                    if (echo) begin
                        echo_count <= echo_count + 1;
                    end else begin
                        measuring <= 0;
                        // Convert echo count to distance in mm
                        // At 50MHz, 294 cycles = 1mm
                        // Divide by 2 because we're measuring round trip
                        distance <= echo_count / 294;
                        $display("Debug: echo_count=%d, calculated distance=%d", echo_count, echo_count / 294);
                        done <= 1;
                        state <= IDLE;
                    end
                end
            end
        endcase
    end
endmodule 