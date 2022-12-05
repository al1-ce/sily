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