BITS 32
            org     0x00888000
            db      0x7F, "ELF"             ; e_ident
            dd      1                                       ; p_type
            dd      0                                       ; p_offset
            dd      $$                                      ; p_vaddr 
            dw      2                       ; e_type        ; p_paddr
            dw      3                       ; e_machine
            dd      _start                  ; e_version     ; p_filesz
            dd      _start                  ; e_entry       ; p_memsz
            dd      4                       ; e_phoff       ; p_flags
_start:
            jmp     __start                 ; e_shoff       ; p_align
            db      0E8h
            dd      0DEADBEEFh
            db      0
            dw      0x34                    ; e_ehsize
            dw      0x20                    ; e_phentsize
            dw      1                       ; e_phnum
            dw      0                       ; e_shentsize
            dw      0                       ; e_shnum
            dw      0                       ; e_shstrndx
__start:
            lea     esp, [esp-45]
            mov     eax, 3
            xor     ebx, ebx
            lea     ecx, [esp]
            mov     edx, 45
            int     0x80
            xor     eax, eax
            call    loop00
loop00:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_00
            db      232, 183, 161, 48
junk0_00:   xor     edi, edi
            jz      junk1_00
            db      235
junk1_00:   xor     ebx, ebx
            jz      junk2_00
            db      235
junk2_00:
loop_body00:mov     cl, byte [esp+edi]
            mov     dl, byte [mA00+edi]
            xor     esi, esi
loop_Gmul00:test    edx, 1
            jz      next0_00
            xor     ebx, ecx
next0_00:   test    ecx, 80h
            jz      next1_00
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_00
next1_00:   shl     cl, 1
next2_00:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul00
            inc     edi
            cmp     edi, 44
            jnz     loop_body00
            cmp     ebx, 200
            setnz   bl
            or      eax, ebx
            call    loop01
mA00:       db      166, 8, 116, 187, 48, 79, 49, 143, 88, 194, 27, 131, 58, 75, 251, 195, 192, 185, 69, 60, 84, 24, 124, 33, 211, 251, 140, 124, 161, 9, 44, 208, 20, 42, 8, 37, 59, 147, 79, 232, 57, 16, 12, 84
loop01:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_01
            db      233, 146
junk0_01:   xor     edi, edi
            jz      junk1_01
            db      232
junk1_01:   xor     ebx, ebx
            jz      junk2_01
            db      235
junk2_01:
loop_body01:mov     cl, byte [esp+edi]
            mov     dl, byte [mA01+edi]
            xor     esi, esi
loop_Gmul01:test    edx, 1
            jz      next0_01
            xor     ebx, ecx
next0_01:   test    ecx, 80h
            jz      next1_01
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_01
next1_01:   shl     cl, 1
next2_01:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul01
            inc     edi
            cmp     edi, 44
            jnz     loop_body01
            cmp     ebx, 201
            setnz   bl
            or      eax, ebx
            call    loop02
mA01:       db      73, 252, 81, 126, 50, 87, 184, 130, 196, 114, 29, 107, 153, 91, 63, 217, 31, 191, 74, 176, 208, 252, 97, 253, 55, 231, 82, 169, 185, 236, 171, 86, 208, 154, 192, 109, 255, 62, 35, 140, 91, 49, 139, 255
loop02:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_02
            db      232, 34
junk0_02:   xor     edi, edi
            jz      junk1_02
            db      234, 117, 41, 196, 137, 36
junk1_02:   xor     ebx, ebx
            jz      junk2_02
            db      235
junk2_02:
loop_body02:mov     cl, byte [esp+edi]
            mov     dl, byte [mA02+edi]
            xor     esi, esi
loop_Gmul02:test    edx, 1
            jz      next0_02
            xor     ebx, ecx
next0_02:   test    ecx, 80h
            jz      next1_02
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_02
next1_02:   shl     cl, 1
next2_02:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul02
            inc     edi
            cmp     edi, 44
            jnz     loop_body02
            cmp     ebx, 204
            setnz   bl
            or      eax, ebx
            call    loop03
mA02:       db      57, 18, 43, 102, 96, 26, 50, 187, 129, 161, 7, 55, 11, 29, 151, 219, 203, 139, 56, 12, 176, 160, 250, 237, 1, 238, 239, 211, 241, 254, 18, 13, 75, 47, 215, 168, 149, 154, 33, 222, 77, 138, 240, 42
loop03:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_03
            db      235
junk0_03:   xor     edi, edi
            jz      junk1_03
            db      234, 248, 149, 156, 63, 216
junk1_03:   xor     ebx, ebx
            jz      junk2_03
            db      232, 143, 42, 117
junk2_03:
loop_body03:mov     cl, byte [esp+edi]
            mov     dl, byte [mA03+edi]
            xor     esi, esi
loop_Gmul03:test    edx, 1
            jz      next0_03
            xor     ebx, ecx
next0_03:   test    ecx, 80h
            jz      next1_03
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_03
next1_03:   shl     cl, 1
next2_03:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul03
            inc     edi
            cmp     edi, 44
            jnz     loop_body03
            cmp     ebx, 116
            setnz   bl
            or      eax, ebx
            call    loop04
mA03:       db      96, 198, 230, 11, 49, 62, 42, 10, 169, 77, 7, 164, 198, 241, 131, 157, 75, 147, 201, 103, 120, 133, 161, 14, 214, 157, 28, 220, 165, 232, 20, 132, 16, 79, 9, 1, 33, 194, 192, 55, 109, 166, 101, 110
loop04:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_04
            db      232
junk0_04:   xor     edi, edi
            jz      junk1_04
            db      232, 67, 137, 109
junk1_04:   xor     ebx, ebx
            jz      junk2_04
            db      233, 61, 147, 60
junk2_04:
loop_body04:mov     cl, byte [esp+edi]
            mov     dl, byte [mA04+edi]
            xor     esi, esi
loop_Gmul04:test    edx, 1
            jz      next0_04
            xor     ebx, ecx
next0_04:   test    ecx, 80h
            jz      next1_04
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_04
next1_04:   shl     cl, 1
next2_04:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul04
            inc     edi
            cmp     edi, 44
            jnz     loop_body04
            cmp     ebx, 124
            setnz   bl
            or      eax, ebx
            call    loop05
mA04:       db      108, 159, 167, 183, 165, 180, 74, 194, 149, 63, 211, 153, 174, 97, 102, 123, 157, 142, 47, 30, 185, 209, 57, 108, 170, 161, 126, 248, 206, 238, 140, 105, 192, 231, 237, 36, 46, 185, 123, 161, 97, 192, 168, 129
loop05:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_05
            db      232
junk0_05:   xor     edi, edi
            jz      junk1_05
            db      233, 134, 25
junk1_05:   xor     ebx, ebx
            jz      junk2_05
            db      233
junk2_05:
loop_body05:mov     cl, byte [esp+edi]
            mov     dl, byte [mA05+edi]
            xor     esi, esi
loop_Gmul05:test    edx, 1
            jz      next0_05
            xor     ebx, ecx
next0_05:   test    ecx, 80h
            jz      next1_05
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_05
next1_05:   shl     cl, 1
next2_05:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul05
            inc     edi
            cmp     edi, 44
            jnz     loop_body05
            cmp     ebx, 94
            setnz   bl
            or      eax, ebx
            call    loop06
mA05:       db      72, 18, 132, 37, 37, 42, 224, 99, 92, 159, 95, 27, 18, 172, 43, 251, 97, 44, 238, 106, 42, 86, 124, 1, 231, 63, 99, 147, 239, 180, 217, 195, 203, 106, 21, 4, 238, 229, 43, 232, 193, 31, 116, 213
loop06:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_06
            db      235
junk0_06:   xor     edi, edi
            jz      junk1_06
            db      233, 250
junk1_06:   xor     ebx, ebx
            jz      junk2_06
            db      234
junk2_06:
loop_body06:mov     cl, byte [esp+edi]
            mov     dl, byte [mA06+edi]
            xor     esi, esi
loop_Gmul06:test    edx, 1
            jz      next0_06
            xor     ebx, ecx
next0_06:   test    ecx, 80h
            jz      next1_06
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_06
next1_06:   shl     cl, 1
next2_06:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul06
            inc     edi
            cmp     edi, 44
            jnz     loop_body06
            cmp     ebx, 129
            setnz   bl
            or      eax, ebx
            call    loop07
mA06:       db      17, 133, 116, 7, 57, 79, 20, 19, 197, 146, 5, 40, 103, 56, 135, 185, 168, 73, 3, 113, 118, 102, 210, 99, 29, 12, 34, 249, 237, 132, 57, 71, 44, 41, 1, 65, 136, 112, 20, 142, 162, 232, 225, 15
loop07:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_07
            db      232, 33, 218, 98
junk0_07:   xor     edi, edi
            jz      junk1_07
            db      232
junk1_07:   xor     ebx, ebx
            jz      junk2_07
            db      232, 170, 71, 52
junk2_07:
loop_body07:mov     cl, byte [esp+edi]
            mov     dl, byte [mA07+edi]
            xor     esi, esi
loop_Gmul07:test    edx, 1
            jz      next0_07
            xor     ebx, ecx
next0_07:   test    ecx, 80h
            jz      next1_07
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_07
next1_07:   shl     cl, 1
next2_07:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul07
            inc     edi
            cmp     edi, 44
            jnz     loop_body07
            cmp     ebx, 127
            setnz   bl
            or      eax, ebx
            call    loop08
mA07:       db      224, 192, 5, 102, 220, 42, 18, 221, 124, 173, 85, 87, 112, 175, 157, 72, 160, 207, 229, 35, 136, 157, 229, 10, 96, 186, 112, 156, 69, 195, 89, 86, 238, 167, 169, 154, 137, 47, 205, 238, 22, 49, 177, 83
loop08:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_08
            db      233
junk0_08:   xor     edi, edi
            jz      junk1_08
            db      232, 238, 117, 98
junk1_08:   xor     ebx, ebx
            jz      junk2_08
            db      235
junk2_08:
loop_body08:mov     cl, byte [esp+edi]
            mov     dl, byte [mA08+edi]
            xor     esi, esi
loop_Gmul08:test    edx, 1
            jz      next0_08
            xor     ebx, ecx
next0_08:   test    ecx, 80h
            jz      next1_08
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_08
next1_08:   shl     cl, 1
next2_08:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul08
            inc     edi
            cmp     edi, 44
            jnz     loop_body08
            cmp     ebx, 211
            setnz   bl
            or      eax, ebx
            call    loop09
mA08:       db      234, 233, 189, 191, 209, 106, 254, 220, 45, 12, 242, 132, 93, 12, 226, 51, 209, 114, 131, 4, 51, 119, 117, 247, 19, 219, 231, 136, 251, 143, 203, 145, 203, 212, 71, 210, 12, 255, 43, 189, 148, 233, 199, 224
loop09:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_09
            db      235
junk0_09:   xor     edi, edi
            jz      junk1_09
            db      233, 4
junk1_09:   xor     ebx, ebx
            jz      junk2_09
            db      232
junk2_09:
loop_body09:mov     cl, byte [esp+edi]
            mov     dl, byte [mA09+edi]
            xor     esi, esi
loop_Gmul09:test    edx, 1
            jz      next0_09
            xor     ebx, ecx
next0_09:   test    ecx, 80h
            jz      next1_09
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_09
next1_09:   shl     cl, 1
next2_09:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul09
            inc     edi
            cmp     edi, 44
            jnz     loop_body09
            cmp     ebx, 85
            setnz   bl
            or      eax, ebx
            call    loop10
mA09:       db      5, 62, 126, 209, 242, 136, 95, 189, 79, 203, 244, 196, 2, 251, 150, 35, 182, 115, 205, 78, 215, 183, 88, 246, 208, 211, 161, 35, 39, 198, 171, 152, 231, 57, 44, 91, 81, 58, 163, 230, 179, 149, 114, 105
loop10:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_10
            db      234, 238
junk0_10:   xor     edi, edi
            jz      junk1_10
            db      235
junk1_10:   xor     ebx, ebx
            jz      junk2_10
            db      235
junk2_10:
loop_body10:mov     cl, byte [esp+edi]
            mov     dl, byte [mA10+edi]
            xor     esi, esi
loop_Gmul10:test    edx, 1
            jz      next0_10
            xor     ebx, ecx
next0_10:   test    ecx, 80h
            jz      next1_10
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_10
next1_10:   shl     cl, 1
next2_10:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul10
            inc     edi
            cmp     edi, 44
            jnz     loop_body10
            cmp     ebx, 61
            setnz   bl
            or      eax, ebx
            call    loop11
mA10:       db      72, 169, 107, 116, 56, 205, 187, 117, 2, 157, 39, 28, 149, 94, 127, 255, 60, 45, 59, 254, 30, 144, 182, 156, 159, 26, 39, 44, 129, 34, 111, 174, 176, 230, 253, 24, 139, 178, 200, 87, 44, 71, 67, 67
loop11:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_11
            db      234, 201, 208, 49, 202, 77
junk0_11:   xor     edi, edi
            jz      junk1_11
            db      235
junk1_11:   xor     ebx, ebx
            jz      junk2_11
            db      235
junk2_11:
loop_body11:mov     cl, byte [esp+edi]
            mov     dl, byte [mA11+edi]
            xor     esi, esi
loop_Gmul11:test    edx, 1
            jz      next0_11
            xor     ebx, ecx
next0_11:   test    ecx, 80h
            jz      next1_11
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_11
next1_11:   shl     cl, 1
next2_11:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul11
            inc     edi
            cmp     edi, 44
            jnz     loop_body11
            cmp     ebx, 154
            setnz   bl
            or      eax, ebx
            call    loop12
mA11:       db      5, 98, 151, 83, 43, 8, 109, 58, 204, 250, 125, 152, 246, 203, 135, 195, 8, 164, 195, 69, 148, 14, 71, 94, 81, 37, 187, 64, 48, 50, 230, 165, 20, 167, 254, 153, 249, 73, 201, 40, 106, 3, 93, 178
loop12:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_12
            db      235
junk0_12:   xor     edi, edi
            jz      junk1_12
            db      235
junk1_12:   xor     ebx, ebx
            jz      junk2_12
            db      234, 164, 35, 126, 69, 236
junk2_12:
loop_body12:mov     cl, byte [esp+edi]
            mov     dl, byte [mA12+edi]
            xor     esi, esi
loop_Gmul12:test    edx, 1
            jz      next0_12
            xor     ebx, ecx
next0_12:   test    ecx, 80h
            jz      next1_12
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_12
next1_12:   shl     cl, 1
next2_12:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul12
            inc     edi
            cmp     edi, 44
            jnz     loop_body12
            cmp     ebx, 50
            setnz   bl
            or      eax, ebx
            call    loop13
mA12:       db      104, 212, 183, 194, 181, 196, 225, 130, 208, 159, 255, 32, 91, 59, 170, 44, 71, 34, 99, 157, 194, 182, 86, 167, 148, 206, 237, 196, 250, 113, 22, 244, 100, 185, 47, 250, 33, 253, 204, 44, 191, 50, 146, 181
loop13:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_13
            db      232, 178
junk0_13:   xor     edi, edi
            jz      junk1_13
            db      234, 25
junk1_13:   xor     ebx, ebx
            jz      junk2_13
            db      234, 54, 163, 246
junk2_13:
loop_body13:mov     cl, byte [esp+edi]
            mov     dl, byte [mA13+edi]
            xor     esi, esi
loop_Gmul13:test    edx, 1
            jz      next0_13
            xor     ebx, ecx
next0_13:   test    ecx, 80h
            jz      next1_13
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_13
next1_13:   shl     cl, 1
next2_13:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul13
            inc     edi
            cmp     edi, 44
            jnz     loop_body13
            cmp     ebx, 51
            setnz   bl
            or      eax, ebx
            call    loop14
mA13:       db      143, 5, 236, 210, 136, 80, 252, 104, 156, 100, 209, 109, 103, 134, 125, 138, 115, 215, 108, 155, 191, 160, 228, 183, 21, 157, 225, 61, 89, 198, 250, 57, 189, 89, 205, 152, 184, 86, 207, 72, 65, 20, 209, 155
loop14:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_14
            db      232, 154, 200, 200
junk0_14:   xor     edi, edi
            jz      junk1_14
            db      235
junk1_14:   xor     ebx, ebx
            jz      junk2_14
            db      234, 139, 48, 236, 129
junk2_14:
loop_body14:mov     cl, byte [esp+edi]
            mov     dl, byte [mA14+edi]
            xor     esi, esi
loop_Gmul14:test    edx, 1
            jz      next0_14
            xor     ebx, ecx
next0_14:   test    ecx, 80h
            jz      next1_14
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_14
next1_14:   shl     cl, 1
next2_14:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul14
            inc     edi
            cmp     edi, 44
            jnz     loop_body14
            cmp     ebx, 27
            setnz   bl
            or      eax, ebx
            call    loop15
mA14:       db      103, 51, 118, 167, 111, 152, 184, 97, 213, 190, 175, 93, 237, 141, 92, 30, 82, 136, 16, 212, 99, 21, 105, 166, 161, 214, 103, 21, 116, 161, 148, 132, 95, 54, 60, 161, 207, 183, 250, 45, 156, 81, 208, 15
loop15:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_15
            db      233, 225, 126, 80
junk0_15:   xor     edi, edi
            jz      junk1_15
            db      232
junk1_15:   xor     ebx, ebx
            jz      junk2_15
            db      235
junk2_15:
loop_body15:mov     cl, byte [esp+edi]
            mov     dl, byte [mA15+edi]
            xor     esi, esi
loop_Gmul15:test    edx, 1
            jz      next0_15
            xor     ebx, ecx
next0_15:   test    ecx, 80h
            jz      next1_15
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_15
next1_15:   shl     cl, 1
next2_15:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul15
            inc     edi
            cmp     edi, 44
            jnz     loop_body15
            cmp     ebx, 28
            setnz   bl
            or      eax, ebx
            call    loop16
mA15:       db      150, 65, 4, 37, 202, 4, 54, 106, 113, 55, 51, 181, 225, 120, 173, 61, 251, 42, 153, 149, 88, 160, 79, 197, 204, 20, 65, 79, 165, 85, 203, 193, 203, 97, 9, 142, 53, 50, 127, 193, 225, 11, 121, 148
loop16:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_16
            db      232, 101, 239, 104
junk0_16:   xor     edi, edi
            jz      junk1_16
            db      233, 129, 8
junk1_16:   xor     ebx, ebx
            jz      junk2_16
            db      234
junk2_16:
loop_body16:mov     cl, byte [esp+edi]
            mov     dl, byte [mA16+edi]
            xor     esi, esi
loop_Gmul16:test    edx, 1
            jz      next0_16
            xor     ebx, ecx
next0_16:   test    ecx, 80h
            jz      next1_16
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_16
next1_16:   shl     cl, 1
next2_16:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul16
            inc     edi
            cmp     edi, 44
            jnz     loop_body16
            cmp     ebx, 19
            setnz   bl
            or      eax, ebx
            call    loop17
mA16:       db      99, 27, 20, 52, 248, 197, 117, 210, 216, 249, 122, 48, 225, 117, 211, 2, 33, 172, 60, 140, 84, 44, 71, 187, 160, 198, 26, 100, 162, 92, 89, 181, 82, 55, 184, 152, 112, 51, 248, 255, 205, 145, 31, 137
loop17:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_17
            db      232, 246, 147
junk0_17:   xor     edi, edi
            jz      junk1_17
            db      234, 214, 63, 94, 218, 140
junk1_17:   xor     ebx, ebx
            jz      junk2_17
            db      234, 70, 166, 6, 17, 189
junk2_17:
loop_body17:mov     cl, byte [esp+edi]
            mov     dl, byte [mA17+edi]
            xor     esi, esi
loop_Gmul17:test    edx, 1
            jz      next0_17
            xor     ebx, ecx
next0_17:   test    ecx, 80h
            jz      next1_17
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_17
next1_17:   shl     cl, 1
next2_17:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul17
            inc     edi
            cmp     edi, 44
            jnz     loop_body17
            cmp     ebx, 134
            setnz   bl
            or      eax, ebx
            call    loop18
mA17:       db      209, 78, 219, 94, 189, 146, 92, 172, 214, 106, 122, 121, 90, 60, 174, 6, 82, 28, 166, 206, 248, 86, 28, 113, 159, 183, 196, 12, 183, 146, 225, 107, 169, 128, 67, 221, 228, 244, 212, 66, 118, 136, 162, 218
loop18:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_18
            db      234, 119, 236
junk0_18:   xor     edi, edi
            jz      junk1_18
            db      233
junk1_18:   xor     ebx, ebx
            jz      junk2_18
            db      232, 126
junk2_18:
loop_body18:mov     cl, byte [esp+edi]
            mov     dl, byte [mA18+edi]
            xor     esi, esi
loop_Gmul18:test    edx, 1
            jz      next0_18
            xor     ebx, ecx
next0_18:   test    ecx, 80h
            jz      next1_18
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_18
next1_18:   shl     cl, 1
next2_18:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul18
            inc     edi
            cmp     edi, 44
            jnz     loop_body18
            cmp     ebx, 121
            setnz   bl
            or      eax, ebx
            call    loop19
mA18:       db      163, 143, 112, 123, 98, 87, 0, 143, 198, 176, 196, 246, 231, 201, 157, 169, 244, 123, 106, 210, 50, 159, 47, 55, 28, 203, 235, 91, 74, 16, 175, 125, 53, 54, 82, 2, 112, 159, 122, 251, 118, 138, 120, 184
loop19:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_19
            db      233, 102, 145, 34
junk0_19:   xor     edi, edi
            jz      junk1_19
            db      233, 224, 207, 16
junk1_19:   xor     ebx, ebx
            jz      junk2_19
            db      233, 174
junk2_19:
loop_body19:mov     cl, byte [esp+edi]
            mov     dl, byte [mA19+edi]
            xor     esi, esi
loop_Gmul19:test    edx, 1
            jz      next0_19
            xor     ebx, ecx
next0_19:   test    ecx, 80h
            jz      next1_19
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_19
next1_19:   shl     cl, 1
next2_19:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul19
            inc     edi
            cmp     edi, 44
            jnz     loop_body19
            cmp     ebx, 70
            setnz   bl
            or      eax, ebx
            call    loop20
mA19:       db      187, 81, 128, 55, 221, 223, 44, 37, 166, 168, 32, 169, 22, 255, 169, 251, 101, 158, 161, 153, 89, 1, 244, 87, 246, 237, 157, 232, 180, 3, 248, 23, 58, 162, 144, 159, 173, 28, 117, 196, 186, 225, 81, 83
loop20:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_20
            db      232, 170, 30
junk0_20:   xor     edi, edi
            jz      junk1_20
            db      234, 218, 186, 18, 60, 89
junk1_20:   xor     ebx, ebx
            jz      junk2_20
            db      235
junk2_20:
loop_body20:mov     cl, byte [esp+edi]
            mov     dl, byte [mA20+edi]
            xor     esi, esi
loop_Gmul20:test    edx, 1
            jz      next0_20
            xor     ebx, ecx
next0_20:   test    ecx, 80h
            jz      next1_20
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_20
next1_20:   shl     cl, 1
next2_20:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul20
            inc     edi
            cmp     edi, 44
            jnz     loop_body20
            cmp     ebx, 100
            setnz   bl
            or      eax, ebx
            call    loop21
mA20:       db      169, 45, 229, 173, 17, 248, 83, 201, 242, 38, 116, 201, 12, 87, 3, 231, 200, 143, 166, 63, 146, 86, 240, 197, 26, 198, 21, 34, 202, 192, 26, 188, 203, 3, 13, 238, 109, 179, 214, 146, 193, 255, 226, 189
loop21:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_21
            db      233, 148, 31
junk0_21:   xor     edi, edi
            jz      junk1_21
            db      234, 174
junk1_21:   xor     ebx, ebx
            jz      junk2_21
            db      232, 208
junk2_21:
loop_body21:mov     cl, byte [esp+edi]
            mov     dl, byte [mA21+edi]
            xor     esi, esi
loop_Gmul21:test    edx, 1
            jz      next0_21
            xor     ebx, ecx
next0_21:   test    ecx, 80h
            jz      next1_21
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_21
next1_21:   shl     cl, 1
next2_21:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul21
            inc     edi
            cmp     edi, 44
            jnz     loop_body21
            cmp     ebx, 219
            setnz   bl
            or      eax, ebx
            call    loop22
mA21:       db      16, 63, 38, 178, 184, 25, 51, 81, 142, 189, 2, 37, 163, 244, 157, 193, 149, 21, 6, 215, 185, 13, 205, 56, 158, 45, 48, 243, 98, 248, 129, 223, 68, 111, 88, 62, 119, 28, 255, 243, 132, 238, 149, 75
loop22:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_22
            db      232
junk0_22:   xor     edi, edi
            jz      junk1_22
            db      235
junk1_22:   xor     ebx, ebx
            jz      junk2_22
            db      232, 176, 159, 62
junk2_22:
loop_body22:mov     cl, byte [esp+edi]
            mov     dl, byte [mA22+edi]
            xor     esi, esi
loop_Gmul22:test    edx, 1
            jz      next0_22
            xor     ebx, ecx
next0_22:   test    ecx, 80h
            jz      next1_22
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_22
next1_22:   shl     cl, 1
next2_22:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul22
            inc     edi
            cmp     edi, 44
            jnz     loop_body22
            cmp     ebx, 1
            setnz   bl
            or      eax, ebx
            call    loop23
mA22:       db      185, 141, 49, 173, 86, 9, 150, 99, 183, 114, 226, 133, 170, 2, 65, 124, 2, 164, 2, 155, 153, 89, 109, 220, 138, 127, 150, 213, 114, 6, 151, 227, 248, 172, 28, 0, 92, 63, 41, 229, 214, 120, 49, 164
loop23:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_23
            db      233, 171
junk0_23:   xor     edi, edi
            jz      junk1_23
            db      232
junk1_23:   xor     ebx, ebx
            jz      junk2_23
            db      233, 168, 134
junk2_23:
loop_body23:mov     cl, byte [esp+edi]
            mov     dl, byte [mA23+edi]
            xor     esi, esi
loop_Gmul23:test    edx, 1
            jz      next0_23
            xor     ebx, ecx
next0_23:   test    ecx, 80h
            jz      next1_23
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_23
next1_23:   shl     cl, 1
next2_23:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul23
            inc     edi
            cmp     edi, 44
            jnz     loop_body23
            cmp     ebx, 132
            setnz   bl
            or      eax, ebx
            call    loop24
mA23:       db      242, 48, 147, 252, 204, 89, 111, 168, 251, 136, 160, 106, 5, 155, 137, 198, 250, 250, 57, 180, 252, 118, 165, 21, 254, 155, 154, 247, 242, 217, 131, 65, 35, 207, 112, 77, 209, 176, 122, 192, 147, 107, 80, 37
loop24:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_24
            db      233, 231, 8, 142
junk0_24:   xor     edi, edi
            jz      junk1_24
            db      232
junk1_24:   xor     ebx, ebx
            jz      junk2_24
            db      235
junk2_24:
loop_body24:mov     cl, byte [esp+edi]
            mov     dl, byte [mA24+edi]
            xor     esi, esi
loop_Gmul24:test    edx, 1
            jz      next0_24
            xor     ebx, ecx
next0_24:   test    ecx, 80h
            jz      next1_24
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_24
next1_24:   shl     cl, 1
next2_24:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul24
            inc     edi
            cmp     edi, 44
            jnz     loop_body24
            cmp     ebx, 93
            setnz   bl
            or      eax, ebx
            call    loop25
mA24:       db      52, 183, 251, 29, 226, 175, 39, 75, 34, 254, 233, 96, 155, 144, 9, 254, 189, 41, 169, 184, 91, 97, 87, 88, 251, 138, 114, 118, 91, 156, 198, 75, 222, 19, 183, 52, 81, 194, 144, 13, 249, 111, 3, 73
loop25:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_25
            db      232, 52, 250
junk0_25:   xor     edi, edi
            jz      junk1_25
            db      232, 38, 184, 210
junk1_25:   xor     ebx, ebx
            jz      junk2_25
            db      232, 6, 104
junk2_25:
loop_body25:mov     cl, byte [esp+edi]
            mov     dl, byte [mA25+edi]
            xor     esi, esi
loop_Gmul25:test    edx, 1
            jz      next0_25
            xor     ebx, ecx
next0_25:   test    ecx, 80h
            jz      next1_25
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_25
next1_25:   shl     cl, 1
next2_25:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul25
            inc     edi
            cmp     edi, 44
            jnz     loop_body25
            cmp     ebx, 252
            setnz   bl
            or      eax, ebx
            call    loop26
mA25:       db      21, 107, 222, 106, 222, 98, 190, 4, 244, 225, 112, 133, 120, 253, 141, 48, 52, 154, 63, 235, 190, 78, 33, 209, 4, 172, 158, 187, 219, 151, 17, 233, 214, 32, 120, 38, 26, 0, 250, 129, 251, 40, 89, 39
loop26:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_26
            db      234
junk0_26:   xor     edi, edi
            jz      junk1_26
            db      235
junk1_26:   xor     ebx, ebx
            jz      junk2_26
            db      233, 32, 182
junk2_26:
loop_body26:mov     cl, byte [esp+edi]
            mov     dl, byte [mA26+edi]
            xor     esi, esi
loop_Gmul26:test    edx, 1
            jz      next0_26
            xor     ebx, ecx
next0_26:   test    ecx, 80h
            jz      next1_26
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_26
next1_26:   shl     cl, 1
next2_26:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul26
            inc     edi
            cmp     edi, 44
            jnz     loop_body26
            cmp     ebx, 152
            setnz   bl
            or      eax, ebx
            call    loop27
mA26:       db      25, 66, 117, 107, 200, 80, 88, 90, 24, 176, 247, 95, 59, 121, 118, 67, 56, 133, 145, 167, 24, 46, 180, 145, 128, 220, 200, 29, 172, 157, 100, 9, 97, 253, 8, 200, 52, 229, 147, 218, 254, 255, 182, 170
loop27:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_27
            db      235
junk0_27:   xor     edi, edi
            jz      junk1_27
            db      232, 82
junk1_27:   xor     ebx, ebx
            jz      junk2_27
            db      234, 38
junk2_27:
loop_body27:mov     cl, byte [esp+edi]
            mov     dl, byte [mA27+edi]
            xor     esi, esi
loop_Gmul27:test    edx, 1
            jz      next0_27
            xor     ebx, ecx
next0_27:   test    ecx, 80h
            jz      next1_27
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_27
next1_27:   shl     cl, 1
next2_27:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul27
            inc     edi
            cmp     edi, 44
            jnz     loop_body27
            cmp     ebx, 87
            setnz   bl
            or      eax, ebx
            call    loop28
mA27:       db      172, 79, 214, 26, 85, 230, 228, 223, 32, 227, 84, 74, 109, 209, 222, 45, 48, 66, 23, 197, 52, 212, 179, 184, 90, 149, 199, 128, 153, 70, 3, 73, 160, 39, 49, 165, 88, 252, 135, 9, 157, 140, 32, 33
loop28:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_28
            db      235
junk0_28:   xor     edi, edi
            jz      junk1_28
            db      234, 216, 56, 209, 174
junk1_28:   xor     ebx, ebx
            jz      junk2_28
            db      234, 136, 74, 18, 252
junk2_28:
loop_body28:mov     cl, byte [esp+edi]
            mov     dl, byte [mA28+edi]
            xor     esi, esi
loop_Gmul28:test    edx, 1
            jz      next0_28
            xor     ebx, ecx
next0_28:   test    ecx, 80h
            jz      next1_28
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_28
next1_28:   shl     cl, 1
next2_28:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul28
            inc     edi
            cmp     edi, 44
            jnz     loop_body28
            cmp     ebx, 32
            setnz   bl
            or      eax, ebx
            call    loop29
mA28:       db      72, 233, 196, 173, 35, 166, 146, 186, 61, 86, 64, 42, 25, 86, 66, 93, 12, 255, 63, 83, 95, 219, 108, 152, 205, 31, 238, 77, 74, 156, 149, 228, 68, 244, 178, 78, 181, 173, 251, 248, 185, 99, 181, 205
loop29:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_29
            db      235
junk0_29:   xor     edi, edi
            jz      junk1_29
            db      234, 210, 148, 220, 25
junk1_29:   xor     ebx, ebx
            jz      junk2_29
            db      232
junk2_29:
loop_body29:mov     cl, byte [esp+edi]
            mov     dl, byte [mA29+edi]
            xor     esi, esi
loop_Gmul29:test    edx, 1
            jz      next0_29
            xor     ebx, ecx
next0_29:   test    ecx, 80h
            jz      next1_29
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_29
next1_29:   shl     cl, 1
next2_29:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul29
            inc     edi
            cmp     edi, 44
            jnz     loop_body29
            cmp     ebx, 171
            setnz   bl
            or      eax, ebx
            call    loop30
mA29:       db      106, 86, 224, 51, 91, 194, 158, 83, 144, 77, 217, 95, 125, 119, 144, 47, 85, 220, 24, 40, 59, 77, 70, 190, 188, 20, 105, 150, 79, 85, 194, 168, 64, 215, 234, 226, 4, 99, 157, 0, 186, 74, 18, 94
loop30:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_30
            db      235
junk0_30:   xor     edi, edi
            jz      junk1_30
            db      232, 123
junk1_30:   xor     ebx, ebx
            jz      junk2_30
            db      234, 238, 85, 72, 240
junk2_30:
loop_body30:mov     cl, byte [esp+edi]
            mov     dl, byte [mA30+edi]
            xor     esi, esi
loop_Gmul30:test    edx, 1
            jz      next0_30
            xor     ebx, ecx
next0_30:   test    ecx, 80h
            jz      next1_30
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_30
next1_30:   shl     cl, 1
next2_30:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul30
            inc     edi
            cmp     edi, 44
            jnz     loop_body30
            cmp     ebx, 228
            setnz   bl
            or      eax, ebx
            call    loop31
mA30:       db      36, 23, 51, 78, 191, 254, 1, 166, 174, 62, 222, 243, 131, 207, 37, 4, 199, 35, 169, 7, 216, 42, 190, 241, 120, 11, 166, 129, 117, 93, 184, 50, 237, 84, 122, 67, 250, 248, 60, 96, 117, 91, 187, 79
loop31:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_31
            db      232
junk0_31:   xor     edi, edi
            jz      junk1_31
            db      234, 199, 164, 0, 220
junk1_31:   xor     ebx, ebx
            jz      junk2_31
            db      234, 39
junk2_31:
loop_body31:mov     cl, byte [esp+edi]
            mov     dl, byte [mA31+edi]
            xor     esi, esi
loop_Gmul31:test    edx, 1
            jz      next0_31
            xor     ebx, ecx
next0_31:   test    ecx, 80h
            jz      next1_31
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_31
next1_31:   shl     cl, 1
next2_31:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul31
            inc     edi
            cmp     edi, 44
            jnz     loop_body31
            cmp     ebx, 156
            setnz   bl
            or      eax, ebx
            call    loop32
mA31:       db      248, 17, 173, 127, 98, 184, 11, 20, 50, 140, 249, 248, 24, 222, 34, 86, 71, 0, 237, 138, 148, 107, 115, 104, 62, 191, 39, 221, 123, 115, 131, 229, 127, 56, 64, 177, 106, 239, 26, 255, 100, 88, 1, 75
loop32:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_32
            db      234, 210, 75, 124
junk0_32:   xor     edi, edi
            jz      junk1_32
            db      233, 127, 26, 132
junk1_32:   xor     ebx, ebx
            jz      junk2_32
            db      235
junk2_32:
loop_body32:mov     cl, byte [esp+edi]
            mov     dl, byte [mA32+edi]
            xor     esi, esi
loop_Gmul32:test    edx, 1
            jz      next0_32
            xor     ebx, ecx
next0_32:   test    ecx, 80h
            jz      next1_32
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_32
next1_32:   shl     cl, 1
next2_32:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul32
            inc     edi
            cmp     edi, 44
            jnz     loop_body32
            cmp     ebx, 43
            setnz   bl
            or      eax, ebx
            call    loop33
mA32:       db      144, 18, 85, 103, 3, 31, 157, 44, 67, 24, 228, 226, 82, 208, 69, 17, 189, 216, 205, 140, 6, 1, 33, 11, 61, 223, 12, 116, 123, 167, 151, 58, 167, 79, 96, 189, 151, 233, 92, 94, 22, 60, 254, 254
loop33:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_33
            db      234, 132
junk0_33:   xor     edi, edi
            jz      junk1_33
            db      232, 233, 195
junk1_33:   xor     ebx, ebx
            jz      junk2_33
            db      233, 186
junk2_33:
loop_body33:mov     cl, byte [esp+edi]
            mov     dl, byte [mA33+edi]
            xor     esi, esi
loop_Gmul33:test    edx, 1
            jz      next0_33
            xor     ebx, ecx
next0_33:   test    ecx, 80h
            jz      next1_33
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_33
next1_33:   shl     cl, 1
next2_33:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul33
            inc     edi
            cmp     edi, 44
            jnz     loop_body33
            cmp     ebx, 98
            setnz   bl
            or      eax, ebx
            call    loop34
mA33:       db      216, 167, 82, 244, 143, 231, 192, 63, 79, 49, 131, 176, 212, 46, 141, 107, 125, 207, 201, 5, 103, 155, 107, 166, 210, 49, 182, 60, 34, 26, 220, 198, 225, 160, 57, 52, 138, 27, 247, 181, 0, 67, 1, 205
loop34:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_34
            db      233, 67
junk0_34:   xor     edi, edi
            jz      junk1_34
            db      233, 101, 164, 140
junk1_34:   xor     ebx, ebx
            jz      junk2_34
            db      232, 58, 109
junk2_34:
loop_body34:mov     cl, byte [esp+edi]
            mov     dl, byte [mA34+edi]
            xor     esi, esi
loop_Gmul34:test    edx, 1
            jz      next0_34
            xor     ebx, ecx
next0_34:   test    ecx, 80h
            jz      next1_34
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_34
next1_34:   shl     cl, 1
next2_34:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul34
            inc     edi
            cmp     edi, 44
            jnz     loop_body34
            cmp     ebx, 203
            setnz   bl
            or      eax, ebx
            call    loop35
mA34:       db      19, 243, 215, 203, 156, 157, 71, 187, 142, 198, 244, 52, 100, 195, 129, 134, 38, 227, 155, 241, 122, 192, 145, 179, 195, 16, 180, 70, 86, 219, 250, 67, 127, 47, 178, 249, 19, 36, 183, 50, 154, 186, 239, 15
loop35:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_35
            db      235
junk0_35:   xor     edi, edi
            jz      junk1_35
            db      235
junk1_35:   xor     ebx, ebx
            jz      junk2_35
            db      235
junk2_35:
loop_body35:mov     cl, byte [esp+edi]
            mov     dl, byte [mA35+edi]
            xor     esi, esi
loop_Gmul35:test    edx, 1
            jz      next0_35
            xor     ebx, ecx
next0_35:   test    ecx, 80h
            jz      next1_35
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_35
next1_35:   shl     cl, 1
next2_35:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul35
            inc     edi
            cmp     edi, 44
            jnz     loop_body35
            cmp     ebx, 2
            setnz   bl
            or      eax, ebx
            call    loop36
mA35:       db      163, 224, 95, 10, 171, 106, 49, 57, 28, 178, 119, 6, 40, 228, 92, 163, 93, 225, 23, 37, 24, 211, 72, 105, 209, 70, 0, 165, 70, 226, 43, 187, 167, 60, 143, 233, 207, 209, 12, 207, 64, 246, 222, 16
loop36:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_36
            db      232
junk0_36:   xor     edi, edi
            jz      junk1_36
            db      235
junk1_36:   xor     ebx, ebx
            jz      junk2_36
            db      233, 183, 31
junk2_36:
loop_body36:mov     cl, byte [esp+edi]
            mov     dl, byte [mA36+edi]
            xor     esi, esi
loop_Gmul36:test    edx, 1
            jz      next0_36
            xor     ebx, ecx
next0_36:   test    ecx, 80h
            jz      next1_36
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_36
next1_36:   shl     cl, 1
next2_36:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul36
            inc     edi
            cmp     edi, 44
            jnz     loop_body36
            cmp     ebx, 24
            setnz   bl
            or      eax, ebx
            call    loop37
mA36:       db      245, 140, 237, 250, 89, 99, 215, 112, 85, 182, 51, 26, 62, 220, 116, 17, 196, 247, 172, 121, 22, 106, 91, 200, 115, 240, 31, 78, 47, 126, 50, 114, 109, 88, 83, 120, 17, 95, 198, 206, 71, 112, 172, 49
loop37:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_37
            db      233
junk0_37:   xor     edi, edi
            jz      junk1_37
            db      233, 45, 203, 110
junk1_37:   xor     ebx, ebx
            jz      junk2_37
            db      235
junk2_37:
loop_body37:mov     cl, byte [esp+edi]
            mov     dl, byte [mA37+edi]
            xor     esi, esi
loop_Gmul37:test    edx, 1
            jz      next0_37
            xor     ebx, ecx
next0_37:   test    ecx, 80h
            jz      next1_37
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_37
next1_37:   shl     cl, 1
next2_37:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul37
            inc     edi
            cmp     edi, 44
            jnz     loop_body37
            cmp     ebx, 63
            setnz   bl
            or      eax, ebx
            call    loop38
mA37:       db      254, 198, 189, 175, 121, 123, 248, 38, 163, 170, 91, 171, 125, 66, 94, 37, 181, 207, 13, 60, 210, 178, 252, 39, 175, 18, 106, 94, 171, 196, 182, 129, 101, 165, 103, 164, 234, 110, 146, 69, 36, 75, 58, 98
loop38:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_38
            db      232, 4, 249, 171
junk0_38:   xor     edi, edi
            jz      junk1_38
            db      232, 148
junk1_38:   xor     ebx, ebx
            jz      junk2_38
            db      233, 194
junk2_38:
loop_body38:mov     cl, byte [esp+edi]
            mov     dl, byte [mA38+edi]
            xor     esi, esi
loop_Gmul38:test    edx, 1
            jz      next0_38
            xor     ebx, ecx
next0_38:   test    ecx, 80h
            jz      next1_38
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_38
next1_38:   shl     cl, 1
next2_38:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul38
            inc     edi
            cmp     edi, 44
            jnz     loop_body38
            cmp     ebx, 215
            setnz   bl
            or      eax, ebx
            call    loop39
mA38:       db      184, 162, 160, 24, 71, 214, 24, 14, 196, 222, 67, 178, 163, 150, 206, 104, 38, 176, 245, 98, 180, 213, 93, 134, 25, 198, 166, 10, 183, 99, 207, 127, 163, 10, 141, 105, 52, 68, 18, 121, 217, 209, 124, 127
loop39:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_39
            db      232, 254
junk0_39:   xor     edi, edi
            jz      junk1_39
            db      233, 33, 147, 25
junk1_39:   xor     ebx, ebx
            jz      junk2_39
            db      233
junk2_39:
loop_body39:mov     cl, byte [esp+edi]
            mov     dl, byte [mA39+edi]
            xor     esi, esi
loop_Gmul39:test    edx, 1
            jz      next0_39
            xor     ebx, ecx
next0_39:   test    ecx, 80h
            jz      next1_39
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_39
next1_39:   shl     cl, 1
next2_39:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul39
            inc     edi
            cmp     edi, 44
            jnz     loop_body39
            cmp     ebx, 186
            setnz   bl
            or      eax, ebx
            call    loop40
mA39:       db      142, 153, 245, 130, 182, 55, 211, 250, 217, 10, 172, 119, 212, 171, 244, 99, 99, 41, 223, 221, 128, 66, 31, 129, 195, 145, 241, 50, 77, 139, 29, 232, 60, 167, 110, 139, 124, 135, 18, 197, 200, 85, 15, 159
loop40:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_40
            db      233
junk0_40:   xor     edi, edi
            jz      junk1_40
            db      233
junk1_40:   xor     ebx, ebx
            jz      junk2_40
            db      235
junk2_40:
loop_body40:mov     cl, byte [esp+edi]
            mov     dl, byte [mA40+edi]
            xor     esi, esi
loop_Gmul40:test    edx, 1
            jz      next0_40
            xor     ebx, ecx
next0_40:   test    ecx, 80h
            jz      next1_40
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_40
next1_40:   shl     cl, 1
next2_40:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul40
            inc     edi
            cmp     edi, 44
            jnz     loop_body40
            cmp     ebx, 201
            setnz   bl
            or      eax, ebx
            call    loop41
mA40:       db      225, 159, 86, 55, 158, 137, 229, 250, 129, 194, 200, 31, 147, 30, 219, 233, 147, 28, 6, 219, 81, 172, 132, 162, 212, 115, 232, 60, 152, 105, 146, 77, 187, 9, 20, 191, 157, 96, 131, 190, 125, 175, 141, 4
loop41:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_41
            db      235
junk0_41:   xor     edi, edi
            jz      junk1_41
            db      232
junk1_41:   xor     ebx, ebx
            jz      junk2_41
            db      235
junk2_41:
loop_body41:mov     cl, byte [esp+edi]
            mov     dl, byte [mA41+edi]
            xor     esi, esi
loop_Gmul41:test    edx, 1
            jz      next0_41
            xor     ebx, ecx
next0_41:   test    ecx, 80h
            jz      next1_41
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_41
next1_41:   shl     cl, 1
next2_41:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul41
            inc     edi
            cmp     edi, 44
            jnz     loop_body41
            cmp     ebx, 128
            setnz   bl
            or      eax, ebx
            call    loop42
mA41:       db      110, 75, 232, 58, 102, 13, 222, 137, 137, 14, 191, 155, 48, 100, 169, 184, 49, 249, 49, 39, 138, 124, 63, 73, 237, 150, 244, 126, 127, 206, 91, 252, 110, 45, 189, 116, 188, 42, 18, 68, 194, 244, 53, 2
loop42:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_42
            db      235
junk0_42:   xor     edi, edi
            jz      junk1_42
            db      233, 74, 133, 153
junk1_42:   xor     ebx, ebx
            jz      junk2_42
            db      235
junk2_42:
loop_body42:mov     cl, byte [esp+edi]
            mov     dl, byte [mA42+edi]
            xor     esi, esi
loop_Gmul42:test    edx, 1
            jz      next0_42
            xor     ebx, ecx
next0_42:   test    ecx, 80h
            jz      next1_42
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_42
next1_42:   shl     cl, 1
next2_42:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul42
            inc     edi
            cmp     edi, 44
            jnz     loop_body42
            cmp     ebx, 103
            setnz   bl
            or      eax, ebx
            call    loop43
mA42:       db      109, 116, 87, 241, 128, 121, 227, 188, 2, 6, 81, 194, 4, 225, 176, 48, 8, 59, 243, 50, 234, 228, 192, 176, 168, 187, 248, 244, 27, 188, 107, 204, 222, 202, 73, 141, 160, 139, 151, 206, 1, 227, 152, 81
loop43:     add     esp, 4
            xor     ecx, ecx
            jz      junk0_43
            db      233
junk0_43:   xor     edi, edi
            jz      junk1_43
            db      234
junk1_43:   xor     ebx, ebx
            jz      junk2_43
            db      235
junk2_43:
loop_body43:mov     cl, byte [esp+edi]
            mov     dl, byte [mA43+edi]
            xor     esi, esi
loop_Gmul43:test    edx, 1
            jz      next0_43
            xor     ebx, ecx
next0_43:   test    ecx, 80h
            jz      next1_43
            shl     cl, 1
            xor     cl, 39h
            jmp     next2_43
next1_43:   shl     cl, 1
next2_43:   shr     dl, 1
            inc     esi
            cmp     esi, 8
            jnz     loop_Gmul43
            inc     edi
            cmp     edi, 44
            jnz     loop_body43
            cmp     ebx, 52
            setnz   bl
            or      eax, ebx
            call    loop44
mA43:       db      13, 149, 85, 158, 164, 119, 149, 36, 138, 84, 173, 132, 39, 230, 96, 229, 84, 218, 14, 153, 184, 98, 160, 129, 2, 161, 99, 41, 17, 114, 55, 67, 192, 102, 241, 168, 149, 191, 216, 18, 229, 153, 94, 171
loop44:     add     esp, 4
            mov     ebx, eax
            xor     eax, eax
            inc     eax
            int     0x80
