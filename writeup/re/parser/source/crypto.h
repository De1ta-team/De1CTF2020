//
// Created by Administrator on 2020/4/7.
//

#ifndef PARSEME_CRYPTO_H
#define PARSEME_CRYPTO_H

#include <string>
#include "aes.h"
#include "des.h"
#include "rc4.h"

std::string aes_encrypt(std::string& _plain, std::string& _key);
std::string des_encrypt(std::string& _plain, std::string& _key);
std::string rc4_encrypt(std::string& _plain, std::string& _key);
#endif //PARSEME_CRYPTO_H
