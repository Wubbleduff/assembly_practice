
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
EXTERN ValidateRect :PROC
EXTERN PeekMessageA :PROC
EXTERN DispatchMessageA :PROC
EXTERN TranslateMessage :PROC
EXTERN ExitProcess :PROC



MyWinMain    PROC
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 208h

    mov rbx, rcx ; Save hInstance

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
    mov dword ptr [rsp + 20h + 0], 3h ; wc.style = CS_HREDRAW (0x0002) | CS_VREDRAW (0x0001)
    lea rax, qword ptr [WindowProc]
    ;lea rax, qword ptr [DefWindowProcA]
    mov qword ptr [rsp + 20h + 8], rax ; wc.lpfnWndProc = WindowProc
    mov dword ptr [rsp + 20h + 16], 0 ; wc.cbClsExtra
    mov dword ptr [rsp + 20h + 20], 0 ; wc.cbWndExtra
    mov qword ptr [rsp + 20h + 24], rbx ; wc.hInstance
    mov qword ptr [rsp + 20h + 32], 0 ; wc.hIcon
    mov qword ptr [rsp + 20h + 40], 0 ; wc.hCursor
    mov qword ptr [rsp + 20h + 48], 0 ; wc.hbrBackground
    mov qword ptr [rsp + 20h + 56], 0 ; wc.lpszMenuName
    lea rax, qword ptr [window_class_str]
    mov qword ptr [rsp + 20h + 64], rax ; wc.lpszClassName
    lea rcx, qword ptr [rsp + 20h]
    call RegisterClassA


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

    mov r9, 0cf0000h ; 90000000h ; dwStyle = WS_POPUP (0x80000000) | WS_VISIBLE (0x10000000)
    mov dword ptr [rsp + 20h + 0], 100 ; X
    mov dword ptr [rsp + 20h + 8], 100 ; Y
    mov dword ptr [rsp + 20h + 16], 500 ; nWidth
    mov dword ptr [rsp + 20h + 24], 500 ; nHeight
    mov qword ptr [rsp + 20h + 32], 0 ; nWndParent
    mov qword ptr [rsp + 20h + 40], 0 ; hMenu
    mov qword ptr [rsp + 20h + 48], rbx ; hInstance
    ;mov  rax, qword ptr [rsp+0d0h]
    ;mov qword ptr [rsp + 20h + 48], rax ; hInstance
    mov qword ptr [rsp + 20h + 56], 0 ; lpParam
    call CreateWindowExA

    ; BOOL ShowWindow(
    ;         [in] HWND hWnd,
    ;         [in] int  nCmdShow
    ;         );
    mov rcx, rax
    mov rdx, 10
    call ShowWindow
    call GetLastError

    loop_top:

        ; sizeof(MSG) = 0x30
        ; typedef struct tagMSG {
        ;   HWND   hwnd;
        ;   UINT   message;
        ;   WPARAM wParam;
        ;   LPARAM lParam;
        ;   DWORD  time;
        ;   POINT  pt;
        ;   DWORD  lPrivate;
        ; } MSG, *PMSG, *NPMSG, *LPMSG;
        ;
        ; BOOL PeekMessageA(
        ;   [out]          LPMSG lpMsg,
        ;   [in, optional] HWND  hWnd,
        ;   [in]           UINT  wMsgFilterMin,
        ;   [in]           UINT  wMsgFilterMax,
        ;   [in]           UINT  wRemoveMsg
        ; );
        ;
        ; Create MSG at rsp + 0x100
        vxorps  ymm0, ymm0, ymm0
        vmovups ymmword ptr [rsp + 100h], ymm0
        vmovups ymmword ptr [rsp + 100h + 10h], ymm0
        ; Call PeekMessageA
        lea rcx, [rsp + 100h]
        mov rdx, 0
        mov r8, 0
        mov r9, 0
        mov dword ptr [rsp + 20h], 1 ; PM_REMOVE = 0x0001
        call PeekMessageA

        ; BOOL TranslateMessage(
        ;   [in] const MSG *lpMsg
        ; );
        lea rcx, [rsp + 100h]
        call TranslateMessage

        ; LRESULT DispatchMessageA(
        ;   [in] const MSG *lpMsg
        ; );
        lea rcx, [rsp + 100h]
        call DispatchMessageA

        jmp loop_top

    xor rax, rax

    add rsp, 208h
    pop rbx
    pop rbp
    ret     0
MyWinMain    ENDP




; LRESULT Wndproc(
;   HWND hwnd,
;   UINT uMsg,
;   WPARAM wParam,
;   LPARAM lParam
; )
WindowProc    PROC
    push rbp
    mov rbp, rsp
    sub rsp, 20h

    cmp rdx, 2h ; #define WM_DESTROY 0x0002
    jz  WindowProc_case_WM_DESTROY

    cmp rdx, 10h ; #define WM_CLOSE 0x0010
    jz  WindowProc_case_WM_CLOSE

    cmp rdx, 0fh ; #define WM_PAINT 0xf (?)
    jz  WindowProc_case_WM_PAINT

    cmp rdx, 100h ; #define WM_KEYDOWN 0x0100
    jz  WindowProc_case_WM_KEYDOWN

    ; Default
    call DefWindowProcA
    jmp WindowProc_end
    

    WindowProc_case_WM_DESTROY:
        xor rcx, rcx
        call ExitProcess
        jmp WindowProc_end

    WindowProc_case_WM_CLOSE:
        xor rcx, rcx
        call ExitProcess
        jmp WindowProc_end

    WindowProc_case_WM_PAINT:
        ; BOOL ValidateRect(
        ;   [in] HWND       hWnd,
        ;   [in] const RECT *lpRect
        ; );
        xor rdx, rdx
        call ValidateRect
        jmp WindowProc_end

    WindowProc_case_WM_KEYDOWN:
        xor rcx, rcx
        call ExitProcess
        jmp WindowProc_end


    WindowProc_end:
    add rsp, 20h
    pop rbp

    ret
WindowProc    ENDP



end

