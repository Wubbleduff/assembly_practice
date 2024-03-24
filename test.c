
#include <windows.h>
#include <stdio.h>

LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    LRESULT result = 0;

    switch (uMsg)
    {
        case WM_DESTROY:
        {
            //PostQuitMessage(0);
            exit(0);
            return 0;
        }
        break;

        case WM_CLOSE: 
        {
            //DestroyWindow(hwnd);
            exit(0);
            return 0;
        }  
        break;

        case WM_PAINT:
        {
            ValidateRect(hwnd, 0);
        }
        break;

        case WM_KEYDOWN: 
        {
            exit(0);
        }
        break;

        // case WM_KEYDOWN: 
        // {
        //     g_keyboard[wParam] = true;
        // }
        // break;

        // case WM_KEYUP:
        // {
        //     g_keyboard[wParam] = false;
        // }
        // break;

        // case WM_LBUTTONDOWN:
        // {
        //     g_mouse_button[0] = true;
        // }
        // break;
        // case WM_LBUTTONUP:
        // {
        //     g_mouse_button[0] = false;
        // }
        // break;

        // case WM_RBUTTONDOWN:
        // {
        //     g_mouse_button[1] = true;
        // }
        // break;
        // case WM_RBUTTONUP:
        // {
        //     g_mouse_button[1] = false;
        // }
        // break;

        default:
        {
            result = DefWindowProc(hwnd, uMsg, wParam, lParam);
        }
        break;
    }

    return result;
}

static const char* window_class_name = "Window Class";
static const char* window_name = "Game";

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR pCmdLine, int nCmdShow)
{
    WNDCLASS wc;

    wc.style = CS_HREDRAW|CS_VREDRAW;
    wc.lpfnWndProc = WindowProc;
    wc.cbClsExtra = 0;
    wc.cbWndExtra = 0;
    wc.hInstance = hInstance;
    wc.hIcon = 0;
    wc.hCursor = 0;
    wc.hbrBackground = 0;
    wc.lpszMenuName = 0;
    wc.lpszClassName = window_class_name;
    ATOM register_class_result = RegisterClassA(&wc);

    int a = GetLastError();

    HWND hwnd = CreateWindowExA(
        0,
        window_class_name,
        window_name,
        WS_OVERLAPPEDWINDOW, //WS_POPUP | WS_VISIBLE,
        100,
        100,
        500,
        500,
        NULL,
        NULL,
        hInstance,
        NULL);

    ShowWindow(hwnd, SW_SHOWDEFAULT);

    HDC DIB_handle;
    int fb_width = 500;
    int fb_height = 500;
    int* fb;
    {
        // Create DIB
        HBITMAP DIB_bitmap;
        int DIB_row_byte_width;
        HDC hdc = GetDC(hwnd);
        RECT client_rect;
        GetClientRect(hwnd, &client_rect);
        fb_width = client_rect.right;
        fb_height = client_rect.bottom;
        int bitCount = 32;
        DIB_row_byte_width = ((fb_width * (bitCount / 8) + 3) & -4);
        int totalBytes = DIB_row_byte_width * fb_height;
        BITMAPINFO mybmi = {0};
        mybmi.bmiHeader.biSize = sizeof(mybmi);
        mybmi.bmiHeader.biWidth = fb_width;
        mybmi.bmiHeader.biHeight = -fb_height;
        mybmi.bmiHeader.biPlanes = 1;
        mybmi.bmiHeader.biBitCount = bitCount;
        mybmi.bmiHeader.biCompression = BI_RGB;
        mybmi.bmiHeader.biSizeImage = totalBytes;
        mybmi.bmiHeader.biXPelsPerMeter = 0;
        mybmi.bmiHeader.biYPelsPerMeter = 0;
        DIB_handle = CreateCompatibleDC(hdc);
        DIB_bitmap = CreateDIBSection(hdc, &mybmi, DIB_RGB_COLORS, (VOID **)&fb, NULL, 0);
        (HBITMAP)SelectObject(DIB_handle, DIB_bitmap);
        ReleaseDC(hwnd, hdc);
    }
    const int fb_size = fb_width * fb_height;
    memset(fb, 0x88, fb_size * sizeof(*fb));

    int running = 1;
    while(running)
    {
        MSG msg;
        int asdf = sizeof(msg);
        while(PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
        {
            if(msg.message == WM_QUIT)
            {
                running = 0;
                break;
            }
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }

        HDC hdc = GetDC(hwnd);
        BitBlt(hdc, 0, 0, fb_width, fb_height, DIB_handle, 0, 0, SRCCOPY);
        ReleaseDC(hwnd, hdc);
    }

    return 0;
}
