中文 | [En](./writeup_en.md)

## parser

### 出题思路

最近在学编译原理，写了个极其简单的词法分析器和语法分析器来解析flag。

首先词法分析提取token，不满足要求的会抛出异常

文法:

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

其实就是跟四则运算一样

首先所有WORD都会被RC4加密一下

a + b被定义为aes_encrypt(ab)

a _ b被定义为des_encrpt(ab)

_的优先级比+要高，没有实现括号，因为括号会产生多解（无限加括号）。除非对括号进行其他操作的定义，但我觉得没必要

编译时没有开启编译优化。（看了一眼O3后的，我自己都看不懂，开了怕不是被打

但是由于用了9.0的g++，新特性添加了endbr64指令（漏洞缓解机制，具体不太懂），导致IDA得不到plt表的信息，但是GDB或者用ida调试起来可以看。。。

符号表保留了挺多有用的信息，所以strip了。

### 逆向

由于是用C++编写的，逆向的难度较大。就算O0也挺难纯静态做。

首先可以随便输点什么测试一下，不难发现输入的格式和结构。

最好的办法应该是一边调试一边跟踪数据流，很快会发现输入在`sub_35F0`被分割成一个一个token，不难分析出token的种类。所有token被存进一个`std::vector`。

跟踪存放token的vector来到`sub_4E70`和`sub_507E`，这里递归的调用了`sub_507E`最终来到`sub_51CC`，类型为4的token（也就是单个字符串）被RC4加密。

返回到`sub_507E`。这里是一个循环，结束的条件为下一个token不是`_`。继续递归调用`sub_507E`解析出一个字符串后，讲两个字符串拼接然后des加密。

继续返回，来到`sub_4E70`，依然是一个循环，结束条件为下一个token不是`+`。然后又调用`sub_507E`，解析一个新的结果出来，两个结果拼接后aes加密。

所有的结果都是用`std::string`链接起来的，最后和`unk_8040`常量对比。

到这里基本就完全逆完了。比较重要的事情是+和_的优先级是不一样的，这是解题的关键。

加密算法全部用的PKCS7来pad，全部是标准的加密算法，（AES的S盒替换这一步没有直接查表，而是按照S盒生成原理写的，所以找不到S盒。但是观察AES的10轮结构应该很轻松能看出来），结合调试和验证也能发现是正常标准的加密算法，分组模式是CBC（ECB的话求解起来可能更复杂一些），密钥都为De1CTF，也用PKCS7来pad到正确的长度。

### 解法

注意到所有的明文都通过PKCS7pad到正确的长度，所以我们可以通过尝试判断当前这一步是aes还是des。

拿到常量后，考虑这是`A+B+C+D`这种的结果还是`A_B_C_D`这种。通过解密发现aes解密结果有padding，所以就有：

result = aes(result_before+D)

尽管我们不知道前一部分有多少个项，但是最后一部分一定只有一个项。接下来要确认这一项是`d1_d1_d3`这种形式（des的密文）还是单独的一个字符串`d1`（rc4的密文）。

尽管我们仍然不知道最后一项有多长，但由于前面一部分大概率是aes或des的密文（如果前一部分是rc4密文，就意味着我们对着整体解rc4就能拿到第一部分的明文了），所以我们在后一部分只要考虑8\*n的长度即可。对后8\*n字节解des或rc4，寻找padding或明文，然后在对后一部分讨论rc4与des的组合情况，这里就比较容易了。

以此类推，我们就可以恢复所有部分的明文，根据加密关系补上符号就是flag了。

详细的分析在脚本里

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
# 不太可能直接解rc4

# 分别尝试des和aes解密，在aes中发现了padding，说明结果是A+B的形式
print(des_decrypt(cipher))
# b'\x0e\x08r\xa8C\x14u\xae\xee\xd6)9.Q\xd3\xca|\xcf.\xde\xb9<\x8f4N\xcaP%X>5,\x1fIu\x89\xd5\xb3\xf5[1\x9b\x86Q\x86&\x05\xc8FGW\xf3\xfd&\xb4[#\x16O4\x94:h\x90'
print(aes_decrypt(cipher))
# b"\x0b\x82z\x9e\x00.\x07m\xe2\xd8L\xac\xb1#\xbc\x1e\xb0\x8e\xbe\xc1\xa4T\xe0\xf5P\xc6]7\xc5\x8c}\xaf-H'4-;\x13\xd9s\x0f%\xc1v\x89\x19\x8b\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10"
cipher = unpad(aes_decrypt(cipher), 16)
print()

# 由于解析时是循环加上TERM的，所以后一部分必然是一个TERM，因此我们先讨论后一部分更合适
# 既然B是一个TERM，那么要么直接是一个WORD，直接rc4解密并不能发现正常结果
# 要么就是b1_b2的形式。根据des分组长度为8字节，爆破des的分组数目
# 最后在长度为16时发现了des的padding
print(des_decrypt(cipher[-8:]))
# b'G*\x11p~z\x16\xdc'
print(des_decrypt(cipher[-16:]))
# b'\xcd\xc55\x89\x9f#\xf0\xb2.\x07\x07\x07\x07\x07\x07\x07'
term_1 = unpad(des_decrypt(cipher[-16:]), 8)
cipher = cipher[:-16] # 前一部分放到后面讨论
print()

# b1_b2的形式，跟之前+的分析类似，从后往前找WORD，再讨论b1的情况
# 正常来说只能知道后面是单独的WORD，所以要爆破这一部分rc4明文长度
# 当然，这里的长度足够短，可以猜测就是两个WORD，直接rc4解密就能看到第一个WORD，剩下的是另一个
print(rc4_decrypt(term_1))
# 开头发现了有意义的字符串`4nd`
print(rc4_decrypt(term_1[3:]))
# b"p4r53r"
word_1 = rc4_decrypt(term_1[3:])
word_2 = rc4_decrypt(term_1[:3])
flag = word_2 + b"_" + word_1 + flag
flag = b"+" + flag
print()

# 接下来又和一开始一样了，重复一遍。先试一下aes和des，判断是单独的TERM还是两部分相加（当然还有直接是一个WORD的可能）
# 还是在aes中发现了padding，依然是A+B的形式
print(des_decrypt(cipher))
# b"\xa7\xaf\xa7\xe8#I\x9e#6X\x19\xed\xd5\x06\xcc\x86\xe4OC\x89 \x15\xff'\xd8\xe1f\x95\xfc\x99\xf8\x1e"
print(aes_decrypt(cipher))
# b'\x91\x98=\xa9\xb1:1\xef\x04r\xb5\x02\x07;h\xdd\xbd\xdb<\xc1}\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b'
cipher = unpad(aes_decrypt(cipher), 16)
print()

# 依然是爆破后面一个TERM的长度
print(des_decrypt(cipher[-8:]))
print(des_decrypt(cipher[-16:]))
# 长度为16时发现padding，剩下的就是前一部分
term_2 = unpad(des_decrypt(cipher[-16:]), 8)
cipher = cipher[0:-16]
print()

# 依然是可以猜测两个WORD组成
print(rc4_decrypt(term_2))
# 开头发现了有意义的字符串b"w0rld"
print(rc4_decrypt(term_2[5:]))
# b"l3x3r"
word_3 = rc4_decrypt(term_2[5:])
word_4 = rc4_decrypt(term_2[:5])
flag = word_4 + b"_" + word_3 + flag
flag = b"+" + flag
print()

# 剩下的内容很短，直接解rc4
print(rc4_decrypt(cipher))
word_5 = rc4_decrypt(cipher)
flag = word_5 + flag

flag = b"De1CTF{" + flag
print(flag)
```

感觉可以根据padding写一个自动求解的脚本。不过处理起来挺麻烦的，就没有尝试
