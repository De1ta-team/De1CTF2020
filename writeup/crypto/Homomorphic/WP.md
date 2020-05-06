## Homomorphic

This is a homomorphic encryption crypto system. We can use CCA to leak secret key and attack it.

Here is the solution:

1. Let : $M = \delta/4 + 20$ , where 20 is a number large enough to cover up the noise. 

2. Let: $t_1 = Mx^i,t2 = M$

3. Let ciphertext: $c_0 = pk[0] + t_1,c1 = pk[1]+t_2$

4. Send $c = (c0,c1)$ to server

5. The server will do this: $c_0+c_1s = pk[0]+t_1+(pk[1]+t_2)s = -(as+e)+t_1+(a+t_2)s=e+t_1+t_2s$

   so the decryption result is all 0 except for the i-th bit, and the i-th bit is equal to the i-th bit of secret key $s$

6. Append the i-th bit of secret key $s$ to result array and back to step 1 until recover all the bits of secret key $s$

7. Use the secret key to decrypt flag



Also because the task has a decrypt function with bad check function. We can use many other ways to decrypt flag too. Such as add a $q$ to the items of input $c0$ and $c1$,  add other small numbers or etc.



Reference:

https://arxiv.org/pdf/1906.07127.pdf

https://www.slideshare.net/ssuserbd9135/danger-of-using-fully-homomorphic-encryption-a-look-at-microsoft-seal-cansecwest2019

https://github.com/edwardz246003/danger-of-using-homomorphic-encryption

