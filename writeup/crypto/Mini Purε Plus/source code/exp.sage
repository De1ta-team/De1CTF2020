#keys = [16359893, 9091260, 11254674L, 353718L, 5395716L, 9319892L, 2360013L, 12784246L, 9857353L, 2940944L, 964650L, 3296014L, 7022345L, 198188L, 9208218L, 14944194L]
F = GF(2**24)
ROUND = 16

def fbox(x):
    return F(x^3)

def dec_block(cipher,keys):
    l = F.fetch_int(int(cipher[:6],16))
    r = F.fetch_int(int(cipher[6:],16))
    for i in range(ROUND):
        key = F.fetch_int(keys[ROUND-i-1])
        l , r = r , l + fbox(key + r)
    l , r = r , l
    l = l.integer_representation()
    r = r.integer_representation()
    result = ((hex((l << 24) + r)[2:].rstrip('L')).rjust(12,'0')).decode('hex')
    return result

def unpad(x):
    return x[:-ord(x[-1])]

# Get k0
P = 2^24 - 3^15
count = 0
with open('pt.txt','r') as ptfile:
    with open('ct.txt','r') as ctfile:
        sum = F.fetch_int(0)
        for i in range(2**24):
            if i%2**20 == 0:
                print '[+]k0 Round ' + str(count)
                count += 1
            pt = ptfile.readline()[:-2]
            ct = ctfile.readline()[:-2]
            pt = int(pt[6:],16)
            ct = int(ct[6:],16)
            x = F.fetch_int(pt)
            xr = F.fetch_int(ct)
            sum += x^P*xr
        k0 = sum.integer_representation()
        print('[+]Get k0: ') + str(k0)

# Get k1
P = 2^24 - 3^15 + 2
c = F.fetch_int(0x777777)
count = 0
with open('pt.txt','r') as ptfile:
    with open('ct.txt','r') as ctfile:
        sum = F.fetch_int(0)
        for i in range(2**24):
            if i%2**20 == 0:
                print '[+]k1 Round ' + str(count)
                count += 1
            pt = ptfile.readline()[:-2]
            ct = ctfile.readline()[:-2]
            pt = int(pt[6:],16)
            ct = int(ct[6:],16)
            x = F.fetch_int(pt)
            xr = F.fetch_int(ct)
            sum += x^P*xr
        sum += (F.fetch_int(k0))^3 + c
        k1 = sum.integer_representation()
        print('[+]Get k1: ') + str(k1)

# k0 = 16359893
# k1 = 9091260
p = 16777259

with open('data.txt','r') as f:
    data = f.readlines()

    result = (data[-2][9:-2] + data[-1][:-3]).split(' ')
    res = []
    for i in result:
        if i != '':
            res.append(int(i))

    data = data[:-2]
    arr = []
    for i in range(0,len(data),2):
        l = []
        tmp = (data[i][:-2] + data[i+1][:-2]).replace('Array: ',' ').replace('[',' ').replace(']',' ').split(' ')
        for j in tmp:
            if j!= '':
                l.append(int(j))
        arr.append(l)

length = len(res)
for i in range(length):
    res[i] = (res[i] - (arr[0][i] * k0 + arr[1][i] * k1)) % p
arr = arr[2:]

MS = MatrixSpace(GF(p),length,length)
MSS = MatrixSpace(GF(p),1,length)
A = MS(arr)
s = MSS(res)
inv = A.inverse()
res_keys = s*inv
keys = [int(x) for x in res_keys[0]]
keys.insert(0,k1)
keys.insert(0,k0)
print '[+]Get keys: ' + str(keys)

flag_enc = 'd519b93b0fd950bdf1e1c321fc32e4c4c4b225b80c1ba091f31217b90132ed107e1f6b1c9dd60ba0eafcdd5923764c46'
flag = ''

for i in range(0,len(flag_enc),12):
    cipher = flag_enc[i:i+12]
    flag += dec_block(cipher,keys)
flag = unpad(flag)
print '[+]Get flag: ' + flag
