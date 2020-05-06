//
// Created by Administrator on 2020/4/7.
//

#ifndef PARSEME_LEXER_H
#define PARSEME_LEXER_H

#include <vector>
#include <iostream>
#include <stdexcept>
#include "token.h"
class Lexer {
public:
    static std::vector<Token> parse_line(std::string &str);
};



#endif //PARSEME_LEXER_H
