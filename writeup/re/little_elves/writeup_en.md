[中文](./writeup_zh.md) | En

# little elves

reference to [tiny-elf](https://github.com/arjun024/tiny-elf)

I reference this elf that I can write some assembly code and run it directly. Another intention is to learn something about the ELF format.

In this case, the program header is at the offset of 4 in the file. And the third member of the program header is the address of the segment. So the base address is 0x888000. If you can't get this point, you may have a little trouble in later analysis.

I add some junk code and it is not very hard to remove them. The main code is a big unrolling loop, every part is similar.

The algorithm is some basis abstract algebra, the matrix multiple over Finite Field of size 2 with the modulus x^8 + x^5 + x^4 + x^3 + 1.

Use sage to solve it easily, and the z3-solver doesn't work.



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

