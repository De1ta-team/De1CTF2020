from pwn import *
#context.log_level = 'debug'
q = 0xdd7860f2c4afe6d96059766ddd2b52f7bb1ab0fce779a36f723d50339ab25bbd
a = 0x4cee8d95bb3f64db7d53b078ba3a904557425e2a6d91c5dfbf4c564a3f3619fa
b = 0x56cbc73d8d2ad00e22f12b930d1d685136357d692fa705dae25c66bee23157b8
Px = 0xb55c08d92cd878a3ad444a3627a52764f5a402f4a86ef700271cb17edfa739ca
Py = 0x49ee01169c130f25853b66b1b97437fb28cfc8ba38b9f497c78f4a09c17a7ab2

r = process(['/home/anemone/ecgen/ecgen','--fp','-i','256'])

def getData():
	r.recvuntil('points')
	r.recvuntil('\"x\": \"0x')
	x = int(r.recvuntil('\"',drop = True),16)
	r.recvuntil('\"y\": \"0x')
	y = int(r.recvuntil('\"',drop = True),16)
	r.recvuntil('\"order\": \"0x')
	order = int(r.recvuntil('\"',drop = True),16)
	return x,y,order
	
r.recvuntil('p:')
r.sendline(str(q))
r.recvuntil('a:')
r.sendline(str(a))
r.recvuntil('b:')
r.sendline(str(b))

orders = []
count = 0
mul = 1
with open('data.txt','w') as f:
	while True:
		x,y,order = getData()
		if order not in orders:
			orders.append(order)
			count += 1
			mul *= order
			data = '('+str(x)+','+str(y)+','+str(order)+')\n'
			print('[+]Round: '+str(count))
			print(data)
			f.write(data)
		else:
			continue
		if mul > q:
			break
r.close()