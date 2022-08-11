module fcsr 
  import fpnew_pkg::*;
  #(
    parameter fp_pkg::rvfloat_e RVF   = fp_pkg::RV32FNone)
  (
    output fpnew_pkg::roundmode_e frm,
    output logic frm_en,
    input  logic [31:0] instr_i,
    output logic [31:0] csr_rdata_int,
    input  logic [31:0] gpr_i0_rs1_d,
    output logic fpucsr,
    output logic [4:0] fflags
  );
  logic [11:0] csr_addr_i ;
  logic illegal_csr,fflags_en;
  logic [2:0] csr_we_int;
  logic [31:0] csr_wdata_int;
  logic [6:0] opcode;

  assign csr_addr_i = instr_i[31:20];
  assign csr_wdata_int = gpr_i0_rs1_d;
  assign csr_we_int = instr_i[14:!2];
  assign opcode = instr_i[6:0];
//000000000010 00000 000 00000 1110011 
//addr rs1 w/r_en rd opcode
  localparam CSR_FCSR = 12'h003;
  localparam CSR_FFLAG = 12'h001;
  localparam CSR_FRM = 12'h002;

  always_comb begin
    csr_rdata_int = '0;
    illegal_csr   = 1'b0;
    fpucsr = 1'b0;
    if (opcode == 7'h73)begin
    if (csr_we_int == 3'b000) begin
      fpucsr= 1;
    unique case (csr_addr_i)
      CSR_FCSR: csr_rdata_int = {24'b0 , frm, fflags};
      
      CSR_FFLAG: csr_rdata_int = {27'b0 , fflags};
      
      CSR_FRM: begin
        csr_rdata_int = {29'b0 , frm};
      end
      default: begin
        illegal_csr = 1'b1;
      end
    endcase
    end
    end
  end
  always_comb begin
    fflags_en    = 1'b0;
    frm_en       = 1'b0;
    fpucsr = 0;
    if (opcode == 7'h73) begin 
    if (csr_we_int) begin
      fpucsr = 1;
      unique case (csr_addr_i)
        CSR_FCSR: begin 
          fflags_en = 1'b1;
          frm_en    = 1'b1;
          fflags  = csr_wdata_int[4:0];
          frm    = csr_wdata_int[7:5];
        end

        CSR_FFLAG : begin
          fflags_en = 1'b1;
          fflags  = fpnew_pkg::status_t'(csr_wdata_int[4:0]);
        end

        CSR_FRM: begin
          frm_en  = 1'b1;
          frm  = roundmode_e'(csr_wdata_int[2:0]); 
        end
        default:;
      endcase
    end
    end
  end


endmodule