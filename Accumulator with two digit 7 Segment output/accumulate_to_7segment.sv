module accumulate_to_7segment #(
    parameter N = 10, W = 3
) (
    input logic clk, rstn,
    input logic [W-1:0] s_data,
    output logic [1:0][6:0] m_data
);
    //counters
  	logic [$clog2(N)-1: 0] c_data = 0;
  	logic [$clog2(99)-1: 0] sum_data = 0;

    always_ff @( posedge clk or negedge rstn) begin : add
        if (!rstn) begin
            c_data <= '0;
            sum_data <= '0;
        end   
      	else begin 
          	c_data <= (c_data == N-1) ? '0 : c_data + 1'b1;
          	sum_data <= (c_data == N-1) || (sum_data + s_data > 'd99) ? '0 : (sum_data + s_data);
        end 	
    end

    always_comb begin : display
      	m_data = decimal_to_7segment(sum_data);
    end
endmodule

function automatic [1:0][6:0] decimal_to_7segment(
    input logic [$clog2(99)-1: 0] sum_data 
  );

    logic [1:0][6:0] m_data;
    logic [9:0][6:0] lut_decimal_to_7segment = 
    {7'h7B, 7'h7F, 7'h70, 7'h5F, 7'h5B, 7'h33, 7'h79, 7'h6D, 7'h30, 7'h7E};

    m_data[0] = lut_decimal_to_7segment[(sum_data%10)]; 
    m_data[1] = lut_decimal_to_7segment[(sum_data/10)];
    return m_data;
endfunction

