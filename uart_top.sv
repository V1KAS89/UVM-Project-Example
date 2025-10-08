module uart_top;
  import uart_pkg::*;
  import uvm_pkg::*;

  logic clk;
  logic rst;

  uart_interface uart_intf(.clk(clk), .rst(rst));

  uart uart_design (
    .clk      (uart_intf.clk),
    .reset_n  (~uart_intf.rst),
    .tx_data  (uart_intf.tx_data),
    .tx_valid (uart_intf.tx_valid),
    .tx_ready (uart_intf.tx_ready),
    .txd      (uart_intf.txd),
    .rxd      (uart_intf.rxd),
    .rx_data  (uart_intf.rx_data),
    .rx_valid (uart_intf.rx_valid)
  );


  initial $display("Starting UART top module...");

  initial begin
    $dumpfile("uart.vcd");
    $dumpvars();
	run_test("uart_test");
  end

initial begin
	clk = 1'b0;
	rst = 1'b1;
	#100 rst = 1'b0;
end

initial begin

	forever begin
		#10 clk = ~clk;
	end
end

  initial begin
    /*// Set virtual interface for driver
    if (!uvm_config_db#(virtual uart_interface)::set(null, "*uart_driver_h*", "vif", uart_intf))
      `uvm_error("UART_TOP", "Failed to set UART virtual interface")
    else
      `uvm_info("UART_TOP", "UART virtual interface set successfully", UVM_LOW);

    // Start UVM test
    run_test("uart_test");*/
	uvm_config_db#(virtual uart_interface)::set(null, "*uart_driver_h*", "vif", uart_intf);
  end

endmodule
