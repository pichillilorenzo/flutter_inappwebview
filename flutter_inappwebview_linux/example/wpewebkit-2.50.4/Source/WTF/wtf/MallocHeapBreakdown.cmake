add_library(MallocHeapBreakdown
    STATIC
    malloc_heap_breakdown/main.cpp
)
add_library(WebKit::MallocHeapBreakdown
    ALIAS
    MallocHeapBreakdown
)

target_include_directories(MallocHeapBreakdown
    PUBLIC
    malloc_heap_breakdown
)
