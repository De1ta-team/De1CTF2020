中文 | [En](./writeup_en.md)

# little elves

参考一个很小的elf头tiny elf，直接能执行汇编代码，通过系统调用获取输入，校验完后调用exit，正确会返回0，错误返回1。

加入了一些简单的花指令，基本上匹配对应模式就可以去除。

需要注意的是，elf头中定义的程序头的偏移是在4的位置，从第四个字节开始程序头和ELF头进行了复用。程序头的第三个成员代表段的其实地址，可以看到是00888000，所以加载的时候要自定义偏移0x888000，后续一些地址才是正确的。

算法方面，是有限域GF(2^8)上的矩阵乘法（就像希尔密码），用到的多项式是x^9+x^5+x^4+x^3+1，（`Rijndael MixColumns`中用的是x^9+x^4+x^3+x+1），需要一点点数学功底，或者求助密码学队友。

使用sage计算矩阵的逆

```python
from sage.all import *
import random
flag = "De1CTF{01ab211f-589b-40b7-9ee4-4243f541fc40}"
SIZE = len(flag)
res = [200, 201, 204, 116, 124, 94, 129, 127, 211, 85, 61, 154, 50, 51, 27, 28, 19, 134, 121, 70, 100, 219, 1, 132, 93, 252, 152, 87, 32, 171, 228, 156, 43, 98, 203, 2, 24, 63, 215, 186, 201, 128, 103, 52]
def i2x(num):
    res = 0
    i = 0
    while num!=0:
        res += (num&1) * (x^i)
        num >>= 1
        i+=1
    return res

def i2y(num):
    res = 0
    i = 0
    while num!=0:
        res += (num&1) * (y^i)
        num >>= 1
        i+=1
    return res

def y2i(r):
    tmp = r.list()
    res = 0
    for i in tmp[::-1]:
        res <<= 1
        res += int(i)
    return res

def vi2y(v):
    res = []
    for i in v:
        res.append(i2y(i))
    return res

def vy2i(v):
    res = []
    for i in v:
        res.append(y2i(i))
    return res

def mi2y(m):
    res = []
    for i in m:
        res.append(vi2y(i))
    return res

def my2i(m):
    res = []
    for i in m:
        res.append(vy2i(i))
    return res

R.<x> = PolynomialRing(GF(2), 'x')
S.<y> = QuotientRing(R, R.ideal(i2x(313)))

M = MatrixSpace(S, SIZE, SIZE)
V = VectorSpace(S, SIZE)

def genM():
    res = []
    for i in range(SIZE):
        tmp = []
        for j in range(SIZE):
            tmp.append(random.randint(0, 255))
        res.append(tmp)
    return res

A = # matrix here ...
#A = genM()
AM = M(mi2y(A))
v = V(vi2y(res))
f = vy2i(AM.solve_right(v))
f = "".join(map(chr, f))
print(f)
```

