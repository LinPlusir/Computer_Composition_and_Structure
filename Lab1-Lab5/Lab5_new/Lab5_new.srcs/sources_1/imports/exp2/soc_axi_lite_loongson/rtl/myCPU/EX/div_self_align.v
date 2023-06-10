//module:       div
//description:  self-align divider
//              ��������ԼΪ��3 + max{2*(a����Чλ��-b����Чλ��), 0}
//version:      1.4

/** log:
1.1: �����˴洢������߼� (����ͣM,W�׶�, ����ǰ�Ƶ������뷢���仯)
1.2: ������flush�߼������ڷ����쳣ʱֹͣ���������1.3: �ϲ���rst�У�
1.3: �ӿ�����axi�����߼�������"��ַ"����(opn_valid)����Ϊ�ǵ������֣�slave��ʱ��׼���ý������룩
1.4: rstʱ��һЩreg��0����ֹresult����xxx�����
*/

module div_self_align(
    input wire clk,
    input wire rst,
    input wire [31:0] a,    //divident
    input wire [31:0] b,    //divisor
    input wire sign,        //1:signed

    input wire opn_valid,   //master������׼����
    output reg res_valid,   //slave������׼����
    input wire res_ready,   //master���Խ��ռ�����
    output wire [63:0] result
    );
    /*
    ע���
    1. ��ȡ����ֵ��������������̡��ٸ��ݱ��������������ŶԽ������
    2. ��ʼ���SR��HWΪ������������1λ����RMEAINER�汻��������������SR��LW���̣����򣩣�REMAINER��������
    3. SR��HW��չ����33λ����ֹ�޷���������ʱ����ʼ������1λʱ�������λ��1Ĩȥ��
    */

    reg [31:0] a_save, b_save;

    reg [64:0] SR;          //shift register
    reg [31:0] REMAINER;    //divisor 2's complement
    wire [31:0] QUOTIENT;
    wire [32:0] DIVISOR;

    wire [31:0] divident_abs;
    wire [31:0] divisor_abs;
    wire [31:0] remainer, quotient;

    //FSM
    reg start;
    reg left_shift;
    reg [31:0] flag;        //���1��λ�ã��������ƶ�

    assign DIVISOR = SR[64:32];
    //����
    assign QUOTIENT = {SR[0],SR[1],SR[2],SR[3],SR[4],SR[5],SR[6],SR[7],SR[8],SR[9],SR[10],SR[11],SR[12],SR[13],SR[14],SR[15],SR[16],SR[17],SR[18],SR[19],SR[20],SR[21],SR[22],SR[23],SR[24],SR[25],SR[26],SR[27],SR[28],SR[29],SR[30],SR[31]};

    assign divident_abs = (sign & a[31]) ? ~a + 1'b1 : a;
    assign divisor_abs = (sign & b[31]) ? ~b + 1'b1 : b;
    //���������뱻������ͬ
    assign remainer = (sign & a_save[31]) ? ~REMAINER + 1'b1 : REMAINER;
    assign quotient = sign & (a_save[31] ^ b_save[31]) ? ~QUOTIENT + 1'b1 : QUOTIENT;
    assign result = {remainer,quotient};

    wire CO;
    wire [32:0] sub_result;
    wire [31:0] mux_result;
    //sub
    // wire [32:0] NEG_DIVISOR;
    // assign NEG_DIVISOR = ~DIVISOR + 1'b1;
    // assign {CO,sub_result} = {1'b0,REMAINER} + NEG_DIVISOR; //��Ҫ�Ż�����֪��vivado�᲻���Լ��Ż�
    adderN #(33) ADDER(
        1'b1,~DIVISOR,{1'b0,REMAINER},
        sub_result,CO
    );
    //mux
    assign mux_result = ~left_shift & CO ? sub_result[31:0] : REMAINER; //������COΪ1ʱ��������

    //state machine
    always @(posedge clk) begin
        if(rst) begin
            SR <= 0;
            REMAINER <= 0;
            a_save <= 0;
            b_save <= 0;

            start <= 1'b0;
            left_shift <= 1'b1;
        end
        else if(~start & opn_valid & ~res_valid) begin
            start <= 1'b1;
            left_shift <= 1'b1;

            //save a,b
            a_save <= a;
            b_save <= b;

            //Initial register
            REMAINER <= divident_abs;
            SR[64:32] <= {divisor_abs[31:0],1'b0};  //��ʼ������һ��
            flag <= 32'h0000_0002;
            SR[31:0] <= 32'b0;
        end
        else if(start) begin
            if(left_shift & CO) begin
                SR <= {SR[63:0],1'b0};
                flag <= {flag[30:0],1'b0};
            end
            if(left_shift & ~CO) begin
                left_shift <= 1'b0;
                SR <= {1'b0,SR[64:1]};
                flag <= {1'b0,flag[31:1]};
            end
            else if(~left_shift) begin
                if(flag[0]) begin
                   //end
                    REMAINER <= mux_result;
                    SR[31] <= CO;

                    start <= 1'b0;
                end
                else begin
                    REMAINER <= mux_result;
                    SR <= {1'b0,SR[64:32],CO,SR[30:1]};
                    flag <= {1'b0,flag[31:1]};
                end
            end
        end
    end

    wire data_go;
    assign data_go = res_valid & res_ready;
    always @(posedge clk) begin
        res_valid <= rst     ? 1'b0 :
                     start & ~left_shift & flag[0] ? 1'b1 :
                     data_go ? 1'b0 : res_valid;
    end
endmodule

module full_adder(
    input Cin,x,y,
    output s,Cout
    );

    assign s  = x ^ y ^ Cin;
    assign Cout = (x & y) | (x & Cin) | (y & Cin);
endmodule

module adderN
    #(N = 32)(
    input carryin,
    input [N-1:0] x,y,
    output [N-1:0] s,
    output carryout
    );

    wire [N:0] c;

    assign c[0] = carryin;
    assign carryout = c[N];

    genvar i;
    generate
        for(i=0;i<N;i=i+1)
            full_adder stage(c[i],x[i],y[i],s[i],c[i+1]);
    endgenerate
endmodule