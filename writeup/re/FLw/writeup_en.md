[中文](./writeup_zh.md) | English

# Flw

## VM instruction

`unsigned char flag[] = "de1ctf{Innocence_Eye&Daisy*}";`

This is a queue-based virtual machine.

The structure of the virtual machine is as follows:

```c++
class QueueVirtualMachine{
public:
    QueueVirtualMachine();
    QueueVirtualMachine(unsigned char*);
    ~QueueVirtualMachine();
    bool run();
    void printQueueMemSpace(); //Used to get debugging information
    void printMemSpace();      //Used to get debugging information
private:
    int head,tail;         //The head and tail pointer of the queue
    unsigned short reg;    //The register used to calculate the packet base58
    unsigned char *queueMemSpace;//Queue space
    unsigned char *memSpace;     //Memory space
    unsigned char *codeSpace;    //Code segment
    unsigned char *tempString;   //String buffer
};
```



The instructions of the virtual machine are as follows:

14 xx

Press a number into the end of the queue

15

Discard a queue tail element

20 xx

Place a byte of the queue header in the location of 'memSpace[xx]'

2a xx

Press a byte of 'memspace[xx]' into the end of the queue

2b

Take a piece of data from the head of the queue as an index and press a byte of memspace[] into the end of the queue

2c

Take a piece of data from the queue header as an index and put the next byte in the queue into memspace[]

30

Let's move reg 8 bits to the left, and then reg plus the element at the end of the queue

31 xx

Short in register divided by xx, remainder into queue, quotient in reg

32

A byte at the head of the queue is taken as the index value of table[], and the value result is queued

33

Take the sum of the two data at the head of the queue, and the result is queued

34

The two data at the head of the queue are subtracted and the result is queued.

Notice that the decrement is at the head of the queue

35

Take the two data phases of the queue head ×, and the result is queued

36

The data in the register is queued and the register is cleared

37

Take two data at the head of the queue that are xor, and the result is queued

3a

Read in a string, place the string in the buffer, and queue the string length

40 xx

Takes a number at the head of the queue, if the number is not zero

Xx  op - =

41

The string in the buffer is queued to clear the buffer

ab

The instruction completes and returns true

ff

If the queue header is not 0, the virtual machine returns the bool value 'false'

## Algorithm design

### 1.Read the string, detect the length, and move into memSpace

```c
    //cin>>tempString;
    0x3a,
    //if(strlen(tempString)!=28)return false;
    0x14,28,
    0x34,
    0xff,
    //Move the string into the buffer
    0x41,
    //Move into memory from the queue
    0x20,0x19,//d
    0x20,0x1a,//e
    0x20,0x1b,//1
    0x20,0x1c,//c
    0x20,0x1d,//t
    0x20,0x1e,//f
    0x20,0x1f,//{
    0x20,0x20,
    0x20,0x21,
    0x20,0x22,
    0x20,0x23,
    0x20,0x24,
    0x20,0x25,
    0x20,0x26,
    0x20,0x27,
    0x20,0x28,
    0x20,0x29,
    0x20,0x2a,
    0x20,0x2b,
    0x20,0x2c,
    0x20,0x2d,
    0x20,0x2e,
    0x20,0x2f,
    0x20,0x30,
    0x20,0x31,
    0x20,0x32,
    0x20,0x33,
    0x20,0x34,//}
```

### 2. Check the format.

The following several inspections are scattered throughout the virtual machine instructions.

```c++
    0x2a,0x19,
    0x14,'D',
    0x34,
    0xff, 
    0x2a,0x1a,
    0x14,'e',
    0x34,
    0xff,
    0x2a,0x1b,
    0x14,'1',
    0x34,
    0xff,
    0x2a,0x1c,
    0x14,'C,
    0x34,
    0xff,
    0x14,'T',
    0x34,
    0xff,
    0x2a,0x1e,
    0x14,'F',
    0x34,
    0xff,
    0x2a,0x1f,
    0x14,'{',
    0x34,
    0xff,
    0x2a,0x34,
    0x14,'}',
    0x34,
    0xff,
```

Junk instructions：

```
 _asm
    {
        mov eax, _PE1
        push eax
        push fs : [0]
        mov fs : [0] , esp
        xor ecx, ecx
        div ecx
        retn
        _PE1 :
        mov esp, [esp + 8]
            mov eax, fs : [0]
            mov eax, [eax]
            mov eax, [eax]
            mov fs : [0] , eax
            add esp, 8
    }    
```

     _asm
    {
        jz _P2
        jnz _P2
        _P1 :
        __emit 0xE8
    }
    
      _asm
    {
        call _P1
        _P1 :
        add[esp], 5
            retn
    }
    
    	_asm
            {
                xor eax, eax
                add eax, 2
                ret 0xff
            }


​            

### 3.The 20 characters in flag packaging were divided into 10 groups for base58 encoding

The machine code is too long. I'll put a pseudo code here

It is important to note that although the table is 64-bit long, the algorithm used is base58, not base64

```c++
table = '0123456789QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm+/='
for(int i = 0;i<10;++i){
  reg = (memSpace[0x20+i*2]<<8)+memspace(0x21+i*2);
  for(int j = 3;j>0;--j){
    memspace[0x39+j+i*3] = table[reg%58];
    reg /= 58;
  }
}
```

### 4.Packet encryption

Then do not know how, whim, made a round of encryption, grouping.

Modular addition, modular subtraction, or xor are all reversible.

```python
for(int i = 0,i<30,i+=3){
  memSpace[0x40+i+1] = memSpace[0x40+i+1]+memSpace[0x40+i+0];
  memSpace[0x40+i+2] = memSpace[0x40+i+2]-memSpace[0x40+i+1];
  memSpace[0x40+i+0] = memSpace[0x40+i+0]^memSpace[0x40+i+2];
}
```



### 5.The encrypted results are detected

The reason for not putting machine code is the same as above.

```cpp
enc_flag = [0x7a,0x19,0x4f,0x6e,0xe,0x56,0xaf,0x1f,0x98,0x58,0xe,0x60,0xbd,0x42,0x8a,0xa2,0x20,0x97,0xb0,0x3d,0x87,0xa0,0x22,0x95,0x79,0xf9,0x41,0x54,0xc,0x6d]
for i in range(len(enc_flag)):
    if enc_flag[i]!=memSpace[i]:
        return false
```

### 6.The virtual machine finishes running and returns true

```c++
case 0xab:return true;
```

## exp.py

```python
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
print("de1ctf{",end = '')

for i in range(10):
  temp = enc[i*3]*58*58+enc[i*3+1]*58+enc[i*3+2]
  print("{}{}".format(chr(temp//256),chr(temp%256)),end = '')

print("}",end = '')
```

