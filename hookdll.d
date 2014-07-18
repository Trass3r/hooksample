module hookdll;

import win32.windef;
import win32.winuser;
import win32.wingdi;

import dllmain;

private __gshared
{
	HHOOK hook = null;
	int lastx, lasty;
}

extern(Windows)
private LRESULT mouseMsgProc(int nCode, WPARAM wParam, LPARAM lParam)
{
	if (nCode < 0)
		return CallNextHookEx(hook, nCode, wParam, lParam);

	auto data = cast(MOUSEHOOKSTRUCT*) lParam;

	// get desktop DC
	HDC hDC = GetDC(null); // for some reason you have to call it every time

	// draw a line
	MoveToEx(hDC, lastx, lasty, null);
	LineTo(hDC, data.pt.x, data.pt.y);

	lastx = data.pt.x;
	lasty = data.pt.y;

	return CallNextHookEx(hook, nCode, wParam, lParam);
}

export extern(C)
int installHooks(HWND hWndParent)
{
	hook = SetWindowsHookEx(WH_MOUSE, &mouseMsgProc, hInstDll, 0);
	return hook != null;
}

export extern(C)
int uninstallHooks(HWND hWndParent)
{
	return UnhookWindowsHookEx(hook);
}
