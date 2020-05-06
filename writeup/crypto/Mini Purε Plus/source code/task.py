#!/usr/bin/env python3
# coding=utf-8
import os,random,sys,string
import binascii
from pyfinite import ffield
from FLAG import flag
import sympy
import numpy as np
from Crypto.Util.number import long_to_bytes 

ROUND = 16
F = ffield.FField(24)
flag = ''.join(['%02x' % b for b in flag.encode(encoding="utf-8")])

def pad(plain):
    pad_length = (6 - len(plain) % 6 ) % 6
    return plain + chr(pad_length) * pad_length

def genkeys():
    keys=[]
    for _ in range(ROUND):
        key = os.urandom(3)
        key_int = int(binascii.hexlify(key),16)
        keys.append(key_int)
    return keys

def Mul(q1,q2):
    return F.Multiply(q1,q2)

def fbox(x):
    return Mul(Mul(x,x),x)

def enc_block(plain,keys):
    l = int(binascii.hexlify(plain[:3]),16)
    r = int(binascii.hexlify(plain[3:]),16)
    for i in range(ROUND):
        l , r = r , l ^ fbox(keys[i] ^ r)
    l , r = r , l
    result = (hex((l << 24) + r)[2:]).rjust(12,'0')
    return result

def encrypt(plain, keys):
    p = ''
    for i in range(0,len(plain),2):
        p += chr(int(plain[i:i+2],16))
    plain = pad(p).encode(encoding='utf-8')
    cipher = ''
    for i in range(0,len(plain),6):
        cipher += enc_block(plain[i:i+6],keys)
    return cipher

keys = genkeys()
with open('pt.txt','r') as ptfile:
    with open('ct.txt','w') as ctfile:
        while True:
            pt = ptfile.readline().rstrip('\n')
            if pt == '':
                break
            ct = encrypt(pt,keys)
            ctfile.write(ct + '\n')

p = sympy.nextprime(2**24)
arr = np.random.randint(0,p,(ROUND,ROUND-2),dtype='int64')
keys = np.array(keys)
res = np.mod(np.dot(keys,arr),p)

with open('data.txt','w') as f:
    f.write('Array: ' + str(arr) + '\n')
    f.write('Result: ' + str(res) + '\n')

with open('flag.txt','w') as f:
    ct = encrypt(flag,keys)
    f.write(ct)