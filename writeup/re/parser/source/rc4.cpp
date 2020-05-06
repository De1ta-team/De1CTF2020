//
// Created by Administrator on 2020/4/9.
//

#include "rc4.h"

unsigned char s_box[256];

void swap(unsigned char*a, unsigned char*b) {
    unsigned char tmp = *a;
    *a = *b;
    *b = tmp;
}

void init_s_box(const unsigned char* key, unsigned int len) {
    for (int i = 0; i < 256; ++i)
        s_box[i] = i;
    int j = 0;
    for (int i = 0; i < 256; ++i) {
        j = (j + s_box[i] + key[i%len]) % 256;
        swap(&s_box[i], &s_box[j]);
    }
}

void rc4_encrypt_block(unsigned char* plain, unsigned int plain_len, const unsigned char* key, unsigned int key_len) {
    init_s_box(key, key_len);
    int i = 0, j = 0;
    for (int k = 0; k < plain_len; ++k) {
        i = (i + 1) % 256;
        j = (j + s_box[i]) % 256;
        swap(&s_box[i], &s_box[j]);
        plain[k] ^= s_box[(s_box[i] + s_box[j]) % 256];
    }
}