Blocking vs Non-blocking Sockets
Blocking Socket

    Default behavior of sockets.

    A function like read() or recv() will wait ("block") until data is available.

    Similarly, connect() will block until the connection is complete, and accept() will block until a client connects.

    Simple to use, but not scalable for many connections: if one connection blocks, the whole app can get stuck.

Non-blocking Socket

    The socket is configured with O_NONBLOCK (e.g. via fcntl()).

    Functions like read() or recv() will return immediately:

        If there's data: returns the data.

        If there's no data: returns -1 with errno == EAGAIN or EWOULDBLOCK.

    You need to check repeatedly or use an event loop to manage many sockets efficiently.

select, poll, epoll

These are I/O multiplexing tools — they let you wait for multiple file descriptors (like sockets) to become ready for reading, writing, etc.
select()

*    Works with fd_set and a maximum of 1024 file descriptors (unless recompiled).

*    Checks every descriptor on each call — not efficient for lots of sockets.

*    Good for small applications or teaching.
```
fd_set readfds;
FD_ZERO(&readfds);
FD_SET(sock, &readfds);
select(sock + 1, &readfds, NULL, NULL, NULL);
```

fd_set readfds // This declares a set of file descriptors — a data structure used by select().

fd_set is basically a bitmask where each bit corresponds to a file descriptor number (0, 1, 2, ...).

Internally, the fd_set holds a bit for each possible file descriptor number.

When you do FD_SET(1, &readfds);, it just sets the bit at position 1 in that structure.

That tells select() you want to check file descriptor 1 (not that you’re overwriting stdout or changing anything about fd 1 itself.)


You'll use this to tell select() which fds you're interested in checking.
-------

FD_ZERO(&readfds);

*    Clears the set — initializes it so it contains no file descriptors.

*    Always do this before adding anything to the set.

 FD_SET(sock, &readfds);

*    Adds the file descriptor sock to the set.

*    You're telling select() that you want to know if sock is ready to read.

  select(sock + 1, &readfds, NULL, NULL, NULL);

    This is the actual call to select().

Arguments:
Arg         Meaning
sock + 1    Highest-numbered fd + 1 — this tells select() how many fds to check.
&readfds    Set of fds to check for readability.
NULL        We're not checking for writability.
NULL        We're not checking for exceptional conditions.
NULL        Block forever (no timeout) until something is ready.


Prepares a set of sockets to monitor.

Tells select() to wait for any of them to become readable.

Blocks until something is ready.

You then check which fd(s) became ready using FD_ISSET().


_________________________________________________

poll()

*    More flexible than select() — no hard limit on fds.

*    Uses an array of struct pollfd.

*    Still checks all descriptors each time — O(n) complexity.
```
struct pollfd fds[1];
fds[0].fd = sock;
fds[0].events = POLLIN;
poll(fds, 1, -1);
```

struct pollfd fds[1];

*    Creates an array of pollfd structs — in this case, size 1.

*    Each pollfd tells poll():

**        Which file descriptor to watch

**        What events to watch for

**        What events occurred (filled by the kernel)

---

 fds[0].fd = sock;

*    Sets the file descriptor to monitor — here, it’s sock, a socket you opened earlier.


fds[0].events = POLLIN;

*    Tells poll() that you want to know when sock is readable.

*    Other possible flags include:

**        POLLOUT – ready to write

**        POLLERR – error condition

**        POLLHUP – hang-up

**        POLLIN | POLLPRI – urgent or out-of-band data

poll(fds, 1, -1);

*    Calls the poll() syscall:

**        fds is the array of descriptors.

**        1 is the number of items in the array.

**        -1 means wait forever (no timeout).

*    It blocks until:

**        sock becomes readable

**        or an error/hangup occurs


After poll() returns:

if (fds[0].revents & POLLIN) {
    // Data is ready to be read from sock
}

The revents field is filled in by the kernel with what actually happened.

struct pollfd fds[1];          // Prepare 1 fd to monitor
fds[0].fd = sock;              // Watch this socket
fds[0].events = POLLIN;        // Wait until there's data to read
poll(fds, 1, -1);              // Block forever until it's readable



_________________________________

epoll (Linux only)





*    Designed for high performance.

*    You register fds with an epoll instance once.

*    Then you wait for events with epoll_wait() — kernel tells you which fds are ready.

    O(1) scalable — good for thousands of connections.

```
int epfd = epoll_create1(0);
struct epoll_event ev;
ev.events = EPOLLIN;
ev.data.fd = sock;
epoll_ctl(epfd, EPOLL_CTL_ADD, sock, &ev);

epoll_wait(epfd, events, maxevents, timeout);
```

int epfd = epoll_create1(0);

*    Creates an epoll instance, and returns a file descriptor (epfd) that represents it.

**    You’ll use epfd in later calls.

**    The argument 0 means “no special flags” (e.g., EPOLL_CLOEXEC if you wanted it to auto-close on exec()).

**    Think of this like epfd = epoll_create();, but with a cleaner interface.

struct epoll_event ev;

*    You define a struct to describe what you're interested in for a socket.

ev.events = EPOLLIN;

*    Set it to watch for readability (like POLLIN, same idea).

*    You could also use:

**        EPOLLOUT – ready to write

**        EPOLLET – edge-triggered mode (more efficient, but trickier)

**        EPOLLERR, EPOLLHUP, etc.

ev.data.fd = sock;

*    Store the socket fd here.

**    You could also use a pointer or integer in ev.data.ptr or ev.data.u64 if you need to track more info (e.g., a connection object).


epoll_ctl(epfd, EPOLL_CTL_ADD, sock, &ev);

*    Tells the kernel: "Please monitor sock for these events."

*    epfd: your epoll instance

*    EPOLL_CTL_ADD: operation type (add a new socket)

*    sock: the fd you're adding

*    &ev: what you're watching for

. epoll_wait(epfd, events, maxevents, timeout);

*    This is the big one — waits for events to occur.

*    Arguments:

**        epfd: your epoll instance

**        events: array of struct epoll_event (where results will be stored)

**        maxevents: how many entries fit in the events[] array

**        timeout: how long to wait

**            -1 = block forever

**            0 = return immediately (non-blocking)

**            >0 = wait that many milliseconds

After epoll_wait()
```
int n = epoll_wait(epfd, events, 64, -1);

for (int i = 0; i < n; i++) {
    int fd = events[i].data.fd;
    if (events[i].events & EPOLLIN) {
        // fd is readable
    }
}
```
    epoll_wait() returns the number of ready fds.

    events[] is filled with exactly those fds and their readiness info.

You only register fds once (epoll_ctl), not every time like with poll()/select().

epoll_wait() gives you only the ready fds, not a list you have to scan.

Scales well to tens of thousands of fds (used in web servers, DBs, etc.)



Summary
Feature         select      poll        epoll
Max fds         ~1024       No limit    No limit
Scalable?       No (O(n))   No (O(n))   Yes (O(1))
Kernel support  POSIX       POSIX       Linux only
Ideal for       Small apps  Medium apps High-load apps


-------------


epoll_wait() is the syscall where the kernel tells you which file descriptors are ready.

```
int epfd = epoll_create1(0);
```

returns a file descriptor for the epoll instance.

register file descriptors you are interested in:

```
struct epoll_event ev;
ev.events = EPOLLIN;      // Interested in read readiness
ev.data.fd = sock;        // The fd you're watching
epoll_ctl(epfd, EPOLL_CTL_ADD, sock, &ev);
```

the kernel will store those in its internal interest list.

wait for events:

```
struct epoll_event events[64];
int n = epoll_wait(epfd, events, 64, -1); // blocks until event
```

_____________________



during epoll_wait()

* The kernel monitors all registered fds.

* When one or more of them becomes ready (e.g., data available to read), the kernel collects those into a list.

* epoll_wait returns:

** The number of ready fds.
** It fills the events[] array with details for each ready fd.

The kernel tells you which fds are ready by filling the array you pass to epoll_wait() with epoll_event structs, each containing the ready fd and the kind of event (readable, writable, etc.).

Let's say you can read/write on a fd from the array that was returned by epoll_wait:

```
for (int i = 0; i < n; i++) {
    int fd = events[i].data.fd;
    // now you can read() or write() on fd
}
```




Events
-------


 EPOLLIN — Readable

    “There’s data available to read”

Happens when:

    A TCP socket has incoming data

    A new connection is waiting (on a listening socket!)

    A pipe or socketpair has data

    A remote side closed the connection (you’ll see it as read() returns 0)



if (events[i].events & EPOLLIN) {
    // Read data from socket, or accept new connection
}





EPOLLOUT — Writable

    “You can write to the socket without blocking”

Happens when:

    The socket send buffer has room

    For non-blocking connect(), this signals connect success

if (events[i].events & EPOLLOUT) {
    // Safe to write data to socket
}







EPOLLERR — Error Condition

    “Something went wrong”

    The socket has an error pending.

    You should call getsockopt(fd, SOL_SOCKET, SO_ERROR, ...) to get the error code.

if (events[i].events & EPOLLERR) {
    // Check what the error is
}



EPOLLHUP — Hang-up

    “The other side closed the connection”

    For TCP, the remote side did a close().

    Often comes together with EPOLLIN (so a read() gives 0 bytes).

if (events[i].events & EPOLLHUP) {
    // Close your side too
}


EPOLLRDHUP (Linux-only)

    “Peer closed their half of the connection (read shutdown)”

Useful for detecting shutdown more precisely than EPOLLIN + read() == 0.




EPOLLET — Edge-Triggered Mode (optional)

    Notifies only once when the state changes

    More efficient but harder to use

    You need to read/write in a loop until EAGAIN (non-blocking mode)

Without EPOLLET: you get notified as long as the socket is readable/writable.
With EPOLLET: you only get notified once when it becomes readable, so you have to drain all data in one go.




______________________________________



Typical Scenarios
------------------
Socket type                   What can happen
TCP server socket             EPOLLIN = new client is waiting (accept())
TCP client socket             EPOLLIN = data received
                              EPOLLOUT = can send
                              EPOLLHUP = remote closed
UDP socket                    EPOLLIN = new datagram arrived
Pipe / FIFO                   EPOLLIN = data available to read



Main Events You Care About
EPOLLIN                 Ready to read
EPOLLOUT                Ready to write
EPOLLERR                Error happened
EPOLLHUP                Remote closed connection
EPOLLRDHUP              Remote closed their write-end
EPOLLET                 Edge-triggered (faster, more complex)


