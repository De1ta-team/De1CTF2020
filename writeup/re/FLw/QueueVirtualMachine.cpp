#include<iostream>
#include<string>
#include<algorithm>
#include<cstring>
#include<fstream>
#include<cstdlib>
using namespace std;

unsigned char table[] = "0123456789QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm+/=";
unsigned char testCode[] = {
    0x3a,
    0x14,28,
    0x34,
    0xff,
    0x41,
    0x20,0x19,//d
    0x20,0x1a,//e
    0x20,0x1b,//1
    0x20,0x1c,//c
    0x20,0x1d,//t
    0x20,0x1e,//f
    0x20,0x1f,//{
    0x20,0x20,
    0x20,0x21,
    0x20,0x22,
    0x20,0x23,
    0x20,0x24,
    0x20,0x25,
    0x20,0x26,
    0x20,0x27,
    0x20,0x28,
    0x20,0x29,
    0x20,0x2a,
    0x20,0x2b,
    0x20,0x2c,
    0x20,0x2d,
    0x20,0x2e,
    0x20,0x2f,
    0x20,0x30,
    0x20,0x31,
    0x20,0x32,
    0x20,0x33,
    0x20,0x34,//}

    0x2a,0x19,
    0x14,'D',
    0x34,
    0xff,

    //Ñ­ï¿½ï¿½1ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½base58
    //int i = 0
    0x14,0x0,
    0x20,0xff,//ï¿½ï¿½ï¿½ï¿½Ñ­ï¿½ï¿½Ê±Ê¹ï¿½ÃµÄ±ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½memSpace[0xff]ï¿½ï¿½

    0x2a,0x1a,
    0x14,'e',
    0x34,
    0xff,
    //reg = (reg<<8)+memSpace[i+i+0x20]
    0x14,0x20,
    0x2a,0xff,
    0x2a,0xff,
    0x33,
    0x33,
    0x2b,
    0x30,

    //reg = (reg<<8)+memSpace[i+0x21]
    0x14,0x21,
    0x2a,0xff,
    0x2a,0xff,
    0x33,
    0x33,
    0x2b,
    0x30,

    //int j = 3
    0x14,0x3,
    0x20,0xfe,
    //push( 0x3f+i*3+j )
    0x2a,0xff,
    0x14,3,
    0x35,
    0x2a,0xfe,
    0x14,0x3f,
    0x33,
    0x33,
    //base58(reg)
    0x31,58,
    //memSpace[0x3f+i*3+j] = base58(reg)
    0x2c,
    //j--
    0x14,0x1,
    0x2a,0xfe,
    0x34,
    0x20,0xfe,
    //if(j == 0)jumpout
    0x2a,0xfe,
    0x40,23,
    //i+=2
    0x2a,0xff,
    0x14,1,
    0x33,
    0x20,0xff,
    //if(i==20)jumpout
    0x2a,0xff,
    0x14,10,
    0x34,
    0x40,61,
    0x2a,0x1d,
    0x14,'T',
    0x34,
    0xff,
    0x2a,0x1e,
    0x14,'F',
    0x34,
    0xff,
    0x2a,0x1f,
    0x14,'{',
    0x34,
    0xff,
    //ï¿½Ú¶ï¿½ï¿½ï¿½Ñ­ï¿½ï¿½:ï¿½ï¿½ï¿½ï¿½ï¿½Üºï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ç·ï¿½ï¿½ï¿½È?
    //×ª»¯Îªbase58×Ö·û´®

    //int i = 0
    0x14,0x0,
    0x20,0xff,
    //reg = 0
    0x36,
    0x15,
    //memspace[0x40+i] = table[memSpace[0x40+i]]
    0x2a,0xff,
    0x14,0x40,
    0x33,
    0x2b,
    0x32,
    0x30,
    0x2a,0xff,
    0x14,0x40,
    0x33,
    0x36,
    0x2c,
    //i+=1
    0x2a,0xff,
    0x14,0x1,
    0x33,
    0x20,0xff,
    0x2a,0xff,
    0x14,30,
    0x34,
    0x40,29,
    0x2a,0x1c,
    0x14,'C',
    0x34,
    0xff,
    0x2a,0x1b,
    0x14,'1',
    0x34,
    0xff,
    //»ìÏý»¯¼ÓÃÜ
    //int i = 0;
    0x14,0x0,
    0x20,0xff,
    //reg = 0
    0x14,0x0,
    0x14,0x0,
    0x30,
    0x30,
    //memSpace[0x40+i+1] -= memSpace[0x40+i+0]
    0x2a,0xff,
    0x14,0x40,
    0x2a,0xff,
    0x14,0x41,
    0x33,
    0x33,
    0x2b,
    0x2b,
    0x34,
    0x30,
    0x2a,0xff,
    0x14,0x41,
    0x33,
    0x36,
    0x2c,
    //memSpace[0x40+i+2] += memSpace[0x40+i+1]
    0x2a,0xff,
    0x14,0x41,
    0x2a,0xff,
    0x14,0x42,
    0x33,0x33,
    0x2b,
    0x2b,
    0x33,
    0x30,
    0x2a,0xff,
    0x14,0x42,
    0x33,
    0x36,
    0x2c,
    //memSpace[0x40+i] ^= memSpace[0x40+i+2]
    0x2a,0xff,
    0x14,0x40,
    0x2a,0xff,
    0x14,0x42,
    0x33,0x33,
    0x2b,
    0x2b,
    0x37,
    0x30,
    0x2a,0xff,
    0x14,0x40,
    0x33,
    0x36,
    0x2c,
    //i+=3
    0x2a,0xff,
    0x14,0x3,
    0x33,
    0x20,0xff,
    //if(i = 30)jumpout
    0x2a,0xff,
    0x14,30,
    0x34,
    0x40,81,



    0x2a,0x34,
    0x14,'}',
    0x34,
    0xff,
    //¼ì²âÊÖ¶Î
    0x2a,0x40,
    0x14,0x7a,
    0x34,
    0xff,
    0x2a,0x41,
    0x14,0x19,
    0x34,
    0xff,
    0x2a,0x42,
    0x14,0x4f,
    0x34,
    0xff,
    0x2a,0x43,
    0x14,0x6e,
    0x34,
    0xff,
    0x2a,0x44,
    0x14,0xe,
    0x34,
    0xff,
    0x2a,0x45,
    0x14,0x56,
    0x34,
    0xff,
    0x2a,0x46,
    0x14,0xaf,
    0x34,
    0xff,
    0x2a,0x47,
    0x14,0x1f,
    0x34,
    0xff,
    0x2a,0x48,
    0x14,0x98,
    0x34,
    0xff,
    0x2a,0x49,
    0x14,0x58,
    0x34,
    0xff,
    0x2a,0x4a,
    0x14,0xe,
    0x34,
    0xff,
    0x2a,0x4b,
    0x14,0x60,
    0x34,
    0xff,
    0x2a,0x4c,
    0x14,0xbd,
    0x34,
    0xff,
    0x2a,0x4d,
    0x14,0x42,
    0x34,
    0xff,
    0x2a,0x4e,
    0x14,0x8a,
    0x34,
    0xff,
    0x2a,0x4f,
    0x14,0xa2,
    0x34,
    0xff,
    0x2a,0x50,
    0x14,0x20,
    0x34,
    0xff,
    0x2a,0x51,
    0x14,0x97,
    0x34,
    0xff,
    0x2a,0x52,
    0x14,0xb0,
    0x34,
    0xff,
    0x2a,0x53,
    0x14,0x3d,
    0x34,
    0xff,
    0x2a,0x54,
    0x14,0x87,
    0x34,
    0xff,
    0x2a,0x55,
    0x14,0xa0,
    0x34,
    0xff,
    0x2a,0x56,
    0x14,0x22,
    0x34,
    0xff,
    0x2a,0x57,
    0x14,0x95,
    0x34,
    0xff,
    0x2a,0x58,
    0x14,0x79,
    0x34,
    0xff,
    0x2a,0x59,
    0x14,0xf9,
    0x34,
    0xff,
    0x2a,0x5a,
    0x14,0x41,
    0x34,
    0xff,
    0x2a,0x5b,
    0x14,0x54,
    0x34,
    0xff,
    0x2a,0x5c,
    0x14,0xc,
    0x34,
    0xff,
    0x2a,0x5d,
    0x14,0x6d,
    0x34,
    0xff,
    0xab,

    0x0
};
//ï¿½ï¿½ï¿½Ú¶ï¿½ï¿½Ðµï¿½,ï¿½ï¿½ï¿½ß¼ï¿½ï¿½ï¿½ï¿½ï¿½Îªï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿?

class QueueVirtualMachine {
public:
    QueueVirtualMachine();
    QueueVirtualMachine(unsigned char*);
    ~QueueVirtualMachine();
    //void printQueueMemSpace();
    bool run();
    //unsigned char* get_encrypted_0x40();
    //void printMemSpace();
private:
    int head, tail;
    unsigned short reg;
    unsigned char* queueMemSpace;
    unsigned char* memSpace;
    unsigned char* codeSpace;
    unsigned char* tempString;
};
void fw1()
{
    _asm
    {
        call _P1
        _P1 :
        add[esp], 5
            retn
    }
_P2:
    cout << "Welcome 2 de1ctf\n";
    return;
}

int main() {
    fw1();
    _asm
    {
        mov eax, _PE1
        push eax
        push fs : [0]
        mov fs : [0] , esp
        xor ecx, ecx
        div ecx
        retn
        _PE1 :
        mov esp, [esp + 8]
            mov eax, fs : [0]
            mov eax, [eax]
            mov eax, [eax]
            mov fs : [0] , eax
            add esp, 8
    }
    cout << "Please input:";
    QueueVirtualMachine* vm = new QueueVirtualMachine(testCode);
    _asm
    {
        jz _P2
        jnz _P2
        _P1 :
        __emit 0xE8
    }
_P2:
    bool mark = vm->run();
    _asm
    {
        __emit 0xEB
        __emit 0xFF
        __emit 0xC0
        __emit 0x48
    }
    if (mark)
        cout << "Well Done!\n";
    else {
        _asm
        {
            __emit 0xEB
            __emit 0xFF
            __emit 0xC0
            __emit 0x48
        }
        cout << "Try again!\n";
    }
    system("pause");
    //vm->printQueueMemSpace();
    //system("pause");
    //vm->printMemSpace();
    //system("pause");
    //unsigned char* encrypted = vm->get_encrypted_0x40();
    //for(int i = 0;i < 30;++i){
    //	cout<<"0x"<<hex<<(int)encrypted[i]<<",";
    //}
    delete vm;
    return 0;
}

QueueVirtualMachine::QueueVirtualMachine() {
    cout << "ERROR!";
    return;
}

QueueVirtualMachine::QueueVirtualMachine(unsigned char* codes) :
    queueMemSpace(nullptr),
    head(0),
    tail(0),
    reg(0),
    memSpace(nullptr),
    codeSpace(codes) {
    queueMemSpace = new unsigned char[0x100];
    memSpace = new unsigned char[0x100];
    tempString = new unsigned char[512];
    memset(queueMemSpace, 0, 0x100);
    memset(memSpace, 0, 0x100);
    memset(tempString, 0, 512);
    return;
};

QueueVirtualMachine::~QueueVirtualMachine() {
    delete[] queueMemSpace;
    delete[] memSpace;
    delete[] tempString;
    return;
}

bool QueueVirtualMachine::run() {
    for (unsigned int op = 0;codeSpace[op] != 0;) {
        tail = tail == 0x100 ? 0 : tail;
        head = head == 0x100 ? 0 : head;
        //cout<<(int) op<<": "<<hex<<(int)codeSpace[op]<<'\n';
        switch (codeSpace[op]) {
        case 0x14: {//ï¿½ï¿½Ò»ï¿½ï¿½ï¿½Ö½ï¿½Ñ¹ï¿½ï¿½ï¿½ï¿½ï¿? ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½È£ï¿½2bytes
            queueMemSpace[tail++] = codeSpace[op + 1];
            op += 2;
            break;
        }
        case 0x15: {//ï¿½ï¿½ï¿½ï¿½Ò»ï¿½ï¿½ï¿½ï¿½Î²Ôªï¿½ï¿½
            ++head;
            ++op;
            break;
        }
        case 0x20: {//ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í·ï¿½ï¿½ï¿½ï¿½Ò»ï¿½ï¿½ï¿½Ö½Ú·ï¿½ï¿½ï¿½memSpace[xx]ï¿½ï¿½Î»ï¿½Ã£ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½È£ï¿½2bytes
            memSpace[codeSpace[op + 1]] = queueMemSpace[head++];
            op += 2;
            break;
        }

        case 0x2a: { //ï¿½ï¿½`memspace[xx]`ï¿½ï¿½Ò»ï¿½ï¿½ï¿½Ö½ï¿½Ñ¹ï¿½ï¿½ï¿½ï¿½ï¿½Î²ï¿½ï¿?,ï¿½ï¿½ï¿½ï¿½2bytes
            queueMemSpace[tail++] = memSpace[codeSpace[op + 1]];
            op += 2;
            break;
        }

        case 0x2b: {
            queueMemSpace[tail++] = memSpace[queueMemSpace[head++]];
            op++;
            break;
        }
        case 0x2c: {
            unsigned char idx = queueMemSpace[head++];
            head = head == 0x100 ? 0 : head;
            memSpace[idx] = queueMemSpace[head++];
            op++;
            break;
        }

        case 0x30: {//È¡ï¿½ï¿½Í·ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ö½Ú£ï¿½ï¿½ï¿½ï¿½Ò»ï¿½ï¿½shortï¿½ï¿½ï¿½ï¿½Ä´ï¿½ï¿½ï¿½`regs`ï¿½Ð³ï¿½ï¿½ï¿½1bytes
            reg = (reg << 8) + queueMemSpace[head++];
            ++op;
            break;
        }

        case 0x31: {//ï¿½Ä´ï¿½ï¿½ï¿½ï¿½Ðµï¿½shortï¿½ï¿½ï¿½ï¿½xx,ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿?,ï¿½ï¿½ï¿½ï¿½2bytes
            queueMemSpace[tail++] = reg % codeSpace[op + 1];
            reg = reg / codeSpace[op + 1];
            op += 2;
            break;
        }

        case 0x32: {//È¡ï¿½ï¿½ï¿½ï¿½Í·ï¿½ï¿½ï¿½ï¿½Ò»ï¿½ï¿½byteï¿½ï¿½Îªtable[]ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½È¡Öµï¿½ï¿½È¡Öµï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ð£ï¿½ï¿½ï¿½ï¿½ï¿½1bytes
            queueMemSpace[tail++] = table[queueMemSpace[head++]];
            ++op;
            break;
        }

        case 0x33: {//È¡ï¿½ï¿½ï¿½ï¿½Í·ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ó£ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ð£ï¿½ï¿½ï¿½ï¿½ï¿?1byte
            unsigned char first = queueMemSpace[head++];
            head = head == 0x100 ? 0 : head;
            queueMemSpace[tail++] = first + queueMemSpace[head++];
            op++;
            break;
        }
        case 0x34: {//È¡ï¿½ï¿½ï¿½ï¿½Í·ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿?
            unsigned char first = queueMemSpace[head++];
            head = head == 0x100 ? 0 : head;
            queueMemSpace[tail++] = queueMemSpace[head++] - first;
            op++;
            break;
        }
        case 0x35: {//È¡ï¿½ï¿½ï¿½ï¿½Í·ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ë£ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿?
            unsigned char first = queueMemSpace[head++];
            head = head == 0x100 ? 0 : head;
            queueMemSpace[tail++] = first * queueMemSpace[head++];
            op++;
            break;
        }
        case 0x37: {//È¡ï¿½ï¿½ï¿½ï¿½Í·ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ó£ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ð£ï¿½ï¿½ï¿½ï¿½ï¿?1byte
            unsigned char first = queueMemSpace[head++];
            head = head == 0x100 ? 0 : head;
            queueMemSpace[tail++] = first ^ queueMemSpace[head++];
            op++;
            break;
        }
        case 0x3a: {//ï¿½ï¿½ï¿½ï¿½Ò»ï¿½ï¿½ï¿½Ö·ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Î²ï¿½ï¿?,ï¿½ï¿½ï¿½ï¿½Îª1bytes
            cin >> tempString;
            if (strlen((const char*)tempString) >= 0x100)
                return false;
            queueMemSpace[tail++] = strlen((const char*)tempString);
            op++;
            break;
        }

        case 0x40: {//È¡ï¿½ï¿½ï¿½ï¿½Í·ï¿½ï¿½ï¿½ï¿½Ò»ï¿½ï¿½ï¿½ï¿½ï¿½Ö£ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ö²ï¿½Î?0ï¿½ï¿½ï¿½ï¿½op -= xx,ï¿½ï¿½ï¿½ï¿½Îª2bytes
            unsigned char temp = 0;
            temp = queueMemSpace[head++];
            if (temp != 0)
                op -= codeSpace[op + 1];
            else
                op += 2;
            break;
        }
        case 0x41: {
            for (int i = 0;i < strlen((const char*)tempString);++i) {
                queueMemSpace[tail++] = tempString[i];
                tail = tail == 0x100 ? 0 : tail;
            }
            memset(tempString, 0, 512);
            op++;
            break;
        }
        case 0xab: {
            return true;
        }
        case 0xff: {
            unsigned char temp = 0;
            temp = queueMemSpace[head++];
            if (temp != 0)
                return false;
            else
                op++;
            break;
        }
        case 0x36: {
            queueMemSpace[tail++] = reg & 0xff;
            reg = 0;
            ++op;
            break;
        }
        default:
            _asm
            {
                xor eax, eax
                add eax, 2
                ret 0xff
            }       //²âÊÔµÄÊ±ºò°ÑÕâ¸ö×¢ÊÍµô
        }
    }
}

/*void QueueVirtualMachine::printMemSpace() {
    for (int i = 0;i < 0x100;++i) {
        if (memSpace[i] >= 0x20 && memSpace[i] < 0x7f) {
            cout << i << "     " << (char)memSpace[i] << '\n';
        }
        else {
            cout << i << " (int)" << (int)memSpace[i] << '\n';
        }
    }
    return;
}

void QueueVirtualMachine::printQueueMemSpace() {
    for (int i = 0;i < 0x100;++i) {
        if (queueMemSpace[i] >= 0x20 && queueMemSpace[i] < 0x7f) {
            cout << i << "     " << (char)queueMemSpace[i] << '\n';
        }
        else {
            cout << i << " (int)" << (int)queueMemSpace[i] << '\n';
        }
    }
    cout << "head:" << head << '\n';
    cout << "tail:" << tail << '\n';
    return;
}

unsigned char* QueueVirtualMachine::get_encrypted_0x40(){
    return &memSpace[0x40];
}*/
