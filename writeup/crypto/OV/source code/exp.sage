q = 256
o = 16
v = o
n = o + v

COMMAND = "iwanttoknowflag!"

K.<a> = GF(q)
PR = PolynomialRing(K,'x',n)
x = matrix(PR.gens())

def hashFunction(m):
    assert(len(m) == o)
    H = [K.fetch_int(ord(i)) for i in m]
    return H

def sign(m,T,F):
    H = hashFunction(m)

    central_map = [x*F[i]*x.transpose() for i in range(o)]

    R = PolynomialRing(K,o,["x%s"%i for i in range(v,n)])
    Rgen = R.gens()

    while True:
        images = [K.random_element() for i in range(v)] + list(Rgen)
        phi = PR.hom(images,R)
        central_map_sub = [phi(central_map[i][0]) for i in range(o)]
        s = [central_map_sub[i] - H[i] for i in range(o)]
        h = R.ideal(s)
        var = h.variety()
        if len(var) != 0:
            result = var[0]
            break
    preimage = vector(images[:v] + [result["x"+str(i)] for i in range(v,n)])
    sign = T * preimage
    return sign

def IntListEncoder(s):
    return [i.integer_representation() for i in s]

def IntListDecoder(l):
    return vector([K.fetch_int(i) for i in l])

def PkDecode(pk):
    result = []
    for i in pk:
        result.append(Matrix(K,[IntListDecoder(j) for j in i]))
    return result

pk = []
with open("pk.txt","r") as f:
    for i in range(o):
        tmp = []
        for j in range(n):
            tmp.append([int(f.readline().strip("\n")) for _ in range(n)])
        pk.append(tmp)
pk = PkDecode(pk)       

T = []
count = 0
FLAG = 0
flag = 0

for i in range(len(pk)):
    if flag == 1:
        break
    for j in range(len(pk)):
        if flag == 1:
            break
        W = pk[i]*pk[j].inverse()
        fac = W.minimal_polynomial().factor()
        for k in fac:
            if k[1] == 1:
                data = k[0](W)
                ker = data.kernel()
                basis = ker.basis()
                if len(basis) != 1:
                    for item in basis:
                        if item*pk[j]*item == 0:
                            if item in T:
                                continue
                            T.append(item)
                            if Matrix(PR,T).rank() != len(T):
                                T = T[:-1]
                            else:
                                count += 1
                                print count
                                if count == o:
                                    FLAG = 1
                                    break
                    if FLAG == 1:
                        flag = 1
                        break

V = VectorSpace(K,n)
TT = [V(i) for i in T]
So = V.subspace(TT)
Sv = So.complement()

o_basis = So.basis()
v_basis = Sv.basis()

Mo = matrix(o_basis)
Mv = matrix(v_basis)
M = Matrix.block([[Mv],[Mo]])

Mi = M.inverse()
Mt = M.transpose()

F = [M*pk[i]*Mt for i in range(o)]

s = sign(COMMAND,Mt,F)
s = IntListEncoder(s)
with open("flag.txt","w") as f:
    for i in s:
        f.write(str(i) + "\n")
print "Done"