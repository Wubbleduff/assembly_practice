#include <windows.h>
int WINAPI MyWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR pCmdLine, int nCmdShow);
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR pCmdLine, int nCmdShow)
{
    return MyWinMain(hInstance, hPrevInstance, pCmdLine, nCmdShow);
}


