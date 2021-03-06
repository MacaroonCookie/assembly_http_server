.text
.cstring
_msg:
    .asciz  "<p>hello, world!</p>"
_templ:
    .asciz "FD: %d\n"
_error_msg:
    .asciz "(Error) Number: %d\n"
_debug_msg:
    .asciz "(Debug)[%d]\n"

.text
.globl _main

_main:
    #    (%rbp) - Base Pointer
    #  -4(%rbp) - %edi
    # -16(%rbp) - %rsi
    # -24(%rbp) - socketfd
    # -32(%rbp) - server sockaddr
    # -40(%rbp) - client sockaddr
    # -48(%rbp) - response socketfd
    # -56(%rbp) - client addr len
    pushq   %rbp                # Push the base pointer to the stack
    movq    %rsp, %rbp          # Make the base pointer the current stack
    subq    $64, %rsp           # Add stack space
    movl    %edi, -4(%rbp)
    movq    %rsi, -16(%rbp)

    leaq _debug_msg(%rip), %rdi
    movq $1, %rsi
    call _printf
    # Create initial socket
    movq    $2, %rdi            # Argument 1 - AF_INET Domain
    movq    $1, %rsi            # Argument 2 - SOCK_STREAM Type
    movq    $0, %rdx            # Argument 3 - IP Protocol
    call    _socket
    cmpq $0, %rax
    jl errored
    movq    %rax, -24(%rbp)     # Store fd for socket
 
    leaq _debug_msg(%rip), %rdi
    movq $2, %rsi
    call _printf
    # Create sockaddr strcture
    movq $16, %rdi              # Argument 1 - sockaddr length
    call _malloc
    movq %rax, -32(%rbp)        # Store pointer

    movb $2, 1(%rax)            # Set SIN_Family to AF_INET (IPv4)
    movw $35091, 2(%rax)        # Set SIN_Port to 5001
    movl $0, 4(%rax)            # Set SIN_ADDR to INADDR_ANY (0)

    leaq _debug_msg(%rip), %rdi
    movq $3, %rsi
    call _printf
    # Create client sockaddr
    movq $16, %rdi              # Argument 1 - sockaddr length
    call _malloc
    cmpq $0, %rax
    jl errored

    movq %rax, -40(%rbp)

    leaq _debug_msg(%rip), %rdi
    movq $4, %rsi
    call _printf
    # Bind in preperation
    movq -24(%rbp), %rdi        # Argument 1 - socketfd
    movq -32(%rbp), %rsi        # Argument 2 - sockaddr
    movq $16, %rdx              # Argument 3 - length of sockaddr
    call _bind
    cmpq $0, %rax
    jl errored

    leaq _debug_msg(%rip), %rdi
    movq $5, %rsi
    call _printf
    # Listen
    movq -24(%rbp), %rdi        # Argument 1 - socketfd
    movq $1, %rsi               # Argument 2 - connection backlogs
    call _listen
    cmpq $0, %rax
    jl errored

    leaq _debug_msg(%rip), %rdi
    movq $6, %rsi
    call _printf
    # Accept connection
    movq -24(%rbp), %rdi        # Argument 1 - socketfd
    movq -40(%rbp), %rsi        # Argument 2 - client sockaddr
    movq $16, (%rsp)            # Argument 3 - set and point client len
    movq %rsp, %rdx
    call _accept
    cmpq $0, %rax
    jl errored

    movq %rax, -48(%rbp)        # Store new client sockfd

    leaq _debug_msg(%rip), %rdi
    movq $7, %rsi
    call _printf
    # Collect request
    movq $256, %rdi             # Create a buffer of 255 bytes
    call _malloc
    movq -48(%rbp), %rdi        # Argument 1 - client sockfd
    movq %rax, %rsi             # Argument 2 - buffer
    movq $255, %rdx             # Argument 3 - read lenth
    call _read                  # Read buffer
    movq %rsi, %rdi             # Argument 1 - buffer
    call _free                  # Free the buffer

    leaq _debug_msg(%rip), %rdi
    movq $7, %rsi
    call _printf
    # Respond to connection
    movq -48(%rbp), %rdi        # Argument 1 - response socketfd
    leaq _msg(%rip), %rsi       # Argument 2 - response string
    movq $20, %rdx              # Argument 3 - length of response
    call _write
    cmpq $0, %rax
    jl errored

    # Close response socket
    movq -40(%rbp), %rdi        # Argument 1 - rsponse socketfd
    call _close

    # Close listening socket
    movq -24(%rbp), %rdi        # Argument 1 - socketfd
    call _close

    jmp return_prep
errored:
    callq ___error
    movq (%rax), %rsi
    leaq _error_msg(%rip), %rdi
    call _printf

return_prep:
    # Prepping for return
    addq    $64, %rsp
    popq    %rbp

    movq $0, %rax
    ret
