//
// Created by Administrator on 2020/4/9.
//

#include "aes.h"

#define ROL(a, n) (((a << n) | (a >> (8-n))) & 0xffu)


unsigned char affine_trans(unsigned char a) {
    unsigned int tmp = a;
    tmp = tmp ^ ROL(tmp, 1u) ^ ROL(tmp, 2u) ^ ROL(tmp, 3u) ^ ROL(tmp, 4u) ^ 0x63u;
    return (tmp);
}

unsigned int poly_mul(unsigned int a, unsigned int b) {
    unsigned int res = 0;
    for (int i = 0; i < 9; ++i) {
        if (b&1u)
            res ^= a;
        b>>=1u;
        a<<=1u;
    }
    return res;
}

int get_highest_bit(unsigned int a) {
    int i = 0;
    while(a) {
        i+=1;
        a >>= 1u;
    }
    return i;
}

unsigned int poly_div(unsigned int dividend, unsigned int divisor) {
    unsigned int r = 0, q = 0;
    unsigned int delta_bit = 0;
    r = dividend;
    delta_bit = get_highest_bit(r) - get_highest_bit(divisor);
    while (delta_bit <= 0x7fffffff) {
        q |= 1u << (unsigned int)delta_bit;
        r ^= (divisor << (unsigned int)delta_bit);
        delta_bit = get_highest_bit(r) - get_highest_bit(divisor);
    }
    return q;
}

unsigned int poly_mod(unsigned int dividend, unsigned int divisor) {
    unsigned int r = 0, q = 0;
    unsigned int delta_bit = 0;
    r = dividend;
    delta_bit = get_highest_bit(r) - get_highest_bit(divisor);
    while (delta_bit <= 0x7fffffff) {
        q |= 1u << (unsigned int)delta_bit;
        r ^= (divisor << (unsigned int)delta_bit);
        delta_bit = get_highest_bit(r) - get_highest_bit(divisor);
    }
    return r;
}

unsigned int poly_ext_euc(unsigned int a, unsigned int m) {
    unsigned int old_s=1, s=0,
    old_t = 0, t = 1, old_r = m, r = a;
    unsigned int q;
    unsigned int tmp;
    if (a == 0)
        return 0;
    else {
        while(r != 0) {
            q = poly_div(old_r, r);
            tmp = r;
            r = old_r ^ poly_mul(q, r);
            old_r = tmp;
            tmp = s;
            s = old_s ^ poly_mul(q, s);
            old_s = tmp;
            tmp = t;
            t = old_t ^ poly_mul(q, t);
            old_t = tmp;
        }
    }
    return old_t;
}

unsigned char s_box_trans(unsigned char a) {
    unsigned char tmp = poly_ext_euc(a, 0x11B) & 0xffu;
    return affine_trans(tmp);
}



void T(unsigned char* w) {
    unsigned char tmp = w[0];
    w[0] = s_box_trans(w[1]);
    w[1] = s_box_trans(w[2]);
    w[2] = s_box_trans(w[3]);
    w[3] = s_box_trans(tmp);
}

void word_xor(unsigned char* a, const unsigned char* b) {
    *(unsigned int*)a ^= *(unsigned int*)b;
}

unsigned char* aes_key_extend(unsigned char* key) {
    auto* res = (unsigned char*)malloc(16 * 11);
    memcpy(res, key, 16);
    for (int i = 4; i < 44; ++i) {
        unsigned char a[4];
        memcpy(a, res + (i - 4) * 4, 4);
        unsigned char b[4];
        memcpy(b, res + (i - 1) * 4, 4);
        if (i % 4 == 0) {
            unsigned int tmp = ((i/4)-1);
            unsigned int d = 1u << tmp;
            tmp = poly_div(d, 0x11B);
            tmp = d ^ poly_mul(tmp, 0x11B);
            T(b);
            *(unsigned int*)b ^= tmp;
        }
        word_xor(a, b);
        memcpy(res+i*4, a, 4);
    }
    return res;
}

void add_round_key(unsigned char*a, const unsigned char* b) {
    *(unsigned long long *)a ^= *(unsigned long long*)b;
    ((unsigned long long *)a)[1] ^= ((unsigned long long*)b)[1];
}

void sub_byte(unsigned char* a) {
    for (int i = 0; i < 16; ++i) {
        a[i] = s_box_trans(a[i]);
    }
}

void shift_row(unsigned char* a) {
    unsigned char tmp;
    tmp = a[1];
    a[1] = a[5];
    a[5] = a[9];
    a[9] = a[13];
    a[13] = tmp;

    tmp = a[2];
    a[2] = a[10];
    a[10] = tmp;

    tmp = a[6];
    a[6] = a[14];
    a[14] = tmp;

    tmp = a[3];
    a[3] = a[15];
    a[15] = a[11];
    a[11] = a[7];
    a[7] = tmp;
}

void mix_col(unsigned char *a) {
    unsigned int tmp[4] = {0};
    for (int i = 0; i < 4; ++i) {
        tmp[0] = poly_mul(2, a[i*4+0]) ^ poly_mul(3, a[i*4+1]) ^ poly_mul(1, a[i*4+2]) ^ poly_mul(1, a[i*4+3]);
        tmp[0] = poly_mod(tmp[0], 0x11B);

        tmp[1] = poly_mul(1, a[i*4+0]) ^ poly_mul(2, a[i*4+1]) ^ poly_mul(3, a[i*4+2]) ^ poly_mul(1, a[i*4+3]);
        tmp[1] = poly_mod(tmp[1], 0x11B);

        tmp[2] = poly_mul(1, a[i*4+0]) ^ poly_mul(1, a[i*4+1]) ^ poly_mul(2, a[i*4+2]) ^ poly_mul(3, a[i*4+3]);
        tmp[2] = poly_mod(tmp[2], 0x11B);

        tmp[3] = poly_mul(3, a[i*4+0]) ^ poly_mul(1, a[i*4+1]) ^ poly_mul(1, a[i*4+2]) ^ poly_mul(2, a[i*4+3]);
        tmp[3] = poly_mod(tmp[3], 0x11B);

        a[i*4+0] = tmp[0];
        a[i*4+1] = tmp[1];
        a[i*4+2] = tmp[2];
        a[i*4+3] = tmp[3];
    }
}

void aes_encrypt_block(unsigned char* plain, unsigned char* key) {
    unsigned char* sub_key = aes_key_extend(key);
    add_round_key(plain, sub_key);
    for (int i = 1; i < 10; ++i) {
        sub_byte(plain);
        shift_row(plain);
        mix_col(plain);
        add_round_key(plain, sub_key+i*16);
    }
    sub_byte(plain);
    shift_row(plain);
    add_round_key(plain, sub_key+10*16);
    free(sub_key);
}