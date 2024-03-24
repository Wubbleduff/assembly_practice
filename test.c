
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
    int fb_width = 0;
    int fb_height = 0;
    int* fb;
    {
        // Create DIB
        RECT client_rect;
        GetClientRect(hwnd, &client_rect);
        fb_width = client_rect.right;
        fb_height = client_rect.bottom;
        BITMAPINFO bmi = {
            .bmiHeader.biSize = sizeof(BITMAPINFO),
            .bmiHeader.biWidth = fb_width,
            .bmiHeader.biHeight = -fb_height,
            .bmiHeader.biPlanes = 1,
            .bmiHeader.biBitCount = 32,
            .bmiHeader.biCompression = BI_RGB,
            .bmiHeader.biSizeImage = fb_width * fb_height * sizeof(int),
        };
        HDC hdc = GetDC(NULL);
        DIB_handle = CreateCompatibleDC(hdc);
        HBITMAP DIB_bitmap = CreateDIBSection(hdc, &bmi, DIB_RGB_COLORS, (VOID **)&fb, NULL, 0);
        SelectObject(DIB_handle, DIB_bitmap);
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

        for(int y = 32; y < 64; y++)
        {
            for(int x = 32; x < 64; x++)
            {
                fb[y * fb_width + x] = 0xFFFFFFFF;
            }
        }

        HDC hdc = GetDC(hwnd);
        BitBlt(hdc, 0, 0, fb_width, fb_height, DIB_handle, 0, 0, SRCCOPY);
        ReleaseDC(hwnd, hdc);
    }

    return 0;
}
