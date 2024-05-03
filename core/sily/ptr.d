// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

/// Pointer utils
module sily.ptr;

/// Returns void pointer to `i`
void* vptr(T)(T i) {
    return cast(void*) i;
}

/// Dereferences pointer
T deref(T)(T* t) {
	return (*cast(T*)(t));
}
