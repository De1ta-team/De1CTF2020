中文 | [en](./writeup_en.md)

# QueueVirtualMachine

## VirtualMachine

`unsigned char flag[] = "de1ctf{Innocence_Eye&Daisy*}";`

这是一个基于队列的虚拟机。

虚拟机的结构如下：

```c++
class QueueVirtualMachine{
public:
    QueueVirtualMachine();
    QueueVirtualMachine(unsigned char*);
    ~QueueVirtualMachine();
    bool run();
    void printQueueMemSpace(); //用于获取调试信息
    void printMemSpace();      //用于获取调试信息
private:
    int head,tail;         //队列的头，尾指针
    unsigned short reg;    //用于计算分组base58的寄存器
    unsigned char *queueMemSpace;//队列空间
    unsigned char *memSpace;     //内存空间
    unsigned char *codeSpace;    //代码段
    unsigned char *tempString;   //字符串缓冲区
};
```



虚拟机的指令如下：

14 xx

将一个数字压入队列的尾部

15

丢弃一个队尾元素

20 xx

将队列头部的一个字节放入`memSpace[xx]`的位置

2a xx

将`memspace[xx]`的一个字节压入队列尾部

2b

取队列头部的一个数据作为索引，将memspace[]的一个字节压入队列尾部

2c

取队列头部的一个数据作为索引，将队列中的下一个字节放入memspace[]

30

先左移reg 8位，然后reg加上队尾元素

31 xx

寄存器中的short除以xx,余数入队列，商在reg中

32

取队列头部的一个byte作为table[]的索引取值，取值结果入队列

33

取队列头部的两个数据相加，结果入队列

34

取队列头部的两个数据相减，结果入队列。

注意，减数在队首

35

取队列头部的两个数据相×，结果入队列

36

寄存器中的数据入队列，并清空寄存器

37

取队列头部的两个数据相异或，结果入队列

3a

读入一个字符串，字符串放在缓冲区，字符串长度入队列

40 xx

取队列头部的一个数字，如果该数字【不】为0，则

`op -= xx`

41

缓冲区中的字符串入队列，清空缓冲区

ab

指令执行完毕，返回true

ff

如果队列头部的数据不为0，则虚拟机返回bool值`false`

## 算法设计

### 1.读取字符串、检测长度、移入memSpace

```c
    //cin>>tempString;
    0x3a,
    //if(strlen(tempString)!=28)return false;
    0x14,28,
    0x34,
    0xff,
    //将缓冲区中暂存的字符串移入缓冲区
    0x41,
    //从队列中移入内存
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

### 2. 检测flag的格式

下面这几个检测分布在虚拟机指令的各个角落

```c++
    0x2a,0x19,
    0x14,'d',
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
    0x14,'c',
    0x34,
    0xff,
    0x14,'t',
    0x34,
    0xff,
    0x2a,0x1e,
    0x14,'f',
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

花指令：

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

### 3.将flag包装内的20个字符分成10组，分组进行base58编码

机器码太长了，这里就放个伪码

需要注意的是，虽然用的table是64位长,但是使用的算法是base58而不是base64

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

### 4.分组加密

然后不知道咋的，突发奇想吧，搞了轮加密，分组进行的。

模加，模减，异或这三种运算都是可逆的。

```python
for(int i = 0,i<30,i+=3){
  memSpace[0x40+i+1] = memSpace[0x40+i+1]+memSpace[0x40+i+0];
  memSpace[0x40+i+2] = memSpace[0x40+i+2]-memSpace[0x40+i+1];
  memSpace[0x40+i+0] = memSpace[0x40+i+0]^memSpace[0x40+i+2];
}
```



### 5.对加密后的结果进行检测

不放机器码的理由同上。

```cpp
enc_flag = [0x7a,0x19,0x4f,0x6e,0xe,0x56,0xaf,0x1f,0x98,0x58,0xe,0x60,0xbd,0x42,0x8a,0xa2,0x20,0x97,0xb0,0x3d,0x87,0xa0,0x22,0x95,0x79,0xf9,0x41,0x54,0xc,0x6d]
for i in range(len(enc_flag)):
    if enc_flag[i]!=memSpace[i]:
        return false
```

### 6.虚拟机运行完毕，返回true

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

