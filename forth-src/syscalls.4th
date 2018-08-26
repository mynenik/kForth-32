\ syscalls.4th
\
\ Selected system calls for kForth ver >= 1.5.x on Linux.
\
\ !!! see WARNING below !!!  
\
\ Copyright (c) 2004--2010 Krishna Myneni,
\ Provided under the GNU General Public License
\
\ Notes:
\
\ 0)   WARNING: Not all system calls provided here as Forth words have been
\               tested. USE WITH CAUTION -- it may be possible to DAMAGE
\               YOUR SYSTEM due to bugs in this code, or with improper 
\               arguments to a syscall word. The appropriate arguments for
\               a particular system call are documented in the Linux man
\               page, section 2, for that call. For example, type 
\
\                     man 2 lseek
\
\               to obtain the man page for the lseek system call.
\               Note the following for the arguments to a word:
\
\             a) addresses to strings must contain a NULL terminated
\                string.
\
\             b) addresses to structures must contain data packed with
\                the correct alignment for that structure.
\
\ 1)   System calls under Linux may also be performed using a software
\      interrupt, $80, and placing the parameters in appropriate
\      registers.
\ 
\ 2)   There are over 300 system calls under Linux. A number of
\      these are provided in the form of Forth words here. System call 
\      numbers may be found in /usr/include/asm/unistd_32.h 
\
\ 3)   The words OPEN, CLOSE, READ, WRITE, LSEEK, and IOCTL are already
\        defined in kForth with the same behavior.
\
\ Revisions:
\ 	2004-09-16  created  KM 
\       2005-11-07  ported to kForth (requires asm-x86.4th)  KM
\       2009-09-26  the word SYSCALL has been intrinsic to kForth
\                   since v. 1.4.1; this file is now updated
\                   to use the intrinsic SYSCALL and no longer requires
\                   asm-x86.4th;  KM
\       2010-04-17  renamed this file from syscalls386.4th to
\                   syscalls.4th; KM
\       2010-04-29  added numerous syscalls; most have NOT been tested  KM
\       2010-04-30  renamed open to sys_open; revised comments  KM
\       2012-01-25  made syscalls a module  km
\       2012-01-27  fixed stack diagram for getcwd; mmap with 6 args
\                   needs to use syscall 90 with 1 structure arg  KM
\       2015-08-01  added MAP_ANONYMOUS  km

BASE @
DECIMAL

Module: syscalls
Begin-Module

\ From /usr/include/asm/unistd_32.h
  0  constant  NR_RESTART
  1  constant  NR_EXIT
  2  constant  NR_FORK
  3  constant  NR_READ
  4  constant  NR_WRITE
  5  constant  NR_OPEN
  6  constant  NR_CLOSE
  7  constant  NR_WAITPID
  8  constant  NR_CREAT
  9  constant  NR_LINK
 10  constant  NR_UNLINK
 11  constant  NR_EXECVE
 12  constant  NR_CHDIR
 13  constant  NR_TIME
 14  constant  NR_MKNOD
 15  constant  NR_CHMOD
 16  constant  NR_LCHOWN
 17  constant  NR_BREAK
 18  constant  NR_OLDSTAT
 19  constant  NR_LSEEK
 20  constant  NR_GETPID
 21  constant  NR_MOUNT
 22  constant  NR_UMOUNT
 23  constant  NR_SETUID
 24  constant  NR_GETUID
 25  constant  NR_STIME
 26  constant  NR_PTRACE
 27  constant  NR_ALARM
 28  constant  NR_OLDFSTAT
 29  constant  NR_PAUSE
 30  constant  NR_UTIME
 31  constant  NR_STTY
 32  constant  NR_GTTY
 33  constant  NR_ACCESS
 34  constant  NR_NICE
 35  constant  NR_FTIME
 36  constant  NR_SYNC
 37  constant  NR_KILL
 38  constant  NR_RENAME
 39  constant  NR_MKDIR
 40  constant  NR_RMDIR
 41  constant  NR_DUP
 42  constant  NR_PIPE
 43  constant  NR_TIMES
 44  constant  NR_PROF
 45  constant  NR_BRK
 46  constant  NR_SETGID
 47  constant  NR_GETGID
 48  constant  NR_SIGNAL
 49  constant  NR_GETEUID
 50  constant  NR_GETEGID
 51  constant  NR_ACCT
 52  constant  NR_UMOUNT2
 53  constant  NR_LOCK
 54  constant  NR_IOCTL
 55  constant  NR_FCNTL
 56  constant  NR_MPX
 57  constant  NR_SETPGID
 58  constant  NR_ULIMIT
 59  constant  NR_OLDOLDUNAME
 60  constant  NR_UMASK
 61  constant  NR_CHROOT
 62  constant  NR_USTAT
 63  constant  NR_DUP2
 64  constant  NR_GETPPID
 65  constant  NR_GETPGRP
 66  constant  NR_SETSID
 67  constant  NR_SIGACTION
 68  constant  NR_SGETMASK
 69  constant  NR_SSETMASK
 70  constant  NR_SETREUID
 71  constant  NR_SETREGID
 72  constant  NR_SIGSUSPEND
 73  constant  NR_SIGPENDING
 74  constant  NR_SETHOSTNAME
 75  constant  NR_SETRLIMIT
 76  constant  NR_GETRLIMIT
 77  constant  NR_GETRUSAGE
 78 constant  NR_GETTIMEOFDAY
 79 constant  NR_SETTIMEOFDAY
 80 constant  NR_GETGROUPS
 81 constant  NR_SETGROUPS
 82 constant  NR_SELECT
 83 constant  NR_SYMLINK
 84 constant  NR_OLDLSTAT
 85 constant  NR_READLINK
 86 constant  NR_USELIB
 87 constant  NR_SWAPON
 88 constant  NR_REBOOT
 89 constant  NR_READDIR
 90 constant  NR_MMAP
 91 constant  NR_MUNMAP
 92 constant  NR_TRUNCATE
 93 constant  NR_FTRUNCATE
 94 constant  NR_FCHMOD
 95 constant  NR_FCHOWN
 96 constant  NR_GETPRIORITY
 97 constant  NR_SETPRIORITY
 98 constant  NR_PROFIL
 99 constant  NR_STATFS
100 constant  NR_FSTATFS
101 constant  NR_IOPERM
102 constant  NR_SOCKETCALL
103 constant  NR_SYSLOG
104 constant  NR_SETITIMER
105 constant  NR_GETITIMER
106 constant  NR_STAT
107 constant  NR_LSTAT
108 constant  NR_FSTAT
109 constant  NR_OLDUNAME
110 constant  NR_IOPL
111 constant  NR_VHANGUP
112 constant  NR_IDLE
113 constant  NR_VM86OLD
114 constant  NR_WAIT4
115 constant  NR_SWAPOFF
116 constant  NR_SYSINFO
117 constant  NR_IPC
118 constant  NR_FSYNC
119 constant  NR_SIGRETURN
120 constant  NR_CLONE
121 constant  NR_SETDOMAINNAME
122 constant  NR_UNAME
123 constant  NR_MODIFY_LDT
124 constant  NR_ADJTIMEX
125 constant  NR_MPROTECT
126 constant  NR_SIGPROCMASK
127 constant  NR_CREATE_MODULE
128 constant  NR_INIT_MODULE
129 constant  NR_DELETE_MODULE
130 constant  NR_GET_KERNEL_SYMS
131 constant  NR_QUOTACTL
132 constant  NR_GETPGID
133 constant  NR_FCHDIR
134 constant  NR_BDFLUSH
135 constant  NR_SYSFS
136 constant  NR_PERSONALITY
137 constant  NR_AFS_SYSCALL
138 constant  NR_SETFSUID
139 constant  NR_SETFSGID
140 constant  NR_LLSEEK
141 constant  NR_GETDENTS
142 constant  NR_NEWSELECT
143 constant  NR_FLOCK
144 constant  NR_MSYNC
145 constant  NR_READV
146 constant  NR_WRITEV
147 constant  NR_GETSID
148 constant  NR_FDATASYNC
149 constant  NR__SYSCTL
150 constant  NR_MLOCK
151 constant  NR_MUNLOCK
152 constant  NR_MLOCKALL
153 constant  NR_MUNLOCKALL
154 constant  NR_SCHED_SETPARAM
155 constant  NR_SCHED_GETPARAM
156 constant  NR_SCHED_SETSCHEDULER
157 constant  NR_SCHED_GETSCHEDULER
158 constant  NR_SCHED_YIELD
159 constant  NR_SCHED_GET_PRIORITY_MAX
160 constant  NR_SCHED_GET_PRIORITY_MIN
161 constant  NR_SCHED_RR_GET_INTERVAL
162 constant  NR_NANOSLEEP
163 constant  NR_MREMAP
164 constant  NR_SETRESUID
165 constant  NR_GETRESUID
166 constant  NR_VM86
167 constant  NR_QUERY_MODULE
168 constant  NR_POLL
169 constant  NR_NFSSERVCTL
170 constant  NR_SETRESGID
171 constant  NR_GETRESGID
172 constant  NR_PRCTL
173 constant  NR_RT_SIGRETURN
174 constant  NR_RT_SIGACTION
175 constant  NR_RT_SIGPROCMASK
176 constant  NR_RT_SIGPENDING
177 constant  NR_RT_SIGTIMEDWAIT
178 constant  NR_RT_SIGQUEUEINFO
179 constant  NR_RT_SIGSUSPEND
180 constant  NR_PREAD64
181 constant  NR_PWRITE64
182 constant  NR_CHOWN
183 constant  NR_GETCWD
184 constant  NR_CAPGET
185 constant  NR_CAPSET
186 constant  NR_SIGALTSTACK
187 constant  NR_SENDFILE
188 constant  NR_GETPMSG
189 constant  NR_PUTPMSG
190 constant  NR_VFORK
191 constant  NR_UGETRLIMIT
192 constant  NR_MMAP2


: syscall0 0 swap syscall ;
: syscall1 1 swap syscall ;
: syscall2 2 swap syscall ;
: syscall3 3 swap syscall ;
: syscall4 4 swap syscall ;
: syscall5 5 swap syscall ;
: syscall6 6 swap syscall ;

create mmap_args 6 cells allot

: !-- ( n a1 -- a2 ) tuck ! 1 cells - ;  \ utility to fill structure

Public:

\   sysexit is NOT the recommended way to exit back to the 
\   system from Forth. It is provided here as a demo of a very 
\   simple syscall.
: sysexit ( ncode -- ) NR_EXIT syscall1 ;
: execve  ( afilename aargv aenvp -- n ) NR_EXECVE syscall3 ;
: reboot  ( nmagic nmagic2 ncmd aarg -- n ) NR_REBOOT syscall4 ;
: sync    ( -- n ) NR_SYNC syscall0 ;
: uname   ( abuf -- n )  NR_UNAME syscall1 ;
: sethostname ( aname nlen -- n ) NR_SETHOSTNAME syscall2 ;
: setdomainname ( aname nlen -- n ) NR_SETDOMAINNAME syscall2 ;
: syslog  ( ntype abufp nlen -- n ) NR_SYSLOG syscall3 ;
: uselib  ( alibrary -- n )  NR_USELIB syscall1 ;
: socketcall ( ncall aargs -- n )  NR_SOCKETCALL syscall2 ;


\ File system handling
: mount   ( asrc atarget afilesystype umountflags adata -- n ) NR_MOUNT syscall5 ;
: umount  ( atarget -- n ) NR_UMOUNT syscall1 ;
: umount2 ( atarget nflags -- n ) NR_UMOUNT2 syscall2 ;
: ustat   ( ndev aubuf -- n ) NR_USTAT syscall2 ;
: statfs  ( apath astatfsbuf -- n ) NR_STATFS syscall2 ;
: fstatfs ( fd astatfsbuf -- n ) NR_FSTATFS syscall2 ;
: swapon  ( apath nswapflags -- n )  NR_SWAPON syscall2 ;
: swapoff ( apath -- n )  NR_SWAPOFF syscall1 ;
 

\ System time calls
: stime        ( atime -- n ) NR_STIME syscall1 ;
: time         ( atime -- ntime ) NR_TIME syscall1 ;
: nanosleep    ( areq arem -- n ) NR_NANOSLEEP syscall2 ;
: gettimeofday ( atimeval atimezone -- n )  NR_GETTIMEOFDAY syscall2 ;
: settimeofday ( atimeval atimezone -- n )  NR_SETTIMEOFDAY syscall2 ;

 
\ Process handling
: fork    ( -- pid ) NR_FORK syscall0 ;
: getpid  ( -- u | get process id ) NR_GETPID syscall0 ;
: waitpid ( pid astatus noptions -- pid ) NR_WAITPID syscall3 ;
: ptrace  ( nrequest pid addr adata -- n ) NR_PTRACE syscall4 ;
: brk     ( addr -- n ) NR_BRK syscall1 ;
: acct    ( afilename -- n ) NR_ACCT syscall1 ;
: times   ( abuf -- n ) NR_TIMES syscall1 ;
: iopl    ( nlevel -- n ) NR_IOPL syscall1 ;
: kill    ( npid nsig -- n ) NR_KILL syscall2 ;
: chroot  ( apath -- n ) NR_CHROOT syscall1 ;
: ioperm  ( ufrom unum nturnon -- n ) NR_IOPERM syscall3 ;
: nice ( ninc -- n ) NR_NICE syscall1 ;
: getpriority ( nwhich nwho -- n ) NR_GETPRIORITY syscall2 ;
: setpriority ( nwhich nwho nprio -- n ) NR_SETPRIORITY syscall3 ;
: setuid   ( nuid -- n ) NR_SETUID syscall1 ;
: getuid   ( -- nuid ) NR_GETUID syscall0 ;
: setgid   ( ngid -- n ) NR_SETGID syscall1 ;
: getgid   ( -- n ) NR_GETGID syscall0 ;
: geteuid  ( -- n ) NR_GETEUID syscall1 ;
: getegid  ( -- n ) NR_GETEGID syscall0 ;
: setpgid  ( npid npgid -- n ) NR_SETPGID syscall2 ;
: getppid  ( -- npid ) NR_GETPPID syscall0 ;
: getpgrp  ( -- npid ) NR_GETPGRP syscall0 ;
: setsid   ( -- npid ) NR_SETSID syscall0 ;
: setreuid ( nruid neuid -- n ) NR_SETREUID syscall2 ;
: setregid ( nrgid negid -- n ) NR_SETREGID syscall2 ;


\ Memory

\ system constants for mmap, msync, mlockall, mremap
\ from: /usr/include/bits/mman.h
 1  constant  PROT_READ   \ Page can be read
 2  constant  PROT_WRITE  \ Page can be written
 4  constant  PROT_EXEC   \ Page can be executed
 0  constant  PROT_NONE   \ Page can not be accessed
 
\ Sharing types
 1  constant  MAP_SHARED  \ Share changes
 2  constant  MAP_PRIVATE \ Changes are private
16  constant  MAP_FIXED   \ interpret address exactly
32  constant  MAP_ANONYMOUS  \ Don't use a file

\ Flags for msync
 1  constant  MS_ASYNC    \ Sync memory asynchronously
 4  constant  MS_SYNC     \ Synchronous memory sync.
 2  constant  MS_INVALIDATE  \ Invalidate the caches

\ Flags for mlockall
 1  constant  MCL_CURRENT  \ Lock all currently mapped pages
 2  constant  MCL_FUTURE   \ Locak all additions to address space

\ Flags for mremap
 1  constant  MREMAP_MAYMOVE
 2  constant  MREMAP_FIXED

: mmap       ( addr  nlength  nprot  nflags  nfd  noffset -- n ) 
    mmap_args 5 cells +
    !--  \ offset
    !--  \ fd
    !--  \ flags
    !--  \ prot
    !--  \ length
    !    \ addr
    mmap_args NR_MMAP syscall1 ;

: mmap2      ( addr  nlength  nprot  nflags  nfd  noffset -- n ) NR_MMAP2 syscall6 ;
: munmap     ( addr nlen -- n )  NR_MUNMAP syscall2 ;
: msync      ( addr nlen nflags -- n )  NR_MSYNC syscall3 ;
: mlock      ( addr nlen -- n )  NR_MLOCK syscall2 ;
: munlock    ( addr nlen -- n ) NR_MUNLOCK syscall2 ;
: mprotect   ( addr nlen nprot -- n ) NR_MPROTECT syscall3 ;
: mlockall   ( nflags -- n ) NR_MLOCKALL syscall1 ;
: munlockall ( -- n )  NR_MUNLOCKALL syscall0 ;
: mremap     ( aoldaddress noldsize nnewsize nflags -- anewmem ) NR_MREMAP syscall4 ;


\ File i/o and handling

\ System constants for file i/o
\ Standard file descriptors from: /usr/include/unistd.h
 0  constant  STDIN_FILENO    \ Standard input
 1  constant  STDOUT_FILENO   \ Standard output
 2  constant  STDERR_FILENO   \ Standard error output

\ Values for "whence" argument to lseek
 0  constant  SEEK_SET        \ Seek from beginning of file
 1  constant  SEEK_CUR        \ Seek from current position
 2  constant  SEEK_END        \ Seek from end of file

\ Constants for open/fcntl, from: /usr/include/bits/fnctl.h
   3  constant  O_ACCMODE
   0  constant  O_RDONLY
   1  constant  O_WRONLY
   2  constant  O_RDWR
 100  constant  O_CREAT     \ not fcntl
 200  constant  O_EXCL      \ not fcntl
 400  constant  O_NOCTTY    \ not fcntl
1000  constant  O_TRUNC     \ not fcntl
2000  constant  O_APPEND
4000  constant  O_NONBLOCK
O_NONBLOCK  constant  O_NDELAY
4010000  constant  O_SYNC
O_SYNC constant  O_FSYNC
20000  constant  O_ASYNC

\ Values for the second argument to fcntl
 0  constant  F_DUPFD    \ Duplicate file descriptor.
 1  constant  F_GETFD    \ Get file descriptor flags.
 2  constant  F_SETFD    \ Set file descriptor flags.
 3  constant  F_GETFL    \ Get file status flags.
 4  constant  F_SETFL    \ Set file status flags.

[undefined] read  [IF] : read ( fd buf count -- n) NR_READ syscall3 ; 
                  [ELSE] : read read ; [THEN]
[undefined] write [IF] : write ( fd buf count -- n) NR_WRITE syscall3 ;
                  [ELSE] : write write ; [THEN]
\ Change name of OPEN system call to sys_open to avoid name collision
\   with kForth's OPEN 
: sys_open ( addr  flags mode -- fd | file descriptor is returned)
	NR_OPEN syscall3 ;
[undefined] close [IF] : close ( fd -- flag )  NR_CLOSE syscall1 ; 
                  [ELSE] : close close ; [THEN]
[undefined] lseek [IF] : lseek ( fd offs type -- offs ) NR_LSEEK syscall3 ; 
                  [ELSE] : lseek  lseek ; [THEN]
: llseek ( fd offshigh offslow aresult nwhence -- n ) NR_LLSEEK syscall5 ;

[undefined] ioctl [IF] : ioctl ( fd  request argp -- error ) 
                            NR_IOCTL syscall3 ; 
                  [ELSE] : ioctl  ioctl ; [THEN]

: creat    ( apath mode -- n )        NR_CREAT  syscall2 ;
: link     ( aoldpath anewpath -- n ) NR_LINK   syscall2 ;
: unlink   ( apathname -- n )         NR_UNLINK syscall1 ;
: symlink  ( aoldpath anewpath -- n )  NR_SYMLINK syscall2 ;
: readlink ( apath abuf nbufsiz -- nsize )  NR_READLINK syscall3 ;

[undefined] chdir [IF] : chdir ( apath -- n ) NR_CHDIR syscall1 ; 
                  [ELSE] : chdir  chdir ; [THEN]
: fchdir ( fd -- n )  NR_FCHDIR syscall1 ;
: getcwd ( abuf nsize -- n ) NR_GETCWD syscall2 ;
\ Use getdents instead of readdir syscall
\ : readdir ( nfd adirp ucount -- n )  NR_READDIR syscall3 ;
: getdents ( fd adirp ncount -- n )  NR_GETDENTS syscall3 ;

: umask ( nmask -- n ) NR_UMASK syscall1 ;

: mknod ( apathname nmode ndev -- n ) NR_MKNOD syscall3 ;
: utime ( afilename atimes -- n ) NR_UTIME syscall2 ;

: chmod  ( apath nmode -- n ) NR_CHMOD syscall2 ;
: fchmod ( fd  nmode -- n )  NR_FCHMOD syscall2 ;

: chown  ( apath nowner ngroup -- n )  NR_CHOWN  syscall3 ;
: fchown ( fd  nowner  ngroup -- n )  NR_FCHOWN syscall3 ;
: lchown ( apath nowner ngroup -- n )  NR_LCHOWN syscall3 ;
: access ( apathname nmode -- n ) NR_ACCESS syscall2 ;

: fsync ( fd -- n )  NR_FSYNC syscall1 ;
: fcntl ( fd ncmd arg -- n )  NR_FCNTL syscall3 ;
: flock ( fd nop -- n )  NR_FLOCK syscall2 ;
: stat  ( apath  astatbuf  -- n )  NR_STAT  syscall2 ;
: fstat ( fd astatbuf -- n )      NR_FSTAT syscall2 ;
: lstat ( apath  astatbuf  -- n )  NR_LSTAT syscall2 ;
: truncate ( apath  nlength -- n ) NR_TRUNCATE syscall2 ;
: ftruncate ( fd  nlength -- n )  NR_FTRUNCATE syscall2 ;

: rename ( aoldpath anewpath -- n ) NR_RENAME syscall2 ;
: mkdir  ( apathname nmode -- n )   NR_MKDIR  syscall2 ;
: rmdir  ( apathname -- n )         NR_RMDIR  syscall1 ;


: select ( nfds areadfds awritefds aexceptfds atimeout -- n ) NR_SELECT syscall5 ;
: pipe ( afdarray -- n )  NR_PIPE syscall1 ;
 
\ dup and dup2 syscalls
: sys_dup ( oldfd -- n ) NR_DUP syscall1 ;
: sys_dup2 ( oldfd newfd -- n ) NR_DUP2 syscall2 ;


\ Signal handling system calls
: alarm       ( useconds -- u ) NR_ALARM syscall1 ;
: pause       ( -- n ) NR_PAUSE syscall0 ;
: signal      ( nsignum ahandler -- n ) NR_SIGNAL syscall2 ;
: sigaction   ( nsignum asigact aoldact -- n ) NR_SIGACTION syscall3 ;
: sigsuspend  ( amask -- n ) NR_SIGSUSPEND syscall1 ;
: sigpending  ( aset -- n ) NR_SIGPENDING syscall1 ;
: sigprocmask ( nhow aset aoldset -- n ) NR_SIGPROCMASK syscall3 ;

: setitimer   ( nwhich anewval aoldval -- n ) NR_SETITIMER syscall3 ;
: getitimer   ( nwhich acurrval -- n ) NR_GETITIMER syscall2 ;


\ System resource 
: setrlimit ( nresource arlim -- n ) NR_SETRLIMIT syscall2 ;
: getrlimit ( nresource arlim -- n ) NR_GETRLIMIT syscall2 ;
: getrusage ( nwho ausage -- n )  NR_GETRUSAGE syscall2 ;

: getgroups ( nsize agidlist -- n )  NR_GETGROUPS syscall2 ;
: setgroups ( nsize agidlist -- n )  NR_SETGROUPS syscall2 ;

End-Module

BASE !



