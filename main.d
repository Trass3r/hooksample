module main;

import std.stdio;
import win32.windows;

extern(C) int installHooks(HWND hWndParent);
extern(C) int uninstallHooks(HWND hWndParent);

// HACK for const wchar*
class TypeInfo_xPu : TypeInfo
{
}

// length is number of wchars
private string utf16ToUtf8(in wchar* str, size_t length) // pure nothrow
{
	string result;

	if (!length)
		return result;

	// get length
	int size;
	size = WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS,
	                           str, cast(int)length, // input
	                           null, 0,              // output
	                           null, null);          // invalid for CP_UTF8

	result.length = size;

	size = WideCharToMultiByte(CP_UTF8, 0,
	                           str, cast(int)length,
	                           cast(char*)result.ptr, size,
	                           null, null);

	if (!size)
		result.length = 0;

	return result;
}

private string getErrorMessage()
{
	LPWSTR lpMsgBuf = null;
	DWORD len = FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_ALLOCATE_BUFFER,
	                           null,
	                           GetLastError(),
	                           MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // user default language
	                           cast(LPWSTR) &lpMsgBuf,
	                           0,
	                           null);

	string message;
	if (lpMsgBuf)
	{
		message = utf16ToUtf8(lpMsgBuf, len);
		// string has \r\n at the end
		message = message[0 .. $-2];
		LocalFree(lpMsgBuf);
	}
	return message;
}

int main()
{
	if (!installHooks(null))
		write(getErrorMessage);

	scope(exit)
	{
		if (!uninstallHooks(null))
			write(getErrorMessage);
	}

	Sleep(10_000); // ms

	return 0;
}