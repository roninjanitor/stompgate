#!/usr/bin/python3
# Ask the visible X11 windows of one WM_CLASS to close, the way a window
# manager's close button does: send WM_DELETE_WINDOW to each mapped one that
# supports it. Wine also gives every process hidden "Default IME" windows;
# asking those to close too leaves Cortex Control ignoring the real request,
# which is why this skips unmapped windows (and why taskkill doesn't work). stompgate --quit uses this
# for Cortex Control inside gamescope, whose own X server Hyprland can't reach.
# Plain ctypes on libX11, so it needs nothing beyond Python and XWayland.
#
# Usage: x11-close.py DISPLAY WM_CLASS
# Exits 0 when at least one window was asked to close, 1 when none matched.

import ctypes
import ctypes.util
import sys

Window = Atom = ctypes.c_ulong


class XClassHint(ctypes.Structure):
    _fields_ = [("res_name", ctypes.c_void_p), ("res_class", ctypes.c_void_p)]


class XWindowAttributes(ctypes.Structure):
    _fields_ = [
        ("x", ctypes.c_int), ("y", ctypes.c_int),
        ("width", ctypes.c_int), ("height", ctypes.c_int),
        ("border_width", ctypes.c_int), ("depth", ctypes.c_int),
        ("visual", ctypes.c_void_p), ("root", Window),
        ("class", ctypes.c_int), ("bit_gravity", ctypes.c_int), ("win_gravity", ctypes.c_int),
        ("backing_store", ctypes.c_int),
        ("backing_planes", ctypes.c_ulong), ("backing_pixel", ctypes.c_ulong),
        ("save_under", ctypes.c_int), ("colormap", ctypes.c_ulong),
        ("map_installed", ctypes.c_int), ("map_state", ctypes.c_int),
        ("all_event_masks", ctypes.c_long), ("your_event_mask", ctypes.c_long),
        ("do_not_propagate_mask", ctypes.c_long),
        ("override_redirect", ctypes.c_int), ("screen", ctypes.c_void_p),
    ]


class XClientMessageEvent(ctypes.Structure):
    _fields_ = [
        ("type", ctypes.c_int),
        ("serial", ctypes.c_ulong),
        ("send_event", ctypes.c_int),
        ("display", ctypes.c_void_p),
        ("window", Window),
        ("message_type", Atom),
        ("format", ctypes.c_int),
        ("data", ctypes.c_long * 5),
    ]


class XEvent(ctypes.Union):
    _fields_ = [("xclient", XClientMessageEvent), ("pad", ctypes.c_long * 24)]


ClientMessage = 33
IsViewable = 2
ERROR_HANDLER = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_void_p, ctypes.c_void_p)


def main():
    if len(sys.argv) != 3:
        sys.exit("usage: x11-close.py DISPLAY WM_CLASS")
    display_name, wm_class = sys.argv[1].encode(), sys.argv[2].encode()

    x = ctypes.CDLL(ctypes.util.find_library("X11") or "libX11.so.6")
    x.XOpenDisplay.restype = ctypes.c_void_p
    x.XOpenDisplay.argtypes = [ctypes.c_char_p]
    x.XDefaultRootWindow.restype = Window
    x.XDefaultRootWindow.argtypes = [ctypes.c_void_p]
    x.XInternAtom.restype = Atom
    x.XInternAtom.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int]
    x.XQueryTree.argtypes = [ctypes.c_void_p, Window, ctypes.POINTER(Window), ctypes.POINTER(Window),
                             ctypes.POINTER(ctypes.POINTER(Window)), ctypes.POINTER(ctypes.c_uint)]
    x.XGetWindowAttributes.argtypes = [ctypes.c_void_p, Window, ctypes.POINTER(XWindowAttributes)]
    x.XGetClassHint.argtypes = [ctypes.c_void_p, Window, ctypes.POINTER(XClassHint)]
    x.XGetWMProtocols.argtypes = [ctypes.c_void_p, Window, ctypes.POINTER(ctypes.POINTER(Atom)),
                                  ctypes.POINTER(ctypes.c_int)]
    x.XSendEvent.argtypes = [ctypes.c_void_p, Window, ctypes.c_int, ctypes.c_long, ctypes.POINTER(XEvent)]
    x.XFree.argtypes = [ctypes.c_void_p]
    x.XSync.argtypes = [ctypes.c_void_p, ctypes.c_int]
    x.XCloseDisplay.argtypes = [ctypes.c_void_p]

    # Windows can vanish while we walk the tree; Xlib's default handler would
    # exit on the resulting BadWindow.
    ignore_errors = ERROR_HANDLER(lambda dpy, err: 0)
    x.XSetErrorHandler(ignore_errors)

    dpy = x.XOpenDisplay(display_name)
    if not dpy:
        sys.exit(f"x11-close.py: cannot open display {sys.argv[1]}")
    wm_protocols = x.XInternAtom(dpy, b"WM_PROTOCOLS", 0)
    wm_delete = x.XInternAtom(dpy, b"WM_DELETE_WINDOW", 0)

    def children(window):
        root, parent = Window(), Window()
        kids, count = ctypes.POINTER(Window)(), ctypes.c_uint()
        if not x.XQueryTree(dpy, window, ctypes.byref(root), ctypes.byref(parent),
                            ctypes.byref(kids), ctypes.byref(count)):
            return []
        found = [kids[i] for i in range(count.value)]
        if kids:
            x.XFree(kids)
        return found

    def viewable(window):
        attrs = XWindowAttributes()
        return bool(x.XGetWindowAttributes(dpy, window, ctypes.byref(attrs))) and attrs.map_state == IsViewable

    def has_class(window):
        hint = XClassHint()
        if not x.XGetClassHint(dpy, window, ctypes.byref(hint)):
            return False
        match = bool(hint.res_class) and ctypes.string_at(hint.res_class) == wm_class
        for ptr in (hint.res_name, hint.res_class):
            if ptr:
                x.XFree(ptr)
        return match

    def accepts_delete(window):
        atoms, count = ctypes.POINTER(Atom)(), ctypes.c_int()
        if not x.XGetWMProtocols(dpy, window, ctypes.byref(atoms), ctypes.byref(count)):
            return False
        found = any(atoms[i] == wm_delete for i in range(count.value))
        x.XFree(atoms)
        return found

    asked = 0
    pending = children(x.XDefaultRootWindow(dpy))
    while pending:
        window = pending.pop()
        if viewable(window) and has_class(window) and accepts_delete(window):
            event = XEvent()
            event.xclient.type = ClientMessage
            event.xclient.window = window
            event.xclient.message_type = wm_protocols
            event.xclient.format = 32
            event.xclient.data[0] = wm_delete
            x.XSendEvent(dpy, window, 0, 0, ctypes.byref(event))
            asked += 1
        else:
            pending.extend(children(window))
    x.XSync(dpy, 0)
    x.XCloseDisplay(dpy)
    sys.exit(0 if asked else 1)


if __name__ == "__main__":
    main()
