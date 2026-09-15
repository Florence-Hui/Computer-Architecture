module top (
    input  logic clk,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);

    localparam int unsigned STEP_INTERVAL = 2_000_000;
    logic [$clog2(STEP_INTERVAL)-1:0] clk_cnt = '0;

    logic [2:0] state = 3'd0;


    always_ff @(posedge clk) begin
        if (clk_cnt == STEP_INTERVAL - 1) begin
            clk_cnt <= '0;
            if (state == 3'd5)
                state <= 3'd0;
            else
                state <= state + 1'b1;
        end else begin
            clk_cnt <= clk_cnt + 1'b1;
        end
    end

    always_comb begin
        case (state)
            3'd0:    {RGB_R, RGB_G, RGB_B} = 3'b011; // RED:     R ON
            3'd1:    {RGB_R, RGB_G, RGB_B} = 3'b001; // YELLOW:  R+G ON
            3'd2:    {RGB_R, RGB_G, RGB_B} = 3'b101; // GREEN:   G ON
            3'd3:    {RGB_R, RGB_G, RGB_B} = 3'b100; // CYAN:    G+B ON
            3'd4:    {RGB_R, RGB_G, RGB_B} = 3'b110; // BLUE:    B ON
            3'd5:    {RGB_R, RGB_G, RGB_B} = 3'b010; // MAGENTA: R+B ON
            default: {RGB_R, RGB_G, RGB_B} = 3'b111; // All OFF
        endcase
    end

endmodule
