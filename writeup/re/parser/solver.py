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

cipher = unpad(aes_decrypt(cipher), 16)
term_1 = unpad(des_decrypt(cipher[-16:]), 8)
cipher = cipher[:-16] 
word_1 = rc4_decrypt(term_1[3:])
word_2 = rc4_decrypt(term_1[:3])
flag = word_2 + b"_" + word_1 + flag
flag = b"+" + flag
cipher = unpad(aes_decrypt(cipher), 16)
term_2 = unpad(des_decrypt(cipher[-16:]), 8)
cipher = cipher[0:-16]
word_3 = rc4_decrypt(term_2[5:])
word_4 = rc4_decrypt(term_2[:5])
flag = word_4 + b"_" + word_3 + flag
flag = b"+" + flag
word_5 = rc4_decrypt(cipher)
flag = word_5 + flag
flag = b"De1CTF{" + flag

