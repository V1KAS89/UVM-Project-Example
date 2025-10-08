class uart_sequencer extends uvm_sequencer#(uart_seq_item);
	`uvm_component_utils(uart_sequencer) // register to factory
	function new(string name = "UART_SEQUENCER",uvm_component parent = null);
		super.new(name,parent);
		$display("Inside the constructor of sequencer");
		`uvm_info("UART_SEQUENCER","Inside constructor of sequencer",UVM_NONE); //uvm_info(ide,message,verbosity);
	endfunction

	

endclass
