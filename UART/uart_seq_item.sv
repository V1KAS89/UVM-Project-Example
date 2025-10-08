/*
class uart_seq_item extends uvm_sequence_item;

  rand bit [7:0] tx_data;
  rand bit       tx_valid;
       bit [7:0] rx_stim;   // not randomized, will be derived

  // Constraint: If TX is active, RX must follow the same data
  constraint rx_follows_tx {
    if (tx_valid) rx_stim == tx_data;
    else          rx_stim == 8'h00; // idle (no stimulus) when not transmitting
  }
  constraint c_valid { tx_valid == 1; }  // Always drive
  `uvm_object_utils_begin(uart_seq_item)
    `uvm_field_int(tx_data, UVM_ALL_ON)
    `uvm_field_int(tx_valid, UVM_ALL_ON)
    `uvm_field_int(rx_stim, UVM_ALL_ON) // still register for printing
  `uvm_object_utils_end

  function new(string name = "uart_seq_item");
    super.new(name);
  endfunction

endclass
*/
/*
// uart_seq_item.sv
class uart_seq_item extends uvm_sequence_item;

  // -------------------------------------------------------------------
  // Fields
  // -------------------------------------------------------------------
  rand bit [7:0] tx_data;   // randomized TX data
  rand bit       tx_valid;  // whether TX is driving
       bit [7:0] rx_stim;   // derived RX stimulus (not randomized)

  // -------------------------------------------------------------------
  // Constraints
  // -------------------------------------------------------------------
  // Always drive something (you can relax this later if needed)
  constraint c_valid { tx_valid == 1; }

  // -------------------------------------------------------------------
  // UVM Macros
  // -------------------------------------------------------------------
  `uvm_object_utils_begin(uart_seq_item)
    `uvm_field_int(tx_data,  UVM_ALL_ON)
    `uvm_field_int(tx_valid, UVM_ALL_ON)
    `uvm_field_int(rx_stim,  UVM_ALL_ON) // included for printing
  `uvm_object_utils_end

  // -------------------------------------------------------------------
  // Constructor
  // -------------------------------------------------------------------
  function new(string name = "uart_seq_item");
    super.new(name);
  endfunction

  // -------------------------------------------------------------------
  // Post Randomize Hook
  // -------------------------------------------------------------------
  function void post_randomize();
    if (tx_valid)
      rx_stim = tx_data;   // mirror TX data to RX
    else
      rx_stim = 8'h00;     // idle condition
  endfunction

endclass
*/
//=====================================================
// UART Sequence Item
//=====================================================
class uart_seq_item extends uvm_sequence_item;

  // Transaction fields
  rand bit [7:0] tx_data;   // byte to transmit
  rand bit       tx_valid;  // request to send

  // Constraints
  constraint c_tx_valid { tx_valid == 1; }  // always drive valid
  // if you want both valid/idle traffic, comment out above

  // UVM macros for automation
  `uvm_object_utils_begin(uart_seq_item)
    `uvm_field_int(tx_data, UVM_ALL_ON)
    `uvm_field_int(tx_valid, UVM_ALL_ON)
  `uvm_object_utils_end

  // Constructor
  function new(string name = "uart_seq_item");
    super.new(name);
  endfunction

endclass
