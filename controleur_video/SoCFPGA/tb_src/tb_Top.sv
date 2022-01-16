`timescale 1ns/1ps

`default_nettype none

module tb_Top;

// Entrées sorties extérieures
bit   FPGA_CLK1_50;
logic [1:0]	KEY;
wire  [7:0]	LED;
logic [3:0]	SW;

// Interface vers le support matériel
hws_if      hws_ifm();

// Instance du module Top
video_if video_if0() ;
//Parameters HDISP for 160 and VDISP for 90
Top #(.HDISP(160), .VDISP(90)) Top0(.*, .video_ifm(video_if0) ) ; //Interface video_if0 connected

///////////////////////////////
//  Code élèves
//////////////////////////////
always #10ns FPGA_CLK1_50 =~ FPGA_CLK1_50;

initial begin
    KEY[0] = 1;
    #128ns;
    KEY[0]=0;
    #128ns;
    KEY[0]=1;
    #4ms;
    $stop();
end

endmodule
