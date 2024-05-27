// Copyright (c) 2021 Sungkyunkwan University
//
// Authors:
// - Jungrae Kim <dale40@skku.edu>

module DMAC_CFG
(
    input   wire                clk,
    input   wire                rst_n,  // _n means active low

    // AMBA APB interface
    input   wire                psel_i,
    input   wire                penable_i,
    input   wire    [11:0]      paddr_i,
    input   wire                pwrite_i,
    input   wire    [31:0]      pwdata_i,
    output  reg                 pready_o,
    output  reg     [31:0]      prdata_o,
    output  reg                 pslverr_o,

    // configuration registers
    output  reg     [31:0]      src_addr_o,
    output  reg     [31:0]      dst_addr_o,
    output  reg     [15:0]      byte_len_o,
    output  wire                start_o,
    input   wire                done_i
);

    // Configuration register to read/write
    reg     [31:0]              src_addr;
    reg     [31:0]              dst_addr;
    reg     [15:0]              byte_len;
    reg     [31:0]              dma_ver = 32'h00012024;


    //----------------------------------------------------------
    // Write
    //----------------------------------------------------------
    // an APB write occurs when PSEL & PENABLE & PWRITE
    // clk     : __--__--__--__--__--__--__--__--__--__--
    // psel    : ___--------_____________________________
    // penable : _______----_____________________________
    // pwrite  : ___--------_____________________________
    // wren    : _______----_____________________________
    //
    // DMA start command must be asserted when APB writes 1 to the DMA_CMD
    // register
    // clk     : __--__--__--__--__--__--__--__--__--__--
    // psel    : ___--------_____________________________
    // penable : _______----_____________________________
    // pwrite  : ___--------_____________________________
    // paddr   :    |DMA_CMD|
    // pwdata  :    |   1   |
    // start   : _______----_____________________________

    wire    wren;
    assign  wren = psel_i & penable_i & pwrite_i; // fill your code here
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset logic for writable registers
            src_addr <= 32'd0;
            dst_addr <= 32'd0;
            byte_len <= 16'd0;
            dma_ver <= 32'h00012024; // Initialize dma_ver to the version number
        end else if (wren) begin
            case (paddr_i)
                32'h100: src_addr <= pwdata_i;   // Write to DMA_SRC
                32'h104: dst_addr <= pwdata_i;   // Write to DMA_DST
                32'h108: byte_len <= pwdata_i[15:0]; // Write to DMA_LEN
                //32'h10C: if (done_i) start_reg = pwdata_i[0]; // Write to DMA_CMD, only if DMA is not active
                // No default case required here since we only handle writes to specific registers
            endcase
        end
    end
    wire    start;
    assign start = wren & paddr_i ==32'h10C &(pwdata_i[0] == 1'b1) & done_i;// fill your code here
    // Read
    reg     [31:0]              rdata;

    //----------------------------------------------------------
    // READ
    //----------------------------------------------------------
    // an APB read occurs when PSEL & PENABLE & !PWRITE
    // To make read data a direct output from register,
    // this code shall buffer the muxed read data into a register
    // in the SETUP cycle (PSEL & !PENABLE)
    // clk        : __--__--__--__--__--__--__--__--__--__--
    // psel       : ___--------_____________________________
    // penable    : _______----_____________________________
    // pwrite     : ________________________________________
    // reg update : ___----_________________________________
    //
    wire reg_update;
    assign reg_update = psel_i & !penable_i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rdata <= 32'd0;
            prdata_o <= 32'd0;
        end else if (reg_update) begin
            // Logic to buffer the read data in SETUP cycle
            case (paddr_i)
                32'h000: rdata <= dma_ver;   // Read from DMA_VER
                32'h100: rdata <= src_addr;  // Read from DMA_SRC
                32'h104: rdata <= dst_addr;  // Read from DMA_DST
                32'h108: rdata <= {16'd0, byte_len}; // Read from DMA_LEN
                32'h110: rdata <= {31'd0, done_i}; // Read from DMA_STATUS
                // Default case could be added to handle invalid addresses
                default: rdata <= 32'd0;
            endcase
        end

    end
    always @(psel_i & penable_i & !pwrite_i)begin
        prdata_o <= rdata;
    end



    // output assignments
    assign  pready_o            = 1'b1;
    //assign  prdata_o            = rdata;
    assign  pslverr_o           = 1'b0;

    assign  src_addr_o          = src_addr;
    assign  dst_addr_o          = dst_addr;
    assign  byte_len_o          = byte_len;
    assign  start_o             = start;

endmodule