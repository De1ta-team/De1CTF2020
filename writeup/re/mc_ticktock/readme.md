## reverse - mc_ticktock

Previously on the challenge, we got a hidden command `/MC2020-DEBUG-VIEW:-)`. We could read player's log file by their's UUID. Of course, it's a classical directory traversal attack here to read any file on the challenge environment.

Let's read the service binary file `../../../../../../../proc/self/exe`, and reverse it. (`go run exp.go types.go crypt.go -s1`)

In `main_main` function, there is some code like:

```
_, err := os.Stat("webserver")
if err != nil {
    log.Fatal("webserver not found")
}
```

Go on, and read the web service binary file `../../../../../../../proc/self/cwd/webserver`, and reverse it. (`go run exp.go types.go crypt.go -s2`)

You will found three hidden functions.

1. `http://:80/ticktock?text={text}`

It will have a Modified-SM4 encryption of the {text}, and compare the cipher-text with the prefix one. If they match, you will have 20 minutes (One day-night cycle in Minecraft World) to access function two and three. In the meantime, the plain text contains the flag of this challenge.

```
KEY := Sha256([]byte("de1ctf-mc2020"))
NONCE := Sha256([]byte("de1ta-team"))[:24]
c, _ := crypt.NewCipher(KEY[:16])
s := cipher.NewCFBEncrypter(c, NONCE[:16])
plain := []byte("example plain text")
buff := make([]byte, len(plain))
s.XORKeyStream(buff, plain)
```

2. `http://:80/webproxy`

It's a custom proxy service. You can use it to make HTTP request or do a TCP scanning. Remaining three challenges `mc_realworld` & `mc_logclient` & `mc_noisemap` need this proxy to access the web service.

How to use? Make a POST request to this URL. The POST body should be encrypted using `chacha20` cipher.

```
KEY := Sha256([]byte("de1ctf-mc2020"))
NONCE := Sha256([]byte("de1ta-team"))[:24]
cipher, _ := chacha20.NewUnauthenticatedCipher(KEY[:], NONCE[:])
body := []byte("127.0.0.1:80|GET /assets/ HTTP/1.1\r\nHost: 127.0.0.1\r\n\r\n")
buff := make([]byte, len(body))
cipher.XORKeyStream(buff, body)
```

3. `tcp://:8080/`

It's a custom TCP proxy service to access the game service of challenge `mc_realworld`. Inbound traffic and outbound traffic are both using `chacha20` cipher to encrypt which mentioned above.

To get the flag, try `go run exp.go types.go crypt.go -s3`.

`De1CTF{t1Ck-t0ck_Tlck-1ocK_MC2O20_:)SM4}`

## reverse - mc_ticktock

上一题提到的 `/MC2020-DEBUG-VIEW:-)` 隐藏命令，是管理员用于读取指定 `uuid` 玩家 `log日志文件` 的命令。

很容易联想到 `目录穿越` 去实现 `任意文件读取`。

接下来我们可以读取以及逆向 `../../../../../../../proc/self/exe` (`go run exp.go types.go crypt.go -s1`)

文件含有符号表。

在 `main_main` 函数开头可以找到以下代码。

```
_, err := os.Stat("webserver")
if err != nil {
    log.Fatal("webserver not found")
}
```

然后我们继续读 `../../../../../../../proc/self/cwd/webserver` (`go run exp.go types.go crypt.go -s2`)

文件没有符号表，可以使用 [IDAGolangHelper](https://github.com/sibears/IDAGolangHelper) 进行恢复。

文件有以下三个功能。

1. `http://:80/ticktock?text={text}`

这里会有一个修改过的 SM4 加密算法，会对 {text} 进行加密，然后返回密文，同时与预设密文进行比较。比较相同，会将你的ip记录下来，然后你才能使用功能二和功能三，此时明文就是本题的flag值。

记录ip的表每20分钟（20分钟是mc里一昼夜的时间）清空一次。

加密过程大致如下：

```
KEY := Sha256([]byte("de1ctf-mc2020"))
NONCE := Sha256([]byte("de1ta-team"))[:24]
c, _ := crypt.NewCipher(KEY[:16])
s := cipher.NewCFBEncrypter(c, NONCE[:16])
plain := []byte("example plain text")
buff := make([]byte, len(plain))
s.XORKeyStream(buff, plain)
```

2. `http://:80/webproxy`

由于平时在开发网络协议，所以出题时也写了个代理，作为考点，想让选手访问内部网络的题。然后没想到有点难度，最后比赛过程中，这部分被临时砍掉了，出题人翻车了。

使用这个代理功能，可以实现 `http代理` 和 `端口扫描` 的功能。

剩下三道题 `mc_realworld` & `mc_logclient` & `mc_noisemap` 都需要使用这个代理去访问。

三道题的ip，可以使用 `/MC2020-DEBUG-VIEW:-) ../../../../../etc/hosts` 读取 `/etc/hosts` 来获取。

如何使用呢？发 POST 请求，POST 请求 BODY 使用 `chacha20` 加密。加密过程如下：

```
KEY := Sha256([]byte("de1ctf-mc2020"))
NONCE := Sha256([]byte("de1ta-team"))[:24]
cipher, _ := chacha20.NewUnauthenticatedCipher(KEY[:], NONCE[:])
body := []byte("127.0.0.1:80|GET /assets/ HTTP/1.1\r\nHost: 127.0.0.1\r\n\r\n")
buff := make([]byte, len(body))
cipher.XORKeyStream(buff, body)
```

3. `tcp://:8080/`

一个自定义TCP代理，用于 `mc_realworld` 的游戏服务。双向流量使用上面提到的 `chacha20` 加密。

使用命令 `go run exp.go types.go crypt.go -s3`，可以得到 flag。

`De1CTF{t1Ck-t0ck_Tlck-1ocK_MC2O20_:)SM4}`