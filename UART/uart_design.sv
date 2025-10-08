//=====================================================
// UART Design (TX + RX) - design.sv
// Format: 8N1 (8 data bits, no parity, 1 stop bit)
//=====================================================
module uart #(
  parameter CLK_FREQ = 50000000,  // System clock frequency (Hz)
  parameter BAUD_RATE = 9600      // UART baud rate
)(
  input  logic       clk,
  input  logic       reset_n,     // <-- kept as in your original design

  // Transmit side
  input  logic [7:0] tx_data,
  input  logic       tx_valid,
  output logic       tx_ready,
  output logic       txd,

  // Receive side
  input  logic       rxd,
  output logic [7:0] rx_data,
  output logic       rx_valid
);

  //=====================================
  // Baud rate generator
  //=====================================
  localparam integer BAUD_DIV = CLK_FREQ / BAUD_RATE;

  logic [$clog2(BAUD_DIV)-1:0] baud_cnt;
  logic baud_tick;

  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      baud_cnt  <= 0;
      baud_tick <= 0;
    end else begin
      if (baud_cnt == BAUD_DIV-1) begin
        baud_cnt  <= 0;
        baud_tick <= 1;
      end else begin
        baud_cnt  <= baud_cnt + 1;
        baud_tick <= 0;
      end
    end
  end

  //=====================================
  // UART Transmitter
  //=====================================
  typedef enum logic [2:0] {
    TX_IDLE,
    TX_START,
    TX_DATA,
    TX_STOP
  } tx_state_t;

  tx_state_t tx_state;
  logic [2:0] tx_bit_cnt;
  logic [7:0] tx_shift;

  assign tx_ready = (tx_state == TX_IDLE);

  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      tx_state   <= TX_IDLE;
      txd        <= 1'b1; // idle line is high
      tx_bit_cnt <= 0;
      tx_shift   <= 0;
    end else if (baud_tick) begin
      case (tx_state)
        TX_IDLE: begin
          if (tx_valid) begin
            tx_shift   <= tx_data;
            tx_state   <= TX_START;
            txd        <= 1'b0; // start bit
          end
        end

        TX_START: begin
          tx_state   <= TX_DATA;
          tx_bit_cnt <= 0;
        end

        TX_DATA: begin
          txd       <= tx_shift[0];
          tx_shift  <= tx_shift >> 1;
          if (tx_bit_cnt == 7)
            tx_state <= TX_STOP;
          else
            tx_bit_cnt <= tx_bit_cnt + 1;
        end

        TX_STOP: begin
          txd      <= 1'b1; // stop bit
          tx_state <= TX_IDLE;
        end
      endcase
    end
  end

  //=====================================
  // UART Receiver
  //=====================================
  typedef enum logic [2:0] {
    RX_IDLE,
    RX_START,
    RX_DATA,
    RX_STOP
  } rx_state_t;

  rx_state_t rx_state;
  logic [2:0] rx_bit_cnt;
  logic [7:0] rx_shift;
  logic [15:0] rx_sample_cnt;
  logic rx_valid_reg;

  assign rx_valid = rx_valid_reg;

  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      rx_state      <= RX_IDLE;
      rx_bit_cnt    <= 0;
      rx_shift      <= 0;
      rx_valid_reg  <= 0;
      rx_sample_cnt <= 0;
      rx_data       <= 0;
    end else begin
      rx_valid_reg <= 0; // default

      case (rx_state)
        RX_IDLE: begin
          if (!rxd) begin // detect start bit
            rx_state      <= RX_START;
            rx_sample_cnt <= BAUD_DIV/2; // sample mid start bit
          end
        end

        RX_START: begin
          if (rx_sample_cnt == 0) begin
            if (!rxd) begin
              rx_state      <= RX_DATA;
              rx_bit_cnt    <= 0;
              rx_sample_cnt <= BAUD_DIV-1;
            end else begin
              rx_state <= RX_IDLE; // false start
            end
          end else
            rx_sample_cnt <= rx_sample_cnt - 1;
        end

        RX_DATA: begin
          if (rx_sample_cnt == 0) begin
            rx_shift <= {rxd, rx_shift[7:1]};
            if (rx_bit_cnt == 7)
              rx_state <= RX_STOP;
            else
              rx_bit_cnt <= rx_bit_cnt + 1;
            rx_sample_cnt <= BAUD_DIV-1;
          end else
            rx_sample_cnt <= rx_sample_cnt - 1;
        end

        RX_STOP: begin
          if (rx_sample_cnt == 0) begin
            if (rxd) begin // valid stop bit
              rx_data      <= rx_shift;
              rx_valid_reg <= 1;
            end
            rx_state <= RX_IDLE;
          end else
            rx_sample_cnt <= rx_sample_cnt - 1;
        end
      endcase
    end
  end

endmodule
