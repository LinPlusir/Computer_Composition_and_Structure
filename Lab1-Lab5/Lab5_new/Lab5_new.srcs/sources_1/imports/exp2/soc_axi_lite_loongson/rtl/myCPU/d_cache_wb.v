module d_cache_wb (
    input wire clk, rst,
    //mips core
    input         cpu_data_req     , // cpu->cache�Ķ�д�źţ�1Ϊ�ж�д����
    input         cpu_data_wr      , // cpu->cache,�����Ƿ���д����һֱ���ֵ�ƽ״ֱ̬������ɹ�
    input  [1 :0] cpu_data_size    , //��ϵ�ַ�����λ��ȷ�����ݵ���Ч�ֽ�
    input  [31:0] cpu_data_addr    , // cpu->cache���������ĵ�ַ
    input  [31:0] cpu_data_wdata   , // cpu->cache��д�������
    output [31:0] cpu_data_rdata   , // cache->cpu�ķ��صĶ�����
    output        cpu_data_addr_ok , // cache->cpu�ô�����ĵ�ַ����OK��������ַ�����գ�д����ַ�����ݱ�����
    output        cpu_data_data_ok , // cache->cpu�ô���������ݴ���OK���������ݷ��أ�д������д�����

    //axi interface
    output         cache_data_req     , //cache->mem, �ǲ�����������
    output         cache_data_wr      , //cache->mem, ��ǰ�����Ƿ���д����һֱ���ֵ�ƽ״ֱ̬������ɹ�
    output  [1 :0] cache_data_size    , 
    output  [31:0] cache_data_addr    , //cache->mem���������ĵ�ַ
    output  [31:0] cache_data_wdata   , //cache->mem��д�������
    input   [31:0] cache_data_rdata   , //mem->cache���صĶ�����
    input          cache_data_addr_ok , //mem->cache�ô�����ĵ�ַ����OK��������ַ�����գ�д����ַ�����ݱ�����
    input          cache_data_data_ok   //mem->cache�ô���������ݴ���OK���������ݷ��أ�д������д�����
);

    //ʹ��LUT����ʵ�ִ洢
    //Cache����
    parameter  INDEX_WIDTH  = 10, OFFSET_WIDTH = 2;
    localparam TAG_WIDTH    = 32 - INDEX_WIDTH - OFFSET_WIDTH;
    localparam CACHE_DEEPTH = 1 << INDEX_WIDTH;
    
    //Cache�洢��Ԫ
    //ʹ��reg�����ά����ķ�ʽʵ�ִ洢
    reg                 cache_valid [CACHE_DEEPTH - 1 : 0]; //��Чλ
    reg                 cache_dirty [CACHE_DEEPTH - 1 : 0]; //�޸�λ
    reg [TAG_WIDTH-1:0] cache_tag   [CACHE_DEEPTH - 1 : 0]; //��Ǵ洢��
    reg [31:0]          cache_block [CACHE_DEEPTH - 1 : 0]; //���ݴ洢��

    //���ʵ�ַ�ֽ�
    wire [OFFSET_WIDTH-1:0] offset;
    wire [INDEX_WIDTH-1:0] index;
    wire [TAG_WIDTH-1:0] tag;
    
    assign offset = cpu_data_addr[OFFSET_WIDTH - 1 : 0];
    assign index = cpu_data_addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign tag = cpu_data_addr[31 : INDEX_WIDTH + OFFSET_WIDTH];

    //����Cache line
    wire c_valid;
    wire c_dirty; 
    wire [TAG_WIDTH-1:0] c_tag;
    wire [31:0] c_block;
   
   //����indexȷ��cache��ĳһ�л�ĳ����
    assign c_valid = cache_valid[index];
    assign c_dirty = cache_dirty[index]; 
    assign c_tag   = cache_tag  [index];
    assign c_block = cache_block[index];

    //�ж��Ƿ�����
    wire hit, miss;
    assign hit = c_valid & (c_tag == tag);  //cache line��validλΪ1����tag���ַ��tag���
    assign miss = ~hit;//������

    //����д
    wire read, write;
    assign write = cpu_data_wr; //д����
    assign read =~write; // ����д���Ƕ�

    //cache��ǰλ���Ƿ��޸�
    wire dirty, clean;
    assign dirty = c_dirty; //�޸ģ����Ҫ����
    assign clean = ~dirty;  //���޸�

    //FSM״̬��
    //IDLE:����״̬
    //RM:��ȡ�ڴ�״̬
    //WM��д�ڴ�״̬
    parameter IDLE = 2'b00, RM = 2'b01, WM = 2'b11;
    reg [1:0] state;
    reg inRM; //����дcacheʱ������дȱʧ��dirty���������Ҫ��RM�ٵ�IDLE�ٻ�дcache��������һλ���ж�֮ǰ�Ƿ�����RM

    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
            inRM <= 1'b0;
        end
        else begin
            case(state)
                IDLE:
                begin
                    state <= cpu_data_req & read & hit? IDLE:                      //������ֱ�Ӷ�ȡ��Ӧ��cache������
                             cpu_data_req & read & miss? (clean? RM : WM):         //��ȱʧ��clean:���ڴ��ȡ���ݣ���д��cache;dirty:����Ҫ�����cache line��������д�뵽�ڴ��У��ȴ�д��������ɺ��ٷ��Ͷ�����
                             cpu_data_req & write & hit? IDLE:                     //д���У�clean:ֱ��дcache line��drityλ��1��dirty��ֱ��дcache line
                             cpu_data_req & write & miss? (clean? IDLE:WM): IDLE;  //дȱʧ��clean:ֱ��дcache line��dirty���Ƚ�cache������д���ڴ�
                    inRM <= 1'b0;
                end
                WM:  state <= cache_data_data_ok ? IDLE : WM;     //д���ڴ��������ʱ������00���������

                RM:  
                begin
                    state <= cache_data_data_ok ? IDLE : RM; //��ȡ�ڴ��������ʱ������00���������
                    inRM <= 1'b1;
                end
            endcase
        end
    end
 //���ڴ�
    //���� read_req, addr_rcv, read_finish���ڹ�����sram�źš�
    wire read_req;        //�Ƿ���cache->mem�Ķ�����
    reg addr_rcv;         //��ַ���ճɹ�(addr_ok)�󵽽���
    wire read_finish;     //���ݽ��ճɹ�(data_ok)�������������
    always @(posedge clk) begin
        addr_rcv <= rst ? 1'b0 :
                    cache_data_req & read & cache_data_addr_ok ? 1'b1 : //��ַ���ճɹ�
                    read_finish ? 1'b0 : 
                    addr_rcv;
    end
    assign read_req = state==RM;
    assign read_finish = read & cache_data_data_ok;   //���ݷ������

    //д�ڴ�
    wire write_req;    //�Ƿ���cache->mem��д����
    reg waddr_rcv;      
    wire write_finish;  
    always @(posedge clk) begin
        waddr_rcv <= rst ? 1'b0 :
                     cache_data_req& write & cache_data_addr_ok ? 1'b1 :  //��ַ�����ݽ��ճɹ�
                     write_finish ? 1'b0 :
                     waddr_rcv;
    end
    assign write_req = state==WM;
    assign write_finish = write & cache_data_data_ok;      //����д�����

    //cache->cpu
    assign cpu_data_rdata   = hit ? c_block : cache_data_rdata;  //cache->cpu�������ݣ�������������cache�����ݿ飬�����д������ж�
    assign cpu_data_addr_ok = cpu_data_req & hit | cache_data_req & cache_data_addr_ok;
    assign cpu_data_data_ok = cpu_data_req & hit | cache_data_data_ok;

    // cache->mem
    assign cache_data_req   = read_req & ~addr_rcv | write_req & ~waddr_rcv; //�������ҵ�ַ�������ݣ�δ��mem����
    assign cache_data_wr    = write_req;  //ֻҪ����WM״̬��һֱ��д����
    assign cache_data_size  = cpu_data_size;
    assign cache_data_addr  = cache_data_wr ? {c_tag, index, offset}:  //д�ڴ棬д��mem�ĵ�ַΪԭcache line��Ӧ�ĵ�ַ
                                              cpu_data_addr;           //���ڴ棬��Ӧmem�ĵ�ַΪcpu_data_addr
    assign cache_data_wdata = c_block;    //д��mem��������ԭ��cache line������

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
    //new_data = old_data & ~mask | write_data & mask �����ݲ����»�д��ȥ������
    assign write_cache_data = cache_block[index] & ~{{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}} | 
                              cpu_data_wdata & {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};

    
    
    integer t;
    wire isIDLE;  //дcacheʱ������write������񣬶�Ҫ�ص�IDLE״̬����д��
    assign isIDLE = state==IDLE;
    always @(posedge clk) begin
        if(rst) begin
            for(t=0; t<CACHE_DEEPTH; t=t+1) begin   //�տ�ʼ��Cache��Ϊ��Ч //* dirty Ϊ 0
                cache_valid[t] <= 0;
                cache_dirty[t] <= 0;
            end
        end
        else begin
            if(read_finish) begin //��������ɺ�
                cache_valid[index_save] <= 1'b1;             //��Cache line��Ϊ��Ч
                cache_dirty[index_save] <= 1'b0;            // ��ȡ�ڴ�����ݺ�һ����clean��δ���޸ĵ�
                cache_tag  [index_save] <= tag_save;
                cache_block[index_save] <= cache_data_rdata; //д��Cache line
            end
            else if (write & isIDLE & (hit | inRM)) 
              begin 
                cache_dirty[index] <= 1'b1; // �޸ģ���1
                cache_block[index] <= write_cache_data;      //д��Cache line��ʹ��index������index_save
            end
        end
    end
endmodule