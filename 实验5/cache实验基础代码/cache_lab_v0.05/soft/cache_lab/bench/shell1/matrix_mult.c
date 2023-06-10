#define N 16
#define BLOCKSIZE 4
#include <machine.h>

void do_block(int n, int si, int sj, int sk, int *A, int *B, int *C)
{
    int i, j, k;
    int cij;
    for (i = si; i < si + BLOCKSIZE; i++){
        for (j = sj; j < sj + BLOCKSIZE; j++){
            cij = C[i * n + j];     //cij = C[i][j]
            for(k=sk; k < sk + BLOCKSIZE; k++){
                cij += A[i * n + k] * B[k * n + j];     //A[i][k] * B[k][j]
            }
            C[i * n + j] = cij;
        }
    }
}

void dgemm(int n, int *A, int *B, int *C)
{
    int si, sj, sk;
    for (sj = 0; sj < n; sj += BLOCKSIZE)
        for (si = 0; si < n; si += BLOCKSIZE)
            for (sk = 0; sk < n; sk += BLOCKSIZE)
                do_block(n, si, sj, sk, A, B, C);
}

A_array [16 * 16] = {
1, 11, 11, 12, 13, 2, 7, 6, 13, 13, 15, 6, 5, 10, 11, 4, \
12, 7, 8, 13, 13, 0, 1, 3, 7, 2, 9, 2, 0, 14, 8, 10, \
5, 14, 13, 1, 8, 10, 3, 7, 3, 3, 14, 3, 2, 0, 10, 8, \
8, 13, 2, 9, 5, 7, 8, 12, 5, 15, 9, 11, 2, 3, 15, 11, \
15, 7, 4, 11, 9, 11, 6, 8, 10, 11, 6, 1, 13, 9, 15, 6, \
4, 0, 7, 1, 7, 1, 2, 15, 12, 3, 6, 10, 14, 0, 2, 4, \
10, 9, 14, 13, 15, 8, 7, 3, 5, 2, 12, 10, 14, 7, 6, 11, \
4, 1, 12, 15, 9, 0, 0, 3, 7, 10, 5, 9, 10, 13, 2, 14, \
13, 8, 3, 12, 12, 6, 2, 4, 10, 2, 0, 7, 4, 0, 0, 15, \
12, 7, 14, 13, 5, 9, 9, 3, 0, 2, 11, 13, 9, 14, 4, 4, \
0, 10, 13, 1, 5, 2, 12, 3, 11, 8, 8, 5, 13, 13, 6, 0, \
12, 0, 1, 13, 12, 7, 11, 11, 15, 14, 13, 7, 12, 11, 15, 5, \
7, 2, 5, 1, 1, 6, 1, 3, 1, 11, 10, 6, 11, 9, 0, 2, \
13, 11, 14, 4, 6, 1, 15, 9, 7, 15, 4, 8, 0, 12, 7, 10, \
13, 15, 2, 8, 11, 2, 10, 10, 6, 14, 4, 11, 12, 15, 14, 6, \
6, 9, 2, 15, 6, 15, 8, 11, 15, 6, 3, 14, 1, 13, 2, 13 \
};
B_array [16 * 16] = {
7, 15, 6, 8, 0, 6, 1, 13, 14, 8, 3, 2, 1, 5, 11, 13, \
5, 14, 5, 7, 2, 11, 7, 9, 0, 10, 13, 0, 8, 4, 3, 3, \
2, 4, 10, 6, 8, 1, 3, 14, 6, 10, 4, 4, 7, 5, 0, 15, \
7, 11, 7, 0, 12, 15, 10, 7, 10, 6, 4, 10, 4, 3, 4, 12, \
10, 12, 3, 7, 8, 0, 13, 8, 5, 5, 12, 14, 3, 14, 3, 13, \
7, 10, 15, 10, 10, 8, 6, 4, 6, 5, 7, 5, 3, 10, 10, 10, \
6, 3, 1, 8, 7, 13, 3, 4, 8, 6, 4, 8, 0, 13, 15, 7, \
5, 15, 4, 12, 10, 9, 6, 10, 2, 11, 14, 7, 4, 5, 3, 2, \
13, 3, 10, 3, 8, 13, 5, 7, 6, 15, 10, 0, 10, 13, 5, 15, \
5, 10, 1, 12, 12, 3, 6, 3, 15, 13, 15, 1, 14, 13, 7, 12, \
14, 3, 10, 14, 3, 4, 7, 2, 12, 7, 2, 6, 13, 9, 9, 12, \
9, 2, 7, 1, 1, 6, 11, 5, 7, 14, 7, 12, 5, 13, 10, 0, \
5, 8, 12, 12, 13, 1, 6, 1, 5, 9, 2, 12, 9, 3, 8, 11, \
7, 5, 3, 3, 12, 8, 14, 14, 13, 1, 0, 11, 13, 8, 9, 8, \
15, 12, 4, 3, 4, 6, 8, 10, 13, 0, 1, 3, 1, 2, 0, 13, \
12, 4, 13, 1, 15, 0, 11, 3, 12, 8, 3, 11, 13, 9, 2, 12 \
};
C_ref_array [16 * 16] = {
1190, 1096, 876, 928, 1087, 934, 1085, 1007, 1186, 1123, 950, 878, 1058, 1167, 763, 1462, \
960, 935, 710, 577, 834, 697, 907, 949, 1025, 744, 583, 765, 772, 819, 564, 1208, \
874, 899, 804, 786, 690, 578, 711, 765, 784, 807, 691, 572, 695, 776, 515, 1050, \
1148, 1212, 840, 901, 981, 924, 992, 912, 1185, 1104, 968, 791, 893, 1076, 790, 1232, \
1171, 1329, 971, 991, 1140, 942, 994, 1038, 1272, 1043, 860, 866, 899, 1045, 869, 1529, \
706, 680, 680, 673, 708, 490, 602, 576, 598, 884, 642, 647, 611, 728, 509, 830, \
1171, 1155, 1118, 939, 1130, 835, 1109, 1028, 1184, 1124, 802, 1111, 963, 1129, 872, 1516, \
898, 819, 835, 609, 1084, 620, 973, 824, 1057, 941, 640, 924, 958, 917, 608, 1231, \
818, 877, 770, 510, 782, 641, 748, 695, 779, 862, 685, 699, 610, 816, 549, 1018, \
952, 984, 930, 819, 936, 847, 955, 998, 1119, 953, 613, 960, 827, 966, 903, 1234, \
820, 752, 708, 794, 872, 719, 772, 802, 856, 901, 663, 692, 851, 908, 712, 1094, \
1399, 1328, 1014, 1105, 1274, 1087, 1170, 1078, 1479, 1221, 972, 1067, 1053, 1324, 1053, 1676, \
553, 580, 563, 653, 618, 377, 537, 485, 722, 642, 436, 513, 661, 620, 579, 754, \
1007, 1094, 760, 877, 1013, 895, 930, 1104, 1218, 1134, 915, 792, 937, 1151, 856, 1311, \
1210, 1388, 856, 1008, 1141, 1019, 1172, 1151, 1321, 1182, 1011, 1015, 1016, 1190, 970, 1405, \
1139, 1091, 1013, 754, 1165, 1111, 1116, 983, 1122, 1168, 953, 966, 951, 1224, 909, 1251 \
};
C_array [16 * 16];

int matrix_mult()
{
    enable_trace_cmp;          //打开trace比对

    dgemm(N, A_array, B_array, C_array);

    disable_trace_cmp;         //关闭trace比对，且不再打开

    int i, j;
    for(i=0; i<N; i++){
        for(j=0; j<N; j++){
            if(C_array[i * N + j]!=C_ref_array[i * N + j]){
                printf("Error C and C_ref not equal\n");
                return -1;
            }
        }
    }

    printf("dgemm PASS!\n");
    return 0;
}