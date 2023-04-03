module accumulator_to_7segment;
    timeunit 1ns/1ps;
    localparam  N = 10, W = 3,
                CLK_PERIOD = 10;


    logic clk = 0, rstn = 0;
  	logic [W-1:0] s_data = 0;
    logic [1:0][6:0] m_data;
  
    logic [$clog2(N)-1: 0] tb_c_data = 0;
  	logic [$clog2(99)-1: 0] tb_sum_data = 0;
  	logic [1:0][6:0] tb_m_data;
  	logic [9:0][6:0] lut_decimal_to_7segment = 
    	{7'h7B, 7'h7F, 7'h70, 7'h5F, 7'h5B, 7'h33, 7'h79, 7'h6D, 7'h30, 7'h7E};

    initial forever #(CLK_PERIOD/2) clk <= !clk;

    accumulate_to_7segment #(.N(N), .W(W)) dut(.*);

    //Driver
    initial begin
      	$dumpfile("dump.vcd"); $dumpvars(0, dut);
        @(posedge clk) #1 rstn = 1;
      repeat (100) @(posedge clk) begin 
        #1 s_data <= $urandom();
        if (!rstn) begin
          tb_c_data <= '0;
          tb_sum_data <= '0;
        end   
      	else begin 
          tb_c_data <= (tb_c_data == N-1) ? '0 : tb_c_data + 1'b1;
          tb_sum_data <= (tb_c_data == N-1) || (tb_sum_data + s_data > 'd99) ? '0 : (tb_sum_data + s_data);
        end
      end       	
      $finish();
    end

    //Monitor
    initial forever begin
      @(posedge clk)
      tb_m_data = decimal_to_7segment(tb_sum_data);
      assert ({tb_m_data[1], tb_m_data[0]} == {m_data[1], m_data[0]}) $display("Ok, %b", {m_data[1], m_data[0]});
      else $error("TB_Sum %b, Design_sum %b", {tb_m_data[1], tb_m_data[0]}, {m_data[1], m_data[0]});
    end


endmodule