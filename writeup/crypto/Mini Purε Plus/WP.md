## Mini Purε Plus

[Mini Purε](https://github.com/De1ta-team/De1CTF2019/tree/master/writeup/crypto/Mini Purε) is the crypto challenge of De1CTF 2019, this year I try to add the *ROUND* and give you data to attack.

Here is the solution:

Assume the input is $(C,x)$ , the output is $(C_L,C_R)$, then we can easily get the coefficients of $x^{3^{m-1}-1}$ and $x^{3^{m-1}-3}$ in $C_R$ is  $k0$ and ${k0}^3 + k1 + C$ , where $C$ is a constant，$x$ is a variable and $k0,k1$ are the first and second round keys.

So we can use [Square attack](https://en.wikipedia.org/wiki/Integral_cryptanalysis) to find this:
$$
\sum_{x\in F_{2^n}}x^{2^{n} - 3^{m-1}}C_R(x) = k0
$$

$$
\sum_{x\in F_{2^n}}x^{2^{n} - 3^{m-1}-2}C_R(x) = k0^3 + k1 + C
$$

where $n=24,m=16$

Then we can get $k0,k1$ and get all keys to decrypt flag.

And thanks to [Redbud](https://redbud.info/ctfteam.html), they provided an improved interpolation attack method. It also works.



PS: Please download *pt.txt* and *ct.txt* from the address in *pt_ct_download.txt*.



Reference:

https://en.wikipedia.org/wiki/Integral_cryptanalysis

https://link.springer.com/content/pdf/10.1007%2F978-3-642-03317-9_11.pdf



