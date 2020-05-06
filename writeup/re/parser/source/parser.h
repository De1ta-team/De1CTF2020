//
// Created by Administrator on 2020/4/7.
//

#ifndef PARSEME_PARSER_H
#define PARSEME_PARSER_H

#include <vector>
#include <iostream>
#include <stdexcept>
#include "token.h"
#include "crypto.h"
class Parser {
    std::vector<Token> tokens;
public:
    Parser() = default;
    explicit Parser(std::vector<Token> tokens): tokens(std::move(tokens)) {}
    std::string parse();

private:
    Token De1CTF;
    void pass_front(TokenKind kind);
    std::string parse_line();
    std::string parse_expr();
    std::string parse_term();
    std::string parse_primary_str();
};


#endif //PARSEME_PARSER_H
