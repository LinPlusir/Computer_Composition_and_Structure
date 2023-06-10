module d_cache_wb_2way(
    input wire clk, rst,
    //mips core
    input         cpu_data_req     , // �ǲ�����������(load �� storeָ��)��һ�����ں�������
    input         cpu_data_wr      , // mips->cache, ��ǰ�����Ƿ���д����(�ǲ���storeָ��)��һֱ���ֵ�ƽ״ֱ̬������ɹ�
    input  [1 :0] cpu_data_size    , // ��ϵ�ַ�����λ��ȷ�����ݵ���Ч�ֽڣ�����sb��sh��ָ�
    input  [31:0] cpu_data_addr    , // cpu->cache���������ĵ�ַ
    input  [31:0] cpu_data_wdata   , // cpu->cache��д�������
    output [31:0] cpu_data_rdata   , // cache->cpu�ķ��صĶ�����
    output        cpu_data_addr_ok , // cache->cpu�ô�����ĵ�ַ����OK��������ַ�����գ�д����ַ�����ݱ�����
    output        cpu_data_data_ok , // cache->cpu�ô���������ݴ���OK���������ݷ��أ�д������д�����

    //axi interface
    output         cache_data_req     , // cache->mem, �ǲ�����������
    output         cache_data_wr      , // cache->mem, ��ǰ�����Ƿ���д����(�ǲ��Ǵ���WM״̬)��һֱ���ֵ�ƽ״ֱ̬������ɹ�
    output  [1 :0] cache_data_size    ,
    output  [31:0] cache_data_addr    , //cache->mem���������ĵ�ַ
    output  [31:0] cache_data_wdata   , //cache->mem��д�������
    input   [31:0] cache_data_rdata   , //mem->cache���صĶ�����
    input          cache_data_addr_ok , // mem->cache�ô�����ĵ�ַ����OK��������ַ�����գ�д����ַ�����ݱ�����
    input          cache_data_data_ok   //mem->cache�ô���������ݴ���OK���������ݷ��أ�д������д�����
);
    //Cache����
    parameter  INDEX_WIDTH  = 10, OFFSET_WIDTH = 2;
    localparam TAG_WIDTH    = 32 - INDEX_WIDTH - OFFSET_WIDTH;
    localparam CACHE_DEEPTH = 1 << INDEX_WIDTH;
    
    //Cache�洢��Ԫ
    //��·��������cache
    reg                 cache_valid [CACHE_DEEPTH - 1 : 0][1:0]; //��Чλ
    reg                 cache_dirty [CACHE_DEEPTH - 1 : 0][1:0]; //�޸�λ
    reg                 cache_used    [CACHE_DEEPTH - 1 : 0][1:0]; //ʹ�ñ��λ
    reg [TAG_WIDTH-1:0] cache_tag   [CACHE_DEEPTH - 1 : 0][1:0]; //��Ǵ洢��
    reg [31:0]          cache_block [CACHE_DEEPTH - 1 : 0][1:0]; //���ݴ洢��

    //���ʵ�ַ�ֽ�
    wire [OFFSET_WIDTH-1:0] offset;
    wire [INDEX_WIDTH-1:0] index;
    wire [TAG_WIDTH-1:0] tag;
    
    assign offset = cpu_data_addr[OFFSET_WIDTH - 1 : 0];
    assign index = cpu_data_addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign tag = cpu_data_addr[31 : INDEX_WIDTH + OFFSET_WIDTH];

    //����Cache line
    wire                 c_valid[1:0];
    wire                 c_dirty[1:0]; 
    wire                 c_used   [1:0]; //recently used
    wire [TAG_WIDTH-1:0] c_tag  [1:0];
    wire [31:0]          c_block[1:0];
    
    //����indexȷ��cache��ĳһ�л�ĳ����
    assign c_valid[0] = cache_valid[index][0];
    assign c_valid[1] = cache_valid[index][1];
    assign c_dirty[0] = cache_dirty[index][0];
    assign c_dirty[1] = cache_dirty[index][1];
    assign c_used   [0] = cache_used   [index][0];
    assign c_used   [1] = cache_used   [index][1];
    assign c_tag  [0] = cache_tag  [index][0];
    assign c_tag  [1] = cache_tag  [index][1];
    assign c_block[0] = cache_block[index][0];
    assign c_block[1] = cache_block[index][1];

    //�ж��Ƿ�����
    wire hit,hit0,hit1,miss;
    //0·�Ƿ�����
    assign hit0=c_valid[0] & (c_tag[0] == tag);//cache line��0·��validλΪ1����tag���ַ��tag���
    //1·�Ƿ�����
    assign hit1=c_valid[1] & (c_tag[1] == tag);//cache line��1·��validλΪ1����tag���ַ��tag���
    assign hit = hit0| hit1 ; //0��1·��һ·���м��� 
    assign miss = ~hit;

    //�����cache����Ӧ������һ·
    wire c_way;
    //���hit����wayû�����壬��miss����way��ʾ������·
    assign c_way = hit ? (hit0 ? 1'b0 : 1'b1) : 
                   c_used[0] ? 1'b1 : 1'b0; 

    // cpuָ�����д
    wire read, write;
    assign write = cpu_data_wr;
    assign read = cpu_data_req & ~write; //�����ݶ�д���󣬲���д���Ƕ�

    //cache��ǰλ���Ƿ��޸�
    wire dirty, clean;
    assign dirty = c_dirty[c_way];//�޸ģ����Ҫ����
    assign clean = ~dirty;//δ�޸�

    //FSM״̬��
    //IDLE:����״̬
    //RM:��ȡ�ڴ�״̬
    //WM:д�ڴ�״̬
    parameter IDLE = 2'b00, RM = 2'b01, WM = 2'b11;
    reg [1:0] state;
    reg inRM;//����дcacheʱ������дȱʧ��dirty���������Ҫ��RM�ٵ�IDLE��д��cache��������һλ���ж�֮ǰ�Ƿ�����RM

    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
            inRM <= 1'b0;
        end
        else begin
            case(state)
                IDLE: begin
                    state <= cpu_data_req & read & hit ? IDLE: //������ֱ�Ӷ�ȡ��Ӧ��cache������
                             cpu_data_req & read & miss ? (clean ? RM : WM): 
                             //��ȱʧ��clean:���ڴ��ȡ���ݣ���д��cache;
                             //dirty:����Ҫ�����cache line��������д�뵽�ڴ��У��ȴ�д��������ɺ��ٷ��Ͷ�����
                             cpu_data_req & write & hit ? IDLE://д���У�clean:ֱ��дcache line��drityλ��1��dirty��ֱ��дcache line
                             cpu_data_req & write & miss ? (clean? IDLE : WM):IDLE;//дȱʧ��clean:ֱ��дcache line��dirty���Ƚ�cache������д���ڴ�
                    inRM <= 1'b0;
                end

                WM:  state <= cache_data_data_ok ? IDLE : WM;     //д���ڴ��������ʱ������00���������

                RM: begin
                    state <= cache_data_data_ok ? IDLE : RM; //��ȡ�ڴ��������ʱ������00���������
                    inRM <= 1'b1;
                end
            endcase
        end
    end

    //���ڴ�
    //���� read_req, addr_rcv, read_finish���ڹ�����sram�źš�
    wire read_req;      //�Ƿ���cache->mem�Ķ�����
    reg addr_rcv;       //��ַ���ճɹ�(addr_ok)�󵽽��� 
    wire read_finish;   //���ݽ��ճɹ�(data_ok)�������������
    always @(posedge clk) begin
        addr_rcv <= rst ? 1'b0 :
                    cache_data_req & read & cache_data_addr_ok ? 1'b1 :
                    read_finish ? 1'b0 : 
                    addr_rcv;
    end
    assign read_req = state==RM;
    assign read_finish = read & cache_data_data_ok;//���ݷ������

    //д�ڴ�
    wire write_req;     //�Ƿ���cache->mem��д����
    reg waddr_rcv;      
    wire write_finish;  
    always @(posedge clk) begin
        waddr_rcv <= rst ? 1'b0 :
                     cache_data_req & write & cache_data_addr_ok ? 1'b1 ://��ַ�����ݽ��ճɹ�
                     write_finish ? 1'b0 :
                     waddr_rcv;
    end
    assign write_req = state==WM;
    assign write_finish = write & cache_data_data_ok;//����д�����

    //cache->cpu
    assign cpu_data_rdata   = hit ? c_block[c_way] : cache_data_rdata;//cache->cpu�������ݣ�������������cache�����ݿ飬�����д������ж�
    assign cpu_data_addr_ok = cpu_data_req & hit | cache_data_req & read_req & cache_data_addr_ok;
    assign cpu_data_data_ok = cpu_data_req & hit | read_req & cache_data_data_ok;

    //output to axi interface
    // cache->mem
    assign cache_data_req   = read_req & ~addr_rcv | write_req & ~waddr_rcv;//�������ҵ�ַ�������ݣ�δ��mem����
    assign cache_data_wr    = write_req;//ֻҪ����WM״̬��һֱ��д����
    assign cache_data_size  = cpu_data_size;
    assign cache_data_addr  = cache_data_wr ? {c_tag[c_way], index, offset}://д��д��mem�ĵ�ַΪԭcache line��Ӧ�ĵ�ַ(һ·)
                                              cpu_data_addr;//������Ӧmem�ĵ�ַΪcpu_data_addr
    assign cache_data_wdata = c_block[c_way];//д��mem��������ԭ��cache line��һ·��������

    //д��Cache
    //�����ַ�е�tag, index����ֹaddr�����ı�
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

    //���ݵ�ַ����λ��size������д���루���sb��sh�Ȳ���д����һ���ֵ�ָ���4λ��Ӧ1���֣�4�ֽڣ���ÿ���ֵ�дʹ��
    assign write_mask = cpu_data_size==2'b00 ?
                            (cpu_data_addr[1] ? (cpu_data_addr[0] ? 4'b1000 : 4'b0100):
                                                (cpu_data_addr[0] ? 4'b0010 : 4'b0001)) :
                            (cpu_data_size==2'b01 ? (cpu_data_addr[1] ? 4'b1100 : 4'b0011) : 4'b1111);

    //�����ʹ�ã�λΪ1�Ĵ�����Ҫ���µġ�
    //λ��չ��{8{1'b1}} -> 8'b11111111
    //new_data = old_data & ~mask | write_data & mask
    assign write_cache_data = cache_block[index][c_way] & ~{{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}} | 
                              cpu_data_wdata & {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};

    integer t, way;
    wire isIDLE;//дcacheʱ������write������񣬶�Ҫ�ص�IDLE״̬����д��
    assign isIDLE = state==IDLE;
    always @(posedge clk) begin
        if(rst) begin
        //reset
            for(t=0; t<CACHE_DEEPTH; t=t+1) begin 
                for (way = 0; way<2; way=way+1) begin
                    cache_valid[t][way] <= 0;
                    cache_dirty[t][way] <= 0;
                    cache_used [t][way] <= 0;
                end
            end
        end
        else begin
            if(read_finish) begin //��������ɺ�
                cache_valid[index_save][c_way] <= 1'b1;             //��Cache line��Ϊ��Ч
                cache_dirty[index_save][c_way] <= 1'b0; // ��ȡ�ڴ�����ݺ�һ����clean
                cache_tag  [index_save][c_way] <= tag_save;
                cache_block[index_save][c_way] <= cache_data_rdata; //����mem��������д��Cache
            end
            else if (write & isIDLE & (hit | inRM)) begin
                cache_dirty[index][c_way] <= 1'b1; // �������ݣ���dirty
                cache_block[index][c_way] <= write_cache_data;      //д��Cache line��ʹ��index������index_save
            end
            //c_way��д�룬һ·ʹ����,һ·��δʹ��
            if (read & isIDLE & (hit | inRM)) begin
                //��cache��hitֱ��IDLE;miss,clean:RM,dirty:WM->RM ��һ״̬����RM������Ҫ��inRM
                cache_used[index][c_way]   <= 1'b1; 
                cache_used[index][1-c_way] <= 1'b0; 
            end
            else if(write & isIDLE & (hit |inRM)) begin
            //дcache��hitֱ��IDLE;miss,clean:����,dirty:RM 
                 cache_used[index][c_way]   <= 1'b1; 
                cache_used[index][1-c_way] <= 1'b0; 
            end
        end
    end
endmodule