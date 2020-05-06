//
// Created by Administrator on 2020/4/7.
//

#include "lexer.h"

std::vector<Token> Lexer::parse_line(std::string &str) {
    std::vector<Token> tokens;
    int idx = 0;
    while(idx < str.length()) {
        if (str[idx] == '\n') {
            Token token;
            token.type = CR;
            token.str = std::string("\n");
            tokens.push_back(token);
            idx++;
            continue;
        }
        if (str[idx] == '+') {
            Token token;
            token.type = ADD;
            token.str = std::string("+");
            tokens.push_back(token);
            idx++;
            continue;
        }
        if (str[idx] == '_') {
            Token token;
            token.type = UL;
            token.str = std::string("_");
            tokens.push_back(token);
            idx++;
            continue;
        }
//        if (str[idx] == '(') {
//            Token token;
//            token.type = LP;
//            token.str = std::string("(");
//            tokens.push_back(token);
//            idx++;
//            continue;
//        }
//        if (str[idx] == ')') {
//            Token token;
//            token.type = RP;
//            token.str = std::string(")");
//            tokens.push_back(token);
//            idx++;
//            continue;
//        }
        if (str[idx] == '{') {
            Token token;
            token.type = LB;
            token.str = std::string("{");
            tokens.push_back(token);
            idx++;
            continue;
        }
        if (str[idx] == '}') {
            Token token;
            token.type = RB;
            token.str = std::string("}");
            tokens.push_back(token);
            idx++;
            continue;
        }
        if (isalnum(str[idx])) {
            std::string tmp_str;
            for (int i = 0; ; ++i) {
                if (isalnum(str[idx+i])) {
                    tmp_str.append(str.substr(idx + i, 1));
                } else
                    break;
            }
            Token token;
            if (tmp_str=="De1CTF") {
                token.type = DE1CTF;
                token.str = std::string("De1CTF");
            }
            else {
                token.type = STR;
                token.str = std::string(tmp_str);            }
            tokens.push_back(token);
            idx+=tmp_str.length();
        }
        else
            throw std::logic_error("Syntax error.");
    }
    return tokens;
}
