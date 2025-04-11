
# some project ideas

talk to me about details.

## ip messenger

* keeps contact list (it's possible to add/remove/edit a contact)
* contact is a name and ip address.
* message is sent as
```
  XMPPMessage :=
      '<message to="' + ATo + '" from="' + AFrom + '" type="chat" xmlns="jabber:client">' +
      '<body>' + AMessage + '</body>' +
      '</message>';
```

receiving party should show the message.

## network game

can be anything, chess, "sea battle", whatever.

* huge advantage if you implement it in decentralized way, i. e: it would work over xmpp.

both users just need to login to any xmpp servers, then during the game clients send to the other party xml messages.

## location sharing

get data from the gps sensor, share to other party.

ideally over xmpp. there's a XEP for that.

## http server

can be forking or cloning (threaded).

* should support basicauth, chunked and non-chunked transfer.

## http client

* should support BasicAuth and download password protected files.
* should support chunked and non-chunked transfers, when content-length is known or not known.
* should understand a couple of return codes, 301 - redirect - necessary.

it would be very good if you extend/improve my http client: https://github.com/norayr/http

## chat bot.

IRC or XMPP bot which can
* join a room
* log whatever is going on
* respond to a private conversation with anyone
* understand the command 'last N' where N is the number of messages to print.

## misfin client or server

misfin is a very simple email protocol.

## spartan/gopher/gemini browser

ui or console program that can receive .gmi and other files, render the page, go by links.

## fast sender/receiver of many files
since we learned that TCP is not optimal for small files, write a program which will send lots of small files in one stream, so on one end it should concatenate files on the fly and send, on the receiving side it should separate the files and save them.

## simple vpn
both client and the server open vpn0 interface and the socket.
then each of them reads from vpn0 and sends to the socket and vice versa.
it should also apply basic, even if very primitive encryption.

# gocomics.com or some other website scraper
do a program which given the stream, let's say https://gocomics.com/pearlsbeforeswine, will figure out latest image, and show/download it.
then will have a button for previous and next image, will figure out how to get the previous image, and show that too.

## Improve my Linux Oberon networking interface.

I implemented procedures:
```
(* Networking Procedures *)

PROCEDURE -bind(addrlen, addr, sockfd: LONGINT): LONGINT;
CODE {SYSTEM.i386}
  MOV  EAX, SOCKETCALL
  MOV  EBX, SYSBIND
  MOV  ECX, ESP  (* Parameters directly from the stack *)
  INT  80H
END bind;

PROCEDURE Bind0*(sockfd, addrPtr, addrLen: LONGINT): LONGINT;
BEGIN
  RETURN bind(addrLen, addrPtr, sockfd);
END Bind0;

PROCEDURE -listen(backlog, sockfd: LONGINT): LONGINT;
CODE {SYSTEM.i386}
  MOV EAX, SOCKETCALL
  MOV EBX, SYSLISTEN
  MOV ECX, ESP          (* pointer to [sockfd, backlog] *)
  INT 80H
END listen;

PROCEDURE Listen0*(sockfd, backlog: LONGINT): LONGINT;
BEGIN
  RETURN listen(backlog, sockfd);
END Listen0;

PROCEDURE -accept(addrLenPtr, addrPtr, sockfd: LONGINT): LONGINT;
CODE {SYSTEM.i386}
  MOV EAX, SOCKETCALL
  MOV EBX, SYSACCEPT
  MOV ECX, ESP          (* pointer to [sockfd, addrPtr, addrLenPtr] *)
  INT 80H
END accept;

PROCEDURE Accept0*(sockfd, addrPtr, addrLenPtr: LONGINT): LONGINT;
BEGIN
  RETURN accept(addrLenPtr, addrPtr, sockfd);
END Accept0;

PROCEDURE -recv(flags, len, buf, sockfd: LONGINT): LONGINT;
CODE {SYSTEM.i386}
  MOV  EAX, SOCKETCALL
  MOV  EBX, SYSRECV
  MOV  ECX, ESP  (* Parameters directly from the stack *)
  INT  80H
END recv;

PROCEDURE Recv0*(sockfd, buf, len, flags: LONGINT): LONGINT;
BEGIN
  RETURN recv(flags, len, buf, sockfd);
END Recv0;

PROCEDURE -send(flags, len, buf, sockfd: LONGINT): LONGINT;
CODE {SYSTEM.i386}
  MOV  EAX, SOCKETCALL
  MOV  EBX, SYSSEND
  MOV  ECX, ESP  (* Parameters directly from the stack *)
  INT  80H
END send;

PROCEDURE Send0*(sockfd, buf, len, flags: LONGINT): LONGINT;
BEGIN
  RETURN send(flags, len, buf, sockfd);
END Send0;
(* end of network procedures *)

```

I have checked that sending works. Receiving not tested.
Make it possible to send/receive messages.
Ideally, implement select(), poll(), epoll() wrappers.

It is semi-done for X86 but ARMV7 and MIPS CPU support is needed too.

Proof of concept would be to compile my http module and download a file from http.
Or my IRC bot can be run from within oberon os.


