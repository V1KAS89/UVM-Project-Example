class uart_sequence extends uvm_sequence#(uart_seq_item);

	`uvm_object_utils(uart_sequence)
	uart_seq_item uart_seq_item_h; 
	function new(string name = "uart_sequence");
		super.new(name);
	endfunction

	task body;
		`uvm_info("UART_SEQUENCE","enter inside body of sequence",UVM_NONE);
		uart_seq_item_h = uart_seq_item::type_id::create("uart_seq_item_h");

		start_item(uart_seq_item_h);
		if(!uart_seq_item_h.randomize() ) begin //with {WRITE == 1'b0;}) begin
			`uvm_error("RANDOMIZATION FAILED","randomization failed");
		end
		else begin
			`uvm_info("UART_SEQUENCE","Randomization successful with the folowing value",UVM_NONE);
			uart_seq_item_h.print();
		end
		finish_item(uart_seq_item_h);

		`uvm_info("UART_SEQUENCE","exit body of sequence",UVM_NONE);
	endtask

endclass
