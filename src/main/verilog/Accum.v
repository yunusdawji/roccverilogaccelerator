module Accel0(input clk, input reset,
    output io_cmd_ready,
    input  io_cmd_valid,
    input [6:0] io_cmd_bits_inst_funct,
    input [4:0] io_cmd_bits_inst_rs2,
    input [4:0] io_cmd_bits_inst_rs1,
    input  io_cmd_bits_inst_xd,
    input  io_cmd_bits_inst_xs1,
    input  io_cmd_bits_inst_xs2,
    input [4:0] io_cmd_bits_inst_rd,
    input [6:0] io_cmd_bits_inst_opcode,
    input [63:0] io_cmd_bits_rs1,
    input [63:0] io_cmd_bits_rs2,
    input  io_resp_ready,
    output io_resp_valid,
    output[4:0] io_resp_bits_rd,
    output[63:0] io_resp_bits_data,
    input  io_mem_req_ready,
    output io_mem_req_valid,
    output[39:0] io_mem_req_bits_addr,
    output[9:0] io_mem_req_bits_tag,
    output[4:0] io_mem_req_bits_cmd,
    output[2:0] io_mem_req_bits_typ,
    //output io_mem_req_bits_kill
    output io_mem_req_bits_phys,
    output[63:0] io_mem_req_bits_data,
    input  io_mem_resp_valid,
    input [39:0] io_mem_resp_bits_addr,
    input [9:0] io_mem_resp_bits_tag,
    input [4:0] io_mem_resp_bits_cmd,
    input [2:0] io_mem_resp_bits_typ,
    input [63:0] io_mem_resp_bits_data,
    input  io_mem_resp_bits_nack,
    input  io_mem_resp_bits_replay,
    input  io_mem_resp_bits_has_data,
    input [63:0] io_mem_resp_bits_data_word_bypass,
    input [63:0] io_mem_resp_bits_store_data,
    //input  io_mem_replay_next_valid
    //input [9:0] io_mem_replay_next_bits
    //input  io_mem_xcpt_ma_ld
    //input  io_mem_xcpt_ma_st
    //input  io_mem_xcpt_pf_ld
    //input  io_mem_xcpt_pf_st
    output io_mem_invalidate_lr,
    //input  io_mem_ordered
    output io_busy,
    input  io_s,
    output io_interrupt,
    input  io_autl_acquire_ready,
    output io_autl_acquire_valid,
    //output[25:0] io_autl_acquire_bits_addr_block
    //output[2:0] io_autl_acquire_bits_client_xact_id
    //output[1:0] io_autl_acquire_bits_addr_beat
    //output io_autl_acquire_bits_is_builtin_type
    //output[2:0] io_autl_acquire_bits_a_type
    //output[16:0] io_autl_acquire_bits_union
    //output[127:0] io_autl_acquire_bits_data
    output io_autl_grant_ready,
    input  io_autl_grant_valid,
    input [1:0] io_autl_grant_bits_addr_beat,
    input [2:0] io_autl_grant_bits_client_xact_id,
    input [3:0] io_autl_grant_bits_manager_xact_id,
    input  io_autl_grant_bits_is_builtin_type,
    input [3:0] io_autl_grant_bits_g_type,
    input [127:0] io_autl_grant_bits_data,
    //input  io_fpu_req_ready
    //output io_fpu_req_valid
    //output[4:0] io_fpu_req_bits_cmd
    //output io_fpu_req_bits_ldst
    //output io_fpu_req_bits_wen
    //output io_fpu_req_bits_ren1
    //output io_fpu_req_bits_ren2
    //output io_fpu_req_bits_ren3
    //output io_fpu_req_bits_swap12
    //output io_fpu_req_bits_swap23
    //output io_fpu_req_bits_single
    //output io_fpu_req_bits_fromint
    //output io_fpu_req_bits_toint
    //output io_fpu_req_bits_fastpipe
    //output io_fpu_req_bits_fma
    //output io_fpu_req_bits_div
    //output io_fpu_req_bits_sqrt
    //output io_fpu_req_bits_round
    //output io_fpu_req_bits_wflags
    //output[2:0] io_fpu_req_bits_rm
    //output[1:0] io_fpu_req_bits_typ
    //output[64:0] io_fpu_req_bits_in1
    //output[64:0] io_fpu_req_bits_in2
    //output[64:0] io_fpu_req_bits_in3
    //output io_fpu_resp_ready
    //input  io_fpu_resp_valid
    //input [64:0] io_fpu_resp_bits_data
    //input [4:0] io_fpu_resp_bits_exc
    input  io_exception,
    //input [11:0] io_csr_waddr
    //input [63:0] io_csr_wdata
    //input  io_csr_wen
    input  io_host_id
);

reg [1:0] state_next, state_curr;
reg [6:0] io_cmd_bits_inst_funct_next,io_cmd_bits_inst_funct_curr;
reg [4:0] io_cmd_bits_inst_rs2_next,io_cmd_bits_inst_rs2_curr;
reg [4:0] io_cmd_bits_inst_rs1_next,io_cmd_bits_inst_rs1_curr;
reg  io_cmd_bits_inst_xd_next,io_cmd_bits_inst_xd_curr;
reg  io_cmd_bits_inst_xs1_next,io_cmd_bits_inst_xs1_curr;
reg  io_cmd_bits_inst_xs2_next,io_cmd_bits_inst_xs2_curr;
reg [4:0] io_cmd_bits_inst_rd_curr,io_cmd_bits_inst_rd_next;
reg [63:0] io_cmd_bits_rs1_next,io_cmd_bits_rs1_curr;
reg [63:0] io_cmd_bits_rs2_next,io_cmd_bits_rs2_curr;
reg [63:0] result_next, result_curr;
reg busy_next, busy_curr;
reg resp_valid_next, resp_valid_curr;
reg [63:0] io_resp_bits_data_next, io_resp_bits_data_curr;
reg [4:0] io_resp_bits_rd_next, io_resp_bits_rd_curr;
reg io_cmd_ready_curr, io_cmd_ready_next;

assign io_cmd_ready = io_cmd_ready_curr;
assign io_busy = busy_curr;
assign io_resp_valid = resp_valid_curr;
assign io_resp_bits_data = io_resp_bits_data_curr;
assign io_resp_bits_rd = io_resp_bits_rd_curr;
assign io_interrupt = 0;

//default values
assign io_mem_req_valid = 0;
assign io_mem_req_bits_addr = 0;
assign io_mem_req_bits_tag = 0;
assign io_mem_req_bits_cmd = 0;
assign io_mem_req_bits_typ = 0;
//output io_mem_req_bits_kill
assign io_mem_req_bits_phys = 1;
assign io_mem_req_bits_data = 0;
assign io_mem_invalidate_lr = 0;
assign io_autl_acquire_valid = 0;
assign io_autl_grant_ready = 0;

always @(posedge clk) begin
	if(reset) begin
		state_curr<=0;
		io_cmd_ready_curr <= 1;
		io_cmd_bits_inst_funct_curr <= 0;
		io_cmd_bits_inst_rs2_curr <= 0;
		io_cmd_bits_inst_rs1_curr <= 0;
		io_cmd_bits_inst_xd_curr <= 0;
		io_cmd_bits_inst_xs1_curr <= 0;
		io_cmd_bits_inst_xs2_curr <= 0;
		io_cmd_bits_inst_rd_curr <= 0;
		io_cmd_bits_rs2_curr <= 0;
		io_cmd_bits_rs1_curr <= 0;
		result_curr <= 0;
		busy_curr <= 0;
		io_resp_bits_data_curr <= 0;
		io_resp_bits_rd_curr <= 0;
	end else begin
		state_curr<=state_next;
		io_cmd_ready_curr<=io_cmd_ready_next;
		io_cmd_bits_inst_funct_curr <= io_cmd_bits_inst_funct_next;
		io_cmd_bits_inst_rs2_curr <= io_cmd_bits_inst_rs2_next;
		io_cmd_bits_inst_rs1_curr <= io_cmd_bits_inst_rs1_next;
		io_cmd_bits_inst_xd_curr <= io_cmd_bits_inst_xd_next;
		io_cmd_bits_inst_xs1_curr <= io_cmd_bits_inst_xs1_next;
		io_cmd_bits_inst_xs2_curr <= io_cmd_bits_inst_xs2_next;
		io_cmd_bits_inst_rd_curr <= io_cmd_bits_inst_rd_next;
		io_cmd_bits_rs2_curr <= io_cmd_bits_rs2_next;
		io_cmd_bits_rs1_curr <= io_cmd_bits_rs1_next;
		result_curr <= result_next;
		busy_curr <= busy_next;
		io_resp_bits_data_curr <= io_resp_bits_data_next;
		io_resp_bits_rd_curr <= io_resp_bits_rd_next;
		resp_valid_curr <= resp_valid_next;
	end
end 

always @(*) begin
	io_cmd_ready_next <= io_cmd_ready_curr;
	io_cmd_bits_inst_rs1_next <= io_cmd_bits_inst_rs1_curr;
	io_cmd_bits_inst_rs2_next <= io_cmd_bits_inst_rs2_curr;
	io_cmd_bits_inst_xd_next <= io_cmd_bits_inst_xd_curr;
	io_cmd_bits_inst_xs1_next <= io_cmd_bits_inst_xs1_curr;
	io_cmd_bits_inst_xs2_next <= io_cmd_bits_inst_xs2_curr;
	io_cmd_bits_inst_rd_next <= io_cmd_bits_inst_rd_curr;
	state_next <= state_curr;	
	io_cmd_bits_rs2_next <= io_cmd_bits_rs2_curr;
	io_cmd_bits_rs1_next <= io_cmd_bits_rs1_curr;
	result_next <= result_curr;
	busy_next <= busy_curr;
	resp_valid_next <= resp_valid_curr;
	io_resp_bits_rd_next <= io_resp_bits_rd_curr;
	io_resp_bits_data_next <= io_resp_bits_data_curr;
	case (state_curr) 
		//idle state
		2'b00 : 
		begin 
			if(io_cmd_valid) begin
				//if(io_cmd_bits_inst_funct==0)begin
					state_next <= 1;
					io_cmd_ready_next <= 0;
					io_cmd_bits_inst_rs1_next <= io_cmd_bits_inst_rs1;
					io_cmd_bits_inst_rs2_next <= io_cmd_bits_inst_rs2;
					io_cmd_bits_inst_xd_next <= io_cmd_bits_inst_xd;
					io_cmd_bits_inst_xs1_next <= io_cmd_bits_inst_xs1;
					io_cmd_bits_inst_xs2_next <= io_cmd_bits_inst_xs2;
					io_cmd_bits_inst_rd_next <= io_cmd_bits_inst_rd;
					io_cmd_bits_rs2_next <= io_cmd_bits_rs2;
					io_cmd_bits_rs1_next <= io_cmd_bits_rs1;
					busy_next <= 1;					
				//end else begin
				//	state_next <= 2;
				//	io_cmd_ready_next <= 0;
				//end
			end
			resp_valid_next <= 0;
			busy_next <= 0;
			
		end
		//processing state	 	
	    	2'b01 :  
		begin
			result_next <= io_cmd_bits_rs1_curr + io_cmd_bits_rs2_curr;
			state_next <= 2;
		end
		//response state
		2'b10 :  
		begin
			if(io_resp_ready) begin
				state_next <= 0;
				io_cmd_ready_next <= 1;
				resp_valid_next <= 1;
				//set the data for rd reg
				io_resp_bits_rd_next <= io_cmd_bits_inst_rd_curr;
				io_resp_bits_data_next <= result_curr;
			end
		end
	    	default : state_next <= 0;//$display("Error in SEL");
	endcase

end

endmodule
/*
module Queue_Accum(input clk, input reset,
    output io_enq_ready,
    input  io_enq_valid,
    input [6:0] io_enq_bits_inst_funct,
    input [4:0] io_enq_bits_inst_rs2,
    input [4:0] io_enq_bits_inst_rs1,
    input  io_enq_bits_inst_xd,
    input  io_enq_bits_inst_xs1,
    input  io_enq_bits_inst_xs2,
    input [4:0] io_enq_bits_inst_rd,
    input [6:0] io_enq_bits_inst_opcode,
    input [63:0] io_enq_bits_rs1,
    input [63:0] io_enq_bits_rs2,
    input  io_deq_ready,
    output io_deq_valid,
    output[6:0] io_deq_bits_inst_funct,
    output[4:0] io_deq_bits_inst_rs2,
    output[4:0] io_deq_bits_inst_rs1,
    output io_deq_bits_inst_xd,
    output io_deq_bits_inst_xs1,
    output io_deq_bits_inst_xs2,
    output[4:0] io_deq_bits_inst_rd,
    output[6:0] io_deq_bits_inst_opcode,
    output[63:0] io_deq_bits_rs1,
    output[63:0] io_deq_bits_rs2,
    output[1:0] io_count
);

  wire[1:0] T0;
  wire ptr_diff;
  reg  R1;
  wire T35;
  wire T2;
  wire T3;
  wire do_deq;
  reg  R4;
  wire T36;
  wire T5;
  wire T6;
  wire do_enq;
  wire T7;
  wire ptr_match;
  reg  maybe_full;
  wire T37;
  wire T8;
  wire T9;
  wire[63:0] T10;
  wire[159:0] T11;
  reg [159:0] ram [1:0];
  wire[159:0] T12;
  wire[159:0] T13;
  wire[159:0] T14;
  wire[140:0] T15;
  wire[134:0] T16;
  wire[127:0] T17;
  wire[5:0] T18;
  wire[18:0] T19;
  wire[6:0] T20;
  wire[1:0] T21;
  wire[11:0] T22;
  wire[63:0] T23;
  wire[6:0] T24;
  wire[4:0] T25;
  wire T26;
  wire T27;
  wire T28;
  wire[4:0] T29;
  wire[4:0] T30;
  wire[6:0] T31;
  wire T32;
  wire empty;
  wire T33;
  wire T34;
  wire full;

`ifndef SYNTHESIS
// synthesis translate_off
  integer initvar;
  initial begin
    #0.002;
    R1 = {1{$random}};
    R4 = {1{$random}};
    maybe_full = {1{$random}};
    for (initvar = 0; initvar < 2; initvar = initvar+1)
      ram[initvar] = {5{$random}};
  end
// synthesis translate_on
`endif

  assign io_count = T0;
  assign T0 = {T7, ptr_diff};
  assign ptr_diff = R4 - R1;
  assign T35 = reset ? 1'h0 : T2;
  assign T2 = do_deq ? T3 : R1;
  assign T3 = R1 + 1'h1;
  assign do_deq = io_deq_ready & io_deq_valid;
  assign T36 = reset ? 1'h0 : T5;
  assign T5 = do_enq ? T6 : R4;
  assign T6 = R4 + 1'h1;
  assign do_enq = io_enq_ready & io_enq_valid;
  assign T7 = maybe_full & ptr_match;
  assign ptr_match = R4 == R1;
  assign T37 = reset ? 1'h0 : T8;
  assign T8 = T9 ? do_enq : maybe_full;
  assign T9 = do_enq != do_deq;
  assign io_deq_bits_rs2 = T10;
  assign T10 = T11[6'h3f:1'h0];
  assign T11 = ram[R1];
  assign T13 = T14;
  assign T14 = {T19, T15};
  assign T15 = {T18, T16};
  assign T16 = {io_enq_bits_inst_opcode, T17};
  assign T17 = {io_enq_bits_rs1, io_enq_bits_rs2};
  assign T18 = {io_enq_bits_inst_xs2, io_enq_bits_inst_rd};
  assign T19 = {T22, T20};
  assign T20 = {io_enq_bits_inst_rs1, T21};
  assign T21 = {io_enq_bits_inst_xd, io_enq_bits_inst_xs1};
  assign T22 = {io_enq_bits_inst_funct, io_enq_bits_inst_rs2};
  assign io_deq_bits_rs1 = T23;
  assign T23 = T11[7'h7f:7'h40];
  assign io_deq_bits_inst_opcode = T24;
  assign T24 = T11[8'h86:8'h80];
  assign io_deq_bits_inst_rd = T25;
  assign T25 = T11[8'h8b:8'h87];
  assign io_deq_bits_inst_xs2 = T26;
  assign T26 = T11[8'h8c:8'h8c];
  assign io_deq_bits_inst_xs1 = T27;
  assign T27 = T11[8'h8d:8'h8d];
  assign io_deq_bits_inst_xd = T28;
  assign T28 = T11[8'h8e:8'h8e];
  assign io_deq_bits_inst_rs1 = T29;
  assign T29 = T11[8'h93:8'h8f];
  assign io_deq_bits_inst_rs2 = T30;
  assign T30 = T11[8'h98:8'h94];
  assign io_deq_bits_inst_funct = T31;
  assign T31 = T11[8'h9f:8'h99];
  assign io_deq_valid = T32;
  assign T32 = empty ^ 1'h1;
  assign empty = ptr_match & T33;
  assign T33 = maybe_full ^ 1'h1;
  assign io_enq_ready = T34;
  assign T34 = full ^ 1'h1;
  assign full = ptr_match & maybe_full;

  always @(posedge clk) begin
    if(reset) begin
      R1 <= 1'h0;
    end else if(do_deq) begin
      R1 <= T3;
    end
    if(reset) begin
      R4 <= 1'h0;
    end else if(do_enq) begin
      R4 <= T6;
    end
    if(reset) begin
      maybe_full <= 1'h0;
    end else if(T9) begin
      maybe_full <= do_enq;
    end
    if (do_enq)
      ram[R4] <= T13;
  end
endmodule
*/
