module d_cache_wb_4way_fLRU (
   input wire clk, rst,
    //mips core
    input         cpu_data_req     , // cpu->cache的读写信号，1为有读写请求
    input         cpu_data_wr      , // cpu->cache,请求是否是写请求。一直保持电平状态直到请求成功
    input  [1 :0] cpu_data_size    , //结合地址最低两位，确定数据的有效字节
    input  [31:0] cpu_data_addr    , // cpu->cache的这次请求的地址
    input  [31:0] cpu_data_wdata   , // cpu->cache的写入的数据
    output [31:0] cpu_data_rdata   , // cache->cpu的返回的读数据
    output        cpu_data_addr_ok , // cache->cpu该次请求的地址传输OK，读：地址被接收；写：地址和数据被接收
    output        cpu_data_data_ok , // cache->cpu该次请求的数据传输OK，读：数据返回；写：数据写入完成

    //axi interface
    output         cache_data_req     , //cache->mem, 是不是数据请求。
    output         cache_data_wr      , //cache->mem, 当前请求是否是写请求。一直保持电平状态直到请求成功
    output  [1 :0] cache_data_size    , 
    output  [31:0] cache_data_addr    , //cache->mem的这次请求的地址
    output  [31:0] cache_data_wdata   , //cache->mem的写入的数据
    input   [31:0] cache_data_rdata   , //mem->cache返回的读数据
    input          cache_data_addr_ok , // mem->cache该次请求的地址传输OK，读：地址被接收；写：地址和数据被接收
    input          cache_data_data_ok   //mem->cache该次请求的数据传输OK，读：数据返回；写：数据写入完成
);
    //Cache配置
    parameter  INDEX_WIDTH  = 10, OFFSET_WIDTH = 2;
    localparam TAG_WIDTH    = 32 - INDEX_WIDTH - OFFSET_WIDTH;
    localparam CACHE_DEEPTH = 1 << INDEX_WIDTH;
    
    //Cache存储单元
    //cache分成四部分
    reg                 cache_valid [CACHE_DEEPTH - 1 : 0][3:0];//有效位
    reg                 cache_dirty [CACHE_DEEPTH - 1 : 0][3:0]; //修改位
    reg [TAG_WIDTH-1:0] cache_tag   [CACHE_DEEPTH - 1 : 0][3:0]; //标记存储体
    reg [31:0]          cache_block [CACHE_DEEPTH - 1 : 0][3:0]; //数据存储体
    reg [2:0]           cache_bit  [CACHE_DEEPTH - 1 : 0];   //(4-1)位的bits去确定cache line
    //* tree 为对应cache set的查找树, tree[2]为根节点, tree[1]右子树，tree[0]左子树
    wire [2:0] tree;
    

    //访问地址分解
    wire [OFFSET_WIDTH-1:0] offset;
    wire [INDEX_WIDTH-1:0] index;
    wire [TAG_WIDTH-1:0] tag;
    
    assign offset = cpu_data_addr[OFFSET_WIDTH - 1 : 0];
    assign index = cpu_data_addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign tag = cpu_data_addr[31 : INDEX_WIDTH + OFFSET_WIDTH];

    //访问Cache line
    wire                 c_valid[3:0];
    wire                 c_dirty[3:0]; 
    wire [TAG_WIDTH-1:0] c_tag  [3:0];
    wire [31:0]          c_block[3:0];

   //根据index确定cache line
    assign c_valid[0] = cache_valid[index][0];
    assign c_valid[1] = cache_valid[index][1];
    assign c_valid[2] = cache_valid[index][2];
    assign c_valid[3] = cache_valid[index][3];
    assign c_dirty[0] = cache_dirty[index][0];
    assign c_dirty[1] = cache_dirty[index][1];
    assign c_dirty[2] = cache_dirty[index][2];
    assign c_dirty[3] = cache_dirty[index][3];
    assign c_tag  [0] = cache_tag  [index][0];
    assign c_tag  [1] = cache_tag  [index][1];
    assign c_tag  [2] = cache_tag  [index][2];
    assign c_tag  [3] = cache_tag  [index][3];
    assign c_block[0] = cache_block[index][0];
    assign c_block[1] = cache_block[index][1];
    assign c_block[2] = cache_block[index][2];
    assign c_block[3] = cache_block[index][3];
    assign tree =  cache_bit[index];
    //判断是否命中
    wire hit, hit0,hit1,hit2,hit3,miss;
    assign hit0 = c_valid[0] & (c_tag[0] == tag);
    assign hit1 = c_valid[1] & (c_tag[1] == tag);
    assign hit2 = c_valid[2] & (c_tag[2] == tag);
    assign hit3 = c_valid[3] & (c_tag[3] == tag);
    assign hit = hit0 | hit1 | hit2 | hit3;  //查看set中是否有line命中
    assign miss = ~hit;

    //0-3路cache line
    wire [1:0] c_way;
    //如果hit，则way没意义，若miss，则way表示分配那路
    //根节点为1，表示最近访问的是0，1路；根节点为0，表示最近访问的是2，3路
    assign c_way = hit ? (hit0 ? 2'b00 :
                          hit1 ? 2'b01 :
                          hit2 ? 2'b10 : 2'b11) : tree[2] ? 
                          {tree[2], tree[0]} : //next_state是2，3路
                          {tree[2], tree[1]};  //next_states是0，1路
// cpu指令读或写
    wire read, write;
    assign  write = cpu_data_wr;
    assign  read = ~write; // 不是写就是读

    //cache当前位置是否修改
    wire dirty, clean;
    assign dirty = c_dirty[c_way]; //修改，脏就要换出
    assign clean = ~dirty;  //不修改
    
    
    //FSM状态机
    //IDLE:空闲状态
    //RM:读取内存状态
    //WM：写内存状态
    parameter IDLE = 2'b00, RM = 2'b01, WM = 2'b11;
    reg [1:0] state;
    reg inRM; //用于写cache时，发生写缺失且dirty的情况，需要先RM再到IDLE再回写cache，所以置一位来判断之前是否是在RM

    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
            inRM <= 1'b0;
        end
        else begin
            case(state)
                IDLE:
                begin
                    state <= cpu_data_req & read & hit? IDLE:                      //读命中直接读取对应的cache的数据
                             cpu_data_req & read & miss? (clean? RM : WM):         //读缺失，clean:从内存读取数据，并写入cache;dirty:首先要将这个cache line的脏数据写入到内存中，等待写请求处理完成后，再发送读请求
                             cpu_data_req & write & hit? IDLE:                     //写命中，clean:直接写cache line，drity位置1；dirty：直接写cache line
                             cpu_data_req & write & miss? (clean? IDLE:WM): IDLE;  //写缺失，clean:直接写cache line；dirty：先将cache的数据写进内存
                    inRM <= 1'b0;
                end
                WM:  state <= cache_data_data_ok ? IDLE : WM;     //写入内存数据完成时，返回00，否则继续

                RM:  
                begin
                    state <= cache_data_data_ok ? IDLE : RM; //读取内存数据完成时，返回00，否则继续
                    inRM <= 1'b1;
                end
            endcase
        end
    end

    //读内存
   //变量 read_req, addr_rcv, read_finish用于构造类sram信号。
    wire read_req;        //是否有cache->mem的读请求
    reg addr_rcv;         //地址接收成功(addr_ok)后到结束
    wire read_finish;    //数据接收成功(data_ok)，即读请求结束
    always @(posedge clk) begin
        addr_rcv <= rst ? 1'b0 :
                    cache_data_req & read & cache_data_addr_ok ? 1'b1 : //地址接收成功
                    read_finish ? 1'b0 : 
                    addr_rcv;
    end
    assign read_req = state==RM;
    assign read_finish = read & cache_data_data_ok;   //数据返回完成

    //写内存
    wire write_req;    //是否有cache->mem的写请求
    reg waddr_rcv;      
    wire write_finish;  
    always @(posedge clk) begin
        waddr_rcv <= rst ? 1'b0 :
                     cache_data_req& write & cache_data_addr_ok ? 1'b1 :  //地址和数据接收成功
                     write_finish ? 1'b0 :
                     waddr_rcv;
    end
    assign write_req = state==WM;
    assign write_finish = write & cache_data_data_ok;      //数据写入完成


   //cache->cpu
    assign cpu_data_rdata   = hit ? c_block[c_way] : cache_data_rdata; //cache->cpu读的数据，命中则来自于cache的数据块，不命中从主存中读
    assign cpu_data_addr_ok = cpu_data_req & hit | cache_data_req & read_req & cache_data_addr_ok;
    assign cpu_data_data_ok = cpu_data_req & hit | read_req & cache_data_data_ok;

    // cache->mem
    assign cache_data_req   = read_req & ~addr_rcv | write_req & ~waddr_rcv;//有请求且地址（和数据）未被mem接受
    assign cache_data_wr    = write_req;//只要处在WM状态就一直有写请求
    assign cache_data_size  = cpu_data_size;
    assign cache_data_addr  = cache_data_wr ? {c_tag[c_way], index, offset}:  //写，写回mem的地址为原cache line对应的地址(一路)
                                              cpu_data_addr;                  //读，对应mem的地址为cpu_data_addr
    assign cache_data_wdata = c_block[c_way];                                 //写回mem的数据是原来cache line（一路）的数据
//写入Cache
    //保存地址中的tag, index，防止addr发生改变
    reg [TAG_WIDTH-1:0] tag_save;
    reg [INDEX_WIDTH-1:0] index_save;
    always @(posedge clk) begin
        tag_save   <= rst ? 0 :
                      cpu_data_req ? tag : tag_save;
        index_save <= rst ? 0 :
                      cpu_data_req ? index : index_save;
    end

    wire [31:0] write_cache_data;
    wire [3:0] write_mask;
    //根据地址低两位和size，生成写掩码（针对sb，sh等不是写完整一个字的指令），4位对应1个字（4字节）中每个字的写使能
    assign write_mask = cpu_data_size==2'b00 ?
                            (cpu_data_addr[1] ? (cpu_data_addr[0] ? 4'b1000 : 4'b0100):
                                                (cpu_data_addr[0] ? 4'b0010 : 4'b0001)) :
                            (cpu_data_size==2'b01 ? (cpu_data_addr[1] ? 4'b1100 : 4'b0011) : 4'b1111);

    //掩码的使用：位为1的代表需要更新的。
    //位拓展：{8{1'b1}} -> 8'b11111111
    //new_data = old_data & ~mask | write_data & mask
    assign write_cache_data = cache_block[index][c_way] & ~{{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}} | 
                              cpu_data_wdata & {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};

    integer t, way;
    wire isIDLE;  //写cache时，不论write命中与否，都要回到IDLE状态才能写入
    assign isIDLE = state==IDLE;
    always @(posedge clk) begin
        if(rst) begin
            for(t=0; t<CACHE_DEEPTH; t=t+1) begin   //刚开始将Cache初始化为无效，dirty 初始化为 0
                for ( way = 0;  way<4;  way= way+1) begin
                    cache_valid[t][way] <= 0;
                    cache_dirty[t][way] <= 0;
                end
                //* tree初始化为000
                 cache_bit[t] <= 3'b000;
            end
        end
        else begin
           if(read_finish)
              begin // 处于RM状态，且已得到mem读取的数据
                cache_valid[index_save][c_way] <= 1'b1;             //将Cache line置为有效
                cache_dirty[index_save][c_way] <= 1'b0; // 读取内存的数据后，一定是clean
                cache_tag  [index_save][c_way] <= tag_save;
                cache_block[index_save][c_way] <= cache_data_rdata; //写入Cache line
             end
           else if (write & isIDLE & (hit | inRM))
             begin 
                cache_dirty[index][c_way] <= 1'b1; // 修改，置1
                cache_block[index][c_way] <= write_cache_data;      //写入Cache line，使用index而不是index_save
             end
             
           //更新树的标识位
           if ( read & isIDLE & (hit | inRM)) 
              begin
              //读cache：hit直接IDLE;miss,clean:RM,dirty:WM->RM 上一状态都是RM，所以要求inRM
                if (c_way[1] == 1'b0)  //当前state为0，1路，则更新tree[2]和tree[1]
                    { cache_bit[index][2],  cache_bit[index][1]} <= ~c_way;
                else  //当前state为2，3路，则更新tree[2]和tree[0]
                    { cache_bit[index][2],  cache_bit[index][0]} <= ~c_way;
             end
            else if ( write & isIDLE & (hit | inRM)) 
            begin
              //写cache：hit直接IDLE;miss,clean:覆盖,dirty:RM 
              if (c_way[1] == 1'b0)  //当前state为0，1路，则更新tree[2]和tree[1]
                    { cache_bit[index][2],  cache_bit[index][1]} <= ~c_way;
               else  //当前state为2，3路，则更新tree[2]和tree[0]
                    { cache_bit[index][2],  cache_bit[index][0]} <= ~c_way;
            end
            
        end
    end
endmodule
