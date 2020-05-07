## Life
No Game No Life!

![87821588769450_.pic_hd.jpg](https://i.loli.net/2020/05/06/BWRS5XzCgJfqh9o.jpg)

### Hints
1. Game of Life.

### Flag
De1CTF{l3t_us_s7art_th3_g4m3!}

### Solution
1. 从jpg中分离出题目本体的zip;
2. zip内含一张黑白图片，以及另一个加密的zip;
3. 将黑白图片作为康威生命游戏的输入跑一回合，得到qrcode，扫码得到zip的密码;
4. 解压zip，内含一个文本文件;
5. 将pilf.txt中的文本反转，debase64，再反转，HEX to ASCII，得到flag.

### Note
这玩意主要是数据很难造，我花了好几天也没整出来怎么逆康威生命游戏状态，搜了一下好像是要ML。

~~不如直接把逆康威生命游戏出成一道炼丹题~~

现在用的密码是之前某次decoding时见到的，我把它反色过了所以直接搜是搜不出来的。

如果剩下几天能整出来的话就换个图。