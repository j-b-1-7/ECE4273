`define reg_ADD 1
`define reg_SUB 2
`define reg_AND 3
`define reg_OR 4
`define reg_XOR 5

`define addr_ADD 6
`define addr_SUB 7
`define addr_AND 8
`define addr_OR 9
`define addr_XOR 10

`define JZ 11
`define LOAD 12
`define STORE 13

module ALU (
    input [3:0] opcode,
    input [15:0] regAr, regBr,
    output reg [15:0] regAw,
    output reg CF, ZF
);
    always @(opcode, regAr, regBr) 
    begin
        case (opcode)
            `reg_ADD, `addr_ADD: {CF, regAw} = regAr + regBr;
            `reg_SUB, `addr_SUB: {CF, regAw} = regAr - regBr;
            `reg_AND, `addr_AND: 
            begin
                CF <= 0;
                regAw <= regAr & regBr;
            end
            `reg_OR, `addr_OR: 
            begin
                CF <= 0;
                regAw <= regAr | regBr;
            end
            `reg_XOR, `addr_XOR:
            begin
                CF <= 0;
                regAw <= regAr ^ regBr;
            end
        endcase

        ZF <= (regAw == 16'b0) ? 1 : 0;
    end

endmodule

module REGS (
    input clk, rwR, rwRM,
    input [3:0] addrA, addrB, addrC,
    input [15:0] regAw, DtoR,
    output [15:0] regAr, regBr, DfromR
);

    reg [15:0] RegFile [7:0]; //8 16 bit registers
    
    assign regAr = RegFile[addrA];
    assign regBr = RegFile[addrB];
    assign DfromR = RegFile[addrC];
    
    always @(posedge clk) 
    begin 
        if (rwR) begin 
            RegFile[addrA]=regAw;  
        end
        if(rwRM) begin
            RegFile[addrC]=DtoR;  
        end
    end
endmodule

module EXEC (
    input clk, R, CF,
    input [15:0] DfromM, DfromR,
    output reg [15:0] addrD, DtoM, DtoR, 
    output reg [3:0] addrA, addrB, addrC, opcode,
    output reg rwR, rwRM, wM
);

    parameter prog_start = 0;

    localparam fetch = 0;
    localparam decode = 1;
    localparam execute = 2;
    localparam increment_PC = 3;
    localparam next = 4;

    reg [15:0] IR, PC;
    reg [2:0] S;

    always @(posedge clk)
    begin
        if(R) begin
            S = fetch;
            rwR = 0;
            rwRM = 0;
            wM = 0;
            opcode = 4'b0;

            addrD = 16'b0;
            PC = prog_start;
        end else begin
            case (S)
                fetch: 
                begin
                    IR = DfromM;
                    rwR = 0;
                    rwRM = 0;
                    wM = 0;
                    S = decode;
                    opcode = 4'b0;
                end
                decode:
                begin
                    S = execute;
                    opcode = IR[15:12];
                    case (opcode)
                        `reg_ADD, //fallthrough
                        `reg_SUB, //fallthrough
                        `reg_AND, //fallthrough
                        `reg_OR, //fallthrough
                        `reg_XOR: 
                        begin
                            addrA = IR[11:8];
                            addrB = IR[7:4];                            
                            rwR = 0;
                            wM = 0;
                        end
                        `addr_ADD, //fallthrough
                        `addr_SUB, //fallthrough
                        `addr_AND, //fallthrough
                        `addr_OR, //fallthrough
                        `addr_XOR:
                        begin
                            addrA = IR[11:8];
                            addrC = 4'b0111;
                            addrB = addrC;
                            if(IR[7:0] == 8'b0) begin
                                //immediate value will follow
                                addrD = PC+1; //get the next line for the immediate
                            end else begin
                                addrD = {8'b0, IR[7:0]};
                            end
                            rwRM = 0;
                            wM = 0;
                        end
                        `JZ:
                        begin
                            addrC = IR[11:8];
                            rwRM = 0;
                            wM = 0;
                        end
                        `LOAD, //fallthrough
                        `STORE: 
                        begin
                            addrC = IR[11:8];
                            addrD = {8'b0, IR[7:0]};
                            rwRM = 0;
                            wM = 0;
                        end
                    endcase        
                end
                execute:
                begin
                    S = increment_PC;
                    case(opcode)
                        `reg_ADD, //fallthrough
                        `reg_SUB, //fallthrough
                        `reg_AND, //fallthrough
                        `reg_OR, //fallthrough
                        `reg_XOR:
                        begin
                            rwR = 0;
                            wM = 0;
                        end 
                        `addr_ADD, //fallthrough
                        `addr_SUB, //fallthrough
                        `addr_AND, //fallthrough
                        `addr_OR, //fallthrough
                        `addr_XOR:
                        begin
                            DtoR = DfromM;
                            rwRM = 0;
                            wM = 0;
                        end
                        `JZ:
                        begin
                            if(DfromR == 16'b0) begin
                                PC = PC + IR[7:0];
                            end
                        end
                        `LOAD:
                        begin
                            DtoR = DfromM;
                            rwRM = 1;
                            wM = 0;
                        end
                        `STORE:
                        begin
                            DtoM = DfromR;
                            rwRM = 0;
                            wM = 1;
                        end
                    endcase
                end
                increment_PC:
                begin
                    S = next;
                    PC = PC + 1;
                    case (opcode)
                        `reg_ADD, //fallthrough
                        `reg_SUB, //fallthrough
                        `reg_AND, //fallthrough
                        `reg_OR, //fallthrough
                        `reg_XOR:
                        begin 
                            rwR=1; 
                            wM=0; 
                        end 
                        `addr_ADD, //fallthrough
                        `addr_SUB, //fallthrough
                        `addr_AND, //fallthrough
                        `addr_OR, //fallthrough
                        `addr_XOR:
                        begin 
                            rwRM=1; 
                            wM=0; 
                        end
                        `LOAD: 
                        begin 
                            rwRM=0; 
                            wM=0; 
                        end
                        `STORE: 
                        begin 
                            rwRM=0; 
                            wM=1; 
                        end
                        `JZ:
                        begin
                            rwRM=0; 
                            wM=0;
                        end
                    endcase
                end
                next:
                begin
                    S = fetch; 
                    addrD = PC; 
                    wM = 0; 
                    rwR = 0;
                    rwRM = 0;
                end
            endcase
        end
    end
endmodule

module CPU (
    input clk, R,
    input [15:0] DfromM,
    output wM,
    output [15:0] DtoM, addrD
);

    parameter prog_start = 0;

    wire [3:0] addrA, addrB, addrC, opcode;
    wire [15:0] regAr, regBr, regAw, DtoR, DfromR;
    wire rwR, rwRM, CF, ZF;
    
    EXEC #(.prog_start(prog_start)) ex (   
                .clk(clk), 
                .R(R), 
                .opcode(opcode), 
                .CF(CF), 
                .addrD(addrD), 
                .DfromM(DfromM), 
                .DtoM(DtoM),
                .addrA(addrA), 
                .addrB(addrB), 
                .addrC(addrC), 
                .DtoR(DtoR), 
                .DfromR(DfromR), 
                .rwR(rwR), 
                .rwRM(rwRM),
                .wM(wM)
            );
    
    ALU alu1 (
                .opcode(opcode), 
                .regAr(regAr), 
                .regBr(regBr),
                .regAw(regAw), 
                .CF(CF),
                .ZF(ZF)
            );
    
    REGS rg (
                .clk(clk), 
                .rwR(rwR), 
                .rwRM(rwRM),
                .addrA(addrA), 
                .regAr(regAr), 
                .regAw(regAw), 
                .addrB(addrB), 
                .regBr(regBr), 
                .addrC(addrC), 
                .DfromR(DfromR), 
                .DtoR(DtoR)
            );
endmodule 

module MEM (
    clk, rwM, addrM, Din, Dout
);
    parameter address_space = 16;
    parameter width = 16;

    input wire clk;
    input wire rwM;
    input wire [address_space-1:0] addrM;
    input wire [width-1:0] Din;
    output wire [width-1:0] Dout;
    
    reg [width-1:0] mem [(2**address_space)-1:0];
    
    assign Dout = mem[addrM];
    
    always @(posedge clk) 
    begin 
        if (rwM) begin 
           mem[addrM]=Din; 
        end
    end
endmodule

module BUS (
    input io, wM, Mw,
    input [15:0] DtoM, addrD, Dout, DI, addr,
    output reg [15:0] DfromM, Din, addrM, DO,
    output reg rwM
);

    always @(io or DtoM or addrD or Dout or DI or addr or wM or Mw) 
    begin
        if (io) begin 
            DO = Dout; 
            Din = DI; 
            addrM = addr; 
            rwM = Mw; 
        end else begin 
            DfromM = Dout; 
            Din = DtoM; 
            addrM = addrD; 
            rwM = wM; 
        end
    end
endmodule

module comp001 (
    input wire clk, R, Mw,
    input io,
    input wire [15:0] addr, DI,
    output wire [15:0] DO
);

    parameter prog_start = 0;
    wire wM, rwM;
    wire [15:0] DfromM, DtoM, addrD, Din, Dout, addrM;
    
    CPU #(.prog_start(prog_start)) cpu001 (
                .clk(clk), 
                .R(R), 
                .DfromM(DfromM), 
                .addrD(addrD), 
                .wM(wM), 
                .DtoM(DtoM)
            );
            
    MEM mem001 (
                .clk(clk), 
                .Din(Din), 
                .Dout(Dout), 
                .addrM(addrM), 
                .rwM(rwM)
            );
            
    BUS bus001 (
                .io(io), 
                .DfromM(DfromM), 
                .DtoM(DtoM), 
                .addrD(addrD), 
                .Din(Din), 
                .Dout(Dout), 
                .addrM(addrM), 
                .DO(DO), 
                .DI(DI), 
                .addr(addr), 
                .wM(wM), 
                .Mw(Mw), 
                .rwM(rwM)
            );
endmodule
