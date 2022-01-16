module vga(
    input wire pixel_clk,
    input wire pixel_rst,
    video_if.master video_ifm
);

parameter HDISP = 800;
parameter VDISP = 480;
localparam HFP = 40;
localparam HPULSE = 48;
localparam HBP = 40;
localparam VFP = 13;
localparam VPULSE = 3;
localparam VBP = 29;

logic [$clog2(HDISP+HFP+HPULSE+HBP):0] count_pix; //Pixels equivalent to horizontals constants
logic [$clog2(VDISP+VFP+VPUSE+VBP):0] count_line; //Line equivalent to vertical constants

assign video_ifm.CLK = pixel_clk;

//For the counters (pixels and lines) From top-down
always_ff @(posedge pixel_clk or posedge pixel_rst)
begin
    if (!pixel_rst)
    begin
        if (count_pix == HDISP+HFP+HPULSE+HBP) // if the pixels of line are complete
        begin
            count_pix <= 0; //reset counter for pixels when is completed (to start from zero on the new line)
            if (count_line == VDISP+VFP+VPUSE+VBP)
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


endmodule