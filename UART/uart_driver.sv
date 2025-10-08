/*
class uart_driver extends uvm_driver#(uart_seq_item);
  `uvm_component_utils(uart_driver) // register to factory

  virtual uart_interface uart_vif;
  uart_seq_item req; // Active transaction

  function new(string name = "uart_driver",uvm_component parent = null);
    super.new(name,parent);
    `uvm_info("UART_DRIVER","Inside constructor of driver",UVM_NONE);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("UART_DRIVER","Inside build of driver",UVM_NONE);
    if(!(uvm_config_db#(virtual uart_interface)::get(this,"","vif",uart_vif))) begin
      `uvm_fatal("GET_FAILED","uart_interface was not set properly");
    end
    else begin
      `uvm_info("UART_DRIVER","uart_interface GET SUCCESSFUL",UVM_NONE);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("UART_DRIVER","Inside connect of driver",UVM_NONE);
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info("UART_DRIVER","item received in the driver",UVM_NONE);
      req.print();

      check_reset();

      if (req.tx_valid) begin
        perform_tx(req.tx_data);
        // For loopback: push transmitted byte into RX side
        perform_rx(req.rx_stim);
      end
      else begin
        // If no TX, you may still choose to drive RX idle
        perform_rx(req.rx_stim);
      end

      seq_item_port.item_done(req);
    end
  endtask

  // -------------------------------
  // Task: Transmit
  // -------------------------------
  task perform_tx(bit [7:0] data);
    @(posedge uart_vif.clk);
    uart_vif.tx_data  <= data;
    uart_vif.tx_valid <= 1'b1;

    // Wait until DUT is ready
    @(posedge uart_vif.clk);
    wait (uart_vif.tx_ready);

    uart_vif.tx_valid <= 1'b0;
    `uvm_info("UART_DRIVER", $sformatf("Transmitted data: %0h", data), UVM_LOW)
  endtask

  // -------------------------------
  // Task: Receive (loopback style)
  // -------------------------------
  task perform_rx(bit [7:0] data);
    int i;
    // Start bit
    uart_vif.rxd <= 1'b0;
    @(posedge uart_vif.clk);

    // Data bits LSB-first
    for (i = 0; i < 8; i++) begin
      uart_vif.rxd <= data[i];
      @(posedge uart_vif.clk);
    end

    // Stop bit
    uart_vif.rxd <= 1'b1;
    @(posedge uart_vif.clk);

    // Optionally check if DUT received correctly
    if (uart_vif.rx_valid) begin
      `uvm_info("UART_DRIVER", $sformatf("Received data: %0h", uart_vif.rx_data), UVM_LOW)
    end
  endtask

  // -------------------------------
  // Task: Reset check
  // -------------------------------
  task check_reset();
    if (uart_vif.rst) begin
      @(posedge uart_vif.clk);
      uart_vif.tx_data  <= 8'b0;
      uart_vif.tx_valid <= 1'b0;
      uart_vif.rxd      <= 1'b1; // idle
    end
    `uvm_info("UART_DRIVER", "Waiting for reset deassertion", UVM_NONE)
    wait (!uart_vif.rst);
    `uvm_info("UART_DRIVER", "Reset deasserted", UVM_NONE)
  endtask
endclass
*/
class uart_driver extends uvm_driver#(uart_seq_item);
  `uvm_component_utils(uart_driver)

  virtual uart_interface uart_vif;
  uart_seq_item req; // Active transaction

  function new(string name = "uart_driver",uvm_component parent = null);
    super.new(name,parent);
    `uvm_info("UART_DRIVER","Inside constructor of driver",UVM_NONE);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!(uvm_config_db#(virtual uart_interface)::get(this,"","vif",uart_vif))) begin
      `uvm_fatal("GET_FAILED","uart_interface was not set properly");
    end
    else begin
      `uvm_info("UART_DRIVER","uart_interface GET SUCCESSFUL",UVM_NONE);
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info("UART_DRIVER","item received in the driver",UVM_NONE);
      req.print();

      check_reset();

      if (req.tx_valid) begin
        perform_tx(req.tx_data);
        // loopback: feed TX data back into RX
        perform_rx(req.tx_data);
      end

      seq_item_port.item_done(req);
    end
  endtask

  // -------------------------------
  // Task: Transmit
  // -------------------------------
  task perform_tx(bit [7:0] data);
    @(posedge uart_vif.clk);
    uart_vif.tx_data  <= data;
    uart_vif.tx_valid <= 1'b1;

    // Wait until DUT is ready
    @(posedge uart_vif.clk);
    wait (uart_vif.tx_ready);

    uart_vif.tx_valid <= 1'b0;
    `uvm_info("UART_DRIVER", $sformatf("Transmitted data: %0h", data), UVM_LOW)
  endtask

  // -------------------------------
// Task: Receive (simple loopback)
// -------------------------------
task perform_rx(bit [7:0] data);
  // Wait 1 clock, then directly drive the DUT RX signals
  @(posedge uart_vif.clk);
  uart_vif.rx_data  <= data;
  uart_vif.rx_valid <= 1'b1;

  // Hold it for 1 cycle
  @(posedge uart_vif.clk);
  uart_vif.rx_valid <= 1'b0;

  `uvm_info("UART_DRIVER", $sformatf("Loopback RX injected: %0h", data), UVM_LOW)
endtask

  // -------------------------------
  // Task: Reset check
  // -------------------------------
  task check_reset();
    if (uart_vif.rst) begin
      @(posedge uart_vif.clk);
      uart_vif.tx_data  <= 8'b0;
      uart_vif.tx_valid <= 1'b0;
      uart_vif.rxd      <= 1'b1; // idle
    end
    wait (!uart_vif.rst);
  endtask
endclass