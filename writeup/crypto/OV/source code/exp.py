from pwn import *
import hashlib
import string
#context.log_level = "debug"

o = 16
v = o
n = o + v

COMMAND = "iwanttoknowflag!"

#r = remote("134.175.220.99",8848)
r = remote("127.0.0.1",8848)


def getFlag(s):
    r.sendline("GetFlag")
    r.recvuntil("Please input the sign data of \"" + COMMAND + "\"(Separated by commas):\n")
    r.sendline(s)
    r.recvuntil("Wow! How smart you are! Here is your flag:\n")
    flag = r.recvuntil("}")
    return flag

def solve_PoW(suffix, h):
    print "solving PoW......"
    charset = string.letters + string.digits
    for p1 in charset:
        for p2 in charset:
            for p3 in charset:
                for p4 in charset:
                    plaintext = p1 + p2+ p3+ p4 + suffix
                    m = hashlib.sha256()
                    m.update(plaintext)
                    if m.hexdigest() == h:
                        print "PoW solution has been found!"
                        return p1+p2+p3+p4 

data = r.recvuntil("Give me XXXX:")
suffix = re.findall(r"XXXX\+([^\)]+)",data)[0]
h = re.findall(r"== ([0-9a-f]+)",data)[0]
p = solve_PoW(suffix, h)
r.send(p)

r.recvuntil("Please tell me your name(at most " + str(o) + " bytes):\n")
r.sendline("Anemone")

r.recvuntil("The public keys are: \n")
r.recvuntil("pk: ")
pks = r.recvuntil("\n",drop=True)
pks = pks.split(",")
with open("pk.txt","w") as f:
	for i in pks:
		f.write(i.replace("[","").replace("]","") + "\n")
        
r.recvuntil("Tell me your choice:\n")


Sage = process(["sage", "exp.sage"])
for i in range(o):
	print "[+]Round: " + Sage.recvline().strip()
Sage.recvline().strip()
Sage.close()

s = ""
with open("flag.txt","r") as f:
    for i in range(n): 
        s += f.readline().strip("\n") + ","
s = s[:-1]

flag = getFlag(s)
print "[+]Get flag: " + flag

r.close()