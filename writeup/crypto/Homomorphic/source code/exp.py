from pwn import *
import hashlib
import string
#context.log_level = 'debug'
d = 1024

r = remote("106.52.180.168",8848)

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

def decrypt(c0,c1,index):
	print "[+]Round " + str(index)
	r.recvuntil("Tell me your choice:\n")
	r.sendline("Decrypt")
	r.recvuntil("Please input c0(Separated by commas):\n")
	r.sendline(c0)
	r.recvuntil("Please input c1(Separated by commas):\n")
	r.sendline(c1)
	r.recvuntil("The index:\n")
	r.sendline(str(index))
	r.recvuntil("The result is: \n")
	result = r.recvuntil("\n")
	print "[+]Result: " + str(result)
	return result

data = r.recvuntil("Give me XXXX:")
suffix = re.findall(r"XXXX\+([^\)]+)",data)[0]
h = re.findall(r"== ([0-9a-f]+)",data)[0]
p = solve_PoW(suffix, h)
r.send(p)

r.recvuntil("The public keys are: \n")

r.recvuntil("pk0: ")
pk0 = r.recvuntil("\n",drop = True)
pk0 = [int(i) for i in pk0.strip("[]").split(",")]

r.recvuntil("pk1: ")
pk1 = r.recvuntil("\n",drop = True)
pk1 = [int(i) for i in pk1.strip("[]").split(",")]

r.recvuntil("The enc flag is: \n")
with open("FLAG.txt","w") as f:
	FLAG = []
	for i in range(44):
		c1 = r.recvuntil("\n",drop = True)
		c1 = [int(i) for i in c1.strip("[]").split(",")]

		for j in c1:
			f.write(str(j)+"\n")

		c2 = r.recvuntil("\n",drop = True)
		c2 = [int(i) for i in c2.strip("[]").split(",")]

		for j in c2:
			f.write(str(j)+"\n")

		FLAG.append((c1,c2))

with open("pk0.txt","w") as f:
	for i in pk0:
		f.write(str(i)+"\n")

with open("pk1.txt","w") as f:
	for i in pk1:
		f.write(str(i)+"\n")

Sage = process(["sage", "gen.sage"])
Sage.recvline().strip()
Sage.close()

s = []
for i in range(d):
	c0 = ""
	with open(str(i) + "-c0.txt","r") as f:
		for j in range(d):
			c0 += f.readline().strip("\n") + ","
	c0 = c0[:-1]

	c1 = ""
	with open(str(i) + "-c1.txt","r") as f:
		for j in range(d):
			c1 += f.readline().strip("\n") + ","
	c1 = c1[:-1]

	s.append(int(decrypt(c0,c1,i)))

with open("pri.txt","w") as f:
	for i in s:
		f.write(str(i)+"\n")
r.close()

Sage = process(["sage", "getFlag.sage"])
flag = Sage.recvline().strip()
Sage.close()

print("[+]Get flag: " + flag)