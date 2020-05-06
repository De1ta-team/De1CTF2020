import os,random,sys,string
from hashlib import sha256
import SocketServer
import signal
from FLAG import flag
from gmpy2 import invert
from Crypto.Util.number import bytes_to_long, long_to_bytes

q = 0xdd7860f2c4afe6d96059766ddd2b52f7bb1ab0fce779a36f723d50339ab25bbd
a = 0x4cee8d95bb3f64db7d53b078ba3a904557425e2a6d91c5dfbf4c564a3f3619fa
b = 0x56cbc73d8d2ad00e22f12b930d1d685136357d692fa705dae25c66bee23157b8
zero = (0,0)

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

def pointToString(p):
	return "(" + str(p[0]) + "," + str(p[1]) + ")"

Px = 0xb55c08d92cd878a3ad444a3627a52764f5a402f4a86ef700271cb17edfa739ca
Py = 0x49ee01169c130f25853b66b1b97437fb28cfc8ba38b9f497c78f4a09c17a7ab2
P = (Px,Py)

class Task(SocketServer.BaseRequestHandler):
	def proof_of_work(self):
		random.seed(os.urandom(8))
		proof = "".join([random.choice(string.ascii_letters+string.digits) for _ in range(20)])
		digest = sha256(proof).hexdigest()
		self.request.send("sha256(XXXX+%s) == %s\n" % (proof[4:],digest))
		self.request.send("Give me XXXX:")
		x = self.request.recv(10)
		x = x.strip()
		if len(x) != 4 or sha256(x+proof[4:]).hexdigest() != digest: 
			return False
		return True

	def recvall(self, sz):
		try:
			r = sz
			res = ""
			while r > 0:
				res += self.request.recv(r)
				if res.endswith("\n"):
					r = 0
				else:
					r = sz - len(res)
			res = res.strip()
		except:
			res = ""
		return res.strip("\n")

	def dosend(self, msg):
		try:
			self.request.sendall(msg)
		except:
			pass
	

	def handle(self):
		try:
			if not self.proof_of_work():
				return
			signal.alarm(300)
			self.secret = random.randint(0,q)
			Q = mul(self.secret,P)

			self.dosend("Welcome to the ECDH System.\n")   
			self.dosend("The params are: \n")
			self.dosend("q: " + str(q) + "\n")
			self.dosend("a: " + str(a) + "\n")
			self.dosend("b: " + str(b) + "\n")
			self.dosend("P: " + pointToString(P) + "\n")
			self.dosend("Q: " + pointToString(Q) + "\n")
			self.exchange()
			for _ in range(90):
				self.dosend("Tell me your choice:\n")
				choice = self.recvall(9)
				if choice == "Exchange":
					self.exchange()
				elif choice == "Encrypt":
					self.encrypt()
				elif choice == "Backdoor":
					self.backdoor()
				else:
					self.dosend("No such choice!\n")
			self.dosend("Bye bye~\n")	 
			self.request.close()
		except:
			self.dosend("Something error!\n")
			self.request.close()

	def pad(self,m):
		pad_length = q.bit_length()*2 - len(m)
		for _ in range(pad_length):
			m.insert(0,0)
		return m

	def encrypt(self):
		self.dosend("Give me your message(hex):\n") 
		msg = self.recvall(150)
		data = [int(i) for i in list('{0:0b}'.format(bytes_to_long(msg.decode("hex"))))] 
		enc = [data[i] ^ self.key[i%len(self.key)] for i in range(len(data))]
		result = 0
		for bit in enc:
			result = (result << 1) | bit
		result =  long_to_bytes(result).encode("hex")
		self.dosend("The result is:\n") 
		self.dosend(result + "\n") 

	def pointToKeys(self,p):
		x = p[0]
		y = p[1]
		tmp = x << q.bit_length() | y
		res = self.pad([int(i) for i in list('{0:0b}'.format(tmp))]) 
		return res

	def exchange(self):
		self.dosend("Give me your key:\n") 
		self.dosend("X:\n") 
		x = int(self.recvall(80))
		self.dosend("Y:\n") 
		y = int(self.recvall(80))
		key = (x,y)
		result = mul(self.secret,key)
		self.key = self.pointToKeys(result)
		self.dosend("Exchange success\n") 

	def backdoor(self):
		self.dosend("Give me the secret:\n") 
		s = self.recvall(80)
		if int(s) == self.secret:
			self.dosend('Wow! How smart you are! Here is your flag:\n')
			self.dosend(flag)
		else:
			self.dosend('Sorry you are wrong!\n')
		exit(0)

class ForkedServer(SocketServer.ForkingTCPServer, SocketServer.TCPServer):
    pass


if __name__ == "__main__":
    HOST, PORT = "0.0.0.0", 8848
    server = ForkedServer((HOST, PORT), Task)
    server.allow_reuse_address = True
    server.serve_forever()