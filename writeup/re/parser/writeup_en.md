[中文](./writeup_zh.md) | En

## parser

### Idea

I'm studying compilation principles recently, so I make a very simple lexer and parser to parse flag.

Here is the grammar:

```
∑ ：
De1CTF	"De1CTF"
LB			"{"
RB			"}"
WORD		"[0-9a-zA-Z]+"
ADD			"+"
UL			"_"
LP			"("
RP			")"
CR			"\n"

N ：
FLAG, PRIM, EXP, TERM, WORD

P ：
FLAG -> De1CTF LB EXP RB CR
EXP ->  TERM
      | TERM ADD TERM
TERM -> PRIM  
		  | PRIM UL TERM
PRIM -> WORD

S : FLAG
```

Just like arithmetic.

First, the lexer will depart the string into tokens, and check the format.

All words will be encrypted with RC4

We need to define some notation:

"a+b" denotes AES_encrypt("ab")

"a_b" denotes DES_encrypt("ab")

“_" has higher priority than "+"

I didn't implement the brackets, because it may lead to multi-solution(you can add brackets infinitely), and it will also make the solver complex.

Compilation optimization is not enabled, because it's very difficult to reverse. I use g++ 9.0 to compile it, the endbr64 instruction will disturb IDA to identify got table, but you can find the function name by gdb. The symbol table has much useful information, so it is stripped.

### Reverse

I write this program in C++ and strip the symbol table, so it's a little difficult to analyze statically. 

At first, you can input some strings to test, and it's easy to confirm the format and structure.

I suggest guessing the logic of the program while debugging. Soon you can find out the input string will be departed into many parts at `sub_35F0`. It defines a structure Token here. The member contains substring and type. These token will store in an std::vector. 

Tracing the token into `sub_4E70` and  `sub_507E`, you can find some recursive functions and finally in `sub_51CC`, the type 4 token which means `WORD` will be encrypted by RC4.

We can trace the vector and final in `sub_507E` we find a loop. If next token is not `_` it will break. After getting a token `_`, get next `WORD`, splice them, and in `sub_70F6` encrypt it by DES. 

After return to`sub_4E70`, it does something similar. There is a loop and break condition is that the next token is not `+`. Then call `sub_507E` again to get another part of the result, and splice them and in `sub_6E8B` encrypt it by AES.

Here you almost reverse the program totally. The most important thing is the precedence of `+` and  `_`.

The aes and des use the same key `De1CTF` and will be padded to correct length. All the crypto cipher is the standard cipher. The implement of AES is a little different between normal AES, but the results are the same. (you will not find the SBOX of AES in the cipher).

### Solver

Notice that all the plain will be padded by PKCS7, so we could try to decrypt and find the padding.

After get the cipher, consider it is like "A+B+C+D" or "A_B_C_D", so you could decrypt it by aes or des.

After we find out the last step is aes:

result = aes(result_before+D)

Although we don't know how many terms the result_before have, we know that the last part is a single term. And we should confirm this term is like d1_d2_d3(will be the result of des encryption) or d4 directly(will be the result of rc4 encryption). 

Although we don't know how long is the last part, the result_before may be the result of des or aes(if it is the cipher of rc4, we can use rc4 decrypt it into plaintext directly and get the length), so the length must be a multiple of 8. So we can decrypt last 8\*n bytes by des and rc4, and find the PKCS7 padding or the plain.

And so on, we depart every part and finally get the plaintext.

And the detail of the analysis will be written in the scrip:

```python
from Crypto.Cipher import ARC4, AES, DES
from Crypto.Util.Padding import unpad
from binascii import *
key = b"De1CTF"
rc4_key = key
des_key = key.ljust(8, b"\x02")
aes_key = key.ljust(16, b"\x0a")

def rc4_decrypt(cipher, key=rc4_key):
    rc4 = ARC4.new(key)
    return rc4.decrypt(cipher)

def aes_decrypt(cipher, key=aes_key):
    aes = AES.new(key, iv=key, mode=AES.MODE_CBC)
    return aes.decrypt(cipher)

def des_decrypt(cipher, key=des_key):
    des = DES.new(key, iv=key, mode=AES.MODE_CBC)
    return des.decrypt(cipher)
flag = b"}"
cipher = b"\xe7\xa43L\xd3\x11\xe7\x85hV\x97\x11\xee\xd2\xf8\xd9>p\xc9N\x94\xa02Z'\x98\x00\x1d\xd5\xd7\x11\x1d\xf4\x85a\xac\x0c\x80'@\xbd\xdd\x1f\x0b\xb4\x97\x1f`[T\xcb\xc5\xa8\xb7\x11\x90\xc9\xb5\x81eS\x0f~\x7f"
# It is unlikely that the result is a word. You can try rc4_decrypt(cipher) and get nothing.

# Last result may be like A+B+C+D or A_B_C_D, so we try aes and des decrypt.
print(des_decrypt(cipher))
# b'\x0e\x08r\xa8C\x14u\xae\xee\xd6)9.Q\xd3\xca|\xcf.\xde\xb9<\x8f4N\xcaP%X>5,\x1fIu\x89\xd5\xb3\xf5[1\x9b\x86Q\x86&\x05\xc8FGW\xf3\xfd&\xb4[#\x16O4\x94:h\x90'
print(aes_decrypt(cipher))
# b"\x0b\x82z\x9e\x00.\x07m\xe2\xd8L\xac\xb1#\xbc\x1e\xb0\x8e\xbe\xc1\xa4T\xe0\xf5P\xc6]7\xc5\x8c}\xaf-H'4-;\x13\xd9s\x0f%\xc1v\x89\x19\x8b\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10"
# We find the padding in aes result, so last result is like A+B+C+D.
cipher = unpad(aes_decrypt(cipher), 16)
print()

# The last part must be a TERM, which may be like d1_d2_d3_d4 or d1 directly.
# Try last 8*n bytes, and find padding or plaintext
# print(rc4_decrypt(cipher[-8:])) # nothing
# print(rc4_decrypt(cipher[-16:])) # nothing
# ...
print(des_decrypt(cipher[-8:]))
# b'G*\x11p~z\x16\xdc'
print(des_decrypt(cipher[-16:]))
# b'\xcd\xc55\x89\x9f#\xf0\xb2.\x07\x07\x07\x07\x07\x07\x07'
# Find the padding here, so the last term is like d1_d2_d3_d4
term_1 = unpad(des_decrypt(cipher[-16:]), 8)
cipher = cipher[:-16] # The first part.
print()

# Notice the length is 9, it's very short. if the last byte is a sinle primary_expr, the padding will be found in des_decrypt[0:8]
# or try to rc4 decrypt the whole result.
print(rc4_decrypt(term_1))
# Find a plaintext b"4nd", the left part will be another plaintext.
print(rc4_decrypt(term_1[3:]))
# b"p4r53r"
word_1 = rc4_decrypt(term_1[3:])
word_2 = rc4_decrypt(term_1[:3])
flag = word_2 + b"_" + word_1 + flag
flag = b"+" + flag
print()

# Next, we do the same thing again.
print(des_decrypt(cipher))
# b"\xa7\xaf\xa7\xe8#I\x9e#6X\x19\xed\xd5\x06\xcc\x86\xe4OC\x89 \x15\xff'\xd8\xe1f\x95\xfc\x99\xf8\x1e"
print(aes_decrypt(cipher))
# b'\x91\x98=\xa9\xb1:1\xef\x04r\xb5\x02\x07;h\xdd\xbd\xdb<\xc1}\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b'
cipher = unpad(aes_decrypt(cipher), 16)
print()

# Also find last part length
print(des_decrypt(cipher[-8:]))
print(des_decrypt(cipher[-16:]))
# Find the padding
term_2 = unpad(des_decrypt(cipher[-16:]), 8)
cipher = cipher[0:-16]
print()

# rc4 decrypt directly
print(rc4_decrypt(term_2))
# Find the plaintext b"w0rld"
print(rc4_decrypt(term_2[5:]))
# b"l3x3r"
word_3 = rc4_decrypt(term_2[5:])
word_4 = rc4_decrypt(term_2[:5])
flag = word_4 + b"_" + word_3 + flag
flag = b"+" + flag
print()

# Last part is less than 8 bytes. rc4_decrypt it directly
print(rc4_decrypt(cipher))
word_5 = rc4_decrypt(cipher)
flag = word_5 + flag

flag = b"De1CTF{" + flag
print(flag)
```

I think there may be a way to write a script to solve it automatically, but I didn't try.
