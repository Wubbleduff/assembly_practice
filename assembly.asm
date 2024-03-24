
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
EXTERN GetClientRect :PROC
EXTERN GetDC :PROC
EXTERN CreateCompatibleDC :PROC
EXTERN CreateDIBSection :PROC
EXTERN SelectObject :PROC
EXTERN ReleaseDC :PROC
EXTERN BitBlt :PROC



MyWinMain    PROC
    push rbx
    push rbp
    mov rbp, rsp
    push rdi
    push rsi
    push rsp
    push r12
    push r13
    push r14
    push r15

    sub rsp, 300h

    ; rsp + 0x100 : u64 hdc
    ; rsp + 0x108 : u64 hwnd
    ; rsp + 0x110 : RECT client_rect
    ; rsp + 0x120 : u64 DIB_handle
    ; rsp + 0x128 : u32* fb
    ; rsp + 0x130 : u64 DIB_bitmap

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
    mov dword ptr [rsp + 20h + 16], 1200 ; nWidth
    mov dword ptr [rsp + 20h + 24], 800 ; nHeight
    mov qword ptr [rsp + 20h + 32], 0 ; nWndParent
    mov qword ptr [rsp + 20h + 40], 0 ; hMenu
    mov qword ptr [rsp + 20h + 48], rbx ; hInstance
    mov qword ptr [rsp + 20h + 56], 0 ; lpParam
    call CreateWindowExA
    mov qword ptr [rsp + 108h], rax ; hwnd

    ; BOOL ShowWindow(
    ;         [in] HWND hWnd,
    ;         [in] int  nCmdShow
    ;         );
    mov rcx, rax
    mov rdx, 10
    call ShowWindow
    call GetLastError

    ; BOOL GetClientRect(
    ;   [in]  HWND   hWnd,
    ;   [out] LPRECT lpRect
    ; );
    mov rcx, qword ptr [rsp + 108h]
    lea rdx, dword ptr [rsp + 110h]
    call GetClientRect ; client_rect
    call GetLastError

    ; BITMAPINFO
    ; sizeof(BITMAPINFO) = 0x2c
    ; typedef struct tagBITMAPINFO {
    ;     BITMAPINFOHEADER bmiHeader;
    ;     RGBQUAD          bmiColors[1];
    ; } BITMAPINFO, *LPBITMAPINFO, *PBITMAPINFO;
    ; typedef struct tagBITMAPINFOHEADER {
    ;     DWORD biSize;            0x0
    ;     LONG  biWidth;           0x4
    ;     LONG  biHeight;          0x8
    ;     WORD  biPlanes;          0xC
    ;     WORD  biBitCount;        0xE
    ;     DWORD biCompression;     0x10
    ;     DWORD biSizeImage;       0x14
    ;     LONG  biXPelsPerMeter;   0x18
    ;     LONG  biYPelsPerMeter;   0x1C
    ;     DWORD biClrUsed;         0x20
    ;     DWORD biClrImportant;    0x24
    ; } BITMAPINFOHEADER, *LPBITMAPINFOHEADER, *PBITMAPINFOHEADER;
    ; typedef struct tagRGBQUAD {
    ;     BYTE rgbBlue;
    ;     BYTE rgbGreen;
    ;     BYTE rgbRed;
    ;     BYTE rgbReserved;
    ; } RGBQUAD;
    ; Creating a BITMAPINFOHEADER at rsp + 0x200
    vxorps ymm0, ymm0, ymm0
    vmovups ymmword ptr [rsp + 200h], ymm0
    vmovups ymmword ptr [rsp + 220h], ymm0
    mov dword ptr [rsp + 200h + 0h], 2ch ; bmiHeader.biSize
    mov eax, dword ptr [rsp + 110h + 8h]
    mov dword ptr [rsp + 200h + 4h], eax ; bmiHeader.biWidth
    mov ecx, dword ptr [rsp + 110h + 0ch]
    mov dword ptr [rsp + 200h + 8h], ecx ; bmiHeader.biHeight
    mov dword ptr [rsp + 200h + 0ch], 1 ; bmiHeader.biPlanes
    mov dword ptr [rsp + 200h + 0eh], 20h ; bmiHeader.biBitCount
    mov dword ptr [rsp + 200h + 10h], 0 ; bmiHeader.biCompression, BI_RGB = 0
    imul eax, ecx
    imul eax, 4
    mov dword ptr [rsp + 200h + 14h], eax ; bmiHeader.biSizeImage
    xor rcx, rcx
    call GetDC
    mov qword ptr [rsp + 100h], rax ; hdc
    mov rcx, rax
    call CreateCompatibleDC
    mov qword ptr [rsp + 120h], rax ; DIB_handle

    ; HBITMAP CreateDIBSection(
    ;         [in]  HDC              hdc,
    ;         [in]  const BITMAPINFO *pbmi,
    ;         [in]  UINT             usage,
    ;         [out] VOID             **ppvBits,
    ;         [in]  HANDLE           hSection,
    ;         [in]  DWORD            offset
    ;         );
    mov rcx, qword ptr [rsp + 100h]
    lea rdx, qword ptr [rsp + 200h]
    xor r8, r8
    lea r9, qword ptr [rsp + 128h]
    mov qword ptr [rsp + 20h + 0], 0
    mov dword ptr [rsp + 20h + 8], 0
    call CreateDIBSection ; fb
    mov qword ptr [rsp + 130h], rax

    mov rcx, qword ptr [rsp + 120h]
    mov rdx, rax
    call SelectObject

    mov rcx, qword ptr [rsp + 108h]
    mov rdx, qword ptr [rsp + 100h]
    call ReleaseDC
    

    loop_top:

        ; typedef struct tagMSG {
        ;   HWND   hwnd;
        ;   UINT   message;
        ;   WPARAM wParam;
        ;   LPARAM lParam;
        ;   DWORD  time;
        ;   POINT  pt;
        ;   DWORD  lPrivate;
        ; } MSG, *PMSG, *NPMSG, *LPMSG;
        ; sizeof(MSG) = 0x30
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
        vmovups ymmword ptr [rsp + 200h], ymm0
        vmovups ymmword ptr [rsp + 200h + 10h], ymm0
        ; Call PeekMessageA
        lea rcx, [rsp + 200h]
        mov rdx, 0
        mov r8, 0
        mov r9, 0
        mov dword ptr [rsp + 20h], 1 ; PM_REMOVE = 0x0001
        call PeekMessageA

        ; BOOL TranslateMessage(
        ;   [in] const MSG *lpMsg
        ; );
        lea rcx, [rsp + 200h]
        call TranslateMessage

        ; LRESULT DispatchMessageA(
        ;   [in] const MSG *lpMsg
        ; );
        lea rcx, [rsp + 200h]
        call DispatchMessageA





        
        ; Fill background
        mov rdi, qword ptr [rsp + 128h]
        mov eax, 0ff11fff3h
        mov r8d, dword ptr [rsp + 110h + 8h]
        mov ecx, dword ptr [rsp + 110h + 0ch]
        imul ecx, r8d
        rep stosd



        mov rax, 0 ; y
        mov r8d, dword ptr [rsp + 110h + 8h] ; width
        imul r8d, 4
        mov rdi, qword ptr [rsp + 128h] ; fb
        add rdi, 256
        loop_square_outer:
            mov rbx, 0 ; x
            loop_square_inner:
                mov dword ptr [rdi], 0ff0000ffh
                add rdi, 4
                add rbx, 4
                cmp rbx, 256
                jnz loop_square_inner
            sub rdi, 256
            add rdi, r8
            add rax, 4
            cmp rax, 256
            jnz loop_square_outer

        


        ; Blit
        mov rcx, qword ptr [rsp + 108h]
        call GetDC
        mov qword ptr [rsp + 100h], rax ; hdc
        ; BOOL BitBlt(
        ;         [in] HDC   hdc,
        ;         [in] int   x,
        ;         [in] int   y,
        ;         [in] int   cx,
        ;         [in] int   cy,
        ;         [in] HDC   hdcSrc,
        ;         [in] int   x1,
        ;         [in] int   y1,
        ;         [in] DWORD rop
        ;         );
        mov rcx, rax ; hdc
        mov rdx, 0 ; x
        mov r8, 0 ; y
        mov r9d, dword ptr [rsp + 110h + 8h] ; cx
        mov eax, dword ptr [rsp + 110h + 0ch]
        mov dword ptr [rsp + 20h + 0h], eax ; cy
        mov rax, qword ptr [rsp + 120h]
        mov qword ptr [rsp + 20h + 8h], rax ; hdcSrc (DIB_handle)
        mov qword ptr [rsp + 20h + 10h], 0 ; x1
        mov qword ptr [rsp + 20h + 18h], 0 ; y1
        mov qword ptr [rsp + 20h + 20h], 0cc0020h ; rop (SRCCOPY = 0cc0020h)
        call BitBlt
        mov rcx, qword ptr [rsp + 108h]
        mov rdx, qword ptr [rsp + 100h]
        call ReleaseDC


        jmp loop_top

    xor rax, rax

    pop rbp

    add rsp, 300h
    pop r15
    pop r14
    pop r13
    pop r12
    pop rsp
    pop rsi
    pop rdi
    pop rbp
    pop rbx


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



; rcx : u32 - Pos x
; rdx : u32 - Pos y
; r8 : u32 - width
; r9 : u32 - height
draw_square PROC
draw_square ENDP



end

