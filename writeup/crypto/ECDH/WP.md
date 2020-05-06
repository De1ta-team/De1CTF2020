## ECDH

In this task we can see a [ECDH]([https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman](https://en.wikipedia.org/wiki/Elliptic-curve_Diffie–Hellman)) system. We can exchange keys and encrypt message to get result. So we can get the exchanged keys by encrypting our message. Also there is a backdoor, if you give server the secret, the server will give you flag.

But the task doesn't check whether the given point is on curve. So we can us [Invalid curve attack](https://web-in-security.blogspot.com/2015/09/practical-invalid-curve-attacks.html) to get secret.

We can construct points not on the given curve with low order by using open source software such as [ecgen](https://github.com/J08nY/ecgen) or [Invalid curve attack algorithm](https://crypto.stackexchange.com/questions/71065/invalid-curve-attack-finding-low-order-points) and use CRT to get secret. Then we can use the generated data to attack the task and get flag.



PS: use *genData.py* to generated *data.txt* locally and use $exp.py$ to attack this chanllenge.



Reference:

[https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman](https://en.wikipedia.org/wiki/Elliptic-curve_Diffie–Hellman)

https://crypto.stackexchange.com/questions/71065/invalid-curve-attack-finding-low-order-points

https://web-in-security.blogspot.com/2015/09/practical-invalid-curve-attacks.html

https://www.iacr.org/archive/pkc2003/25670211/25670211.pdf

https://github.com/J08nY/ecgen

