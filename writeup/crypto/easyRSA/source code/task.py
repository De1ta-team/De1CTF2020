from Crypto.Util.number import *
import gmpy2
import random
from FLAG import flag

def genE(lcm,limit):
    while True:
        r = random.randint(limit,limit*0x1000000000001)
        d = gmpy2.next_prime(r)
        e = gmpy2.invert(d,lcm)
        if isPrime(e):
            break
    return e

p = getStrongPrime(1024)
q = getStrongPrime(1024)
n = p*q
lcm = gmpy2.lcm(p-1,q-1)
limit = gmpy2.iroot(n,3)[0]

e1 = genE(lcm,limit)
e2 = genE(lcm,limit)

phi = (p-1)*(q-1)
d1 = gmpy2.invert(e1,phi)
d2 = gmpy2.invert(e2,phi)

e = [e1,e2]
plain = bytes_to_long(flag)
cipher = pow(plain,e[random.getrandbits(1)],n)

print('N:' + str(n))
print('e1:' + str(e1))
print('e2:' + str(e2))
print('cipher:' + str(cipher))
