## web - mc_logclient

It's a `minecraft log web client`.

The `chatting content` of players are stored in `logs/` with their's UUID. The `logs/` is mounted as read-only directory.

A simple `SSTI` with `render_template_string` of `flask`. Almost words are blacklisted. After `python 3.7`, there is a new function `sys.breakpointhook()`, using it to run arbitrary code.

First, saying `payload` showed below in the chat box of minecraft. (Message with a '/' prefix to act as a command, for hiding your `payload` from other players)

The environment is `python 3.8`.

```
/{{[].__class__.__base__.__subclasses__()[133].__init__.__globals__['sys']['breakpointhook']()}}
```

Then, triggle `render_template_string` by visiting `/read?work={work}&filename={uuid}`.

You have 30 seconds to access `/write` for writing the `command` to `pdb`.

More details, have a check on exploit file `exp.go`.

`De1CTF{MC_L0g_C1ieNt-t0-S1mPl3_S2Tl~}`

## web - mc_logclient

这是一个 `minecraft log web client`。可以用于读取所有用户的日志。

默认python3.8环境，iptables禁止对外通讯，当然白名单了icmp，可以使用ping进行外带。（赛后发现出现非预期，由于多个题目环境处于同一网络，有队伍使用 mc 协议的对话功能带出数据）

玩家的日志都存储在 logs 文件夹里，以玩家 uuid 作为文件名。logs 文件夹以 只读方式 挂载到环境里。

一个简单的 ssti，黑名单过滤了大部分关键词。在 `python 3.7` 以后，有一个新的函数 `sys.breakpointhook()` 可以通过它起一个调试器，进行任意代码执行。

赛后发现，由于黑名单不完善出现非预期，可以通过 `\x` 或者 `request.args` 进行绕过，直接进行 ssti，不需要调用 `/write` 功能。

首先我们需要在游戏对话框里，进行先 payload 的操作。开头最好加上 `/` 将 payload 作为命令的形式进行隐藏，防止向其他选手泄露 payload。

payload 如下：

```
/{{[].__class__.__base__.__subclasses__()[133].__init__.__globals__['sys']['breakpointhook']()}}
```

然后访问 `/read?work={work}&filename={uuid}` 触发 ssti。

大概有 30秒 的时间，去调用 `/write` 往 `pdb` 去写命令。

详情可见 `exp.go`。

`De1CTF{MC_L0g_C1ieNt-t0-S1mPl3_S2Tl~}`