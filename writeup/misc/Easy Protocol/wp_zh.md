# Easy Protocol

## hint

hint的文件头是`MSCF`，搜索一下可以知道这就是一个makecab压缩的文件，直接使用expand命令解压得到hint.txt

hint.txt

```
hint1: flag is De1CTF{part1_part2_part3}
hint2: The part1,part2 and part3 is a pure number with a length of 8

have fun!!!!!
```

hint.txt应该是和流量包有关的，暂时先不管

## part1

简单浏览一下数据包，主要把目光投到Kerberos协议和LDAP协议上，简单跟一下LDAP，发现过滤条件是：`(&(&(&(samAccountType=805306368)(servicePrincipalName=*))(samAccountName=De1CTF2020))(!(UserAccountControl:1.2.840.113556.1.4.803:=2)))`，主要是这个`servicePrincipalName=*`，是查询域用户`De1CTF2020`所有存在的SPN

![9.png](https://i.loli.net/2020/05/05/98zZt3wkNfog7Hi.png)

然后后面又有一个TGS-REQ请求

![10.png](https://i.loli.net/2020/05/05/raVzWJtOveiPslk.png)

再回到hint中，应该是要你暴力破解之类的，然后猜测应该是`Kerberoasting`

然后将TGS-REQ中的SPN和票据的`enc-part`提取出来

![8.png](https://i.loli.net/2020/05/05/boYP7hWDpjUnzQV.png)

构造成hashcat支持的hash格式，`$krb5tgs$23$*<USERNAME>$<DOMAIN>$<SPN>*$<FIRST_16_BYTES>$<REMAINING_BYTES>`

然后爆破即可

```
hashcat64.exe -m 13100 $krb5tgs$23$*De1CTF2020$test.local$part1/De1CTF2020*$b9bac2cd9555738bc4f8a38b7aa3b01d$12befde687b62d10d325ebc03e0dd0d6bca1f526240dfa6d23dc5bcafc224591dcf4ba97bf6219cfbe16f1b59d289800fdcc8f051626b7fe0c2343d860087c45b68d329fd1107cebe4e537f77f9eea0834ae8018a4fe8518f1c69be95667fd69dcc590d3d443a8530ff8e38ee7f7b6e378d64a8b43b985bcc20f941947ea9e8463fd7e0fa77f284368b9b489f6d557da1e02990cfc725723e5d452ff6e659717947805b852ad734c5acc8011e535b96cef3af796610196d31c725362f7426e0cf92985ffe0717baaf5066fdba760b90e2c9b7e15bc9a4952cff47d4a092d3be6128997f9ff85dbafb85a5569b5d021b2a23c6371cbdf8beaa68b332e6ba1c1a8dc43c50695498ed8c2dfbf11760af35e1b913cd36b8015df37a146d2696c8b6b5f2ce375f2674acc0ce04aa98b9d21291466ce7a2aeb5a72fda17fa53e5b41df67d3898457d05fc899096092b3aa5bc333cb75eb5eee4b1c33356e72d9d28d6d674a5e47f64c72afb580e8d4f713a5ae265a4c825c39c19313a532a23c27eaf24bcde29c5e65c13cc057e0db72094bcedb6049574e35e511847f460180ddd78f4c9187345b1068bd608ca238c20d200ffa7e3891d076fe6fcef93d044c79f5ec9fb33561a35acf785b2a203df6d07e39161d9d3cedbe6d4394bd2bf43e545acd03f796c7863d684f9db4a5eef070f71e58a4882c2387d0705f4bed32fd7986dd672a15f6cfa56fe127af7c157216b2ea4f61ab7963d9dcaf4bb9222a7cba86d6a5e6c24833ffbf1957d90224764a01e0cb5a90f12dfea4ddaef23e30c2bdafcbcd99031db5d0698c1a050fc679213a8b81b854c08686f43241a4ec937c71cd09c9519fa2bba3aa845c4e84dbd6d9bbc3a62c876fb4c30bfa7960f0f51587ece14a31add698b1b9743e14fc343394f8a346c8e24cc8c26a8f8246f6a68928d0118dea81fea9976af3c57fa4c764f565e458e065d5a2a3dd1b083f7851d4ae1b791ada853e9a20e5b169ea0b8b582711f04df4dad8b461771dda5fca11c3f8f82d85e657bbd57d12cf15c8bbce7ad6cd1ebf540c45aefd4aef2ec828b06f208bd57be6a5529481b9f8b8fad5962e86b349a720ec2a1380ed711ee0261b29383907dae6f7a45d3fff54efae7ace1f4d7193f4a4d932699a41c3deb3ba9934278942e8f09ecd4339de4059dd3ff06b78e773b6ab9826df7ea2a443dddd55cdf79db1f76e2f05105e6cc5f0c4bd494b9556d921c6cb3fa48d1ddd27cf077ebd3e44b716fc74d1115b293e348fb9676e6727a3a97a7c2b86e8b83d8f90b9bf628c71e56aabcac381a32d493db3f255378c498a0bf527a9677cb81ec89911a9b09d6ffe16e2f2de63728439f8275d9f6feac2da860c5aab772034b2b0b962c033f8102ac86b2a9b07a82e9c70be65fe371e9d296afbe0e7272b90256428553c6a4fb0a8f5290098e4dad4021d99a65f2a3fa4ad0d2f ?d?d?d?d?d?d?d?d -a 3 --force
```

得到part1:79345612

## part2

这其实是`AS-REPRoasting`，判定过程如下：

跟进LDAP查询的请求，发现有一个这样的过滤条件`(userAccountControl:1.2.840.113556.1.4.803:=4194304)`

![4.png](https://i.loli.net/2020/05/05/dpPUTgXieY9AGIw.png)

![5.png](https://i.loli.net/2020/05/05/IZRjrLFk8Eldpac.png)

`DONT_REQ_PREAUTH`的值为`4194304`，也就是说这个LDAP请求是查找开启了`Do not require Kerberos preauthentication`的用户，如果用户开启了`Do not require Kerberos preauthentication`那么就可以通过`AS-REPRoasting`去暴力破解这个用户的凭证。

还有一个判断方法是第一步发送AS-REQ请求的时候，AS-REP返回了一个`eRR-PROAUTH-REQUIRED`错误，不过这个方法不完全能判定是`AS-REPRoasting`，因为在默认情况下，`Windows Kerberos`客户端在第一个请求中不包括预身份验证信息，所以在正常认证中也会出现此情况。`eRR-PROAUTH-REQUIRED`只不过是进一步验证我们上面`AS-REPRoasting`的猜测

![6.png](https://i.loli.net/2020/05/05/6jbiXVxd1gYsFMI.png)

猜测是`AS-REPRoasting`过程之后，然后从AS-REP中把票据的`enc-part`部分提取出来

![7.png](https://i.loli.net/2020/05/05/XzlLOxdZofhqIE2.png)

构造成hashcat支持的的格式，`$krb5asrep$23$<PRINCIPAL_NAME>:<FIRST_16_BYTES>$<REMAINING_BYTES>`

然后爆破即可

```
hashcat64.exe -m 18200 $krb5asrep$23$De1CTF2020@test.local:2a00ca98642914e2cebb2718e79cbfb6$9026dd00f0b130fd4c4fd71a80817ddd5aec619a9b2e9b53ae2309bde0a9796ebcfa90558e8aaa6f39350b8f6de3a815a7b62ec0c154fe5e2802070146068dc9db1dc981fb355c94ead296cdaefc9c786ce589b43b25fb5b7ddad819db2edecd573342eaa029441ddfdb26765ce01ff719917ba3d0e7ce71a0fae38f91d17cf26d139b377ea2eb5114a2d36a5f27983e8c4cb599d9a4a5ae31a24db701d0734c79b1d323fcf0fe574e8dcca5347a6fb98b7fc2e63ccb125a48a44d4158de940b4fd0c74c7436198380c03170835d4934965ef6a25299e3f1af107c2154f40598db8600c855b2b183 ?d?d?d?d?d?d?d?d -a 3 --force
```

得到part2:74212345

## part3

一个NTLM认证的过程，将数据包中的`Net-NTLM v2 hash`提取出来爆破即可，有两种方法，第一种方法是将`WWW-Authenticate`头的内容提取出来，第二种方法是直接从数据包中提取`Net-NTLM v2 hash`的各个部分

这里以第一种方法为例，将`WWW-Authenticate`头的内容提取出来，写一个脚本转换为`Net-NTLM v2 hash`即可

参考这篇文章[https://www.innovation.ch/personal/ronald/ntlm.html](https://www.innovation.ch/personal/ronald/ntlm.html)

脚本如下

```python
NTLM="NTLM TlRMTVNTUAADAAAAGAAYAH4AAAAkASQBlgAAAAgACABYAAAAFAAUAGAAAAAKAAoAdAAAAAAAAAC6AQAABYKIogoAY0UAAAAPZ+qOBf/ZoMFgp+YUgxdqNVQARQBTAFQARABlADEAQwBUAEYAMgAwADIAMABXAEkATgAxADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAtZkcwqDVhdD4EzWOqvx0EgEBAAAAAAAAEwy5ECMI1gHSKQvAwlYXqAAAAAACAAgAVABFAFMAVAABAAwARABNADIAMAAxADIABAAUAHQAZQBzAHQALgBsAG8AYwBhAGwAAwAiAGQAbQAyADAAMQAyAC4AdABlAHMAdAAuAGwAbwBjAGEAbAAFABQAdABlAHMAdAAuAGwAbwBjAGEAbAAHAAgAEwy5ECMI1gEGAAQAAgAAAAgAMAAwAAAAAAAAAAAAAAAAEAAA7Ko9RN3EZAJsRTIGgTqvoLkY8q1D1Jfvj7a+sggyWKQKABAAAAAAAAAAAAAAAAAAAAAAAAkAHgBIAFQAVABQAC8AdABlAHMAdAAuAGwAbwBjAGEAbAAAAAAAAAAAAA=="
b64_challenge="NTLM TlRMTVNTUAACAAAACAAIADgAAAAFgomiVohvkPy3Pe0AAAAAAAAAAIIAggBAAAAABgOAJQAAAA9UAEUAUwBUAAIACABUAEUAUwBUAAEADABEAE0AMgAwADEAMgAEABQAdABlAHMAdAAuAGwAbwBjAGEAbAADACIAZABtADIAMAAxADIALgB0AGUAcwB0AC4AbABvAGMAYQBsAAUAFAB0AGUAcwB0AC4AbABvAGMAYQBsAAcACAATDLkQIwjWAQAAAAA="
challenge= b64_challenge[5:].decode("base64")[24:24+8].encode("hex")
message = NTLM[5:].decode("base64")

def msg2str(msg,start,uni=True):
    len = ord(msg[start+1])*256 + ord(msg[start])
    offset = ord(msg[start+5])*256 + ord(msg[start+4])
    if uni:
        return (msg[offset:offset+len]).replace("\x00","")
    else:
        return msg[offset:offset+len]


user = msg2str(message,36)
domain = msg2str(message,28)
response = msg2str(message,20,False)
NTProofStr = response[0:16].encode("hex")
blob = response[16:].encode("hex")

print("{user}::{domain}:{challenge}:{NTProofStr}:{blob}".format(user=user,domain=domain,challenge=challenge,NTProofStr=NTProofStr,blob=blob))
```

得到`Net-NTLM v2 hash`

```
De1CTF2020::TEST:56886f90fcb73ded:b5991cc2a0d585d0f813358eaafc7412:0101000000000000130cb9102308d601d2290bc0c25617a80000000002000800540045005300540001000c0044004d0032003000310032000400140074006500730074002e006c006f00630061006c000300220064006d0032003000310032002e0074006500730074002e006c006f00630061006c000500140074006500730074002e006c006f00630061006c0007000800130cb9102308d60106000400020000000800300030000000000000000000000000100000ecaa3d44ddc464026c453206813aafa0b918f2ad43d497ef8fb6beb2083258a40a0010000000000000000000000000000000000009001e0048005400540050002f0074006500730074002e006c006f00630061006c000000000000000000
```

然后hashcat爆破即可

```
hashcat64.exe -m 5600 De1CTF2020::TEST:56886f90fcb73ded:b5991cc2a0d585d0f813358eaafc7412:0101000000000000130cb9102308d601d2290bc0c25617a80000000002000800540045005300540001000c0044004d0032003000310032000400140074006500730074002e006c006f00630061006c000300220064006d0032003000310032002e0074006500730074002e006c006f00630061006c000500140074006500730074002e006c006f00630061006c0007000800130cb9102308d60106000400020000000800300030000000000000000000000000100000ecaa3d44ddc464026c453206813aafa0b918f2ad43d497ef8fb6beb2083258a40a0010000000000000000000000000000000000009001e0048005400540050002f0074006500730074002e006c006f00630061006c000000000000000000 ?d?d?d?d?d?d?d?d -a 3 --force
```

得到part为`74212345`

所以最终flag为：De1CTF{79345612_15673223_74212345}，上面的3个部分都是有工具可以提取hash的，篇幅有限这里就不过多演示了。

## END

其实Part1和Part2也不一定说是攻击过程，正常域认证出现这样的数据包也是很正常不过的，所以我才在我在中间加上了LDAP的查询语句，是想要选手快速定位数据包。还有就是密码长度设置的也不是很长，我这边跑完3个部分用时不到`1分钟`，有的队拿超算来跑，还有老外拿矿机来跑，看来我这题是真有“价值”啊233333