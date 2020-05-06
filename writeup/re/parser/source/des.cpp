//
// Created by Administrator on 2020/4/9.
//

#include "des.h"

unsigned char K_IP[56] = {
        57, 49, 41, 33, 25, 17, 9, 1,
        58, 50, 42, 34, 26, 18, 10, 2,
        59, 51, 43, 35, 27, 19, 11, 3,
        60, 52, 44, 36, 63, 55, 47, 39,
        31, 23, 15, 7, 62, 54, 46, 38,
        30, 22, 14, 6, 61, 53, 45, 37,
        29, 21, 13, 5, 28, 20, 12, 4};

unsigned char SHIFT[16] = {1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1};

unsigned char CP[48] = {14, 17, 11, 24, 1, 5, 3, 28,
                        15, 6, 21, 10, 23, 19, 12, 4,
                        26, 8, 16, 7, 27, 20, 13, 2,
                        41, 52, 31, 37, 47, 55, 30, 40,
                        51, 45, 33, 48, 44, 49, 39, 56,
                        34, 53, 46, 42, 50, 36, 29, 32};

unsigned char IP[64] = {58, 50, 42, 34, 26, 18, 10, 2,
                        60, 52, 44, 36, 28, 20, 12, 4,
                        62, 54, 46, 38, 30, 22, 14, 6,
                        64, 56, 48, 40, 32, 24, 16, 8,
                        57, 49, 41, 33, 25, 17, 9, 1,
                        59, 51, 43, 35, 27, 19, 11, 3,
                        61, 53, 45, 37, 29, 21, 13, 5,
                        63, 55, 47, 39, 31, 23, 15, 7};

unsigned char EP[48] = {32, 1, 2, 3, 4, 5,
                        4, 5, 6, 7, 8, 9,
                        8, 9, 10, 11, 12, 13,
                        12, 13, 14, 15, 16, 17,
                        16, 17, 18, 19, 20, 21,
                        20, 21, 22, 23, 24, 25,
                        24, 25, 26, 27, 28, 29,
                        28, 29, 30, 31, 32, 1};

unsigned char S_BOX[8][4][16] = {

        {
                {14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7},
                {0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8},
                {4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0},
                {15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13},
        },

        {
                {15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10},
                {3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5},
                {0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15},
                {13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9},
        },

        {
                {10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8},
                {13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1},
                {13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7},
                {1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12},
        },

        {
                {7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15},
                {13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9},
                {10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4},
                {3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14},
        },

        {
                {2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9},
                {14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6},
                {4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14},
                {11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3},
        },

        {
                {12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11},
                {10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8},
                {9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6},
                {4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13},
        },

        {
                {4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1},
                {13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6},
                {1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2},
                {6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12},
        },

        {
                {13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7},
                {1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2},
                {7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8},
                {2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11},
        }
};

unsigned char P_BOX[32] = {16, 7, 20, 21, 29, 12, 28, 17,
                           1, 15, 23, 26, 5, 18, 31, 10,
                           2, 8, 24, 14, 32, 27, 3, 9,
                           19, 13, 30, 6, 22, 11, 4, 25};

unsigned char FP[64] = {40, 8, 48, 16, 56, 24, 64, 32,
                        39, 7, 47, 15, 55, 23, 63, 31,
                        38, 6, 46, 14, 54, 22, 62, 30,
                        37, 5, 45, 13, 53, 21, 61, 29,
                        36, 4, 44, 12, 52, 20, 60, 28,
                        35, 3, 43, 11, 51, 19, 59, 27,
                        34, 2, 42, 10, 50, 18, 58, 26,
                        33, 1, 41, 9, 49, 17, 57, 25};

void byte_to_bit(unsigned char ch, unsigned char bit[8]) {
    for (unsigned int i = 0; i < 8; ++i) {
        bit[i] = (unsigned char)(ch >> (7-i)) & 1u;
    }
}

unsigned int bit_to_byte(const unsigned char bit[8]) {
    unsigned char res = 0;
    for (unsigned int i = 0; i < 8; ++i) {
        res <<= 1u;
        res |= (unsigned char)(bit[i]);
    }
    return res;
}

void bits28_shift_left(unsigned char *bits, int n) {
    unsigned char res[28];
    for (int i = 0; i < 28; ++i) {
        res[i] = bits[(i + n) % 28];
    }
    memcpy(bits, res, 28);
}

void bits_xor(unsigned char* a, const unsigned char* b, int length) {
    for (int i = 0; i < length; ++i) {
        a[i] = a[i] ^ b[i];
    }
}

void permute(unsigned char* a, const unsigned char* table, int length) {
    auto* res = (unsigned char*)malloc(length);
    for (int i = 0; i < length; ++i) {
        res[i] = a[table[i]-1];
    }
    memcpy(a, res, length);
    free(res);
}

unsigned char* des_key_extend(unsigned char* key) {
    auto* res = (unsigned char*)malloc(16 * 48);
    unsigned char key_bits[64];
    for (int i = 0; i < 8; ++i) {
        byte_to_bit(key[i], &key_bits[i*8]);
    }
    permute(key_bits, K_IP, 56);
    for (int j = 0; j < 16; ++j) {
        bits28_shift_left(key_bits, SHIFT[j]);
        bits28_shift_left(key_bits + 28, SHIFT[j]);
        unsigned char tmp[56] = {0};
        memcpy(tmp, key_bits, 56);
        permute(tmp, CP, 48);
        memcpy(res + (48*j), tmp, 48);
    }
    return res;
}

void s_replace(unsigned char out[4], const unsigned char in[6], unsigned char s_box[4][16]) {
    unsigned int x = (in[0] << 1u) + in[5];
    unsigned int y = (in[1] << 3u) + (in[2] << 2u) + (in[3] << 1u) + in[4];
    unsigned char tmp = s_box[x][y];
    for (int i = 0; i < 4; ++i) {
        out[i] = (unsigned char)(tmp >> (3u - i)) & 1u;
    }
}

void s_box_replace(unsigned char input[48]) {
    unsigned char tmp[32];
    for (int i = 0; i < 8; ++i) {
        s_replace(tmp + 4*i, input + 6*i, S_BOX[i]);
    }
    memcpy(input, tmp, 32);
}

void func(unsigned char* r, unsigned char* child_key) {
    unsigned char tmp[48];
    memcpy(tmp, r, 32);
    permute(tmp, EP, 48);
    bits_xor(tmp, child_key, 48);
    s_box_replace(tmp);
    permute(tmp, P_BOX, 32);
    memcpy(r, tmp, 32);
}

void des_encrypt_block(unsigned char plain[8], unsigned char* key) {
    unsigned char* sub_key = des_key_extend(key);
    unsigned char plain_bits[64];
    for (int i = 0; i < 8; ++i) {
        byte_to_bit(plain[i], &plain_bits[i*8]);
    }
    permute(plain_bits, IP, 64);
    unsigned char tmp_plain[64];
    memcpy(tmp_plain, plain_bits, 64);
    unsigned char* left = tmp_plain;
    unsigned char* right = tmp_plain+32;
    for (int i = 0; i < 16; ++i) {
        unsigned char tmp[32];
        memcpy(tmp, right, 32);
        func(tmp, &sub_key[i*48]);
        bits_xor(tmp, left, 32);
        memcpy(left, right, 32);
        memcpy(right, tmp, 32);
    }
    memcpy(plain_bits+32, left, 32);
    memcpy(plain_bits, right, 32);
    permute(plain_bits, FP, 64);
    for (int j = 0; j < 8; ++j) {
        plain[j] = bit_to_byte(&plain_bits[j*8]);
    }
    free(sub_key);
}
