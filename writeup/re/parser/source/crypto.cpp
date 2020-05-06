//
// Created by Administrator on 2020/4/9.
//

#include "crypto.h"

void byte_xor(unsigned char* plain, const unsigned char* iv, unsigned int len) {
    for (int i = 0; i < len; ++i) {
        plain[i] ^= iv[i];
    }
}

std::string padding(std::string& str, unsigned long length) {
    std::string res(str);
    unsigned long pad = length - str.length() % length;
    res.append(pad, pad);
    return res;
}

std::string aes_encrypt(std::string& _plain, std::string& _key) {
    std::string plain = padding(_plain, 16);
    std::string k = padding(_key, 16);
    unsigned long length = plain.length();
    auto* key = (unsigned char*)malloc(16);
    auto* iv = (unsigned char*)malloc(16);
    auto* cipher = (unsigned char*)malloc(length);
    memcpy(cipher, plain.c_str(), length);
    memcpy(key, k.c_str(), 16);
    memcpy(iv, k.c_str(), 16);
    for (int i = 0; i < length; i+=16) {
        byte_xor(cipher+i, iv, 16);
        aes_encrypt_block(cipher + i, key);
        memcpy(iv, cipher+i, 16);
    }
    std::string res = std::string((char*)cipher, length);
    free(key);
    free(cipher);
    return res;
}


std::string des_encrypt(std::string& _plain, std::string& _key) {
    std::string plain = padding(_plain, 8);
    std::string k = padding(_key, 8);
    unsigned long length = plain.length();
    auto* key = (unsigned char*)malloc(8);
    auto* iv = (unsigned char*)malloc(8);
    auto* cipher = (unsigned char*)malloc(length);
    memcpy(cipher, plain.c_str(), length);
    memcpy(key, k.c_str(), 8);
    memcpy(iv, k.c_str(), 8);
    for (int i = 0; i < length; i+=8) {
        byte_xor(cipher+i, iv, 8);
        des_encrypt_block(cipher+i, key);
        memcpy(iv, cipher+i, 8);
    }
    std::string res = std::string((char*)cipher, length);
    free(key);
    free(cipher);
    return res;
}


std::string rc4_encrypt(std::string& _plain, std::string& _key) {
    unsigned long length = _plain.length();
    unsigned long key_length = _key.length();
    auto* key = (unsigned char*)malloc(key_length);
    auto* cipher = (unsigned char*)malloc(length);
    memcpy(cipher, _plain.c_str(), length);
    memcpy(key, _key.c_str(), key_length);
    rc4_encrypt_block(cipher, length, key, key_length);
    std::string res = std::string((char*)cipher, length);
    free(key);
    free(cipher);
    return res;
}
