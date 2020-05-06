## misc - mc_champion

The Minecraft game is modified basing on [TyphoonMC/TyphoonLimbo](https://github.com/TyphoonMC/TyphoonLimbo).

When you login to the game, you are in the Limbo World. Nothing you can do except chatting with other players. After fuzzing, it's not difficult to find out the `/help` command.

```
[ADMIN]
/help -> show the usage
/uuid -> show your uuid
/status -> show your status
/items -> show your items
/exchange -> make some exchange
/shop -> list all category
/shop [category_id] -> list items in category
/buy [item_id] -> buy the item
/use [item_id] -> use your item
/attack -> attack the BOSS
```

Player's items are stored in a golang slice. Each item has five attributes listed below. After a fuzzing, you may figure it out.

> Price / Attack / Shield / HP / Food / XP

The vulnerable function is located in `exhcange` -> `random sell`. It triggles a `pop from slice` liked function which return result in bad sequence caused wrong item pop out.

```
func slicePop(s []int, i uint) (r []int, e int) {
    if len(s) == 0 {
        return []int{}, -1
    }else if len(s) == 1 {
        return []int{}, s[0]
    }
    if i >= uint(len(s)) {
        return s[1:], s[0]
    }
    return append(s[:i], s[i + 1:]...), s[i]
}
```

Our goal is earning enough money (more than $200) and using a TNT to defeat the boss.

Want more details? Have a look on the exploit `exp.go` written in golang.

After won the game, we got the `Encoded Message`. Simply have a `Base32 Decode`. We got Flag Two of this challenge and a hidden command `/MC2020-DEBUG-VIEW:-)`. Next challenge, we will use this command.

`De1CTF{S3cur3_UsAG3_0f-GO_Slice~}`

## misc - mc_champion

此题基于轮子 [TyphoonMC/TyphoonLimbo](https://github.com/TyphoonMC/TyphoonLimbo) 魔改而来。

由于这个轮子的原因，所以数据包与市面上的MC客户端不是特别兼容，会经常掉线，尤其是网络不好的情况。所以这题建议模拟 `1.12` 通讯协议，实现通讯。

当你进入游戏，此时处于虚空时间，除了对话，其他功能都无法使用。熟悉命令行的选手，不难发现 `/help` 命令，这是一个文字游戏。

```
[ADMIN]
/help -> show the usage
/uuid -> show your uuid
/status -> show your status
/items -> show your items
/exchange -> make some exchange
/shop -> list all category
/shop [category_id] -> list items in category
/buy [item_id] -> buy the item
/use [item_id] -> use your item
/attack -> attack the BOSS
```

玩家的物品都存储在一个 `slice` 列表里，而且每一个物品都包含以下属性，fuzz一下也不难发现这点。

> Price / Attack / Shield / HP / Food / XP

漏洞函数位于 `exhcange` -> `random sell`。 这个漏洞是我平时写代码时发现的，他会触发大概像 `slice` 出栈的功能，但是由于返回值顺序的问题，导致返回了错误的值。大致代码如下：

```
func slicePop(s []int, i uint) (r []int, e int) {
    if len(s) == 0 {
        return []int{}, -1
    }else if len(s) == 1 {
        return []int{}, s[0]
    }
    if i >= uint(len(s)) {
        return s[1:], s[0]
    }
    return append(s[:i], s[i + 1:]...), s[i]
}
```

我这里的解法是，通过不断调用此功能，获得足够多的金钱（大于200），然后使用一个TNT去打败boss。

当然，赛后发现还有其他解法，只需要最终打败boss即可。

详情可见 `exp.go`。

当你打败boss，你将得到编码信息。简单地进行 `base32解码` 和 `rot13变换` ，你将得到 flag 和一个隐藏命令 `/MC2020-DEBUG-VIEW:-)`。

`De1CTF{S3cur3_UsAG3_0f-GO_Slice~}`