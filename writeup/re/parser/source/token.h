//
// Created by Administrator on 2020/4/7.
//

#ifndef PARSEME_TOKEN_H
#define PARSEME_TOKEN_H

#include <string>

enum TokenKind {
    BAD,
    DE1CTF,
    LB,
    RB,
    STR,
    ADD,
    UL,
    LP,
    RP,
    CR
};

struct Token {
    TokenKind type;
    std::string str;
};

#endif //PARSEME_TOKEN_H
