module mire (
            wshb_if.master wshb_ifm
            );
parameter VDISP = 480;
parameter HDISP = 800;

logic [$clog2(HDISP)-1:0] count_pix;
logic [$clog2(VDISP)-1:0] count_line;


//For the counters (pixels and lines) From top-down
always_ff @(posedge wshb_ifm.clk or posedge wshb_ifm.rst)
begin
    if (pixel_rst)
    begin
        count_pix <= 0;
        count_line <= 0;
    end
    else
    begin
        if (count_pix == HDISP -1)
        begin
            count_pix <= 0; //reset counter for pixels when is completed (to start from zero on the new line)
            if (count_line == VDISP -1)
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



/////////////////////////////////////////////////////////////


//assign wshb_ifm.adr = (count_pix + HDISP*count_line)*4;
assign wshb_ifm.we = 1'b1;
assign wshb_ifm.cti = '0;
assign wshb_ifm.bte = '0;
assign wshb_ifm.sel = 4'b1111;


always_ff @(posedge wshb_ifm.clk or posedge wshb_ifm.rst)
begin
   if (wshb_ifm.rst)
   begin
      wshb_ifm.adr <= 0;
      wshb_ifm.dat_ms <= 0;
      wshb_ifm.cyc <= 1;
      wshb_ifm.stb <= 0;
   end
   else
   begin
        //Each 16bits makes a square count_pix guarantees horizontal distance,
        //and count_line guarantees vertical distance
        if (count_pix%16 == 0 || count_line%16 == 0) // If it happens one of them
        begin
        wshb_ifm.dat_ms = 32'hffffff; // Make 32 bits 1
        end
        else
        begin
        wshb_ifm.dat_ms = 32'h000000;
        end

        wshb_ifm.adr <= (count_pix + HDISP*count_line)*4; //assign address

        if (count_pix % 64 == 0)
        begin
            //cyc and stb are the same
            wshb_ifm.stb <= 0;
        end
        else
        begin
            //cyc and stb are the same
            wshb_ifm.stb <= 1;
        end
        wshb_ifm.cyc <= wshb_ifm.stb;
   end
end

endmodule