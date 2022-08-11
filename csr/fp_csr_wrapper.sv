module fp_csr_wrapper(
  input logic [31:0] instr_i,
  input logic clk_i,rst_ni,
  input logic [31:0] gpr_i0_rs1_d,
  output logic [2:0] frm_reg,
  output logic frm_en,
  output logic fpucsr
);
logic [31:0] csr_rdata_int;
logic [4:0] fflags_reg;
logic [4:0] fflags;
logic [2:0] frm;

fcsr fp_csr(
  .instr_i(instr_i),
  .gpr_i0_rs1_d(gpr_i0_rs1_d),
  .frm(frm_reg),
  .frm_en(frm_en),
  .csr_rdata_int(csr_rdata_int),
  .fpucsr(fpucsr),
  .fflags(fflags)
);

always @(posedge clk_i or negedge rst_ni) begin
  if(!rst_ni) begin
    frm_reg = 3'b0;
    fflags_reg = 5'b0;
   end
   else begin
    frm_reg = frm;
    fflags_reg = fflags;
   end

end 
endmodule