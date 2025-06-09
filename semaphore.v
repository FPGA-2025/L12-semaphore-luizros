module Semaphore (
    input wire clk,
    input wire rst_n,
    input wire pedestrian,
    output reg green,
    output reg yellow,
    output reg red
);
    parameter CLK_FREQ = 100_000_000;

    // Estados da máquina (Verilog puro)
    localparam S_RED    = 2'b00;
    localparam S_GREEN  = 2'b01;
    localparam S_YELLOW = 2'b10;

    reg [1:0] state, next_state;

    // Contadores para temporização
    localparam integer RED_TICKS    = 5   * CLK_FREQ;      // 5 segundos
    localparam integer GREEN_TICKS  = 7   * CLK_FREQ;      // 7 segundos
    localparam integer YELLOW_TICKS = CLK_FREQ / 2;        // 0,5 segundo

    reg [31:0] counter, next_counter;

    // Lógica de transição de estados
    always @(*) begin
        next_state = state;
        next_counter = counter;

        case (state)
            S_RED: begin
                if (counter >= RED_TICKS - 1) begin
                    next_state = S_GREEN;
                    next_counter = 0;
                end else begin
                    next_counter = counter + 1;
                end
            end

            S_GREEN: begin
                if (pedestrian) begin
                    next_state = S_YELLOW;
                    next_counter = 0;
                end else if (counter >= GREEN_TICKS - 1) begin
                    next_state = S_YELLOW;
                    next_counter = 0;
                end else begin
                    next_counter = counter + 1;
                end
            end

            S_YELLOW: begin
                if (counter >= YELLOW_TICKS - 1) begin
                    next_state = S_RED;
                    next_counter = 0;
                end else begin
                    next_counter = counter + 1;
                end
            end

            default: begin
                next_state = S_RED;
                next_counter = 0;
            end
        endcase
    end

    // Lógica sequencial
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_RED;
            counter <= 0;
        end else begin
            state <= next_state;
            counter <= next_counter;
        end
    end

    // Saídas
    always @(*) begin
        green  = (state == S_GREEN);
        yellow = (state == S_YELLOW);
        red    = (state == S_RED);
    end

endmodule