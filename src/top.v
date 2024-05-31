// Testbench for the nano6502

module top
(
    input clk_i,
    input rst_i,
    input uart_rx_i
);

    nano6502_top dut(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .uart_rx_i(uart_rx_i),
        .uart_tx_o(),
        .leds()
    );

    initial begin
        if($test$plusargs("trace") != 0) begin
            $display("[%0t] Tracing to logs/vlt_dump.vcd...\n", $time);
            $dumpfile("logs/vltdump.vcd");
            $dumpvars();
        end
        $display("[%0t] Model running...\n", $time);
    end

    always_ff @ (posedge clk_i) begin
        if($time > 1000000) begin
            $write("*-* All Finished *-*\n");
            $finish;
        end
    end
endmodule
