#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# @Author: impakho
# @Date:   2020/04/19
# @Github: https://github.com/impakho

import sys, math

table_bits = {
    0b0001: 32,
    0b0010: 40,
    0b0011: 48,
    0b0100: 56,
    0b0101: 64,
    0b0110: 80,
    0b0111: 96,
    0b1000: 112,
    0b1001: 128,
    0b1010: 160,
    0b1011: 192,
    0b1100: 224,
    0b1101: 256,
    0b1110: 320
}

table_sample = {
    0b00: 44.1,
    0b01: 48,
    0b10: 32
}

def toSize(size):
    return (( size[0] & 0x7F ) << 21) + \
        (( size[1] & 0x7F ) << 14) + \
        (( size[2] & 0x7F ) << 7) + \
        ( size[3] & 0x7F )

def toInt(byte):
    return (byte[0] << 24) + \
        (byte[1] << 16) + \
        (byte[2] << 8) + \
        byte[3]

def toFrameSize(crc, bits, sample, padding):
    return math.floor(1152 / 8 * table_bits[bits] / table_sample[sample] + padding + 4 * (crc ^ 1))

def encode(path, msg):
    # msg
    msg = ''.join(format(ord(x), 'b').rjust(8, '0') for x in msg)[::-1].rstrip('0')

    # open
    rfp = open(path, 'rb')
    wfp = open(path + '.encode.mp3', 'wb')

    # file_id
    file_id = rfp.read(3)
    if file_id != b'ID3':
        raise Exception('not a valid mp3 file')
    wfp.write(file_id)

    # ver
    ver = rfp.read(1)
    if ver != b'\x03':
        raise Exception('not a valid mp3 file')
    wfp.write(ver)

    # rev
    rev = rfp.read(1)
    wfp.write(rev)

    # flag
    flag = rfp.read(1)
    wfp.write(flag)

    # size
    size = rfp.read(4)
    wfp.write(size)

    # tags
    tags = rfp.read(toSize(size))
    wfp.write(tags)

    # frames
    while True:
        frame_head = rfp.read(4)
        if frame_head[:2] != b'\xff\xfa' and frame_head[:2] != b'\xff\xfb':
            wfp.write(frame_head)
            break

        crc = frame_head[1] & 1
        bits = frame_head[2] >> 4
        sample = (frame_head[2] >> 2) & 3
        padding = (frame_head[2] >> 1) & 1
        frame_size = toFrameSize(crc, bits, sample, padding)
        frame_data = rfp.read(frame_size - 4)

        if not crc:
            frame_head = frame_head[:1] + bytes([frame_head[1] & 0xfe]) + frame_head[2:]
            frame_data = frame_data[:-4]

        if len(msg) > 0:
            frame_head = frame_head[:2] + bytes([(frame_head[2] & 0xfe) + int(msg[0])]) + frame_head[3:]
            msg = msg[1:]

        wfp.write(frame_head)
        wfp.write(frame_data)
    
    other_data = rfp.read()
    wfp.write(other_data)

    # close
    rfp.close()
    wfp.close()

def decode(path):
    # msg
    msg = ''

    # open
    rfp = open(path, 'rb')

    # file_id
    file_id = rfp.read(3)
    if file_id != b'ID3':
        raise Exception('not a valid mp3 file')

    # ver
    ver = rfp.read(1)
    if ver != b'\x03':
        raise Exception('not a valid mp3 file')

    # rev
    rev = rfp.read(1)

    # flag
    flag = rfp.read(1)

    # size
    size = rfp.read(4)

    # tags
    tags = rfp.read(toSize(size))

    # frames
    while True:
        frame_head = rfp.read(4)
        if frame_head[:2] != b'\xff\xfa' and frame_head[:2] != b'\xff\xfb':
            break

        crc = frame_head[1] & 1
        bits = frame_head[2] >> 4
        sample = (frame_head[2] >> 2) & 3
        padding = (frame_head[2] >> 1) & 1
        frame_size = toFrameSize(crc, bits, sample, padding)

        frame_data = rfp.read(frame_size - 4)

        msg = str(frame_head[2] & 1) + msg

    # close
    rfp.close()

    # print msg
    msg = msg.lstrip('0')
    if len(msg) % 8 != 0:
        msg = msg.rjust((int(len(msg) / 8) + 1) * 8, '0')
    msg = ''.join(chr(int(''.join(x), 2)) for x in zip(*[iter(msg)]*8))
    print(msg)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('hide message into mp3 file:')
        print(' ' * 4, 'python3', __file__, '<file>', '<message>')
        print('')
        print('read message from mp3 file:')
        print(' ' * 4, 'python3', __file__, '<file>')

    if len(sys.argv) == 3:
        encode(sys.argv[1], sys.argv[2])

    if len(sys.argv) == 2:
        decode(sys.argv[1])