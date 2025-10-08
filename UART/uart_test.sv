class uart_test extends uvm_test;

	`uvm_component_utils(uart_test) // register to factory
	uart_env uart_env_h; //declaring handle of env class	
	uart_sequence uart_sequence_h;
	function new(string name = "uart_test",uvm_component parent = null);
		super.new(name,parent);
		$display("Inside the constructor of test");
		`uvm_info("UART_TEST","Inside constructor of test",UVM_NONE); //uvm_info(ide,message,verbosity);
		//`uvm_info("uart_TEST","Inside constructor of test",UVM_LOW);
		//`uvm_info("uart_TEST","Inside constructor of test",UVM_MEDIUM);
		//`uvm_info("uart_TEST","Inside constructor of test",UVM_HIGH);
		//`uvm_info("uart_TEST","Inside constructor of test",UVM_DEBUG);
		//`uvm_info("uart_TEST","Inside constructor of test",UVM_FULL);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("UART_TEST","Inside build of test",UVM_NONE);
		//uart_env_h=new(); //in case of SV
		uart_env_h=uart_env::type_id::create("uart_env_h",this);
		
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info("UART_TEST","Inside connect of test",UVM_NONE);
	endfunction

	virtual function void end_of_elaboration_phase(uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info("UART_TEST","Inside end_of_elaboration of test",UVM_NONE);
		uvm_top.print_topology(); //Prints the topology of UVM test environment for better understanding.
	endfunction

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		`uvm_info("UART_TEST","Inside run phase of test",UVM_NONE);
		//#100;
		uart_sequence_h=uart_sequence::type_id::create("uart_sequence");
		uart_sequence_h.start(uart_env_h.uart_agent_h.uart_sequencer_h);
		`uvm_info("UART_TEST","Inside run phase of test and sequence completed",UVM_NONE);
		#100;
		phase.drop_objection(this);
	endtask

endclass

