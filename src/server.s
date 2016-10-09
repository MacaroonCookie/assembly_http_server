.text
.cstring
_msg:
    .asciz  "hello, world!\n"

.text
.globl _main

_main:
    pushq   %rbp                # Push the base pointer to the stack
    movq    %rsp, %rbp          # Make the base pointer the current stack pointer
    subq    $16, %rsp           # Add stack space
    movl    %edi, -4(%rbp)
    movq    %rsi, -16(%rbp)

    leaq    _msg(%rip), %rdi
    call    _printf

    addq    $16, %rsp
    popq    %rbp

    movq $0, %rax
    ret

