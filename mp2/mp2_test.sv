`timescale 1ns / 1ps

module mp2_tb;
    logic clk;
    logic SW;
    logic RGB_R, RGB_G, RGB_B;

    
    top #(
        .CLK_FREQ(15360) 
    ) dut (
        .clk(clk),
        .SW(SW),
        .RGB_R(RGB_R),
        .RGB_G(RGB_G),
        .RGB_B(RGB_B)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("mp2_sim.vcd");
        $dumpvars(0, mp2_tb);

        SW = 0; // Active-low reset asserted
        #20;
        SW = 1; // Release reset

        #160000; // Wait for a full color wheel cycle

        $display("Simulation complete.");
        $finish;
    end
endmodule