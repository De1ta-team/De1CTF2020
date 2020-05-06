from pwn import *
from gmpy2 import invert, gcd
from Crypto.Util.number import bytes_to_long
#context.log_level = 'debug'

q = 0xdd7860f2c4afe6d96059766ddd2b52f7bb1ab0fce779a36f723d50339ab25bbd
a = 0x4cee8d95bb3f64db7d53b078ba3a904557425e2a6d91c5dfbf4c564a3f3619fa
b = 0x56cbc73d8d2ad00e22f12b930d1d685136357d692fa705dae25c66bee23157b8
zero = (0,0)
msg = '\xff' * 64
msg_bit = [int(i) for i in list('{0:0b}'.format(bytes_to_long(msg)))] 


def add(p1,p2):
	if p1 == zero:
		return p2
	if p2 == zero:
		return p1
	(p1x,p1y),(p2x,p2y) = p1,p2
	if p1x == p2x and (p1y != p2y or p1y == 0):
	    return zero
	if p1x == p2x:
	    tmp = (3 * p1x * p1x + a) * invert(2 * p1y , q) % q
	else:
	    tmp = (p2y - p1y) * invert(p2x - p1x , q) % q
	x = (tmp * tmp - p1x - p2x) % q
	y = (tmp * (p1x - x) - p1y) % q
	return (int(x),int(y))

def mul(n,p):
	r = zero
	tmp = p
	while 0 < n:
	    if n & 1 == 1:
	        r = add(r,tmp)
	    n, tmp = n >> 1, add(tmp,tmp)
	return r

def GCRT(mi, ai):
    assert (isinstance(mi, list) and isinstance(ai, list))
    curm, cura = mi[0], ai[0]
    for (m, a) in zip(mi[1:], ai[1:]):
        d = gcd(curm, m)
        c = a - cura
        assert (c % d == 0)
        K = c // d * invert(curm // d, m // d)
        cura += curm * K
        curm = curm * m // d
        cura %= curm
    return (cura % curm, curm) 
	
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

r = remote("134.175.225.42",8848)
data = r.recvuntil("Give me XXXX:")
suffix = re.findall(r"XXXX\+([^\)]+)",data)[0]
h = re.findall(r"== ([0-9a-f]+)",data)[0]
p = solve_PoW(suffix, h)
r.send(p)

def pad(m):
	pad_length = q.bit_length()*2 - len(m)
	for _ in range(pad_length):
		m.insert(0,0)
	return m

def setKeys(P):
	r.recvuntil('Give me your key:\n')
	r.recvuntil('X:')
	r.sendline(str(P[0]))
	r.recvuntil('Y:')
	r.sendline(str(P[1]))
	r.recvuntil('Exchange success\n')

def encrypt(m):
	r.recvuntil('Give me your message(hex):\n')
	r.sendline(m.encode('hex'))
	r.recvuntil('The result is:\n')
	result = r.recvuntil('\n',drop=True)
	return result.decode('hex')

def getPoint(m):
	data = pad([int(i) for i in list('{0:0b}'.format(bytes_to_long(m)))])
	data = [data[i] ^ msg_bit[i] for i in range(len(data))]
	x_bit = data[:-q.bit_length()]
	x = 0
	for bit in x_bit:
		x = (x << 1) | bit
	y_bit = data[-q.bit_length():]
	y = 0
	for bit in y_bit:
		y = (y << 1) | bit
	return (x,y)

def sendData(P):
	r.recvuntil('choice:')
	r.sendline('Exchange')
	setKeys(P)
	r.recvuntil('choice:')
	r.sendline('Encrypt')
	result = encrypt(msg)
	return getPoint(result)

def getflag(secret):
	r.recvuntil('choice:')
	r.sendline('Backdoor')
	r.recvuntil('Give me the secret:\n')
	r.sendline(str(secret))
	r.recvuntil('flag:\n')
	flag = r.recvuntil('}')
	return flag

Px = 0xb55c08d92cd878a3ad444a3627a52764f5a402f4a86ef700271cb17edfa739ca
Py = 0x49ee01169c130f25853b66b1b97437fb28cfc8ba38b9f497c78f4a09c17a7ab2
P = (Px,Py)
setKeys(P)

data = []
with open('data.txt','r') as f:
	d = f.readlines()
	for i in d:
		tmp = i[1:-2].split(',')
		res = [int(x) for x in tmp]
		data.append(res)

orders = []
CRT = []
for i in data:
	P = (i[0],i[1])
	order = i[2]
	orders.append(order)
	res = sendData(P)
	for o in range(0,order):
		Q = mul(o,P)
		if res[0] == Q[0] and res[1] == Q[1]:
			CRT.append(o)
			break

secret = int(GCRT(orders,CRT)[0])
flag = getflag(secret)
print('[+]Get flag: ' + flag)
r.close()
