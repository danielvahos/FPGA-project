module wshb_intercon ( //Define wshb_intercon of module
	wshb_if.slave wshb_ifs_vga,
	wshb_if.slave wshb_ifs_mire,
	wshb_if.master wshb_ifm_sdram
);

logic cond; //Conditional for true - vga and false -mire

//      MASTER
assign wshb_ifm_sdram.sel = cond ? wshb_ifs_vga.sel : wshb_ifs_mire.sel;
assign wshb_ifm_sdram.cti = cond ? wshb_ifs_vga.cti : wshb_ifs_mire.cti;
assign wshb_ifm_sdram.bte = cond ? wshb_ifs_vga.bte : wshb_ifs_mire.bte;
assign wshb_ifm_sdram.cyc = cond ? wshb_ifs_vga.cyc : wshb_ifs_mire.cyc;
assign wshb_ifm_sdram.stb = cond ? wshb_ifs_vga.stb : wshb_ifs_mire.stb;
assign wshb_ifm_sdram.adr = cond ? wshb_ifs_vga.adr : wshb_ifs_mire.adr;
assign wshb_ifm_sdram.we = cond ? wshb_ifs_vga.we : wshb_ifs_mire.we;
assign wshb_ifm_sdram.dat_ms = cond ? wshb_ifs_vga.dat_ms : wshb_ifs_mire.dat_ms;

//      SLAVES
//RTY
assign wshb_ifs_vga.rty = cond ? wshb_ifm_sdram.rty : '0;
assign wshb_ifs_mire.rty = ~cond ? wshb_ifm_sdram.rty : '0;

//ERR
assign wshb_ifs_vga.err = cond ? wshb_ifm_sdram.err : '0;
assign wshb_ifs_mire.err = ~cond ? wshb_ifm_sdram.err : '0;

//ACK
assign wshb_ifs_vga.ack = cond ? wshb_ifm_sdram.ack : '0;
assign wshb_ifs_mire.ack = ~cond ? wshb_ifm_sdram.ack : '0;

//DAT_SM
assign wshb_ifs_vga.dat_sm = cond ? wshb_ifm_sdram.dat_sm : '0;
assign wshb_ifs_mire.dat_sm = ~cond ? wshb_ifm_sdram.dat_sm : '0;


//Update COND according,
always @(posedge wshb_ifm_sdram.clk or posedge wshb_ifm_sdram.rst)
    begin
        if (wshb_ifm_sdram.rst)
        begin
            cond = 0;
        end
        else
        begin
        if (cond) //if COND ==1
        begin
            if (~wshb_ifs_vga.cyc)
                cond <= 0; //reset
        end
        else
        begin
            if (~wshb_ifs_mire.cyc)
                cond <= 1; //reset
        end
        end
    end
endmodule