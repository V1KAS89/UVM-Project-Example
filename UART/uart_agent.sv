class uart_agent extends uvm_agent;
	`uvm_component_utils(uart_agent) // register to factory
	uart_driver uart_driver_h; //declaring handle of driver class
	uart_sequencer uart_sequencer_h;

	function new(string name = "uart_agent",uvm_component parent = null);
		super.new(name,parent);
		$display("Inside the constructor of agent");
		`uvm_info("UART_AGENT","Inside constructor of agent",UVM_NONE); //uvm_info(ide,message,verbosity);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("UART_AGENT","Inside build of agent",UVM_NONE);
		//uart_driver_h=new(); //in cas of SV
		uart_driver_h=uart_driver::type_id::create("uart_driver_h",this); //UVM way of creating object/handle
		uart_sequencer_h=uart_sequencer::type_id::create("uart_sequencer_h",this);
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info("UART_AGENT","Inside connect of agent",UVM_NONE);
		uart_driver_h.seq_item_port.connect(uart_sequencer_h.seq_item_export);
	endfunction

endclass
