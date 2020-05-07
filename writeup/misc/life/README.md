## Life
No Game No Life!

![87821588769450_.pic_hd.jpg](https://i.loli.net/2020/05/06/BWRS5XzCgJfqh9o.jpg)

### Hints
1. Game of Life.

### Flag
De1CTF{l3t_us_s7art_th3_g4m3!}

### Solution
1. Separate zip from jpg;
2. There is a monochrome in the zip file, and another encrypted zip;
3. Use the monochrome as the input to the Conway life game for the first round, you will get a qrcode, scan and you the get the password for the zip;
4. Unzip, and you will get a plain text file
5. Reverse the text in the pilf.txt, base64 decode , reverse, HEX to ASCII and you will get the flag

### Note
The main problem of this game is hard to froge the data to the Conway Life Game. And I presume that machine learning maybe helpful

So Conway Life game will be the trap for player.