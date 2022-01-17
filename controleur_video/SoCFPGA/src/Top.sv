`default_nettype none

module Top #(parameter HDISP = 800,
            parameter VDISP = 480)(
    // Les signaux externes de la partie FPGA
	input  wire         FPGA_CLK1_50,
	input  wire  [1:0]	KEY,
	output logic [7:0]	LED,
	input  wire	 [3:0]	SW,
    // Les signaux du support matériel son regroupés dans une interface
    hws_if.master       hws_ifm,
    video_if.master video_ifm //port video_ifm added
);

//====================================
//  Déclarations des signaux internes
//====================================
  wire        sys_rst;   // Le signal de reset du système
  wire        sys_clk;   // L'horloge système a 100Mhz
  wire        pixel_clk; // L'horloge de la video 32 Mhz

//=======================================================
//  La PLL pour la génération des horloges
//=======================================================

sys_pll  sys_pll_inst(
		   .refclk(FPGA_CLK1_50),   // refclk.clk
		   .rst(1'b0),              // pas de reset
		   .outclk_0(pixel_clk),    // horloge pixels a 32 Mhz
		   .outclk_1(sys_clk)       // horloge systeme a 100MHz
);

//=============================
//  Les bus Wishbone internes
//=============================
wshb_if #( .DATA_BYTES(4)) wshb_if_sdram  (sys_clk, sys_rst);
wshb_if #( .DATA_BYTES(4)) wshb_if_stream (sys_clk, sys_rst);

//=============================
//  Le support matériel
//=============================
hw_support hw_support_inst (
    .wshb_ifs (wshb_if_sdram),
    .wshb_ifm (wshb_if_stream),
    .hws_ifm  (hws_ifm),
	.sys_rst  (sys_rst), // output
    .SW_0     ( SW[0] ),
    .KEY      ( KEY )
 );

//=============================
// On neutralise l'interface
// du flux video pour l'instant
// A SUPPRIMER PLUS TARD
//=============================
assign wshb_if_stream.ack = 1'b1;
assign wshb_if_stream.dat_sm = '0 ;
assign wshb_if_stream.err =  1'b0 ;
assign wshb_if_stream.rty =  1'b0 ;

//=============================
// On neutralise l'interface SDRAM
// pour l'instant
// A SUPPRIMER PLUS TARD
//=============================
assign wshb_if_sdram.stb  = 1'b0;
assign wshb_if_sdram.cyc  = 1'b0;
assign wshb_if_sdram.we   = 1'b0;
assign wshb_if_sdram.adr  = '0  ;
assign wshb_if_sdram.dat_ms = '0 ;
assign wshb_if_sdram.sel = '0 ;
assign wshb_if_sdram.cti = '0 ;
assign wshb_if_sdram.bte = '0 ;

//--------------------------
//------- Code Eleves ------
//--------------------------
`ifdef SIMULATION
    localparam h=50;
    localparam h2=16;
`else
    localparam h=50000000;
    localparam h2=16000000;
`endif
logic [$clog2(h):0] count;
logic [$clog2(h2):0] count2;
logic pixel_rst;
logic flipflop;


always_ff@(posedge sys_clk)
    begin
        LED[0]<=KEY[0];
        if (sys_rst)
        begin
            LED[1] <= 0;
            count <= 0;
        end
        else
        begin
            count <= count + 1;
            if (count == 0)
            begin
                LED[1] <= ~LED[1];
            end
            if (count >= h)
            begin
                count <= 0;
            end
        end
    end

always_ff @(posedge pixel_clk)
    if (sys_rst)
    begin
        flipflop <=1;
        pixel_rst<=1;
    end
    else
    begin
        flipflop <= 0;
        pixel_rst <= flipflop;
    end

always_ff @(posedge pixel_clk)
    if (pixel_rst)
    begin
        count2 <= 0;
        LED[2] <= 0;
    end
    else
    begin
        count2 <= count2 + 1;
        if (count2 == 0)
        begin
            LED[2] <= ~LED[2];
        end
        if (count2 >= h2)
        begin
            count2 <= 0;
        end
    end
vga #(.HDISP(HDISP), .VDISP(VDISP)) vga_inst(.pixel_clk(pixel_clk), .pixel_rst(pixel_rst), .video_ifm(video_ifm));//Instance vga

endmodule
