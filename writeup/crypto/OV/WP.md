## OV

This is a balanced oil and vinegar scheme. And it has been attacked by [Kipnis and Shamir in 1998](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.120.9564&rep=rep1&type=pdf).

So we can just use Kipnis-Shamir attack to solve this task.



However I made some mistakes in the *hashFunction*. It should be like this:

```python
H = [K.fetch_int(ord(i)) for i in m]
```

But I write it like this:

```python
H = [ord(i) for i in m]
```

So there is a unexpected solution: just send *Iwanttoknowflag!* to sign and send the signed data to get flag.

And thanks to [Mystiz](https://github.com/samueltangz) , he helped me to find out the unexpected solution and improve my solution scripts.

Also thanks to [Hellman](https://github.com/hellman), he reminded me of this mistake too.



Here is the excepted solution:

​	We assume public key is $P: k^n \rightarrow k^o$ , where $o = v = 16,n = o+v$

1. Produce the corresponding symmetric matrices for the homogeneous quadratic parts of public key's polynomials: $W_1,W_2,...,W_o$. Randomly choose two linear combination of $W_1,W_2,...,W_o$ and still denote them as $W_1$ and $W_2$ in which $W_1,W_2$ is invertible. Calculate $W_{12} = W_1 * W^{-1}_2$.
2. Compute the minimal polynomial of $W_{12}$ and find its linear factor of multiplicity 1. Denote such factor as $h(x)$. Compute $h(W_{12})$ and its corresponding kernel.
3. For each vector $O$ in the kernel of step 2, use $OW_iO=0$, $(1 \leq i \leq o)$  to test if $O$ belongs to the hidden oil space. Choose linear dependent vectors among them and append them to set $T$.
4. If $T$ contains only one vector or nothing, go back to step 1.
5. If necessary, find more vectors in $T:O_3,O_4,...$ Calculate $K_{O_1} \bigcap ... \bigcap K_{O_t}$ to find out the hidden Oil space in which $K_{O_t}$ is a space from which the vectors $x$ satisfy that $O_tW_ix=0$, $(1 \leq i \leq o)$.
6. Extract a basis of hidden Oil space and extend it to a basis of $k^n$ and use it to transform the public key polynomials to basic Oil-Vinegar polynomials form.



This write up doesn't write the whole content of Kipnis-Shamir attack, if you are interesting in it, you can see the papers in reference. Thanks.



PS: I have fixed these mistakes including word spelling mistake and generated the new source code. You can try to solve this task.



Reference:

http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.120.9564&rep=rep1&type=pdf

https://link.springer.com/content/pdf/10.1007%2F978-3-642-03317-9_11.pdf

https://link.springer.com/chapter/10.1007/978-3-319-38898-4_4

https://github.com/dsm501/Multivariate-cryptography-/blob/master/UOV Scheme.sagews