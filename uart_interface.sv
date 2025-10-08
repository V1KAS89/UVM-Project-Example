interface uart_interface(clk,rst);
	input clk,rst;
	logic 	    PSEL;
	logic[7:0]  tx_data;
	logic	    tx_valid;
	logic 	    tx_ready;
	logic	    txd;
	logic	    rxd;
	logic[7:0]  rx_data;
	logic 	    rx_valid;

endinterface

