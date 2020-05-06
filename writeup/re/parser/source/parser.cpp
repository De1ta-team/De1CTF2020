//
// Created by Administrator on 2020/4/7.
//
#include "parser.h"

std::string Parser::parse() {
    return parse_line();
}

std::string Parser::parse_line() {
    std::string res;
    De1CTF = tokens.front();
    pass_front(DE1CTF);
    pass_front(LB);
    res = parse_expr();
    pass_front(RB);
    pass_front(CR);
    return res;
}

std::string Parser::parse_expr() {
    std::string left = parse_term();
    while(true) {
        if (tokens.front().type != ADD)
            break;
        tokens.erase(tokens.begin());
        std::string right = parse_term();
        left += right;
        left = aes_encrypt(left, De1CTF.str);
//        left += aes_encrypt(right, De1CTF.str);
    }
    return left;
}

void Parser::pass_front(TokenKind kind) {
    if (tokens.front().type!=kind)
        throw std::logic_error("Syntax error.");
    tokens.erase(tokens.begin());
}

std::string Parser::parse_term() {
    std::string left = parse_primary_str();
    while (true) {
        if (tokens.front().type!=UL)
            break;
        tokens.erase(tokens.begin());
        std::string right = parse_term();
        left += right;
        left = des_encrypt(left, De1CTF.str);
    }
    return left;
}

std::string Parser::parse_primary_str() {
    Token token = tokens.front();
    tokens.erase(tokens.begin());
    if (token.type == STR)
        return rc4_encrypt(token.str, De1CTF.str);
//    else if(token.type == LP) {
//        std::string res = parse_expr();
//        pass_front(RP);
//        res = rc4_encrypt(res, De1CTF.str);
//        return res;
//    }

    throw std::logic_error("Syntax error.");
}

