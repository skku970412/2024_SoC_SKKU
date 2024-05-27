// Copyright (c) 2021 Sungkyunkwan University
//
// Authors:
// - Jungrae Kim <dale40@skku.edu>

module DMAC_TOP
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

    // AMBA AXI interface (AW channel)
    output  wire    [3:0]       awid_o,
    output  wire    [31:0]      awaddr_o,
    output  wire    [3:0]       awlen_o,
    output  wire    [2:0]       awsize_o,
    output  wire    [1:0]       awburst_o,
    output  wire                awvalid_o,
    input   wire                awready_i,

    // AMBA AXI interface (AW channel)
    output  wire    [3:0]       wid_o,
    output  wire    [31:0]      wdata_o,
    output  wire    [3:0]       wstrb_o,
    output  wire                wlast_o,
    output  wire                wvalid_o,
    input   wire                wready_i,

    // AMBA AXI interface (B channel)
    input   wire    [3:0]       bid_i,
    input   wire    [1:0]       bresp_i,
    input   wire                bvalid_i,
    output  wire                bready_o,

    // AMBA AXI interface (AR channel)
    output  wire    [3:0]       arid_o,
    output  wire    [31:0]      araddr_o,
    output  wire    [3:0]       arlen_o,
    output  wire    [2:0]       arsize_o,
    output  wire    [1:0]       arburst_o,
    output  wire                arvalid_o,
    input   wire                arready_i,

    // AMBA AXI interface (R channel)
    input   wire    [3:0]       rid_i,
    input   wire    [31:0]      rdata_i,
    input   wire    [1:0]       rresp_i,
    input   wire                rlast_i,
    input   wire                rvalid_i,
    output  wire                rready_o
);

    wire    [31:0]              src_addr;
    wire    [31:0]              dst_addr;
    wire    [15:0]              byte_len;
    wire                        start;
    wire                        done;

    DMAC_CFG u_cfg(
        .clk                    (clk),
        .rst_n                  (rst_n),

        // AMBA APB interface
        .psel_i                 (psel_i),
        .penable_i              (penable_i),
        .paddr_i                (paddr_i),
        .pwrite_i               (pwrite_i),
        .pwdata_i               (pwdata_i),
        .pready_o               (pready_o),
        .prdata_o               (prdata_o),
        .pslverr_o              (pslverr_o),

        .src_addr_o             (src_addr),
        .dst_addr_o             (dst_addr),
        .byte_len_o             (byte_len),
        .start_o                (start),
        .done_i                 (done)
    );

    DMAC_ENGINE u_engine(
        .clk                    (clk),
        .rst_n                  (rst_n),

        // configuration registers
        .src_addr_i             (src_addr),
        .dst_addr_i             (dst_addr),
        .byte_len_i             (byte_len),
        .start_i                (start),
        .done_o                 (done),

        // AMBA AXI interface (AW channel)
        .awid_o                 (awid_o),
        .awaddr_o               (awaddr_o),
        .awlen_o                (awlen_o),
        .awsize_o               (awsize_o),
        .awburst_o              (awburst_o),
        .awvalid_o              (awvalid_o),
        .awready_i              (awready_i),

        // AMBA AXI interface (W channel)
        .wid_o                  (wid_o),
        .wdata_o                (wdata_o),
        .wstrb_o                (wstrb_o),
        .wlast_o                (wlast_o),
        .wvalid_o               (wvalid_o),
        .wready_i               (wready_i),

        // AMBA AXI interface (B channel)
        .bid_i                  (bid_i),
        .bresp_i                (bresp_i),
        .bvalid_i               (bvalid_i),
        .bready_o               (bready_o),

        // AMBA AXI interface (AR channel)
        .arid_o                 (arid_o),
        .araddr_o               (araddr_o),
        .arlen_o                (arlen_o),
        .arsize_o               (arsize_o),
        .arburst_o              (arburst_o),
        .arvalid_o              (arvalid_o),
        .arready_i              (arready_i),

        // AMBA AXI interface (R channel)
        .rid_i                  (rid_i),
        .rdata_i                (rdata_i),
        .rresp_i                (rresp_i),
        .rlast_i                (rlast_i),
        .rvalid_i               (rvalid_i),
        .rready_o               (rready_o)
    );

endmodule
