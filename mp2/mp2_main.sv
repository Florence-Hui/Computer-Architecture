`timescale 1ns / 1ps

module top #(
    parameter CLK_FREQ = 12000000
)(
    input  logic clk,
    input  logic SW,      
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);

    //There are 6 distinct color states in total. Within each state, an 8-bit variable would adjust the LED brightness across 256 levels
    //Therefore, in total, there would be 6*256 = 1536 steps
    localparam STEP_TICKS = CLK_FREQ / 1536; 

    
    // FSM State Definitions
    typedef enum logic [2:0] {
        S_0_TO_60    = 3'd0, // Red Max, Green Ramps Up, Blue Min
        S_60_TO_120  = 3'd1, // Red Ramps Down, Green Max, Blue Min
        S_120_TO_180 = 3'd2, // Red Min, Green Max, Blue Ramps Up
        S_180_TO_240 = 3'd3, // Red Min, Green Ramps Down, Blue Max
        S_240_TO_300 = 3'd4, // Red Ramps Up, Green Min, Blue Max
        S_300_TO_360 = 3'd5  // Red Max, Green Min, Blue Ramps Down
    } state_t;

    
    // Registers & Inline Initialization
    logic [31:0] step_timer = '0; // start counting from zero upon power-up so that the system would move to the next brightness
    logic [7:0] fade_val = 8'd0; // from zero to 255 to determine the progress within the current 60-degree wedge of the color wheel
    logic [7:0] pwm_counter = 8'd0; // rapidly loop from 0 to 255, increments the value on every clock tick
    state_t state = S_0_TO_60; //tracks which of the 6 states is currently active. Initially is from red to yellow
    
    logic [7:0] r_duty, g_duty, b_duty; //store the final target brightness for the R, G, B LEDs

    
    always_ff @(posedge clk) begin
        pwm_counter <= pwm_counter + 8'd1;
    end

    assign RGB_R = ~(pwm_counter < r_duty);
    assign RGB_G = ~(pwm_counter < g_duty);
    assign RGB_B = ~(pwm_counter < b_duty);


    // FSM & Duty Cycle Logic
    always_ff @(posedge clk) begin
        if (step_timer >= (STEP_TICKS - 1)) begin
            step_timer <= '0;
            
            if (fade_val == 8'd255) begin
                fade_val <= 8'd0;
                
                case (state)
                    S_0_TO_60: state <= S_60_TO_120;
                    S_60_TO_120: state <= S_120_TO_180;
                    S_120_TO_180: state <= S_180_TO_240;
                    S_180_TO_240: state <= S_240_TO_300;
                    S_240_TO_300: state <= S_300_TO_360;
                    S_300_TO_360: state <= S_0_TO_60;
                    default: state <= S_0_TO_60;
                endcase
            end else begin
                fade_val <= fade_val + 8'd1;
            end
        end else begin
            step_timer <= step_timer + 1'b1;
        end
    end


    // RGB Duty Cycle Mapping
    always_comb begin
        case (state)
            S_0_TO_60: begin // 0 to 60 deg
                r_duty = 8'd255;
                g_duty = fade_val;
                b_duty = 8'd0;
            end
            S_60_TO_120: begin // 60 to 120 deg
                r_duty = 8'd255 - fade_val;
                g_duty = 8'd255;
                b_duty = 8'd0;
            end
            S_120_TO_180: begin // 120 to 180 deg
                r_duty = 8'd0;
                g_duty = 8'd255;
                b_duty = fade_val;
            end
            S_180_TO_240: begin // 180 to 240 deg
                r_duty = 8'd0;
                g_duty = 8'd255 - fade_val;
                b_duty = 8'd255;
            end
            S_240_TO_300: begin // 240 to 300 deg
                r_duty = fade_val;
                g_duty = 8'd0;
                b_duty = 8'd255;
            end
            S_300_TO_360: begin // 300 to 360 deg
                r_duty = 8'd255;
                g_duty = 8'd0;
                b_duty = 8'd255 - fade_val;
            end
            default: begin
                r_duty = 8'd0;
                g_duty = 8'd0;
                b_duty = 8'd0;
            end
        endcase
    end

endmodule