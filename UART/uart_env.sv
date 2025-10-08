class uart_env extends uvm_env;
	`uvm_component_utils(uart_env) // register to factory
	uart_agent uart_agent_h; //declaring handle of agent class
	function new(string name = "uart_env",uvm_component parent = null);
		super.new(name,parent);
		$display("Inside the constructor of env");
		`uvm_info("UART_ENV","Inside constructor of env",UVM_NONE); //uvm_info(ide,message,verbosity);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("UART_ENV","Inside build of env",UVM_NONE);
		//uart_agent_h=new(); //in cas of SV
		uart_agent_h=uart_agent::type_id::create("uart_agent_h",this);
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info("UART_ENV","Inside connect of env",UVM_NONE);
	endfunction

endclass
