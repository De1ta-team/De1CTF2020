q = 2^54
t = 2^8
d = 2^10

delta = int(q/t)
M = delta//4+50

PR.<x> = PolynomialRing(ZZ)
fx = x^d + 1
Q.<X> = PR.quotient(fx)

pk0 = []
with open("pk0.txt","r") as f:
	for i in range(d):
		data = f.readline().strip("\n")
		pk0.append(data)
pk0 = Q([i for i in pk0])

pk1 = []
with open("pk1.txt","r") as f:
	for i in range(d):
		data = f.readline().strip("\n")
		pk1.append(data)
pk1 = Q([i for i in pk1])

for i in range(d):
	t1 = [0 for _ in range(d)]
	t1[i] = M
	t2 = M
	c0 = (pk0 + Q(t1)).list()
	c1 = (pk1 + Q(t2)).list()

	with open(str(i) + "-c0.txt","w") as f:
		for j in c0:
			f.write(str(j)+"\n")

	with open(str(i) + "-c1.txt","w") as f:
		for j in c1:
			f.write(str(j)+"\n")
print "Done"