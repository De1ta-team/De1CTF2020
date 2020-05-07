## Misc_Chowder

赛题给了一个流量包，使用wireshark打开，选择菜单栏“文件-导出对象-HTTP”，可以发现有7个内容类型为`multipart/form-data`，这些都是上传的一些数据。

![1588654908630.png](https://i.loli.net/2020/05/06/Ccub47IsZDMRYT9.png)

把内容提取出来，可以发现有6个是jpg，有一个是png，包含png图片数据的是上面分组号为3075的数据包，把它save保存下来，然后拖进winhex，找到png数据的开头和结尾(此png的文件头为 89504E47 ，文件尾为 426082 )，结合快捷键alt+1、alt+2、ctrl+x即可完成切割，提取得到png图片，得到另一个附件的链接。

![123.png](https://i.loli.net/2020/05/06/bNfZDhv3aI4PGnM.png)

得到一个readme.zip，解压发现有个readme.docx（其实这里本来还设计了一个zip伪加密，但是文件一上传drive.google，伪加密就不见了，不知道为啥）。

在`readme.docx`里发现藏有zip文件，直接把后缀改为zip，即可提取出来`You_found_me_Orz.zip`。这个zip文件需要暴力破解得到密码（可能由于存在缓存的原因，出题人在自己电脑测试的时候爆破出当时设计的6位密码的时间并不长，后面重装了一下软件，发现确实爆破时间很长，于是给了提示“密码是由6位字符组成，开头的2个字符是DE”），爆破得到密码为`DE34Q1`。

![1588656395938.png](https://i.loli.net/2020/05/06/RaTcEAtufyWJZoK.png)

解压得到一个图片`You_found_me_Orz.jpg`，拖进notepad++、winhex等工具可以发现还有里面还有666.jpg、flag.txt、fffffffflllll.txt等文件，并且发现了rar的一些标志。

![1588655950372.png](https://i.loli.net/2020/05/06/UoWJA1RF4zmMdf7.png)

直接把后缀名改为rar即可解压出里面的文件。其中flag.txt

```
De1CTF{jaivy say that you almost get me!!! }
```

是一个假的flag(这点好多老外过来问...)，并且发现fffffffflllll.txt并没有出现，这里考察的是ADS隐写，也可以通过上图当中的`:fffffffflllll.txt`看出一些端倪，因为ADS隐写的一些数据一般都是这样子的`xxx:xxxxxx`。使用`Shortcut to NTFS Streams Info`工具即可看到藏在666.jpg中的ADS隐写数据获得真正的flag。

![1588656264938.png](https://i.loli.net/2020/05/06/KvL1X6YP7DedxrR.png)

提取得到flag为

```
De1CTF{E4Sy_M1sc_By_Jaivy_31b229908cb9bb}
```