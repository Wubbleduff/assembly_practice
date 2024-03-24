
#include <windows.h>
#include <stdio.h>

//LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
//{
//    return DefWindowProc(hwnd, uMsg, wParam, lParam);
//}

static const char* window_class_name = "Window Class";
static const char* window_name = "Game";

int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, PWSTR pCmdLine, int nCmdShow)
{
    WNDCLASS wc;

    wc.style = CS_HREDRAW|CS_VREDRAW;
    wc.lpfnWndProc = DefWindowProc;
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
        WS_POPUP | WS_VISIBLE,
        100,
        100,
        500,
        500,
        NULL,
        NULL,
        hInstance,
        NULL);

    ShowWindow(hwnd, SW_SHOWDEFAULT);

    return 0;
}
