#include <iostream>
#include "lexer.h"
#include "parser.h"

const char cmp_c[] = {-25, -92, 51, 76, -45, 17, -25, -123, 104, 86, -105, 17, -18, -46, -8, -39, 62, 112, -55, 78, -108, -96, 50, 90, 39, -104, 0, 29, -43, -41, 17, 29, -12, -123, 97, -84, 12, -128, 39, 64, -67, -35, 31, 11, -76, -105, 31, 96, 91, 84, -53, -59, -88, -73, 17, -112, -55, -75, -127, 101, 83, 15, 126, 127};

int main() {
    std::string input;
    std::string cmp(cmp_c, 64);
    while (true) {
        std::cout << "Give me an expression: ";
        std::cin >> input;
        input.append("\n");
        try {

            std::vector<Token> tokens = Lexer::parse_line(input);
            Parser parser = Parser(tokens);
            std::string res = parser.parse();
            if (res==cmp) {
                std::cout << "Right!" << std::endl;
                break;
            }
            else {
                std::cout << "Wrong." << std::endl;
            }
        } catch (std::exception& e) {
            std::cerr << e.what() << std::endl;
        }
    }
    return 0;
}
