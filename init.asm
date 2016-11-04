
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  10:	00 
  11:	c7 04 24 aa 08 00 00 	movl   $0x8aa,(%esp)
  18:	e8 87 03 00 00       	call   3a4 <open>
  1d:	85 c0                	test   %eax,%eax
  1f:	79 30                	jns    51 <main+0x51>
    mknod("console", 1, 1);
  21:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  28:	00 
  29:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  30:	00 
  31:	c7 04 24 aa 08 00 00 	movl   $0x8aa,(%esp)
  38:	e8 6f 03 00 00       	call   3ac <mknod>
    open("console", O_RDWR);
  3d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  44:	00 
  45:	c7 04 24 aa 08 00 00 	movl   $0x8aa,(%esp)
  4c:	e8 53 03 00 00       	call   3a4 <open>
  }
  dup(0);  // stdout
  51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  58:	e8 7f 03 00 00       	call   3dc <dup>
  dup(0);  // stderr
  5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  64:	e8 73 03 00 00       	call   3dc <dup>

  for(;;){
    printf(1, "init: starting sh\n");
  69:	c7 44 24 04 b2 08 00 	movl   $0x8b2,0x4(%esp)
  70:	00 
  71:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  78:	e8 64 04 00 00       	call   4e1 <printf>
    pid = fork();
  7d:	e8 da 02 00 00       	call   35c <fork>
  82:	89 44 24 1c          	mov    %eax,0x1c(%esp)
    if(pid < 0){
  86:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  8b:	79 19                	jns    a6 <main+0xa6>
      printf(1, "init: fork failed\n");
  8d:	c7 44 24 04 c5 08 00 	movl   $0x8c5,0x4(%esp)
  94:	00 
  95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9c:	e8 40 04 00 00       	call   4e1 <printf>
      exit();
  a1:	e8 be 02 00 00       	call   364 <exit>
    }
    if(pid == 0){
  a6:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  ab:	75 2d                	jne    da <main+0xda>
      exec("sh", argv);
  ad:	c7 44 24 04 44 0b 00 	movl   $0xb44,0x4(%esp)
  b4:	00 
  b5:	c7 04 24 a7 08 00 00 	movl   $0x8a7,(%esp)
  bc:	e8 db 02 00 00       	call   39c <exec>
      printf(1, "init: exec sh failed\n");
  c1:	c7 44 24 04 d8 08 00 	movl   $0x8d8,0x4(%esp)
  c8:	00 
  c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d0:	e8 0c 04 00 00       	call   4e1 <printf>
      exit();
  d5:	e8 8a 02 00 00       	call   364 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  da:	eb 14                	jmp    f0 <main+0xf0>
      printf(1, "zombie!\n");
  dc:	c7 44 24 04 ee 08 00 	movl   $0x8ee,0x4(%esp)
  e3:	00 
  e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  eb:	e8 f1 03 00 00       	call   4e1 <printf>
    if(pid == 0){
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
  f0:	e8 77 02 00 00       	call   36c <wait>
  f5:	89 44 24 18          	mov    %eax,0x18(%esp)
  f9:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
  fe:	78 0a                	js     10a <main+0x10a>
 100:	8b 44 24 18          	mov    0x18(%esp),%eax
 104:	3b 44 24 1c          	cmp    0x1c(%esp),%eax
 108:	75 d2                	jne    dc <main+0xdc>
      printf(1, "zombie!\n");
  }
 10a:	e9 5a ff ff ff       	jmp    69 <main+0x69>
 10f:	90                   	nop

00000110 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 110:	55                   	push   %ebp
 111:	89 e5                	mov    %esp,%ebp
 113:	57                   	push   %edi
 114:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 115:	8b 4d 08             	mov    0x8(%ebp),%ecx
 118:	8b 55 10             	mov    0x10(%ebp),%edx
 11b:	8b 45 0c             	mov    0xc(%ebp),%eax
 11e:	89 cb                	mov    %ecx,%ebx
 120:	89 df                	mov    %ebx,%edi
 122:	89 d1                	mov    %edx,%ecx
 124:	fc                   	cld    
 125:	f3 aa                	rep stos %al,%es:(%edi)
 127:	89 ca                	mov    %ecx,%edx
 129:	89 fb                	mov    %edi,%ebx
 12b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 12e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 131:	5b                   	pop    %ebx
 132:	5f                   	pop    %edi
 133:	5d                   	pop    %ebp
 134:	c3                   	ret    

00000135 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 135:	55                   	push   %ebp
 136:	89 e5                	mov    %esp,%ebp
 138:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13b:	8b 45 08             	mov    0x8(%ebp),%eax
 13e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 141:	90                   	nop
 142:	8b 45 08             	mov    0x8(%ebp),%eax
 145:	8d 50 01             	lea    0x1(%eax),%edx
 148:	89 55 08             	mov    %edx,0x8(%ebp)
 14b:	8b 55 0c             	mov    0xc(%ebp),%edx
 14e:	8d 4a 01             	lea    0x1(%edx),%ecx
 151:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 154:	8a 12                	mov    (%edx),%dl
 156:	88 10                	mov    %dl,(%eax)
 158:	8a 00                	mov    (%eax),%al
 15a:	84 c0                	test   %al,%al
 15c:	75 e4                	jne    142 <strcpy+0xd>
    ;
  return os;
 15e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 161:	c9                   	leave  
 162:	c3                   	ret    

00000163 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 163:	55                   	push   %ebp
 164:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 166:	eb 06                	jmp    16e <strcmp+0xb>
    p++, q++;
 168:	ff 45 08             	incl   0x8(%ebp)
 16b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 16e:	8b 45 08             	mov    0x8(%ebp),%eax
 171:	8a 00                	mov    (%eax),%al
 173:	84 c0                	test   %al,%al
 175:	74 0e                	je     185 <strcmp+0x22>
 177:	8b 45 08             	mov    0x8(%ebp),%eax
 17a:	8a 10                	mov    (%eax),%dl
 17c:	8b 45 0c             	mov    0xc(%ebp),%eax
 17f:	8a 00                	mov    (%eax),%al
 181:	38 c2                	cmp    %al,%dl
 183:	74 e3                	je     168 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 185:	8b 45 08             	mov    0x8(%ebp),%eax
 188:	8a 00                	mov    (%eax),%al
 18a:	0f b6 d0             	movzbl %al,%edx
 18d:	8b 45 0c             	mov    0xc(%ebp),%eax
 190:	8a 00                	mov    (%eax),%al
 192:	0f b6 c0             	movzbl %al,%eax
 195:	29 c2                	sub    %eax,%edx
 197:	89 d0                	mov    %edx,%eax
}
 199:	5d                   	pop    %ebp
 19a:	c3                   	ret    

0000019b <strlen>:

uint
strlen(char *s)
{
 19b:	55                   	push   %ebp
 19c:	89 e5                	mov    %esp,%ebp
 19e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1a8:	eb 03                	jmp    1ad <strlen+0x12>
 1aa:	ff 45 fc             	incl   -0x4(%ebp)
 1ad:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1b0:	8b 45 08             	mov    0x8(%ebp),%eax
 1b3:	01 d0                	add    %edx,%eax
 1b5:	8a 00                	mov    (%eax),%al
 1b7:	84 c0                	test   %al,%al
 1b9:	75 ef                	jne    1aa <strlen+0xf>
    ;
  return n;
 1bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1be:	c9                   	leave  
 1bf:	c3                   	ret    

000001c0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c0:	55                   	push   %ebp
 1c1:	89 e5                	mov    %esp,%ebp
 1c3:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1c6:	8b 45 10             	mov    0x10(%ebp),%eax
 1c9:	89 44 24 08          	mov    %eax,0x8(%esp)
 1cd:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d0:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d4:	8b 45 08             	mov    0x8(%ebp),%eax
 1d7:	89 04 24             	mov    %eax,(%esp)
 1da:	e8 31 ff ff ff       	call   110 <stosb>
  return dst;
 1df:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1e2:	c9                   	leave  
 1e3:	c3                   	ret    

000001e4 <strchr>:

char*
strchr(const char *s, char c)
{
 1e4:	55                   	push   %ebp
 1e5:	89 e5                	mov    %esp,%ebp
 1e7:	83 ec 04             	sub    $0x4,%esp
 1ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ed:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1f0:	eb 12                	jmp    204 <strchr+0x20>
    if(*s == c)
 1f2:	8b 45 08             	mov    0x8(%ebp),%eax
 1f5:	8a 00                	mov    (%eax),%al
 1f7:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1fa:	75 05                	jne    201 <strchr+0x1d>
      return (char*)s;
 1fc:	8b 45 08             	mov    0x8(%ebp),%eax
 1ff:	eb 11                	jmp    212 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 201:	ff 45 08             	incl   0x8(%ebp)
 204:	8b 45 08             	mov    0x8(%ebp),%eax
 207:	8a 00                	mov    (%eax),%al
 209:	84 c0                	test   %al,%al
 20b:	75 e5                	jne    1f2 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 20d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 212:	c9                   	leave  
 213:	c3                   	ret    

00000214 <gets>:

char*
gets(char *buf, int max)
{
 214:	55                   	push   %ebp
 215:	89 e5                	mov    %esp,%ebp
 217:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 221:	eb 49                	jmp    26c <gets+0x58>
    cc = read(0, &c, 1);
 223:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 22a:	00 
 22b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 22e:	89 44 24 04          	mov    %eax,0x4(%esp)
 232:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 239:	e8 3e 01 00 00       	call   37c <read>
 23e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 241:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 245:	7f 02                	jg     249 <gets+0x35>
      break;
 247:	eb 2c                	jmp    275 <gets+0x61>
    buf[i++] = c;
 249:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24c:	8d 50 01             	lea    0x1(%eax),%edx
 24f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 252:	89 c2                	mov    %eax,%edx
 254:	8b 45 08             	mov    0x8(%ebp),%eax
 257:	01 c2                	add    %eax,%edx
 259:	8a 45 ef             	mov    -0x11(%ebp),%al
 25c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 25e:	8a 45 ef             	mov    -0x11(%ebp),%al
 261:	3c 0a                	cmp    $0xa,%al
 263:	74 10                	je     275 <gets+0x61>
 265:	8a 45 ef             	mov    -0x11(%ebp),%al
 268:	3c 0d                	cmp    $0xd,%al
 26a:	74 09                	je     275 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 26c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 26f:	40                   	inc    %eax
 270:	3b 45 0c             	cmp    0xc(%ebp),%eax
 273:	7c ae                	jl     223 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 275:	8b 55 f4             	mov    -0xc(%ebp),%edx
 278:	8b 45 08             	mov    0x8(%ebp),%eax
 27b:	01 d0                	add    %edx,%eax
 27d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 280:	8b 45 08             	mov    0x8(%ebp),%eax
}
 283:	c9                   	leave  
 284:	c3                   	ret    

00000285 <stat>:

int
stat(char *n, struct stat *st)
{
 285:	55                   	push   %ebp
 286:	89 e5                	mov    %esp,%ebp
 288:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 28b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 292:	00 
 293:	8b 45 08             	mov    0x8(%ebp),%eax
 296:	89 04 24             	mov    %eax,(%esp)
 299:	e8 06 01 00 00       	call   3a4 <open>
 29e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2a5:	79 07                	jns    2ae <stat+0x29>
    return -1;
 2a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2ac:	eb 23                	jmp    2d1 <stat+0x4c>
  r = fstat(fd, st);
 2ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 2b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b8:	89 04 24             	mov    %eax,(%esp)
 2bb:	e8 fc 00 00 00       	call   3bc <fstat>
 2c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c6:	89 04 24             	mov    %eax,(%esp)
 2c9:	e8 be 00 00 00       	call   38c <close>
  return r;
 2ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2d1:	c9                   	leave  
 2d2:	c3                   	ret    

000002d3 <atoi>:

int
atoi(const char *s)
{
 2d3:	55                   	push   %ebp
 2d4:	89 e5                	mov    %esp,%ebp
 2d6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2e0:	eb 24                	jmp    306 <atoi+0x33>
    n = n*10 + *s++ - '0';
 2e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2e5:	89 d0                	mov    %edx,%eax
 2e7:	c1 e0 02             	shl    $0x2,%eax
 2ea:	01 d0                	add    %edx,%eax
 2ec:	01 c0                	add    %eax,%eax
 2ee:	89 c1                	mov    %eax,%ecx
 2f0:	8b 45 08             	mov    0x8(%ebp),%eax
 2f3:	8d 50 01             	lea    0x1(%eax),%edx
 2f6:	89 55 08             	mov    %edx,0x8(%ebp)
 2f9:	8a 00                	mov    (%eax),%al
 2fb:	0f be c0             	movsbl %al,%eax
 2fe:	01 c8                	add    %ecx,%eax
 300:	83 e8 30             	sub    $0x30,%eax
 303:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 306:	8b 45 08             	mov    0x8(%ebp),%eax
 309:	8a 00                	mov    (%eax),%al
 30b:	3c 2f                	cmp    $0x2f,%al
 30d:	7e 09                	jle    318 <atoi+0x45>
 30f:	8b 45 08             	mov    0x8(%ebp),%eax
 312:	8a 00                	mov    (%eax),%al
 314:	3c 39                	cmp    $0x39,%al
 316:	7e ca                	jle    2e2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 318:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 31b:	c9                   	leave  
 31c:	c3                   	ret    

0000031d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 31d:	55                   	push   %ebp
 31e:	89 e5                	mov    %esp,%ebp
 320:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 323:	8b 45 08             	mov    0x8(%ebp),%eax
 326:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 329:	8b 45 0c             	mov    0xc(%ebp),%eax
 32c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 32f:	eb 16                	jmp    347 <memmove+0x2a>
    *dst++ = *src++;
 331:	8b 45 fc             	mov    -0x4(%ebp),%eax
 334:	8d 50 01             	lea    0x1(%eax),%edx
 337:	89 55 fc             	mov    %edx,-0x4(%ebp)
 33a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 33d:	8d 4a 01             	lea    0x1(%edx),%ecx
 340:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 343:	8a 12                	mov    (%edx),%dl
 345:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 347:	8b 45 10             	mov    0x10(%ebp),%eax
 34a:	8d 50 ff             	lea    -0x1(%eax),%edx
 34d:	89 55 10             	mov    %edx,0x10(%ebp)
 350:	85 c0                	test   %eax,%eax
 352:	7f dd                	jg     331 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 354:	8b 45 08             	mov    0x8(%ebp),%eax
}
 357:	c9                   	leave  
 358:	c3                   	ret    
 359:	90                   	nop
 35a:	90                   	nop
 35b:	90                   	nop

0000035c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 35c:	b8 01 00 00 00       	mov    $0x1,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <exit>:
SYSCALL(exit)
 364:	b8 02 00 00 00       	mov    $0x2,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <wait>:
SYSCALL(wait)
 36c:	b8 03 00 00 00       	mov    $0x3,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <pipe>:
SYSCALL(pipe)
 374:	b8 04 00 00 00       	mov    $0x4,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <read>:
SYSCALL(read)
 37c:	b8 05 00 00 00       	mov    $0x5,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <write>:
SYSCALL(write)
 384:	b8 10 00 00 00       	mov    $0x10,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <close>:
SYSCALL(close)
 38c:	b8 15 00 00 00       	mov    $0x15,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <kill>:
SYSCALL(kill)
 394:	b8 06 00 00 00       	mov    $0x6,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <exec>:
SYSCALL(exec)
 39c:	b8 07 00 00 00       	mov    $0x7,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <open>:
SYSCALL(open)
 3a4:	b8 0f 00 00 00       	mov    $0xf,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <mknod>:
SYSCALL(mknod)
 3ac:	b8 11 00 00 00       	mov    $0x11,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <unlink>:
SYSCALL(unlink)
 3b4:	b8 12 00 00 00       	mov    $0x12,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <fstat>:
SYSCALL(fstat)
 3bc:	b8 08 00 00 00       	mov    $0x8,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <link>:
SYSCALL(link)
 3c4:	b8 13 00 00 00       	mov    $0x13,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <mkdir>:
SYSCALL(mkdir)
 3cc:	b8 14 00 00 00       	mov    $0x14,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <chdir>:
SYSCALL(chdir)
 3d4:	b8 09 00 00 00       	mov    $0x9,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <dup>:
SYSCALL(dup)
 3dc:	b8 0a 00 00 00       	mov    $0xa,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <getpid>:
SYSCALL(getpid)
 3e4:	b8 0b 00 00 00       	mov    $0xb,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <sbrk>:
SYSCALL(sbrk)
 3ec:	b8 0c 00 00 00       	mov    $0xc,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <sleep>:
SYSCALL(sleep)
 3f4:	b8 0d 00 00 00       	mov    $0xd,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <uptime>:
SYSCALL(uptime)
 3fc:	b8 0e 00 00 00       	mov    $0xe,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 404:	55                   	push   %ebp
 405:	89 e5                	mov    %esp,%ebp
 407:	83 ec 18             	sub    $0x18,%esp
 40a:	8b 45 0c             	mov    0xc(%ebp),%eax
 40d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 410:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 417:	00 
 418:	8d 45 f4             	lea    -0xc(%ebp),%eax
 41b:	89 44 24 04          	mov    %eax,0x4(%esp)
 41f:	8b 45 08             	mov    0x8(%ebp),%eax
 422:	89 04 24             	mov    %eax,(%esp)
 425:	e8 5a ff ff ff       	call   384 <write>
}
 42a:	c9                   	leave  
 42b:	c3                   	ret    

0000042c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 42c:	55                   	push   %ebp
 42d:	89 e5                	mov    %esp,%ebp
 42f:	56                   	push   %esi
 430:	53                   	push   %ebx
 431:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 434:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 43b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 43f:	74 17                	je     458 <printint+0x2c>
 441:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 445:	79 11                	jns    458 <printint+0x2c>
    neg = 1;
 447:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 44e:	8b 45 0c             	mov    0xc(%ebp),%eax
 451:	f7 d8                	neg    %eax
 453:	89 45 ec             	mov    %eax,-0x14(%ebp)
 456:	eb 06                	jmp    45e <printint+0x32>
  } else {
    x = xx;
 458:	8b 45 0c             	mov    0xc(%ebp),%eax
 45b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 45e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 465:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 468:	8d 41 01             	lea    0x1(%ecx),%eax
 46b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 46e:	8b 5d 10             	mov    0x10(%ebp),%ebx
 471:	8b 45 ec             	mov    -0x14(%ebp),%eax
 474:	ba 00 00 00 00       	mov    $0x0,%edx
 479:	f7 f3                	div    %ebx
 47b:	89 d0                	mov    %edx,%eax
 47d:	8a 80 4c 0b 00 00    	mov    0xb4c(%eax),%al
 483:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 487:	8b 75 10             	mov    0x10(%ebp),%esi
 48a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 48d:	ba 00 00 00 00       	mov    $0x0,%edx
 492:	f7 f6                	div    %esi
 494:	89 45 ec             	mov    %eax,-0x14(%ebp)
 497:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 49b:	75 c8                	jne    465 <printint+0x39>
  if(neg)
 49d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4a1:	74 10                	je     4b3 <printint+0x87>
    buf[i++] = '-';
 4a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4a6:	8d 50 01             	lea    0x1(%eax),%edx
 4a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4ac:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4b1:	eb 1e                	jmp    4d1 <printint+0xa5>
 4b3:	eb 1c                	jmp    4d1 <printint+0xa5>
    putc(fd, buf[i]);
 4b5:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4bb:	01 d0                	add    %edx,%eax
 4bd:	8a 00                	mov    (%eax),%al
 4bf:	0f be c0             	movsbl %al,%eax
 4c2:	89 44 24 04          	mov    %eax,0x4(%esp)
 4c6:	8b 45 08             	mov    0x8(%ebp),%eax
 4c9:	89 04 24             	mov    %eax,(%esp)
 4cc:	e8 33 ff ff ff       	call   404 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4d1:	ff 4d f4             	decl   -0xc(%ebp)
 4d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4d8:	79 db                	jns    4b5 <printint+0x89>
    putc(fd, buf[i]);
}
 4da:	83 c4 30             	add    $0x30,%esp
 4dd:	5b                   	pop    %ebx
 4de:	5e                   	pop    %esi
 4df:	5d                   	pop    %ebp
 4e0:	c3                   	ret    

000004e1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4e1:	55                   	push   %ebp
 4e2:	89 e5                	mov    %esp,%ebp
 4e4:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4e7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4ee:	8d 45 0c             	lea    0xc(%ebp),%eax
 4f1:	83 c0 04             	add    $0x4,%eax
 4f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4f7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4fe:	e9 77 01 00 00       	jmp    67a <printf+0x199>
    c = fmt[i] & 0xff;
 503:	8b 55 0c             	mov    0xc(%ebp),%edx
 506:	8b 45 f0             	mov    -0x10(%ebp),%eax
 509:	01 d0                	add    %edx,%eax
 50b:	8a 00                	mov    (%eax),%al
 50d:	0f be c0             	movsbl %al,%eax
 510:	25 ff 00 00 00       	and    $0xff,%eax
 515:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 518:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 51c:	75 2c                	jne    54a <printf+0x69>
      if(c == '%'){
 51e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 522:	75 0c                	jne    530 <printf+0x4f>
        state = '%';
 524:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 52b:	e9 47 01 00 00       	jmp    677 <printf+0x196>
      } else {
        putc(fd, c);
 530:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 533:	0f be c0             	movsbl %al,%eax
 536:	89 44 24 04          	mov    %eax,0x4(%esp)
 53a:	8b 45 08             	mov    0x8(%ebp),%eax
 53d:	89 04 24             	mov    %eax,(%esp)
 540:	e8 bf fe ff ff       	call   404 <putc>
 545:	e9 2d 01 00 00       	jmp    677 <printf+0x196>
      }
    } else if(state == '%'){
 54a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 54e:	0f 85 23 01 00 00    	jne    677 <printf+0x196>
      if(c == 'd'){
 554:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 558:	75 2d                	jne    587 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 55a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 55d:	8b 00                	mov    (%eax),%eax
 55f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 566:	00 
 567:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 56e:	00 
 56f:	89 44 24 04          	mov    %eax,0x4(%esp)
 573:	8b 45 08             	mov    0x8(%ebp),%eax
 576:	89 04 24             	mov    %eax,(%esp)
 579:	e8 ae fe ff ff       	call   42c <printint>
        ap++;
 57e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 582:	e9 e9 00 00 00       	jmp    670 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 587:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 58b:	74 06                	je     593 <printf+0xb2>
 58d:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 591:	75 2d                	jne    5c0 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 593:	8b 45 e8             	mov    -0x18(%ebp),%eax
 596:	8b 00                	mov    (%eax),%eax
 598:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 59f:	00 
 5a0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5a7:	00 
 5a8:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ac:	8b 45 08             	mov    0x8(%ebp),%eax
 5af:	89 04 24             	mov    %eax,(%esp)
 5b2:	e8 75 fe ff ff       	call   42c <printint>
        ap++;
 5b7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5bb:	e9 b0 00 00 00       	jmp    670 <printf+0x18f>
      } else if(c == 's'){
 5c0:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5c4:	75 42                	jne    608 <printf+0x127>
        s = (char*)*ap;
 5c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c9:	8b 00                	mov    (%eax),%eax
 5cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5ce:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5d6:	75 09                	jne    5e1 <printf+0x100>
          s = "(null)";
 5d8:	c7 45 f4 f7 08 00 00 	movl   $0x8f7,-0xc(%ebp)
        while(*s != 0){
 5df:	eb 1c                	jmp    5fd <printf+0x11c>
 5e1:	eb 1a                	jmp    5fd <printf+0x11c>
          putc(fd, *s);
 5e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e6:	8a 00                	mov    (%eax),%al
 5e8:	0f be c0             	movsbl %al,%eax
 5eb:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ef:	8b 45 08             	mov    0x8(%ebp),%eax
 5f2:	89 04 24             	mov    %eax,(%esp)
 5f5:	e8 0a fe ff ff       	call   404 <putc>
          s++;
 5fa:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 600:	8a 00                	mov    (%eax),%al
 602:	84 c0                	test   %al,%al
 604:	75 dd                	jne    5e3 <printf+0x102>
 606:	eb 68                	jmp    670 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 608:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 60c:	75 1d                	jne    62b <printf+0x14a>
        putc(fd, *ap);
 60e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 611:	8b 00                	mov    (%eax),%eax
 613:	0f be c0             	movsbl %al,%eax
 616:	89 44 24 04          	mov    %eax,0x4(%esp)
 61a:	8b 45 08             	mov    0x8(%ebp),%eax
 61d:	89 04 24             	mov    %eax,(%esp)
 620:	e8 df fd ff ff       	call   404 <putc>
        ap++;
 625:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 629:	eb 45                	jmp    670 <printf+0x18f>
      } else if(c == '%'){
 62b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 62f:	75 17                	jne    648 <printf+0x167>
        putc(fd, c);
 631:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 634:	0f be c0             	movsbl %al,%eax
 637:	89 44 24 04          	mov    %eax,0x4(%esp)
 63b:	8b 45 08             	mov    0x8(%ebp),%eax
 63e:	89 04 24             	mov    %eax,(%esp)
 641:	e8 be fd ff ff       	call   404 <putc>
 646:	eb 28                	jmp    670 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 648:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 64f:	00 
 650:	8b 45 08             	mov    0x8(%ebp),%eax
 653:	89 04 24             	mov    %eax,(%esp)
 656:	e8 a9 fd ff ff       	call   404 <putc>
        putc(fd, c);
 65b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 65e:	0f be c0             	movsbl %al,%eax
 661:	89 44 24 04          	mov    %eax,0x4(%esp)
 665:	8b 45 08             	mov    0x8(%ebp),%eax
 668:	89 04 24             	mov    %eax,(%esp)
 66b:	e8 94 fd ff ff       	call   404 <putc>
      }
      state = 0;
 670:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 677:	ff 45 f0             	incl   -0x10(%ebp)
 67a:	8b 55 0c             	mov    0xc(%ebp),%edx
 67d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 680:	01 d0                	add    %edx,%eax
 682:	8a 00                	mov    (%eax),%al
 684:	84 c0                	test   %al,%al
 686:	0f 85 77 fe ff ff    	jne    503 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 68c:	c9                   	leave  
 68d:	c3                   	ret    
 68e:	90                   	nop
 68f:	90                   	nop

00000690 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 690:	55                   	push   %ebp
 691:	89 e5                	mov    %esp,%ebp
 693:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 696:	8b 45 08             	mov    0x8(%ebp),%eax
 699:	83 e8 08             	sub    $0x8,%eax
 69c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 69f:	a1 68 0b 00 00       	mov    0xb68,%eax
 6a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6a7:	eb 24                	jmp    6cd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ac:	8b 00                	mov    (%eax),%eax
 6ae:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6b1:	77 12                	ja     6c5 <free+0x35>
 6b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6b9:	77 24                	ja     6df <free+0x4f>
 6bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6be:	8b 00                	mov    (%eax),%eax
 6c0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6c3:	77 1a                	ja     6df <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c8:	8b 00                	mov    (%eax),%eax
 6ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6d3:	76 d4                	jbe    6a9 <free+0x19>
 6d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d8:	8b 00                	mov    (%eax),%eax
 6da:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6dd:	76 ca                	jbe    6a9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e2:	8b 40 04             	mov    0x4(%eax),%eax
 6e5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ef:	01 c2                	add    %eax,%edx
 6f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f4:	8b 00                	mov    (%eax),%eax
 6f6:	39 c2                	cmp    %eax,%edx
 6f8:	75 24                	jne    71e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fd:	8b 50 04             	mov    0x4(%eax),%edx
 700:	8b 45 fc             	mov    -0x4(%ebp),%eax
 703:	8b 00                	mov    (%eax),%eax
 705:	8b 40 04             	mov    0x4(%eax),%eax
 708:	01 c2                	add    %eax,%edx
 70a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 710:	8b 45 fc             	mov    -0x4(%ebp),%eax
 713:	8b 00                	mov    (%eax),%eax
 715:	8b 10                	mov    (%eax),%edx
 717:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71a:	89 10                	mov    %edx,(%eax)
 71c:	eb 0a                	jmp    728 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 71e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 721:	8b 10                	mov    (%eax),%edx
 723:	8b 45 f8             	mov    -0x8(%ebp),%eax
 726:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 728:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72b:	8b 40 04             	mov    0x4(%eax),%eax
 72e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 735:	8b 45 fc             	mov    -0x4(%ebp),%eax
 738:	01 d0                	add    %edx,%eax
 73a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 73d:	75 20                	jne    75f <free+0xcf>
    p->s.size += bp->s.size;
 73f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 742:	8b 50 04             	mov    0x4(%eax),%edx
 745:	8b 45 f8             	mov    -0x8(%ebp),%eax
 748:	8b 40 04             	mov    0x4(%eax),%eax
 74b:	01 c2                	add    %eax,%edx
 74d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 750:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 753:	8b 45 f8             	mov    -0x8(%ebp),%eax
 756:	8b 10                	mov    (%eax),%edx
 758:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75b:	89 10                	mov    %edx,(%eax)
 75d:	eb 08                	jmp    767 <free+0xd7>
  } else
    p->s.ptr = bp;
 75f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 762:	8b 55 f8             	mov    -0x8(%ebp),%edx
 765:	89 10                	mov    %edx,(%eax)
  freep = p;
 767:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76a:	a3 68 0b 00 00       	mov    %eax,0xb68
}
 76f:	c9                   	leave  
 770:	c3                   	ret    

00000771 <morecore>:

static Header*
morecore(uint nu)
{
 771:	55                   	push   %ebp
 772:	89 e5                	mov    %esp,%ebp
 774:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 777:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 77e:	77 07                	ja     787 <morecore+0x16>
    nu = 4096;
 780:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 787:	8b 45 08             	mov    0x8(%ebp),%eax
 78a:	c1 e0 03             	shl    $0x3,%eax
 78d:	89 04 24             	mov    %eax,(%esp)
 790:	e8 57 fc ff ff       	call   3ec <sbrk>
 795:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 798:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 79c:	75 07                	jne    7a5 <morecore+0x34>
    return 0;
 79e:	b8 00 00 00 00       	mov    $0x0,%eax
 7a3:	eb 22                	jmp    7c7 <morecore+0x56>
  hp = (Header*)p;
 7a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ae:	8b 55 08             	mov    0x8(%ebp),%edx
 7b1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b7:	83 c0 08             	add    $0x8,%eax
 7ba:	89 04 24             	mov    %eax,(%esp)
 7bd:	e8 ce fe ff ff       	call   690 <free>
  return freep;
 7c2:	a1 68 0b 00 00       	mov    0xb68,%eax
}
 7c7:	c9                   	leave  
 7c8:	c3                   	ret    

000007c9 <malloc>:

void*
malloc(uint nbytes)
{
 7c9:	55                   	push   %ebp
 7ca:	89 e5                	mov    %esp,%ebp
 7cc:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7cf:	8b 45 08             	mov    0x8(%ebp),%eax
 7d2:	83 c0 07             	add    $0x7,%eax
 7d5:	c1 e8 03             	shr    $0x3,%eax
 7d8:	40                   	inc    %eax
 7d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7dc:	a1 68 0b 00 00       	mov    0xb68,%eax
 7e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7e4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7e8:	75 23                	jne    80d <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 7ea:	c7 45 f0 60 0b 00 00 	movl   $0xb60,-0x10(%ebp)
 7f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7f4:	a3 68 0b 00 00       	mov    %eax,0xb68
 7f9:	a1 68 0b 00 00       	mov    0xb68,%eax
 7fe:	a3 60 0b 00 00       	mov    %eax,0xb60
    base.s.size = 0;
 803:	c7 05 64 0b 00 00 00 	movl   $0x0,0xb64
 80a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 80d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 810:	8b 00                	mov    (%eax),%eax
 812:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 815:	8b 45 f4             	mov    -0xc(%ebp),%eax
 818:	8b 40 04             	mov    0x4(%eax),%eax
 81b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 81e:	72 4d                	jb     86d <malloc+0xa4>
      if(p->s.size == nunits)
 820:	8b 45 f4             	mov    -0xc(%ebp),%eax
 823:	8b 40 04             	mov    0x4(%eax),%eax
 826:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 829:	75 0c                	jne    837 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 82b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82e:	8b 10                	mov    (%eax),%edx
 830:	8b 45 f0             	mov    -0x10(%ebp),%eax
 833:	89 10                	mov    %edx,(%eax)
 835:	eb 26                	jmp    85d <malloc+0x94>
      else {
        p->s.size -= nunits;
 837:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83a:	8b 40 04             	mov    0x4(%eax),%eax
 83d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 840:	89 c2                	mov    %eax,%edx
 842:	8b 45 f4             	mov    -0xc(%ebp),%eax
 845:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 848:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84b:	8b 40 04             	mov    0x4(%eax),%eax
 84e:	c1 e0 03             	shl    $0x3,%eax
 851:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 854:	8b 45 f4             	mov    -0xc(%ebp),%eax
 857:	8b 55 ec             	mov    -0x14(%ebp),%edx
 85a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 85d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 860:	a3 68 0b 00 00       	mov    %eax,0xb68
      return (void*)(p + 1);
 865:	8b 45 f4             	mov    -0xc(%ebp),%eax
 868:	83 c0 08             	add    $0x8,%eax
 86b:	eb 38                	jmp    8a5 <malloc+0xdc>
    }
    if(p == freep)
 86d:	a1 68 0b 00 00       	mov    0xb68,%eax
 872:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 875:	75 1b                	jne    892 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 877:	8b 45 ec             	mov    -0x14(%ebp),%eax
 87a:	89 04 24             	mov    %eax,(%esp)
 87d:	e8 ef fe ff ff       	call   771 <morecore>
 882:	89 45 f4             	mov    %eax,-0xc(%ebp)
 885:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 889:	75 07                	jne    892 <malloc+0xc9>
        return 0;
 88b:	b8 00 00 00 00       	mov    $0x0,%eax
 890:	eb 13                	jmp    8a5 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 892:	8b 45 f4             	mov    -0xc(%ebp),%eax
 895:	89 45 f0             	mov    %eax,-0x10(%ebp)
 898:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89b:	8b 00                	mov    (%eax),%eax
 89d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8a0:	e9 70 ff ff ff       	jmp    815 <malloc+0x4c>
}
 8a5:	c9                   	leave  
 8a6:	c3                   	ret    
