module control(
    input clk,
    input [31:26]opcode,
    input [5:0]funct,
    input reset,
    input MIO_ready,
    output reg MemRead,
    output reg MemWrite,
    output reg [1:0]RegDst,
    output reg RegWrite,
    output reg IRWrite,
    output reg [1:0]MemtoReg,
    output reg ALUSrcA,
    output reg [1:0]ALUSrcB,
    output reg PCWriteCond,
    output reg Branch,
    output reg PCWrite,
    output reg [1:0]PCSrc,
    output reg IorD,
    output reg[4:0]state,
    output reg [1:0]ALUOp
);

//------------ state --------------
    parameter IF = 5'd0;
    parameter ID = 5'd1;
    parameter Execution = 5'd6;
    parameter ComputeAddr = 5'd2;
    parameter ComputeImm = 5'd10;
    parameter ComputeImmSignal = 5'd11;
    parameter JumpCompletion = 5'd9;
    parameter RTYPECompletion = 5'd7;

//------------ opcode -------------
    parameter RTYPE = 6'h0;
    parameter LW = 6'h23;
    parameter SW = 6'h2b;
    parameter LUI = 6'hf;
    parameter BEQ = 6'h4;
    parameter BNE = 6'h5;
    parameter J = 6'h2;
    parameter JAL = 6'h3;
    parameter ADDI = 6'h8;
    parameter ANDI = 6'hc;
    parameter ORI = 6'hd;
    parameter XORI = 6'he;
    parameter SLTI = 6'ha;

    always @(posedge clk or posedge reset) begin
      if(reset == 1) state = IF;
      else begin
        case (state)
          IF: if(MIO_ready) state = ID;
              else state = IF;
          ID: case (opcode)
                RTYPE: state = Execution;
                
                // LW: state = ComputeAddr;
                // SW: state = ComputeAddr;
                
                // ADDI: state = ComputeImmSignal;
                // ANDI: state = ComputeImm;
                // ORI: state = ComputeImm;
                // XORI: state = ComputeImm;
                // SLTI: state = ComputeImmSignal;
                // LUI: state = ComputeImmSignal;

                // J: state = JumpCompletion;
                // JAL:;

                // BEQ: state = BranchCompletion;
                // BNE:;
          endcase
          Execution: state = RTYPECompletion;

          RTYPECompletion: state = IF;
        //   ComputeAddr: begin
        //     case (opcode)
        //       LW: state = MemReadAccess;
        //       SW: state = MemWriteAccess;
        //     endcase
        //   end
        //   ComputeImm: state = 
        endcase
      end
    end

    always @(state) begin
      case (state)
        IF: begin
          MemRead = 1;
          IRWrite = 1;
          PCWrite = 1;

          ALUSrcA = 0;
          ALUSrcB = 2'b01;
          PCSrc = 2'b00;
          IorD = 0;
          ALUOp = 2'b00; // ADD
        end
        ID: begin
          ALUSrcA = 0;
          ALUSrcB = 2'b11;
          ALUOp = 2'b00; // ADD
        end

        Execution: begin
          ALUSrcA = 1;
          ALUSrcB = 2'b00;
          ALUOp = 2'b10;
        end

        RTYPECompletion:begin
          RegDst = 2'b01;
          RegWrite = 1;
          MemtoReg = 0;
        end
//        default: 
      endcase
    end
endmodule // control