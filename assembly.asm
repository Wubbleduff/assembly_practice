
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
; * Volatile:     RAX, RCX, RDX, R8, R9, R10, R11, and XMM0-XMM5
; * Non-volatile: RBX, RBP, RDI, RSI, RSP, R12, R13, R14, R15, and XMM6-XMM15


.data
window_class_str byte 'Window Class', 0
window_str byte 'Game', 0

.code
EXTERN CreateWindowExA :PROC
EXTERN RegisterClassA :PROC
EXTERN GetLastError :PROC
EXTERN DefWindowProcA :PROC


;WindowProc    PROC
;    jmp DefWindowProcA
;WindowProc    ENDP


WinMain    PROC                                            ; COMDAT

        ; Store hInstance for later.
        push rbx
        mov rbx, rcx

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
        ; 68 bytes
        ; 72 bytes
        sub rsp, 72
        ; wc.style = CS_HREDRAW (0x0002) | CS_VREDRAW (0x0001)
        mov rax, 3h
        mov [rsp + 0], eax
        ; wc.lpfnWndProc = WindowProc
        lea rax, [DefWindowProcA]
        mov [rsp + 8], rax
        ; wc.cbClsExtra
        xor rax, rax
        mov [rsp + 16], eax
        ; wc.cbWndExtra
        xor rax, rax
        mov [rsp + 20], eax
        ; wc.hInstance
        mov [rsp + 24], rcx
        ; wc.hIcon
        xor rax, rax
        mov [rsp + 32], rax
        ; wc.hCursor
        xor rax, rax
        mov [rsp + 40], rax
        ; wc.hbrBackground
        xor rax, rax
        mov [rsp + 48], rax
        ; wc.lpszMenuName
        xor rax, rax
        mov [rsp + 56], rax
        ; wc.lpszClassName
        lea rax, [window_class_str]
        mov [rsp + 64], rax
        mov rcx, rsp
        sub     rsp, 40
        call RegisterClassA
        add rsp, 40
        add rsp, 72


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
        ; dwExStyle
        xor rcx, rcx
        ; lpClassName
        lea rdx, [window_class_str]
        ; lpWindowName
        lea r8, [window_str]
        ; dwStyle
        ; WS_POPUP (0x80000000) | WS_VISIBLE (0x10000000)
        mov r9, 90000000h
        ; X
        sub rsp, 64
        mov rax, 100
        mov qword ptr [rsp + 0], rax
        ; Y
        mov qword ptr [rsp + 8], rax
        ; nWidth
        mov rax, 500
        mov qword ptr [rsp + 16], rax
        ; nHeight
        mov qword ptr [rsp + 24], rax
        ; nWndParent
        xor rax, rax
        mov qword ptr [rsp + 32], rax
        ; hMenu
        mov qword ptr [rsp + 40], rax
        ; hInstance
        mov qword ptr [rsp + 48], rbx
        ; lpParam
        mov qword ptr [rsp + 56], rax
        sub rsp, 32
        call CreateWindowExA
        add rsp, 32
        add rsp, 64

        pop rbx
        ret     0
WinMain    ENDP

end

