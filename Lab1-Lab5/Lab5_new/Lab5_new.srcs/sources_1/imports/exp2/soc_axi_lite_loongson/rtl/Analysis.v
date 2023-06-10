module Analysis (
    input wire clk, rst,

    input wire cpu_inst_req,
    input wire cpu_inst_data_ok,

    input wire cpu_data_req,
    input wire cpu_data_data_ok,
    input wire no_dcache
);
    wire [31:0] inst_req_total, data_req_total, i_cache_hit_count, d_cache_hit_count;

    judge judege_i_cache(
        .clk(clk), .rst(rst),
        .req(cpu_inst_req),
        .data_ok(cpu_inst_data_ok),

        .total(inst_req_total),
        .hit(i_cache_hit_count)
    );

    judge judege_d_cache(
        .clk(clk), .rst(rst),
        .req(cpu_data_req & ~no_dcache),
        .data_ok(cpu_data_data_ok),

        .total(data_req_total),
        .hit(d_cache_hit_count)
    );
endmodule

module judge #(parameter LIMIT = 3)(
    input wire clk, rst,
    input wire req,
    input wire data_ok,

    output reg [31:0] total, //��������
    output reg [31:0] hit    //��������
);
    //Mealy��״̬�����ͱ��йأ�
    reg state;
    always @(posedge clk) begin
        if(rst) begin
            state <= 1'b0;
        end
        else begin
            case(state)
                1'b0: state <= req & data_ok ? 1'b0 :   //������� 0->0(req & data_ok)
                               req ? 1'b1 : state;
                1'b1: state <= data_ok ? 1'b0 : state;
            endcase
        end
    end

    reg [6:0] cnt; //���������Ҫ�����ڡ�3��������������󣬼��϶�����
    always @(posedge clk) begin
        if(rst) begin
            total <= 0;
            hit <= 0;
            cnt <= 0;
        end
        else begin
            case(state)
                1'b0: begin
                    if(req & data_ok) begin   //������� 0->0(req & data_ok)
                        total <= total + 1;
                        hit <= hit + 1;
                    end
                    else if(req) begin //0->1
                        total <= total + 1; //�������1
                        cnt <= 0;           //��ʼ���������������
                    end
                end
                1'b1: begin
                    if(data_ok) begin  //1->0
                        if(cnt < LIMIT) begin
                            hit <= hit + 1; //�����м�1
                        end
                    end
                    else begin //keep 1
                        cnt <= cnt + 1; //����������ڼ�1
                    end
                end
            endcase
        end
    end

endmodule