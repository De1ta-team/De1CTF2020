enc_flag = [0x7a,0x19,0x4f,0x6e,0xe,0x56,0xaf,0x1f,0x98,0x58,0xe,0x60,0xbd,0x42,0x8a,0xa2,0x20,0x97,0xb0,0x3d,0x87,0xa0,0x22,0x95,0x79,0xf9,0x41,0x54,0xc,0x6d]
table = '0123456789QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm+/='
enc = [None]*30

i = 0
while(i!=30):
  enc_flag[i+0] = enc_flag[i+2]^enc_flag[i+0] 
  enc_flag[i+2] = (enc_flag[i+2]-enc_flag[i+1]+0x100)%0x100
  enc_flag[i+1] = (enc_flag[i]+enc_flag[i+1]+0x100)%0x100
  i+=3

temp = ''
for i in range(len(enc_flag)):
  temp += chr(enc_flag[i])
enc_flag = temp
print(enc_flag)

for i in range(len(enc_flag)):
  for j in range(len(table)):
    if ord(enc_flag[i])==ord(table[j]):
      enc[i] = j
      break
print("De1CTF{",end = '')

for i in range(10):
  temp = enc[i*3]*58*58+enc[i*3+1]*58+enc[i*3+2]
  print("{}{}".format(chr(temp//256),chr(temp%256)),end = '')

print("}")