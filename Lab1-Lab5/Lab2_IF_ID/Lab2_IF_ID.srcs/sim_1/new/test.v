module test();
reg clk;
reg rst;
wire memtoreg;
wire jump;
wire memwrite;
wire branch;
wire alusrc;
wire pcsrc;
wire regdst;
wire regwrite;
wire [2:0]alucontrol;
wire inst_ce;
wire [31:0]addr;
wire [31:0]inst;
pc c1(.clk(clk),.rst(rst),.inst_ce(inst_ce),.pc(addr));
inst_ram blk(.clka(clk),.addra(addr),.ena(inst_ce),.douta(inst),.dina(32'h00000000),.wea(4'b0000));
controller con(.op(inst[31:26]),.funct(inst[5:0]),.zero(1'b1),.memtoreg(memtoreg),.memwrite(memwrite),.branch(branch),.jump(jump),.alusrc(alusrc),.regdst(regdst),.regwrite(regwrite),.alucontrol(alucontrol),.pcsrc(pcsrc));
always #5 clk = ~clk;
initial begin
clk = 1; rst = 1;
#35 rst=0;
end
always #10 $display("instruction: %h, memtoreg: %b, memwrite: %b, pcsrc: %b, alusrc: %b, regdst: %b, regwrite: %b, jump: %b, branch: %b, alucontrol: %b",
					inst, memtoreg, memwrite, pcsrc, alusrc, regdst, regwrite, jump, branch, alucontrol);
endmodule