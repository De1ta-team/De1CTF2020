## Misc_Chowder

There is a `Misc_Chowder.pcap` given.Use wireshark to open it. Export the HTTP objects. You can see the type `multipart/form-data`. There are some data in them. 

![1588654908630.png](https://i.loli.net/2020/05/06/Ccub47IsZDMRYT9.png)

 Extract the content and you will find a `png` file.(the begin of this png is `89504E47`and the end of this png is `426082`), use `winhex` to  extract it. And then you will get this information.

![123.png](https://i.loli.net/2020/05/06/bNfZDhv3aI4PGnM.png)

Download it and you will get the `readme.zip`.There is a `readme.docx` in it. Change the filename of readme.docx to 123.zip ,open it and you will find the` You_found_me_Orz.zip`.You need to use `brute-force attack` to get the password of ` You_found_me_Orz.zip`.There is a tip here:`The password is composed of six letters, and the two letters at the beginning of the password are D and E.`

And then you can get the password is `DE34Q1`.

![1588656395938.png](https://i.loli.net/2020/05/06/RaTcEAtufyWJZoK.png)

Now you get a new file `You_found_me_Orz.jpg`.Use `notepad++` or `winhex` to open it.You will find `666.jpg`、`flag.txt`、`fffffffflllll.txt`and other files.Change the filename of `You_found_me_Orz.jpg` to `You_found_me_Orz.rar` ,open it and you will get the files except `fffffffflllll.txt`

![1588655950372.png](https://i.loli.net/2020/05/06/UoWJA1RF4zmMdf7.png)

There is a file `flag.txt` in it, which content is 

```
De1CTF{jaivy say that you almost get me!!! }
```

but it's a fake flag and you need to find the real one.

The test point is `ADS steganography` .You can use `Shortcut to NTFS Streams Info` to open it, and you will find the `fffffffflllll.txt` is  hidden in `666.jpg`.

![1588656264938.png](https://i.loli.net/2020/05/06/KvL1X6YP7DedxrR.png)

Extract it and you get the real flag!

```
De1CTF{E4Sy_M1sc_By_Jaivy_31b229908cb9bb}
```