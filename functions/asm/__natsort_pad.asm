; Mike's Function
; vim: set tabstop=4 expandtab autoindent smartindent:
; author: Jean-Yves Eckert <jean-yves.eckert@f-secure.com>
; date: 20/04/2011
; copyright: All rights reserved

%ifidn __OUTPUT_FORMAT__, coff
    segment .text
%elifidn __OUTPUT_FORMAT__, elf
    segment .text align=16
%endif

NATSORT_PADDING     equ     8

; ------------------------------------------------------------------------------
; int __natsort_pad_size(int size, char* str)

align   16

%ifidn __OUTPUT_FORMAT__, coff
    global ___natsort_pad_size
___natsort_pad_size:
%elifidn __OUTPUT_FORMAT__, elf
    global __natsort_pad_size
__natsort_pad_size:
%endif
        push    ebp
        mov     ebp,esp
        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi

        mov     edi,[ebp+8]         ; size
        mov     esi,[ebp+12]        ; str

        xor     ebx,ebx             ; iPtr = 0
        xor     eax,eax             ; result size = 0
        xor     ecx,ecx             ; ch  <=  state = 0

padsize_loop:
        cmp     ebx,edi
        jnc     padsize_endloop

        mov     cl,[esi+ebx]        ; al  <=  char
        inc     ebx

        or      ch,ch
        jz      padsize_state0

        ; NUM state

        cmp     cl,'0'
        jc      padsize_1_nonum
        cmp     cl,'9'
        ja      padsize_1_nonum

        ; CL is numeric

        inc     edx                 ; counter++
        jmp     padsize_loop

padsize_1_nonum:

        mov     ch,0                ; state = 0
        inc     eax

        cmp     edx,NATSORT_PADDING ; counter < PADVALUE ?
        jc      padsize_1_inf

        add     eax,edx
        jmp     padsize_loop

padsize_1_inf:

        add     eax,NATSORT_PADDING
        jmp     padsize_loop

padsize_state0:

        ; non NUM state

        cmp     cl,'0'
        jc      padsize_0_nonum
        cmp     cl,'9'
        ja      padsize_0_nonum

        ; CL is numeric

        mov     edx,1
        mov     ch,1
        jmp     padsize_loop

padsize_0_nonum:

        inc     eax
        jmp     padsize_loop

padsize_endloop:

        or      ch,ch
        jz     padsize_end

        cmp     edx,NATSORT_PADDING ; counter < PADVALUE ?
        jc      padsize_1_endinf

        add     eax,edx
        jmp     padsize_end

padsize_1_endinf:

        add     eax,NATSORT_PADDING

padsize_end:

        pop     edi
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        pop     ebp
        ret

;-------------------------------------------------------------------------------
; void __natsort_pad(int size, char* str, char* output)

align   16

%ifidn __OUTPUT_FORMAT__, coff
    global ___natsort_pad
___natsort_pad:
%elifidn __OUTPUT_FORMAT__, elf
    global __natsort_pad
__natsort_pad:
%endif
        push    ebp
        mov     ebp,esp
        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi

        mov     edi,[ebp+8]         ; size
        mov     esi,[ebp+12]        ; str
        mov     eax,[ebp+16]        ; output

        xor     ebx,ebx             ; iPtr = 0
        xor     ecx,ecx             ; ch  <=  state = 0

pad_loop:
        cmp     ebx,edi
        jnc     pad_endloop

        mov     cl,[esi+ebx]        ; al  <=  char
        inc     ebx

        or      ch,ch
        jz      pad_state0

        ; NUM state

        cmp     cl,'0'
        jc      pad_1_nonum
        cmp     cl,'9'
        ja      pad_1_nonum

        ; CL is numeric

        inc     edx                 ; counter++
        jmp     pad_loop

pad_1_nonum:

        mov     ch,0                ; state = 0

        cmp     edx,NATSORT_PADDING ; counter < PADVALUE ?
        jc      pad_1_inf

        inc     edx
        sub     ebx,edx

pad_1_loop1:

        mov     cl,[esi+ebx]
        mov     [eax],cl
        inc     eax
        inc     ebx
        dec     edx
        jnz     pad_1_loop1

        jmp     pad_loop

pad_1_inf:

        push    edx
        sub     edx,NATSORT_PADDING
        neg     edx
        mov     cl,'0'

pad_1_loop2:
        mov     [eax],cl
        inc     eax
        dec     edx
        jnz     pad_1_loop2

        pop     edx
        inc     edx
        sub     ebx,edx

pad_1_loop3:

        mov     cl,[esi+ebx]
        mov     [eax],cl
        inc     eax
        inc     ebx
        dec     edx
        jnz     pad_1_loop3

        jmp     pad_loop

pad_state0:

        ; non NUM state

        cmp     cl,'0'
        jc      pad_0_nonum
        cmp     cl,'9'
        ja      pad_0_nonum

        ; CL is numeric

        mov     edx,1
        mov     ch,1
        jmp     pad_loop

pad_0_nonum:

        mov     [eax],cl
        inc     eax
        jmp     pad_loop

pad_endloop:

        or      ch,ch
        jz     pad_end

        cmp     edx,NATSORT_PADDING ; counter < PADVALUE ?
        jc      pad_1_endinf

        ;inc     edx
        sub     ebx,edx

pad_end_loop1:

        mov     cl,[esi+ebx]
        mov     [eax],cl
        inc     eax
        inc     ebx
        dec     edx
        jnz     pad_end_loop1

        jmp     pad_end

pad_1_endinf:

        push    edx
        sub     edx,NATSORT_PADDING
        neg     edx
        mov     cl,'0'

pad_end_loop2:
        mov     [eax],cl
        inc     eax
        dec     edx
        jnz     pad_end_loop2

        pop     edx
        ;inc     edx
        sub     ebx,edx

pad_end_loop3:

        mov     cl,[esi+ebx]
        mov     [eax],cl
        inc     eax
        inc     ebx
        dec     edx
        jnz     pad_end_loop3

pad_end:

        pop     edi
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        pop     ebp
        ret
