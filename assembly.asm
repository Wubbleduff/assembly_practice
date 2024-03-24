
;includelib ucrt.lib
;includelib legacy_stdio_definitions.lib
;includelib msvcrt.lib
;includelib gdi32.lib
;includelib shell32.lib
;includelib User32.lib




; Calling convetion
; https://learn.microsoft.com/en-us/cpp/build/x64-calling-convention?view=msvc-170
; * The caller must allocate 32 bytes of shadow space for callees to save their parameters.
; * By default, the x64 calling convention passes the first four arguments to a
;   function in registers. The registers used for these arguments depend on the
;   position and type of the argument. Remaining arguments get pushed on the
;   stack in right-to-left order.
;
; * Registers
;  * integer:   1     2    3    4    5+
;             RCX   RDX   R8   R9 stack
;  * float:      1    2    3    4    5+
;             XMM0 XMM1 XMM2 XMM3 stack
; * Volatile:     rax, rcx, rdx, r8, r9, r10, r11, and xmm0-xmm5
; * Non-volatile: rbx, rbp, rdi, rsi, rsp, r12, r13, r14, r15, and xmm6-xmm15


.data
window_class_str byte 'Window Class', 0
window_str byte 'Game', 0

.code
EXTERN CreateWindowExA :PROC
EXTERN RegisterClassA :PROC
EXTERN GetLastError :PROC
EXTERN DefWindowProcA :PROC
EXTERN ShowWindow :PROC


;WindowProc    PROC
;    jmp DefWindowProcA
;WindowProc    ENDP


MyWinMain    PROC                                            ; COMDAT

        ;push rbp
        ;push rbx
        ;sub rsp, 108h

        ;mov rbx, rcx ; Save hInstance

        ; RegisterClassA
        ; ATOM RegisterClassA([in] const WNDCLASSA *lpWndClass);
        ; typedef struct tagWNDCLASSA {
        ;     UINT      style;             4 bytes (0)
        ;     WNDPROC   lpfnWndProc;       8 bytes (8)
        ;     int       cbClsExtra;        4 bytes (16)
        ;     int       cbWndExtra;        4 bytes (20)
        ;     HINSTANCE hInstance;         8 bytes (24)
        ;     HICON     hIcon;             8 bytes (32)
        ;     HCURSOR   hCursor;           8 bytes (40)
        ;     HBRUSH    hbrBackground;     8 bytes (48)
        ;     LPCSTR    lpszMenuName;      8 bytes (56)
        ;     LPCSTR    lpszClassName;     8 bytes (64)
        ; } WNDCLASSA, *PWNDCLASSA, *NPWNDCLASSA, *LPWNDCLASSA;
        ; 72 bytes
        ;mov dword ptr [rsp + 20h + 0], 3h ; wc.style = CS_HREDRAW (0x0002) | CS_VREDRAW (0x0001)
        ;lea rax, qword ptr [DefWindowProcA]
        ;mov qword ptr [rsp + 20h + 8], rax ; wc.lpfnWndProc = WindowProc
        ;mov dword ptr [rsp + 20h + 16], 0 ; wc.cbClsExtra
        ;mov dword ptr [rsp + 20h + 20], 0 ; wc.cbWndExtra
        ;mov qword ptr [rsp + 20h + 24], rbx ; wc.hInstance
        ;mov qword ptr [rsp + 20h + 32], 0 ; wc.hIcon
        ;mov qword ptr [rsp + 20h + 40], 0 ; wc.hCursor
        ;mov qword ptr [rsp + 20h + 48], 0 ; wc.hbrBackground
        ;mov qword ptr [rsp + 20h + 56], 0 ; wc.lpszMenuName
        ;lea rax, qword ptr [window_class_str]
        ;mov qword ptr [rsp + 20h + 64], rax ; wc.lpszClassName
        ;lea rcx, qword ptr [rsp + 20h]
        ;call RegisterClassA

        ;call GetLastError





        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        mov             dword ptr [rsp+20h], r9d
        mov             qword ptr [rsp+18h], r8
        mov             qword ptr [rsp+10h], rdx
        mov             qword ptr [rsp+8h], rcx
        sub             rsp, 0c8h
        mov             dword ptr [rsp+70h], 03h
        ;mov             rax, qword ptr [rip+9527Eh]
        lea rax, qword ptr [DefWindowProcA]
        mov qword ptr [rsp + 20h + 8], rax ; wc.lpfnWndProc = WindowProc
        mov             qword ptr [rsp+78h], rax
        mov             dword ptr [rsp+80h], 0h
        mov             dword ptr [rsp+84h], 0h
        mov             rax, qword ptr [rsp+0d0h]
        mov             qword ptr [rsp+88h], rax
        mov             qword ptr [rsp+90h], 0h
        mov             qword ptr [rsp+98h], 0h
        mov             qword ptr [rsp+0a0h], 0h
        mov             qword ptr [rsp+0a8h], 0h
        ;mov             rax, qword ptr [rip+8be7ch]
        lea rax, qword ptr [window_class_str]
        mov qword ptr [rsp + 20h + 64], rax ; wc.lpszClassName
        mov             qword ptr [rsp+0b0h], rax
        lea             rcx, qword ptr [rsp+70h]
        call            RegisterClassA
        mov             word ptr [rsp+60h], ax
        call            GetLastError
        

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


        ; call CreateWindowExA
        ; HWND CreateWindowExA(
        ;         [in]           DWORD     dwExStyle,     
        ;         [in, optional] LPCSTR    lpClassName,   
        ;         [in, optional] LPCSTR    lpWindowName,  
        ;         [in]           DWORD     dwStyle,       
        ;         [in]           int       X,             <-- stack
        ;         [in]           int       Y,             
        ;         [in]           int       nWidth,        
        ;         [in]           int       nHeight,       
        ;         [in, optional] HWND      hWndParent,    
        ;         [in, optional] HMENU     hMenu,         
        ;         [in, optional] HINSTANCE hInstance,     
        ;         [in, optional] LPVOID    lpParam        
        ;         );
        xor rcx, rcx ; dwExStyle
        lea rdx, qword ptr [window_class_str] ; lpClassName
        lea r8, qword ptr [window_str] ; lpWindowName
        mov r9, 90000000h ; dwStyle = WS_POPUP (0x80000000) | WS_VISIBLE (0x10000000)
        mov dword ptr [rsp + 20h + 0], 100 ; X
        mov dword ptr [rsp + 20h + 8], 100 ; Y
        mov dword ptr [rsp + 20h + 16], 500 ; nWidth
        mov dword ptr [rsp + 20h + 24], 500 ; nHeight
        mov qword ptr [rsp + 20h + 32], 0 ; nWndParent
        mov qword ptr [rsp + 20h + 40], 0 ; hMenu
        mov qword ptr [rsp + 20h + 48], rbx ; hInstance
        mov qword ptr [rsp + 20h + 56], 0 ; lpParam
        call CreateWindowExA

        ; BOOL ShowWindow(
        ;         [in] HWND hWnd,
        ;         [in] int  nCmdShow
        ;         );
        mov rcx, rax
        mov rdx, 10
        call ShowWindow

        xor rax, rax

        add rsp, 108h
        pop rbx
        pop rbp
        ret     0
MyWinMain    ENDP

end

