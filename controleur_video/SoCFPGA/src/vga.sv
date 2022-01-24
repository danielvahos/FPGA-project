module vga(
    input wire pixel_clk,
    input wire pixel_rst,
    video_if.master video_ifm,


    wshb_if.master wshb_ifm // added wishbone
);

parameter HDISP = 800;
parameter VDISP = 480;
localparam HFP = 40;
localparam HPULSE = 48;
localparam HBP = 40;
localparam VFP = 13;
localparam VPULSE = 3;
localparam VBP = 29;
assign video_ifm.CLK = pixel_clk;

logic [$clog2(HDISP+HFP+HPULSE+HBP):0] count_pix; //Pixels equivalent to horizontals constants
logic [$clog2(VDISP+VFP+VPULSE+VBP):0] count_line; //Line equivalent to vertical constants


assign wshb_ifm.dat_ms = 32'hBABECAFE;//Data of 32 bits emitted
assign wshb_ifm.adr= '0;// address for writing
assign wshb_ifm.cyc = 1'b1;//the bus is selected
assign wshb_ifm.sel = 4'b1111; //the 4 octets sont for writing
assign wshb_ifm.stb = 1'b1; //it's asked for a transaction
assign wshb_ifm.we = 1'b1; //(write enable) transaction in writing
assign wshb_ifm.cti = '0; //classic transference
assign wshb_ifm.bte = '0; //without utility

//For the counters (pixels and lines) From top-down
always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
    if (pixel_rst)
    begin
        count_pix <= 0;
        count_line <= 0;
    end
    else
    begin
        if (count_pix == HDISP+HFP+HPULSE+HBP -1) // if the pixels of line are complete
        begin
            count_pix <= 0; //reset counter for pixels when is completed (to start from zero on the new line)
            if (count_line == VDISP+VFP+VPULSE+VBP -1)
            begin
                count_line <= 0; //reset line counter if it's completed
            end
            else
            begin
                count_line <= count_line + 1; //to continue counting if it's not done all lines
            end
        end
        else
        begin
            count_pix <= count_pix + 1; //to continue counting if it's not done
        end
    end
end

//Synchronisation
always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
    if (pixel_rst)
    begin
		video_ifm.BLANK <= 0;
  		video_ifm.VS <= 1;
  		video_ifm.HS <= 1;
  		video_ifm.RGB <= {24{1'b0}};
    end
    else
    begin
        if (count_pix % 16 == 0 || count_line % 16 == 0) //it has to be every 16 lines
        begin
            video_ifm.RGB <= {24{1'b1}}; //8bits for each color
        end
        if (count_pix % 16 != 0 && count_line % 16 != 0)
        begin
            video_ifm.RGB <= {24{1'b0}}; //8 bits for each color
        end

        //Condition for counter of pixels
        if (count_pix < HFP || count_pix >= HFP + HPULSE)
        begin
            video_ifm.HS <= 1;
        end
        if (count_pix >= HFP && count_pix < HFP + HPULSE)
        begin
            video_ifm.HS <= 0;
        end

        //Condition for counter of lines
        if (count_line < VFP || count_line >= VFP + VPULSE )
        begin
            video_ifm.VS <= 1;
        end
        if (count_line >= VFP && count_line < VFP+VPULSE)
        begin
            video_ifm.VS <= 0;
        end
        video_ifm.BLANK <= count_line >= VFP + VPULSE + VBP && count_pix >= HPULSE + HFP + HBP;
    end
end

endmodule