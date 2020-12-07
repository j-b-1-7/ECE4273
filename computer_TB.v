module comp001_comptest_v_tf();    

    integer i;
    
    parameter prog_start = 300;
    
    // Inputs    
    reg clk;    
    reg R;    
    reg io;    
    reg Mw;    
    reg [15:0] addr;    
    reg [15:0] DI;
    
    // Outputs    
    wire [15:0] DO;
    
    // Bidirs
    // Instantiate the UUT    
    
    comp001 #(.prog_start(prog_start)) uut (        
                .clk(clk),         
                .R(R),         
                .io(io),         
                .Mw(Mw),         
                .addr(addr),         
                .DI(DI),         
                .DO(DO)        
    );
    
    initial begin
        $monitor ("time=%t, clk=%b, R=%b, io=%b, Mw=%b, addr=%b, DI=%b, D0=%b", $realtime, clk, R, io, Mw, addr, DI, DO);
    end
    
    initial begin
        clk = 0;    
        R = 0;    
        io = 0;    
        Mw = 0;    
        addr = 16'b0;    
        DI = 16'b0;
    end
    
    always 
        #20 clk = ~clk;
    
    initial begin            
        R = 1;   // Reset high 
        io = 1;  // Store our program in memory
        addr = prog_start;  // start at the beginning of program memory
        #40; //full clock cycle
        
        Mw = 1; 
        
        //*********************************************//
        //           Set all registers to 0            //
        //*********************************************//
        
         
        DI = 16'b0;
        addr = 20;  

        #40; //full clock cycle
        addr = prog_start;
        DI = 16'b1100000000010100; // LOAD r1, 00010100  -- r0 = 0    
            
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1100000100010100; // LOAD r1, 00010100  -- r1 = 0
                
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1100001000010100; // LOAD r2, 00010100  -- r2 = 0
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1100001100010100; // LOAD r3, 00010100  -- r3 = 0
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1100010000010100; // LOAD r4, 00010100  -- r4 = 0
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1100010100010100; // LOAD r5, 00010100  -- r5 = 0
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1100011000010100; // LOAD r6, 00010100  -- r6 = 0
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1100011100010100; // LOAD r7, 00010100  -- r7 = 0

        //
        //start program
        //
        
        //*********************************************//
        //           Test immediate values             //
        //                   &                         //
        //             Populate registers              //
        //                                             //
        //            Store result of each             //
        //           operation in memory for           //
        //             verifying result                //
        //*********************************************//
        DI = 16'b0110000100000000; // ADD r1, 30
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 30; // imm16 
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101000100110010; // STORE r1, 00110010 
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b0110001000000000; // ADD r2, 50               
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 20; // imm16  
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101001000110011; // STORE r2, 00110011 
               
        #40; //full clock cycle
        addr = addr + 1;
        DI = 16'b0110001100000000; // ADD r3, 1
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 1; // imm16
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101001100110100; // STORE r3, 00110100 
                  
        #40; //full clock cycle
        addr = addr + 1;
        DI = 16'b0110010000000000; // ADD r4, 25
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 25; // imm16
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101010000110101; // STORE r4, 00110101 
                
        #40; //full clock cycle
        addr = addr + 1;    
        DI = 16'b0111000100000000; // SUB r1, 16 -- r1 now should equal 14
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16; // imm16
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101000100110111; // STORE r1, 00110111
                
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1000001000000000; // AND r2, 30 -- r2 now should equal 18
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 30; // imm16 
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101001000111000; // STORE r2, 00111000
                
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1001000100000000; // OR r3, 30 -- r3 should now be 31
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 30; // imm16
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101001100111001; // STORE r3, 00111001
                
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1010000100000000; // XOR r4, imm16 --r4 should now be 6
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 31; // imm16
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101010000111010; // STORE r4, 00111010
                 
        #40; //full clock cycle
        addr = addr + 1; 

        //*********************************************//
        //           Test register values              //
        //                                             //
        //            Store result of each             //
        //           operation in memory for           //
        //             verifying result                //
        //*********************************************//
        
        DI = 16'b000100010010ZZZZ; // ADD r1, r2  -- r1 should now be 32
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101000100111011; // STORE r1, 00111011
        
        #40; //full clock cycle
        addr = addr + 1;
        DI = 16'b001000010010ZZZZ; // SUB r1, r3 -- r1 should now be 1 
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101000100111100; // STORE r1, 00111100
                 
        #40; //full clock cycle
        addr = addr + 1;
        DI = 16'b001100010010ZZZZ; // AND r2, r4 -- r2 should now be 2
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101001000111101; // STORE r2, 00111101
                
        #40; //full clock cycle
        addr = addr + 1;
        DI = 16'b010000010010ZZZZ; // OR r3, r1  -- r3 remains at 31
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101001100111110; // STORE r3, 00111110
                
        #40; //full clock cycle
        addr = addr + 1; 
        DI = 16'b010100010010ZZZZ; // XOR r4, r2  -- r4 should now be 27
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101010000111111; // STORE r4, 00111111
         
        //*********************************************//
        //           Test LOAD and STORE               //
        //*********************************************//
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101010101000000; // STORE r5, 01000000 (to see the before value)
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101000101000001; // STORE r1, 01000001    -- store r1 in memory
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1100010101000001; // LOAD r5, 01000001     -- load it back, into r5
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101010101000010; // STORE r5, 01000010     -- verify result      
         
        //*********************************************//
        //           Test opcode with addr8            //
        //*********************************************//
                
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b0110000100110010; // ADD r1, [00111100] 
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101000101000011; // STORE r1, 01000011
                
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b0111000100110011; // SUB r1, [00111101]
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101000101000100; // STORE r1, 01000100
                
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1000000100110100; // AND r1, [00111110]
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101000101000101; // STORE r1, 01000101
                
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1001000100110101; // OR r1, [00111111]
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101000101000110; // STORE r1, 01000110
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1010000100110111; // XOR r1, [00111011]
        
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1101000101000110; // STORE r1, 01000111
         
        #40; //full clock cycle
        addr = addr + 1;  
        DI = 16'b1011000111110001; // JZ r1, address        Jump back 15 instructions
        
        /* Wait for last 15 instructions to repeat */
        for (i=0; i<15; i=i+1) begin
            #40;
        end
                
        Mw = 0;  
        io = 0;  
        R = 1;  
        #40;
        R = 0;  
        
        /* Wait for instructions to be executed by computer */
        for (i=0; i<60; i=i+1) begin
            #40;
        end  
        
        io = 1;
        addr = prog_start;
        
        
        /* Read program from memory */
        for (i=0; i<60; i=i+1) begin
            #40 addr = addr + 1;
        end  
        
        addr = 20;
        /* Read results of operations */
        for (i=0; i<30; i=i+1) begin
            #40 addr = addr + 1;
        end
            

        $finish;
        $stop;
    end
endmodule