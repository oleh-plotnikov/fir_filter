`timescale 1ns / 1ps

module filter (i_clk, i_rst_n, i_data, o_data);

	parameter INPUT_WIDTH = 18;

	input i_clk, i_rst_n;
	input  	   signed [INPUT_WIDTH - 1 : 0] i_data;
	
	output reg signed [INPUT_WIDTH - 1 : 0] o_data;

	reg [3 : 0] counter_r;
	reg 		ctrl_comp;

	reg signed [INPUT_WIDTH - 1 : 0] pipeline_r [0 : 10];
	
	reg signed [INPUT_WIDTH + 4 - 1 : 0] mux_out, term;
	reg signed [INPUT_WIDTH + 7 - 1 : 0] acc_r;

	wire sync_reset;

	integer i;

	
assign  sync_reset = (counter_r == 4'b1111) ? 1'b0 : 1'b1;
	
	
always @(posedge i_clk, negedge i_rst_n)
	if(!i_rst_n)
		counter_r <= 4'b0;
	else
		counter_r <= counter_r + 1'b1;


always @(posedge i_clk, negedge i_rst_n)
    if(!i_rst_n)
		for(i = 0 ; i < 11; i = i + 1)
			pipeline_r[i] <= {INPUT_WIDTH{1'b0}};
    else if (!sync_reset) 
		begin
			pipeline_r[0] <= i_data;
			for(i = 0 ; i < 10; i = i + 1)
				pipeline_r [i + 1] <= pipeline_r[i];
	        end


always @(*) begin
    case (counter_r)
    
        4'd0  : 
                begin
                    mux_out = pipeline_r[0];
                    ctrl_comp = 1'b1;
                end
        4'd1  : 
                begin
                    mux_out = pipeline_r[0] << 1;
                    ctrl_comp = 1'b1;
                end
        4'd2  : 
                begin
                    mux_out = pipeline_r[1] << 3;
                    ctrl_comp = 1'b1;
                end
        4'd3  : 
                begin
                    mux_out = pipeline_r[2] << 3;
                    ctrl_comp = 1'b1;
                end
        4'd4  : 
                begin
                    mux_out = pipeline_r[4] << 3;
                    ctrl_comp = 1'b0;
                end
        4'd5  : 
                begin
                    mux_out = pipeline_r[4] << 1;
                    ctrl_comp = 1'b0;
                end
        4'd6  : 
                begin 
                    mux_out = pipeline_r[4];
                    ctrl_comp = 1'b0;
                end
        4'd7  : 
                begin
                    mux_out = pipeline_r[5] << 4;
                    ctrl_comp = 1'b0;
                end
        4'd8  :
                begin 
                    mux_out = pipeline_r[6] << 3;
                    ctrl_comp = 1'b0;
                end
        4'd9  : 
                begin
                    mux_out = pipeline_r[6] << 1;
                    ctrl_comp = 1'b0;
                end
        4'd10 : 
                begin
                    mux_out = pipeline_r[6];
                    ctrl_comp = 1'b0;
                end
        4'd11 :
                begin 
                    mux_out = pipeline_r[8] << 3;
                    ctrl_comp = 1'b1;
                end
        4'd12 : 
                begin
                mux_out = pipeline_r[9] << 3;
                ctrl_comp = 1'b1;
                end
        4'd13 : 
                begin
                    mux_out = pipeline_r[10];
                    ctrl_comp = 1'b1;
                end                                      
        4'd14 : 
                begin
                    mux_out = pipeline_r[10] << 1;
                    ctrl_comp = 1'b1;
                end
	default:
		begin
		    mux_out = {INPUT_WIDTH + 4 {1'b0}};
		    ctrl_comp = 1'b0;
		end
	    
    endcase
end

	
always @(*)
	if (ctrl_comp)
		term = ~ mux_out + 1'b1; 
	else
		term = mux_out;

	
always @(posedge i_clk, negedge i_rst_n)
	if (!i_rst_n)
		acc_r <= {(INPUT_WIDTH + 7){1'b0}};
	else if (!sync_reset)
		acc_r <= {(INPUT_WIDTH + 7){1'b0}};
	else
		acc_r <= term + acc_r;


always @(posedge i_clk, negedge i_rst_n)
	if(!i_rst_n)
		o_data <= {(INPUT_WIDTH){1'b0}};
	else if(sync_reset == 1'b0)
		if((~(|acc_r[24:22])) || (&acc_r[24:22]))
			o_data <= acc_r[22:5] + {acc_r[4]&&(|acc_r[3:0]||acc_r[5])};
		else if(acc_r[24]) 
			o_data <= 18'h20000;
		else 
			o_data <= 18'h1FFFF;


endmodule