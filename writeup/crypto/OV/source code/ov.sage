class OV:
    def __init__(self,q,o,v):
        self.q = q
        self.o = o
        self.v = v
        self.n = o + v
        K.<a> = GF(self.q)
        self.K = K
        self.PR = PolynomialRing(K,'x',self.n)
        self.x = matrix(self.PR.gens())
        self.xt = self.x.transpose()
    
    def genKeys(self):
        B0 = [random_matrix(self.K,self.v,self.v) for _ in range(self.o)]
        B1 = [random_matrix(self.K,self.v,self.o) for _ in range(self.o)]
        B2 = [random_matrix(self.K,self.o,self.v) for _ in range(self.o)]
        B3 = [matrix(self.K,self.o,self.o) for _ in range(self.o)]

        self.F = [matrix.block([[B0[i],B1[i]],[B2[i],B3[i]]]) for i in range(self.o)]

        while true:
            self.T = random_matrix(self.K,self.n)
            if self.T.is_invertible():
                break

        self.Tt = self.T.transpose()
        self.Ti = self.T.inverse()
        self.pk = [self.Tt*self.F[i]*self.T for i in range(self.o)]
    
    def hashFunction(self,m):
        assert(len(m) == o)
        H = [self.K.fetch_int(ord(i)) for i in m]
        return H
    
    def sign(self,m):
        H = self.hashFunction(m)

        central_map = [self.x*self.F[i]*self.xt for i in range(self.o)]

        R = PolynomialRing(self.K,self.o,["x%s"%i for i in range(self.v,self.n)])
        Rgen = R.gens()

        while True:
            images = [self.K.random_element() for i in range(self.v)] + list(Rgen)
            phi = self.PR.hom(images,R)
            central_map_sub = [phi(central_map[i][0]) for i in range(self.o)]
            s = [central_map_sub[i] - H[i] for i in range(self.o)]
            h = R.ideal(s)
            var = h.variety()
            if len(var) != 0:
                result = var[0]
                break
        preimage = vector(images[:self.v] + [result["x"+str(i)] for i in range(self.v,self.n)])
        sign = self.Ti * preimage
        return self.IntListEncoder(sign)
    
    def verify(self,sign,H):
        sign = self.IntListDecoder(sign)
        PK = [self.x*self.pk[i]*self.xt for i in range(self.o)]
        images = [i for i in sign]
        phi = self.PR.hom(images,self.K)
        pk_sub = [phi(PK[i][0]) for i in range(self.o)]
        return pk_sub == H
    
    def IntListEncoder(self,s):
        return [i.integer_representation() for i in s]

    def IntListDecoder(self,l):
        return vector([self.K.fetch_int(i) for i in l])

    def PkEncoder(self):
        result = []
        for i in self.pk:
            result.append([self.IntListEncoder(j) for j in i])
        return result
    