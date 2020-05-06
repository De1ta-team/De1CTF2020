import os,random,sys,string
from hashlib import sha256
import SocketServer
import signal
load("ov.sage")
from FLAG import flag

q = 256
o = 16
v = 16
n = o + v

COMMAND = "iwanttoknowflag!"

class Task(SocketServer.BaseRequestHandler):
    def pad(self,m):
        assert(len(m) <= o)
        pad_length = o - len(m)
        return m + pad_length * "\x00"

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
            signal.alarm(600)
            if not self.proof_of_work():
                return
            seed = int(os.urandom(16).encode("hex"),16)
            set_random_seed(seed)

            self.dosend("Welcome to the Oil & Vinegar Crypto System.\n")   
            self.dosend("Please tell me your name(at most " + str(o) + " bytes):\n")
            name = self.pad(self.recvall(o+1))
            self.Check(name)

            ov = OV(q,o,v)
            self.ov = ov
            self.ov.genKeys()
            pk = self.ov.PkEncoder()
            s = self.ov.sign(name)
            
            self.dosend("Hello! " + name + "\n")
            self.dosend("Your sign is " + str(s) + "\n")
            self.dosend("The public keys are: \n")
            self.dosend("pk: " + str(pk) + "\n")

            for _ in range(3):
                self.dosend("Tell me your choice:\n")
                choice = self.recvall(9)
                if choice == "Sign":
                    self.Sign()
                elif choice == "Verify":
                    self.Verify()
                elif choice == "GetFlag":
                    self.GetFlag()
                else:
                    self.dosend("No such choice!\n") 

            self.dosend("Bye bye~\n")
            self.request.close()
        except:
			self.dosend("Something error!\n")
			self.request.close()

    def Sign(self):
        self.dosend("Please input your data(at most " + str(o) + " bytes):\n")
        data = self.pad(self.recvall(o+1))
        self.Check(data)
        result = self.ov.sign(data)
        self.dosend("The result is: \n")
        self.dosend(str(result) + "\n")

    def Verify(self):
        self.dosend("Please input your data:\n")
        data = self.pad(self.recvall(o+1))
        H = self.ov.hashFunction(data)
        self.dosend("Please input your sign data(Separated by commas):\n")
        s = (self.recvall(n*5)).split(",")
        s = [int(i) for i in s] 
        result = self.ov.verify(s,H)
        self.dosend("The result is: \n")
        self.dosend(str(result) + "\n")
    
    def GetFlag(self):
        self.dosend("Please input the sign data of \"" + COMMAND + "\"(Separated by commas):\n")
        s = (self.recvall(n*5)).split(",")
        s = [int(i) for i in s]
        H = self.ov.hashFunction(COMMAND)
        result = self.ov.verify(s,H)
        if result == True:
            self.dosend('Wow! How smart you are! Here is your flag:\n')
            self.dosend(flag)
        else:
            self.dosend('Sorry you are wrong.\n')
        exit(0)
        

    def Check(self,m):
        if m == COMMAND:
            self.dosend("No no no! Your can't do this\n")
            exit(0)


class ForkedServer(SocketServer.ForkingTCPServer, SocketServer.TCPServer):
    pass


if __name__ == "__main__":
    HOST, PORT = "0.0.0.0", 8848
    server = ForkedServer((HOST, PORT), Task)
    server.allow_reuse_address = True
    server.serve_forever()