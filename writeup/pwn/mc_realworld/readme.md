## pwn - mc_realworld

The challenge was modified based on a minecraft-liked game written in C [fogleman/Craft](https://github.com/fogleman/Craft).

The vulnerability function is `add_messages` located in the client binary. You can use `bindiff` to find it. In the function, there is some codes like:

```
if (text[0] == '@' && strlen(text) > 192) {
    text = text + 1;
    char *body = text + 32;
    size_t length;
    char *plain = base64_decode(body, strlen(body), &length);
    char message[16] = {0};
    memcpy(&message, plain, length);
    printf("%8s", &message);
    return;
}
```

Obviously, an easy stack BOF! Let's use `checksec` to have a look at the protection.

```
Arch:     amd64-64-little
RELRO:    Partial RELRO
Stack:    No canary found
NX:       NX enabled
PIE:      No PIE (0x400000)
```

Okay... A check-in challenge, that's what I'm thinking about.

`add_messages` will be triggled before some messages show on the console in game. Therefore, we can exploit a player's machine by @someone in the chat box. Make sure the length of text message above 192 bytes, also using `base64` to encode.

One more problem, how to get the `flag` from the victim(bot)'s machine. After digging in the binary, I find `client_talk` function. Using it to @attacker(me) follow with the `flag`, we can receive the flag at the client side.

For more details, check the expolit `exp.py`.

`De1CTF{W3_L0vE_D4nge2_ReA1_W0r1d1_CrAft!2233}`

## pwn - mc_realworld

出题人继续挖与mc相关的材料。找到了这个 [fogleman/Craft](https://github.com/fogleman/Craft) 。

游戏还蛮好的，服务端用 python 写，pwn 服务端有点难下手，而且搅屎情况更不好控制，所以打算从客户端处下手。在客户端处，埋下一个简单的 bof，在用户聊天时触发。为了防止选手集体挨打，所以限制了@特定用户时才能触发。

client to client的pwn题变得有趣多了，像极了A&D模式。

回传flag成为一个问题，中间隔着一个server。预设解法是通过聊天功能回传，只能@自己，因为公屏黑名单了关键词 `De1CTF`，防止 flag 意外泄露。

非预期回传方式，参考上面 `mc_logclient` wp 的说明。

漏洞点位于客户端 `add_messages` 函数。你可以通过 `bindiff` 找到它（需要保证编译环境一致，编译器flags一致）。代码大概如下：

```
if (text[0] == '@' && strlen(text) > 192) {
    text = text + 1;
    char *body = text + 32;
    size_t length;
    char *plain = base64_decode(body, strlen(body), &length);
    char message[16] = {0};
    memcpy(&message, plain, length);
    printf("%8s", &message);
    return;
}
```

很明显，简单 bof。

更多细节详见：exp.py。

`De1CTF{W3_L0vE_D4nge2_ReA1_W0r1d1_CrAft!2233}`