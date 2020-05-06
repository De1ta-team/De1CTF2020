from sage.stats.distributions.discrete_gaussian_integer import DiscreteGaussianDistributionIntegerSampler
import os,random,sys,string
from hashlib import sha256
import SocketServer
import signal
from FLAG import flag

assert(len(flag) == 44)

q = 2^54
t = 2^8
d = 2^10
delta = int(q/t)

PR.<x> = PolynomialRing(ZZ)
DG = DiscreteGaussianDistributionIntegerSampler(sigma=1)
fx = x^d + 1
Q.<X> = PR.quotient(fx)

def sample(r):
    return Q([randint(0,r) for _ in range(d)])

def genError():
    return Q([DG() for _ in range(d)])

def Round(a,r):
    A = a.list()
    for i in range(len(A)):
        A[i] = (A[i]%r) - r if (A[i]%r) > r/2 else A[i]%r
    return Q(A)

def genKeys():
    s = sample(1)
    a = Round(sample(q-1),q)
    e = Round(genError(),q)
    pk = [Round(-(a*s+e),q),a]
    return s,pk

def encrypt(m):
    u = sample(1)
    e1 = genError()
    e2 = genError()
    c1 = Round(pk[0]*u + e1 + delta*m,q)
    c2 = Round(pk[1]*u + e2,q)
    return (c1.list(),c2.list())

def decrypt(c):
    c0 = Q([i for i in c[0]])
    c1 = Q([i for i in c[1]])
    data = (t * Round(c0 + c1*s,q)).list()
    for i in range(len(data)):
        data[i] = round(data[i]/q)
    data = Round(Q(data),t)
    return data

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
    
    def check(self,m):
        m0,m1 = [abs(j) for j in m[0]],[abs(j) for j in m[1]]
        for f in FLAG:
            i0,i1 = [abs(j) for j in f[0]],[abs(j) for j in f[1]]
            if m0 == i0 and m1 == i1:
                return False
        return True

    def Encrypt(self):
        self.dosend("Please input your data:\n")
        data = self.recvall(20)
        result = [encrypt(ord(i)) for i in data]
        self.dosend("The result is: \n")
        self.dosend(str(result) + "\n")
       
    def Decrypt(self):
        self.dosend("Please input c0(Separated by commas):\n")
        c0 = (self.recvall(60*d)).split(",")
        c0 = [int(i) for i in c0]

        self.dosend("Please input c1(Separated by commas):\n")
        c1 = (self.recvall(60*d)).split(",")
        c1 = [int(i) for i in c1]

        self.dosend("The index:\n")
        index = int(self.recvall(60))
        c = (c0,c1)

        if not self.check(c):
            self.dosend("No no no!\n")  
            exit(0)
        result = decrypt(c)
        result = result.list()[index]

        self.dosend("The result is: \n")
        self.dosend(str(result) + "\n")
        

    def handle(self):
        try:
            signal.alarm(800)
            if not self.proof_of_work():
                return
            seed = int(os.urandom(16).encode("hex"),16)
            set_random_seed(seed)

            global s,pk,FLAG
            s,pk = genKeys()
            FLAG  = [encrypt(ord(i)) for i in flag]

            self.dosend("Welcome to the Homomorphic Encryption Crypto System.\n")   
            self.dosend("The public keys are: \n")
            self.dosend("pk0: " + str(pk[0].list()) + "\n")
            self.dosend("pk1: " + str(pk[1].list()) + "\n")

            self.dosend("The enc flag is: \n")
            for i in FLAG:
                for j in i:
                    self.dosend(str(j) + "\n")

            for _ in range(2**10):
                self.dosend("Tell me your choice:\n")
                choice = self.recvall(9)
                if choice == "Encrypt":
                    self.Encrypt()
                elif choice == "Decrypt":
                    self.Decrypt()
                else:
                    self.dosend("No such choice!\n") 

            self.request.close()
        except:
			self.dosend("Something error!\n")
			self.request.close()

class ForkedServer(SocketServer.ForkingTCPServer, SocketServer.TCPServer):
    pass


if __name__ == "__main__":
    HOST, PORT = "0.0.0.0", 8848
    server = ForkedServer((HOST, PORT), Task)
    server.allow_reuse_address = True
    server.serve_forever()
