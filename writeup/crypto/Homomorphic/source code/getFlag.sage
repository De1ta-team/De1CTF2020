q = 2^54
t = 2^8
d = 2^10

delta = int(q/t)
M = delta//4+50

PR.<x> = PolynomialRing(ZZ)
fx = x^d + 1
Q.<X> = PR.quotient(fx)

pri = []
with open("pri.txt","r") as f:
	for i in range(d):
		data = f.readline().strip("\n")
		pri.append(data)
pri = Q([i for i in pri])

def Round(a,r):
    A = a.list()
    for i in range(len(A)):
        A[i] = (A[i]%r)-r if (A[i]%r) > r/2 else A[i]%r
    return Q(A)

def decrypt(c,s):
    data = (t * Round(c[0] + c[1]*s,q)).list()
    for i in range(len(data)):
        data[i] = round(data[i]/q)
    data = Round(Q(data),t)
    return data

FLAG = ""
with open("FLAG.txt","r") as f:
	for i in range(44):
		c0 = []
		for j in range(d):
			c0.append(f.readline().strip("\n"))
		c1 = []
		for j in range(d):
			c1.append(f.readline().strip("\n"))
		c0 = Q([i for i in c0])
		c1 = Q([i for i in c1])
		FLAG += chr(int(decrypt((c0,c1),pri)))
print FLAG